import QtQuick 2.7

Rectangle {
    property string stateValue

    color: {
        switch(stateValue) {
        case 'completed':
            return '#E3F6CE';
        case 'discarded':
            return '#BDBDBD';
        case 'open':
        default:
            return 'white';
        }
    }
}
