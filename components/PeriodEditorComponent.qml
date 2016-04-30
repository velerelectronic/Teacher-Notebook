import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors

Common.AbstractEditor {
    id: periodEditorItem

    property string identifier
    property var annotationContent
    property var content

    onContentChanged: {
        var re = /([0-9]{1,4}-[0-9]{1,2}-[0-9]{1,2})|([0-9]{1,2}\:[0-9]{1,2}(?:\:[0-9]{1,2})?)/g;

        var start = new Date();
        var parts = content.start.match(re);
        if ((parts == null) || (parts.length == 0)) {
            startDateCheckbox.checked = false;
        } else {
            startDateCheckbox.checked = true;
            start.fromYYYYMMDDFormat(parts[0]);
            if (parts.length == 1) {
                startTimeCheckbox.checked = false;
            } else {
                startTimeCheckbox.checked = true;
                start.fromHHMMFormat(parts[1]);
            }
        }
        startDate.selectedDate = start;
        startTimePicker.setDateTime(start);

        var end = new Date();
        console.log('content change', content.end);
        var parts = content.end.match(re);
        console.log(parts);
        if ((parts == null) || (parts.length == 0)) {
            endDateCheckbox.checked = false;
        } else {
            endDateCheckbox.checked = true;
            end.fromYYYYMMDDFormat(parts[0]);
            if (parts.length == 1) {
                endTimeCheckbox.checked = false;
            } else {
                endTimeCheckbox.checked = true;
                end.fromHHMMFormat(parts[1]);
            }
        }
        endDate.selectedDate = end;
        endTimePicker.setDateTime(end);

        startReadableText.text = (startDateCheckbox.checked)?((start.toShortReadableDate()) + ((startTimeCheckbox.checked)?(qsTr(" a les ") + start.toTimeSpecificFormat()):'')):qsTr('No especificat');
        endReadableText.text = (endDateCheckbox.checked)?((end.toShortReadableDate()) + ((endTimeCheckbox.checked)?(qsTr(" a les ") + end.toTimeSpecificFormat()):'')):qsTr('No especificat');
    }

    GridLayout {
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

        Calendar {
            id: startDate
            Layout.fillWidth: true
            Layout.preferredHeight: width

            enabled: startDateCheckbox.checked

            onClicked: periodEditorItem.copyContentsToParentEditor()
        }

        Calendar {
            id: endDate

            Layout.fillWidth: true
            Layout.preferredHeight: width

            enabled: endDateCheckbox.checked

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

            function setDateTime(date) {
                startHours.selectedIndex = date.getHours()-1;
                startMinutes.selectedIndex = date.getMinutes() / startMinutes.step;
            }

            function getTime() {
                var date = new Date();
                date.setHours(startHours.selectedIndex + 1);
                date.setMinutes(startMinutes.selectedIndex * startMinutes.step);
                return date;
            }

            Common.WheelClock {
                id: startHours
                anchors.fill: parent
                from: 1
                to: 23
                step: 1
                angleStepOffset: 1
                onSelectedIndexChanged: copyContentsToParentEditor()
            }
            Common.WheelClock {
                id: startMinutes
                anchors.fill: parent
                anchors.margins: units.fingerUnit
                from: 0
                to: 11
                step: 5
                angleStepOffset: 0
                onSelectedIndexChanged: copyContentsToParentEditor()
            }
        }

        /*
        Editors.TimePicker {
            id: startTimePicker

            Layout.fillWidth: true
            Layout.preferredHeight: width

            enabled: startTimeCheckbox.checked

            onUpdatedByUser: periodEditorItem.copyContentsToParentEditor()
        }
        */

        Editors.TimePicker {
            id: endTimePicker

            Layout.fillWidth: true
            Layout.preferredHeight: width

            enabled: endTimeCheckbox.checked

            onUpdatedByUser: periodEditorItem.copyContentsToParentEditor()
        }
    }

    function copyContentsToParentEditor() {
        var start = "";
        if (startDateCheckbox.checked) {
            start = startDate.selectedDate.toYYYYMMDDFormat();
            if (startTimeCheckbox.checked) {
                start +=  " " + startTimePicker.getTime().toHHMMFormat();
            }
        }
        var end = "";
        if (endDateCheckbox.checked) {
            end = endDate.selectedDate.toYYYYMMDDFormat();
            if (endTimeCheckbox.checked) {
                end += " " + endTimePicker.getTime().toHHMMFormat();
            }
        }

        periodEditorItem.annotationContent = {start: start, end: end};
        periodEditorItem.content = {start: start, end: end};
        periodEditorItem.setChanges(true);
    }
}
