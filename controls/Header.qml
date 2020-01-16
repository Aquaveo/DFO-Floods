import QtQuick 2.0
import QtQuick.Controls 2.1
//import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Material 2.1

import "../controls" as Controls

ToolBar {
    width: parent.width
    height: 50 * scaleFactor
    Material.background: "#00693e"
    Controls.HeaderBar{}

    ToolButton {
        id: menuButton
        width: 45 * scaleFactor
        height: 45 * scaleFactor
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: 8
        }

        indicator: Image {
            source: "../assets/menu.png"
            anchors.fill: parent
        }

        onClicked: {
            menu.open();
        }
    }
}

