import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors

CollectionInspectorItem {
    id: dateTimeItem

    Common.UseUnits { id: units }

    clip: true

    visorComponent: Text {
        id: textVisor
        property int requiredHeight: Math.max(contentHeight, units.fingerUnit)
        property string shownContent

        property var shownContent2

        text: shownContent
        font.pixelSize: units.readUnit
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    }

    editorComponent: Rectangle {
        property int requiredHeight: childrenRect.height
        property string editedContent

        property string editedDate
        property string editedTime

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

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: units.fingerUnit
                Layout.columnSpan: 2

                text: qsTr('Opcions')
                onClicked: {
                    console.log('Opcions')
                    dateTimeItem.openMenu(units.fingerUnit * 2,menuComponent);
                }
            }

            CheckBox {
                id: limitDateOption
                Layout.fillWidth: true
                text: qsTr('Especifica data')
                checked: editedDate !== ''
                onClicked: datetimeToContent()
            }
            CheckBox {
                id: limitTimeOption
                text: qsTr('Especifica hora')
                checked: editedTime !== ''
                // If the date is not specified then we don't show the option to change the time
                visible: limitDateOption.checked
                onClicked: datetimeToContent()
            }

            Calendar {
                id: limitDatePicker

                Layout.fillWidth: true
                Layout.preferredHeight: (visible)?width:0

                navigationBarVisible: true

                visible: limitDateOption.checked
                onClicked: {
                    datetimeToContent();
                }

                function setDate(date) {
                    selectedDate = date;
                }

                function addDays(days) {
                    var date = selectedDate;
                    date.setDate(date.getDate() + days);
                    selectedDate = date;
                    datetimeToContent();
                }

                function addMonths(months) {
                    var date = selectedDate;
                    date.setMonth(date.getMonth() + months);
                    selectedDate = date;
                    datetimeToContent();
                }

                function addYears(years) {
                    var date = selectedDate;
                    date.setFullYear(date.getFullYear() + years);
                    selectedDate = date;
                    datetimeToContent();

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
                    dateTimeItem.setChanges(true);
                    datetimeToContent();
                }
            }
            Button {
                text: qsTr('Original')
                onClicked: {
                    // Revert changes to the initial values
                    editedContent = dateTimeItem.originalContent;
                    dateTimeItem.setChanges(false);
                }
            }

        }

        onEditedContentChanged: {
            var split = editedContent.split(' ');
            editedDate = split[0];
            editedTime = split[1];

            var refDate = new Date();
            limitDatePicker.selectedDate = (editedDate !== '')?refDate.fromYYYYMMDDFormat(editedDate):refDate;
            limitDateOption.checked = editedDate !== '';
            limitTimePicker.setDateTime((editedTime !== '')?refDate.fromHHMMFormat(editedTime):refDate);
            limitTimeOption.checked = editedTime !== '';
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
            editedContent = dateStr + " " + timeStr;
            setChanges(true);
        }

        Component {
            id: menuComponent
            Rectangle {
                id: menuRect

                property int requiredHeight: childrenRect.height + units.fingerUnit * 2

                signal closeMenu()

                color: 'white'
                ColumnLayout {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                    anchors.margins: units.fingerUnit

                    spacing: units.fingerUnit
                    Common.TextButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: units.fingerUnit
                        fontSize: units.readUnit
                        text: qsTr('Ajorna un dia')
                        onClicked: {
                            menuRect.closeMenu();
                            limitDatePicker.addDays(1);
                        }
                    }
                    Common.TextButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: units.fingerUnit
                        fontSize: units.readUnit
                        text: qsTr('Ajorna una setmana')
                        onClicked: {
                            menuRect.closeMenu();
                            limitDatePicker.addDays(7);
                        }
                    }
                    Common.TextButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: units.fingerUnit
                        fontSize: units.readUnit
                        text: qsTr('Ajorna un mes')
                        onClicked: {
                            menuRect.closeMenu();
                            limitDatePicker.addMonths(1);
                        }
                    }
                    Common.TextButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: units.fingerUnit
                        fontSize: units.readUnit
                        text: qsTr('Ajorna un any')
                        onClicked: {
                            menuRect.closeMenu();
                            limitDatePicker.addYears(1);
                        }
                    }
                }
            }
        }

    }

}

