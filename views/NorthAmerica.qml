import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.4

import QtPositioning 5.3

import "../controls" as Controls

Page {
    id: pageItem
    property real scaleFactor: AppFramework.displayScaleFactor
    property url wms2wkServiceUrl: "http://floodobservatory.colorado.edu/geoserver/DFO_2wk_current_NA/wms?service=wms&request=getCapabilities";
    property url wms3dayServiceUrl: "http://floodobservatory.colorado.edu/geoserver/DFO_3day_current_NA/wms?service=wms&request=getCapabilities";
    property url wmsJanServiceUrl: "http://floodobservatory.colorado.edu/geoserver/DFO_Jan_till_current_NA/wms?service=wms&request=getCapabilities";
    property url wmsRegWServiceUrl: "http://floodobservatory.colorado.edu/geoserver/Permanent_water_2013-2016-na/wms?service=wms&request=getCapabilities";

    property url wmsEventServiceUrl: "http://floodobservatory.colorado.edu/geoserver/Events_NA/wms?service=wms&request=getCapabilities";
    property url wmsGlofasServiceUrl: "http://globalfloods-ows.ecmwf.int/glofas-ows/ows.py?service=wms&request=getCapabilities";

    property WmsService service2wk;
    property WmsLayerInfo layerNA2wk;
    property WmsLayer wmsLayer2wk;

    property WmsService service3day;
    property WmsLayerInfo layerNA3day;
    property WmsLayer wmsLayer3day;

    property WmsService serviceJan;
    property WmsLayerInfo layerNAJan;
    property WmsLayer wmsLayerJan;

    property WmsService serviceRegW;
    property WmsLayerInfo layerNARegW;
    property WmsLayer wmsLayerRegW;

    property WmsService serviceEv
    property WmsLayerInfo layerNAEv;
    property WmsLayer wmsLayerEv;

    property WmsService serviceGlo
    property WmsLayerInfo layerGlo;
    property WmsLayer wmsLayerGlo;
    property var layerGloSL;

    property WmsService serviceCu
    property WmsLayerInfo layerCu;
    property WmsLayer wmsLayerCu;
    property var layerCuSL;

    property Scene scene;
    property string descriptionLyr;

    property bool drawPin: false;
    property Point pinLocation;
    property SimpleMarkerSceneSymbol symbolMarker;

    header: ToolBar {
        id: header
        width: parent.width
        height: 50 * scaleFactor
        Material.background: "#00693e"
        Controls.HeaderBar{}

        ToolButton {
            id: menuButton
            width: 45 * scaleFactor
            height: 45 * scaleFactor
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                leftMargin: 8
            }

            indicator: Image {
                source: "../assets/menu.png"
                anchors.fill: parent
            }

            onClicked: if (sceneView.scene.operationalLayers.count >= 4) {
                           layerList = sceneView.scene.operationalLayers;

                           menu.open();
                       }
        }
    }

    ViewpointCenter {
        id: initView
        center: Point {
            x: -11e6
            y: 6e6
            spatialReference: SpatialReference {wkid: 102100}
        }
        targetScale: 9e7
    }

    // Create SceneView
    SceneView {
        id:sceneView
//        property alias compass: compass

        anchors.fill: parent

        //Busy Indicator
        BusyIndicator {
            anchors.centerIn: parent
            height: 48 * scaleFactor
            width: height
            running: true
            Material.accent:"#00693e"
            visible: (sceneView.drawStatus === Enums.DrawStatusInProgress)
        }

        PositionSource {
            id: positionSource
            active: true
            property bool isInitial: true
            onPositionChanged: {
                if(sceneView.scene !== null && sceneView.scene.loadStatus === Enums.LoadStatusLoaded && isInitial) {
                    isInitial = false;
                    zoomToRegionLocation();

                    function zoomToRegionLocation(){
                        positionSource.update();
                        var currentPositionPoint = ArcGISRuntimeEnvironment.createObject("Point", {x: -100.005218, y: 38.411692, spatialReference: SpatialReference.createWgs84()});
                        var centerPoint = GeometryEngine.project(currentPositionPoint, sceneView.spatialReference);

                        var viewPointCenter = ArcGISRuntimeEnvironment.createObject("ViewpointCenter",{center: centerPoint});
                        sceneView.setViewpoint(viewPointCenter);
                    }
                }
            }
        }

        // add a graphics overlay
        GraphicsOverlay {
            id: graphicsOverlay
        }

        onMouseClicked: {
            pinMessage.visible = 0;
            if (drawPin === true) {
                function toRad(Value) {
                    /** Converts numeric degrees to radians */
                    return Value * Math.PI / 180;
                }

                function haversine(lat1,lat2,lng1,lng2) {
                    var rad = 6372.8; // for km Use 3961 for miles
                    var deltaLat = toRad(lat2-lat1);
                    var deltaLng = toRad(lng2-lng1);
                    lat1 = toRad(lat1);
                    lat2 = toRad(lat2);
                    var a = Math.sin(deltaLat/2) * Math.sin(deltaLat/2) + Math.sin(deltaLng/2) * Math.sin(deltaLng/2) * Math.cos(lat1) * Math.cos(lat2);
                    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
                    return  rad * c;
                }

                pinLocation = mouse.mapPoint;
                var xCoor = mouse.mapPoint.x.toFixed(2);
                var yCoor = mouse.mapPoint.y.toFixed(2);

                symbolMarker = ArcGISRuntimeEnvironment.createObject("SimpleMarkerSceneSymbol", {
                                                                         style: Enums.SimpleMarkerSceneSymbolStyleSphere,
                                                                         color: "#00693e",
                                                                         width: 75,
                                                                         height: 75,
                                                                         depth: 75,
                                                                     });

                // create a graphic using the point and the symbol
                var graphic = ArcGISRuntimeEnvironment.createObject("Graphic", {
                                                                        geometry: pinLocation,
                                                                        symbol: symbolMarker
                                                                    });

                // clear previous and add new  graphic to the graphics overlay
                graphicsOverlay.graphics.clear();
                graphicsOverlay.graphics.append(graphic);

                serviceEv = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wmsEventServiceUrl });

                serviceEv.loadStatusChanged.connect(function() {
                    if (serviceEv.loadStatus === Enums.LoadStatusLoaded) {
                        // get the layer info list
                        var serviceEvInfo = serviceEv.serviceInfo;
                        var layerInfos = serviceEvInfo.layerInfos;

                        // get the all layers
                        var layerNAEvTiles = layerInfos[0].sublayerInfos;

                        var nearestTile = [999999999, 1];

                        for (var i=2; i<layerNAEvTiles.length; i++) {
                            var ans = haversine(yCoor, layerInfos[0].sublayerInfos[i].extent.center.y,
                                                xCoor, layerInfos[0].sublayerInfos[i].extent.center.x
                                                );
                            if (ans < nearestTile[0]) {

                                nearestTile = [ans, i];
                            }
                        }

                        layerNAEv = layerInfos[0].sublayerInfos[nearestTile[1]]


                        wmsLayerEv = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                               layerInfos: [layerNAEv],
                                                                               visible: true
                                                                           });

                        sceneView.scene.operationalLayers.insert(0, wmsLayerEv);
                        sceneView.scene.operationalLayers.setProperty(0, "name", "Nearest Event");
                        sceneView.scene.operationalLayers.setProperty(0, "description", layerNAEv.description);

                        graphicsOverlay.graphics.clear();

                        var newViewPointCenter = ArcGISRuntimeEnvironment.createObject("ViewpointCenter", {
                                                                                           center: layerInfos[0].sublayerInfos[nearestTile[1]].extent.center,
                                                                                           targetScale: 1000000 * layerInfos[0].sublayerInfos[nearestTile[1]].extent.width * scaleFactor
                                                                                       });
                        sceneView.setViewpoint(newViewPointCenter);


                    }
                });

                serviceEv.load();

            }
        }

        Component.onCompleted: createWmsLayer();

        function createWmsLayer() {
            var basemap = ArcGISRuntimeEnvironment.createObject("BasemapTopographic");

            // create a scene
            scene = ArcGISRuntimeEnvironment.createObject("Scene", {
                                                              basemap: basemap,
                                                              initialViewpoint: initView,
                                                          });

            // create the services
            service2wk = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wms2wkServiceUrl });
            service3day = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wms3dayServiceUrl });
            serviceJan = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wmsJanServiceUrl });
            serviceRegW = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wmsRegWServiceUrl });
            serviceGlo = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wmsGlofasServiceUrl });

            serviceGlo.loadStatusChanged.connect(function() {
                if (serviceGlo.loadStatus === Enums.LoadStatusLoaded) {
                    var serviceGloInfo = serviceGlo.serviceInfo;
                    var layerInfos = serviceGloInfo.layerInfos;

                    // get the all layers
                    layerGloSL = layerInfos[0].sublayerInfos[3].sublayerInfos;
                }
            });

            service2wk.loadStatusChanged.connect(function() {
                if (service2wk.loadStatus === Enums.LoadStatusLoaded) {
                    // get the layer info list
                    var service2wkInfo = service2wk.serviceInfo;
                    var layerInfos = service2wkInfo.layerInfos;

                    // get the desired layer from the list
                    layerNA2wk = layerInfos[0].sublayerInfos[0]

                    wmsLayer2wk = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                            layerInfos: [layerNA2wk]
                                                                        });

                    scene.operationalLayers.insert(0, wmsLayer2wk);
                    scene.operationalLayers.setProperty(0, "description", layerNA2wk.description);
                }
            });

            service3day.loadStatusChanged.connect(function() {
                if (service3day.loadStatus === Enums.LoadStatusLoaded) {
                    // get the layer info list
                    var service3dayInfo = service3day.serviceInfo;
                    var layerInfos = service3dayInfo.layerInfos;

                    // get the desired layer from the list
                    layerNA3day = layerInfos[0].sublayerInfos[0]

                    wmsLayer3day = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                             layerInfos: [layerNA3day]
                                                                         });

                    scene.operationalLayers.insert(1, wmsLayer3day);
                    scene.operationalLayers.setProperty(1, "description", layerNA3day.description);

                }
            });

            serviceJan.loadStatusChanged.connect(function() {
                if (serviceJan.loadStatus === Enums.LoadStatusLoaded) {
                    // get the layer info list
                    var serviceJanInfo = serviceJan.serviceInfo;
                    var layerInfos = serviceJanInfo.layerInfos;

                    // get the desired layer from the list
                    layerNAJan = layerInfos[0].sublayerInfos[0]

                    wmsLayerJan = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                            layerInfos: [layerNAJan],
                                                                            visible: false
                                                                        });

                    scene.operationalLayers.insert(2, wmsLayerJan);
                    scene.operationalLayers.setProperty(2, "description", layerNAJan.description);
                }
            });

            serviceRegW.loadStatusChanged.connect(function() {
                if (serviceRegW.loadStatus === Enums.LoadStatusLoaded) {
                    // get the layer info list
                    var serviceRegWInfo = serviceRegW.serviceInfo;
                    var layerInfos = serviceRegWInfo.layerInfos;

                    // get the desired layer from the list
                    layerNARegW = layerInfos[0].sublayerInfos[0]

                    wmsLayerRegW = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                             layerInfos: [layerNARegW],
                                                                             visible: false
                                                                         });

                    scene.operationalLayers.append(wmsLayerRegW);
                    scene.operationalLayers.setProperty(3, "description", layerNARegW.description);
                }
            });

            // load the services
            service2wk.load();
            service3day.load();
            serviceJan.load();
            serviceRegW.load();
            serviceGlo.load();

            // set the scene on the sceneview
            sceneView.scene = scene;
        }
    }

    Controls.MenuDrawer {
        id:menu
    }

    Controls.FloatActionButton {
        id:switchBtn
    }

    Controls.CurrentPositionBtn {
        id:locationBtn
    }

    Controls.DescriptionLayer {
        id:descLyrPage
        visible: false
    }
}
