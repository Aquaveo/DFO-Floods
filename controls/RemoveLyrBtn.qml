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

        if (menu.contentItem.children[0].contentItem.children[6].children[0].children[1] &&
                menu.contentItem.children[0].contentItem.children[6].children[0].children[1].text === remLyr.name) {
            menu.contentItem.children[0].contentItem.children[6].children[0].children[0].checked = false;
        }

        if (menu.contentItem.children[0].contentItem.children[7].children[0].children[1] &&
                menu.contentItem.children[0].contentItem.children[7].children[0].children[1].text === remLyr.name) {
            menu.contentItem.children[0].contentItem.children[7].children[0].children[0].checked = false;
        }

        for (var suggested in menu.contentItem.children[0].contentItem.children[11].children[0].contentItem.children) {
            if (menu.contentItem.children[0].contentItem.children[11].children[0].contentItem.children[suggested].children[0] &&
                    menu.contentItem.children[0].contentItem.children[11].children[0].contentItem.children[suggested].children[0].text === remLyr.name) {
                menu.contentItem.children[0].contentItem.children[11].children[0].contentItem.children[suggested].color = 'lightgray';
            }
        }

        for (var custom in menu.contentItem.children[0].contentItem.children[11].children[1].contentItem.children) {
            if (menu.contentItem.children[0].contentItem.children[11].children[1].contentItem.children[custom].children[0] &&
                    menu.contentItem.children[0].contentItem.children[11].children[1].contentItem.children[custom].children[0].text === remLyr.name) {
                menu.contentItem.children[0].contentItem.children[11].children[1].contentItem.children[custom].color = 'lightgray';
            }
        }

        if (remLyr.name !== "All Events" && remLyr.name !== "Nearest Events") {
            sceneView.scene.operationalLayers.remove(remIx, 1);
            if (/2-week|Current daily|January till|Regular water|Historical flood extent /.test(remLyr.name)) {
                suggestedListM.append(remLyr);
            }
        }

        legendListView.model.remove(menu.contentItem.children[0].contentItem.children[4].count - remIx, 1);

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
