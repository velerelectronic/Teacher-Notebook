import QtQuick 2.5
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common

Rectangle {
    id: yearView
    property int fullyear

    signal dateSelected(int date, int month, int fullyear)

    property var monthNames: [qsTr('Gener'), qsTr('Febrer'), qsTr('Març'), qsTr('Abril'), qsTr('Maig'), qsTr('Juny'), qsTr('Juliol'), qsTr('Agost'), qsTr('Setembre'), qsTr('Octubre'), qsTr('Novembre'), qsTr('Desembre')]

    Common.UseUnits {
        id: units
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: units.nailUnit

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 1.5

            RowLayout {
                anchors.fill: parent
                spacing: units.nailUnit

                Common.TextButton {
                    Layout.fillHeight: true
                    text: qsTr('< Any anterior')
                    onClicked: {
                        fullyear--;
                    }
                }
                Text {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    font.pixelSize: units.glanceUnit
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                    text: qsTr('Any ') + fullyear
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var today = new Date();
                            fullyear = today.getFullYear();
                        }
                    }
                }

                Common.TextButton {
                    Layout.fillHeight: true
                    text: qsTr('Any posterior >')
                    onClicked: {
                        fullyear++;
                    }
                }
            }

        }

        GridView {
            id: monthGrid

            Layout.fillWidth: true
            Layout.fillHeight: true

            interactive: false

            property bool isVertical: width < height
            property int numberOfColumns: (isVertical)?3:4
            property int numberOfRows: (isVertical)?4:3

            property int spacing: 0 // units.fingerUnit

            // Calculated properties
            cellWidth: Math.floor((width - spacing * (numberOfColumns-1)) / numberOfColumns)
            cellHeight: Math.floor((height - spacing * (numberOfRows-1)) / numberOfRows)

            model: 12

                delegate: Rectangle {
                    width: monthGrid.cellWidth
                    height: monthGrid.cellHeight

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: units.fingerUnit / 2

                    Text {
                        Layout.fillWidth: true
                        Layout.preferredHeight: units.fingerUnit

                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter

                        font.pixelSize: units.readUnit
                        font.bold: true
                        text: monthNames[modelData]
                    }

                    Item {
                        id: monthViewContainer

                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }

                    Component {
                        id: monthviewComponent

                        MonthView {
                            anchors.fill: parent
                            month: modelData
                            fullyear: yearView.fullyear

                            onDateSelected: yearView.dateSelected(date, month, fullyear)
                        }
                    }

                    Component.onCompleted: {
                        var incubator = monthviewComponent.incubateObject(monthViewContainer, {})
                    }
                }
            }
        }
    }

}
