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

        ListView {
            id: settingsListView
            anchors.topMargin: 64 * scaleFactor
            anchors.bottomMargin: 40 * scaleFactor
            anchors.fill: parent
            model: ListModel {
                id: settingItems

                ListElement { name: "Region"; save: false; saveFrom: ""}
                ListElement { name: "Basemap"; save: false; saveFrom: "menu.comboBoxBasemap.currentText"}
            }

            clip: true
            ScrollBar.vertical: ScrollBar {
                active: true
                width: 20 * scaleFactor
            }

            delegate: Rectangle {
                id: saveStateDelegate
                width: parent.width
                height: 40 * scaleFactor
                border.color: "#00693e"

                Row {
                    id: settingStateRow
                    spacing: 30 * scaleFactor
                    anchors.verticalCenter: parent.verticalCenter
                    leftPadding: 20 * scaleFactor
                    rightPadding: 20 * scaleFactor

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 0.7 * saveStateRect.width - (20 * scaleFactor)
                        text: name
                        wrapMode: Text.WordWrap
                        font.pixelSize: 14 * scaleFactor
                    }

                    CheckBox {
                        id: saveStateCheck
                        width: 0.3 * saveStateRect.width - (20 * scaleFactor)
                        height: settingStateRow.height
                        Material.accent: "#00693e"
                        checked: app.settings.boolValue(name.toLowerCase().replace(/ /g,"_"))

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
                                visible: saveStateCheck.checked

                                Image {
                                    width: parent.width * 0.8
                                    height: parent.height * 0.8
                                    anchors.centerIn: parent
                                    source: "../assets/checkmark.png"
                                }
                            }
                        }

                        onCheckedChanged: {
                            save = checked;
                        }
                    }
                }
            }
        }

        Text {
            id: applySaveStateRect
            anchors.bottom: parent.bottom
            anchors.right: closeSaveStateRect.left
            anchors.bottomMargin: 13 * scaleFactor
            anchors.rightMargin: 16 * scaleFactor
            text: qsTr("APPLY")
            color: "#00693e"
            font {
                pixelSize: 14 * scaleFactor
                bold: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    for (var i=0; i<settingItems.rowCount(); i++) {
                        if (settingItems.get(i).save) {
                            app.settings.setValue(settingItems.get(i).name.toLowerCase().replace(/ /g,"_"), eval(settingItems.get(i).saveFrom));
                        } else {
                            app.settings.remove(settingItems.get(i).name.toLowerCase().replace(/ /g,"_"));
                        }
                    }
                    pageItem.saveState.visible = 0;
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
                    pageItem.saveState.visible = 0;
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
