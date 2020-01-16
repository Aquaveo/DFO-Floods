import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.5

RoundButton {
    id: removeLyrBtn

    radius: 30 * scaleFactor
    width: 60 * scaleFactor
    height: 60 * scaleFactor
    Material.elevation: 6
    Material.background: "#00693e"

    anchors {
        right: parent.right
        bottom: parent.bottom
        rightMargin: 20 * scaleFactor
        bottomMargin: 10 * scaleFactor
    }

    onClicked: {
        var remLyr
        var remIx;
        sceneView.scene.operationalLayers.forEach(function (lyr, ix) {
            if (lyr.name === pageItem.compLyrName) {
                remLyr = lyr
                remIx = ix;
            }
        })

        if (menu.allEventsLyrName && menu.allEventsLyrName.text === remLyr.name) {
            menu.allEventsLyrCheck.checked = false;
        }

        if (menu.nearestEventLyrName && menu.nearestEventLyrName.text === remLyr.name) {
            menu.nearestEventLyrCheck.checked = false;
        }

        for (var suggested in menu.suggestedLyrsList.contentItem.children) {
            if (menu.suggestedLyrsList.contentItem.children[suggested].label && menu.suggestedLyrsList.contentItem.children[suggested].label.text === remLyr.name) {
                menu.suggestedLyrsList.contentItem.children[suggested].color = 'lightgray';
            }
        }

        for (var custom in menu.customLyrList.contentItem.children) {
            if (menu.customLyrList.contentItem.children[custom].label && menu.customLyrList.contentItem.children[custom].label.text === remLyr.name) {
                menu.customLyrList.contentItem.children[custom].color = 'lightgray';
            }
        }

        if (remLyr.name !== "All Events" && remLyr.name !== "Nearest Events") {
            sceneView.scene.operationalLayers.remove(remIx, 1);

            if (/2-week|Current daily|January till|Regular water|Historical flood extent /.test(remLyr.name)) {
                suggestedListM.append(remLyr);
            }

            sceneView.legendListView.model.remove(menu.lyrToC.count - remIx, 1);
        }

        descLyrPage.visible = 0;
        menu.open();
    }

    Image {
        source: "../assets/removeLyr.png"
        height: 24 * scaleFactor
        width: 24 * scaleFactor
        anchors.centerIn: parent
    }
}
