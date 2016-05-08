import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///components' as Components
import 'qrc:///editors' as Editors
import ClipboardAdapter 1.0

Item {
    id: showResourceItem

    Common.UseUnits {
        id: units
    }

    property int resource
    property string title: ''
    property string desc: ''
    property string mediaType: ''
    property string source: ''
    property string annotation: ''

    signal resourceUpdated()
    signal annotationEditSelected(string annotation, int resource)

    Models.ResourcesModel {
        id: resourcesModel
    }

    onResourceChanged: getResourceDetails()

    ListView {
        id: resourceListView
        anchors.fill: parent
        spacing: units.nailUnit

        model: ObjectModel {
            Text {
                width: resourceListView.width
                height: units.fingerUnit
                font.pixelSize: units.readUnit
                font.bold: true
                text: qsTr('Títol')
            }
            Editors.TextAreaEditor3 {
                id: titleEditor
                width: resourceListView.width
                height: units.fingerUnit * 8
                color: 'white'
                border.color: 'black'
                text: title
            }

            Text {
                width: resourceListView.width
                height: units.fingerUnit
                font.pixelSize: units.readUnit
                font.bold: true
                text: qsTr('Descripció')
            }
            Editors.TextAreaEditor3 {
                id: descEditor
                width: resourceListView.width
                height: units.fingerUnit * 8
                color: 'white'
                border.color: 'black'
                text: desc
            }

            Text {
                width: resourceListView.width
                height: units.fingerUnit
                font.pixelSize: units.readUnit
                font.bold: true
                text: qsTr('Tipus')
            }
            Editors.TextAreaEditor3 {
                id: mediaTypeEditor
                width: resourceListView.width
                height: units.fingerUnit * 8
                color: 'white'
                border.color: 'black'
                text: mediaType
            }

            Text {
                width: resourceListView.width
                height: units.fingerUnit
                font.pixelSize: units.readUnit
                font.bold: true
                text: qsTr('Origen')
            }
            Editors.TextAreaEditor3 {
                id: sourceEditor
                width: resourceListView.width
                height: units.fingerUnit * 8
                color: 'white'
                border.color: 'black'
                text: source
            }

            Text {
                width: resourceListView.width
                height: units.fingerUnit
                font.pixelSize: units.readUnit
                font.bold: true
                text: qsTr('Anotació')
            }
            Rectangle {
                width: resourceListView.width
                height: units.fingerUnit * 3
                Text {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.pixelSize: units.readUnit
                    text: annotation
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: annotationEditSelected(annotation, resource)
                }
            }
        }
    }

    function getResourceDetails() {
        resourcesModel.select();
        var obj = resourcesModel.getObject(resource);
        if (obj) {
            title = obj['title'];
            desc = obj['desc'];
            mediaType = obj['type'];
            source = obj['source'];
            annotation = obj['annotation'];
        }
    }

    function saveEditorContents() {
        var obj = {
            title: titleEditor.text,
            desc: descEditor.text,
            type: mediaTypeEditor.text,
            source: sourceEditor.text,
            annotation: annotation
        }

        resourcesModel.updateObject(resource,obj);
        console.log('saved');
        resourceUpdated();
    }

    Component.onCompleted: getResourceDetails()
}
