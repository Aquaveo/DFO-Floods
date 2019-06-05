import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0

import "../controls" as Controls

Rectangle {
    id: descLyrPage
    width: parent.width
    height: parent.height
    anchors.fill:parent

    onVisibleChanged: {
        if (descLyrPage.visible === false) {
            popUpReorder.visible = false;
        }
    }

    property string desc: pageItem.descriptionLyr;
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        clip:true

        Rectangle {
            id:descLyrheader
            Layout.alignment: Qt.AlignTop
            color: "#00693e"
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50 * scaleFactor

            Button {
                Material.background: "transparent"
                height: 30 * scaleFactor
                width: 30 * scaleFactor
                anchors {
                    right: parent.right
                    rightMargin: 10 * scaleFactor
                    verticalCenter: parent.verticalCenter
                }

                Image {
                    source: "../assets/clear.png"
                    height: 30 * scaleFactor
                    width: 30 * scaleFactor
                    anchors.centerIn: parent
                }

                onClicked: {
                    descLyrPage.visible = 0;
                    menu.open()
                }
            }

            Text {
                id: aboutApp
                text:qsTr("About this Layer")
                color:"white"
                font.pixelSize: app.baseFontSize * 1.1
                font.bold: true
                anchors.centerIn: parent
                maximumLineCount: 2
                elide: Text.ElideRight
            }
        }

        Rectangle {
            color:"black"
            Layout.fillWidth: true
            Layout.fillHeight: true

            Flickable {
                anchors.fill: parent
                contentHeight: parent.height > descLyrText.height ? parent.height : descLyrText.height
                clip:true

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (popUpReorder.visible === true) {
                            popUpReorder.visible = false;
                        }
                    }
                }

                Text {
                    id: descLyrText
                    text: desc
                    y: 30 * scaleFactor
                    bottomPadding: 60 * scaleFactor
                    textFormat: Text.StyledText
                    anchors.horizontalCenterOffset: 0
                    color:"white"
                    width: 0.85 * parent.width
                    horizontalAlignment: Text.AlignLeft
                    linkColor: "#e5e6e7"
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: app.baseFontSize
                    onLinkActivated: Qt.openUrlExternally(link)
                }
            }
        }
    }

    Controls.RemoveLyrBtn {
        id: removeLyrBtn
    }

    Controls.ReorderLyrBtn {
        id: reorderLyrBtn
    }

    Controls.ReorderInput{
        id: popUpReorder
    }
}
