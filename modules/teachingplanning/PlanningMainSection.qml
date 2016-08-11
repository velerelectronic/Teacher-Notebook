import QtQuick 2.5
import QtQml.Models 2.2

Rectangle {
    color: 'white'
    default property alias subObjects: widgetsModel.children

    ListView {
        id: mainItem
        anchors.fill: parent
        clip: true
        model: widgetsModel
    }
    ObjectModel {
        id: widgetsModel
    }
}
