import QtQuick 2.0
import QtQuick.Layouts 1.1

Rectangle {
    property string title: qsTr('Rellotge');
    property int esquirolGraphicalUnit: 100
    width: 100
    height: 62

    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            id: row
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            height: childrenRect.height

            Clock {

            }

            StopWatch {
                id: stopWatch
            }
        }

        ListView {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: row.bottom
            anchors.bottom: parent.bottom

            model: ListModel { id: chronoModel }
            delegate: Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                height: childrenRect.height
                color: 'green'
                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: title
                    color: 'white'
                }
                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
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
