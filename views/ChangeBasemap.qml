import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.4

Item {

    property real scaleFactor: AppFramework.displayScaleFactor
    property url wmsServiceUrl: "http://floodobservatory.colorado.edu/geoserver/DFO_2wk_current_NA/wms?service=wms&request=getCapabilities"
    property WmsService service;
    property WmsLayerInfo layerNA;
    property WmsLayer wmsLayer;

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
//        Scene {
//            id: scene
//            // Set the initial basemap to Topographic
//            BasemapTopographic {}
//            initialViewpoint: ViewpointCenter {
//                center: Point {
//                    x: -11e6
//                    y: 6e6
//                    spatialReference: SpatialReference {wkid: 102100}
//                }
//                targetScale: 9e7
//            }
//        }
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
                    var scene = ArcGISRuntimeEnvironment.createObject("Scene", {
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

//    ComboBox {
//        id: comboBoxBasemap
//        anchors {
//            left: parent.left
//            top: parent.top
//            margins: 15 * scaleFactor
//        }
//        width: 140 * scaleFactor
//        height: 30 * scaleFactor
//        Material.accent:"#00693e"
//        background: Rectangle {
//            radius: 6 * scaleFactor
//            border.color: "darkgrey"
//            width: 140 * scaleFactor
//            height: 30 * scaleFactor
//        }

//        model: ["Topographic","Streets","Imagery","Oceans"]
//        onCurrentTextChanged: {
//            // Call this JavaScript function when the current selection changes
//            if (scene.loadStatus === Enums.LoadStatusLoaded)
//                changeBasemap();
//        }

//        function changeBasemap() {
//            // Determine the selected basemap, create that type, and set the Map's basemap
//            switch (comboBoxBasemap.currentText) {
//            case "Topographic":
//                scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapTopographic");
//                break;
//            case "Streets":
//                scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapStreets");
//                break;
//            case "Imagery":
//                scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapImagery");
//                break;
//            case "Oceans":
//                scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapOceans");
//                break;
//            default:
//                scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapTopographic");
//                break;
//            }
//        }
//    }
}
