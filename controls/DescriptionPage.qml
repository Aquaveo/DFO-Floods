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
                                xhr.open("POST", "https://sheets.googleapis.com/v4/spreadsheets/1cCegrHWHCc5G-BQ9wzH0AtozZlO4e5xvuf547KAlBp8/values/Sheet1!A1%3AH1:append?includeValuesInResponse=true&insertDataOption=INSERT_ROWS&valueInputOption=USER_ENTERED");
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
                                "iss": "dtest-839@dfo-test-267918.iam.gserviceaccount.com",
                                "scope": "https://www.googleapis.com/auth/spreadsheets",
                                "aud": "https://oauth2.googleapis.com/token",
                                "exp": currentDate + 1800,
                                "iat": currentDate
                            }

                            var prvKey = JWS.KEYUTIL.getKey("-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCVj6vURsAPvB23\npFBXP9jujWIXHtSEQt4+KUTlGDBHdQJQ7JbgeZ3AWBHGJYuOm9QM00k/qeQt6iKE\nYZNiSzQo6p25cW5pomsbQA94XDXUGdTsMUZLtIyGpSO/UCisPi5L8o/tFp0Z9cDL\nOAtb31UF1wI/bRdIBvXnITA0HPmuozkSvnd8ZcID8KDymMvEWJqBSUZTrcnbjJme\nNBGMbpm2a+kT3eHv1nV3en518t59jrkg0Y6MHduzufnTd51qHGoh0iwqcLlLBIOH\n8J13HbLSEAA7r5Y0u98IXBU8TGP/l4KUah2Adf9bSihdis1T8ieg2a1SUuAdhwi+\nWTsB2iixAgMBAAECggEADe5WgozeifirSfZHt4DOe5X2y5GHGRTDb8XXUYGZyaYo\nA5KuERWy8H4jlbHcmHmCXHl3yrLP+sji0zLlkBPSNXd5HpNmxfcng9/JMRxhtTJ8\nx01lr1qPdmE+fa0BRN374P4kkuB23Lqr7SH4yON6H3OiFXdbYk2nrRJF06zZQv9z\ntp6EuYJp4GaGGQ0h+uF92xwmGGi+5aGx12D6Xt6K2zydFxR+fFXIsTFBYyIpAzH+\nwXx6biKBwdPiQ6xVqerz8xCjxVY8tO5/taFEdiEAvd/2e80mXNC9JdmXnpzZA7J+\nyD3PfkT5Zg9yhh+RU2JZ4tnEPHwNFTISQBgMHd2ymwKBgQDFsBFIH2U8h3BVn4Ss\nPr1SIKcwxEZxIJRzY1a1y9oVEhSTP9C4IlZVtoN3rVCvuBlhveJLIgdD7871F4fk\ne+YyJf0z/eXXzovLuRNXhWmKOGO1RjWOSVTCWrySqTRgO313O4eos8opI0NFDUn0\nkqK3n76A2Z9XY1yGDEyMQlutIwKBgQDBrXBtB4e1MldNNWDIBXNUGCrEU8GJ5+EV\n5IaE1dMT3RUKkMg3oL5AYZVFCvQpePH/vYyR31g/pKYM6Mh6FBNKlOqi6yR91qr5\nA3lwqR0RT0+5cyzRwqLvh7PfE9GOcokHkCG6bmu66rlNY2oSe3/9Bw4AiF+Yht8c\ngsZeG7LiGwKBgQDDYt/RzuX6S0rl9cHllCT+dTOJ6ZRN34uZ+EcNa6viQ3p+hwY9\n2AJIuRl7QZuL8YN0rX5qD/nqVazRZS50z1iXnCCEMJ/pCkX1VrkdOck0ScOSuQ/Z\nz/SsG45hzkbsDiBVpkrQnNJkkmu8ZgQAbKXSo1pgc7cfYh9ihelqf3OozQKBgDvN\nXgWMaa7dWG+Sp8ubQz0YKTxt0DjQzIOCCLdDfuWHQlP82JW0oIool3q2IyYbHj4l\nPR5dpFYidNNPnXd0c3B4AutDSAVDH4+8LudGkJ8jqi5NDe3G96CWekfLSs19OCqJ\nqqByL/mLOKRYqgwC7kYmw4AOm9Xw7ztSdgXg7585AoGAF8ePzkQQxsOKkWNeHn4t\nlo2/s3C3LGPQ1ZkqFjJ+muVr9+YRHBuW2dOf8lXzPWZptfdqRqCg6eGH1Pj8r0QE\nJ8yyayS2Yt2SmWfFAD2oOx33oSlBKKaZe9RrzHOeuDceHaAh0fPaRLJxaRkvroNE\n8+xgpDA24wC0OPmRrFyljkU=\n-----END PRIVATE KEY-----\n");

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
