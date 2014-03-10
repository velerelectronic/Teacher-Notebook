import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import "Storage.js" as Storage
import 'common' as Common
import 'common/FormatDates.js' as FormatDates

Rectangle {
    id: newEvent
    property string pageTitle: qsTr('Edita esdeveniment')

    signal savedEvent(string event, string desc,date startDate,date startTime,date endDate,date endTime)
    signal canceledEvent()
    property int idEvent: -1
    property alias event: event.text
    property alias desc: desc.text
    property string startDate: ''
    property string startTime: ''
    property string endDate: ''
    property string endTime: ''

    property string specifyDate: qsTr('Especifica data')
    property string specifyTime: qsTr('Especifica hora')

    Common.UseUnits { id: units }

    GridLayout {
        anchors.fill: parent
        anchors.margins: units.nailUnit
        columns: 2
        Text {
            text:qsTr('Esdeveniment o tasca')
            font.pointSize: 28
            Layout.columnSpan: 2
        }

        Text {
            text: qsTr('Esdeveniment')
        }
        Rectangle {
            border.color: 'black'
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height
            TextInput {
                id: event
                anchors.left: parent.left
                anchors.right: parent.right
                clip: true
                font.pixelSize: units.fingerUnit
                wrapMode: TextInput.WrapAtWordBoundaryOrAnywhere
                inputMethodHints: Qt.ImhNoPredictiveText
            }
        }
        Text {
            text: qsTr('Descripció')
        }
        Rectangle {
            border.color: 'black'
            Layout.fillWidth: true
            Layout.fillHeight: true
            TextInput {
                id: desc
                anchors.fill: parent
                clip: true
                wrapMode: TextInput.WrapAtWordBoundaryOrAnywhere
                font.pixelSize: units.nailUnit
                inputMethodHints: Qt.ImhNoPredictiveText
            }
        }
        Text {
            id: labelStart
            text: qsTr('Inici')
        }

        Flow {
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height
            spacing: units.nailUnit

            ColumnLayout {
                width: childrenRect.width
                height: childrenRect.height
                spacing: units.nailUnit

                CheckBox {
                    id: startDateOption
                    text: specifyDate
                }
                CheckBox {
                    id: startTimeOption
                    text: specifyTime
                    // If the date is not specified then we don't show the option to change the time
                    visible: startDateOption.checked
                }
            }

            DatePicker {
                id: startDatePicker
                // We can choose the date whenever the option has been enabled
                visible: startDateOption.checked
            }

            TimePicker {
                id: startTimePicker
                visible: startTimeOption.visible && startTimeOption.checked
            }

            Button {
                id: buttonNow
                text: qsTr('Ara')
                visible: startDateOption.checked
                onClicked: {
                    var today = new Date();
                    startDatePicker.setDate(today);
                    startTimePicker.setDate(today);
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
        Text {
            text: qsTr('Final')
        }

        Flow {
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height
            spacing: units.nailUnit

            ColumnLayout {
                width: childrenRect.width
                height: childrenRect.height
                spacing: units.nailUnit

                CheckBox {
                    id: endDateOption
                    text: specifyDate
                }
                CheckBox {
                    id: endTimeOption
                    text: specifyTime
                    // If the date is not specified then we don't show the option to change the time
                    visible: endDateOption.checked
                }
            }

            DatePicker {
                id: endDatePicker
                visible: endDateOption.checked
            }

            TimePicker {
                id: endTimePicker
                visible: endTimeOption.visible && endTimeOption.checked
            }
            Button {
                text: qsTr('Ara')
                visible: endDateOption.checked
                onClicked: {
                    var today = new Date();
                    endDatePicker.setDate(today);
                    endTimePicker.setDate(today);
                }
            }
            Button {
                text: qsTr('Original')
                onClicked: {

                }
            }

            Item { Layout.fillWidth: true }
        }

        Text { text: ' '}

        RowLayout {
            Layout.preferredHeight: childrenRect.height
            Button {
                text: qsTr('Desa')
                Layout.preferredHeight: units.fingerUnit
                onClicked: {
                    var startDateStr = (startDateOption.checked)?startDatePicker.getDate().toYYYYMMDDFormat():'';
                    var startTimeStr = (startTimeOption.checked)?startTimePicker.getTime().toHHMMFormat():'';
                    var endDateStr = (endDateOption.checked)?endDatePicker.getDate().toYYYYMMDDFormat():'';
                    var endTimeStr = (endTimeOption.checked)?endTimePicker.getTime().toHHMMFormat():'';
                    Storage.saveEvent(event.text,desc.text,startDateStr,startTimeStr,endDateStr,endTimeStr);
                    newEvent.savedEvent(event.text,desc.text,startDateStr,startTimeStr,endDateStr,endTimeStr);
                }
            }
            Button {
                text: qsTr('Cancela')
                Layout.preferredHeight: units.fingerUnit
                onClicked: newEvent.close()
            }
        }
    }
    function close() {
        if (newEvent.state != 'closing') {
            newEvent.state = 'closing';
            newEvent.canceledEvent();
            return false;
        } else {
            return true;
        }
    }
    Component.onCompleted: {
        function nullToEmpty(arg) {
            return (arg)?arg:'';
        }

        if (newEvent.idEvent != -1) {
            var details = Storage.getDetailsEventId(newEvent.idEvent);
            console.log('Details ' + JSON.stringify(details));
            newEvent.event = nullToEmpty(details.event);
            newEvent.desc = nullToEmpty(details.desc);
            newEvent.startDate = nullToEmpty(details.startDate);
            newEvent.startTime = nullToEmpty(details.startTime);
            newEvent.endDate = nullToEmpty(details.endDate);
            newEvent.endTime = nullToEmpty(details.endTime);
        }
        var start = new Date();
        var end = new Date();

        console.log('SD: ' + startDate + ' ST: ' + startTime + ' ED: ' + endDate + ' ET: ' + endTime);
        startDatePicker.setDate((startDate!='')?start.fromYYYYMMDDFormat(startDate):start);
        startDateOption.checked = (startDate!='');

        startTimePicker.setDateTime((startTime!='')?start.fromHHMMFormat(startTime):start);
        startTimeOption.checked = (startTime!='');

        endDatePicker.setDate((endDate!='')?end.fromYYYYMMDDFormat(endDate):end);
        endDateOption.checked = (endDate!='');

        endTimePicker.setDateTime((endTime!='')?end.fromHHMMFormat(endTime):end);
        endTimeOption.checked = (endTime!='');
    }
}
