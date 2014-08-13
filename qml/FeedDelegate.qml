import QtQuick 2.2

Rectangle {
    id: feedDelegate

    property string textTitol
    property string textContingut
    property string enllac

    property int index
    property string copiaTitol
    property string copiaContingut
    property string copiaEnllac

    property string colorOdd: '#ffffff' // #e0e0e0'
    property string colorEven: '#ffffff'

    color: (index % 2 == 1)?colorOdd:colorEven

    height: Math.max(textContents.height + units.nailUnit * 2, 2 * units.fingerUnit)
    border.color: '#aaaaaa'
    border.width: 2

    Text {
        id: textContents
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: units.nailUnit
        height: paintedHeight

        textFormat: Text.RichText
        font.pixelSize: units.readUnit
        verticalAlignment: Text.AlignVCenter
        text: feedDelegate.textTitol
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    }

    MouseArea {
        anchors.fill: feedDelegate
        onClicked: {
            console.log('Canviat a ' + index);
            feedDelegate.ListView.view.currentIndex = index;
        }
    }

    Component.onCompleted: {
        if (copiaTitol == '')
            copiaTitol = titol;
        if (copiaContingut == '')
            copiaContingut = textContingut;
        if (copiaEnllac == '')
            copiaEnllac = enllac;
    }

}
