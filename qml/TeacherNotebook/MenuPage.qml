import QtQuick 2.0
import QtQuick.Layouts 1.1
import 'common' as Common
import 'Storage.js' as Storage

Rectangle {
    id: menuPage
    property string pageTitle: qsTr('Teacher Notebook');

    signal openPage (string page)
    signal openPageArgs (string page, var args)

    Common.UseUnits { id: units }
    RowLayout {
        anchors.fill: parent
        anchors.margins: units.nailUnit
        spacing: units.nailUnit

        Flow {
            Layout.preferredWidth: parent.width / 2
            Layout.fillHeight: true
            spacing: units.nailUnit

            Common.PreviewBox {
                id: lastAnnotations
                width: parent.width
                Layout.preferredHeight: height

                ListModel {
                    id: annotationsModel
                }
                delegate: Item {
                    width: parent.width
                    height: units.fingerUnit
                    Text {
                        id: textAnnot
                        anchors.fill: parent
                        anchors.margins: units.nailUnit
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        font.pixelSize: units.nailUnit
                        verticalAlignment: Text.AlignVCenter
                        text: '– ' + title + ' ' + desc
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: menuPage.openPageArgs('ShowAnnotation',{idAnnotation: id})
                    }
                }
                caption: qsTr('Darreres anotacions')
                captionBackgroundColor: '#F3F781'
                color: '#F7F8E0'
                totalBackgroundColor: '#F2F5A9'
                maxItems: 3
                prefixTotal: qsTr('Hi ha')
                suffixTotal: qsTr('anotacions')
                onCaptionClicked: menuPage.openPage('AnnotationsList')
                onTotalCountClicked: menuPage.openPage('AnnotationsList')

                Component.onCompleted: {
                    Storage.listAnnotations(annotationsModel,null,'');
                    makeSummary(annotationsModel);
                }
            }
            Common.PreviewBox {
                id: nextEvents
                width: parent.width
                Layout.preferredHeight: height

                ListModel {
                    id: eventsModel
                }
                delegate: Item {
                    width: parent.width
                    height: units.fingerUnit
                    RowLayout {
                        id: textEvents
                        anchors.fill: parent
                        anchors.margins: units.nailUnit

                        Text {
                            Layout.fillHeight: true
                            text: endDate
                            font.bold: true
                            font.pixelSize: units.nailUnit
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            font.pixelSize: units.nailUnit
                            verticalAlignment: Text.AlignVCenter
                            text: event
                        }
                    }
                    MouseArea {
                        anchors.fill: textEvents
                        onClicked: openPageArgs('ShowEvent',{idEvent: id})
                    }
                }
                caption: qsTr("Pròxims terminis")
                captionBackgroundColor: '#F7BE81'
                color: '#F8ECE0'
                totalBackgroundColor: '#F5D0A9'
                maxItems: 3
                prefixTotal: qsTr('Hi ha')
                suffixTotal: qsTr('esdeveniments')
                onCaptionClicked: menuPage.openPage('Schedule')
                onTotalCountClicked: menuPage.openPage('Schedule')

                Component.onCompleted: {
                    Storage.listEvents(eventsModel,null,'',2);
                    makeSummary(eventsModel);
                }
            }
            Item {
                Layout.fillHeight: true
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            anchors.margins: units.nailUnit
            clip: true
            spacing: units.nailUnit / 2
            model: ListModel { id: mainMenuModel }
            // cellHeight: units.fingerUnit * 2 + units.nailUnit * 2
            // cellWidth: units.fingerUnit * 4 + units.nailUnit * 2
            delegate: Rectangle {
                width: parent.width
                height: units.fingerUnit
                // width: units.fingerUnit * 4
                border.color: "green"
                color: "#d5ffcc"
                Text {
                    anchors.centerIn: parent
                    text: title
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: menuPage.openPage(page)
                }
            }

            Component.onCompleted: {
                mainMenuModel.append({title: qsTr('Anotacions'), page: 'AnnotationsList'});
                mainMenuModel.append({title: qsTr('Agenda'), page: 'Schedule'});
                mainMenuModel.append({title: qsTr('Pissarra'), page: 'Whiteboard'});
                mainMenuModel.append({title: qsTr('! Sistema de fitxers'), page: 'Filesystem'});
                mainMenuModel.append({title: qsTr('! Recerca de coneixement'), page: 'Researcher'});
                mainMenuModel.append({title: qsTr('! Document XML'), page: 'XmlViewer'});
                mainMenuModel.append({title: qsTr('! Documents'), page: 'DocumentsList'});
                mainMenuModel.append({title: qsTr('Rellotge'), page: 'TimeController'});
                mainMenuModel.append({title: qsTr('Gestor de dades'), page: 'DataMan'});
            }
        }
    }

}
