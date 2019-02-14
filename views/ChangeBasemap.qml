import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.4

import "../controls" as Controls

Page {
    id: testItem
    property real scaleFactor: AppFramework.displayScaleFactor
    property url wmsServiceUrl: "http://floodobservatory.colorado.edu/geoserver/DFO_2wk_current_NA/wms?service=wms&request=getCapabilities"
    property WmsService service;
    property WmsLayerInfo layerNA;
    property WmsLayer wmsLayer;
    property Scene scene;

    header: ToolBar {
        id: header
        width: parent.width
        height: 50 * scaleFactor
        Material.background: "#00693e"
        Controls.HeaderBar{}

        ToolButton {
            id: menuButton
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                leftMargin: 8
            }

            indicator: Image {
                source: "../assets/menu.png"
                anchors.fill: parent
            }

            onClicked: menu.open()
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

        Component.onCompleted: createWmsLayer();

        function createWmsLayer() {
            // create the service
            service = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wmsServiceUrl });

            // connect to loadStatusChanged signal of the service
            service.loadStatusChanged.connect(function() {
                console.log(service.loadStatus);
                if (service.loadStatus === Enums.LoadStatusLoaded) {
                    // get the layer info list
                    var serviceInfo = service.serviceInfo;
                    var layerInfos = serviceInfo.layerInfos;

//                            listProperty(layerInfos[0].sublayerInfos[7]);

                    // get the desired layer from the list
                    layerNA = layerInfos[0].sublayerInfos[0]
                    console.log('***', layerNA.name)
//                            listProperty(layerNA);
                    // create WMS layer
                    wmsLayer = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                         layerInfos: [layerNA]
                                                                     });

                    // create a basemap from the layer
//                            var basemap = ArcGISRuntimeEnvironment.createObject("Basemap");
//                            basemap.baseLayers.append(wmsLayer);
                    var basemap = ArcGISRuntimeEnvironment.createObject("BasemapTopographic");

                    // create a scene
                    scene = ArcGISRuntimeEnvironment.createObject("Scene", {
                                                                      basemap: basemap,
                                                                      initialViewpoint: initView,
                                                                  });

                    scene.operationalLayers.append(wmsLayer);

//                            listProperty(scene.operationalLayers.get(0).layerInfo);
                    console.log("layers in map = " + scene.operationalLayers.count);

                    // set the scene on the sceneview
                    sceneView.scene = scene;

//                            scene.basemap = basemap;
//                            scene.initialViewpoint = initView;
                }
            });

            // load the service
            service.load();
        }
    }

    Controls.MenuDrawer {
        id:menu
    }
}
