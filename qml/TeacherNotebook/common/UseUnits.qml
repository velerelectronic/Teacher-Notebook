import QtQuick 2.0

Item {
    id: units
    property alias fingerUnit: refTextLarge.height
    property alias nailUnit: refTextSmall.height

    Text {
        visible: false
        id: refTextLarge
        text:'M'
        font.pointSize: 32
    }
    Text {
        visible: false
        id: refTextSmall
        text: 'M'
        font.pointSize: 10
    }

    Component.onCompleted: console.log('Created units: ' + fingerUnit + '-' + nailUnit)
}
