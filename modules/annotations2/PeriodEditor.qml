import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
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

    signal periodEndChanged()
    signal periodStartChanged()

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
        console.log('setting', startString, endString);

        var startObj = acquireDateAndTime((startString !== null)?startString:'');
        startDateObject = startObj.object;
        startDateIsDefined = startObj.dateDefined;
        startTimeIsDefined = startObj.timeDefined;

        var endObj = acquireDateAndTime((endString !== null)?endString:'');
        endDateObject = endObj.object;
        endDateIsDefined = endObj.dateDefined;
        endTimeIsDefined = endObj.timeDefined;

        printDateTime();
    }

    function printDateTime() {
        startDateText.text = (startDateIsDefined)?(startDateObject.toLongDate()):qsTr('No definit');
        startTimeText.text = (startTimeIsDefined)?(startDateObject.toHHMMFormat()):qsTr('No definit');

        endDateText.text = (endDateIsDefined)?(endDateObject.toLongDate()):qsTr('No definit');
        endTimeText.text = (endTimeIsDefined)?(endDateObject.toHHMMFormat()):qsTr('No definit');
    }

    GridLayout {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: childrenRect.height

        columns: 3
        columnSpacing: units.fingerUnit
        rowSpacing: units.fingerUnit
        rows: 4
        flow: GridLayout.TopToBottom

        Text {
            Layout.preferredHeight: units.fingerUnit * 4
            Layout.preferredWidth: parent.width / 3
            Layout.rowSpan: 2

            font.pixelSize: units.readUnit
            font.bold: true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: qsTr('Comença')
        }
        Text {
            Layout.preferredHeight: units.fingerUnit * 4
            Layout.preferredWidth: parent.width / 3
            Layout.rowSpan: 2

            font.pixelSize: units.readUnit
            font.bold: true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: qsTr('Acaba')
        }
        Text {
            id: startDateText
            Layout.preferredHeight: units.fingerUnit * 2
            Layout.fillWidth: true
            font.pixelSize: units.readUnit
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
        Text {
            id: startTimeText
            Layout.preferredHeight: units.fingerUnit * 2
            Layout.fillWidth: true
            font.pixelSize: units.readUnit
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
        Text {
            id: endDateText
            Layout.preferredHeight: units.fingerUnit * 2
            Layout.fillWidth: true
            font.pixelSize: units.readUnit
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
        Text {
            id: endTimeText
            Layout.preferredHeight: units.fingerUnit * 2
            Layout.fillWidth: true
            font.pixelSize: units.readUnit
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
        Button {
            //Layout.preferredHeight: units.fingerUnit * 4
            //Layout.preferredWidth: parent.height / 3
            Layout.fillHeight: true
            Layout.preferredWidth: units.fingerUnit * 4

            Layout.rowSpan: 2

            text: qsTr('Canvia')

            onClicked: {
                if (startDateIsDefined)
                    periodChangeDialog.openStartChange();
                else
                    dateChangeDialog.openStartDateSelector();
            }
        }
        Button {
            Layout.fillHeight: true
            Layout.preferredWidth: units.fingerUnit * 4
            Layout.rowSpan: 2

            text: qsTr('Canvia')

            onClicked: {
                if (endDateIsDefined)
                    periodChangeDialog.openEndChange();
                else
                    dateChangeDialog.openEndDateSelector();
            }
        }
    }

    Common.SuperposedMenu {
        id: periodChangeDialog

        title: qsTr('Canvia')

        property bool isStart

        function openStartChange() {
            title = qsTr('Canvia inici');
            isStart = true;
            open();
        }

        function openEndChange() {
            title = qsTr('Canvia final');
            isStart = false;
            open();
        }

        Common.SuperposedMenuEntry {
            text: qsTr('Ajorna un dia')
            onClicked: {
                if (periodChangeDialog.isStart) {
                    startDateObject.setDate(startDateObject.getDate()+1);
                    printDateTime();
                    periodStartChanged();
                } else {
                    endDateObject.setDate(endDateObject.getDate()+1);
                    printDateTime();
                    periodEndChanged();
                }
                periodChangeDialog.close();
            }
        }
        Common.SuperposedMenuEntry {
            text: qsTr('Ajorna una setmana')
            onClicked: {
                if (periodChangeDialog.isStart) {
                    startDateObject.setDate(startDateObject.getDate()+7);
                    printDateTime();
                    periodStartChanged();
                } else {
                    endDateObject.setDate(endDateObject.getDate()+7);
                    printDateTime();
                    periodEndChanged();
                }
                periodChangeDialog.close();
            }
        }
        Common.SuperposedMenuEntry {
            text: qsTr('Ajorna un mes')
            onClicked: {
                if (periodChangeDialog.isStart) {
                    startDateObject.setMonth(startDateObject.getMonth()+1);
                    printDateTime();
                    periodStartChanged();
                } else {
                    endDateObject.setMonth(endDateObject.getMonth()+1);
                    printDateTime();
                    periodEndChanged();
                }
                periodChangeDialog.close();
            }
        }
        Common.SuperposedMenuEntry {
            text: qsTr('Ajorna un any')
            onClicked: {
                if (periodChangeDialog.isStart) {
                    startDateObject.setFullYear(startDateObject.getFullYear()+1);
                    printDateTime();
                    periodStartChanged();
                } else {
                    endDateObject.setFullYear(endDateObject.getFullYear()+1);
                    printDateTime();
                    periodEndChanged();
                }
                periodChangeDialog.close();
            }
        }
        Rectangle {
            height: units.nailUnit
            width: parent.width
            color: 'gray'
        }

        Common.SuperposedMenuEntry {
            text: qsTr('Tria una data')

            onClicked: {
                periodChangeDialog.close();
                if (periodChangeDialog.isStart) {
                    dateChangeDialog.openStartDateSelector();
                } else {
                    dateChangeDialog.openEndDateSelector();
                }
            }
        }
        Common.SuperposedMenuEntry {
            text: qsTr('Esborra data')
            onClicked: {
                if (periodChangeDialog.isStart) {
                    startDateIsDefined = false;
                    startTimeIsDefined = false;
                } else {
                    endDateIsDefined = false;
                    endTimeIsDefined = false;
                }
                printDateTime();
                periodStartChanged();
                periodEndChanged();
                periodChangeDialog.close();
            }
        }
        Rectangle {
            height: units.nailUnit
            width: parent.width
            color: 'gray'
        }
        Common.SuperposedMenuEntry {
            text: qsTr('Tria una hora')

            onClicked: {
                periodChangeDialog.close();
                if (periodChangeDialog.isStart) {
                    timeChangeDialog.openStartTimeSelector();
                } else {
                    timeChangeDialog.openEndTimeSelector();
                }
            }
        }
        Common.SuperposedMenuEntry {
            text: qsTr('Esborra hora')
            onClicked: {
                if (periodChangeDialog.isStart) {
                    startTimeIsDefined = false;
                } else {
                    endTimeIsDefined = false;
                }
                printDateTime();
                periodStartChanged();
                periodEndChanged();
                periodChangeDialog.close();
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
                    startDateObject.setDate(date.getDate());
                    startDateObject.setMonth(date.getMonth());
                    startDateObject.setFullYear(date.getFullYear());
                    startDateIsDefined = true;
                    printDateTime();
                    periodStartChanged();
                } else {
                    endDateObject.setDate(date.getDate());
                    endDateObject.setMonth(date.getMonth());
                    endDateObject.setFullYear(date.getFullYear());
                    endDateIsDefined = true;
                    printDateTime();
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

    function getStartDateString() {
        var startString = "";
        if (startDateIsDefined) {
            startString += startDateObject.toYYYYMMDDFormat();
            if (startTimeIsDefined) {
                startString += " " + startDateObject.toHHMMFormat();
            }
        }
        return startString;
    }

    function getEndDateString() {
        var endString = "";
        if (endDateIsDefined) {
            endString += endDateObject.toYYYYMMDDFormat();
            if (endTimeIsDefined) {
                endString += " " + endDateObject.toHHMMFormat();
            }
        }
        return endString;
    }
}
