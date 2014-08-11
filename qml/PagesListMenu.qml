import QtQuick 2.2

Rectangle {
    id: pagesList

    property int readUnit
    property int menuWidth
    property int sectionsHeight: units.fingerUnit * 2
    property int durationEffect
    property alias model: list.model
    property int textMargins: units.nailUnit
    signal pageSelected(int index)
    signal pageCloseRequested(int index)

    color: 'white'
    clip: true

}
