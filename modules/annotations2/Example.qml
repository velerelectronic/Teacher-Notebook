import QtQuick 2.6

import 'qrc:///common' as Common

Common.ThreePanesNavigator {
    id: annotationListAndShowItem

    firstPane: Rectangle {
        border.width: 10
        border.color: '#004400'
        //visible: false
    }

    secondPane: Rectangle {
        border.width: 10
        border.color: '#00AA00'
        //visible: false
    }

    thirdPane: Rectangle {
        border.width: 10
        border.color: '#00FF00'
        //visible: false
    }

    Component.onCompleted: {
        setFirstPane(firstPane);
        setSecondPane(secondPane);
        setThirdPane(thirdPane);
    }
}
