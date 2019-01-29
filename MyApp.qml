/* Copyright 2017 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */
import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.4

import "controls" as Controls

App{
    id: app
    width: 414
    height: 736
    function units(value) {
        return AppFramework.displayScaleFactor * value
    }
    property real scaleFactor: AppFramework.displayScaleFactor
    property int  baseFontSize : app.info.propertyValue("baseFontSize", 15 * scaleFactor) + (isSmallScreen ? 0 : 3)
    property bool isSmallScreen: (width || height) < units(400)

    property url  qmlfile
    property string viewName
    property string descriptionText

    property url wmsServiceUrl

    Page {
        anchors.fill: parent

        header: ToolBar {
            id: header
            width: parent.width
            height: 50 * scaleFactor
            Material.background: "#00693e"
            Controls.HeaderBar{}

            ToolButton {
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: 8
                }

                indicator: Image {
                    source: "assets/menu.png"
                    anchors.fill: parent
                }

                onClicked: menu.open()
            }
        }

        // Add a Loader to load different views.
        contentItem: Rectangle {
            id: loader
            anchors.top:header.bottom
            Loader{
                height: app.height - header.height
                width: app.width
                source: qmlfile
            }
        }

        Drawer {
            id: menu
            width: 0.75 * parent.width
            height: parent.height

            Column {
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
                    padding: 8
                }

                ComboBox {
                    id: comboBoxBasemap
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 0.98 * parent.width
                    height: 30 * scaleFactor
                    Material.accent:"#00693e"
                    background: Rectangle {
                        radius: 6 * scaleFactor
                        border.color: "darkgrey"
                        width: parent.width
                        height: 30 * scaleFactor
                    }

                    model: ["Topographic","Streets","Imagery","Oceans"]
                    onCurrentTextChanged: {
                        if (scene.loadStatus === Enums.LoadStatusLoaded)
                            changeBasemap();
                    }

                    function changeBasemap() {
                        switch (comboBoxBasemap.currentText) {
                        case "Topographic":
                            scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapTopographic");
                            break;
                        case "Streets":
                            scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapStreets");
                            break;
                        case "Imagery":
                            scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapImagery");
                            break;
                        case "Oceans":
                            scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapOceans");
                            break;
                        default:
                            scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapTopographic");
                            break;
                        }
                    }
                }
            }
        }
    }

    Controls.FloatActionButton {
        id:switchBtn
    }

    Controls.PopUpPage {
        id:popUp
        visible:false
    }

    Controls.DescriptionPage {
        id:descPage
        visible: false
    }
}






