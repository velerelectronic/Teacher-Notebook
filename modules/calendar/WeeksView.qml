import QtQuick 2.7
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common

Rectangle {
    id: weeksViewItem
    color: 'gray'

    clip: true

    property var initialDate: new Date()
    property int weeksNumber: 20

    property Component subWidget

    signal selectedDate(int day, int month, int year)

    Common.UseUnits {
        id: units
    }

    ColumnLayout {
        anchors.fill: parent

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 2

            z: 2
            RowLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                spacing: units.nailUnit

                Repeater {
                    model: [qsTr('dl'), qsTr('dt'), qsTr('dc'), qsTr('dj'), qsTr('dv'), qsTr('ds'), qsTr('dg')]

                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        font.bold: true

                        horizontalAlignment: Text.AlignVCenter
                        verticalAlignment: Text.AlignBottom
                        text: modelData
                    }
                }
            }
        }

        GridView {
            id: weeksList

            Layout.fillHeight: true
            Layout.fillWidth: true

            z: 1
            property int daySize: Math.floor(width / 7)

            cellWidth: daySize
            cellHeight: daySize

            function setDates() {
                var date = new Date();
                date.setFullYear(initialDate.getFullYear());
                date.setMonth(initialDate.getMonth());
                date.setDate(initialDate.getDate()-initialDate.getDay()+1);

                console.log('today', date);

                var months = [qsTr('GEN'), qsTr('FEB'), qsTr('MAR'), qsTr('ABR'), qsTr('MAI'), qsTr('JUN'), qsTr('JUL'), qsTr('AGO'), qsTr('SET'), qsTr('OCT'), qsTr('NOV'), qsTr('DES')];
                for (var i=0; i<weeksNumber; i++) {
                    for (var j=0; j<7; j++) {
                        var monthName = months[date.getMonth()];
                        daysModel.append({day: date.getDate(), weekDay: date.getDay(), month: date.getMonth(), monthName: monthName, year: date.getFullYear()});
                        date.setDate(date.getDate()+1);
                    }
                }
            }

            model: ListModel {
                id: daysModel
            }

            delegate: Item {
                id: singleWeek

                width: weeksList.cellWidth
                height: weeksList.cellHeight

                property string sss: ListView.section
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit / 2

                    color: 'white'

                    MouseArea {
                        anchors.fill: parent
                        onClicked: weeksViewItem.selectedDate(model.day, model.month, model.year)
                    }

                    Text {
                        id: monthText

                        anchors.fill: parent
                        anchors.margins: units.nailUnit

                        verticalAlignment: Text.AlignTop
                        horizontalAlignment: Text.AlignLeft

                        font.pixelSize: units.readUnit
                        font.bold: true

                        Component.onCompleted: {
                            if (((model.index>0) && (daysModel.get(model.index-1)['month'] !== model.month)) || (model.index == 0)) {
                                console.log(model.month, model.monthName);
                                monthText.text = model.monthName;
                            } else {
                                if ((model.index % 7 == 0) && (model.index>6) && (daysModel.get(model.index-7)['month'] !== model.month)) {
                                    monthText.text = model.monthName;
                                }
                            }
                        }
                    }
                    Text {
                        id: dayText

                        anchors.fill: parent
                        anchors.margins: units.nailUnit

                        verticalAlignment: Text.AlignTop
                        horizontalAlignment: Text.AlignRight

                        font.pixelSize: units.readUnit

                        text: model.day
                    }

                    Loader {
                        id: subWidgetLoader

                        anchors.fill: parent

                        sourceComponent: subWidget

                        onLoaded: {
                            item.day = model.day;
                            item.month = model.month;
                            item.year = model.year;
                            item.init();
                        }
                    }
                }
            }
        }

    }


    Component.onCompleted: weeksList.setDates()
}