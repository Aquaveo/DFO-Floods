import QtQuick 2.7
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0
//import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.5

Rectangle {
    width: app.width
    height: app.height - 50 * scaleFactor

    property alias mapView: mapView
    property string statusText: ""
    readonly property url outputTileCache: AppFramework.userHomeFolder.fileUrl("ArcGIS/AppStudio/Data/BasemapTileCache.tpk")
    property var basemapUrls: {
        'Imagery': 'https://tiledbasemaps.arcgis.com/arcgis/rest/services/World_Imagery/MapServer',
        'Streets': 'https://tiledbasemaps.arcgis.com/arcgis/rest/services/World_Topo_Map/MapServer',
        'Terrain': 'https://tiledbasemaps.arcgis.com/arcgis/rest/services/World_Terrain_Base/MapServer',
        'Topographic': 'https://tiledbasemaps.arcgis.com/arcgis/rest/services/World_Topo_Map/MapServer'
    }
    property ArcGISTiledLayer xTiledLayer
    property Envelope tileCacheExtent: null
    property ExportTileCacheParameters params

    // Create MapView that contains a Map
    MapView {
        id: mapView
        anchors.fill: parent

        ViewpointCenter {
            center: Point {
                x: -11e6
                y: 6e6
                spatialReference: SpatialReference {wkid: 102100}
            }
            targetScale: 9e7
        }

        Map {
            id: map
            // Nest an ArcGISTiledLayer in the Basemap

//            minScale: 6000000
//            maxScale: 600000

            Component.onCompleted: {
                map.basemap = Qt.createQmlObject(
                    "import Esri.ArcGISRuntime 100.5

                    Basemap {
                        ArcGISTiledLayer {
                            url: basemapUrls[menu.comboBoxBasemap.displayText]

                            credential: Credential {
                                id: cred
                                username: 'qwewqe'
                                password: 'qwewqeqe'
                            }
                        }
                    }",
                    map
                )
            }
        }
    }

    // Create ExportTileCacheTask
    //! [ExportTiles ExportTileCacheTask]

    ExportTileCacheTask {
        id: exportTask

        credential: Credential {
            id: cred
            username: 'sdasdsad'
            password: 'asdsadada'
        }

        url: basemapUrls[menu.comboBoxBasemap.displayText]

        property var exportJob

        onCreateDefaultExportTileCacheParametersStatusChanged: {
            if (createDefaultExportTileCacheParametersStatus === Enums.TaskStatusCompleted) {
                params = defaultExportTileCacheParameters;

                // export the cache with the parameters
                executeExportTileCacheTask(params);
            }
        }

        function executeExportTileCacheTask(params) {
            // execute the asynchronous task and obtain the job

            exportJob = exportTask.exportTileCache(params, outputTileCache);
            // check if job is valid
            if (exportJob) {
                // show the export window
                exportWindow.visible = true;

                // connect to the job's status changed signal to know once it is done
                exportJob.jobStatusChanged.connect(updateJobStatus);

                exportJob.start();
            } else {
                exportWindow.visible = true;
                statusText = "Export failed1";
                exportWindow.hideWindow(5000);
            }
        }

        function updateJobStatus() {
            switch(exportJob.jobStatus) {
            case Enums.JobStatusFailed:
                statusText = "Export failed2";
                console.log(exportJob.messages[exportJob.messages.length - 1].message, '@@@@@@@@@@@@@@')
                console.log(outputTileCache)
                exportWindow.hideWindow(5000);
                break;
            case Enums.JobStatusNotStarted:
                statusText = "Job not started";
                break;
            case Enums.JobStatusPaused:
                statusText = "Job paused";
                break;
            case Enums.JobStatusStarted:
                console.log("In progress...");
                statusText = "In progress...";
                break;
            case Enums.JobStatusSucceeded:
                statusText = "Adding TPK...";
                exportWindow.hideWindow(1500);
                displayOutputTileCache(exportJob.result);
                break;
            default:
                console.log("default");
                break;
            }
        }

        function displayOutputTileCache(tileCache) {
            // create a new tiled layer from the output tile cache
            xTiledLayer = ArcGISRuntimeEnvironment.createObject("ArcGISTiledLayer", { tileCache: tileCache } );

            // create a new basemap with the tiled layer
            var basemap = ArcGISRuntimeEnvironment.createObject("Basemap");
            basemap.baseLayers.append(xTiledLayer);

            // set the new basemap on the map
            map.basemap = basemap;

            // zoom to the new layer and hide window once loaded
            xtiledLayer.loadStatusChanged.connect(function() {
                if (tiledLayer.loadStatus === Enums.LoadStatusLoaded) {
                    extentRectangle.visible = false;
                    downloadButton.visible = false;
                    mapView.setViewpointScale(mapView.mapScale * .5);
                }
            });
        }

        Component.onDestruction: {
            exportJob.jobStatusChanged.disconnect(updateJobStatus);
        }
    }
    //! [ExportTiles ExportTileCacheTask]

    Rectangle {
        id: extentRectangle
        anchors.centerIn: parent
        width: parent.width - (50 * scaleFactor)
        height: parent.height - (125 * scaleFactor)
        color: "transparent"
        border {
            color: "#00693e"
            width: 3 * scaleFactor
        }
    }

    // Create the download button to export the tile cache
    Rectangle {
        id: downloadButton
        property bool pressed: false
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 25 * scaleFactor
        }

        width: 130 * scaleFactor
        height: 35 * scaleFactor
        color: pressed ? Qt.darker("#00693e") : "#00693e"
        radius: 5 * scaleFactor
        border {
            color: Qt.darker("#00693e")
            width: 1 * scaleFactor
        }

        Row {
            anchors.fill: parent
            spacing: 5
            Image {
                width: 38 * scaleFactor
                height: width
                source: "../assets/download.png"
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Export tiles"
                font.pixelSize: 14
                color: "white"
            }
        }

        MouseArea {
            anchors.fill: parent
            onPressed: downloadButton.pressed = true
            onReleased: downloadButton.pressed = false
            onClicked: {
                var corner1 = mapView.screenToLocation(extentRectangle.x, extentRectangle.y);
                var corner2 = mapView.screenToLocation((extentRectangle.x + extentRectangle.width), (extentRectangle.y + extentRectangle.height));
                var envBuilder = ArcGISRuntimeEnvironment.createObject("EnvelopeBuilder");
                envBuilder.setCorners(corner1, corner2);
                tileCacheExtent = GeometryEngine.project(envBuilder.geometry, SpatialReference.createWebMercator());

                var maxScale = mapView.mapScale;
                var minScale = maxScale / 20;

                exportTask.createDefaultExportTileCacheParameters(tileCacheExtent, maxScale, minScale);
            }
        }
    }

    // Create a window to display the export window
    Rectangle {
        id: exportWindow
        anchors.fill: parent
        color: "transparent"
        visible: false
        clip: true

        RadialGradient {
            anchors.fill: parent
            opacity: 0.7
            gradient: Gradient {
                GradientStop { position: 0.0; color: "lightgrey" }
                GradientStop { position: 0.7; color: "black" }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: mouse.accepted = true
            onWheel: wheel.accepted = true
        }

        Rectangle {
            anchors.centerIn: parent
            width: 125
            height: 100
            color: "lightgrey"
            opacity: 0.8
            radius: 5
            border {
                color: "#4D4D4D"
                width: 1
            }

            Column {
                anchors {
                    fill: parent
                    margins: 10
                }
                spacing: 10

                BusyIndicator {
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: statusText
                    font.pixelSize: 16
                }
            }
        }

        Timer {
            id: hideWindowTimer

            onTriggered: exportWindow.visible = false;
        }

        function hideWindow(time) {
            hideWindowTimer.interval = time;
            hideWindowTimer.restart();
        }
    }
}
