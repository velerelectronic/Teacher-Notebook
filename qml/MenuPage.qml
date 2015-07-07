import QtQuick 2.2
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import QtQuick.Controls 1.1
import "qrc:///javascript/Storage.js" as Storage
import PersonalTypes 1.0
import QtGraphicalEffects 1.0

Rectangle {
    id: menuPage
    property string pageTitle: qsTr('Teacher Notebook');

    signal openPage (string page)
    signal openPageArgs (string page, var args)
    signal savedQuickAnnotation(string contents)

    property real buttonWidth: buttonsGrid.cellWidth - 2 * units.nailUnit
    property real buttonHeight: buttonsGrid.cellHeight - 2 * units.nailUnit

    Common.UseUnits { id: units }

    color: 'white'

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
            title: qsTr('Rúbriques')
            onClicked: menuPage.openPage('RubricsList')
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
            title: qsTr('Projectes')
            onClicked: menuPage.openPage('Projects')
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
            title: qsTr('Tasques i esdeveniments')
            onClicked: menuPage.openPage('TasksSystem')
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
            onClicked: menuPage.openPage('AssessmentSystem')
        }

        Common.BigButton {
            width: buttonWidth
            height: buttonHeight
            title: qsTr('Recursos')
            onClicked: menuPage.openPage('ResourceManager')
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
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: 'green'
    }

    Colorize {
        id: backgroundColorize
        anchors.fill: parent
        source: background
        hue: 0.5
        saturation: 0.5
        lightness: 0
        NumberAnimation on hue {
            duration: 250
        }
        NumberAnimation on saturation {
            duration: 250
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

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true

        property real newHue
        property real newSaturation

        property bool ascendingHue: false
        property bool ascendingSaturation: false

        property real initialCoordinateX: 0
        property real initialCoordinateY: 0

        function rotateValues(currentValue,difference,ascending,minValue,maxValue) {
            if (ascending) {
                if (currentValue + difference > maxValue) {
                    return maxValue;
                } else
                    return currentValue + difference;
            } else {
                if (currentValue - difference < minValue) {
                    return minValue;
                } else
                    return currentValue - difference;
            }
        }

        function changeColors() {
            newHue = Math.random() / 100;
            newSaturation = Math.random() / 100;

            backgroundColorize.hue = rotateValues(backgroundColorize.hue,newHue,ascendingHue,0,1);
            backgroundColorize.saturation = rotateValues(backgroundColorize.saturation,newHue,ascendingSaturation,0.5,1);
            if (backgroundColorize.hue==0)
                ascendingHue = true;
            if (backgroundColorize.hue==1)
                ascendingHue = false;
            if (backgroundColorize.saturation==0.5)
                ascendingSaturation = true;
            if (backgroundColorize.saturation==1)
                ascendingSaturation = false;

        }

        onPressed: {
            propagateComposedEvents = true;
            initialCoordinateX = mouseX;
            initialCoordinateY = mouseY;
            changeColors();
        }
        onMouseYChanged: changeColors()
        onMouseXChanged: changeColors()
        onReleased: {
            if (Math.pow(mouseX - initialCoordinateX, 2) + Math.pow(mouseY - initialCoordinateY, 2) > units.fingerUnit) {
                propagateComposedEvents = false;
                mouse.accepted = true;
            } else {
                propagateComposedEvents = true;
                mouse.accepted = false;
            }
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
