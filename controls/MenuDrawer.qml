import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.5

Drawer {
    id: menu

    property alias allEventsLyrName: allEventsLyrName
    property alias allEventsLyrCheck: allEventLayersCheck
    property alias nearestEventLyrName: selectEventLyrText
    property alias nearestEventLyrCheck: selectEventLayersCheck
    property alias suggestedLyrsList: suggestedList
    property alias customLyrList: resultsList
    property alias lyrToC: layerVisibilityListView

    width: 0.75 * parent.width
    height: parent.height
    dragMargin: -1

    Flickable {
        id: mainColum
        width: menu.width
        height: menu.height >= 1.25 * menu.width ? menu.height : 1.25 * menu.width
        contentHeight: menu.height >= 1.25 * menu.width ? menu.height : (menuHeader.height + comboBoxBasemap.height + allExtremeEvRect.height +
                                                                         selectExtremeEvRect.height + textInputRect.height + tabBar.height +
                                                                         (0.4 * menu.height) + (4 * basemapTitle.height) + (20 * scaleFactor));
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
            model: ["Imagery","Streets","Terrain","Topographic"]

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
                case "Imagery":
                    sceneView.scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapImageryWithLabels");
                    menu.close();
                    break;
                case "Streets":
                    sceneView.scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapStreets");
                    menu.close();
                    break;
                case "Terrain":
                    sceneView.scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapTerrainWithLabels");
                    menu.close();
                    break;
                case "Topographic":
                    sceneView.scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapTopographic");
                    menu.close();
                    break;
                default:
                    sceneView.scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapImageryWithLabels");
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

        // Create layer table of content (ToC)
        ListView {
            id: layerVisibilityListView
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: layerContentTitle.bottom
            width: 0.95 * parent.width
            height: childrenRect.height < 0.2 * menu.height ? childrenRect.height : 0.2 * menu.height
            clip: true

            verticalLayoutDirection: ListView.BottomToTop

            // Assign the model to the list model of sublayers
            model: sceneView.scene.operationalLayers

            // Assign the delegate to the delegate created above
            delegate: Item {
                id: layerVisibilityDelegate
                width: parent.width
                height: layerRow.height

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
                        height: 35 * scaleFactor

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
                            sceneView.legendListView.model.setProperty(layerVisibilityListView.count - 1 - index, "visible", checked)
                        }

                        Component.onCompleted: {
                            checked = layerVisible;
                        }

                    }

                    Button {
                        id: infoLayer

                        width: 0.10 * layerVisibilityDelegate.width
                        height: 35 * scaleFactor

                        Material.background: "transparent"

                        onClicked: {
                            pageItem.descriptionLyr = description;
                            pageItem.compLyrName = name;
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

            onContentHeightChanged: {
                layerVisibilityListView.positionViewAtEnd();
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

                    onCheckedChanged: mainColum.allEventsChanged();

                    Component.onCompleted: {
                        checked = false;
                    }
                }

                Text {
                    id: allEventsLyrName
                    width: 0.45 * allExtremeEvRow.width
                    text: qsTr("All Events")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14 * scaleFactor
                    anchors.verticalCenter: parent.verticalCenter
                    padding: 8 * scaleFactor
                }

                ComboBox {
                    id: yearFilter
                    currentIndex: -1
                    displayText: currentIndex === -1 ? "Filter" : currentText
                    width: (0.5 * allExtremeEvRow.width) - (allEventLayersCheck.width * 1.5)  // to match radius width
                    height: 40 * scaleFactor
                    Material.accent:"#00693e"
                    background: Rectangle {
                        radius: 6 * scaleFactor
                        border.color: "darkgrey"
                        width: parent.width
                        height: 40 * scaleFactor
                    }

                    font.pixelSize: 14 * scaleFactor
                    model: availableEventYears

                    delegate: ItemDelegate {
                        Material.accent:"#00693e"
                        width: parent.width
                        height: 40 * scaleFactor

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: yearFilter.model[index]
                            font.pixelSize: 14 * scaleFactor
                        }
                    }

                    contentItem: Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: yearFilter.displayText
                        font: yearFilter.font
                    }

                    indicator: Rectangle {
                        visible: false
                    }

                    onCurrentTextChanged: {
                        filterEventsByYear();
                        mainColum.allEventsChanged();
                        mainColum.selectEventsChanged();
                    }

                    function filterEventsByYear() {
                        switch (yearFilter.currentText) {
                        case "All":
                            filteredEventServiceUrl = wmsEventServiceUrl;
                            break;
                        case "2017":
                            filteredEventServiceUrl = wmsEventServiceUrl.toString().replace("/Events_", "/Events_2017_");
                            break;
                        case "2018":
                            filteredEventServiceUrl = wmsEventServiceUrl.toString().replace("/Events_", "/Events_2018_");
                            break;
                        case "2019":
                            filteredEventServiceUrl = wmsEventServiceUrl.toString().replace("/Events_", "/Events_2019_");
                            break;
                        default:
                            filteredEventServiceUrl = wmsEventServiceUrl;
                            break;
                        }
                    }
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

                    property WmsService serviceEv
                    property WmsLayer wmsLayerEv;

                    Material.accent: "#00693e"

                    onCheckedChanged: mainColum.selectEventsChanged();

                    Component.onCompleted: {
                        checked = false;
                    }
                }

                Text {
                    id: selectEventLyrText
                    width: 0.45 * selectExtremeEvRow.width
                    text: qsTr("Nearest Events")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14 * scaleFactor
                    anchors.verticalCenter: parent.verticalCenter
                    padding: 8 * scaleFactor
                }

                Rectangle {
                    id: radiusInputRect
                    width: (0.5 * selectExtremeEvRow.width) - (selectEventLayersCheck.width * 1.5)
                    height: 40 * scaleFactor
                    radius: 6 * scaleFactor
                    border.color: "darkgrey"

                    TextInput {
                        id: radiusInput
                        text: "Radius"

                        validator: DoubleValidator {
                            bottom: 1
                            top: 9999.99
                            decimals: 2
                            notation: DoubleValidator.StandardNotation
                        }

                        inputMethodHints: Qt.ImhFormattedNumbersOnly

                        color: "black"
                        width: parent.width
                        height: 40 * scaleFactor
                        font.pixelSize: 14 * scaleFactor
                        verticalAlignment: TextInput.AlignVCenter
                        horizontalAlignment: TextInput.AlignHCenter
                        anchors.fill: parent
                        anchors.margins: 5 * scaleFactor
                        selectByMouse: true
                        selectedTextColor: "white"
                        selectionColor: "#249567"
                        clip: true
                        wrapMode: TextInput.WrapAnywhere

                        onFocusChanged: {
                            if (radiusInput.text === "Radius") {
                                radiusInput.text = ""
                            }
                        }

                        onAccepted: {
                            radiusSearch = radiusInput.text;
                            if (selectEventLayersCheck.checked === false) {
                                radiusInput.focus = false;
                                selectEventLayersCheck.checked = true;
                            } else {
                                radiusInput.focus = false;
                                pinMessage.label.text = qsTr("Zoom in and tap on a location");
                                menu.close();
                            }
                        }
                    }
                }

                ComboBox {
                    id: radiusSearchUnitsCB
                    width: 30 * scaleFactor
                    height: 40 * scaleFactor

                    model: ["km", "mi"]

                    Material.accent:"#00693e"
                    background: Rectangle {
                        height: 40 * scaleFactor
                    }

                    font.pixelSize: 14 * scaleFactor

                    delegate: ItemDelegate {
                        Material.accent:"#00693e"
                        width: parent.width
                        height: 40 * scaleFactor

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: radiusSearchUnitsCB.model[index]
                            font.pixelSize: 14 * scaleFactor
                        }
                    }

                    contentItem: Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: radiusSearchUnitsCB.displayText
                        font: radiusSearchUnitsCB.font
                    }

                    indicator: Rectangle {
                        visible: false
                    }

                    onCurrentTextChanged: {
                        radiusSearchUnits = radiusSearchUnitsCB.currentText
                    }
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
                anchors.fill: parent
                verticalAlignment: TextInput.AlignVCenter
                anchors.margins: 13 * scaleFactor
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

                    property alias label: suggestedLabel

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
                                if (lyr.name === suggestedLabel.text) {
                                    inContent = 1;
                                    inContentIx = ix;
                                }
                            })

                            if (inContent === 0) {
                                stackListRect.color = "#249567";

                                loadDefaultOrSuggested(name);

                                sceneView.scene.operationalLayers.insert(0, wmsSuggestedLyr);
                                sceneView.scene.operationalLayers.setProperty(sceneView.scene.operationalLayers.indexOf(wmsSuggestedLyr), "name", suggestedLabel.text);
                                sceneView.scene.operationalLayers.setProperty(sceneView.scene.operationalLayers.indexOf(wmsSuggestedLyr), "description", pageItem.descriptionLyr);
                                menu.close();
                            } else if (inContent === 1) {
                                stackListRect.color = "lightgray";
                                sceneView.scene.operationalLayers.remove(inContentIx, 1);
                                legendModel.remove(layerVisibilityListView.count - inContentIx, 1);
                            }
                        }

                        function loadDefaultOrSuggested(rawName) {
                            if (/2-week/.test(suggestedLabel.text)) {
                                wmsSuggestedLyr = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                                            layerInfos: [layer2wk]
                                                                                        });
                                legendModel.append({name: "Two Week Flooded Area", symbolUrl: "../assets/legend_icons/2wk_blue.png", visible: true});
                                pageItem.descriptionLyr = layer2wk.description;
                                suggestedListM.remove(index, 1);
                            } else if (/Current daily/.test(suggestedLabel.text)) {
                                wmsSuggestedLyr = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                                            layerInfos: [layer3day]
                                                                                        });
                                legendModel.append({name: "Current Daily Flooded Area / Clouds", symbolUrl: "../assets/legend_icons/3day_red.png", visible: true});
                                pageItem.descriptionLyr = layer3day.description;
                                suggestedListM.remove(index, 1);
                            } else if (/January till/.test(suggestedLabel.text)) {
                                wmsSuggestedLyr = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                                            layerInfos: [layerJan]
                                                                                        });
                                legendModel.append({name: "January till Current Flooded Area", symbolUrl: "../assets/legend_icons/jant_cyan.png", visible: true});
                                pageItem.descriptionLyr = layerJan.description;
                                suggestedListM.remove(index, 1);
                            } else if (/Regular water/.test(suggestedLabel.text)) {
                                wmsSuggestedLyr = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                                            layerInfos: [layerRegW]
                                                                                        });
                                legendModel.append({name: "Regular Water Extent", symbolUrl: "../assets/legend_icons/regW_white.png", visible: true});
                                pageItem.descriptionLyr = layerRegW.description;
                                suggestedListM.remove(index, 1)
                            } else if (/Historical flood extent /.test(suggestedLabel.text)) {
                                wmsSuggestedLyr = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                                            layerInfos: [layerHistW]
                                                                                        });
                                legendModel.append({name: "Historical Water Extent", symbolUrl: "../assets/legend_icons/histW_gray.png", visible: true});
                                pageItem.descriptionLyr = layerHistW.description;
                                suggestedListM.remove(index, 1)
                            } else if (/Annual Flood Frequency/.test(suggestedLabel.text)) {
                                var layerInfos = serviceFF.serviceInfo.layerInfos;
                                var regIx = popUp.listViewCurrentIndex + 1;
                                subLayerFFSL = layerInfos[0].sublayerInfos[regIx];
                                wmsSuggestedLyr = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                                            layerInfos: [subLayerFFSL]
                                                                                        });
                                legendModel.append({name: "Annual Flood Frequency", symbolUrl: "http://floodobservatory.colorado.edu/geoserver/wms?REQUEST=GetLegendGraphic&VERSION=1.0.0&FORMAT=image/png&LAYER=MOD_an_frequency_af:Annualfrequency_water_af&TRANSPARENT=true&legend_options=fontColor:ffffff", visible: true});
                                pageItem.descriptionLyr = subLayerFFSL.description;
                            } else if (/World population/.test(suggestedLabel.text)) {
                                layerInfos = servicePop.serviceInfo.layerInfos;
                                subLayerWPSL = layerInfos[0].sublayerInfos[0];
                                wmsSuggestedLyr = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                                            layerInfos: [subLayerWPSL]
                                                                                        });
                                legendModel.append({name: "World Population", symbolUrl: "http://floodobservatory.colorado.edu/geoserver/wms?REQUEST=GetLegendGraphic&VERSION=1.0.0&FORMAT=image/png&LAYER=AF_population:ago_ppp_2015&height=8&WIDTH=10&TRANSPARENT=true&legend_options=fontSize:8;fontColor:ffffff", visible: true});
                                pageItem.descriptionLyr = subLayerWPSL.description;
                            } else if (/River Discharge Stations/.test(suggestedLabel.text)) {
                                layerInfos = serviceStations.serviceInfo.layerInfos;
                                subLayerStationsSL = layerInfos[0].sublayerInfos[0];
                                wmsSuggestedLyr = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                                            layerInfos: [subLayerStationsSL]
                                                                                        });
                                legendModel.append({name: "Discharge Stations", symbolUrl: "http://floodobservatory.colorado.edu/geoserver/wms?REQUEST=GetLegendGraphic&VERSION=1.0.0&FORMAT=image/png&LAYER=RiverWatch:rw_gauginglocations_af&TRANSPARENT=true&legend_options=fontColor:ffffff", visible: true});
                                pageItem.descriptionLyr = subLayerStationsSL.description;
                            } else {
                                layerInfos = serviceGlo.serviceInfo.layerInfos;
                                subLayerGloSL = layerInfos[0].sublayerInfos[2].sublayerInfos[index];
                                wmsSuggestedLyr = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                                            layerInfos: [subLayerGloSL]
                                                                                        });
                                legendModel.append({name: "ECMWF " + suggestedLabel.text, symbolUrl: "http://globalfloods-ows.ecmwf.int/glofas-ows/ows.py?version=1.3.0&service=WMS&request=GetLegendGraphic&sld_version=1.1.0&layer=" + rawName + "&format=image/png", visible: true});
                                pageItem.descriptionLyr = subLayerGloSL.description;

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

                    property alias label: resultsLabel

                    width: parent.width
                    height: resultsLabel.height < 40 * scaleFactor ? 40 * scaleFactor : resultsLabel.height
                    color: "lightgray"
                    anchors.fill: parent.fill

                    Label {
                        id: resultsLabel
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        padding: 12 * scaleFactor
                        text: title.replace(/\_/g, " ")
                        font.pixelSize: 14 * scaleFactor
                    }

                    MouseArea {
                        anchors.fill:parent
                        onClicked: {
                            var wmsCustomLyr = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                                         layerInfos: [layerCuSL[index]]
                                                                                     });

                            var inContent = 0;
                            var inContentIx = -1;

                            sceneView.scene.operationalLayers.forEach(function (lyr, ix) {
                                if (lyr.name === layerCuSL[index].title.replace(/\_/g, " ")) {
                                    inContent = 1;
                                    inContentIx = ix;
                                }
                            })

                            if (inContent === 0) {
                                stackCuListRect.color = "#249567";
                                sceneView.scene.operationalLayers.insert(0, wmsCustomLyr);
                                sceneView.scene.operationalLayers.setProperty(sceneView.scene.operationalLayers.indexOf(wmsCustomLyr), "name", layerCuSL[index].title.replace(/\_/g, " "));
                                sceneView.scene.operationalLayers.setProperty(sceneView.scene.operationalLayers.indexOf(wmsCustomLyr), "description", layerCuSL[index].description);

                                var legendParams;
                                if (textInput.text.includes("arcgis")) {
                                    legendParams = "?REQUEST=GetLegendGraphic&VERSION=1.0.0&FORMAT=image/png&LAYER=" + index + "&TRANSPARENT=true";
                                } else if (textInput.text.includes("geoserver")) {
                                    legendParams = "?REQUEST=GetLegendGraphic&VERSION=1.0.0&FORMAT=image/png&LAYER=" + layerCuSL[index].name + "&TRANSPARENT=true&legend_options=fontColor:ffffff";
                                } else {
                                    legendParams = "?REQUEST=GetLegendGraphic&VERSION=1.0.0&FORMAT=image/png&LAYER=" + layerCuSL[index].name;
                                }

                                legendModel.append({name: layerCuSL[index].title.replace(/\_/g, " "), symbolUrl: textInput.text.split("?")[0] + legendParams, visible: true});
                                menu.close();
                            } else if (inContent === 1) {
                                stackCuListRect.color = "lightgray";
                                sceneView.scene.operationalLayers.remove(inContentIx, 1);
                                legendModel.remove(layerVisibilityListView.count - inContentIx, 1);
                            }
                        }
                    }
                }
            }

            Connections {
                target: layerVisibilityListView
                onHeightChanged: {
                    if (menu.height > menu.width * 1.25) {
                        stackLayout.height = menu.height - stackLayout.y - (20 * scaleFactor);
                    } else {
                        stackLayout.height = 0.2 * menu.height;
                    }
                }
            }
        }

        function selectEventsChanged() {
            if (selectEventLayersCheck.checked == true) {
                allEventLayersCheck.checked = false;

                sceneView.scene.operationalLayers.forEach(function (lyr, ix) {
                    if (lyr.name === "Nearest Events") {
                        sceneView.scene.operationalLayers.remove(ix, 1);
                    }
                });

                drawPin = true;
                if (radiusInput.text == "Radius" || radiusInput.text == "") {
                    radiusSearch = 100;
                    radiusSearchUnits = "km";
                } else {
                    radiusSearch = radiusInput.text;
                }

                menu.close();
                pinMessage.label.text = qsTr("Zoom in and tap on a location");
                pinMessage.visible = 1;
            } else {
                drawPin = false;
                sceneView.scene.operationalLayers.forEach(function (lyr, ix) {
                    if (lyr.name === "Nearest Events") {
                        sceneView.scene.operationalLayers.remove(ix, 1);
                    }
                });

                for (var i=0; i<legendModel.count; i++) {
                    if (legendModel.get(i).name === "Nearest Extreme Event") {
                        legendModel.remove(i, 1);
                    }
                }
            }
        }

        function allEventsChanged() {
            if (allEventLayersCheck.checked == true) {
                pinMessage.visible = 0;
                menu.close();
                selectEventLayersCheck.checked = false;

                sceneView.scene.operationalLayers.forEach(function (lyr, ix) {
                    if (lyr.name === "All Events") {
                        sceneView.scene.operationalLayers.remove(ix, 1);
                    }
                });

                serviceEv = ArcGISRuntimeEnvironment.createObject("WmsService", { url: filteredEventServiceUrl });

                serviceEv.loadStatusChanged.connect(function() {
                    if (serviceEv.loadStatus === Enums.LoadStatusLoaded) {
                        // get the layer info list
                        var serviceEvInfo = serviceEv.serviceInfo;
                        var layerInfos = serviceEvInfo.layerInfos;

                        layerNAEv = layerInfos[0].sublayerInfos

                        wmsLayerEv = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                               layerInfos: layerNAEv,
                                                                               visible: true
                                                                           });

                        sceneView.scene.operationalLayers.append(wmsLayerEv);
                        sceneView.scene.operationalLayers.setProperty(sceneView.scene.operationalLayers.indexOf(wmsLayerEv), "name", "All Events");
                        sceneView.scene.operationalLayers.setProperty(sceneView.scene.operationalLayers.indexOf(wmsLayerEv), "description", layerNAEv.description);
                    }
                });

                serviceEv.load();
                legendModel.insert(0, {name: "All Extreme Events", symbolUrl: "../assets/legend_icons/x_events_red.png", visible: true});
            } else {
                sceneView.scene.operationalLayers.forEach(function (lyr, ix) {
                    if (lyr.name === "All Events") {
                        sceneView.scene.operationalLayers.remove(ix, 1);
                    }
                });
                for (var i=0; i<legendModel.count; i++) {
                    if (legendModel.get(i).name === "All Extreme Events") {
                        legendModel.remove(i, 1);
                    }
                }
            }
        }
    }

    onHeightChanged: {
        if (menu.height <= menu.width * 1.25) {
            mainColum.contentHeight = (menuHeader.height + comboBoxBasemap.height + allExtremeEvRect.height +
                                       selectExtremeEvRect.height + textInputRect.height + tabBar.height +
                                       (0.4 * menu.height) + (4 * basemapTitle.height) + (20 * scaleFactor));
        }
    }
}
