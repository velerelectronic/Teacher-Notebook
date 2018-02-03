import QtQuick 2.7
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///modules/calendar' as Calendar

import "qrc:///common/FormatDates.js" as FormatDates

Common.ThreePanesNavigator {
    id: annotationsCalendarBaseItem

    Common.UseUnits {
        id: units
    }

    property string lastSelectedDate: ''
    property int lastSelectedMarkId: -1
    property int lastSelectedAnnotation: -1

    SimpleAnnotationsModel {
        id: annotationsModel
    }

    AnnotationTimeMarksModel {
        id: mainTimeMarksModel
    }

    AnnotationsWithTimeMarksModel {
        id: mainMarksModel
    }

    firstPane: Common.NavigationPane {
        color: Qt.darker('yellow', 1.4)

        onClosePane: openPane('first')

        ColumnLayout {
            anchors.fill: parent
            spacing: units.nailUnit

            GridLayout {
                id: calendarGrid

                anchors.fill: parent

                property bool isHorizontal: calendarGrid.width > calendarGrid.height

                columns: (isHorizontal)?2:1
                rows: (isHorizontal)?1:2

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        anchors.fill: parent

                        Item {
                            id: selectorsRow

                            Layout.fillWidth: true
                            Layout.preferredHeight: units.fingerUnit

                            RowLayout {
                                anchors.fill: parent
                                spacing: units.nailUnit

                                Common.ImageButton {
                                    Layout.preferredWidth: size
                                    size: units.fingerUnit
                                    image: 'arrow-145769'

                                    onClicked: {
                                        weeksCalendarView.decreaseWeek();
                                        referenceDate.text = weeksCalendarView.firstMonthDate.toShortReadableDate();
                                    }
                                }
                                Text {
                                    id: referenceDate

                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    font.pixelSize: units.readUnit
                                    font.bold: true

                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                                    text: {
                                        return weeksCalendarView.initialDate.toShortReadableDate();
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: weeksCalendarView.setTodayDate()
                                    }
                                }
                                Common.ImageButton {
                                    Layout.preferredWidth: size
                                    size: units.fingerUnit
                                    image: 'arrow-145766'

                                    onClicked: {
                                        weeksCalendarView.advanceWeek();
                                        referenceDate.text = weeksCalendarView.initialDate.toShortReadableDate();
                                    }
                                }
                            }

                        }

                        Calendar.WeeksView {
                            id: weeksCalendarView

                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            weeksNumber: 5
                            interactive: false
                            daysOverWidget: true

                            onSelectedDate: {
                                setLastSelectedDate(year, month, day);

                                var start = getFirstDate().toYYYYMMDDFormat();
                                var end = getLastDate().toYYYYMMDDFormat();

                                mainMarksModel.selectAnnotationsBetweenDates(start, end);
                            }

                            onLongSelectedDate: {
                                setLastSelectedDate(year, month, day);
                                console.log(lastSelectedDate);
                                var annotId = annotationsModel.newAnnotation(qsTr('Anotació per a ') + lastSelectedDate, '', 'Calendar');
                                if (annotId > -1) {
                                    var markId = mainTimeMarksModel.insertObject({annotation: annotId, timeMark: lastSelectedDate, markType: '', label: '' });
                                    lastSelectedAnnotation = annotId;
                                    if (markId > -1) {
                                        lastSelectedMarkId = markId;
                                    }
                                }
                            }

                            function setLastSelectedDate(year, month, day) {
                                var date = new Date(year, month, day, 0, 0, 0, 0);
                                lastSelectedDate = date.toYYYYMMDDFormat();
                            }

                            subWidget: Rectangle {
                                id: dayCell

                                property int day
                                property int month
                                property int year
                                property string dateStr

                                border.color: '#D7DF01'
                                border.width: (dateStr == lastSelectedDate)?units.nailUnit:0

                                AnnotationsWithTimeMarksModel {
                                    id: marksModel
                                }

                                function dateUpdated() {
                                    var date = new Date(year, month, day, 0, 0, 0, 0);
                                    dayCell.dateStr = date.toYYYYMMDDFormat();
                                    getTimeMarks(dayCell.dateStr);
                                }

                                function getTimeMarks(dateStr) {
                                    marksModel.selectAnnotations(dateStr);
                                    var c = marksModel.count

                                    if (c == 0) {
                                        dayCell.color = 'white';
                                    } else {
                                        if (c == 1) {
                                            dayCell.color = 'yellow';
                                        } else {
                                            if (c>10) {
                                                dayCell.color = 'red';
                                            } else {
                                                dayCell.color = 'orange';
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }


                Common.GeneralListView {
                    id: marksListView

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    model: mainMarksModel

                    toolBarHeight: 0
                    headingBar: Rectangle {
                        color: '#DDFFDD'

                        RowLayout {
                            anchors.fill: parent
                            Text {
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width / 4

                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.pixelSize: units.readUnit
                                font.bold: true
                                text: qsTr('Temps')
                            }
                            Text {
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width / 4

                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.pixelSize: units.readUnit
                                font.bold: true
                                text: qsTr('Tipus')
                            }
                            Text {
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width / 4

                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.pixelSize: units.readUnit
                                font.bold: true
                                text: qsTr('Etiqueta')
                            }
                            Text {
                                Layout.fillHeight: true
                                Layout.fillWidth: true

                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.pixelSize: units.readUnit
                                font.bold: true
                                text: qsTr('Anotació')
                            }
                        }
                    }

                    sectionProperty: 'justDate'
                    sectionCriteria: ViewSection.FullString
                    sectionDelegate: sectionHeading

                    Component {
                        id: sectionHeading

                        Rectangle {
                            width: marksListView.width
                            height: units.fingerUnit * 2

                            color: 'gray'

                            Text {
                                anchors.fill: parent
                                anchors.margins: units.nailUnit
                                verticalAlignment: Text.AlignVCenter

                                font.pixelSize: units.readUnit
                                font.bold: true
                                color: 'white'
                                text: {
                                    var date = new Date();
                                    date.fromYYYYMMDDFormat(section);
                                    return date.toLongDate();
                                }
                            }
                        }
                    }

                    delegate: Rectangle {
                        width: marksListView.width
                        height: units.fingerUnit * 4

                        color: (model.markId == lastSelectedMarkId)?'yellow':'white'

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
                            spacing: units.nailUnit

                            Text {
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width / 4

                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.pixelSize: units.readUnit
                                text: model.timeMark + "->" + model.justDate
                            }
                            Text {
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width / 4

                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.pixelSize: units.readUnit

                                text: model.markType
                            }
                            Text {
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width / 4

                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.pixelSize: units.readUnit
                                elide: Text.ElideRight
                                text: model.markLabel
                            }
                            Text {
                                Layout.fillHeight: true
                                Layout.fillWidth: true

                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.pixelSize: units.readUnit
                                text: '<p><b>' + model.annotationTitle + '</b></p><p>' + model.annotationDesc + '</p>'
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                lastSelectedMarkId = -1;
                                // the following order of assignments is important
                                lastSelectedAnnotation = model.annotationId;
                                lastSelectedMarkId = model.markId;
                            }
                        }
                    }

                }
            }

        }

    }

    secondPane: Common.NavigationPane {
        id: secondNavigationPane

        onClosePane: {
            console.log('closeeee');
            secondComponent = null;
            openPane('first');
        }

        Loader {
            id: secondPaneLoader

            anchors.fill: parent

            sourceComponent: secondComponent

            Connections {
                target: annotationsCalendarBaseItem

                onLastSelectedMarkIdChanged: {
                    if ((lastSelectedMarkId > -1) && (lastSelectedAnnotation > -1)) {
                        secondPaneLoader.sourceComponent = null;
                        secondPaneLoader.setSource("ShowAnnotation.qml", {identifier: lastSelectedAnnotation});
                        openPane("second");
                    }
                }
            }
        }
    }
}
