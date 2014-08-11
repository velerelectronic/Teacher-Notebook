import QtQuick 2.2
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import QtQuick.Controls 1.1
import "qrc:///javascript/Storage.js" as Storage
import PersonalTypes 1.0

Rectangle {
    id: menuPage
    property string pageTitle: qsTr('Teacher Notebook');

    signal openPage (string page)
    signal openPageArgs (string page, var args)
    signal savedQuickAnnotation(string contents)

    Common.UseUnits { id: units }
    RowLayout {
        anchors.fill: parent
        anchors.margins: units.nailUnit
        spacing: units.nailUnit

        Flow {
            Layout.preferredWidth: parent.width / 2
            Layout.fillHeight: true
            spacing: units.nailUnit * 2

            QuickAnnotation {
                width: parent.width
                onSavedQuickAnnotation: {
                    if (lastAnnotationsModel.insertObject({title: 'Anotació ràpida',desc: contents})) {
                        annotationsTotal.select();
                        annotationWasSaved();
                        menuPage.savedQuickAnnotation(contents);
                    }
                }
            }

            Common.PreviewBox {
                id: lastAnnotations
                width: parent.width
                // Layout.preferredHeight: height

                model: SqlTableModel {
                    id: lastAnnotationsModel
                    tableName: 'annotations'
                    limit: 3
                    Component.onCompleted: {
                        setSort(0,Qt.DescendingOrder);
                        select();
                    }
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
                totalCount: annotationsTotal.count
                suffixTotal: qsTr('anotacions')
                onCaptionClicked: menuPage.openPage('AnnotationsList')
                onTotalCountClicked: menuPage.openPage('AnnotationsList')
            }
            Common.PreviewBox {
                id: nextEvents
                width: parent.width
                // Layout.preferredHeight: height

                model: SqlTableModel {
                    tableName: 'schedule'
                    limit: 3
                    filters: ["ifnull(state,'') != 'done'"]
                    Component.onCompleted: {
                        setSort(6,Qt.AscendingOrder); // Order by end date
                        select();
                    }
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
                            text: model.endDate
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
                            text: model.event
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
                totalCount: scheduleTotal.count
                suffixTotal: qsTr('esdeveniments')
                onCaptionClicked: menuPage.openPage('Schedule')
                onTotalCountClicked: menuPage.openPage('Schedule')
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

    SqlTableModel {
        id: annotationsTotal
        tableName: 'annotations'
        Component.onCompleted: select()
    }
    SqlTableModel {
        id: scheduleTotal
        tableName: 'schedule'
        filters: ["ifnull(state,'') != 'done'"]
        Component.onCompleted: select();
    }
}
