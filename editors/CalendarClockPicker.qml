import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import 'qrc:///common' as Common
import 'qrc:///common/FormatDates.js' as FormatDates

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

        Item {
            width: units.fingerUnit * 5
            height: limitDateOption.height + limitDateOption.height

            CheckBox {
                id: limitDateOption
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                text: qsTr('Especifica data')
                checked: content['date'] != ''
                onCheckedChanged: {
                    if (trackChanges) {
                        datetimeToContent();
                        setChanges(true);
                    }
                }
            }
            Calendar {
                id: limitDatePicker
                anchors {
                    top: limitDateOption.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: (visible)?units.fingerUnit * 4:0

                visible: limitDateOption.checked
                onClicked: {
                    if (trackChanges) {
                        datetimeToContent();
                        editor.setChanges(true);
                    }
                }
            }
        }

        ColumnLayout {
            width: units.fingerUnit * 5 // Math.max(limitDateOption.width,limitTimeOption.width)
            height: limitTimeOption.height
            spacing: units.nailUnit

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
        console.log('DateTimeEditor');
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
