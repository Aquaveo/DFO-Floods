import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.5

RoundButton {
    id: reorderLyrBtn

    radius: 30 * scaleFactor
    width: 60 * scaleFactor
    height: 60 * scaleFactor
    Material.elevation: 6
    Material.background: "#00693e"

    anchors {
        right: parent.right
        bottom: parent.bottom
        rightMargin: 90 * scaleFactor
        bottomMargin: 10 * scaleFactor
    }

    onClicked: {
        if (popUpReorder.visible === false) {
            popUpReorder.children[0].model = sceneView.scene.operationalLayers.count;
            popUpReorder.children[0].currentIndex = menu.contentItem.children[0].contentItem.children[4].currentIndex;
            popUpReorder.visible = true;
        } else if (popUpReorder.visible === true) {
            popUpReorder.visible = false;
        }
    }

    Image {
        source: "../assets/reorderLyr.png"
        height: 24 * scaleFactor
        width: 24 * scaleFactor
        anchors.centerIn: parent
    }
}
