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

    property real buttonWidth: buttonsGrid.cellWidth - 2 * units.nailUnit
    property real buttonHeight: buttonsGrid.cellHeight - 2 * units.nailUnit

    Common.UseUnits { id: units }

    VisualItemModel {
        id: widgetsModel

        QuickAnnotation {
            width: buttonWidth
            height: buttonHeight
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
            width: buttonWidth
            height: buttonHeight

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
                    onClicked: sendSignal('openPageArgs',{page: 'ShowAnnotation', idAnnotation: id})
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
            onCaptionClicked: openPage('AnnotationsList')
            onTotalCountClicked: openPage('AnnotationsList')
        }
        Common.PreviewBox {
            id: nextEvents
            width: buttonWidth
            height: buttonHeight

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

        Common.BigButton {
            width: buttonWidth
            height: buttonHeight
            title: qsTr('Espai de treball')
            onClicked: menuPage.openPage('WorkSpace')
        }

        Common.BigButton {
            width: buttonWidth
            height: buttonHeight
            title: qsTr('Anotacions')
            onClicked: menuPage.openPage('AnnotationsList')
        }
        Common.BigButton {
            width: buttonWidth
            height: buttonHeight
            title: qsTr('Agenda')
            onClicked: menuPage.openPage('Schedule')
        }
        Common.BigButton {
            width: buttonWidth
            height: buttonHeight
            title: qsTr('Pissarra')
            onClicked: menuPage.openPage('Whiteboard')
        }
        Common.BigButton {
            width: buttonWidth
            height: buttonHeight
            title: qsTr('Documents')
            onClicked: menuPage.openPage('DocumentsList')
        }
        Common.BigButton {
            width: buttonWidth
            height: buttonHeight
            title: qsTr('Avaluació')
            onClicked: menuPage.openPage('AssessmentGrid')
        }

        Common.BigButton {
            width: buttonWidth
            height: buttonHeight
            title: qsTr('! Recerca de coneixement')
            onClicked: menuPage.openPage('Researcher')
        }
        Common.BigButton {
            width: buttonWidth
            height: buttonHeight
            title: qsTr('Feeds')
            onClicked: menuPage.openPage('FeedWEIB')
        }
        Common.BigButton {
            width: buttonWidth
            height: buttonHeight
            title: qsTr('Rellotge')
            onClicked: menuPage.openPage('TimeController')
        }
        Common.BigButton {
            width: buttonWidth
            height: buttonHeight
            title: qsTr('Gestor de dades')
            onClicked: menuPage.openPage('DataMan')
        }
        Common.BigButton {
            width: buttonWidth
            height: buttonHeight
            title: qsTr('Calendari')
            onClicked: menuPage.openPage('Calendar')
        }
    }

    GridView {
        id: buttonsGrid

        anchors.fill: parent
        anchors.margins: units.nailUnit

        cellWidth: width / 3
        cellHeight: units.fingerUnit * 6

        model: widgetsModel
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
