import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors

CollectionInspectorItem {
    id: editState

    Common.UseUnits { id: units }

    clip: true

    visorComponent: Text {
        id: textVisor
        property int requiredHeight: Math.max(contentHeight, units.fingerUnit)
        property var shownContent: {date: ''; time: ''}

        text: shownContent['date'] + " - " + shownContent['time']
        font.pixelSize: units.readUnit
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    }

    editorComponent: Rectangle {
        property int requiredHeight: childrenRect.height
        property var editedContent

        color: 'white'

        GridLayout {
            id: dateTimeFlow
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
//            height: childrenRect.height
            columnSpacing: units.nailUnit
            rowSpacing: columnSpacing
            rows: 3
            columns: 2

            CheckBox {
                id: limitDateOption
                Layout.fillWidth: true
                text: qsTr('Especifica data')
                checked: editedContent['date'] !== ''
                onClicked: datetimeToContent()
            }
            CheckBox {
                id: limitTimeOption
                text: qsTr('Especifica hora')
                checked: editedContent['time'] !== ''
                // If the date is not specified then we don't show the option to change the time
                visible: limitDateOption.checked
                onClicked: datetimeToContent()
            }

            Calendar {
                id: limitDatePicker

                Layout.fillWidth: true
                Layout.preferredHeight: (visible)?width:0

                visible: limitDateOption.checked
                onClicked: {
                    datetimeToContent();
                }

                function setDate(date) {
                    selectedDate = date;
                }
            }

            Editors.TimePicker {
                id: limitTimePicker
                visible: limitTimeOption.visible && limitTimeOption.checked
                onUpdatedByUser: {
                    datetimeToContent();
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
                    editState.setChanges(true);
                    datetimeToContent();
                }
            }
            Button {
                text: qsTr('Original')
                onClicked: {
                    // Revert changes to the initial values
                    editedContent = editState.originalContent;
                    editState.setChanges(false);
                    console.log("Original: " + editState.originalContent['date']+ "---" + editState.originalContent['time']);
                    console.log("Edited: " + editedContent['date']+ "---" + editedContent['time']);
                }
            }

        }

        onEditedContentChanged: {
            var refDate = new Date();
            console.log('DateTimeEditor');
            console.log(editedContent['date'] + "---> " + editedContent['time']);
            limitDatePicker.selectedDate = ((editedContent['date'] !== '')?refDate.fromYYYYMMDDFormat(editedContent['date']):refDate);
            limitDateOption.checked = editedContent['date'] !== '';
            limitTimePicker.setDateTime((editedContent['time'] !== '')?refDate.fromHHMMFormat(editedContent['time']):refDate);
            limitTimeOption.checked = editedContent['time'] !== '';
        }

        function datetimeToContent() {
            var dateStr = '';
            var timeStr = '';
            if (limitDateOption.checked) {
                dateStr = limitDatePicker.selectedDate.toYYYYMMDDFormat();
                if (limitTimeOption.checked) {
                    timeStr = limitTimePicker.getTime().toHHMMFormat();
                }
            }
            console.log("Inside DatetimeToContent " + dateStr + "---> " + timeStr);
            editedContent = {date: dateStr, time: timeStr};
            setChanges(true);
        }
    }
}

