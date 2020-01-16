import QtQuick 2.0
import QtQuick.Controls 2.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Material 2.1

import Esri.ArcGISRuntime 100.5

import QtPositioning 5.3

import "../public/js/customGeoFunctions.js" as CustomGeoFunctions
import "../public/js/createLayers.js" as CreateLyrs

SceneView {
    anchors.fill: parent

    property alias positionSource: positionSource
    property alias legendListView: legend.legendListView

    ViewpointCenter {
        id: initView
        center: Point {
            x: -11e6
            y: 6e6
            spatialReference: SpatialReference {wkid: 102100}
        }
        targetScale: 9e7
    }

    //Busy Indicator
    BusyIndicator {
        anchors.centerIn: parent
        height: 48 * scaleFactor
        width: height
        running: true
        Material.accent:"#00693e"
        visible: (sceneView.drawStatus === Enums.DrawStatusInProgress)
    }

    PositionSource {
        id: positionSource
        active: true
        property bool isInitial: true
        onPositionChanged: {
            if(sceneView.scene !== null && sceneView.scene.loadStatus === Enums.LoadStatusLoaded && isInitial) {
                isInitial = false;
                zoomToRegionLocation();

                function zoomToRegionLocation(){
                    positionSource.update();
                    var centerPoint = GeometryEngine.project(currentPositionPoint, sceneView.spatialReference);

                    var viewPointCenter = ArcGISRuntimeEnvironment.createObject("ViewpointCenter",{center: centerPoint});
                    sceneView.setViewpoint(viewPointCenter);
                }
            }
        }
    }

    // add a graphics overlay
    GraphicsOverlay {
        id: graphicsOverlay
    }

    Scene {
        id: scene
        initialViewpoint: initView

        onLoadStatusChanged: {
            if (scene.loadStatus === Enums.LoadStatusLoaded) {
                if (layerVisibilityListView) {
                    layerVisibilityListView.forceLayout();
                }
            }
        }
    }

    // Create legend
    Legend {
        id: legend
    }

    onMouseClicked: {
        CustomGeoFunctions.getNearestEvent(mouse);
    }

    Component.onCompleted: {
        CreateLyrs.addWmsLayers();
    }
}


