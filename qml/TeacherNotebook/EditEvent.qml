import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import "Storage.js" as Storage
import 'common' as Common
import 'common/FormatDates.js' as FormatDates

Common.AbstractEditor {
    id: newEvent
    property string pageTitle: qsTr('Edita esdeveniment')

    signal savedEvent(string event, string desc,date startDate,date startTime,date endDate,date endTime)
    signal canceledEvent(bool changes)

    property int idEvent: -1
    property alias event: event.text
    property alias desc: desc.text
    property string startDate: ''
    property string startTime: ''
    property string endDate: ''
    property string endTime: ''
    property string stateEvent: ''

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
                onTextChanged: newEvent.setChanges(true)
            }
        }
        Text {
            text: qsTr('Estat')
        }
        CheckBox {
            id: eventDoneButton
            Layout.preferredHeight: units.fingerUnit
            text: qsTr('Finalitzat')
            Component.onCompleted: checked = (newEvent.stateEvent == 'done')
            onClicked: {
                newEvent.stateEvent = (checked)?'done':'';
                newEvent.setChanges(true);
            }
        }
        Text {
            text: qsTr('Descripció')
        }
        Rectangle {
            border.color: 'black'
            Layout.fillWidth: true
            Layout.fillHeight: true
            TextArea {
                id: desc
                anchors.fill: parent
                clip: true
                wrapMode: TextInput.WrapAtWordBoundaryOrAnywhere
                font.pixelSize: units.nailUnit
                inputMethodHints: Qt.ImhNoPredictiveText
                onTextChanged: newEvent.setChanges(true)
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
                    onCheckedChanged: newEvent.setChanges(true)
                }
                CheckBox {
                    id: startTimeOption
                    text: specifyTime
                    // If the date is not specified then we don't show the option to change the time
                    visible: startDateOption.checked
                    onCheckedChanged: newEvent.setChanges(true)
                }
            }

            DatePicker {
                id: startDatePicker
                // We can choose the date whenever the option has been enabled
                visible: startDateOption.checked
                onUpdatedByUser: newEvent.setChanges(true)
            }

            TimePicker {
                id: startTimePicker
                visible: startTimeOption.visible && startTimeOption.checked
                onUpdatedByUser: newEvent.setChanges(true)
            }

            Button {
                id: buttonNow
                text: qsTr('Ara')
                visible: startDateOption.checked
                onClicked: {
                    var today = new Date();
                    startDatePicker.setDate(today);
                    startTimePicker.setDateTime(today);
                    newEvent.setChanges(true);
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
                    onCheckedChanged: newEvent.setChanges(true)
                }
                CheckBox {
                    id: endTimeOption
                    text: specifyTime
                    // If the date is not specified then we don't show the option to change the time
                    visible: endDateOption.checked
                    onCheckedChanged: newEvent.setChanges(true)
                }
            }

            DatePicker {
                id: endDatePicker
                visible: endDateOption.checked
                onUpdatedByUser: newEvent.setChanges(true)
            }

            TimePicker {
                id: endTimePicker
                visible: endTimeOption.visible && endTimeOption.checked
                onUpdatedByUser: newEvent.setChanges(true)
            }
            Button {
                text: qsTr('Ara')
                visible: endDateOption.checked
                onClicked: {
                    var today = new Date();
                    endDatePicker.setDate(today);
                    endTimePicker.setDateTime(today);
                    newEvent.setChanges(true);
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
                onClicked: prepareDataAndSave(newEvent.idEvent)
            }
            Button {
                text: qsTr('Cancela')
                Layout.preferredHeight: units.fingerUnit
                onClicked: {
                    var changes = newEvent.changes;
                    newEvent.setChanges(false);
                    newEvent.canceledEvent(changes);
                }
            }
            Button {
                visible: (newEvent.idEvent != -1)
                text: qsTr('Copia')
                Layout.preferredHeight: units.fingerUnit
                onClicked: prepareDataAndSave(-1)
            }
        }
    }
    function prepareDataAndSave(idCode) {
        var startDateStr = (startDateOption.checked)?startDatePicker.getDate().toYYYYMMDDFormat():'';
        var startTimeStr = (startTimeOption.checked)?startTimePicker.getTime().toHHMMFormat():'';
        var endDateStr = (endDateOption.checked)?endDatePicker.getDate().toYYYYMMDDFormat():'';
        var endTimeStr = (endTimeOption.checked)?endTimePicker.getTime().toHHMMFormat():'';
        Storage.saveEvent(idCode,event.text,desc.text,startDateStr,startTimeStr,endDateStr,endTimeStr,newEvent.stateEvent);
        newEvent.setChanges(false);
        newEvent.savedEvent(event.text,desc.text,startDateStr,startTimeStr,endDateStr,endTimeStr);
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
            newEvent.stateEvent = nullToEmpty(details.state);
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

        // Reinit changes
        newEvent.setChanges(false);
    }
}
