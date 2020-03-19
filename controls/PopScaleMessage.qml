import QtQuick 2.7
import QtQuick.Controls 2.1


Rectangle {
    property alias label: popScaleLabel

    height: childrenRect.height + (30 * scaleFactor)
    width: popScaleLabel.text === "" ? 0 : popScaleLabel.width + 30 * scaleFactor
    color: "#00693e"
    radius: 6 * scaleFactor
    anchors.centerIn: parent.Center
    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.margins: 60 * scaleFactor

    Label {
        id: popScaleLabel
        text: ""
        width: 0.75 * pageItem.width
        anchors.centerIn: parent
        font.pixelSize: 12 * scaleFactor
        font.bold: true
        color: "white"
        wrapMode: Label.Wrap
    }

    Timer {
        id: hideWindowTimer
        onTriggered: popScaleM.visible = false;
    }

    function hideWindow(time) {
        hideWindowTimer.interval = time;
        hideWindowTimer.restart();
    }
}
