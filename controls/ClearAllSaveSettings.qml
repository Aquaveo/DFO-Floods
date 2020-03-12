import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0

Rectangle {
    id: clearAllSSRect
    anchors.fill: parent
    color: "#80000000"

    MouseArea {
        anchors.fill: parent
        onClicked: mouse.accepted = true
        onWheel: wheel.accepted = true
    }

    Rectangle {
        id: popUpClearSS
        height: 180 * scaleFactor
        width: 280 * scaleFactor
        anchors.centerIn: parent
        radius: 3 * scaleFactor
        Material.background:  "#FAFAFA"
        Material.elevation: 24

        Text {
            width: parent.width
            text: qsTr("This action will clear all the saved settings.")
            font {
                pixelSize: app.baseFontSize
                bold: true
            }
            padding: 24 * scaleFactor
            anchors.top: parent.top
            wrapMode: Text.WordWrap
        }

        Button {
            id: clearSSBtn
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
                text: clearSSBtn.text
                font.pixelSize: 14 * scaleFactor
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            onClicked: {
                app.settings.setValue("basemap", false);
                pageItem.saveState.basemapcheck = false;
                app.settings.setValue("layer_list", false);
                pageItem.saveState.layerListcheck = false;
                app.settings.setValue("region", false);
                pageItem.saveState.regioncheck = false;
                app.settings.setValue("zoom", false);
                pageItem.saveState.zoomcheck = false;

                clearAllSS.visible = false;
                app.initLoad = true
                app.qmlfile = "../views/StartPage.qml";
            }
        }

        Text {
            id: cancelClearAllSS
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
                    clearAllSS.visible = 0;
                    saveStagePg.visible = 1;
                }
            }
        }
    }

    DropShadow {
        id: headerbarShadow
        source: popUpClearSS
        anchors.fill: popUpClearSS
        width: source.width
        height: source.height
        cached: true
        radius: 8 * scaleFactor
        samples: 17
        color: "#80000000"
        smooth: true
    }
}
