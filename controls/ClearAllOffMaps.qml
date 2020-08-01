import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0

Rectangle {
    id: clearAllOffMRect
    anchors.fill: parent
    color: "#80000000"

    MouseArea {
        anchors.fill: parent
        onClicked: mouse.accepted = true
        onWheel: wheel.accepted = true
    }

    Rectangle {
        id: popUpClearOFFM
        height: 180 * scaleFactor
        width: 280 * scaleFactor
        anchors.centerIn: parent
        radius: 3 * scaleFactor
        Material.background:  "#FAFAFA"
        Material.elevation: 24

        Text {
            width: parent.width
            text: qsTr("This action will clear all the saved offline maps.")
            font {
                pixelSize: app.baseFontSize
                bold: true
            }
            padding: 24 * scaleFactor
            anchors.top: parent.top
            wrapMode: Text.WordWrap
        }

        Button {
            id: clearAllOMBtn
            width: 0.8 * parent.width
            height: 50 * scaleFactor
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 50 * scaleFactor
            }

            Material.background: "#00693e"

            text: "CONFIRM"
            background: Rectangle {
                width: parent.width
                height: parent.height
                color: "#00693e"
                radius: 6 * scaleFactor
            }

            contentItem: Text {
                text: clearAllOMBtn.text
                font.pixelSize: 14 * scaleFactor
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            onClicked: {
                app.settings.setValue("offline_maps", false);
                clearAllOffM.visible = false;
            }
        }

        Text {
            id: cancelClearAllOffM
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.bottomMargin: 13 * scaleFactor
            anchors.rightMargin: 16 * scaleFactor
            text: qsTr("CANCEL")
            color: "#00693e"
            font {
                pixelSize: 14 * scaleFactor
                bold:true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    clearAllOffM.visible = false;
                }
            }
        }
    }

    DropShadow {
        source: clearAllOffM
        anchors.fill: clearAllOffM
        width: source.width
        height: source.height
        cached: true
        radius: 8 * scaleFactor
        samples: 17
        color: "#80000000"
        smooth: true
    }
}
