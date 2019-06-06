import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.5

import "controls" as Controls

App {
    id: app
    width: 414
    height: 736
    function units(value) {
        return AppFramework.displayScaleFactor * value
    }
    property real scaleFactor: AppFramework.displayScaleFactor
    property int  baseFontSize : app.info.propertyValue("baseFontSize", 15 * scaleFactor) + (isSmallScreen ? 0 : 3)
    property bool isSmallScreen: (width || height) < units(400)

    property bool initLoad: true;
    property url qmlfile: "./views/StartPage.qml";
    property string viewName;
    property string descriptionText;
    property ListView layerVisibilityListView;

    property url wmsGlofasServiceUrl: "http://globalfloods-ows.ecmwf.int/glofas-ows/ows.py?service=wms&request=getCapabilities";

    property WmsService serviceGlo;
    property WmsLayerInfo subLayerGloSL;
    property WmsLayerInfo layer2wk;
    property WmsLayerInfo layer3day;
    property WmsLayerInfo layerJan;
    property WmsLayerInfo layerRegW;

    property WmsLayer wmsSuggestedLyr;
    property ListModel suggestedListM;

    Page {
        anchors.fill: parent

        // Add a Loader to load different views.
        contentItem: Rectangle {
            id: loader
            anchors.top:parent.top
            Loader {
                height: app.height
                width: app.width
                source: qmlfile
            }
        }
    }

    Controls.PopUpPage {
        id:popUp
        visible: false
    }

    Controls.DescriptionPage {
        id:descPage
        visible: false
    }

    Controls.PinMessage {
        id:pinMessage
        visible: false
    }
}






