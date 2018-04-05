import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import 'qrc:///common' as Common
import 'qrc:///modules/calendar' as Calendar

import "qrc:///common/FormatDates.js" as FormatDates

Item {
    id: annotationsCalendarBaseItem

    signal openCard(string page, var pageProperties, var cardProperties)
    signal saveProperty(string name, var value)

    property alias initialDateString: weeksCalendarView.initialDateString

    Common.UseUnits {
        id: units
    }

    signal timeMarkCreated(string timeMark)

    property string lastSelectedDate: ''
    property int lastSelectedMarkId: -1
    property int lastSelectedAnnotation: -1

    onLastSelectedDateChanged: saveProperty('lastSelectedDate', lastSelectedDate)
    onLastSelectedMarkIdChanged: saveProperty('lastSelectedMarkId', lastSelectedMarkId)
    onLastSelectedAnnotationChanged: saveProperty('lastSelectedAnnotation', lastSelectedAnnotation)

    SimpleAnnotationsModel {
        id: annotationsModel
    }

    AnnotationTimeMarksModel {
        id: mainTimeMarksModel
    }

    AnnotationsWithTimeMarksModel {
        id: mainMarksModel
    }


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
                                    //referenceDate.text = weeksCalendarView.initialDate.toShortReadableDate();
                                    referenceDate.text = weeksCalendarView.firstMonthDate.toShortReadableDate();
                                }
                            }
                        }

                    }

                    Calendar.WeeksView {
                        id: weeksCalendarView

                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        property string todayDate: { return (new Date()).toYYYYMMDDFormat(); }

                        onUpdatedInitialDateString: saveProperty('initialDateString', dateStr)

                        weeksNumber: 5
                        interactive: false
                        daysOverWidget: true

                        onSelectedDate: {
                            setLastSelectedDate(year, month, day);
                            marksListView.positionAtDate(lastSelectedDate);
                        }

                        onLongSelectedDate: {
                            setLastSelectedDate(year, month, day);
                            console.log(lastSelectedDate);
                            createTimeMarkDialog.openTimeMarkDialog(lastSelectedDate);
                        }

                        function setLastSelectedDate(year, month, day) {
                            var date = new Date(year, month, day, 0, 0, 0, 0);
                            lastSelectedDate = date.toYYYYMMDDFormat();
                        }

                        onPeriodChanged: {
                            marksListView.updateTimeMarksList();
                        }

                        subWidget: Rectangle {
                            id: dayCell

                            property int day
                            property int month
                            property int year
                            property string dateStr

                            border.color: '#D7DF01'
                            border.width: (dateStr == lastSelectedDate)?units.nailUnit:0

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: units.nailUnit * 2
                                color: 'green'

                                visible: dateStr == weeksCalendarView.todayDate
                            }

                            AnnotationsWithTimeMarksModel {
                                id: marksModel
                            }

                            Connections {
                                target: annotationsCalendarBaseItem

                                onTimeMarkCreated: {
                                    if (timeMark == dayCell.dateStr) {
                                        dayCell.dateUpdated();
                                    }
                                }
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
                    z: 2

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
                        z: 1

                        width: marksListView.width
                        height: units.fingerUnit * 2

                        color: (section == lastSelectedDate)?Qt.lighter('gray'):'gray'

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit

                            Text {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                verticalAlignment: Text.AlignVCenter

                                font.pixelSize: units.readUnit
                                font.bold: true
                                color: 'white'
                                text: {
                                    var date = new Date();
                                    date.fromYYYYMMDDFormat(section);
                                    return date.toLocaleDateString();
                                }
                            }

                            Common.SuperposedButton {
                                Layout.fillHeight: true
                                size: units.fingerUnit
                                imageSource: 'plus-24844'

                                onClicked: createTimeMarkDialog.openTimeMarkDialog(section)

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
                            text: model.timeMark
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
                            elide: Text.ElideRight
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

                            if ((lastSelectedMarkId > -1) && (lastSelectedAnnotation > -1)) {
                                openCard("simpleannotations/ShowAnnotation", {identifier: lastSelectedAnnotation}, {headingText: qsTr('Anotació')});
                            }

                        }
                    }
                }

                function updateTimeMarksList() {
                    var start = weeksCalendarView.getFirstDate().toYYYYMMDDFormat();
                    var end = weeksCalendarView.getLastDate().toYYYYMMDDFormat();

                    console.log('sten', start, end);
                    mainMarksModel.selectAnnotationsBetweenDates(start, end);
                }

                function positionAtDate(dateStr) {
                    var i=0;
                    var found = false;
                    while ((i<mainMarksModel.count) && (!found)) {
                        var timeMark = mainMarksModel.getObjectInRow(i)['justDate'];
                        if (timeMark == dateStr) {
                            found = true;
                        } else {
                            i++;
                        }
                    }
                    if (found) {
                        marksListView.positionAtIndex(i, ListView.Beginning);
                    }
                }
            }
        }

    }

    MessageDialog {
        id: createTimeMarkDialog

        property string timeMark: ''
        property string readableTimeMark: ''

        title: qsTr('Crear marca de temps')
        text: qsTr("Es crearà una marca de temps per al ") + readableTimeMark + qsTr(". Vols continuar?")

        standardButtons: StandardButton.Yes | StandardButton.No

        function openTimeMarkDialog(timeMark) {
            createTimeMarkDialog.timeMark = timeMark;
            var date = new Date();
            date.fromYYYYMMDDFormat(timeMark);
            readableTimeMark = date.toLongDate();
            open();
        }

        onYes: {
            var annotId = annotationsModel.newAnnotation(qsTr('Anotació per a ') + timeMark, '', 'Calendar');
            if (annotId > -1) {
                var markId = mainTimeMarksModel.insertObject({annotation: annotId, timeMark: timeMark, markType: '', label: '' });
                lastSelectedAnnotation = annotId;
                if (markId > -1) {
                    lastSelectedMarkId = markId;
                }
                timeMarkCreated(timeMark);
            }
        }
    }

}
