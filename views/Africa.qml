import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.5

import QtPositioning 5.3

import "../controls" as Controls

Page {
    id: pageItem
    property real scaleFactor: AppFramework.displayScaleFactor
    property url wms3dayServiceUrl: "http://floodobservatory.colorado.edu/geoserver/AF_3day_rs/wms?service=wms&request=getCapabilities";
    property url wms2wkServiceUrl: "http://floodobservatory.colorado.edu/geoserver/AF_2wk_rs/wms?service=wms&request=getCapabilities";
    property url wmsJanServiceUrl: "http://floodobservatory.colorado.edu/geoserver/DFO_rs_Jan_till_current_AF/wms?service=wms&request=getCapabilities";
    property url wmsRegWServiceUrl: "http://floodobservatory.colorado.edu/geoserver/Permanent_water_2013-2016-af/wms?service=wms&request=getCapabilities";
    property url wmsHistWServiceUrl: "http://floodobservatory.colorado.edu/geoserver/MOD_history_AF/wms?service=wms&request=getCapabilities";
    property url wmsEventServiceUrl: "http://floodobservatory.colorado.edu/geoserver/Events_AF/wms?service=wms&request=getCapabilities";
    property url wmsWorldPopServiceUrl: "http://floodobservatory.colorado.edu/geoserver/AF_population/wms?service=wms&request=getCapabilities";
    property url filteredEventServiceUrl: wmsEventServiceUrl;
    property var availableEventYears: ["All","2017","2018","2019"];

    property ListModel legendModel: ListModel {
        id: legendModel
        ListElement {name: "Regular Water Extent"; symbolUrl: "../assets/legend_icons/regW_white.png"; visible: true}
        ListElement {name: "Current Daily Flooded Area / Clouds"; symbolUrl: "../assets/legend_icons/3day_red.png"; visible: true}
        ListElement {name: "Two Week Flooded Area"; symbolUrl: "../assets/legend_icons/2wk_blue.png"; visible: true}
        ListElement {name: "January till Current Flooded Area"; symbolUrl: "../assets/legend_icons/jant_cyan.png"; visible: false}
        ListElement {name: "Historical Water Extent"; symbolUrl: "../assets/legend_icons/histW_gray.png"; visible: false}
    }

    property var defaultLayersArr: ["Regular Water Extent", "Current Daily Flooded Area / Clouds", "Two Week Flooded Area", "January till Current Flooded Area", "Historical Water Extent", "All Extreme Events", "Nearest Extreme Event"];

    property WmsService service2wk;
    property WmsLayer wmsLayer2wk;

    property WmsService service3day;
    property WmsLayer wmsLayer3day;

    property WmsService serviceJan;
    property WmsLayer wmsLayerJan;

    property WmsService serviceRegW;
    property WmsLayer wmsLayerRegW;

    property WmsService serviceHistW;
    property WmsLayer wmsLayerHistW;

    property WmsService serviceEv;
    property list<WmsLayerInfo> layerNAEv;
    property WmsLayer wmsLayerEv;

    property WmsService servicePop;

    property WmsService serviceCu
    property WmsLayerInfo layerCu;
    property WmsLayer wmsLayerCu;
    property var layerCuSL;

    property string descriptionLyr;
    property string compLyrName;

    property double radiusSearch;
    property string radiusSearchUnits;
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

            onClicked: {
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
                        var currentPositionPoint = ArcGISRuntimeEnvironment.createObject("Point", {x: 19.675945, y: 5.579062, spatialReference: SpatialReference.createWgs84()});
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

        Scene {
            id: scene
            initialViewpoint: initView

            onLoadStatusChanged: {
                if (scene.loadStatus === Enums.LoadStatusLoaded) {
                    if (layerVisibilityListView) {
                        layerVisibilityListView.forceLayout();
                    }
                }
            }
        }

        // Create outter rectangle for the legend
        Rectangle {
            id: legendRect
            anchors {
                margins: 10 * scaleFactor
                bottomMargin: 30 * scaleFactor
                left: parent.left
                bottom: sceneView.bottom
            }
            property bool collapsed: true
            height: 40 * scaleFactor
            width: 48 * scaleFactor
            color: "#00693e"
            opacity: 0.95
            radius: 10 * scaleFactor
            clip: true

            // Animate the expand and collapse of the legend
            Behavior on height {
                SpringAnimation {
                    spring: 3
                    damping: .8
                }
            }

            Behavior on width {
                SpringAnimation {
                    spring: 3
                    damping: .8
                }
            }

            // Catch mouse signals so they don't propagate to the map
            MouseArea {
                anchors.fill: parent
                onClicked: mouse.accepted = true
                onWheel: wheel.accepted = true
            }

            // Create UI for the user to select the layer to display
            Column {
                anchors {
                    fill: parent
                    leftMargin: 10 * scaleFactor
                    rightMargin: 10 * scaleFactor
                    bottomMargin: 6 * scaleFactor
                    topMargin: 6 * scaleFactor
                }
                spacing: 6 * scaleFactor

                Row {
                    id: legendTitleRow
                    spacing: 55 * scaleFactor

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        color: "white"
                        font {
                            pixelSize: 18 * scaleFactor
                            bold: true
                        }
                    }

                    // Legend icon to allow expanding and collapsing
                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        source: "../assets/legend.png"
                        width: 28 * scaleFactor
                        height: width

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (legendRect.collapsed) {
                                    legendTitleRow.children[0].text = qsTr("Legend");
                                    legendRect.width = 175 * scaleFactor;
                                    legendRect.height = 200 * scaleFactor < pageItem.height - 85 * scaleFactor ? 200 * scaleFactor : pageItem.height - 85 * scaleFactor;
                                    legendRect.collapsed = false;
                                } else {
                                    legendTitleRow.children[0].text = "";
                                    legendRect.width = 48 * scaleFactor;
                                    legendRect.height = 40 * scaleFactor;
                                    legendRect.collapsed = true;
                                }
                            }
                        }
                    }
                }

                // Create a list view to display the legend
                ListView {
                    id: legendListView
                    anchors.margins: 10 * scaleFactor
                    anchors.leftMargin: 0
                    width: 165 * scaleFactor
                    height: 160 * scaleFactor
                    contentHeight: childrenRect.height

                    model: legendModel

                    delegate: Item {
                        id: legendDelegate
                        width: parent.width
                        height: model.visible ? (defaultLayersArr.indexOf(model.name) === -1 ? childrenRect.height + 10 * scaleFactor : 35 * scaleFactor) : 0
                        visible: model.visible
                        clip: true

                        Rectangle {
                            id: legendInnerRect
                            height: childrenRect.height

                            Row {
                                id: legendRow
                                height: 35 * scaleFactor
                                spacing: 10 * scaleFactor

                                Image {
                                    id: legendSymbol
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    id: legendText
                                    width: defaultLayersArr.indexOf(model.name) === -1 ? 150 * scaleFactor : (150 * scaleFactor) - legendSymbol.width
                                    text: name
                                    color: "white"
                                    wrapMode: Text.Wrap
                                    font.pixelSize: 12 * scaleFactor
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Component.onCompleted: {
                                if (defaultLayersArr.indexOf(model.name) === -1) {
                                    legendRow.children[0].destroy();
                                    if (name.includes("ECMWF ")) {
                                        Qt.createQmlObject('import QtQuick 2.7; Rectangle {width: 0.65 * legendListView.width; height: childrenRect.height; color: "transparent"; clip: true; anchors.top: legendRow.bottom; Image {id: legendSymbol; source: symbolUrl}}', legendInnerRect);
                                    } else {
                                        Qt.createQmlObject('import QtQuick 2.7; Image {id: legendSymbol; source: symbolUrl; anchors.top: legendRow.bottom}', legendInnerRect);
                                    }
                                } else {
                                    legendSymbol.source = symbolUrl;
                                }
                            }
                        }
                    }
                    clip: true;
                }
            }
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
                    if (radiusSearchUnits === 'km') {
                        rad = 6372.8;
                    } else if (radiusSearchUnits === 'mi') {
                        rad = 3961;
                    }
                    var deltaLat = toRad(lat2-lat1);
                    var deltaLng = toRad(lng2-lng1);
                    lat1 = toRad(lat1);
                    lat2 = toRad(lat2);
                    var a = Math.sin(deltaLat/2) * Math.sin(deltaLat/2) + Math.sin(deltaLng/2) * Math.sin(deltaLng/2) * Math.cos(lat1) * Math.cos(lat2);
                    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
                    return  rad * c;
                }

                function insidePolygon(point, tile) {
                    var x = point[0], y = point[1];

                    var inside = false;
                    for (var i = 0, j = tile.length - 1; i < tile.length; j = i++) {
                        var xi = tile[i][0], yi = tile[i][1];
                        var xj = tile[j][0], yj = tile[j][1];

                        var intersect = ((yi > y) != (yj > y))
                            && (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
                        if (intersect) inside = !inside;
                    }

                    return inside;
                };

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

                sceneView.scene.operationalLayers.forEach(function (lyr, ix) {
                    if (lyr.name === "Nearest Events") {
                        sceneView.scene.operationalLayers.remove(ix, 1);
                    }
                });

                serviceEv = ArcGISRuntimeEnvironment.createObject("WmsService", { url: filteredEventServiceUrl });

                serviceEv.loadStatusChanged.connect(function() {
                    if (serviceEv.loadStatus === Enums.LoadStatusLoaded) {
                        // get the layer info list
                        var serviceEvInfo = serviceEv.serviceInfo;
                        var layerInfos = serviceEvInfo.layerInfos;

                        // get the all layers
                        var layerNAEvTiles = layerInfos[0].sublayerInfos;

                        var nearestTileList = [];

                        for (var i=2; i<layerNAEvTiles.length; i++) {
                            var inside = insidePolygon([xCoor, yCoor], [[layerInfos[0].sublayerInfos[i].extent.xMin, layerInfos[0].sublayerInfos[i].extent.yMin],
                                                                        [layerInfos[0].sublayerInfos[i].extent.xMin, layerInfos[0].sublayerInfos[i].extent.yMax],
                                                                        [layerInfos[0].sublayerInfos[i].extent.xMax, layerInfos[0].sublayerInfos[i].extent.yMax],
                                                                        [layerInfos[0].sublayerInfos[i].extent.xMax, layerInfos[0].sublayerInfos[i].extent.yMin]
                                                       ]);

                            if (inside) {
                                nearestTileList.push([0, i]);
                                continue;
                            }

                            var ans = haversine(yCoor, layerInfos[0].sublayerInfos[i].extent.center.y,
                                                xCoor, layerInfos[0].sublayerInfos[i].extent.center.x
                                                );

                            var ans1 = haversine(yCoor, layerInfos[0].sublayerInfos[i].extent.xMax,
                                                 xCoor, layerInfos[0].sublayerInfos[i].extent.yMin
                                                 );

                            var ans2 = haversine(yCoor, layerInfos[0].sublayerInfos[i].extent.xMax,
                                                 xCoor, layerInfos[0].sublayerInfos[i].extent.yMax
                                                 );

                            var ans3 = haversine(yCoor, layerInfos[0].sublayerInfos[i].extent.xMin,
                                                 xCoor, layerInfos[0].sublayerInfos[i].extent.yMin
                                                 );

                            var ans4 = haversine(yCoor, layerInfos[0].sublayerInfos[i].extent.xMin,
                                                 xCoor, layerInfos[0].sublayerInfos[i].extent.yMax
                                                 );

                            if (ans < radiusSearch) {
                                nearestTileList.push([ans, i]);
                            } else if (ans1 < radiusSearch) {
                                nearestTileList.push([ans1, i]);
                            } else if (ans2 < radiusSearch) {
                                nearestTileList.push([ans2, i]);
                            } else if (ans3 < radiusSearch) {
                                nearestTileList.push([ans3, i]);
                            } else if (ans4 < radiusSearch) {
                                nearestTileList.push([ans4, i]);
                            }
                        }

                        layerNAEv = [];

                        if (nearestTileList.length > 0) {
                            nearestTileList.forEach(function (elm) {
                                layerNAEv.push(layerInfos[0].sublayerInfos[elm[1]])
                            });

                            wmsLayerEv = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                                   layerInfos: layerNAEv,
                                                                                   visible: true
                                                                               });

                            sceneView.scene.operationalLayers.append(wmsLayerEv);
                            sceneView.scene.operationalLayers.setProperty(sceneView.scene.operationalLayers.indexOf(wmsLayerEv), "name", "Nearest Events");
                            sceneView.scene.operationalLayers.setProperty(sceneView.scene.operationalLayers.indexOf(wmsLayerEv), "description", layerNAEv.description);

                            graphicsOverlay.graphics.clear();

                            var newViewPointCenter = ArcGISRuntimeEnvironment.createObject("ViewpointCenter", {
                                                                                               center: layerInfos[0].sublayerInfos[nearestTileList[0][1]].extent.center,
                                                                                               targetScale: 1000000 * layerInfos[0].sublayerInfos[nearestTileList[0][1]].extent.width * scaleFactor
                                                                                           });
                            sceneView.setViewpoint(newViewPointCenter);

                            legendModel.insert(0, {name: "Nearest Extreme Event", symbolUrl: "../assets/legend_icons/x_events_red.png", visible: true});
                        } else {
                            pinMessage.children[0].text = qsTr("No nearby event found");
                            pinMessage.visible = 1;
                        }
                    }
                });

                serviceEv.load();

            }
        }

        Component.onCompleted: createWmsLayer();

        function createWmsLayer() {
            // set the default basemap
            scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapImageryWithLabels");

            // create the services
            serviceRegW = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wmsRegWServiceUrl });
            service3day = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wms3dayServiceUrl });
            service2wk = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wms2wkServiceUrl });
            serviceJan = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wmsJanServiceUrl });
            serviceHistW = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wmsHistWServiceUrl });

            // suggested services
            serviceGlo = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wmsGlofasServiceUrl });
            serviceFF = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wmsFloodFreqServiceUrl });
            serviceStations = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wmsStationsServiceUrl });
            servicePop = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wmsWorldPopServiceUrl });

            serviceRegW.loadStatusChanged.connect(function() {
                if (serviceRegW.loadStatus === Enums.LoadStatusLoaded) {
                    // get the layer info list
                    var serviceRegWInfo = serviceRegW.serviceInfo;
                    var layerInfos = serviceRegWInfo.layerInfos;

                    // get the desired layer from the list
                    layerRegW = layerInfos[0].sublayerInfos[0]

                    wmsLayerRegW = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                             layerInfos: [layerRegW],
                                                                         });

                    scene.operationalLayers.append(wmsLayerRegW);
                    scene.operationalLayers.setProperty(scene.operationalLayers.indexOf(wmsLayerRegW), "name", layerRegW.title);
                    scene.operationalLayers.setProperty(scene.operationalLayers.indexOf(wmsLayerRegW), "description", layerRegW.description);
                }
            });

            service3day.loadStatusChanged.connect(function() {
                if (service3day.loadStatus === Enums.LoadStatusLoaded) {
                    // get the layer info list
                    var service3dayInfo = service3day.serviceInfo;
                    var layerInfos = service3dayInfo.layerInfos;

                    // get the desired layer from the list
                    layer3day = layerInfos[0].sublayerInfos[0]

                    wmsLayer3day = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                             layerInfos: [layer3day],
                                                                         });

                    scene.operationalLayers.append(wmsLayer3day);
                    scene.operationalLayers.setProperty(scene.operationalLayers.indexOf(wmsLayer3day), "name", layer3day.title);
                    scene.operationalLayers.setProperty(scene.operationalLayers.indexOf(wmsLayer3day), "description", layer3day.description);

                    serviceRegW.load();
                } else if (service3day.loadStatus === Enums.LoadStatusFailedToLoad ||
                           service3day.loadStatus === Enums.LoadStatusNotLoaded ||
                           service3day.loadStatus === Enums.LoadStatusUnknown) {
                    serviceRegW.load();
                }
            });

            service2wk.loadStatusChanged.connect(function() {
                if (service2wk.loadStatus === Enums.LoadStatusLoaded) {
                    // get the layer info list
                    var service2wkInfo = service2wk.serviceInfo;
                    var layerInfos = service2wkInfo.layerInfos;

                    // get the desired layer from the list
                    layer2wk = layerInfos[0].sublayerInfos[0]

                    wmsLayer2wk = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                            layerInfos: [layer2wk]
                                                                        });

                    scene.operationalLayers.append(wmsLayer2wk);
                    scene.operationalLayers.setProperty(scene.operationalLayers.indexOf(wmsLayer2wk), "name", layer2wk.title);
                    scene.operationalLayers.setProperty(scene.operationalLayers.indexOf(wmsLayer2wk), "description", layer2wk.description);

                    service3day.load();
                } else if (service2wk.loadStatus === Enums.LoadStatusFailedToLoad ||
                           service2wk.loadStatus === Enums.LoadStatusNotLoaded ||
                           service2wk.loadStatus === Enums.LoadStatusUnknown) {
                    service3day.load();
                }
            });

            serviceJan.loadStatusChanged.connect(function() {
                if (serviceJan.loadStatus === Enums.LoadStatusLoaded) {
                    // get the layer info list
                    var serviceJanInfo = serviceJan.serviceInfo;
                    var layerInfos = serviceJanInfo.layerInfos;

                    // get the desired layer from the list
                    layerJan = layerInfos[0].sublayerInfos[0]

                    wmsLayerJan = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                            layerInfos: [layerJan],
                                                                            visible: false
                                                                        });

                    scene.operationalLayers.append(wmsLayerJan);
                    scene.operationalLayers.setProperty(scene.operationalLayers.indexOf(wmsLayerJan), "name", layerJan.title);
                    scene.operationalLayers.setProperty(scene.operationalLayers.indexOf(wmsLayerJan), "description", layerJan.description);

                    service2wk.load();
                } else if (serviceJan.loadStatus === Enums.LoadStatusFailedToLoad ||
                           serviceJan.loadStatus === Enums.LoadStatusNotLoaded ||
                           serviceJan.loadStatus === Enums.LoadStatusUnknown) {
                    service2wk.load();
                }
            });

            serviceHistW.loadStatusChanged.connect(function() {
                if (serviceHistW.loadStatus === Enums.LoadStatusLoaded) {
                    // get the layer info list
                    var serviceHistWInfo = serviceHistW.serviceInfo;
                    var layerInfos = serviceHistWInfo.layerInfos;

                    // get the desired layer from the list
                    layerHistW = layerInfos[0].sublayerInfos[0]

                    wmsLayerHistW = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                              layerInfos: [layerHistW],
                                                                              visible: false
                                                                         });

                    scene.operationalLayers.append(wmsLayerHistW);
                    scene.operationalLayers.setProperty(scene.operationalLayers.indexOf(wmsLayerHistW), "name", layerHistW.title);
                    scene.operationalLayers.setProperty(scene.operationalLayers.indexOf(wmsLayerHistW), "description", layerHistW.description);

                    serviceJan.load();
                } else if (serviceHistW.loadStatus === Enums.LoadStatusFailedToLoad ||
                           serviceHistW.loadStatus === Enums.LoadStatusNotLoaded ||
                           serviceHistW.loadStatus === Enums.LoadStatusUnknown) {
                    serviceJan.load();
                }
            });

            // start service load chain
            serviceHistW.load();

            serviceGlo.loadStatusChanged.connect(function() {
                if (serviceGlo.loadStatus === Enums.LoadStatusLoaded) {
                    var serviceGloInfo = serviceGlo.serviceInfo;
                    var layerInfos = serviceGloInfo.layerInfos;

                    // add all layers to model
                    suggestedListM = Qt.createQmlObject('import QtQuick 2.7; ListModel {}', pageItem);

                    addToModel(layerInfos[0].sublayerInfos[2].sublayerInfos, suggestedListM);
                    serviceFF.load();
                } else if (serviceGlo.loadStatus === Enums.LoadStatusFailedToLoad ||
                           serviceGlo.loadStatus === Enums.LoadStatusNotLoaded ||
                           serviceGlo.loadStatus === Enums.LoadStatusUnknown) {
                    serviceFF.load();
                }
            });

            serviceFF.loadStatusChanged.connect(function() {
                if (serviceFF.loadStatus === Enums.LoadStatusLoaded) {
                    var serviceFFInfo = serviceFF.serviceInfo;
                    var layerInfos = serviceFFInfo.layerInfos;

                    suggestedListM.append(layerInfos[0].sublayerInfos[1]);
                    servicePop.load();
                } else if (serviceFF.loadStatus === Enums.LoadStatusFailedToLoad ||
                           serviceFF.loadStatus === Enums.LoadStatusNotLoaded ||
                           serviceFF.loadStatus === Enums.LoadStatusUnknown) {
                    servicePop.load();
                }
            });

            servicePop.loadStatusChanged.connect(function() {
                if (servicePop.loadStatus === Enums.LoadStatusLoaded) {
                    var servicePopInfo = servicePop.serviceInfo;
                    var layerInfos = servicePopInfo.layerInfos;

                    suggestedListM.append(layerInfos[0].sublayerInfos[0]);
                    serviceStations.load();
                } else if (servicePop.loadStatus === Enums.LoadStatusFailedToLoad ||
                           servicePop.loadStatus === Enums.LoadStatusNotLoaded ||
                           servicePop.loadStatus === Enums.LoadStatusUnknown) {
                    serviceStations.load();
                }
            });

            serviceStations.loadStatusChanged.connect(function() {
                if (serviceStations.loadStatus === Enums.LoadStatusLoaded) {
                    var serviceStationsInfo = serviceStations.serviceInfo;
                    var layerInfos = serviceStationsInfo.layerInfos;

                    suggestedListM.append(layerInfos[0].sublayerInfos[0]);
                }
            });

            // load suggested services
            serviceGlo.load();
        }
    }

    function addToModel (item, model) {
        for (var p in item) {
            var ECMWFPrecip = ["EGE_probRgt300", "EGE_probRgt150", "EGE_probRgt50", "AccRainEGE"];
            if (ECMWFPrecip.includes(item[p].name)) {
                model.append(item[p]);
            }
        }
    }

    Controls.MenuDrawer {
        id:menu
    }

    Controls.FloatActionButton {
        id:switchBtn
    }

    Controls.NorthUpBtn {
        id:northUpBtn
    }

    Controls.CurrentPositionBtn {
        id:locationBtn
    }

    Controls.HomePositionBtn {
        id:homeLocationBtn
    }

    Controls.DescriptionLayer {
        id:descLyrPage
        visible: false
    }
}
