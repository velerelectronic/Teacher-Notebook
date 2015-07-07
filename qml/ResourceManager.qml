import QtQuick 2.3
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import "qrc:///common/FormatDates.js" as FormatDates

Rectangle {
    id: resourceManager

    Common.UseUnits { id: units }

    property string pageTitle: qsTr('Recursos')

    property alias buttons: buttonsModel

    signal createResource(var model)
    signal showResource(int idResource,var model)

    ListModel {
        id: buttonsModel

        Component.onCompleted: {
            append({method: 'newResource', image: 'plus-24844', title: qsTr('Afegeix un recurs')});
        }
    }

    SqlTableModel {
        id: resourcesModel

        tableName: 'resources'
        fieldNames: ['id','created','title','desc','type','source','contents']
        Component.onCompleted: {
            select();
        }
    }

    Rectangle {
        id: resourceHeader
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        height: units.fingerUnit
        RowLayout {
            anchors.fill: parent
            anchors.margins: units.nailUnit
            spacing: units.nailUnit
            Text {
                Layout.fillHeight: true
                Layout.preferredWidth: resourceHeader.width / 4
                font.pixelSize: units.readUnit
                text: qsTr('Títol')
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                elide: Text.ElideRight
            }
            Text {
                Layout.fillHeight: true
                Layout.preferredWidth: resourceHeader.width / 4
                font.pixelSize: units.readUnit
                text: qsTr('Descripció')
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                elide: Text.ElideRight
            }
            Text {
                Layout.fillHeight: true
                Layout.preferredWidth: resourceHeader.width / 4
                font.pixelSize: units.readUnit
                text: qsTr('Tipus')
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                elide: Text.ElideRight
            }
            Text {
                Layout.fillHeight: true
                Layout.fillWidth: true
                font.pixelSize: units.readUnit
                text: qsTr('Origen')
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                elide: Text.ElideRight
            }
        }
    }

    ListView {
        id: resourcesList
        anchors {
            top: resourceHeader.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        clip: true
        model: resourcesModel

        delegate: Rectangle {
            id: resourceItem
            width: resourcesList.width
            height: units.fingerUnit * 2
            border.color: 'grey'
            RowLayout {
                anchors.fill: parent
                spacing: units.nailUnit
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: resourceItem.width / 4
                    font.pixelSize: units.readUnit
                    text: model.title
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: resourceItem.width / 4
                    font.pixelSize: units.readUnit
                    text: model.desc
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: resourceItem.width / 4
                    font.pixelSize: units.readUnit
                    text: model.type
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    font.pixelSize: units.readUnit
                    text: model.source
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: resourceManager.showResource(model.id,resourcesModel)
            }
        }
    }

    Common.SuperposedButton {
        anchors {
            bottom: resourcesList.bottom
            right: resourcesList.right
        }
        size: units.fingerUnit * 2
        margins: units.nailUnit
        label: '+'
        fontSize: units.glanceUnit
        onClicked: newResource()
    }

    function newResource() {
        resourceManager.createResource(resourcesModel);
    }

}

