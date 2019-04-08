import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.4

Drawer {
    id: menu
    width: 0.75 * parent.width
    height: parent.height

    Column {
        id: mainColum
        height: parent.height
        anchors.fill: parent

        Rectangle {
            id: menuHeader
            height: 50 * scaleFactor
            width: parent.width
            color: Qt.darker("#00693e")

            Text {
                id: menuTitle
                text: qsTr("Menu")
                color: "white"
                font.pointSize: 18
                anchors.centerIn: parent
            }
        }

        Text {
            id: basemapTitle
            text: qsTr("Basemap: ")
            color: "black"
            font.pointSize: 12
            anchors.left: parent.left
            anchors.top: menuHeader.bottom
            padding: 8
        }

        ComboBox {
            id: comboBoxBasemap
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: basemapTitle.bottom
            width: 0.98 * parent.width
            height: 30 * scaleFactor
            Material.accent:"#00693e"
            background: Rectangle {
                radius: 6 * scaleFactor
                border.color: "darkgrey"
                width: parent.width
                height: 30 * scaleFactor
            }

            model: ["Topographic","Streets","Imagery","Terrain"]
            onCurrentTextChanged: {
                if (sceneView.scene.loadStatus === Enums.LoadStatusLoaded)
                    changeBasemap();
            }

            function changeBasemap() {
                switch (comboBoxBasemap.currentText) {
                case "Topographic":
                    sceneView.scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapTopographic");
                    break;
                case "Streets":
                    sceneView.scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapStreets");
                    break;
                case "Imagery":
                    sceneView.scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapImageryWithLabels");
                    break;
                case "Terrain":
                    sceneView.scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapTerrainWithLabels");
                    break;
                default:
                    sceneView.scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapTopographic");
                    break;
                }
            }
        }

        Text {
            id: layerContentTitle
            text: qsTr("Layers List: ")
            color: "black"
            font.pointSize: 12
            anchors.left: parent.left
            anchors.top: comboBoxBasemap.bottom
            padding: 8
        }

        // Create a list view to display the layer items
        ListView {
            id: layerVisibilityListView
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: layerContentTitle.bottom
            width: 0.95 * parent.width
            height: childrenRect.height <= 0.3 * menu.height ? childrenRect.height : 0.3 * menu.height
            clip: true

            // Assign the model to the list model of sublayers
//            model: sceneView.scene.operationalLayers
            model: layerList

            // Assign the delegate to the delegate created above
            delegate: Item {
                id: layerVisibilityDelegate
                width: parent.width
                height: 35 * scaleFactor

                Row {
                    spacing: 0
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 0.65 * layerVisibilityListView.width
                        text: name
                        wrapMode: Text.WordWrap
                        font.pixelSize: 12 * scaleFactor
                    }

                    Switch {
                        width: 0.25 * layerVisibilityListView.width

                        Material.accent: "#00693e"

                        onCheckedChanged: {
                            layerVisible = checked;
                        }
                        Component.onCompleted: {
                            checked = layerVisible;
                        }

                    }

                    Button {
                        id:infoLayer

                        width: 0.10 * layerVisibilityListView.width

                        Material.background: "transparent"

                        onClicked: {
                            pageItem.descriptionLyr = description
                            menu.close();
                            descLyrPage.visible = 1
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

        Text {
            id: eventLayersTitle
            text: qsTr("Extreme Events: ")
            color: "black"
            font.pointSize: 12
            anchors.left: parent.left
            anchors.top: layerVisibilityListView.bottom
            padding: 8
        }

        Rectangle {
            id: allExtremeEvRect
            width: 0.95 * parent.width
            height: 35 * scaleFactor
            anchors.left: parent.left
            anchors.top: eventLayersTitle.bottom

            Row {
                id: allExtremeEvRow
                width: parent.width
                spacing: 0
                anchors.verticalCenter: parent.verticalCenter

                CheckBox {
                    id: allEventLayersCheck
                    Material.accent: "#00693e"

                    onCheckedChanged: {
                        if (checked == true) {
                            menu.close()
                            selectEventLayersCheck.checked = false;
                            serviceEv = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wmsEventServiceUrl });

                            serviceEv.loadStatusChanged.connect(function() {
                                if (serviceEv.loadStatus === Enums.LoadStatusLoaded) {
                                    // get the layer info list
                                    var serviceEvInfo = serviceEv.serviceInfo;
                                    var layerInfos = serviceEvInfo.layerInfos;

                                    // get the desired layer from the list
                                    layerNAEv = layerInfos[0].sublayerInfos[0]
                                    var layerNAEvTiles = layerInfos[0].sublayerInfos
//                                    console.log(typeof layerNAEvTiles, layerNAEvTiles[1].extent.center.x, layerNAEvTiles[1].extent.center.y,'#################')

                                    wmsLayerEv = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                                           layerInfos: [layerNAEv],
                                                                                           visible: true
                                                                                       });

                                    sceneView.scene.operationalLayers.insert(0, wmsLayerEv);
                                    sceneView.scene.operationalLayers.setProperty(0, "name", "All Events");
                                    sceneView.scene.operationalLayers.setProperty(0, "description", layerNAEv.description);
                                }
                            });

                            serviceEv.load();
                        } else {
                            if (sceneView.scene.operationalLayers.get(0).name === "All Events") {
                                sceneView.scene.operationalLayers.remove(0,1);
                            };
                        }
                    }

                    Component.onCompleted: {
                        checked = false;
                    }
                }

                Text {
                    width: 0.45 * allExtremeEvRow.width
                    text: qsTr("View all")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 12 * scaleFactor
                    anchors.verticalCenter: parent.verticalCenter
                    padding: 8
                }
            }
        }

        Rectangle {
            id: selectExtremeEvRect
            width: 0.95 * parent.width
            height: 35 * scaleFactor
            anchors.left: parent.left
            anchors.top: allExtremeEvRect.bottom

            Row {
                id: selectExtremeEvRow
                width: parent.width
                spacing: 0
                anchors.verticalCenter: parent.verticalCenter

                CheckBox {
                    id: selectEventLayersCheck
                    property url wmsEventServiceUrl: "http://floodobservatory.colorado.edu/geoserver/Events_NA/wms?service=wms&request=getCapabilities";

                    property WmsService serviceEv
                    property WmsLayerInfo layerNAEvTiles;
                    property WmsLayer wmsLayerEv;

                    Material.accent: "#00693e"

                    onCheckedChanged: {
                        if (checked == true) {
                            allEventLayersCheck.checked = false;
                            drawPin = true;
                            menu.close();
                            pinMessage.visible = 1;
                        } else {
                            drawPin = false;
                            if (sceneView.scene.operationalLayers.get(0).name === "Nearest Event") {
                                sceneView.scene.operationalLayers.remove(0,1);
                            };
                        }
                    }

                    Component.onCompleted: {
                        checked = false;
                    }
                }

                Text {
                    width: 0.45 * selectExtremeEvRow.width
                    text: qsTr("Select nearest event")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 12 * scaleFactor
                    anchors.verticalCenter: parent.verticalCenter
                    padding: 8
                }
            }
        }

        Text {
            id: customServiceTitle
            text: qsTr("Add Public Service: ")
            color: "black"
            font.pointSize: 12
            anchors.left: parent.left
            anchors.top: selectExtremeEvRect.bottom
            padding: 8
        }

        Rectangle {
            id: textInputRect
            width: 0.98 * parent.width
            height: 35 * scaleFactor
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: customServiceTitle.bottom
            radius: 6 * scaleFactor
            border.color: "darkgrey"

            TextInput {
                id: textInput
                text: qsTr("Enter public service host url...")
                validator: RegExpValidator { regExp: /^(?:http(s)?:\/\/)?[\w.-]+(?:\.[\w\.-]+)+[\w-:/?&=.]+$/ }
                color: "black"
                width: parent.width
                height: 28
                font.pointSize: 10
                anchors.fill: parent
                anchors.margins: 10 * scaleFactor
                selectByMouse: true
                selectedTextColor: "white"
                selectionColor: "#249567"
                clip: true
                wrapMode: TextInput.WrapAnywhere

                onFocusChanged: {
                    if (textInput.text === "Enter public service host url...") {
                        textInput.text = ""
                    }
                }

                onAccepted: {
                    focus = false;
                    if (!/(?=\?.*service=wms?)(?=\?.*request=getCapabilities?).*/.test(textInput.text)) {
                        textInput.text = textInput.text.split("?")[0].concat("?service=wms&request=getCapabilities");
                    }
                }
            }
        }

        TabBar {
            id: tabBar
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: textInputRect.bottom
            width: 0.95 * parent.width
            Material.accent:"#00693e"
            background:  Rectangle {
                color: "#249567"
            }

            TabButton {
                contentItem: Text {
                    text: qsTr("Suggested")
                    color: tabBar.currentIndex == 0 ? "#00693e" : "black"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background:  Rectangle {
                    color: "white"
                }
            }
            TabButton {
                contentItem: Text {
                    text: qsTr("Results")
                    color: tabBar.currentIndex == 1 ? "#00693e" : "black"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background:  Rectangle {
                    color: "white"
                }
            }
        }

        StackLayout {
            id: stackLayout
            width: 0.95 * parent.width
            anchors.top: tabBar.bottom
            height: parent.height - stackLayout.y - (20 * scaleFactor)
            anchors.horizontalCenter: parent.horizontalCenter
            currentIndex: tabBar.currentIndex
            ListView {
                id: suggestedList
                height: parent.height
                clip: true

                model: layerGloSL

                ScrollBar.vertical: ScrollBar {active: true}

                delegate: Rectangle {
                    id: stackListRect
                    width: parent.width
                    height: 40 * scaleFactor
                    color: "transparent"
                    anchors.fill: parent.fill

                    Label{
                        anchors.verticalCenter: parent.verticalCenter
                        padding: 24 * scaleFactor
                        text:title
                    }

                    MouseArea{
                        anchors.fill:parent
                        onClicked: {
                            suggestedList.currentIndex = index;
                            stackListRect.color = index===suggestedList.currentIndex ? "#249567":"transparent";

                            var wmsGlofasLyr = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                                         layerInfos: [layerGloSL[index]]
                                                                                     })

                            sceneView.scene.operationalLayers.append(wmsGlofasLyr);
                        }
                    }
                }
            }

            Item {
                id: resultsTab
            }

            Connections {
                target: layerVisibilityListView
                onHeightChanged: {
                    stackLayout.height = parent.height - stackLayout.y - (20 * scaleFactor)
                }
            }
        }
    }
}
