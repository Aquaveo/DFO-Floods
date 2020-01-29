import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0

import "../controls" as Controls

Rectangle {
    anchors.fill: parent
    color: "#80000000"

    property alias basemapcheck: basemapSSCheck.checked
    property alias layerListcheck: layerListSSCheck.checked
    property alias regioncheck: regionSSCheck.checked

    MouseArea {
        anchors.fill: parent
        onClicked: mouse.accepted = true
        onWheel: wheel.accepted = true
    }

    Rectangle {
        id: saveStateRect
        height: 0.75 * parent.height
        width: 0.75 * parent.width
        anchors.centerIn: parent
        radius: 3 * scaleFactor
        Material.background:  "#FAFAFA"
        Material.elevation: 24

        Text {
            id: titleText
            text: qsTr("Save App State")
            color: "#00693e"
            font{
                pixelSize: app.baseFontSize
                bold: true
            }
            padding: 24 * scaleFactor
            anchors.top: parent.top
            anchors.bottom: settingsListView.top
        }

        Rectangle {
            id: basemapSSRect
            width: parent.width
            height: 40 * scaleFactor
            anchors.top: titleText.bottom

            Row {
                id: basemapSSRow
                spacing: 30 * scaleFactor
                anchors.verticalCenter: parent.verticalCenter
                leftPadding: 20 * scaleFactor
                rightPadding: 20 * scaleFactor

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 0.7 * saveStateRect.width - (20 * scaleFactor)
                    text: "BASEMAP"
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14 * scaleFactor
                }

                CheckBox {
                    id: basemapSSCheck
                    width: 0.3 * saveStateRect.width - (20 * scaleFactor)
                    height: basemapSSRow.height
                    Material.accent: "#00693e"
                    checked: app.settings.value("basemap", false) !== false ? true : false

                    indicator: Rectangle {
                        width: 30 * scaleFactor
                        height: 30 * scaleFactor
                        radius: 2 * scaleFactor
                        anchors.leftMargin: 8 * scaleFactor
                        anchors.verticalCenter: parent.verticalCenter
                        border {
                            color: "black"
                            width: 2 * scaleFactor
                        }

                        Rectangle {
                            width: parent.width
                            height: parent.height
                            radius: 2 * scaleFactor
                            color: "#00693e"
                            visible: basemapSSCheck.checked

                            Image {
                                width: parent.width * 0.8
                                height: parent.height * 0.8
                                anchors.centerIn: parent
                                source: "../assets/checkmark.png"
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: layerListSSRect
            width: parent.width
            height: 40 * scaleFactor
            anchors.top: basemapSSRect.bottom

            Row {
                id: layerListSSRow
                spacing: 30 * scaleFactor
                anchors.verticalCenter: parent.verticalCenter
                leftPadding: 20 * scaleFactor
                rightPadding: 20 * scaleFactor

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 0.7 * saveStateRect.width - (20 * scaleFactor)
                    text: "LAYERS LIST"
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14 * scaleFactor
                }

                CheckBox {
                    id: layerListSSCheck
                    width: 0.3 * saveStateRect.width - (20 * scaleFactor)
                    height: layerListSSRow.height
                    Material.accent: "#00693e"
                    checked: app.settings.value("layer_list", false) !== false ? true : false

                    indicator: Rectangle {
                        width: 30 * scaleFactor
                        height: 30 * scaleFactor
                        radius: 2 * scaleFactor
                        anchors.leftMargin: 8 * scaleFactor
                        anchors.verticalCenter: parent.verticalCenter
                        border {
                            color: "black"
                            width: 2 * scaleFactor
                        }

                        Rectangle {
                            width: parent.width
                            height: parent.height
                            radius: 2 * scaleFactor
                            color: "#00693e"
                            visible: layerListSSCheck.checked

                            Image {
                                width: parent.width * 0.8
                                height: parent.height * 0.8
                                anchors.centerIn: parent
                                source: "../assets/checkmark.png"
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: regionSSRect
            width: parent.width
            height: 40 * scaleFactor
            anchors.top: layerListSSRect.bottom

            Row {
                id: regionSSRow
                spacing: 30 * scaleFactor
                anchors.verticalCenter: parent.verticalCenter
                leftPadding: 20 * scaleFactor
                rightPadding: 20 * scaleFactor

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 0.7 * saveStateRect.width - (20 * scaleFactor)
                    text: "REGION"
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14 * scaleFactor
                }

                CheckBox {
                    id: regionSSCheck
                    width: 0.3 * saveStateRect.width - (20 * scaleFactor)
                    height: regionSSRow.height
                    Material.accent: "#00693e"
                    checked: app.settings.value("region", false) !== false ? true : false

                    indicator: Rectangle {
                        width: 30 * scaleFactor
                        height: 30 * scaleFactor
                        radius: 2 * scaleFactor
                        anchors.leftMargin: 8 * scaleFactor
                        anchors.verticalCenter: parent.verticalCenter
                        border {
                            color: "black"
                            width: 2 * scaleFactor
                        }

                        Rectangle {
                            width: parent.width
                            height: parent.height
                            radius: 2 * scaleFactor
                            color: "#00693e"
                            visible: regionSSCheck.checked

                            Image {
                                width: parent.width * 0.8
                                height: parent.height * 0.8
                                anchors.centerIn: parent
                                source: "../assets/checkmark.png"
                            }
                        }
                    }
                }
            }
        }

        Text {
            id: applySaveStateRect
            anchors.bottom: parent.bottom
            anchors.right: clearSaveStateText.left
            anchors.bottomMargin: 13 * scaleFactor
            anchors.rightMargin: 30 * scaleFactor
            text: qsTr("APPLY")
            color: "#00693e"
            font {
                pixelSize: 14 * scaleFactor
                bold: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (basemapSSCheck.checked) {
                        app.settings.setValue("basemap", menu.comboBoxBasemap.displayText);
                    } else if (!basemapSSCheck.checked) {
                        app.settings.setValue("basemap", false);
                    }

                    if (layerListSSCheck.checked) {
                        var dataModelArr = [];

                        for (var i = 0; i < sceneView.scene.operationalLayers.count; i++) {
                            dataModelArr.push({
                                "name": sceneView.scene.operationalLayers.get(i)["name"],
                                "description": sceneView.scene.operationalLayers.get(i)["description"],
                                "visible": sceneView.scene.operationalLayers.get(i)["visible"],
                                "url": sceneView.scene.operationalLayers.get(i)["url"],
                                "layerNames": sceneView.scene.operationalLayers.get(i)["layerNames"],
                                "legendName": sceneView.legendListView.model.get(i)["name"],
                                "symbolUrl": sceneView.legendListView.model.get(i)["symbolUrl"],
                                "legendVisible": sceneView.legendListView.model.get(i)["visible"]
                            });
                        }

                        app.settings.setValue("layer_list", JSON.stringify(dataModelArr));
                    } else if (!layerListSSCheck.checked) {
                        app.settings.setValue("layer_list", false);
                    }

                    if (regionSSCheck.checked) {
                        if (qmlfile !== "./views/StartPage.qml") {
                            app.settings.setValue("region", qmlfile);
                        } else {
                            app.settings.setValue("region", false);
                        }
                    } else if (!regionSSCheck.checked) {
                        app.settings.setValue("region", false);
                    }

                    pageItem.saveState.visible = 0;
                }
            }
        }

        Text {
            id: clearSaveStateText
            anchors.bottom: parent.bottom
            anchors.right: closeSaveStateRect.left
            anchors.bottomMargin: 13 * scaleFactor
            anchors.rightMargin: 30 * scaleFactor
            text: qsTr("CLEAR")
            color: "#00693e"
            font {
                pixelSize: 14 * scaleFactor
                bold: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    clearAllSS.visible = true;
                    pageItem.saveState.visible = false;
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
                    pageItem.saveState.visible = false;
                }
            }
        }
    }

    DropShadow {
        id: saveStateRectShadow
        source: saveStateRect
        anchors.fill: saveStateRect
        width: source.width
        height: source.height
        cached: true
        radius: 8 * scaleFactor
        samples: 17
        color: "#80000000"
        smooth: true
    }
}
