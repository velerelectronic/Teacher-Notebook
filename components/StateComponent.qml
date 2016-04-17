import QtQuick 2.5

Rectangle {
    id: stateItem

    signal clicked()
    property string stateValue
    property int requiredHeight: stateText.contentHeight + 2 * units.nailUnit
    property real percentage: 0

    onStateValueChanged: {
        console.log('RE-calculating height in state', stateItem.stateValue);
        var value = parseInt(stateItem.stateValue);
        if ((value>0) && (value<=10)) {
            percentage = value / 10;
        } else {
            if (value<0)
                percentage = 1;
            else
                percentage = 0;
        }
        console.log(percentage);
    }

    Rectangle {
        id: barRect
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        color: 'orange'
        height: stateItem.percentage * stateItem.height
    }

    Text {
        id: stateText
        anchors.fill: parent
        anchors.margins: units.nailUnit
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: units.readUnit
        text: {
            switch(stateItem.stateValue) {
            case '-1':
                return qsTr('Finalitzat');
                break;
            case '1':
                return qsTr('10%');
                break;
            case '2':
                return qsTr('20%');
                break;
            case '3':
                return qsTr('30%');
                break;
            case '4':
                return qsTr('40%');
                break;
            case '5':
                return qsTr('50%');
                break;
            case '6':
                return qsTr('60%');
                break;
            case '7':
                return qsTr('70%');
                break;
            case '8':
                return qsTr('80%');
                break;
            case '9':
                return qsTr('90%');
                break;
            case '10':
                return qsTr('100%');
                break;
            default:
                return qsTr('Actiu');
                break;
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        onClicked: stateItem.clicked()
    }
}
