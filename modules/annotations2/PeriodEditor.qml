import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQml.Models 2.3
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors

Common.AbstractEditor {
    id: periodEditorItem

    Common.UseUnits {
        id: units
    }

    property var resultContent

    property var startDateObject
    property bool startDateIsDefined: false
    property bool startTimeIsDefined: false
    property var endDateObject
    property bool endDateIsDefined: false
    property bool endTimeIsDefined: false

    property string selectedStartDate: ''
    property string selectedEndDate: ''
    property string selectedStartTime: ''
    property string selectedEndTime: ''

    signal periodEndChanged()
    signal periodStartChanged()

    GridLayout {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: units.nailUnit
        }
        height: childrenRect.height

        columns: 2
        rows: 7
        rowSpacing: 0
        columnSpacing: 0
        flow: GridLayout.LeftToRight

        Text {
            Layout.preferredHeight: units.fingerUnit * 2
            Layout.preferredWidth: parent.width / 3

            font.bold: true
            text: qsTr('Actual:')
        }

        ReperiodDisplay {
            id: actualDateDisplayItem

            Layout.preferredHeight: units.fingerUnit * 2
            Layout.fillWidth: true

            selectedStartDate: periodEditorItem.selectedStartDate
            selectedEndDate: periodEditorItem.selectedEndDate

            onStartDateSelected: periodEditorItem.selectedStartDate = date
            onEndDateSelected: periodEditorItem.selectedEndDate = date
        }

        Text {
            Layout.preferredHeight: units.fingerUnit * 2
            Layout.preferredWidth: parent.width / 3

            font.bold: true
            text: qsTr('Avui:')
        }

        ReperiodDisplay {
            id: todayDateDisplayItem

            Layout.preferredHeight: units.fingerUnit * 2
            Layout.fillWidth: true

            selectedStartDate: periodEditorItem.selectedStartDate
            selectedEndDate: periodEditorItem.selectedEndDate

            onStartDateSelected: periodEditorItem.selectedStartDate = date
            onEndDateSelected: periodEditorItem.selectedEndDate = date
        }

        Text {
            Layout.preferredHeight: units.fingerUnit * 2
            Layout.preferredWidth: parent.width / 3

            font.bold: true
            text: qsTr('Una setmana després')
        }

        ReperiodDisplay {
            id: weekDateDisplayItem

            Layout.preferredHeight: units.fingerUnit * 2
            Layout.fillWidth: true

            selectedStartDate: periodEditorItem.selectedStartDate
            selectedEndDate: periodEditorItem.selectedEndDate

            onStartDateSelected: periodEditorItem.selectedStartDate = date
            onEndDateSelected: periodEditorItem.selectedEndDate = date
        }

        Text {
            Layout.preferredHeight: units.fingerUnit * 2
            Layout.preferredWidth: parent.width / 3

            font.bold: true
            text: qsTr('Un mes després:')
        }

        ReperiodDisplay {
            id: monthDateDisplayItem

            Layout.preferredHeight: units.fingerUnit * 2
            Layout.fillWidth: true

            selectedStartDate: periodEditorItem.selectedStartDate
            selectedEndDate: periodEditorItem.selectedEndDate

            onStartDateSelected: periodEditorItem.selectedStartDate = date
            onEndDateSelected: periodEditorItem.selectedEndDate = date
        }

        Text {
            Layout.preferredHeight: units.fingerUnit * 2
            Layout.preferredWidth: parent.width / 3

            font.bold: true
            text: qsTr('Un any després:')
        }

        ReperiodDisplay {
            id: yearDateDisplayItem

            Layout.preferredHeight: units.fingerUnit * 2
            Layout.fillWidth: true

            selectedStartDate: periodEditorItem.selectedStartDate
            selectedEndDate: periodEditorItem.selectedEndDate

            onStartDateSelected: periodEditorItem.selectedStartDate = date
            onEndDateSelected: periodEditorItem.selectedEndDate = date
        }

        Text {
            Layout.preferredHeight: units.fingerUnit * 2
            Layout.preferredWidth: parent.width / 3

            font.bold: true
            text: qsTr('Una altra data:')
        }

        ReperiodDisplay {
            id: otherDateDisplayItem

            Layout.preferredHeight: units.fingerUnit * 2
            Layout.fillWidth: true

            selectedStartDate: periodEditorItem.selectedStartDate
            selectedEndDate: periodEditorItem.selectedEndDate

            onStartDateSelected: {
                dateChangeDialog.openStartDateSelector();
            }

            onEndDateSelected: {
                dateChangeDialog.openEndDateSelector();
            }
        }

        Text {
            Layout.preferredHeight: units.fingerUnit * 2
            Layout.preferredWidth: parent.width / 3

            font.bold: true
            text: qsTr('Esborra:')
        }

        Item {
            Layout.preferredHeight: units.fingerUnit * 2
            Layout.fillWidth: true

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    color: (selectedStartDate == '')?'yellow':'white'

                    Text {
                        anchors.fill: parent

                        padding: units.nailUnit
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                        text: qsTr('Sense inici')
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: selectedStartDate = ''
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    color: (selectedEndDate == '')?'yellow':'white'

                    Text {
                        anchors.fill: parent

                        padding: units.nailUnit
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                        text: qsTr('Sense final')
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: selectedEndDate = ''
                    }
                }
            }
        }

    }

    Common.SuperposedMenu {
        id: dateChangeDialog

        property bool isStart
        standardButtons: StandardButton.Cancel

        function openStartDateSelector() {
            isStart = true;
            calendarPicker.selectedDate = (startDateIsDefined)?startDateObject:(new Date());
            open();
        }

        function openEndDateSelector() {
            isStart = false;
            calendarPicker.selectedDate = (endDateIsDefined)?endDateObject:(new Date());
            open();
        }

        Calendar {
            id: calendarPicker

            onClicked: {
                var date = calendarPicker.selectedDate;
                if (dateChangeDialog.isStart) {
                    selectedStartDate = date.toYYYYMMDDFormat();
                    otherDateDisplayItem.setContent(date, null);
                    periodStartChanged();
                } else {
                    selectedEndDate = date.toYYYYMMDDFormat();
                    otherDateDisplayItem.setContent(null, date);
                    periodEndChanged();
                }
                dateChangeDialog.close();
            }
        }
    }

    Common.SuperposedMenu {
        id: timeChangeDialog

        property bool isStart
        standardButtons: StandardButton.Save | StandardButton.Cancel

        function openStartTimeSelector() {
            isStart = true;
            open();
        }

        function openEndTimeSelector() {
            isStart = false;
            open();
        }

        Editors.TimePicker {
            id: timePicker
        }

        onAccepted: {
            var time = timePicker.getTime();
            if (timeChangeDialog.isStart) {
                startTimeIsDefined = true;
                startDateObject.setHours(time.getHours());
                startDateObject.setMinutes(time.getMinutes());
                startDateObject.setSeconds(time.getSeconds());
                printDateTime();
                periodStartChanged();
            } else {
                endTimeIsDefined = true;
                endDateObject.setHours(time.getHours());
                endDateObject.setMinutes(time.getMinutes());
                endDateObject.setSeconds(time.getSeconds());
                printDateTime();
                periodEndChanged();
            }
        }
    }

    GridLayout {
        visible: false
        anchors.fill: parent
        columns: 2
        columnSpacing: units.fingerUnit
        Text {
            Layout.preferredHeight: units.fingerUnit
            Layout.fillWidth: true
            font.pixelSize: units.readUnit
            font.bold: true
            text: qsTr('Inici')
        }
        Text {
            Layout.preferredHeight: units.fingerUnit
            Layout.fillWidth: true
            font.pixelSize: units.readUnit
            font.bold: true
            text: qsTr('Final')
        }
        Text {
            id: startReadableText
            Layout.preferredHeight: contentHeight
            Layout.fillWidth: true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.pixelSize: units.readUnit
        }

        Text {
            id: endReadableText
            Layout.preferredHeight: contentHeight
            Layout.fillWidth: true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.pixelSize: units.readUnit
        }

        CheckBox {
            id: startDateCheckbox
            text: qsTr('Especificar data')

            onClicked: periodEditorItem.copyContentsToParentEditor()
        }

        CheckBox {
            id: endDateCheckbox
            text: qsTr('Especificar data')

            onClicked: periodEditorItem.copyContentsToParentEditor()
        }

        CheckBox {
            id: startTimeCheckbox
            enabled: startDateCheckbox.checked
            text: qsTr('Especificar hora')

            onClicked: periodEditorItem.copyContentsToParentEditor()
        }

        CheckBox {
            id: endTimeCheckbox
            enabled: endDateCheckbox.checked
            text: qsTr('Especificar hora')

            onClicked: periodEditorItem.copyContentsToParentEditor()
        }

        Item {
            id: startTimePicker
            Layout.fillWidth: true
            Layout.preferredHeight: width

            property bool switchHours: true

            function setDateTime(date) {
                startHours.selectedIndex = date.getHours()-1;
                startMinutes.selectedIndex = date.getMinutes() / startMinutes.step;
            }

            function getTime() {
                var date = new Date();
                date.setHours(startHours.selectedIndex + 1);
                date.setMinutes(((startMinutes.selectedIndex>-1)?startMinutes.selectedIndex:0) * startMinutes.step);
                return date;
            }

            Common.WheelClock {
                id: startHours
                anchors.fill: parent

                visible: startTimePicker.switchHours
                from: 1
                to: 23
                step: 1
                angleStepOffset: 1
                onSelectedIndexChanged: {
                    copyContentsToParentEditor();
                    startTimePicker.switchHours = false;
                }
            }
            Common.WheelClock {
                id: startMinutes
                anchors.fill: parent

                visible: !startTimePicker.switchHours
                from: 0
                to: 11
                step: 5
                angleStepOffset: 0
                onSelectedIndexChanged: {
                    copyContentsToParentEditor();
                    startTimePicker.switchHours = true;
                }
            }
        }

    }

    function acquireDateAndTime(dateTimeString) {
        // It returns:
        // * Object: date Object
        // * dateDefined: true if object contains a valid date
        // * timeDefined: true if object contains both valid date and time

        var returnObject = new Date();
        var returnDateDefined = false;
        var returnTimeDefined = false;

        var re = /([0-9]{1,4}-[0-9]{1,2}-[0-9]{1,2})|([0-9]{1,2}\:[0-9]{1,2}(?:\:[0-9]{1,2})?)/g;

        var parts = dateTimeString.match(re);

        if ((parts !== null) && (parts.length > 0)) {
            returnObject.fromYYYYMMDDFormat(parts[0]);
            returnDateDefined = true;
            if (parts.length > 1) {
                returnObject.fromHHMMFormat(parts[1]);
                returnTimeDefined = true;
            }
        }
        return {
            object: returnObject,
            dateDefined: returnDateDefined,
            timeDefined: returnTimeDefined
        };
    }

    function setContent(startString, endString) {
        var startObj = acquireDateAndTime((startString !== null)?startString:'');
        startDateObject = startObj.object;
        startDateIsDefined = startObj.dateDefined;
        startTimeIsDefined = startObj.timeDefined;

        var endObj = acquireDateAndTime((endString !== null)?endString:'');
        endDateObject = endObj.object;
        endDateIsDefined = endObj.dateDefined;
        endTimeIsDefined = endObj.timeDefined;


        // Select current date

        if (startDateIsDefined) {
            selectedStartDate = startDateObject.toYYYYMMDDFormat();

            // Keep same defined time for start and end

            if (startTimeIsDefined) {
                selectedStartTime = startDateObject.toHHMMFormat();
            }
        }
        if (endDateIsDefined) {
            selectedEndDate = endDateObject.toYYYYMMDDFormat();

            // Keep same defined time for start and end

            if (endTimeIsDefined) {
                selectedEndTime = endDateObject.toHHMMFormat();
            }
        }

        printDateTime();
    }


    function printDateTime() {
        // Print today
        var today = new Date();
        todayDateDisplayItem.setContent(today, today);

        // Set start and end dates that are current dates if defined or today if current dates have not been set yet.

        var generalStartDate = new Date();
        var generalEndDate = new Date();

        // Print actual date, if defined
        if (startDateIsDefined) {
            generalStartDate.copyDate(startDateObject);
            actualDateDisplayItem.setContent(generalStartDate, null);
        } else {
            actualDateDisplayItem.setContent('', null);
        }

        if (endDateIsDefined) {
            generalEndDate.copyDate(endDateObject);
            actualDateDisplayItem.setContent(null, generalEndDate);
        } else {
            actualDateDisplayItem.setContent(null, '');
        }

        // Print a week afterwards

        generalStartDate.setDate(generalStartDate.getDate() + 7);
        generalEndDate.setDate(generalEndDate.getDate() + 7);
        weekDateDisplayItem.setContent(generalStartDate, generalEndDate);

        // Print a month afterwards

        generalStartDate.setDate(generalStartDate.getDate() - 7);
        generalStartDate.setMonth(generalStartDate.getMonth() + 1);
        generalEndDate.setDate(generalEndDate.getDate() - 7);
        generalEndDate.setMonth(generalEndDate.getMonth() + 1);
        monthDateDisplayItem.setContent(generalStartDate, generalEndDate);

        // Print a year afterwards

        generalStartDate.setMonth(generalStartDate.getMonth() - 1);
        generalStartDate.setFullYear(generalStartDate.getFullYear() + 1);
        generalEndDate.setMonth(generalEndDate.getMonth() - 1);
        generalEndDate.setFullYear(generalEndDate.getFullYear() + 1);
        yearDateDisplayItem.setContent(generalStartDate, generalEndDate);
    }

    function getStartDateString() {
        return selectedStartDate + ((selectedStartTime == '')?'':(' ' + startDateObject.toHHMMFormat()));
    }

    function getEndDateString() {
        return selectedEndDate + ((selectedEndTime == '')?'':(' ' + endDateObject.toHHMMFormat()));
    }
}
