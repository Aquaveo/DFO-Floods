import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0

Rectangle {
    id: popUpReorder
    width: 40 * scaleFactor
    height: 120 * scaleFactor
    anchors {
        right: parent.right
        bottom: parent.bottom
        rightMargin: 100 * scaleFactor
        bottomMargin: 80 * scaleFactor
    }
    color: "#80000000"
    visible: false

    Tumbler {
        id: reorderTmbl
        width: 40 * scaleFactor
        height: 120 * scaleFactor
        visibleItemCount: 3
        Material.background:  "#00693e"
        Material.elevation: 24

        wrap: true

        delegate: Rectangle {
            color: index === menu.contentItem.children[0].contentItem.children[4].currentIndex ? Qt.darker('#00693e') : '#00693e';
            width: parent.width
            height: 40 * scaleFactor
            radius: 12 * scaleFactor
            border.color: "black"
            Text {
                text: sceneView.scene.operationalLayers.count - model.index
                color: "white"
                font.pixelSize: 18 * scaleFactor
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    var reoLyr
                    var reoIx;
                    sceneView.scene.operationalLayers.forEach(function (lyr, ix) {
                        if (lyr.name === pageItem.compLyrName) {
                            reoLyr = lyr
                            reoIx = ix;
                        }
                    })

                    sceneView.scene.operationalLayers.remove(reoIx, 1);
                    sceneView.scene.operationalLayers.insert(model.index, reoLyr);
                    sceneView.scene.operationalLayers.setProperty(model.index, "name", reoLyr.title);
                    sceneView.scene.operationalLayers.setProperty(model.index, "description", reoLyr.description);
                    descLyrPage.visible = 0;
                    menu.open();
                }
            }
        }
    }
}
