import QtQuick 2.7

Rectangle {
    property string stateValue

    property string completedString: 'completed'
    property string discardedString: 'discarded'
    property string openString: 'open'

    property string completedColor: '#E3F6CE'
    property string discardedColor: '#BDBDBD'
    property string openColor: 'white'

    color: {
        switch(stateValue) {
        case completedString:
            return completedColor;
        case discardedString:
            return discardedColor;
        case openString:
        default:
            return openColor;
        }
    }
}
