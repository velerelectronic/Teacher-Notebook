import QtQuick 2.0
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common


Rectangle {
    property string pageTitle: qsTr('Rellotge');
    property bool canClose: true

    Common.UseUnits { id: units }

    ColumnLayout {
        anchors.fill: parent

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 3

            RowLayout {
                id: row
                anchors.fill: parent
                anchors.margins: units.nailUnit
                height: childrenRect.height

                spacing: units.fingerUnit

                Clock {
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height
                }

                StopWatch {
                    id: stopWatch
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height
                }
            }

        }

        ListView {
            Layout.fillHeight: true
            Layout.fillWidth: true

            clip: true
            model: ListModel { id: chronoModel }
            delegate: Rectangle {
                width: parent.width
                height: childrenRect.height
                color: 'green'
                Text {
                    anchors.left: parent.left
                    text: title
                    color: 'white'
                }
                Text {
                    anchors.right: parent.right
                    text: h + ' h ' + m + ' min ' + s + ' s'
                    horizontalAlignment: Text.AlignRight
                }
            }
            Component.onCompleted: {
                chronoModel.append({title: 'Rellotge', h: 0, m: 1, s: 10});
            }
        }

    }

}
