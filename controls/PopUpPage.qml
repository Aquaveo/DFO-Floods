import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0

Rectangle {
    id:popUp
    anchors.fill: parent
    color: "#80000000"

    MouseArea {
        anchors.fill: parent
        onClicked: {
            mouse.accepted = false
        }
    }

    Rectangle {
        id:popUpWindow
        height: 270 * scaleFactor
        width: 280 * scaleFactor
        anchors.centerIn: parent
        radius: 3 * scaleFactor
        Material.background:  "#FAFAFA"
        Material.elevation:24

        Text {
            id: titleText
            text: qsTr("Choose a Layer Group")
            font{
                pixelSize:app.baseFontSize
                bold:true
            }
            padding: 24 * scaleFactor
            anchors.top:parent.top
            anchors.bottom:popUpListView.top
        }

        ListView{
            id:popUpListView
            anchors.topMargin: 64 * scaleFactor
            anchors.fill: parent
            model:ListModel {
                id:viewItems

                ListElement { name:"Change Basemap"; url:"../views/ChangeBasemap.qml";description:"<p> This sample shows how to switch between different basemaps in the map. When a new item is selected from the combo box, a JavaScript function that determines the currently selected basemap is executed. The map's basemap is replaced by simply calling the writable basemap property, passing in the desired basemap. If there were operational layers present in the map, this would have no effect on them.   <br><p></p><a href='http://geonet.esri.com/groups/appstudio/blog/2016/12/06/how-to-describe-our-resources-in-terms-of-difficulty-complexity-and-time-to-digest'><span style=' text-decoration: underline; color:#0000ff;'>Resource Level:</span></a>🍌 </p>" }

                ListElement { name:"Display a Map"; url:"../views/DisplayaMap.qml";description:"<p>This is the most basic sample for displaying a map. It can be considered the Hello World map app for the ArcGIS Runtime SDK for Qt. It shows how to create a map view, and add in a map that contains the imagery with labels basemap. By default, this map supports basic zooming and panning operations. \  <br><p></p><a href='http://geonet.esri.com/groups/appstudio/blog/2016/12/06/how-to-describe-our-resources-in-terms-of-difficulty-complexity-and-time-to-digest'><span style=' text-decoration: underline; color:#0000ff;'>Resource Level:</span></a>🍌 </p>" }

                ListElement { name:"Map Loaded"; url:"../views/MapLoaded.qml"; description:"<p>The load status is obtained from the loadStatus property. The map is considered loaded when any of the following are true: the map has a valid spatial reference, the map has an initial viewpoint, or one of the map's predefined layers has been created. A signal handler is set up on the map to handle the loadStatusChanged signal by updating the text at the bottom of the display with the new load status. <br><p></p><a href='http://geonet.esri.com/groups/appstudio/blog/2016/12/06/how-to-describe-our-resources-in-terms-of-difficulty-complexity-and-time-to-digest'><span style=' text-decoration: underline; color:#0000ff;'>Resource Level:</span></a>🍌 </p>"  }

                ListElement { name:"Set Map Spatial Ref"; url:"../views/SetMapSpatialReference.qml";description:"<p>This sample demonstrates how to set the initial spatial reference of a map so that all layers that support reprojection are projected into the map’s spatial reference.  <br><p></p><a href='http://geonet.esri.com/groups/appstudio/blog/2016/12/06/how-to-describe-our-resources-in-terms-of-difficulty-complexity-and-time-to-digest'><span style=' text-decoration: underline; color:#0000ff;'>Resource Level:</span></a>🍌 </p>" }
            }

            onCurrentIndexChanged: {
                qmlfile = viewItems.get(currentIndex).url
                viewName = viewItems.get(currentIndex).name
                descriptionText =viewItems.get(currentIndex).description
            }
            delegate: Rectangle{
                width:280 * scaleFactor
                height: 40 * scaleFactor
                color: index===popUpListView.currentIndex? "#249567":"transparent"

                Label{
                    anchors.verticalCenter: parent.verticalCenter
                    padding: 24 * scaleFactor
                    font {
                        pixelSize: app.baseFontSize * 0.8
                    }
                    text:name
                }

                MouseArea{
                    anchors.fill:parent
                    onClicked: {
                        popUp.visible = 0
                        popUpListView.currentIndex = index
                        qmlfile = viewItems.get(index).url
                        viewName = viewItems.get(index).name
                        descriptionText =viewItems.get(index).description
                    }
                }
            }

            Text{
                id:cancelText
                anchors.bottom: parent.bottom
                anchors.right:parent.right
                anchors.bottomMargin: 13 * scaleFactor
                anchors.rightMargin: 16 * scaleFactor
                text:qsTr("CANCEL")
                color:"#00693e"
                font{
                    pixelSize: baseFontSize * 0.9
                    bold:true
                }

                MouseArea{
                    anchors.fill: parent
                    onClicked :{
                        popUp.visible = 0
                    }
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
        radius: 8.0
        samples: 17
        color: "#80000000"
        smooth: true
    }
}




