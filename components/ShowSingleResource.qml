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
    property string hashString: ''

    signal resourceUpdated()
    signal annotationEditSelected(string annotation, int resource)

    Models.ResourcesModel {
        id: resourcesModel
    }

    onResourceChanged: getResourceDetails()


    ColumnLayout {
        anchors.fill: parent
        spacing: units.nailUnit
        Common.HorizontalStaticMenu {
            id: menuBar

            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 1.5

            underlineColor: 'orange'
            underlineWidth: units.nailUnit

            sectionsModel: resourceSectionsModel
            connectedList: resourceListView
        }

        ListView {
            id: resourceListView
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true

            spacing: units.fingerUnit

            model: ObjectModel {
                id: resourceSectionsModel

                Common.BasicSection {
                    width: resourceListView.width
                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Títol')

                    Editors.TextAreaEditor3 {
                        id: titleEditor
                        width: parent.width
                        height: units.fingerUnit * 8
                        color: 'white'
                        border.color: 'black'
                        text: title
                    }
                }

                Common.BasicSection {
                    width: resourceListView.width
                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Descripció')

                    Editors.TextAreaEditor3 {
                        id: descEditor
                        width: parent.width
                        height: units.fingerUnit * 8
                        color: 'white'
                        border.color: 'black'
                        text: desc
                    }
                }

                Common.BasicSection {
                    width: resourceListView.width
                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Tipus')

                    Editors.TextAreaEditor3 {
                        id: mediaTypeEditor
                        width: parent.width
                        height: units.fingerUnit * 8
                        color: 'white'
                        border.color: 'black'
                        text: mediaType
                    }
                }

                Common.BasicSection {
                    width: resourceListView.width
                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Origen')

                    Editors.TextAreaEditor3 {
                        id: sourceEditor
                        width: parent.width
                        height: units.fingerUnit * 8
                        color: 'white'
                        border.color: 'black'
                        text: source
                    }
                }

                Common.BasicSection {
                    caption: qsTr('Hash')
                    width: resourceListView.width
                    padding: units.fingerUnit
                    captionSize: units.readUnit

                    Text {
                        id: hash
                        width: parent.width
                        height: contentHeight
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: hashString
                    }
                }

                Common.BasicSection {
                    width: resourceListView.width
                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Anotació')

                    Text {
                        width: parent.width
                        height: units.fingerUnit * 3
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: units.readUnit
                        text: annotation

                        MouseArea {
                            anchors.fill: parent
                            onClicked: annotationEditSelected(annotation, resource)
                        }
                    }
                }
            }
        }
    }

    function getResourceDetails() {
        resourcesModel.select();
        console.log('Resource', resource);
        var obj = resourcesModel.getObject(resource);

        if (obj) {
            title = obj['title'];
            desc = obj['desc'];
            mediaType = obj['type'];
            source = obj['source'];
            annotation = obj['annotation'];
            hashString = obj['hash'];
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
