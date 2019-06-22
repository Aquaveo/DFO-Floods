import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.5

import QtPositioning 5.3

import "../controls" as Controls

Rectangle{
    id: startPage
    width: parent.width
    height: parent.height
    anchors.fill:parent

    ColumnLayout{
        anchors.fill: parent
        spacing: 0
        clip: true

        Rectangle {
            id:startPageheader
            Layout.alignment: Qt.AlignTop
            color: "#00693e"
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50 * scaleFactor

            Text {
                id: aboutApp
                text: qsTr("Dartmouth Flood Observatory")
                color: "white"
                font.pixelSize: app.baseFontSize * 1.1
                font.bold: true
                anchors.centerIn: parent
                maximumLineCount: 2
                elide: Text.ElideRight
            }
        }

        // Create SceneView
        SceneView {
            id: sceneView
            Scene {
                id: scene
                BasemapTopographic {}
            }

            PositionSource {
                id: positionSource
                active: true
            }
        }

        Rectangle {
            color: "black"
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    Component.onCompleted: {
        popUp.visible = 1;
        initLoad = false;
    }
}
