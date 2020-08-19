import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.5

import "../controls" as Controls

Rectangle {
    id: offlineMapRect
    anchors.fill: parent
    color: "black"

    property string fileName: ""
    property alias exportTask: exportTask
    property alias networkRequest: networkRequest
    property alias networkRequest2: networkRequest2
    property alias addOffMap: addOffMap
    property alias offLineMaptabBar: offLineMaptabBar
    property alias oMLyrsModel: oMLyrsModel
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
    property string layer2WkDownloadUrl
    property string layer3DayDownloadUrl

    property var generateLayerOptions: []
    property var offMRemIx

//    Rectangle {
//        id: extentRectangle
//        anchors.centerIn: parent
//        width: 512
//        height: 512
//        color: "transparent"
//        border {
//            color: "#00693e"
//            width: 3 * scaleFactor
//        }
//    }

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

//                var corner1 = sceneView.screenToLocation(extentRectangle.x, extentRectangle.y);
//                var corner2 = sceneView.screenToLocation((extentRectangle.x + extentRectangle.width), (extentRectangle.y + extentRectangle.height));
//                var envBuilder = ArcGISRuntimeEnvironment.createObject("EnvelopeBuilder");
//                envBuilder.setCorners(corner1, corner2);

//                console.log(corner1.x, corner1.y, corner2.x, corner2.y,'$$$$$');

//                for (var p in envBuilder.geometry) {
//                    console.log(p, envBuilder[p], '####');
//                }

//                var tileCacheExtent_tmp = GeometryEngine.project(envBuilder.geometry, SpatialReference.createWebMercator());

                if (sceneView.currentViewpointCenter.targetScale > 18489298) {
                    statusText = "Please zoom in to or below the country level";
                    exportWindow.hideWindow(2000);
                } else if (sceneView.currentViewpointCenter.targetScale < 577790) {
                    statusText = "Please zoom out to or above the county level";
                    exportWindow.hideWindow(2000);
                } else {
                    statusText = "";
                    var maxScale = sceneView.currentViewpointCenter.targetScale;
                    var minScale = 577790.554289 // maxScale / 20;
                    tileCacheExtent = sceneView.currentViewpointExtent.extent;
    //                var tileCacheExtent2 = GeometryEngine.project(tileCacheExtent, SpatialReference.createWebMercator());

                    exportTask.createDefaultExportTileCacheParameters(tileCacheExtent, maxScale, minScale);
    //                console.log(tileCacheExtent.xMin, tileCacheExtent.xMax, tileCacheExtent.yMin, tileCacheExtent.yMax, '$$$$$$$$$');
                }
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

            onCurrentIndexChanged: {
                if (offLineMaptabBar.currentIndex === 1) {
                    clearAllOffMTrigger.visible = true;
                } else {
                    clearAllOffMTrigger.visible = false;
                }
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
                contentHeight: howToOMText.height
                clip: true

                Text {
                    id: howToOMText
                    width: parent.width
                    text: app.isOnline ? "Make sure the map extent is between the country and county/province levels.<i>This is roughly between 1:18500000 and 1:580000</i>. Your current zoom level is <b>1:%1</b>.<br /><br />1. Click on the <b>ADD (+)</b> button on the top right corner.<br /><br />2. A confirmation screen to download the current extent along with the current and two-week layers will appear.<br /><br />3. You will be prompted to enter a name for the downloaded offline area. <i>Only alphanumeric characters, dashes (-) and underscores (_) are accepted.</i><br /><br />4. Downloaded maps can be managed from the <b>MAP LIST</b> tab.<br />".arg(Number(sceneView.currentViewpointCenter.targetScale).toFixed(0)) : "You are currently offline. Offline maps can only be downloaded ahead of time with an Internet connection.<br /><br />Go to the <b>MAP LIST</b> tab for a list of previously downloaded offline maps."
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
                    ListElement {name: "NAME"; date_created: "CREATED"; layer_list: []; zoom: ""; extent: ""}

                    Component.onCompleted: {
                        if (app.settings.value("offline_maps") && viewName) {
                            for (var p in JSON.parse(app.settings.value("offline_maps"))) {
                                if (JSON.parse(app.settings.value("offline_maps"))[p].name.includes(viewName.replace(" ", ""))) {
                                    oMLyrsModel.append(JSON.parse(app.settings.value("offline_maps"))[p]);
                                }
                            }
                        }
                    }
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
                        height: 40 * scaleFactor
                        spacing: 2 * scaleFactor
                        anchors.verticalCenter: parent.verticalCenter
                        leftPadding: 4 * scaleFactor
                        rightPadding: 4 * scaleFactor

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 0.3 * oMDelegate.width
                            text: name === "NAME" ? name : name.split(/_(.+)/)[1]
                            wrapMode: Text.WrapAnywhere
                            font.pixelSize: 14 * scaleFactor
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 0.45 * oMDelegate.width
                            text: date_created === "CREATED" ? date_created : new Date(Number(date_created)).toString()
                            wrapMode: Text.WordWrap
                            font.pixelSize: 14 * scaleFactor
                        }

                        Button {
                            id: loadOffMBtn

                            width: 0.1 * oMDelegate.width
                            height: 40 * scaleFactor
                            visible: false

                            Material.background: "#00693e"

                            onClicked: {
                                if (name !== "NAME") {
                                    var basemapPath = "%1/%2_BasemapTileCache_%3.tpk".arg(dataPath).arg(viewName.replace(" ", "")).arg(oMLyrsModel.get(index).name.split(/_(.+)/)[1]);
                                    var xTileCache = ArcGISRuntimeEnvironment.createObject("TileCache", {path: basemapPath});
                                    var xTiledLayer = ArcGISRuntimeEnvironment.createObject("ArcGISTiledLayer", { tileCache: xTileCache } );

                                    //create a new basemap with the tiled layer
                                    var basemap = ArcGISRuntimeEnvironment.createObject("Basemap");
                                    basemap.baseLayers.append(xTiledLayer);

                                    // set the new basemap on the map
                                    sceneView.scene.basemap = basemap;
                                    offlinePg.visible = false;

                                    sceneView.scene.operationalLayers.clear();
                                    var savedOffMLocation = JSON.parse(oMLyrsModel.get(index).zoom);
                                    var savedOffMPoint = ArcGISRuntimeEnvironment.createObject("Point", {
                                                                                               x: savedOffMLocation.targetGeometry.x,
                                                                                               y: savedOffMLocation.targetGeometry.y,
                                                                                               z: savedOffMLocation.targetGeometry.z,
                                                                                               spatialReference: savedOffMLocation.targetGeometry.spatialReference
                                                                                           });

                                    var centerOffMPoint = GeometryEngine.project(savedOffMPoint, sceneView.spatialReference);
                                    var viewPointOffMCenter = ArcGISRuntimeEnvironment.createObject("ViewpointCenter", {
                                                                                                    center: centerOffMPoint,
                                                                                                    rotation: savedOffMLocation.rotation,
                                                                                                    targetScale: savedOffMLocation.scale - (savedOffMLocation.scale / 4)
                                                                                                });
                                    sceneView.setViewpointAndSeconds(viewPointOffMCenter, 0);
                                    sceneView.lockExtent = JSON.parse(oMLyrsModel.get(index).extent);
                                    sceneView.lockCenterPt = JSON.parse(oMLyrsModel.get(index).zoom);

                                    var twoWkPath = "%1/%2_%3_Two_Week.tpk".arg(dataPath).arg(viewName.replace(" ", "")).arg(oMLyrsModel.get(index).name.split(/_(.+)/)[1]);
                                    var twoWkTileCache = ArcGISRuntimeEnvironment.createObject("TileCache", {path: twoWkPath});

                                    var twoWkLayer = ArcGISRuntimeEnvironment.createObject("ArcGISTiledLayer", { tileCache: twoWkTileCache } );

                                    sceneView.scene.operationalLayers.append(twoWkLayer);
                                    sceneView.scene.operationalLayers.setProperty(0, "name", "2-week accumulated flooded area %1".arg(app.viewName));
                                    sceneView.scene.operationalLayers.setProperty(0, "description",  "This is an offline version of the 2-week accumulated flooded area %1 layer. This layer was saved on %2".arg(app.viewName).arg(new Date(Number(oMLyrsModel.get(index)["date_created"])).toString()));

                                    var threeDayPath = "%1/%2_%3_Current.tpk".arg(dataPath).arg(viewName.replace(" ", "")).arg(oMLyrsModel.get(index).name.split(/_(.+)/)[1]);
                                    var threeDayTileCache = ArcGISRuntimeEnvironment.createObject("TileCache", {path: threeDayPath});

                                    var threeDayLayer = ArcGISRuntimeEnvironment.createObject("ArcGISTiledLayer", { tileCache: threeDayTileCache } );

                                    sceneView.scene.operationalLayers.append(threeDayLayer);
                                    sceneView.scene.operationalLayers.setProperty(1, "name", "Current daily flooded area %1".arg(app.viewName));
                                    sceneView.scene.operationalLayers.setProperty(1, "description", "This is an offline version of the current daily flooded area %1 layer. This layer was saved on %2".arg(app.viewName).arg(new Date(Number(oMLyrsModel.get(index)["date_created"])).toString()));
                                }
                            }

                            Image {
                                source: "../assets/load.png"
                                height: 24 * scaleFactor
                                width: 24 * scaleFactor
                                anchors.centerIn: parent
                            }
                        }

                        Button {
                            id: removeOffMBtn

                            width: 0.1 * oMDelegate.width
                            height: 40 * scaleFactor
                            visible: false

                            Material.background: "#00693e"

                            onClicked: {
                                offMRemIx = index;
                                clearSingleOffM.visible = true;
                            }

                            Image {
                                source: "../assets/clear.png"
                                height: 24 * scaleFactor
                                width: 24 * scaleFactor
                                anchors.centerIn: parent
                            }
                        }

                        Component.onCompleted: {
                            if (name !== "NAME") {
                                removeOffMBtn.visible = true;
                                if (!app.isOnline) {
                                    loadOffMBtn.visible = true;
                                }
                            }
                        }
                    }

                }
            }
        }

        Text {
            id: clearAllOffMTrigger
            visible: false
            anchors.bottom: parent.bottom
            anchors.right: closeOfflinePg.left
            anchors.bottomMargin: 13 * scaleFactor
            anchors.rightMargin: 30 * scaleFactor
            text: qsTr("CLEAR ALL")
            color: "#00693e"
            font {
                pixelSize: 14 * scaleFactor
                bold: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    clearAllOffM.visible = true;
                }
            }
        }

        Text {
            id: closeOfflinePg
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
        id: export2WkTask
        url: 'https://diluvium.colorado.edu/arcgisonline/rest/services/dfo_layers/two_week_flooded_area_%1/MapServer'.arg(viewName.toLowerCase().replace(" ", ""))
    }

    ExportTileCacheTask {
        id: export3DayTask
        url: 'https://diluvium.colorado.edu/arcgisonline/rest/services/dfo_layers/three_day_water_extent_%1/MapServer'.arg(viewName.toLowerCase().replace(" ", ""))
    }

    ExportTileCacheTask {
        id: exportTask

        credential: Credential {
            id: cred
            username: 'DFOappUsers2'
            password: 'Q8o4RKrn!6aNf'
        }

        url:  basemapUrls[menu.comboBoxBasemap.displayText]

        property var exportJob
        property var export2WkJob
        property var export3DayJob
        property var estimateJobSize
        property url layerPathtoUrl

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

            convertPathtoUrl.url = networkRequest.responsePath;
            layerPathtoUrl = convertPathtoUrl.url;
            export2WkJob = export2WkTask.exportTileCache(params, layerPathtoUrl);
            if (export2WkJob) {
                // show the export window
                exportWindow.visible = true;

                // connect to the job's status changed signal to know once it is done
                export2WkJob.jobStatusChanged.connect(update2WkJobStatus);
                export2WkJob.start();
            }

            convertPathtoUrl.url = networkRequest2.responsePath;
            layerPathtoUrl = convertPathtoUrl.url;
            export3DayJob = export3DayTask.exportTileCache(params, layerPathtoUrl);
            if (export3DayJob) {
                // show the export window
                exportWindow.visible = true;

                // connect to the job's status changed signal to know once it is done
                export3DayJob.jobStatusChanged.connect(update3DayJobStatus);
                export3DayJob.start();
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
                break;
            default:
                break;
            }
        }

        function update2WkJobStatus() {
            switch(export2WkJob.jobStatus) {
            case Enums.JobStatusFailed:
                var jobMessages = JSON.stringify(export2WkJob.json);
                if (jobMessages.includes("Tile cache download URL retrieved: https://diluvium.colorado.edu/arcgis/rest/directories/arcgisoutput/dfo_layers/")) {
                    layer2WkDownloadUrl = "https://diluvium.colorado.edu/arcgisonline/rest/directories/arcgisoutput/dfo_layers" + jobMessages.split("Tile cache download URL retrieved: https://diluvium.colorado.edu/arcgis/rest/directories/arcgisoutput/dfo_layers")[1].split("\",")[0];
                    statusText = "Adding two week layer...";
                    offlinePg.networkRequest.send();
                } else {
                    statusText = "Export failed";
                    exportWindow.hideWindow(5000);
                    break;
                }
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
                statusText = "Adding two week layer...";
                exportWindow.hideWindow(1500);
                break;
            default:
                break;
            }
        }

        function update3DayJobStatus() {
            switch(export3DayJob.jobStatus) {
            case Enums.JobStatusFailed:
                var jobMessages = JSON.stringify(export3DayJob.json);
                if (jobMessages.includes("Tile cache download URL retrieved: https://diluvium.colorado.edu/arcgis/rest/directories/arcgisoutput/dfo_layers/")) {
                    layer3DayDownloadUrl = "https://diluvium.colorado.edu/arcgisonline/rest/directories/arcgisoutput/dfo_layers" + jobMessages.split("Tile cache download URL retrieved: https://diluvium.colorado.edu/arcgis/rest/directories/arcgisoutput/dfo_layers")[1].split("\",")[0];
                    statusText = "Adding current layer...";
                    offlinePg.networkRequest2.send();
                } else {
                    statusText = "Export failed";
                    exportWindow.hideWindow(5000);
                    break;
                }
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
                statusText = "Adding current layer...";
                exportWindow.hideWindow(1500);
                break;
            default:
                break;
            }
        }

        Component.onDestruction: {
            if (exportJob && exportJob.jobStatusChanged) {
                exportJob.jobStatusChanged.disconnect(updateJobStatus);
            }

            if (export2WkJob && export2WkJob.jobStatusChanged) {
                export2WkJob.jobStatusChanged.disconnect(update2WkJobStatus);
            }

            if (export3DayJob && export3DayJob.jobStatusChanged) {
                export3DayJob.jobStatusChanged.disconnect(update3DayJobStatus);
            }
        }
    }

    NetworkRequest {
        id: networkRequest
        url: layer2WkDownloadUrl
        responsePath: AppFramework.userHomeFolder.filePath("ArcGIS/AppStudio/Data") + "/%1_%2_Two_Week.tpk".arg(viewName.replace(" ", "")).arg(fileName)

        onError: {
            statusText = "Two week layer download failed";
            exportWindow.hideWindow(1500);
        }
    }

    NetworkRequest {
        id: networkRequest2
        url: layer3DayDownloadUrl
        responsePath: AppFramework.userHomeFolder.filePath("ArcGIS/AppStudio/Data") + "/%1_%2_Current.tpk".arg(viewName.replace(" ", "")).arg(fileName)

        onReadyStateChanged: {
            if (readyState === NetworkRequest.DONE) {
                var visLayers = [];
                visLayers.push({
                    "name": "2-week accumulated flooded area %1".arg(viewName),
                    "legendName": "Two Week Flooded Area",
                    "symbolUrl": "../assets/legend_icons/2wk_blue.png",
                    "legendVisible": true
                });

                visLayers.push({
                    "name": "Current daily water extent %1".arg(viewName),
                    "legendName": "Current Daily Flooded Area / Clouds",
                    "symbolUrl": "../assets/legend_icons/3day_red.png",
                    "legendVisible": true
                });

                if (app.settings.value("offline_maps", false) === false) {
                    var offLineMaps = [];
                } else {
                    offLineMaps = JSON.parse(app.settings.value("offline_maps"));
                }

                var newOffMElm = {
                    "name": "%1_%2".arg(viewName.replace(" ", "")).arg(fileName),
                    "date_created": new Date().getTime().toString(),
                    "layer_list": visLayers,
                    "zoom": JSON.stringify(sceneView.currentViewpointCenter.json),
                    "extent": JSON.stringify(sceneView.currentViewpointExtent.json)
                };

                offLineMaps.push(newOffMElm);
                app.settings.setValue("offline_maps", JSON.stringify(offLineMaps));
                oMLyrsModel.append(newOffMElm);

                offLineMaptabBar.currentIndex = 1;
                exportWindow.hideWindow(1500);
            }
        }

//        onProgressChanged: console.log("progress:", progress)
        onError: {
//            console.log(errorText + ", " + errorCode)
            statusText = "Current layer download failed";
            exportWindow.hideWindow(1500);
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
            width: 200 * scaleFactor
            height: 120 * scaleFactor
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
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
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

    FileFolder {
        id: convertPathtoUrl
    }

    Controls.ClearAllOffMaps {
        id: clearAllOffM
        visible: false
    }

    Controls.ClearSingleOffMap {
        id: clearSingleOffM
        visible: false
    }
}

