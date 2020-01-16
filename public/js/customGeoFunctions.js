function getNearestEvent(mouse) {
    pinMessage.visible = 0;
    if (drawPin === true) {
        pinLocation = mouse.mapPoint;
        var xCoor = mouse.mapPoint.x.toFixed(2);
        var yCoor = mouse.mapPoint.y.toFixed(2);

        symbolMarker = ArcGISRuntimeEnvironment.createObject("SimpleMarkerSceneSymbol", {
                                                                 style: Enums.SimpleMarkerSceneSymbolStyleSphere,
                                                                 color: "#00693e",
                                                                 width: 75,
                                                                 height: 75,
                                                                 depth: 75,
                                                             });

        // create a graphic using the point and the symbol
        var graphic = ArcGISRuntimeEnvironment.createObject("Graphic", {
                                                                geometry: pinLocation,
                                                                symbol: symbolMarker
                                                            });

        // clear previous and add new  graphic to the graphics overlay
        graphicsOverlay.graphics.clear();
        graphicsOverlay.graphics.append(graphic);

        sceneView.scene.operationalLayers.forEach(function (lyr, ix) {
            if (lyr.name === "Nearest Events") {
                sceneView.scene.operationalLayers.remove(ix, 1);
            }
        });

        serviceEv = ArcGISRuntimeEnvironment.createObject("WmsService", { url: filteredEventServiceUrl });

        serviceEv.loadStatusChanged.connect(function() {
            if (serviceEv.loadStatus === Enums.LoadStatusLoaded) {
                // get the layer info list
                var serviceEvInfo = serviceEv.serviceInfo;
                var layerInfos = serviceEvInfo.layerInfos;

                // get the all layers
                var layerNAEvTiles = layerInfos[0].sublayerInfos;

                var nearestTileList = [];

                for (var i=2; i<layerNAEvTiles.length; i++) {
                    var inside = insidePolygon([xCoor, yCoor], [[layerInfos[0].sublayerInfos[i].extent.xMin, layerInfos[0].sublayerInfos[i].extent.yMin],
                                                                [layerInfos[0].sublayerInfos[i].extent.xMin, layerInfos[0].sublayerInfos[i].extent.yMax],
                                                                [layerInfos[0].sublayerInfos[i].extent.xMax, layerInfos[0].sublayerInfos[i].extent.yMax],
                                                                [layerInfos[0].sublayerInfos[i].extent.xMax, layerInfos[0].sublayerInfos[i].extent.yMin]
                                               ]);

                    if (inside) {
                        nearestTileList.push([0, i]);
                        continue;
                    }

                    var ans = haversine(yCoor, layerInfos[0].sublayerInfos[i].extent.center.y,
                                        xCoor, layerInfos[0].sublayerInfos[i].extent.center.x
                                        );

                    var ans1 = haversine(yCoor, layerInfos[0].sublayerInfos[i].extent.xMax,
                                         xCoor, layerInfos[0].sublayerInfos[i].extent.yMin
                                         );

                    var ans2 = haversine(yCoor, layerInfos[0].sublayerInfos[i].extent.xMax,
                                         xCoor, layerInfos[0].sublayerInfos[i].extent.yMax
                                         );

                    var ans3 = haversine(yCoor, layerInfos[0].sublayerInfos[i].extent.xMin,
                                         xCoor, layerInfos[0].sublayerInfos[i].extent.yMin
                                         );

                    var ans4 = haversine(yCoor, layerInfos[0].sublayerInfos[i].extent.xMin,
                                         xCoor, layerInfos[0].sublayerInfos[i].extent.yMax
                                         );

                    if (ans < radiusSearch) {
                        nearestTileList.push([ans, i]);
                    } else if (ans1 < radiusSearch) {
                        nearestTileList.push([ans1, i]);
                    } else if (ans2 < radiusSearch) {
                        nearestTileList.push([ans2, i]);
                    } else if (ans3 < radiusSearch) {
                        nearestTileList.push([ans3, i]);
                    } else if (ans4 < radiusSearch) {
                        nearestTileList.push([ans4, i]);
                    }
                }

                layerNAEv = [];

                if (nearestTileList.length > 0) {
                    nearestTileList.forEach(function (elm) {
                        layerNAEv.push(layerInfos[0].sublayerInfos[elm[1]])
                    });

                    wmsLayerEv = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                           layerInfos: layerNAEv,
                                                                           visible: true
                                                                       });

                    sceneView.scene.operationalLayers.append(wmsLayerEv);
                    sceneView.scene.operationalLayers.setProperty(sceneView.scene.operationalLayers.indexOf(wmsLayerEv), "name", "Nearest Events");
                    sceneView.scene.operationalLayers.setProperty(sceneView.scene.operationalLayers.indexOf(wmsLayerEv), "description", layerNAEv.description);

                    graphicsOverlay.graphics.clear();

                    var newViewPointCenter = ArcGISRuntimeEnvironment.createObject("ViewpointCenter", {
                                                                                       center: layerInfos[0].sublayerInfos[nearestTileList[0][1]].extent.center,
                                                                                       targetScale: 1000000 * layerInfos[0].sublayerInfos[nearestTileList[0][1]].extent.width * scaleFactor
                                                                                   });
                    sceneView.setViewpoint(newViewPointCenter);

                    legendModel.insert(0, {name: "Nearest Extreme Event", symbolUrl: "../assets/legend_icons/x_events_red.png", visible: true});
                } else {
                    pinMessage.label.text = qsTr("No nearby event found");
                    pinMessage.visible = 1;
                }
            }
        });

        serviceEv.load();
    }
}

function toRad(Value) {
    /** Converts numeric degrees to radians */
    return Value * Math.PI / 180;
}

function haversine(lat1,lat2,lng1,lng2) {
    var rad = 6372.8; // for km Use 3961 for miles
    if (radiusSearchUnits === 'km') {
        rad = 6372.8;
    } else if (radiusSearchUnits === 'mi') {
        rad = 3961;
    }
    var deltaLat = toRad(lat2-lat1);
    var deltaLng = toRad(lng2-lng1);
    lat1 = toRad(lat1);
    lat2 = toRad(lat2);
    var a = Math.sin(deltaLat/2) * Math.sin(deltaLat/2) + Math.sin(deltaLng/2) * Math.sin(deltaLng/2) * Math.cos(lat1) * Math.cos(lat2);
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    return  rad * c;
}

function insidePolygon(point, tile) {
    var x = point[0], y = point[1];

    var inside = false;
    for (var i = 0, j = tile.length - 1; i < tile.length; j = i++) {
        var xi = tile[i][0], yi = tile[i][1];
        var xj = tile[j][0], yj = tile[j][1];

        var intersect = ((yi > y) != (yj > y))
            && (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
        if (intersect) inside = !inside;
    }

    return inside;
}


