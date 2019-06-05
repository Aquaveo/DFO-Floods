import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.5

RoundButton{
    id: homeLocationBtn
    radius: 30 * scaleFactor
    width: 60 * scaleFactor
    height: 60 * scaleFactor
    Material.elevation: 6
    Material.background: "#00693e"

    anchors {
        right: parent.right
        top: parent.top
        rightMargin: 20 * scaleFactor
        topMargin: 75 * scaleFactor
    }

    Image{
        source: "../assets/homeBtn.png"
        height: 24 * scaleFactor
        width: 24 * scaleFactor
        anchors.centerIn: parent
    }

    onClicked: zoomToRegionLocation();

    function zoomToRegionLocation() {
        var x, y;
        if (viewName === "North America") {
            x = -100.005218;
            y = 38.411692;
        } else if (viewName === "South America") {
            x = -62.963135;
            y = -11.065338;
        } else if (viewName === "Europe") {
            x = 18.365050;
            y = 48.921274;
        } else if (viewName === "Australia") {
            x = 132.195485;
            y = -25.526449;
        } else if (viewName === "Asia") {
            x = 90.943869;
            y = 24.890659;
        } else if (viewName === "Africa") {
            x =19.675945;
            y = 5.579062;
        }

        positionSource.update();
        var currentPositionPoint = ArcGISRuntimeEnvironment.createObject("Point", {x: x, y: y, spatialReference: SpatialReference.createWgs84()});
        var centerPoint = GeometryEngine.project(currentPositionPoint, sceneView.spatialReference);

        var viewPointCenter = ArcGISRuntimeEnvironment.createObject("ViewpointCenter",{center: centerPoint, targetScale: 90000000});
        sceneView.setViewpoint(viewPointCenter);
    }
}
