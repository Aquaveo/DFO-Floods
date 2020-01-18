import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.5

RoundButton {
    id: locationBtn
    radius: 30 * scaleFactor
    width: 60 * scaleFactor
    height: 60 * scaleFactor
    Material.elevation: 6
    Material.background: "#00693e"

    anchors {
        right: parent.right
        top: parent.top
        rightMargin: 405 * scaleFactor < pageItem.height ? 20 * scaleFactor : 90 * scaleFactor
        topMargin: 405 * scaleFactor < pageItem.height ? 205 * scaleFactor : 10 * scaleFactor
    }

    Image {
        source: "../assets/position.png"
        height: 24 * scaleFactor
        width: 24 * scaleFactor
        anchors.centerIn: parent
    }

    onClicked: {
        zoomToCurrentLocation();
    }

    function zoomToCurrentLocation(){
        sceneView.positionSource.update();
        var currentPositionPoint = ArcGISRuntimeEnvironment.createObject("Point", {x: sceneView.positionSource.position.coordinate.longitude, y: sceneView.positionSource.position.coordinate.latitude, spatialReference: SpatialReference.createWgs84()});
        var centerPoint = GeometryEngine.project(currentPositionPoint, sceneView.spatialReference);

        var viewPointCenter = ArcGISRuntimeEnvironment.createObject("ViewpointCenter",{center: centerPoint, targetScale: 15000});
        sceneView.setViewpoint(viewPointCenter);
    }
}
