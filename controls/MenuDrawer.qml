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

            model: ["Topographic","Streets","Imagery","Oceans"]
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
                    sceneView.scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapImagery");
                    break;
                case "Oceans":
                    sceneView.scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapOceans");
                    break;
                default:
                    sceneView.scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapTopographic");
                    break;
                }
            }
        }
    }
}
