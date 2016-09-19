import QtQuick 2.5
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models

ListView {
    id: sectionsList

    property SqlTableModel sectionsModel

    signal sectionsReordered()
    signal close()

    property bool updating: false

    Common.UseUnits {
        id: units
    }

    spacing: units.nailUnit

    clip: true
    model: sectionsModel

    delegate: Rectangle {
        width: sectionsList.width
        height: units.fingerUnit * 2
        RowLayout {
            anchors.fill: parent
            anchors.margins: units.nailUnit
            spacing: units.nailUnit

            Text {
                Layout.fillHeight: true
                Layout.preferredWidth: units.fingerUnit * 2

                font.pixelSize: units.readUnit
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: model.position
            }
            Text {
                Layout.fillHeight: true
                Layout.fillWidth: true

                font.pixelSize: units.readUnit
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: model.title
            }
            Common.ImageButton {
                Layout.fillHeight: true
                Layout.preferredWidth: units.fingerUnit * 2
                size: units.fingerUnit * 1.5
                image: (model.index>0)?'up-97614':''
                enabled: !updating
                onClicked: {
                    if (model.index>0) {
                        updateSections(model.index, model.index-1);
                    }
                }
            }
            Common.ImageButton {
                Layout.fillHeight: true
                Layout.preferredWidth: units.fingerUnit * 2
                size: units.fingerUnit * 1.5
                image: (model.index<sectionsModel.count-1)?'download-97606':''
                enabled: !updating
                onClicked: {
                    if (model.index<sectionsModel.count-1) {
                        updateSections(model.index, model.index+1);
                    }
                }
            }
        }
    }

    function updateSections(index1, index2) {
        if (!updating) {
            updating = true;
            var firstId = sectionsModel.getObjectInRow(index1)['id'];
            var secondId = sectionsModel.getObjectInRow(index2)['id'];

            sectionsModel.updateObject(firstId, {position: index2+1});
            sectionsList.sectionsReordered();
            sectionsModel.updateObject(secondId, {position: index1+1});
            sectionsList.sectionsReordered();
            updating = false;
        }
    }
}
