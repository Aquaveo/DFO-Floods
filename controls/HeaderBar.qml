import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0

RowLayout {
    anchors.fill: parent
    spacing:0
    clip:true

    Rectangle {
        Layout.preferredWidth: 50 * scaleFactor
    }

    Text {
        text: "DFO - " + qsTr(viewName)
        color: "white"
        font.pixelSize: app.baseFontSize * 1.1
        font.bold: true
        maximumLineCount:2
        wrapMode: Text.Wrap
        elide: Text.ElideRight
        Layout.alignment: Qt.AlignCenter
    }

    Rectangle {
        id: infoImageRect
        Layout.alignment: Qt.AlignRight
        Layout.preferredWidth: 50 * scaleFactor

        Button {
            id: infoImage
            Material.background: "transparent"
            height: 30 * scaleFactor
            width: 30 * scaleFactor
            anchors {
                centerIn: parent
            }

            Image {
                source: "../assets/info.png"
                height: 30 * scaleFactor
                width: 30 * scaleFactor
                anchors.centerIn: parent
            }

            onClicked: {
                descPage.visible = 1
            }
        }
    }
}





