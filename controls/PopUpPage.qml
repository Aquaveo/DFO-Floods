import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0

import "../controls" as Controls

Rectangle {
    property alias listViewCurrentIndex: popUpListView.currentIndex
    property alias tandCBtn: tandCBtn

    anchors.fill: parent
    color: "#80000000"

    MouseArea {
        anchors.fill: parent
        onClicked: mouse.accepted = true
        onWheel: wheel.accepted = true
    }

    Rectangle {
        id: popUpWindow
        height: 270 * scaleFactor
        width: 280 * scaleFactor
        anchors.centerIn: parent
        radius: 3 * scaleFactor
        Material.background: "#FAFAFA"
        Material.elevation: 24

        Text {
            id: titleText
            text: qsTr("Choose a Region")
            font{
                pixelSize: app.baseFontSize
                bold: true
            }
            padding: 24 * scaleFactor
            anchors.top: parent.top
            anchors.bottom: popUpListView.top
        }

        ListView {
            id: popUpListView
            anchors.topMargin: 64 * scaleFactor
            anchors.bottomMargin: 40 * scaleFactor
            anchors.fill: parent
            model: ListModel {
                id: viewItems

                ListElement { name: "Africa"; url: "../views/Africa.qml"; description: "<p> This app was developed by the DFO and Remote Sensing Solutions, Inc, with support from NASA SBIR. The displayed layer group contains different flood products for Africa.<br></p>" }
                ListElement { name: "Asia"; url: "../views/Asia.qml"; description: "<p> This app was developed by the DFO and Remote Sensing Solutions, Inc, with support from NASA SBIR. The displayed layer group contains different flood products for Asia.<br></p>" }
                ListElement { name: "Australia"; url: "../views/Australia.qml"; description: "<p> This app was developed by the DFO and Remote Sensing Solutions, Inc, with support from NASA SBIR. The displayed layer group contains different flood products for Australia.<br></p>" }
                ListElement { name: "Europe"; url: "../views/Europe.qml"; description: "<p> This app was developed by the DFO and Remote Sensing Solutions, Inc, with support from NASA SBIR. The displayed layer group contains different flood products for Europe.<br></p>" }
                ListElement { name: "North America"; url: "../views/NorthAmerica.qml"; description: "<p> This app was developed by the DFO and Remote Sensing Solutions, Inc, with support from NASA SBIR. The displayed layer group contains different flood products for North America.<br></p>" }
                ListElement { name: "South America"; url: "../views/SouthAmerica.qml"; description: "<p> This app was developed by the DFO and Remote Sensing Solutions, Inc, with support from NASA SBIR. The displayed layer group contains different flood products for South America.<br></p>" }
            }

            clip: true
            ScrollBar.vertical: ScrollBar {
                active: true
                width: 20 * scaleFactor
            }

            delegate: Rectangle {
                width: 280 * scaleFactor
                height: 40 * scaleFactor
                color: qmlfile.toString().match(viewItems.get(index).url.toString().replace('..', ''))
                       ? index===popUpListView.currentIndex || app.settings.value("region", false) !== false
                         ? "#249567"
                         : "transparent"
                       : "transparent"

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    padding: 24 * scaleFactor
                    font.pixelSize: 14 * scaleFactor
                    text: name
                }

                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        popUp.visible = 0;
                        initLoad = false;
                        popUpListView.currentIndex = index
                        qmlfile = viewItems.get(index).url
                        viewName = viewItems.get(index).name
                        descriptionText = viewItems.get(index).description
                    }
                }
            }
        }

        Text {
            id: cancelText
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
                    popUp.visible = 0
                }
            }
        }
    }

    DropShadow {
        id: headerbarShadow
        source: popUpWindow
        anchors.fill: popUpWindow
        width: source.width
        height: source.height
        cached: true
        radius: 8 * scaleFactor
        samples: 17
        color: "#80000000"
        smooth: true
    }

    Controls.TandCButton {
        id: tandCBtn
        visible: true
    }

    onVisibleChanged: {
        if (initLoad) {
            cancelText.visible = false;
        } else {
            cancelText.visible = true;
            tandCBtn.visible = false;
        }
    }
}
