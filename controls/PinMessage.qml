import QtQuick 2.7
import QtQuick.Controls 2.1


Rectangle {
    id:pipMessageRec
    height: 40 * scaleFactor
    width: pinMessage.text === "" ? 0 : pinMessage.width + 30 * scaleFactor
    color: "#00693e"
    anchors.top: header.bottom
    anchors.left: parent.left
    anchors.leftMargin: 20 * scaleFactor

    Label {
        id: pinMessage
        text: qsTr("Zoom in and tap on a location")
        anchors.centerIn: parent
        font.bold: true
        font.pointSize: 10
        color: "white"
    }
}
