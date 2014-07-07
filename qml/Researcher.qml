import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtWebKit 3.0
import 'qrc:///common' as Common

Rectangle {
    id: researcher
    property string pageTitle: qsTr('Recerca');

    anchors.fill: parent
    ColumnLayout {
        anchors.fill: parent

        Rectangle {
            id: navbar
            Layout.fillWidth: true
            height: parent.height / 10
            color: 'grey'
            RowLayout {
                anchors.fill: parent
                Common.SimpleButton {
                    label: qsTr('+ terme');
                    onClicked: {
                        console.log('+ terme');
                        for (var p in webview) {
                            console.log(p + ':' + webview[p]);
                        }

                        console.log(webview.selectedText);
                    }
                }
                Common.SimpleButton {
                    label: qsTr('+ info');
                    onClicked: {
                        console.log('+ info');
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    border.color: 'black'
                    color: 'white'
                    radius: height / 4

                    TextInput {
                        id: urlbar
                        anchors.fill: parent
                        anchors.margins: parent.radius
                        clip: true
                        color: 'black'
                        focus: true
                        text: 'Cerca...'
                        onAccepted: {
                            var schemaRE = /^\w+:/;
                            if (!schemaRE.test(text)) {
                                text = 'https://www.google.es/search?q=' + text;
                            }
                            webview.url = text
                        }
                    }
                }
            }
        }

        WebView {
            id: webview
            Layout.fillWidth: true
            Layout.fillHeight: true
            onNavigationRequested: {
                console.log('Redir...');
                if (request.navigationType == WebView.LinkClickedNavigation) {
                    request.action = WebView.IgnoreRequest
                    console.log(request.url + ':' + request.title);
                }
            }
        }
    }
}
