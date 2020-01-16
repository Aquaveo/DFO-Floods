import QtQuick 2.7
import QtQuick.Controls 2.1


Rectangle {
    property alias label: pinMessageLabel

    height: 40 * scaleFactor
    width: pinMessageLabel.text === "" ? 0 : pinMessageLabel.width + 30 * scaleFactor
    color: "#00693e"
    radius: 6 * scaleFactor
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.leftMargin: 55 * scaleFactor
    anchors.topMargin: 55 * scaleFactor

    Label {
        id: pinMessageLabel
        text: qsTr("Zoom in and tap on a location")
        anchors.centerIn: parent
        font.pixelSize: 12 * scaleFactor
        font.bold: true
        color: "white"
    }
}
