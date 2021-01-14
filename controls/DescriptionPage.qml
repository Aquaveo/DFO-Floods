import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0

import "../public/js/jsrsasign.js" as JWS

Rectangle {
    id: descPage
    width: parent.width
    height: parent.height
    anchors.fill: parent

    property string fbStatusText: ""
    property string appRate: "Not rated";
    property string accessToken;
    property var postRequestBody;
    property alias feedbackTextArea: feedbackTextArea

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
            id: descPageheader
            Layout.alignment: Qt.AlignTop
            color: "#00693e"
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50 * scaleFactor

            Button {
                Material.background: "transparent"
                height: 30 * scaleFactor
                width: 30 * scaleFactor
                anchors {
                    right: parent.right
                    rightMargin: 10 * scaleFactor
                    verticalCenter: parent.verticalCenter
                }

                Image {
                    source: "../assets/clear.png"
                    height: 30 * scaleFactor
                    width: 30 * scaleFactor
                    anchors.centerIn: parent
                }

                onClicked: {
                    descPage.visible = 0
                }
            }

            Text {
                id: aboutApp
                text:qsTr("About")
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
                contentHeight: descText.height + imageRect.height + feedbackText.height + feedbackRect.height + (100 * scaleFactor)
                clip: true
                
                Text {
                    id: descText
                    text: descriptionText
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

                Row {
                    id: imageRect
                    width: 0.9 * parent.width
                    spacing: 20 * scaleFactor
                    anchors.top: descText.bottom
                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        width: 0.4 * parent.width
                        height: childrenRect.height
                        anchors.verticalCenter: parent.verticalCenter
                        color: "transparent"

                        Row {
                            width: parent.width
                            spacing: 10 * scaleFactor

                            Text {
                                text: qsTr("Sponsored by: ")
                                textFormat: Text.StyledText
                                color:"white"
                                width: 0.7 * parent.width
                                horizontalAlignment: Text.AlignLeft
                                anchors.verticalCenter: parent.verticalCenter
                                wrapMode: Text.Wrap
                                elide: Text.ElideRight
                                font.pixelSize: 14 * scaleFactor
                            }

                            Image {
                                width: 0.3 * parent.width
                                height: width * 0.84
                                anchors.verticalCenter: parent.verticalCenter
                                source: "../assets/nasaLogo.png"

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: Qt.openUrlExternally('https://sbir.nasa.gov/')
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: 0.5 * parent.width
                        height: childrenRect.height
                        anchors.verticalCenter: parent.verticalCenter
                        color: "transparent"

                        Row {
                            width: parent.width
                            spacing: 10 * scaleFactor

                            Text {
                                text: qsTr("Developed by: ")
                                textFormat: Text.StyledText
                                color:"white"
                                width: 0.5 * parent.width
                                horizontalAlignment: Text.AlignLeft
                                anchors.verticalCenter: parent.verticalCenter
                                wrapMode: Text.Wrap
                                elide: Text.ElideRight
                                font.pixelSize: 14 * scaleFactor
//                                font.bold: true
                            }

                            Text {
                                text: qsTr("DFO, RSS, Aquaveo")
                                textFormat: Text.StyledText
                                color:"white"
                                width: 0.5 * parent.width
                                horizontalAlignment: Text.AlignLeft
                                anchors.verticalCenter: parent.verticalCenter
                                wrapMode: Text.Wrap
                                elide: Text.ElideRight
                                font.pixelSize: 14 * scaleFactor
//                                font.bold: true
                            }


                        }
                    }

                }

                Row {
                    id: fbTitle
                    width: 0.9 * parent.width
                    height: 50 * scaleFactor
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: imageRect.bottom

                    Text {
                        id: feedbackText
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("Send Feedback")
                        textFormat: Text.StyledText
                        color:"white"
                        width: 0.75 * parent.width
                        horizontalAlignment: Text.AlignLeft
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight

                        font.pixelSize: app.baseFontSize
                        font.bold: true
                    }

                    Button {
                        id: feedbackSend
                        anchors.verticalCenter: parent.verticalCenter

                        width: 0.25 * parent.width
                        height: 40 * scaleFactor

                        Material.background: "#00693e"
                        text: "SEND"
                        background: Rectangle {
                            width: parent.width
                            height: parent.height
                            color: "#00693e"
                            radius: 6 * scaleFactor
                        }

                        contentItem: Text {
                            text: feedbackSend.text
                            font.pixelSize: 14 * scaleFactor
                            font.bold: true
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        onClicked: {
                            fbStatusWindow.visible = true
                            function tokenReq(signature) {
                                var xhr = new XMLHttpRequest();

                                xhr.open("POST", "https://oauth2.googleapis.com/token");
                                xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
                                xhr.onload = function (e) {
                                    if (e) {
                                        console.log(e);
                                    };

                                    if (xhr.readyState === 4) {
                                        if (xhr.status === 200) {
                                            fbStatusText = "Obtained token"
                                            accessToken = JSON.parse(xhr.responseText)["access_token"];
                                            postReq(postRequestBody, accessToken);
                                        } else {
                                            fbStatusText = "Failed to get token";
                                            fbStatusWindow.hideWindow(3000);
                                        }
                                    } else {
                                        fbStatusText = "Obtaining token";
                                        fbStatusWindow.hideWindow(3000);
                                    };
                                };

                                xhr.send("grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=%1".arg(signature));
                            };

                            function postReq(request, accessToken) {
                                var xhr = new XMLHttpRequest();
                                xhr.open("POST", "https://sheets.googleapis.com/v4/spreadsheets/1JHr6CcKuFRif7_vBVZ0LLFMRCNqRjdeWFPYba-UBgek/values/Sheet1!A1%3AH1:append?includeValuesInResponse=true&insertDataOption=INSERT_ROWS&valueInputOption=USER_ENTERED");
                                xhr.setRequestHeader('Authorization', 'Bearer ' + accessToken);
                                xhr.setRequestHeader('Content-Type', 'application/json');
                                xhr.onload = function (e) {
                                    if (e) {
                                        console.log(e);
                                    };

                                    if (xhr.readyState === 4) {
                                        if (xhr.status === 200) {
                                            fbStatusText = "Feedback sent";
                                            fbStatusWindow.hideWindow(3000);
                                        } else {
                                            fbStatusText = "Failed to send";
                                            fbStatusWindow.hideWindow(3000);
                                        }
                                    } else {
                                        fbStatusText = "Sending feedback";
                                        fbStatusWindow.hideWindow(3000);
                                    };
                                };
                                xhr.send(JSON.stringify(request));
                            };

                            if (emailFB.text === "Email") {
                                emailFB.text = ""
                            }

                            if (nameFB.text === "Name") {
                                nameFB.text = ""
                            }

                            var currentDate = Math.round(Date.now()/1000);
                            var header = {"alg": "RS256","typ": "JWT"}

                            var payload = {
                                "iss": "dfofeedback@api-project-220498621392.iam.gserviceaccount.com",
                                "scope": "https://www.googleapis.com/auth/spreadsheets",
                                "aud": "https://oauth2.googleapis.com/token",
                                "exp": currentDate + 1800,
                                "iat": currentDate
                            }

                            var prvKey = JWS.KEYUTIL.getKey("-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCYv6FCyL1w2+gO\n2cGQ/53MoIiHN81LCYCmpEmURSWHdIeUCkKMGf1xBJXGOiqunOQ6UHP9f9SM07Jc\ndv9yv9jocTy2cixCkhRWBvOSX7BFLFx5s2ZCopt/c+YBjbpusANgqkmpOjR9cO2w\n+Q6PARsjy7fEPD2iGZdx9y95doCcMH6D7ydOlk4FV10oOjxRPl2kjEDOgxYU82jT\nfe7m2oulvUZSR86WiA+YnORZGMTOvw4jSll1kd6NuaWoeuvKRRmJZakqg15YTSr0\nIWpv/F9N2C0N5rX20lE3e3rU55KSNpa1AqYpK5LtAomCiaXXJpVVyeeO87nk6sFX\n2Q5pEmK5AgMBAAECggEAGjI3LlRuBNZ6AF4BD+R+xBK+B26fAyDwkuO3CLopGwd1\nnwJ5cjyc1g6ivxnHqyWWEJgupEmRgstlme0Al0XmpcqRznpbM9mIqk5L5I0Llnlq\nrKaDQadQgrW2Owr677O5CJF7y42DZgYBhanZANaAOI3eCMYKDexUqENrvWmA2ghE\n/kIh/nP40t3dimXbFUxeI6aoi0tJT0FL4t2+I4Icp+zTiQaRGlG/59eZK5lVynM5\nhE9LzowRb1KIXnP4JH3w/V6wt5T9HL9P/NwQdynq0O3unKfuo7sptZxrCaRlNoIx\nIr08VEZ+qBUsGZnlay95z4cQMoCD+9I8n6/inXQcZwKBgQDXf8wB+itc6DvQGM3I\nJ/i3xVQxeeo8ufBWVbo1LNqdLBL0QWIRWR0Mkt3aTGprRZ6en++1LgBeUCgO4MW2\nn1icKdi2oygB67Ex+tdadcp6omcJoUhO8DSAU/cD+C8BEvtcgOFWqpxPJdHUU2aQ\nMnVGJXpH3UinV7/o7lGhnHhgxwKBgQC1dL40Yh5ny8Rui3IdPcuK+Nvgr0OX01+o\nIZhhkC0AzGE1OPiMyOsAQMLJJ2XsB5VN3vd4BDKIjnkCKWa6XgtgIdJBV3mvFlrt\nkfA2PLedyq+jEy9BmY3foWejCVS06skfpb5pe4L0l70ZkRPS2TT7cDPu95xqeUFi\nX4S1KjKgfwKBgQDLm+rEP3tzF9VTo+viXqnn8GDBMoB3ifMjj3IVReD0Oa1a7N/c\npkcFF0rYM/Ukj630EAcrN2CPu8ptbEBCcUIGop8oyPVHA0rzfx60ULDTt9gEyEcK\nlnf0e+Da9kZrDGVEnFzMRvzS51fe9kHkolgdw9FKTzCTNByV1353ZOB0BwKBgQCD\nTuzJOWupTvJh0HUOpgYiFf3/NLUkLCifoVgE2fFHD58UhZqPPmGYeES8jc8ao04u\n4LeR2O+8k+ULZGxbVuzCbxcYg7WhtvqryhzbEssI24CH8L0UqorZFpLJj1oF5ZUP\nWsBU0rUsTJXh53NB9D576XEbb4F4JzDigB6nftbN/wKBgHdwdVNhBU7amv7NrUEQ\n4MqGck787cvkM9elzUOKKn2pMWFMSfBVaOWg6o6faUY0WRhDeg9JjI+NGoU1eZnm\nFsX6vSLEalHq5xEcGYRsn7OYO6Q6v74bDobB688BwQ+AotkDBpYNzEeyGt3q/BaQ\nvQjwxdMju+t9s21f/0mPhKmI\n-----END PRIVATE KEY-----\n");

                            var sign = JWS.KJUR.jws.JWS.sign("RS256", JSON.stringify(header), JSON.stringify(payload), prvKey);

                            tokenReq(sign);
                            var formattedCurrentDate = new Date(currentDate*1000).toUTCString();

                            postRequestBody = {
                                "range": "Sheet1!A1:H1",
                                "majorDimension": "ROWS",
                                "values": [
                                    [
                                        formattedCurrentDate,
                                        appRate,
                                        professionCB.currentText,
                                        commentTypeCB.currentText,
                                        emailFB.text,
                                        nameFB.text,
                                        feedbackTextArea.text
                                    ]
                                ]
                            };
                        }
                    }
                }

                Rectangle {
                    id: feedbackRect
                    width: 0.9 * parent.width
                    height: childrenRect.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: fbTitle.bottom
                    color: "transparent"
                    radius: 6 * scaleFactor
                    clip: true

                    Column {
                        width: parent.width
                        spacing: 20 * scaleFactor

                        Row {
                            id: ratingRow
                            width: parent.width
                            spacing: 20 * scaleFactor

                            clip: true

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: qsTr("Rate this app: ")
                                textFormat: Text.StyledText
                                color:"white"
                                width: 0.3 * parent.width
                                height: 30 * scaleFactor
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.WordWrap

                                font.pixelSize: 14 * scaleFactor
                                font.bold: true
                            }

                            AbstractButton {
                                id: star1
                                width: (0.3 * parent.width)/5
                                height: 30 * scaleFactor
                                anchors.verticalCenter: parent.verticalCenter
                                checked: false

                                indicator: Rectangle {
                                    width: 30 * scaleFactor
                                    height: 30 * scaleFactor
                                    color: "transparent"
                                    anchors.verticalCenter: parent.verticalCenter

                                    Rectangle {
                                        width: parent.width
                                        height: parent.height
                                        color: "transparent"

                                        Image {
                                            width: parent.width * 0.8
                                            height: parent.height * 0.8
                                            anchors.centerIn: parent
                                            source: star1.checked ? "../assets/starred.png" : "../assets/notStarred.png"
                                        }
                                    }
                                }

                                onClicked: {
                                    star1.checked = true;
                                    star2.checked = false;
                                    star3.checked = false;
                                    star4.checked = false;
                                    star2.checked = false;
                                    appRate = "Terrible";
                                }
                            }

                            AbstractButton {
                                id: star2
                                width: (0.3 * parent.width)/5
                                height: 30 * scaleFactor
                                anchors.verticalCenter: parent.verticalCenter
                                checked: false

                                indicator: Rectangle {
                                    width: 30 * scaleFactor
                                    height: 30 * scaleFactor
                                    color: "transparent"
                                    anchors.verticalCenter: parent.verticalCenter

                                    Rectangle {
                                        width: parent.width
                                        height: parent.height
                                        color: "transparent"

                                        Image {
                                            width: parent.width * 0.8
                                            height: parent.height * 0.8
                                            anchors.centerIn: parent
                                            source: star2.checked ? "../assets/starred.png" : "../assets/notStarred.png"
                                        }
                                    }
                                }

                                onClicked: {
                                    star1.checked = true;
                                    star2.checked = true;
                                    star3.checked = false;
                                    star4.checked = false;
                                    star5.checked = false;
                                    appRate = "Bad";
                                }
                            }

                            AbstractButton {
                                id: star3
                                width: (0.3 * parent.width)/5
                                height: 30 * scaleFactor
                                anchors.verticalCenter: parent.verticalCenter
                                checked: false

                                indicator: Rectangle {
                                    width: 30 * scaleFactor
                                    height: 30 * scaleFactor
                                    color: "transparent"
                                    anchors.verticalCenter: parent.verticalCenter

                                    Rectangle {
                                        width: parent.width
                                        height: parent.height
                                        color: "transparent"

                                        Image {
                                            width: parent.width * 0.8
                                            height: parent.height * 0.8
                                            anchors.centerIn: parent
                                            source: star3.checked ? "../assets/starred.png" : "../assets/notStarred.png"
                                        }
                                    }
                                }

                                onClicked: {
                                    star1.checked = true;
                                    star2.checked = true;
                                    star3.checked = true;
                                    star4.checked = false;
                                    star5.checked = false;
                                    appRate = "Average";
                                }
                            }

                            AbstractButton {
                                id: star4
                                width: (0.3 * parent.width)/5
                                height: 30 * scaleFactor
                                anchors.verticalCenter: parent.verticalCenter
                                checked: false

                                indicator: Rectangle {
                                    width: 30 * scaleFactor
                                    height: 30 * scaleFactor
                                    color: "transparent"
                                    anchors.verticalCenter: parent.verticalCenter

                                    Rectangle {
                                        width: parent.width
                                        height: parent.height
                                        color: "transparent"

                                        Image {
                                            width: parent.width * 0.8
                                            height: parent.height * 0.8
                                            anchors.centerIn: parent
                                            source: star4.checked ? "../assets/starred.png" : "../assets/notStarred.png"
                                        }
                                    }
                                }

                                onClicked: {
                                    star1.checked = true;
                                    star2.checked = true;
                                    star3.checked = true;
                                    star4.checked = true;
                                    star5.checked = false;
                                    appRate = "Good";
                                }
                            }

                            AbstractButton {
                                id: star5
                                width: (0.3 * parent.width)/5
                                height: 30 * scaleFactor
                                anchors.verticalCenter: parent.verticalCenter
                                checked: false

                                indicator: Rectangle {
                                    width: 30 * scaleFactor
                                    height: 30 * scaleFactor
                                    color: "transparent"
                                    anchors.verticalCenter: parent.verticalCenter

                                    Rectangle {
                                        width: parent.width
                                        height: parent.height
                                        color: "transparent"

                                        Image {
                                            width: parent.width * 0.8
                                            height: parent.height * 0.8
                                            anchors.centerIn: parent
                                            source: star5.checked ? "../assets/starred.png" : "../assets/notStarred.png"
                                        }
                                    }
                                }

                                onClicked: {
                                    star1.checked = true;
                                    star2.checked = true;
                                    star3.checked = true;
                                    star4.checked = true;
                                    star5.checked = true;
                                    appRate = "Very good";
                                }
                            }
                        }

                        Row {
                            id: professionRow
                            width: parent.width
                            spacing: 20 * scaleFactor

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: qsTr("Profession: ")
                                textFormat: Text.StyledText
                                color:"white"
                                width: 0.3 * parent.width
                                height: 30 * scaleFactor
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight

                                font.pixelSize: 14 * scaleFactor
                                font.bold: true
                            }

                            ComboBox {
                                id: professionCB
                                anchors.verticalCenter: parent.verticalCenter
                                width: 0.6 * parent.width
                                height: 40 * scaleFactor
                                Material.accent:"#00693e"
                                background: Rectangle {
                                    radius: 6 * scaleFactor
                                    border.color: "darkgrey"
                                    width: parent.width
                                    height: 40 * scaleFactor
                                }

                                font.pixelSize: 14 * scaleFactor
                                model: [
                                    " - ","Academia","Insurance industry", "Non-governmental agency",
                                    "First relief agency", "Government", "Military", "Other"
                                ]

                                delegate: ItemDelegate {
                                    Material.accent:"#00693e"
                                    width: parent.width
                                    text: professionCB.model[index]
                                    font.pixelSize: 14 * scaleFactor
                                    topPadding: 13 * scaleFactor
                                    bottomPadding: 13 * scaleFactor
                                }

                                indicator: Image {
                                    width: 40 * scaleFactor
                                    height: 40 * scaleFactor
                                    source: "../assets/dropdown_arrow.png"
                                    anchors.right: parent.right
                                }
                            }
                        }

                        Row {
                            id: commentTypeRow
                            width: parent.width
                            spacing: 20 * scaleFactor

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: qsTr("Type of Comment: ")
                                textFormat: Text.StyledText
                                color:"white"
                                width: 0.3 * parent.width
                                height: 30 * scaleFactor
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight

                                font.pixelSize: 14 * scaleFactor
                                font.bold: true
                            }

                            ComboBox {
                                id: commentTypeCB
                                anchors.verticalCenter: parent.verticalCenter
                                width: 0.6 * parent.width
                                height: 40 * scaleFactor
                                Material.accent:"#00693e"
                                background: Rectangle {
                                    radius: 6 * scaleFactor
                                    border.color: "darkgrey"
                                    width: parent.width
                                    height: 40 * scaleFactor
                                }

                                font.pixelSize: 14 * scaleFactor
                                model: ["Report a bug", "Suggest new feature", "Other"]

                                delegate: ItemDelegate {
                                    Material.accent:"#00693e"
                                    width: parent.width
                                    text: commentTypeCB.model[index]
                                    font.pixelSize: 14 * scaleFactor
                                    topPadding: 13 * scaleFactor
                                    bottomPadding: 13 * scaleFactor
                                }

                                indicator: Image {
                                    width: 40 * scaleFactor
                                    height: 40 * scaleFactor
                                    source: "../assets/dropdown_arrow.png"
                                    anchors.right: parent.right
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 160 * scaleFactor > feedbackTextArea.contentHeight ? 160 * scaleFactor : feedbackTextArea.contentHeight + 50 * scaleFactor
                            anchors.horizontalCenter: parent.horizontalCenter
                            radius: 6 * scaleFactor
                            color: "white"
                            border.color: "darkgrey"

                            TextArea {
                                id: feedbackTextArea
                                text: "\n\n"
                                color: "black"
                                Material.accent:"#00693e"
                                width: 0.85 * parent.width
                                anchors.fill: parent
                                anchors.margins: 10 * scaleFactor
                                anchors.horizontalCenter: parent.horizontalCenter

                                font.pixelSize: 14 * scaleFactor
                                selectByMouse: true
                                selectedTextColor: "white"
                                selectionColor: "#249567"
                                wrapMode: TextArea.Wrap
                                clip: true
                            }
                        }

                        Row {
                            id: contactInfoRow
                            width: parent.width
                            spacing: 10 * scaleFactor

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: qsTr("Do you want us to follow up?")
                                textFormat: Text.StyledText
                                color:"white"
                                width: 0.3 * parent.width
                                height: 50 * scaleFactor
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.Wrap

                                font.pixelSize: 14 * scaleFactor
                                font.bold: true
                            }

                            Rectangle {
                                id: nameFBRect
                                width: 0.2 * parent.width
                                height: 50 * scaleFactor
                                radius: 6 * scaleFactor
                                border.color: "darkgrey"

                                TextInput {
                                    id: nameFB
                                    text: "Name"
                                    maximumLength: 50
                                    color: "black"
                                    width: 25 * scaleFactor
                                    height: 40 * scaleFactor
                                    font.pixelSize: 14 * scaleFactor
                                    anchors.fill: parent
                                    verticalAlignment: TextInput.AlignVCenter
                                    anchors.margins: 13 * scaleFactor
                                    selectByMouse: true
                                    selectedTextColor: "white"
                                    selectionColor: "#249567"
                                    clip: true
                                    wrapMode: TextInput.WrapAnywhere

                                    onFocusChanged: {
                                        if (nameFB.text === "Name") {
                                            nameFB.text = ""
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                id: emailFBRect
                                width: 0.4 * parent.width
                                height: 50 * scaleFactor
                                radius: 6 * scaleFactor
                                border.color: "darkgrey"

                                TextInput {
                                    id: emailFB
                                    text: "Email"
                                    validator: RegExpValidator { regExp: /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/ }
                                    color: "black"
                                    width: 25 * scaleFactor
                                    height: 40 * scaleFactor
                                    font.pixelSize: 14 * scaleFactor
                                    anchors.fill: parent
                                    verticalAlignment: TextInput.AlignVCenter
                                    anchors.margins: 13 * scaleFactor
                                    selectByMouse: true
                                    selectedTextColor: "white"
                                    selectionColor: "#249567"
                                    clip: true
                                    wrapMode: TextInput.WrapAnywhere

                                    onFocusChanged: {
                                        if (emailFB.text === "Email") {
                                            emailFB.text = ""
                                        }
                                    }

                                    onTextChanged: {
                                        if (!["", "Email"].includes(emailFB.text)) {
                                            if (!emailFB.acceptableInput) {
                                                emailFB.color = "red"
                                            } else {
                                                emailFB.color = "black"
                                            }
                                        }
                                    }
                                }
                            }
                        }

                    }
                }
            }

            Rectangle {
                id: fbStatusWindow
                anchors.fill: parent
                color: "transparent"
                visible: false
                clip: true

                RadialGradient {
                    anchors.fill: parent
                    opacity: 0.7
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "lightgrey" }
                        GradientStop { position: 0.7; color: "black" }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: mouse.accepted = true
                    onWheel: wheel.accepted = true
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 200 * scaleFactor
                    height: 120 * scaleFactor
                    color: "lightgrey"
                    opacity: 0.8
                    radius: 5* scaleFactor
                    border {
                        color: "#4D4D4D"
                        width: 1
                    }

                    Column {
                        anchors {
                            fill: parent
                            margins: 10 * scaleFactor
                        }
                        spacing: 10

                        BusyIndicator {
                            Material.accent:"#00693e"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: fbStatusText
                            font.pixelSize: 16 * scaleFactor
                        }
                    }
                }

                Timer {
                    id: hideWindowTimer
                    onTriggered: fbStatusWindow.visible = false;
                }

                function hideWindow(time) {
                    hideWindowTimer.interval = time;
                    hideWindowTimer.restart();
                }
            }
        }
    }
}
