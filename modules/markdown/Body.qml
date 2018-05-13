import QtQuick 2.7
import PersonalTypes 1.0

ListView {
    id: bodyList

    model: MarkDownItemModel {
        id: mdModel
    }

    delegate: Rectangle {
        width: bodyList.width
        height: 0
    }
}
