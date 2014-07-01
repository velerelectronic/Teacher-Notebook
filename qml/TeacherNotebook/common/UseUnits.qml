import QtQuick 2.2
import QtQuick.Window 2.1

Item {
    id: units
    property int fingerUnit: Screen.pixelDensity * 10
    property int nailUnit: Screen.pixelDensity * 3
    property int glanceUnit: Screen.pixelDensity * 7
    property int readUnit: Screen.pixelDensity * 5

/*
    property alias fingerUnit: refTextLarge.height
    property alias nailUnit: refTextSmall.height
    property int glanceUnit: Math.round(fingerUnit * 1.25)
    property int readUnit: Math.round(nailUnit * 1.25)
*/

    /*
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
    */

//    Component.onCompleted: console.log('Created units: ' + fingerUnit + '-' + nailUnit)
}
