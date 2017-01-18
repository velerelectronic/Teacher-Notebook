import QtQuick 2.6
import QtQuick.Layouts 1.1
import Qt.labs.folderlistmodel 2.1
import PersonalTypes 1.0
import 'qrc:///models' as Models
import 'qrc:///common' as Common
import 'qrc:///modules/plannings' as Plannings
import "qrc:///common/FormatDates.js" as FormatDates

BaseCard {
    requiredHeight: filesList.contentItem.height

    signal imageViewerSelected(string file)

    Common.UseUnits {
        id: units
    }

    ListView {
        id: filesList

        anchors.fill: parent

        model: limitModel
        spacing: units.nailUnit
        interactive: false

        delegate: Rectangle {
            width: filesList.width
            height: units.fingerUnit
            Text {
                font.pixelSize: units.readUnit
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                text: fileName
            }
            MouseArea {
                anchors.fill: parent
                onClicked: Qt.openUrlExternally(fileURL)
            }
        }
    }

    ListModel {
        id: limitModel
    }

    FolderListModel {
        id: downloadsModel

        showDirs: false
        sortField: FolderListModel.Time
        sortReversed: true

        property int selectedIndex: -1
    }

    function updateContents() {
        downloadsModel.folder = "file://" + paths.downloads;
        limitModel.clear();
        for (var i=0; i<Math.min(10, downloadsModel.count); i++) {
            var url = downloadsModel.get(i, 'fileURL');
            var name = downloadsModel.get(i, 'fileName');
            limitModel.append({fileName: name, fileURL: url});
        }
    }

    StandardPaths {
        id: paths
    }

    Component.onCompleted: updateContents()
}
