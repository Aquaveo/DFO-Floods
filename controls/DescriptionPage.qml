import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1


import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Rectangle{
    id: descPage
    width: parent.width
    height: parent.height
    anchors.fill:parent

    ColumnLayout{
        anchors.fill:parent
        spacing: 0
        clip:true

        Rectangle{
            id:descPageheader
            Layout.alignment: Qt.AlignTop
            color:"#00693e"
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50 * scaleFactor

            ImageButton {
                source: "../assets/clear.png"
                height: 30 * scaleFactor
                width: 30 * scaleFactor
                checkedColor: "transparent"
                pressedColor: "transparent"
                hoverColor: "transparent"
                glowColor: "transparent"
                anchors {
                    right: parent.right
                    rightMargin: 10 * scaleFactor
                    verticalCenter: parent.verticalCenter
                }
                onClicked: {
                    descPage.visible = 0
                }
            }

            Text {
                id: aboutApp
                text:qsTr("About")
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
                contentHeight: descText.height + imageRect.height + feedbackText.height + feedbackRect.height + (100 * scaleFactor)
                clip: true
                
                Text {
                    id: descText
                    text: descriptionText
                    y: 30 * scaleFactor
                    textFormat: Text.StyledText
                    anchors.horizontalCenterOffset: 0
                    color:"white"
                    width: 0.85 * parent.width
                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: app.baseFontSize
                }

                Column {
                    id: imageRect
                    width: parent.width
                    spacing: 10 * scaleFactor
                    anchors.top: descText.bottom

                    Text {
                        text: qsTr("Sponsors: ")
                        textFormat: Text.StyledText
                        color:"white"
                        width: 0.85 * parent.width
                        horizontalAlignment: Text.AlignLeft
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: app.baseFontSize
                        font.bold: true
                    }

                    Image {
                        width: 0.5 * parent.width
                        height: sourceSize.height * width * 0.35/100
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "../assets/DFOLogo.jpg"

                        MouseArea {
                            anchors.fill: parent
                            onClicked: Qt.openUrlExternally('http://floodobservatory.colorado.edu/')
                        }
                    }

                    Image {
                        width: 0.85 * parent.width
                        height: sourceSize.height * width * 0.2/100
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "../assets/RSSlogo_inlineTXT.png"

                        MouseArea {
                            anchors.fill: parent
                            onClicked: Qt.openUrlExternally('http://remotesensingsolutions.com/')
                        }
                    }

                    Image {
                        width: 0.85 * parent.width
                        height: sourceSize.height * width * 0.225/100
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "../assets/nasaLogo.png"

                        MouseArea {
                            anchors.fill: parent
                            onClicked: Qt.openUrlExternally('https://sbir.nasa.gov/')
                        }
                    }
                }

                Row {
                    id: fbTitle
                    width: 0.9 * parent.width
                    height: 50 * scaleFactor
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: imageRect.bottom
                    anchors.topMargin: 20 * scaleFactor

                    Text {
                        id: feedbackText
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("Send Feedback")
                        textFormat: Text.StyledText
                        color:"white"
                        width: 0.75 * parent.width
                        horizontalAlignment: Text.AlignLeft
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight

                        font.pixelSize: app.baseFontSize
                        font.bold: true
                    }

                    Button {
                        id:feedbackSend
                        anchors.verticalCenter: parent.verticalCenter

                        width: 0.25 * parent.width
                        height: 50 * scaleFactor

                        Material.background: "#00693e"
                        text: "SEND"

                        contentItem: Text {
                            text: feedbackSend.text
                            font.pixelSize: 14 * scaleFactor
                            font.bold: true
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        onClicked: {
                             Qt.openUrlExternally('mailto:info2dfo@gmail.com?subject=DFO App Feedback&body=' + feedbackTextArea.text);
                        }
                    }
                }

                Rectangle {
                    id: feedbackRect
                    width: 0.9 * parent.width
                    height: 160 * scaleFactor > feedbackTextArea.contentHeight ? 200 * scaleFactor : feedbackTextArea.contentHeight + 50 * scaleFactor
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: fbTitle.bottom
                    radius: 6 * scaleFactor
                    color: "white"
                    border.color: "darkgrey"

                    TextArea {
                        id: feedbackTextArea
                        color: "black"
                        Material.accent:"#00693e"
                        width: 0.85 * parent.width
                        anchors.fill: parent
                        anchors.margins: 10 * scaleFactor
                        anchors.horizontalCenter: parent.horizontalCenter

                        font.pixelSize: 14 * scaleFactor
                        selectByMouse: true
                        selectedTextColor: "white"
                        selectionColor: "#249567"
                        wrapMode: TextArea.Wrap
                        clip: true
                    }
                }
            }
        }
    }
}
