import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

Button {
    id: tandCBtn
    width: 80 * scaleFactor
    height: 50 * scaleFactor
    Material.elevation: 6
    Material.background: "#00693e"
    anchors {
        right: parent.right
        bottom: parent.bottom
        rightMargin: 10 * scaleFactor
        bottomMargin: 10 * scaleFactor
    }

    text: "T&C"
    background: Rectangle {
        width: parent.width
        height: parent.height
        color: "#00693e"
        radius: 6 * scaleFactor
    }

    contentItem: Text {
        text: tandCBtn.text
        font.pixelSize: 14 * scaleFactor
        font.bold: true
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    onClicked: {
//        app.settings.setValue("disclaimerAccepted", false);
        popUp.visible = false;
        tandCBtn.visible = false;
        disclaimer.visible = true;
    }
}
