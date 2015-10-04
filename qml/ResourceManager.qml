import QtQuick 2.5
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import "qrc:///common/FormatDates.js" as FormatDates

Rectangle {
    id: resourceManager

    Common.UseUnits { id: units }

    property string pageTitle: qsTr('Recursos')

    signal createResource(var model)
    signal showResource(int idResource,var model)

    property int requiredHeight: resourcesList.contentItem.height

    Models.ResourcesModel {
        id: resourcesModel

        searchFields: ['title','desc','type','source']

        limit: 30

        Component.onCompleted: {
            select();
        }
    }

    ListView {
        id: resourcesList
        anchors.fill: parent

        clip: true
        model: resourcesModel

        header: Rectangle {
            id: resourceHeader

            width: resourcesList.width
            height: units.fingerUnit * 2 + units.nailUnit
            z: 2

            GridLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                columnSpacing: units.nailUnit
                rowSpacing: columnSpacing

                rows: 2
                columns: 4

                Common.SearchBox {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    Layout.columnSpan: 4

                    onPerformSearch: resourcesModel.searchString = text
                }

                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: resourceHeader.width / 4
                    font.pixelSize: units.readUnit
                    font.bold: true
                    text: qsTr('Títol')
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: resourceHeader.width / 4
                    font.pixelSize: units.readUnit
                    font.bold: true
                    text: qsTr('Descripció')
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: resourceHeader.width / 4
                    font.pixelSize: units.readUnit
                    font.bold: true
                    text: qsTr('Tipus')
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    font.pixelSize: units.readUnit
                    font.bold: true
                    text: qsTr('Origen')
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                }
            }
        }

        headerPositioning: ListView.OverlayHeader

        delegate: Rectangle {
            id: resourceItem
            width: resourcesList.width
            height: units.fingerUnit * 2
            z: 1

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
            bottom: parent.bottom
            right: parent.right
        }
        size: units.fingerUnit * 2
        imageSource: 'plus-24844'
        onClicked: resourceManager.createResource(resourcesModel)
    }

}

