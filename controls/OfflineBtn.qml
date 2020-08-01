import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.5

RoundButton {
    radius: 30 * scaleFactor
    width: 60 * scaleFactor
    height: 60 * scaleFactor
    Material.elevation: 6
    Material.background: "#00693e"

    anchors {
        right: parent.right
        bottom: parent.bottom
        rightMargin: 90 * scaleFactor
        bottomMargin: 20 * scaleFactor
    }

    Image {
        source: "../assets/offlineBtn.png"
        height: 24 * scaleFactor
        width: 24 * scaleFactor
        anchors.centerIn: parent
    }

    onClicked: {
        offlinePg.visible = true
        if (!app.isOnline) {
            offlinePg.addOffMap.visible = false;
        } else {
            offlinePg.addOffMap.visible = true;
        }
    }
}
