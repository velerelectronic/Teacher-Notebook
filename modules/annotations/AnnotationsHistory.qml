import QtQuick 2.5
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models

Rectangle {
    id: annotationsHistory

    Common.UseUnits {
        id: units
    }

    signal annotationSelected(string title)
    signal hideHistory()

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
                anchors.margins: units.nailUnit
                spacing: units.nailUnit

                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: units.fingerUnit
                    font.pixelSize: units.readUnit
                    horizontalAlignment: Text.AlignHCenter
                    fontSizeMode: Text.Fit
                    text: (model.index+1)
                }

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
                onClicked: annotationsHistory.annotationSelected(model.title)
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

