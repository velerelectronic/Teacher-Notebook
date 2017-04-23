import QtQuick 2.5
import 'qrc:///common' as Common


Rectangle {
    id: stateItem

    signal clicked()
    property int stateValue
    property int requiredHeight: units.fingerUnit

    Common.ImageButton {
        anchors.fill: parent
        size: height
        image: {
            switch(stateItem.stateValue) {
            case -1:
                return 'can-294071';
            case 1:
                return 'pin-23620';
            case 2:
                return 'hourglass-23654';
            case 3:
                return 'check-mark-304890';
            case 0:
            default:
                return 'input-25064';
            }
        }
        onClicked: stateItem.clicked()
    }
}
