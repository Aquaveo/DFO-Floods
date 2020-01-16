function addWmsLayers() {
    // set the default basemap
    scene.basemap = ArcGISRuntimeEnvironment.createObject("BasemapImageryWithLabels");

    // create the services
    serviceRegW = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wmsRegWServiceUrl });
    service3day = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wms3dayServiceUrl });
    service2wk = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wms2wkServiceUrl });
    serviceJan = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wmsJanServiceUrl });
    serviceHistW = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wmsHistWServiceUrl });

    // suggested services
    serviceGlo = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wmsGlofasServiceUrl });
    serviceFF = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wmsFloodFreqServiceUrl });
    serviceStations = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wmsStationsServiceUrl });
    servicePop = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wmsWorldPopServiceUrl });

    serviceRegW.loadStatusChanged.connect(function() {
        if (serviceRegW.loadStatus === Enums.LoadStatusLoaded) {
            // get the layer info list
            var serviceRegWInfo = serviceRegW.serviceInfo;
            var layerInfos = serviceRegWInfo.layerInfos;

            // get the desired layer from the list
            layerRegW = layerInfos[0].sublayerInfos[0]

            wmsLayerRegW = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                     layerInfos: [layerRegW],
                                                                 });

            scene.operationalLayers.append(wmsLayerRegW);
            scene.operationalLayers.setProperty(scene.operationalLayers.indexOf(wmsLayerRegW), "name", layerRegW.title);
            scene.operationalLayers.setProperty(scene.operationalLayers.indexOf(wmsLayerRegW), "description", layerRegW.description);
        }
    });

    service3day.loadStatusChanged.connect(function() {
        if (service3day.loadStatus === Enums.LoadStatusLoaded) {
            // get the layer info list
            var service3dayInfo = service3day.serviceInfo;
            var layerInfos = service3dayInfo.layerInfos;

            // get the desired layer from the list
            layer3day = layerInfos[0].sublayerInfos[0]

            wmsLayer3day = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                     layerInfos: [layer3day],
                                                                 });

            scene.operationalLayers.append(wmsLayer3day);
            scene.operationalLayers.setProperty(scene.operationalLayers.indexOf(wmsLayer3day), "name", layer3day.title);
            scene.operationalLayers.setProperty(scene.operationalLayers.indexOf(wmsLayer3day), "description", layer3day.description);

            serviceRegW.load();
        } else if (service3day.loadStatus === Enums.LoadStatusFailedToLoad ||
                   service3day.loadStatus === Enums.LoadStatusNotLoaded ||
                   service3day.loadStatus === Enums.LoadStatusUnknown) {
            serviceRegW.load();
        }
    });

    service2wk.loadStatusChanged.connect(function() {
        if (service2wk.loadStatus === Enums.LoadStatusLoaded) {
            // get the layer info list
            var service2wkInfo = service2wk.serviceInfo;
            var layerInfos = service2wkInfo.layerInfos;

            // get the desired layer from the list
            layer2wk = layerInfos[0].sublayerInfos[0]

            wmsLayer2wk = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                    layerInfos: [layer2wk]
                                                                });

            scene.operationalLayers.append(wmsLayer2wk);
            scene.operationalLayers.setProperty(scene.operationalLayers.indexOf(wmsLayer2wk), "name", layer2wk.title);
            scene.operationalLayers.setProperty(scene.operationalLayers.indexOf(wmsLayer2wk), "description", layer2wk.description);

            service3day.load();
        } else if (service2wk.loadStatus === Enums.LoadStatusFailedToLoad ||
                   service2wk.loadStatus === Enums.LoadStatusNotLoaded ||
                   service2wk.loadStatus === Enums.LoadStatusUnknown) {
            service3day.load();
        }
    });

    serviceJan.loadStatusChanged.connect(function() {
        if (serviceJan.loadStatus === Enums.LoadStatusLoaded) {
            // get the layer info list
            var serviceJanInfo = serviceJan.serviceInfo;
            var layerInfos = serviceJanInfo.layerInfos;

            // get the desired layer from the list
            layerJan = layerInfos[0].sublayerInfos[0]

            wmsLayerJan = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                    layerInfos: [layerJan],
                                                                    visible: false
                                                                });

            scene.operationalLayers.append(wmsLayerJan);
            scene.operationalLayers.setProperty(scene.operationalLayers.indexOf(wmsLayerJan), "name", layerJan.title);
            scene.operationalLayers.setProperty(scene.operationalLayers.indexOf(wmsLayerJan), "description", layerJan.description);

            service2wk.load();
        } else if (serviceJan.loadStatus === Enums.LoadStatusFailedToLoad ||
                   serviceJan.loadStatus === Enums.LoadStatusNotLoaded ||
                   serviceJan.loadStatus === Enums.LoadStatusUnknown) {
            service2wk.load();
        }
    });

    serviceHistW.loadStatusChanged.connect(function() {
        if (serviceHistW.loadStatus === Enums.LoadStatusLoaded) {
            // get the layer info list
            var serviceHistWInfo = serviceHistW.serviceInfo;
            var layerInfos = serviceHistWInfo.layerInfos;

            // get the desired layer from the list
            layerHistW = layerInfos[0].sublayerInfos[0]

            wmsLayerHistW = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                      layerInfos: [layerHistW],
                                                                      visible: false
                                                                 });

            scene.operationalLayers.append(wmsLayerHistW);
            scene.operationalLayers.setProperty(scene.operationalLayers.indexOf(wmsLayerHistW), "name", layerHistW.title);
            scene.operationalLayers.setProperty(scene.operationalLayers.indexOf(wmsLayerHistW), "description", layerHistW.description);

            serviceJan.load();
        } else if (serviceHistW.loadStatus === Enums.LoadStatusFailedToLoad ||
                   serviceHistW.loadStatus === Enums.LoadStatusNotLoaded ||
                   serviceHistW.loadStatus === Enums.LoadStatusUnknown) {
            serviceJan.load();
        }
    });

    // start service load chain
    serviceHistW.load();

    serviceGlo.loadStatusChanged.connect(function() {
        if (serviceGlo.loadStatus === Enums.LoadStatusLoaded) {
            var serviceGloInfo = serviceGlo.serviceInfo;
            var layerInfos = serviceGloInfo.layerInfos;

            // add all layers to model
            suggestedListM = Qt.createQmlObject('import QtQuick 2.7; ListModel {}', pageItem);

            addToModel(layerInfos[0].sublayerInfos[2].sublayerInfos, suggestedListM);
            serviceFF.load();
        } else if (serviceGlo.loadStatus === Enums.LoadStatusFailedToLoad ||
                   serviceGlo.loadStatus === Enums.LoadStatusNotLoaded ||
                   serviceGlo.loadStatus === Enums.LoadStatusUnknown) {
            serviceFF.load();
        }
    });

    serviceFF.loadStatusChanged.connect(function() {
        if (serviceFF.loadStatus === Enums.LoadStatusLoaded) {
            var serviceFFInfo = serviceFF.serviceInfo;
            var layerInfos = serviceFFInfo.layerInfos;
            var regIx = popUp.listViewCurrentIndex + 1;

            suggestedListM.append(layerInfos[0].sublayerInfos[regIx]);
            servicePop.load();
        } else if (serviceFF.loadStatus === Enums.LoadStatusFailedToLoad ||
                   serviceFF.loadStatus === Enums.LoadStatusNotLoaded ||
                   serviceFF.loadStatus === Enums.LoadStatusUnknown) {
            servicePop.load();
        }
    });

    servicePop.loadStatusChanged.connect(function() {
        if (servicePop.loadStatus === Enums.LoadStatusLoaded) {
            var servicePopInfo = servicePop.serviceInfo;
            var layerInfos = servicePopInfo.layerInfos;

            suggestedListM.append(layerInfos[0].sublayerInfos[0]);
            serviceStations.load();
        } else if (servicePop.loadStatus === Enums.LoadStatusFailedToLoad ||
                   servicePop.loadStatus === Enums.LoadStatusNotLoaded ||
                   servicePop.loadStatus === Enums.LoadStatusUnknown) {
            serviceStations.load();
        }
    });

    serviceStations.loadStatusChanged.connect(function() {
        if (serviceStations.loadStatus === Enums.LoadStatusLoaded) {
            var serviceStationsInfo = serviceStations.serviceInfo;
            var layerInfos = serviceStationsInfo.layerInfos;

            suggestedListM.append(layerInfos[0].sublayerInfos[0]);
        }
    });

    // load suggested services
    serviceGlo.load();
}

function addToModel (item, model) {
    for (var p in item) {
        var ECMWFPrecip = ["EGE_probRgt300", "EGE_probRgt150", "EGE_probRgt50", "AccRainEGE"];
        if (ECMWFPrecip.includes(item[p].name)) {
            model.append(item[p]);
        }
    }
}




