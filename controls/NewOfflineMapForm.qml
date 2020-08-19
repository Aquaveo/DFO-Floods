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

        TextInput {
            id: oMNameInput
            text: "Enter Offline Map Name..."
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: storageInfoText.bottom
                topMargin: 20 * scaleFactor
            }
            maximumLength: 50
            validator: RegExpValidator { regExp: /[A-Za-z0-9\-\_]+/ }

            color: "#00693e"
            width: parent.width
            height: 40 * scaleFactor
            font.pixelSize: app.baseFontSize
            anchors.fill: parent
            horizontalAlignment: TextInput.AlignHCenter
            verticalAlignment: TextInput.AlignVCenter
            selectByMouse: true
            selectedTextColor: "white"
            selectionColor: "#249567"
            clip: true
            wrapMode: TextInput.WrapAnywhere

            onFocusChanged: {
                if (oMNameInput.text === "Enter Offline Map Name...") {
                    oMNameInput.text = ""
                }
            }

            onAcceptableInputChanged: {
                if (acceptableInput === false) {
                    confirmOMdownload.visible = false;
                    if (text !== "Enter Offline Map Name...") {
                        color = "red";
                    }
                } else {
                    color = "#00693e";
                    confirmOMdownload.visible = true;
                }
            }

            onAccepted: {
                focus = false;
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
                newOMMapForm.visible = false;
                exportWindow.visible = true;
                offlinePg.fileName = fileName;
                offlinePg.outputTileCache = AppFramework.userHomeFolder.fileUrl("ArcGIS/AppStudio/Data/%1_BasemapTileCache_%2.tpk".arg(viewName.replace(" ", "")).arg(fileName))

                // export the cache with the parameters
                offlinePg.exportTask.executeExportTileCacheTask(offlinePg.params);
            }

            visible: false;
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
