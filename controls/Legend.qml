import QtQuick 2.0
import QtQuick.Controls 2.1

Rectangle {
    id: legendRect
    property alias legendListView: legendListView

    anchors {
        margins: 10 * scaleFactor
        bottomMargin: 30 * scaleFactor
        left: parent.left
        bottom: sceneView.bottom
    }

    property bool collapsed: true
    height: 40 * scaleFactor
    width: 48 * scaleFactor
    color: "#00693e"
    opacity: 0.95
    radius: 10 * scaleFactor
    clip: true

    // Animate the expand and collapse of the legend
    Behavior on height {
        SpringAnimation {
            spring: 3
            damping: .8
        }
    }

    Behavior on width {
        SpringAnimation {
            spring: 3
            damping: .8
        }
    }

    // Catch mouse signals so they don't propagate to the map
    MouseArea {
        anchors.fill: parent
        onClicked: mouse.accepted = true
        onWheel: wheel.accepted = true
    }

    // Create UI for the user to select the layer to display
    Column {
        anchors {
            fill: parent
            leftMargin: 10 * scaleFactor
            rightMargin: 10 * scaleFactor
            bottomMargin: 6 * scaleFactor
            topMargin: 6 * scaleFactor
        }
        spacing: 6 * scaleFactor

        Row {
            id: legendTitleRow
            spacing: 55 * scaleFactor

            Text {
                id: legendTitleText
                anchors.verticalCenter: parent.verticalCenter
                color: "white"
                font {
                    pixelSize: 18 * scaleFactor
                    bold: true
                }
            }

            // Legend icon to allow expanding and collapsing
            Image {
                anchors.verticalCenter: parent.verticalCenter
                source: "../assets/legend.png"
                width: 28 * scaleFactor
                height: width

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (legendRect.collapsed) {
                            legendTitleText.text = qsTr("Legend");
                            legendRect.width = 175 * scaleFactor;
                            legendRect.height = 200 * scaleFactor < pageItem.height - 85 * scaleFactor ? 200 * scaleFactor : pageItem.height - 85 * scaleFactor;
                            legendRect.collapsed = false;
                        } else {
                            legendTitleText.text = "";
                            legendRect.width = 48 * scaleFactor;
                            legendRect.height = 40 * scaleFactor;
                            legendRect.collapsed = true;
                        }
                    }
                }
            }
        }

        // Create a list view to display the legend
        ListView {
            id: legendListView
            anchors.margins: 10 * scaleFactor
            anchors.leftMargin: 0
            width: 165 * scaleFactor
            height: 160 * scaleFactor
            contentHeight: childrenRect.height
            clip: true;

            model: legendModel

            delegate: Item {
                id: legendDelegate
                width: parent.width
                height: model.visible ? (defaultLayersArr.indexOf(model.name) === -1 ? childrenRect.height + 10 * scaleFactor : 35 * scaleFactor) : 0
                visible: model.visible
                clip: true

                Rectangle {
                    id: legendInnerRect
                    height: childrenRect.height

                    Row {
                        id: legendRow
                        height: childrenRect.height < 35 * scaleFactor ? 35 * scaleFactor : childrenRect.height
                        spacing: 10 * scaleFactor

                        Image {
                            id: legendSymbol
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            id: legendText
                            width: defaultLayersArr.indexOf(model.name) === -1 ? 150 * scaleFactor : (150 * scaleFactor) - legendSymbol.width
                            text: name
                            color: "white"
                            wrapMode: Text.Wrap
                            font.pixelSize: 12 * scaleFactor
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Component.onCompleted: {
                        if (defaultLayersArr.indexOf(model.name) === -1) {
                            legendSymbol.destroy();
                            if (name.includes("ECMWF ")) {
                                Qt.createQmlObject('import QtQuick 2.7; Rectangle {width: 0.65 * legendListView.width; height: childrenRect.height; color: "transparent"; clip: true; anchors.top: legendRow.bottom; Image {id: legendSymbol; source: symbolUrl}}', legendInnerRect);
                            } else {
                                Qt.createQmlObject('import QtQuick 2.7; Image {id: legendSymbol; source: symbolUrl; anchors.top: legendRow.bottom}', legendInnerRect);
                            }
                        } else {
                            legendSymbol.source = symbolUrl;
                        }
                    }
                }
            }
        }
    }
}
