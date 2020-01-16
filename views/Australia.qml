import QtQuick 2.7
import QtQuick.Controls 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.5

import "../controls" as Controls

Page {
    id: pageItem
    property Point currentPositionPoint: Point {x: 132.195485; y: -25.526449; spatialReference: SpatialReference.createWgs84()}

    property real scaleFactor: AppFramework.displayScaleFactor
    property url wms3dayServiceUrl: "http://floodobservatory.colorado.edu/geoserver/AU_3day_rs/wms?service=wms&request=getCapabilities";
    property url wms2wkServiceUrl: "http://floodobservatory.colorado.edu/geoserver/AU_2wk_rs/wms?service=wms&request=getCapabilities";
    property url wmsJanServiceUrl: "http://floodobservatory.colorado.edu/geoserver/DFO_rs_Jan_till_current_AU/wms?service=wms&request=getCapabilities";
    property url wmsRegWServiceUrl: "http://floodobservatory.colorado.edu/geoserver/Permanent_water_2013-2016-au/wms?service=wms&request=getCapabilities";
    property url wmsHistWServiceUrl: "http://floodobservatory.colorado.edu/geoserver/MOD_history_AU/wms?service=wms&request=getCapabilities";
    property url wmsEventServiceUrl: "http://floodobservatory.colorado.edu/geoserver/Events_AU/wms?service=wms&request=getCapabilities";
    property url wmsWorldPopServiceUrl: "http://floodobservatory.colorado.edu/geoserver/AU_population/wms?service=wms&request=getCapabilities";
    property url filteredEventServiceUrl: wmsEventServiceUrl;
    property var availableEventYears: ["All","2017","2018"];

    property ListModel legendModel: ListModel {
        id: legendModel
        ListElement {name: "Regular Water Extent"; symbolUrl: "../assets/legend_icons/regW_white.png"; visible: true}
        ListElement {name: "Current Daily Flooded Area / Clouds"; symbolUrl: "../assets/legend_icons/3day_red.png"; visible: true}
        ListElement {name: "Two Week Flooded Area"; symbolUrl: "../assets/legend_icons/2wk_blue.png"; visible: true}
        ListElement {name: "January till Current Flooded Area"; symbolUrl: "../assets/legend_icons/jant_cyan.png"; visible: false}
        ListElement {name: "Historical Water Extent"; symbolUrl: "../assets/legend_icons/histW_gray.png"; visible: false}
    }

    property var defaultLayersArr: ["Regular Water Extent", "Current Daily Flooded Area / Clouds", "Two Week Flooded Area", "January till Current Flooded Area", "Historical Water Extent", "All Extreme Events", "Nearest Extreme Event"];

    property WmsService service2wk;
    property WmsLayer wmsLayer2wk;

    property WmsService service3day;
    property WmsLayer wmsLayer3day;

    property WmsService serviceJan;
    property WmsLayer wmsLayerJan;

    property WmsService serviceRegW;
    property WmsLayer wmsLayerRegW;

    property WmsService serviceHistW;
    property WmsLayer wmsLayerHistW;

    property WmsService serviceEv
    property list<WmsLayerInfo> layerNAEv;
    property WmsLayer wmsLayerEv;

    property WmsService servicePop;

    property WmsService serviceCu
    property WmsLayerInfo layerCu;
    property WmsLayer wmsLayerCu;
    property var layerCuSL;

    property string descriptionLyr;
    property string compLyrName;

    property double radiusSearch;
    property string radiusSearchUnits;
    property bool drawPin: false;
    property Point pinLocation;
    property SimpleMarkerSceneSymbol symbolMarker;

    header: Controls.Header {
        id: header
    }

    Controls.SceneView {
        id: sceneView
    }

    Controls.MenuDrawer {
        id: menu
    }

    Controls.FloatActionButton {
        id: switchBtn
    }

    Controls.NorthUpBtn {
        id: northUpBtn
    }

    Controls.CurrentPositionBtn {
        id: locationBtn
    }

    Controls.HomePositionBtn {
        id: homeLocationBtn
    }

    Controls.DescriptionLayer {
        id: descLyrPage
        visible: false
    }
}
