import QtQuick 2.5
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models

Rectangle {
    id: annotationsHistory

    Common.UseUnits {
        id: units
    }

    signal selectAnnotation(string identifier)

    color: 'grey'

    ListModel {
        id: annotationsHistoryModel
    }

    ListView {
        id: annotationsHistoryView
        anchors.fill: parent
        model: annotationsHistoryModel

        spacing: units.nailUnit

        delegate: Rectangle {
            width: annotationsHistoryView.width
            height: units.fingerUnit * 2
            RowLayout {
                anchors.fill: parent
                Text {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: model.title
                }
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: Math.min(contentWidth, parent.width / 2)
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: model.timestamp
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: annotationsHistory.selectAnnotation(model.title)
                onPressAndHold: annotationsHistoryModel.remove(model.index)
            }
        }
    }

    function addAnnotation(title) {
        var date = new Date();
        annotationsHistoryModel.insert(0,{title: title, timestamp: date.toLocaleString()});
    }

    function showList() {

    }
}

