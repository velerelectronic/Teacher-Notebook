import QtQuick 2.0
import "Filesystem.js" as Filesystem

Rectangle {
    property string pageTitle: qsTr('Sistema de fitxers');
    property int esquirolGraphicalUnit: 100

    width: 100
    height: 62
    ListView {
        anchors.fill: parent
        model: ListModel {}
        delegate: Rectangle {

        }
    }
    Component.onCompleted: {
        var fs = new Filesystem.EsquirolSourceFilesystem('a','');
        fs.showContents();
    }
}

