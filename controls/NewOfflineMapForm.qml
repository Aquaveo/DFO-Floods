import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.5

Rectangle {
    id: oMForm
    anchors.fill: parent
    color: "#80000000"

    property alias fileName: oMNameInput.text

    MouseArea {
        anchors.fill: parent
        onClicked: mouse.accepted = true
        onWheel: wheel.accepted = true
    }

    Rectangle {
        id: popUpOMForm
        height: 280 * scaleFactor
        width: 280 * scaleFactor
        anchors.centerIn: parent
        radius: 3 * scaleFactor
        Material.background:  "#FAFAFA"
        Material.elevation: 24

        Text {
            id: storageInfoText
            width: parent.width
            text: "The current extent would occupy <b>" + ((offlinePg.exportTask.estimateJobSize.result.fileSizeAsInt + 10000000)/1000000).toFixed(2) + "MB</b> of storage. Your device currently has <b> " + (app.storageInfo.bytesFree/1000000000).toFixed(2) + "GB</b> available storage.";
            font {
                pixelSize: app.baseFontSize
            }
            padding: 24 * scaleFactor
            anchors.top: parent.top
            wrapMode: Text.WordWrap
        }

        TextField {
            id: oMNameInput
            placeholderText: "Enter Offline Map Name..."
            text: ""
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: storageInfoText.bottom
                topMargin: 20 * scaleFactor
            }

            implicitWidth: 100 * app.scaleFactor
            implicitHeight: 40 * app.scaleFactor

            maximumLength: 50
            validator: RegExpValidator { regExp: /[A-Za-z0-9\-\_]+/ }

            background: Rectangle {
                radius: 5
                color: "transparent"
                implicitWidth: 100 * app.scaleFactor
                implicitHeight: 40 * app.scaleFactor
                border.color: "transparent"
                border.width: 1
            }

            cursorDelegate: Rectangle {
                id: cursorRect
                visible: oMNameInput.cursorVisible
                color: "#00693e"
                width: oMNameInput.cursorRectangle.width

                OpacityAnimator {
                    target: cursorRect
                    from: 0
                    to: 1
                    duration: 1000
                    running: true
                    loops: 60
                }
            }

            color: "#00693e"
            width: parent.width
            height: 40 * scaleFactor
            font.pixelSize: app.baseFontSize
            anchors.fill: parent
            horizontalAlignment: TextField.AlignHCenter
            verticalAlignment: TextField.AlignVCenter
            selectByMouse: true
            selectedTextColor: "white"
            selectionColor: "#249567"
            clip: true
            wrapMode: TextField.WrapAnywhere

            onAccepted: {
                focus = false;
                newOMMapForm.visible = false;
                exportWindow.visible = true;
                offlinePg.fileName = fileName;
                offlinePg.outputTileCache = AppFramework.userHomeFolder.fileUrl("ArcGIS/AppStudio/Data/%1_BasemapTileCache_%2.tpk".arg(viewName.replace(" ", "")).arg(fileName))

                // export the cache with the parameters
                offlinePg.exportTask.executeExportTileCacheTask(offlinePg.params);
            }
        }

        Button {
            id: confirmOMdownload
            width: 0.8 * parent.width
            height: 50 * scaleFactor
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: popUpOMForm.bottom
                bottomMargin: 50 * scaleFactor
            }

            Material.background: "#00693e"

            text: "CONFIRM DOWNLOAD"
            background: Rectangle {
                width: parent.width
                height: parent.height
                color: "#00693e"
                radius: 6 * scaleFactor
            }

            contentItem: Text {
                text: confirmOMdownload.text
                font.pixelSize: 14 * scaleFactor
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            onClicked: {
                if (oMNameInput.text !== "") {
                    newOMMapForm.visible = false;
                    exportWindow.visible = true;
                    offlinePg.fileName = fileName;
                    offlinePg.outputTileCache = AppFramework.userHomeFolder.fileUrl("ArcGIS/AppStudio/Data/%1_BasemapTileCache_%2.tpk".arg(viewName.replace(" ", "")).arg(fileName))

                    // export the cache with the parameters
                    offlinePg.exportTask.executeExportTileCacheTask(offlinePg.params);
                } else {
                    oMNameInput.focus = true;
                }
            }
        }

        Text {
            id: cancelOMDownload
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.bottomMargin: 13 * scaleFactor
            anchors.rightMargin: 16 * scaleFactor
            text: qsTr("CANCEL")
            color: "#00693e"
            font {
                pixelSize: 14 * scaleFactor
                bold: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    newOMMapForm.visible = false;
                }
            }
        }
    }

    DropShadow {
        source: popUpOMForm
        anchors.fill: popUpOMForm
        width: source.width
        height: source.height
        cached: true
        radius: 8 * scaleFactor
        samples: 17
        color: "#80000000"
        smooth: true
    }
}
