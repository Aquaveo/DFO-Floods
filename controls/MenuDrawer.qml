import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.4

Drawer {
    id: menu
    width: 0.75 * parent.width
    height: parent.height

    Column {
        id: mainColum
        anchors.fill: parent

        Rectangle {
            id: menuHeader
            height: 50 * scaleFactor
            width: parent.width
            color: Qt.darker("#00693e")

            Text {
                id: menuTitle
                text: qsTr("Menu")
                color: "white"
                font.pointSize: 18
                anchors.centerIn: parent
            }
        }

        Text {
            id: basemapTitle
            text: qsTr("Basemap: ")
            color: "black"
            font.pointSize: 12
            anchors.left: parent.left
            padding: 8
        }

        ComboBox {
            id: comboBoxBasemap
            anchors.horizontalCenter: parent.horizontalCenter
            width: 0.98 * parent.width
            height: 30 * scaleFactor
            Material.accent:"#00693e"
            background: Rectangle {
                radius: 6 * scaleFactor
                border.color: "darkgrey"
                width: parent.width
                height: 30 * scaleFactor
            }

            model: ["Topographic","Streets","Imagery","Terrain"]
            onCurrentTextChanged: {
                if (sceneView.scene.loadStatus === Enums.LoadStatusLoaded)
                    changeBasemap();
            }

            function changeBasemap() {
                switch (comboBoxBasemap.currentText) {
                case "Topographic":
                    sceneView.scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapTopographic");
                    break;
                case "Streets":
                    sceneView.scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapStreets");
                    break;
                case "Imagery":
                    sceneView.scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapImageryWithLabels");
                    break;
                case "Terrain":
                    sceneView.scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapTerrainWithLabels");
                    break;
                default:
                    sceneView.scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapTopographic");
                    break;
                }
            }
        }

        Text {
            id: layerContentTitle
            text: qsTr("Layers List: ")
            color: "black"
            font.pointSize: 12
            anchors.left: parent.left
            padding: 8
        }

        // Create a list view to display the layer items
        ListView {
            id: layerVisibilityListView
            anchors.horizontalCenter: parent.horizontalCenter
            width: 0.95 * parent.width
            height: childrenRect.height
            clip: true

            // Assign the model to the list model of sublayers
//            model: sceneView.scene.operationalLayers
            model: layerList

            // Assign the delegate to the delegate created above
            delegate: Item {
                id: layerVisibilityDelegate
                width: parent.width
                height: 35 * scaleFactor

                Row {
                    spacing: 0
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 0.65 * layerVisibilityListView.width
                        text: name
                        wrapMode: Text.WordWrap
                        font.pixelSize: 12 * scaleFactor
                    }

                    Switch {
                        width: 0.25 * layerVisibilityListView.width

                        Material.accent: "#00693e"

                        onCheckedChanged: {
                            layerVisible = checked;
                        }
                        Component.onCompleted: {
                            checked = layerVisible;
                        }

                    }

                    Button {
                        id:infoLayer

                        width: 0.10 * layerVisibilityListView.width

                        Material.background: "transparent"

                        onClicked: {
                            pageItem.descriptionLyr = description
                            menu.close();
                            descLyrPage.visible = 1
                        }

                        Image {
                            source: "../assets/layerInfo.png"
                            height: 24 * scaleFactor
                            width: 24 * scaleFactor
                            anchors.centerIn: parent
                        }
                    }
                }
            }
        }

        Text {
            id: eventLayersTitle
            text: qsTr("Extreme Events: ")
            color: "black"
            font.pointSize: 12
            anchors.left: parent.left
            padding: 8
        }

        Rectangle {
            id: allExtremeEvRect
            width: 0.95 * parent.width
            height: 35 * scaleFactor
            anchors.left: parent.left

            Row {
                id: allExtremeEvRow
                width: parent.width
                spacing: 0
                anchors.verticalCenter: parent.verticalCenter

                CheckBox {
                    id: allEventLayersCheck
                    property url wmsEventServiceUrl: "http://floodobservatory.colorado.edu/geoserver/Events_NA/wms?service=wms&request=getCapabilities";

                    property WmsService serviceEv
                    property WmsLayerInfo layerNAEv;
                    property WmsLayer wmsLayerEv;

                    Material.accent: "#00693e"

                    onCheckedChanged: {
                        if (checked == true) {
                            selectEventLayersCheck.checked = false;
                            serviceEv = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wmsEventServiceUrl });

                            serviceEv.loadStatusChanged.connect(function() {
                                if (serviceEv.loadStatus === Enums.LoadStatusLoaded) {
                                    // get the layer info list
                                    var serviceEvInfo = serviceEv.serviceInfo;
                                    var layerInfos = serviceEvInfo.layerInfos;

                                    // get the desired layer from the list
                                    layerNAEv = layerInfos[0].sublayerInfos[0]
                                    var layerNAEvTiles = layerInfos[0].sublayerInfos
//                                    console.log(typeof layerNAEvTiles, layerNAEvTiles[1].extent.center.x, layerNAEvTiles[1].extent.center.y,'#################')

                                    wmsLayerEv = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                                           layerInfos: [layerNAEv],
                                                                                           visible: true
                                                                                       });

                                    sceneView.scene.operationalLayers.append(wmsLayerEv);
                                    sceneView.scene.operationalLayers.setProperty(4, "name", "All Events");
                                    sceneView.scene.operationalLayers.setProperty(4, "description", layerNAEv.description);
                                }
                            });

                            serviceEv.load();
                        } else {
                            sceneView.scene.operationalLayers.remove(4,1);
                        }
                    }

                    Component.onCompleted: {
                        checked = false;
                    }
                }

                Text {
                    width: 0.45 * allExtremeEvRow.width
                    text: qsTr("View all")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 12 * scaleFactor
                    anchors.verticalCenter: parent.verticalCenter
                    padding: 8
                }
            }
        }

        Rectangle {
            id: selectExtremeEvRect
            width: 0.95 * parent.width
            height: 35 * scaleFactor
            anchors.left: parent.left

            Row {
                id: selectExtremeEvRow
                width: parent.width
                spacing: 0
                anchors.verticalCenter: parent.verticalCenter

                CheckBox {
                    id: selectEventLayersCheck
                    property url wmsEventServiceUrl: "http://floodobservatory.colorado.edu/geoserver/Events_NA/wms?service=wms&request=getCapabilities";

                    property WmsService serviceEv
                    property WmsLayerInfo layerNAEvTiles;
                    property WmsLayer wmsLayerEv;

                    Material.accent: "#00693e"

                    onCheckedChanged: {
                        if (checked == true) {
                            allEventLayersCheck.checked = false;
                            drawPin = true;
                            menu.close();
                        } else {
                            drawPin = false;
                            sceneView.scene.operationalLayers.remove(4,1);
                        }
                    }

                    Component.onCompleted: {
                        checked = false;
                    }
                }

                Text {
                    width: 0.45 * selectExtremeEvRow.width
                    text: qsTr("Select nearest event")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 12 * scaleFactor
                    anchors.verticalCenter: parent.verticalCenter
                    padding: 8
                }
            }
        }
    }
}
