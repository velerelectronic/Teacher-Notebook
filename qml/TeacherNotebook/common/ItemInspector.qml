import QtQuick 2.0
import QtQuick.Layouts 1.1
import '../common' as Common


Common.AbstractEditor {
    property string pageTitle: qsTr('Especifica titol')
    property alias pageBackground: backgroundImage.source

    Image {
        id: backgroundImage
        anchors.fill: parent
    }

    ListView {
        id: inspectorGrid
        anchors.fill: parent
        clip: true
        model: ListModel {}
        delegate: Rectangle {
            width: parent.width
            height: units.fingerUnit
            color: model.color
            RowLayout {
                Text {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: inspectorGrid.model.title
                }
                Text {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: inspectorGrid.model.content
                }
            }
        }
    }

    function addSection(title,content,color) {
        inspectorGrid.model.append({title: title, content: content, color: color});
    }
}
