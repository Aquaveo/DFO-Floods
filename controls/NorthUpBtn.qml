import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.5

RoundButton{
    id: northUpBtn
    radius: 30 * scaleFactor
    width: 60 * scaleFactor
    height: 60 * scaleFactor
    Material.elevation: 6
    Material.background: "#00693e"

    anchors {
        right: parent.right
        top: parent.top
        rightMargin: 340 * scaleFactor < pageItem.height ? 20 * scaleFactor : 90 * scaleFactor
        topMargin: 340 * scaleFactor < pageItem.height ? 140 * scaleFactor : 75 * scaleFactor
    }

    Image{
        source: "../assets/northup.png"
        height: 24 * scaleFactor
        width: 24 * scaleFactor
        anchors.centerIn: parent
    }

    onClicked: {
        setNorthUp();
    }

    function setNorthUp(){
        var northUpCam = sceneView.currentViewpointCamera.rotateTo(0,0,0);
        sceneView.setViewpointCamera(northUpCam);
    }
}
