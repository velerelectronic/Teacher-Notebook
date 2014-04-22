import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import '../common' as Common

Common.AbstractEditor {
    id: editor
    autoEnableChangeTracking: false

    property var content: {"date": '', "time": ''}

    Common.UseUnits { id: units }

    height: childrenRect.height

    Flow {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: childrenRect.height
        spacing: units.nailUnit

        ColumnLayout {
            width: units.fingerUnit * 5 // Math.max(limitDateOption.width,limitTimeOption.width)
            height: limitDateOption.height + spacing + limitTimeOption.height
            spacing: units.nailUnit

            CheckBox {
                id: limitDateOption
                text: qsTr('Especifica data')
                checked: content['date']!=''
                onCheckedChanged: {
                    if (trackChanges) {
                        datetimeToContent();
                        setChanges(true);
                    }
                }
            }
            CheckBox {
                id: limitTimeOption
                text: qsTr('Especifica hora')
                checked: content['time']!=''
                // If the date is not specified then we don't show the option to change the time
                visible: limitDateOption.checked
                onCheckedChanged: {
                    if (trackChanges) {
                        datetimeToContent();
                        setChanges(true);
                    }
                }
            }
        }

        DatePicker {
            id: limitDatePicker
            // We can choose the date whenever the option has been enabled
            visible: limitDateOption.checked
            onUpdatedByUser: {
                if (trackChanges) {
                    datetimeToContent();
                    editor.setChanges(true);
                }
            }
        }

        TimePicker {
            id: limitTimePicker
            visible: limitTimeOption.visible && limitTimeOption.checked
            onUpdatedByUser: {
                if (trackChanges) {
                    datetimeToContent();
                    editor.setChanges(true);
                }
            }
        }

        Button {
            id: buttonNow
            text: qsTr('Ara')
            visible: limitDateOption.checked
            onClicked: {
                var today = new Date();
                limitDatePicker.setDate(today);
                limitTimePicker.setDateTime(today);
                editor.setChanges(true);
                datetimeToContent();
            }
        }
        Button {
            text: qsTr('Original')
            onClicked: {

            }
        }
        Item {
            Layout.fillWidth: true
        }
    }

    Component.onCompleted: {
        var refDate = new Date();

        limitDatePicker.setDate((editor.content['date']!='')?refDate.fromYYYYMMDDFormat(editor.content['date']):refDate);
        limitTimePicker.setDateTime((editor.content['time']!='')?refDate.fromHHMMFormat(editor.content['time']):refDate);
        enableChangesTracking(true);
    }

    function datetimeToContent() {
        var dateStr = '';
        var timeStr = '';
        if (limitDateOption.checked) {
            dateStr = limitDatePicker.getDate().toYYYYMMDDFormat();
            if (limitTimeOption.checked)
                timeStr = limitTimePicker.getTime().toHHMMFormat();
        }
        editor.content = {date: dateStr, time: timeStr};
    }
}
