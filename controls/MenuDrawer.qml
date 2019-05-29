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
    dragMargin: -1

    Flickable {
        id: mainColum
        width: parent.width
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
                font.pixelSize: app.baseFontSize * 1.1
                font.bold: true
                anchors.centerIn: parent
            }
        }

        Text {
            id: basemapTitle
            text: qsTr("Basemap: ")
            color: "black"
            font.pixelSize: 14 * scaleFactor
            font.bold: true
            anchors.left: parent.left
            anchors.top: menuHeader.bottom
            padding: 8 * scaleFactor
        }

        ComboBox {
            id: comboBoxBasemap
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: basemapTitle.bottom
            width: 0.98 * parent.width
            height: 40 * scaleFactor
            Material.accent:"#00693e"
            background: Rectangle {
                radius: 6 * scaleFactor
                border.color: "darkgrey"
                width: parent.width
                height: 40 * scaleFactor
            }

            font.pixelSize: 14 * scaleFactor
            model: ["Topographic","Streets","Imagery","Terrain"]

            delegate: ItemDelegate {
                Material.accent:"#00693e"
                width: parent.width
                text: comboBoxBasemap.model[index]
                font.pixelSize: 14 * scaleFactor
                topPadding: 13 * scaleFactor
                bottomPadding: 13 * scaleFactor
            }

            indicator: Image {
                width: 40 * scaleFactor
                height: 40 * scaleFactor
                source: "../assets/dropdown_arrow.png"
                anchors.right: parent.right
            }

            onCurrentTextChanged: {
                if (sceneView.scene !== null && sceneView.scene.loadStatus === Enums.LoadStatusLoaded) {
                    changeBasemap();
                }
            }

            function changeBasemap() {
                switch (comboBoxBasemap.currentText) {
                case "Topographic":
                    sceneView.scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapTopographic");
                    menu.close();
                    break;
                case "Streets":
                    sceneView.scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapStreets");
                    menu.close();
                    break;
                case "Imagery":
                    sceneView.scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapImageryWithLabels");
                    menu.close();
                    break;
                case "Terrain":
                    sceneView.scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapTerrainWithLabels");
                    menu.close();
                    break;
                default:
                    sceneView.scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapTopographic");
                    menu.close();
                    break;
                }
            }
        }

        Text {
            id: layerContentTitle
            text: qsTr("Layers List: ")
            color: "black"
            font.pixelSize: 14 * scaleFactor
            font.bold: true
            anchors.left: parent.left
            anchors.top: comboBoxBasemap.bottom
            padding: 8 * scaleFactor
        }

        // Create a list view to display the layer items
        ListView {
            id: layerVisibilityListView
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: layerContentTitle.bottom
            width: 0.95 * parent.width
            height: childrenRect.height <= 0.25 * menu.height ? childrenRect.height : 0.25 * menu.height
            clip: true

            // Assign the model to the list model of sublayers
            model: layerList

            // Assign the delegate to the delegate created above
            delegate: Item {
                id: layerVisibilityDelegate
                width: parent.width
                height: layerRow.height < 35 * scaleFactor ? 35 * scaleFactor : layerRow.height

                Row {
                    id: layerRow
                    spacing: 0
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 0.65 * layerVisibilityDelegate.width
                        text: name
                        wrapMode: Text.WordWrap
                        font.pixelSize: 14 * scaleFactor
                    }

                    Switch {
                        id: layerSwitch
                        width: 0.25 * layerVisibilityDelegate.width
                        height: layerVisibilityDelegate.height

                        indicator {
                            width: 35 * scaleFactor
                            height: 35 * scaleFactor
                        }

                        Binding {
                            target: (layerSwitch.indicator ? layerSwitch.indicator.children[0] : null)
                            property: 'height'
                            value: 14 * scaleFactor
                        }

                        Binding {
                            target: (layerSwitch.indicator ? layerSwitch.indicator.children[1] : null)
                            property: 'width'
                            value: 20 * scaleFactor
                        }

                        Binding {
                            target: (layerSwitch.indicator ? layerSwitch.indicator.children[1] : null)
                            property: 'height'
                            value: 20 * scaleFactor
                        }

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

                        width: 0.10 * layerVisibilityDelegate.width
                        height: layerVisibilityDelegate.height

                        Material.background: "transparent"

                        onClicked: {
                            pageItem.descriptionLyr = description;
                            layerVisibilityListView.currentIndex = index;
                            menu.close();
                            descLyrPage.visible = 1;
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
            font.pixelSize: 14 * scaleFactor
            font.bold: true
            anchors.left: parent.left
            anchors.top: layerVisibilityListView.bottom
            padding: 8 * scaleFactor
        }

        Rectangle {
            id: allExtremeEvRect
            width: 0.95 * parent.width
            height: 40 * scaleFactor
            anchors.left: parent.left
            anchors.top: eventLayersTitle.bottom
            anchors.leftMargin: 8 * scaleFactor

            Row {
                id: allExtremeEvRow
                width: parent.width
                spacing: 0
                anchors.verticalCenter: parent.verticalCenter

                CheckBox {
                    id: allEventLayersCheck
                    width: allExtremeEvRect.height
                    height: allExtremeEvRect.height
                    Material.accent: "#00693e"

                    indicator: Rectangle {
                        width: 30 * scaleFactor
                        height: 30 * scaleFactor
                        radius: 2 * scaleFactor
                        anchors.leftMargin: 8 * scaleFactor
                        anchors.verticalCenter: parent.verticalCenter
                        border {
                            color: "darkgrey"
                            width: 2 * scaleFactor
                        }

                        Rectangle {
                            width: parent.width
                            height: parent.height
                            radius: 2 * scaleFactor
                            color: "#00693e"
                            visible: allEventLayersCheck.checked

                            Image {
                                width: parent.width * 0.8
                                height: parent.height * 0.8
                                anchors.centerIn: parent
                                source: "../assets/checkmark.png"
                            }
                        }
                    }

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
                            sceneView.scene.operationalLayers.forEach(function (lyr, ix) {
                                if (lyr.name === "All Events") {
                                    sceneView.scene.operationalLayers.remove(ix, 1);
                                }
                            })
                        }
                    }

                    Component.onCompleted: {
                        checked = false;
                    }
                }

                Text {
                    width: 0.45 * allExtremeEvRow.width
                    text: qsTr("All Events")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14 * scaleFactor
                    anchors.verticalCenter: parent.verticalCenter
                    padding: 8 * scaleFactor
                }
            }
        }

        Rectangle {
            id: selectExtremeEvRect
            width: 0.95 * parent.width
            height: 40 * scaleFactor
            anchors.left: parent.left
            anchors.top: allExtremeEvRect.bottom
            anchors.leftMargin: 8 * scaleFactor

            Row {
                id: selectExtremeEvRow
                width: parent.width
                spacing: 0
                anchors.verticalCenter: parent.verticalCenter

                CheckBox {
                    id: selectEventLayersCheck
                    width: selectExtremeEvRect.height
                    height: selectExtremeEvRect.height

                    indicator: Rectangle {
                        width: 30 * scaleFactor
                        height: 30 * scaleFactor
                        radius: 2 * scaleFactor
                        anchors.leftMargin: 8 * scaleFactor
                        anchors.verticalCenter: parent.verticalCenter
                        border {
                            color: "darkgrey"
                            width: 2 * scaleFactor
                        }

                        Rectangle {
                            width: parent.width
                            height: parent.height
                            radius: 2 * scaleFactor
                            color: "#00693e"
                            visible: selectEventLayersCheck.checked

                            Image {
                                width: parent.width * 0.8
                                height: parent.height * 0.8
                                anchors.centerIn: parent
                                source: "../assets/checkmark.png"
                            }
                        }
                    }

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
                            sceneView.scene.operationalLayers.forEach(function (lyr, ix) {
                                if (lyr.name === "Nearest Events") {
                                    sceneView.scene.operationalLayers.remove(ix, 1);
                                }
                            })
                        }
                    }

                    Component.onCompleted: {
                        checked = false;
                    }
                }

                Text {
                    width: 0.45 * selectExtremeEvRow.width
                    text: qsTr("Nearest Events")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14 * scaleFactor
                    anchors.verticalCenter: parent.verticalCenter
                    padding: 8 * scaleFactor
                }
            }
        }

        Text {
            id: customServiceTitle
            text: qsTr("Add Public Service: ")
            color: "black"
            font.pixelSize: 14 * scaleFactor
            font.bold: true
            anchors.left: parent.left
            anchors.top: selectExtremeEvRect.bottom
            padding: 8 * scaleFactor
        }

        Rectangle {
            id: textInputRect
            width: 0.98 * parent.width
            height: 40 * scaleFactor
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: customServiceTitle.bottom
            radius: 6 * scaleFactor
            border.color: "darkgrey"

            TextInput {
                id: textInput
                text: qsTr("Enter public service host url...")
                validator: RegExpValidator { regExp: /^(?:[H|h]ttp(s)?\:\/\/)?[\w.-]+(?:\.[\w\.-]+)+[\w-:/?&=.]+$/ }
                color: "black"
                width: parent.width
                height: 40 * scaleFactor
                font.pixelSize: 14 * scaleFactor
                font.capitalization: Font.AllLowercase
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
                    var searchPattern = new RegExp('^(?:[H|h]ttp(s)?\:\/\/){1}')
                    if (!searchPattern.test(textInput.text)) {
                        textInput.text = "http://" + textInput.text;
                    }

                    if (!/(?=\?.*service=wms?)(?=\?.*request=getCapabilities?).*/.test(textInput.text)) {
                        textInput.text = textInput.text.split("?")[0].concat("?service=wms&request=getCapabilities");
                    }

                    serviceCu = ArcGISRuntimeEnvironment.createObject("WmsService", { url: textInput.text });

                    serviceCu.loadStatusChanged.connect(function() {
                        if (serviceCu.loadStatus === Enums.LoadStatusLoaded) {
                            var serviceCuInfo = serviceCu.serviceInfo;
                            var layerInfos = serviceCuInfo.layerInfos;

                            // get the all layers
                            layerCuSL = layerInfos[0].sublayerInfos;
                        }
                    });

                    serviceCu.load();
                    tabBar.currentIndex = 1;
                }
            }
        }

        TabBar {
            id: tabBar
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: textInputRect.bottom
            width: 0.95 * parent.width
            height: 40 * scaleFactor
            Material.accent:"#00693e"
            background:  Rectangle {
                color: "#249567"
            }

            TabButton {
                contentItem: Text {
                    text: qsTr("Suggested")
                    font.pixelSize: 14 * scaleFactor
                    color: tabBar.currentIndex == 0 ? "#00693e" : "black"
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
                    text: qsTr("Results")
                    font.pixelSize: 14 * scaleFactor
                    color: tabBar.currentIndex == 1 ? "#00693e" : "black"
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
            id: stackLayout
            width: 0.95 * parent.width
            anchors.top: tabBar.bottom
            height: menu.height > menu.width * 1.25 ? menu.height - stackLayout.y - (20 * scaleFactor) : 0.25 * menu.width
            anchors.horizontalCenter: parent.horizontalCenter
            currentIndex: tabBar.currentIndex
            ListView {
                id: suggestedList
                height: parent.height
                clip: true

                model: suggestedListM

                ScrollBar.vertical: ScrollBar {
                    active: true
                    width: 20 * scaleFactor
                }

                delegate: Rectangle {
                    id: stackListRect
                    width: parent.width
                    height: suggestedLabel.height < 40 * scaleFactor ? 40 * scaleFactor : suggestedLabel.height
                    color: "lightgray"
                    anchors.fill: parent.fill

                    Label {
                        id: suggestedLabel
                        width: parent.width
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        padding: 12 * scaleFactor
                        text: title ? title : name
                        wrapMode: Label.WordWrap
                        font.pixelSize: 14 * scaleFactor
                    }

                    MouseArea {
                        anchors.fill:parent
                        onClicked: {
                            var inContent = 0;
                            var inContentIx = -1;

                            sceneView.scene.operationalLayers.forEach(function (lyr, ix) {
                                if (lyr.name === (title ? title : name)) {
                                    inContent = 1;
                                    inContentIx = ix;
                                }
                            })

                            if (inContent === 0) {
                                stackListRect.color = "#249567";

                                if (title) {
                                    wmsSuggestedLyr = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                                                layerInfos: [layerGloSL[index]]
                                                                                            });
                                } else if (/2-week/.test(name)) {
                                    wmsSuggestedLyr = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                                                layerInfos: [layer2wk]
                                                                                            });
                                    suggestedListM.remove(index, 1);
                                } else if (/Current daily/.test(name)) {
                                    wmsSuggestedLyr = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                                                layerInfos: [layer3day]
                                                                                            });
                                    suggestedListM.remove(index, 1);
                                } else if (/January till/.test(name)) {
                                    wmsSuggestedLyr = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                                                layerInfos: [layerJan]
                                                                                            });
                                    suggestedListM.remove(index, 1);
                                } else if (/Regular water/.test(name)) {
                                    wmsSuggestedLyr = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                                                layerInfos: [layerRegW]
                                                                                            });
                                    suggestedListM.remove(index, 1)
                                }

                                sceneView.scene.operationalLayers.insert(sceneView.scene.operationalLayers.count, wmsSuggestedLyr);
                                sceneView.scene.operationalLayers.setProperty(sceneView.scene.operationalLayers.count-1, "name", title);
                                sceneView.scene.operationalLayers.setProperty(sceneView.scene.operationalLayers.count-1, "description", description);
                                menu.close();
                            } else if (inContent === 1) {
                                stackListRect.color = "lightgray";
                                sceneView.scene.operationalLayers.remove(inContentIx, 1);
                            }
                        }
                    }
                }
            }

            ListView {
                id: resultsList
                height: parent.height
                clip: true

                model: layerCuSL

                ScrollBar.vertical: ScrollBar {active: true}

                delegate: Rectangle {
                    id: stackCuListRect
                    width: parent.width
                    height: 40 * scaleFactor
                    color: "lightgray"
                    anchors.fill: parent.fill

                    Label {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        padding: 24 * scaleFactor
                        text:title
                        font.pixelSize: 14 * scaleFactor
                    }

                    MouseArea {
                        anchors.fill:parent
                        onClicked: {
                            var wmsCustomLyr = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                                         layerInfos: [layerCuSL[index]]
                                                                                     })

                            var inContent = 0;
                            var inContentIx = -1;

                            sceneView.scene.operationalLayers.forEach(function (lyr, ix) {
                                if (lyr.name === layerCuSL[index].title) {
                                    inContent = 1;
                                    inContentIx = ix;
                                }
                            })

                            if (inContent === 0) {
                                stackCuListRect.color = "#249567";
                                sceneView.scene.operationalLayers.insert(sceneView.scene.operationalLayers.count, wmsCustomLyr);
                                sceneView.scene.operationalLayers.setProperty(sceneView.scene.operationalLayers.count-1, "name", layerCuSL[index].title);
                                sceneView.scene.operationalLayers.setProperty(sceneView.scene.operationalLayers.count-1, "description", layerCuSL[index].description);
                                menu.close();
                            } else if (inContent === 1) {
                                stackCuListRect.color = "lightgray";
                                sceneView.scene.operationalLayers.remove(inContentIx, 1);
                            }
                        }
                    }
                }
            }

            Connections {
                target: layerVisibilityListView
                onHeightChanged: {
                    if (menu.height > menu.width * 1.25) {
                        stackLayout.height = parent.height - stackLayout.y - (20 * scaleFactor);
                    } else {
                        stackLayout.height = 0.25 * menu.width;
                    }
                }
            }
        }
    }

    onHeightChanged: {
        if (menu.height <= menu.width * 1.25) {
            mainColum.contentHeight = (menuHeader.height + comboBoxBasemap.height + layerVisibilityListView.height +
                    allExtremeEvRect.height + selectExtremeEvRect.height + textInputRect.height + tabBar.height +
                    stackLayout.height + (160 * scaleFactor));
        } else {
            mainColum.contentHeight = menu.height;
        }
    }
}
