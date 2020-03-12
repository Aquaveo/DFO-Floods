import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.5

Rectangle {
    id: offlineMapRect
    anchors.fill: parent
    color: "#80000000"

    property string fileName: ""
    property alias exportTask: exportTask
    property alias networkRequest: networkRequest
    property string statusText: ""
    property url outputTileCache
    property var basemapUrls: {
        'Imagery': 'https://tiledbasemaps.arcgis.com/arcgis/rest/services/World_Imagery/MapServer',
        'Streets': 'https://tiledbasemaps.arcgis.com/arcgis/rest/services/World_Topo_Map/MapServer',
        'Terrain': 'https://tiledbasemaps.arcgis.com/arcgis/rest/services/World_Terrain_Base/MapServer',
        'Topographic': 'https://tiledbasemaps.arcgis.com/arcgis/rest/services/World_Topo_Map/MapServer'
    }
    property ArcGISTiledLayer xTiledLayer
    property Geometry tileCacheExtent: null
    property ExportTileCacheParameters params

    property var generateLayerOptions: []

    MouseArea {
        anchors.fill: parent
        onClicked: mouse.accepted = true
        onWheel: wheel.accepted = true
    }

    Rectangle {
        id: offlinePgRect
        height: 0.85 * parent.height
        width: 0.85 * parent.width
        anchors.centerIn: parent
        radius: 3 * scaleFactor
        Material.background:  "#FAFAFA"
        Material.elevation: 24

        Text {
            id: titleText
            text: qsTr("Offline Maps")
            color: "#00693e"
            font{
                pixelSize: app.baseFontSize
                bold: true
            }
            padding: 24 * scaleFactor
            anchors.top: parent.top
        }

        Button {
            id: addOffMap

            width: 70 * scaleFactor
            height: 70 * scaleFactor
            anchors.right: parent.right
            anchors.top: parent.top

            Material.background: "transparent"

            onClicked: {
                // show the export window
                exportWindow.visible = true;

//                var corner1 = sceneView.screenToLocation(offlineMapRect.x, offlineMapRect.y);
//                var corner2 = sceneView.screenToLocation((offlineMapRect.x + offlineMapRect.width), (offlineMapRect.y + offlineMapRect.height));
//                var envBuilder = ArcGISRuntimeEnvironment.createObject("EnvelopeBuilder");
//                envBuilder.setCorners(corner1, corner2);
//                tileCacheExtent = GeometryEngine.project(envBuilder.geometry, SpatialReference.createWebMercator());

                var maxScale = sceneView.currentViewpointCenter.targetScale;
                var minScale = maxScale / 20;
                tileCacheExtent = sceneView.currentViewpointExtent.extent
                console.log(sceneView.width, sceneView.height, JSON.stringify(tileCacheExtent.extent.json), '################');
                exportTask.createDefaultExportTileCacheParameters(tileCacheExtent, maxScale, minScale);
            }

            Image {
                source: "../assets/add.png"
                height: 48 * scaleFactor
                width: 48 * scaleFactor
                anchors.centerIn: parent
            }
        }

        TabBar {
            id: offLineMaptabBar
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: titleText.bottom
            width: 0.95 * parent.width
            height: 40 * scaleFactor
            Material.accent:"#00693e"
            background:  Rectangle {
                color: "#249567"
            }

            TabButton {
                contentItem: Text {
                    text: qsTr("HOW TO")
                    font.pixelSize: 14 * scaleFactor
                    color: offLineMaptabBar.currentIndex === 0 ? "#00693e" : "black"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                topPadding: 12 * scaleFactor
                bottomPadding: 12 * scaleFactor

                background:  Rectangle {
                    color: "white"
                }
            }

            TabButton {
                contentItem: Text {
                    text: qsTr("MAP LIST")
                    font.pixelSize: 14 * scaleFactor
                    color: offLineMaptabBar.currentIndex === 1 ? "#00693e" : "black"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                topPadding: 12 * scaleFactor
                bottomPadding: 12 * scaleFactor

                background:  Rectangle {
                    color: "white"
                }
            }
        }

        StackLayout {
            id: stackLayoutOffM
            width: 0.95 * parent.width
            height: parent.height - 150 * scaleFactor
            anchors.top: offLineMaptabBar.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            currentIndex: offLineMaptabBar.currentIndex
            clip: true

            Flickable {
                anchors.fill: parent
                contentHeight: howToOMText.height
                clip: true

                Text {
                    id: howToOMText
                    width: parent.width
                    text: "1. Click on the <b>ADD (+)</b> button on the top right corner.<br /><br />2. A confirmation screen to download the current extent along with visible layers will appear.<br /><br />3. You will be prompted to enter a name for the downloaded offline area. <i>Only alphanumeric characters, dashes (-) and underscores (_) are accepted.</i><br /><br />4. Downloaded maps can be managed from the <b>MAP LIST</b> tab.<br /><br />5. Only the default DFO layers can be added to offline maps. Any other layer will be ignored, even if it is turned on on the menu's layers List<br />"
                    font {
                        pixelSize: app.baseFontSize
                    }
                    padding: 24 * scaleFactor
                    anchors.top: parent.top
                    wrapMode: Text.WordWrap
                }
            }

            ListView {
                id: oMList
                height: parent.height
                clip: true

                model: ListModel {
                    id: oMLyrsModel
                    ListElement {name: "NAME"; date_created: "DATE CREATED"; layer_list: []}
                }

                ScrollBar.vertical: ScrollBar {
                    active: true
                    width: 20 * scaleFactor
                }

                delegate: Item {
                    id: oMDelegate
                    width: parent.width
                    height: oMRow.height

                    Row {
                        id: oMRow
                        spacing: 0

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 0.55 * oMDelegate.width
                            text: name
                            wrapMode: Text.WordWrap
                            font.pixelSize: 14 * scaleFactor
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 0.55 * oMDelegate.width
                            text: date_created
                            wrapMode: Text.WordWrap
                            font.pixelSize: 14 * scaleFactor
                        }

                        Button {
                            id: infoLayer

                            width: 0.10 * oMDelegate.width
                            height: 35 * scaleFactor

                            Material.background: "transparent"

                            onClicked: {

                            }

                            Image {
                                source: "../assets/layerInfo.png"
                                height: 24 * scaleFactor
                                width: 24 * scaleFactor
                                anchors.centerIn: parent
                            }
                        }
                    }

                }
            }
        }

        Text {
            id: closeSaveStateRect
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.bottomMargin: 13 * scaleFactor
            anchors.rightMargin: 16 * scaleFactor
            text: qsTr("CLOSE")
            color: "#00693e"
            font {
                pixelSize: 14 * scaleFactor
                bold: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    offlinePg.visible = false;
                }
            }
        }
    }

    // Create ExportTileCacheTask
    ExportTileCacheTask {
        id: exportTask

        credential: Credential {
            id: cred
            username: 'DFOappUsers2'
            password: 'Q8o4RKrn!6aNf'
        }

        url: basemapUrls[menu.comboBoxBasemap.displayText]

        property var exportJob
        property var estimateJobSize

        onCreateDefaultExportTileCacheParametersStatusChanged: {
            if (createDefaultExportTileCacheParametersStatus === Enums.TaskStatusCompleted) {
                params = defaultExportTileCacheParameters;

                executeEstimateTileCacheSize(params);
            }
        }

        function executeEstimateTileCacheSize(params) {
            // execute the asynchronous task and obtain the job

            estimateJobSize = exportTask.estimateTileCacheSize(params);
            // check if job is valid
            if (estimateJobSize) {
                // connect to the job's status changed signal to know once it is done
                estimateJobSize.jobStatusChanged.connect(updateJobEstimateStatus);

                estimateJobSize.start();
            } else {
                exportWindow.visible = true;
                statusText = "Storage Estimate failed";
                exportWindow.hideWindow(5000);
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
                statusText = "Export failed";
                exportWindow.hideWindow(5000);
            }
        }

        function updateJobEstimateStatus() {
            switch(estimateJobSize.jobStatus) {
            case Enums.JobStatusFailed:
                statusText = "Calculation failed";
                exportWindow.hideWindow(5000);
                break;
            case Enums.JobStatusNotStarted:
                statusText = "Started";
                break;
            case Enums.JobStatusPaused:
                statusText = "Paused";
                break;
            case Enums.JobStatusStarted:
                statusText = "Calculating...";
                break;
            case Enums.JobStatusSucceeded:
                statusText = "Successful...";
                exportWindow.hideWindow(1000);

                loadOMForm.source = "NewOfflineMapForm.qml";
                newOMMapForm.visible = true;
                break;
            default:
                console.log("default");
                break;
            }
        }

        function updateJobStatus() {
            switch(exportJob.jobStatus) {
            case Enums.JobStatusFailed:
                statusText = "Export failed";
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
                statusText = "In progress...";
                break;
            case Enums.JobStatusSucceeded:
                statusText = "Adding map...";
                offlinePg.networkRequest.send();
//                displayOutputTileCache(exportJob.result);
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

    NetworkRequest {
        id: networkRequest
        url: "http://floodobservatory.colorado.edu/geoserver/AF_2wk_rs/wms?service=WMS&version=1.1.0&request=GetMap&layers=AF_2wk_rs:DFO_2wk_current_AF&styles%20%20=&bbox=1.4257904248024005,-6.706102997621768,17.17814185740383,19.39562033629621&width=414&height=686&srs=EPSG:4326&format=image%2Ftiff"
        responsePath: AppFramework.userHomeFolder.filePath("ArcGIS/AppStudio/Data") + "/layer_test1.tiff"

        onReadyStateChanged: {
            if (readyState === NetworkRequest.DONE) {
                var visLayers = [];
                for (var i = 0; i < sceneView.scene.operationalLayers.count; i++) {
                    if (pageItem.defaultLayersLongArr.includes(sceneView.scene.operationalLayers.get(i)["name"]) && sceneView.scene.operationalLayers.get(i)["visible"]) {
                        visLayers.push({
                            "name": sceneView.scene.operationalLayers.get(i)["name"],
                            "description": sceneView.scene.operationalLayers.get(i)["description"],
                            "visible": sceneView.scene.operationalLayers.get(i)["visible"],
                            "layerNames": sceneView.scene.operationalLayers.get(i)["layerNames"],
                            "legendName": sceneView.legendListView.model.get(i)["name"],
                            "symbolUrl": sceneView.legendListView.model.get(i)["symbolUrl"],
                            "legendVisible": sceneView.legendListView.model.get(i)["visible"]
                        });
                    } else {
                        console.log(sceneView.scene.operationalLayers.get(i)["name"], sceneView.scene.operationalLayers.get(i)["visible"], 'nooooooooooooooo2')
                    }
                }

                if (app.settings.value("offline_maps", false) === false) {
                    var offLineMaps = []
                    offLineMaps.push({"name": fileName, "date_created": new Date().getTime().toString(), "layer_list": visLayers})


                    app.settings.setValue("offline_maps", JSON.stringify(offLineMaps));
                }

                for (var p in JSON.parse(app.settings.value("offline_maps"))) {
                    oMLyrsModel.append(JSON.parse(app.settings.value("offline_maps"))[p]);
                }

                console.log(JSON.parse(app.settings.value("offline_maps"))[0].name,
                            JSON.parse(app.settings.value("offline_maps"))[0].date_created,
                            JSON.parse(app.settings.value("offline_maps"))[0].layer_list,
                            '$$$$$$$$$$$$$$$')

                offLineMaptabBar.currentIndex = 1;
                exportWindow.hideWindow(1500);
            }
        }
        onProgressChanged: console.log("progress:", progress)
        onError: {
//            console.log(errorText + ", " + errorCode)
            statusText = "Download failed";
        }
    }

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
            width: 125 * scaleFactor
            height: 100 * scaleFactor
            color: "lightgrey"
            opacity: 0.8
            radius: 5* scaleFactor
            border {
                color: "#4D4D4D"
                width: 1
            }

            Column {
                anchors {
                    fill: parent
                    margins: 10 * scaleFactor
                }
                spacing: 10

                BusyIndicator {
                    Material.accent:"#00693e"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: statusText
                    font.pixelSize: 16 * scaleFactor
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

    Rectangle {
        id: newOMMapForm
        anchors.fill: parent
        color: "black"

        Loader {
            id: loadOMForm
            anchors.centerIn: parent
        }

        visible: false
    }
}
