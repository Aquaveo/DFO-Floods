import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0

Rectangle {
    id: disclaimer
    anchors.fill: parent
    color: "#80000000"

    MouseArea {
        anchors.fill: parent
        onClicked: mouse.accepted = true
        onWheel: wheel.accepted = true
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        clip:true

        Rectangle {
            id: disclaimerHeader
            Layout.alignment: Qt.AlignTop
            color: "#00693e"
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50 * scaleFactor

            Text {
                id: disclaimerTitle
                text:qsTr("DFO - Terms and Conditions")
                color:"white"
                font.pixelSize: app.baseFontSize * 1.1
                font.bold: true
                anchors.centerIn: parent
                maximumLineCount: 2
                elide: Text.ElideRight
            }
        }

        Rectangle {
            color: "black"
            Layout.fillWidth: true
            Layout.fillHeight: true

            Flickable {
                anchors.fill: parent
                contentHeight: disclaimerText.height + (100 * scaleFactor)
                clip: true

                Text {
                    id: disclaimerText
                    text: qsTr("The data on this app ‘DFO floods’ are provided &quot;as is&quot;, and the DFO – Flood Observatory (hereafter DFO) assumes no responsibility for errors or omissions. The User assumes the entire risk associated with its use of these data. The DFO shall not be held liable for any use or misuse of the data described and/or contained herein. The User bears all responsibility in determining whether these data are fit for the User&#39;s intended use. The information contained in these data is dynamic and may change over time. The data are not better than the original sources from which they were derived, and both scale and accuracy may vary across the data set. These data may not have the accuracy, resolution, completeness, timeliness, or other characteristics appropriate for applications that potential users of the data may contemplate. The User is encouraged to carefully consider the content of the metadata file associated with these data. These data are neither official records, nor legal documents and must not be used as such. Please report any errors in the data to the DFO, through the feedback option of the app. The DFO should be cited as the data source in any products derived from these data. Any Users wishing to modify the data are obligated to describe the types of modifications they have performed. The User specifically agrees not to misrepresent the data, nor to imply that changes made were approved or endorsed by DFO. This information may be updated without notification. By using these data you hereby agree to these conditions. No warranty is made by the DFO for use of the data for purposes not intended by DFO. The DFO assumes no responsibility for errors or omissions. No warranty is made by the DFO as to the accuracy, reliability, relevancy, timeliness, utility, or completeness of these data, maps, geographic location for individual use or aggregate use with other data; nor shall the act of distribution to contractors, partners, or beyond, constitute any such warranty for individual or aggregate data use with other data. Although these data have been processed successfully on computers of DFO, no warranty, expressed or implied, is made by DFO regarding the use of these data on any other system, or for general or scientific purposes, nor does the fact of distribution constitute or imply any such warranty. In no event shall the DFO have any liability whatsoever for payment of any consequential, incidental, indirect, special, or tort damages of any kind, including, but not limited to, any loss of profits arising out of the use or reliance on the geographic data or arising out of the delivery, installation, operation, or support by DFO.")
                    y: 30 * scaleFactor
                    textFormat: Text.StyledText
                    anchors.horizontalCenterOffset: 0
                    color:"white"
                    width: 0.85 * parent.width
                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: app.baseFontSize
                }
            }
        }

        RowLayout {
            id: btnsRow
            width: 0.9 * parent.width
            height: 50 * scaleFactor
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: disclaimerText.bottom
            anchors.topMargin: 20 * scaleFactor
            spacing: 30 * scaleFactor
            layoutDirection: Qt.RightToLeft

            Button {
                id: acceptBtn
                Layout.fillWidth: true
                Layout.minimumWidth: 100 * scaleFactor
                Layout.preferredWidth: 100 * scaleFactor
                Layout.maximumWidth: 150 * scaleFactor
                Layout.minimumHeight: 50 * scaleFactor
                Layout.preferredHeight: 50 * scaleFactor
                anchors {
                    right: parent.right
                    margins: 10 * scaleFactor
                    verticalCenter: parent.verticalCenter
                }

                Material.background: "#00693e"

                text: "ACCEPT"
                background: Rectangle {
                    width: parent.width
                    height: parent.height
                    color: "#00693e"
                    radius: 6 * scaleFactor
                }

                contentItem: Text {
                    text: acceptBtn.text
                    font.pixelSize: 14 * scaleFactor
                    font.bold: true
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                onClicked: {
                    app.settings.setValue("disclaimerAccepted", true);
                    disclaimer.visible = 0;
                    popUp.visible = 1;
                    popUp.children[3].visible = 1;
                    tandCBtn.visible = 1;
                }
            }

            Button {
                id: declineBtn
                Layout.fillWidth: true
                Layout.minimumWidth: 50 * scaleFactor
                Layout.preferredWidth: 100 * scaleFactor
                Layout.maximumWidth: 150 * scaleFactor
                Layout.minimumHeight: 50 * scaleFactor
                Layout.preferredHeight: 50 * scaleFactor
                anchors {
                    left: parent.left
                    margins: 10 * scaleFactor
                    verticalCenter: parent.verticalCenter
                }

                Material.background: "#00693e"

                text: "DECLINE"
                background: Rectangle {
                    width: parent.width
                    height: parent.height
                    color: "#00693e"
                    radius: 6 * scaleFactor
                }

                contentItem: Text {
                    text: declineBtn.text
                    font.pixelSize: 14 * scaleFactor
                    font.bold: true
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                onClicked: {
                    app.settings.setValue("disclaimerAccepted", false);
                    Qt.quit()
                }
            }
        }

    }
}
