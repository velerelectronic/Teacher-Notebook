import QtQuick 2.7
import QtQuick.Layouts 1.3
import 'qrc:///common' as Common

Rectangle {
    id: reperiodItem

    property string currentStartDate: '-'
    property string currentEndDate: '-'

    property string selectedStartDate: ''
    property string selectedEndDate: ''

    signal startDateSelected(string date)
    signal endDateSelected(string date)

    Common.UseUnits {
        id: units
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true

            color: (currentStartDate == selectedStartDate)?'yellow':'white'

            Text {
                id: startText

                anchors.fill: parent

                padding: units.nailUnit
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter

                color: 'gray'
                font.pixelSize: units.readUnit

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log('start date selected', currentStartDate)
                        startDateSelected(currentStartDate);
                    }
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true

            color: (currentEndDate == selectedEndDate)?'yellow':'white'

            Text {
                id: endText

                anchors.fill: parent

                padding: units.nailUnit
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter

                color: 'gray'
                font.pixelSize: units.readUnit

                MouseArea {
                    anchors.fill: parent
                    onClicked: endDateSelected(currentEndDate)
                }
            }
        }
    }

    function setContent(start, end) {
        if (start !== null) {
            if (start === '') {
                startText.text = qsTr('Sense inici');
                currentStartDate = '';
            } else {
                startText.text = start.toShortReadableDate();
                currentStartDate = start.toYYYYMMDDFormat();
            }
        }
        if (end !== null) {
            if (end === '') {
                endText.text = qsTr('Sense final');
                currentEndDate = '';
            } else {
                endText.text = end.toShortReadableDate();
                currentEndDate = end.toYYYYMMDDFormat();
            }
        }
    }
}
