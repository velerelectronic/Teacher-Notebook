import QtQuick 2.2
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import "qrc:///javascript/Storage.js" as Storage

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
                        font.pixelSize: units.readUnit
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
                            text: Storage.convertNull(model.endDate)
                            font.bold: true
                            font.pixelSize: units.readUnit
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            font.pixelSize: units.readUnit
                            verticalAlignment: Text.AlignVCenter
                            text: Storage.convertNull(model.event)
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

        VisualItemModel {
            id: buttonsModel
            Common.BigButton {
                width: buttonsList.width
                title: qsTr('Anotacions')
                onClicked: menuPage.openPage('AnnotationsList')
            }
            Common.BigButton {
                width: buttonsList.width
                title: qsTr('Agenda')
                onClicked: menuPage.openPage('Schedule')
            }
            Common.BigButton {
                width: buttonsList.width
                title: qsTr('Pissarra')
                onClicked: menuPage.openPage('Whiteboard')
            }
            Common.BigButton {
                width: buttonsList.width
                title: qsTr('Documents')
                onClicked: menuPage.openPage('DocumentsList')
            }
            Common.BigButton {
                width: buttonsList.width
                title: qsTr('! Recerca de coneixement')
                onClicked: menuPage.openPage('Researcher')
            }
            Common.BigButton {
                width: buttonsList.width
                title: qsTr('Exemple PA')
                onClicked: menuPage.openPage('ProgramacioAula')
            }
            Common.BigButton {
                width: buttonsList.width
                title: qsTr('Rellotge')
                onClicked: menuPage.openPage('TimeController')
            }
            Common.BigButton {
                width: buttonsList.width
                title: qsTr('Gestor de dades')
                onClicked: menuPage.openPage('DataMan')
            }
        }

        ListView {
            id: buttonsList
            Layout.fillWidth: true
            Layout.fillHeight: true
            anchors.margins: units.nailUnit
            clip: true
            spacing: units.nailUnit
            model: buttonsModel
        }
    }

}
