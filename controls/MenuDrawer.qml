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
//            anchors.margins: 10 * scaleFactor
            anchors.horizontalCenter: parent.horizontalCenter
            width: 0.95 * parent.width
            height: parent.height
            clip: true

            // Assign the model to the list model of sublayers
            model: sceneView.scene.operationalLayers

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
                        width: 0.75 * menu.width
                        text: name
                        wrapMode: Text.WordWrap
                        font.pixelSize: 12 * scaleFactor
                    }

                    Switch {
                        width: 0.25 * menu.width

                        Material.accent: "#00693e"

                        onCheckedChanged: {
                            layerVisible = checked;
                        }
                        Component.onCompleted: {
                            console.log(description, "%%%%%%");
                            checked = layerVisible;
                        }

                    }
                }
            }
        }
    }
}
