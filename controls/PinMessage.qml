import QtQuick 2.7
import QtQuick.Controls 2.1


Rectangle {
    id:pipMessageRec
    height: 40 * scaleFactor
    width: pinMessage.text === "" ? 0 : pinMessage.width + 30 * scaleFactor
    color: "#00693e"
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.leftMargin: 55 * scaleFactor
    anchors.topMargin: 55 * scaleFactor

    Label {
        id: pinMessage
        text: qsTr("Zoom in and tap on a location")
        anchors.centerIn: parent
        font.pixelSize: 12 * scaleFactor
        font.bold: true
        color: "white"
    }
}
