import QtQuick 2.6
import QtQuick.Layouts 1.1
import Qt.labs.folderlistmodel 2.1
import PersonalTypes 1.0
import 'qrc:///models' as Models
import 'qrc:///common' as Common
import 'qrc:///modules/plannings' as Plannings
import "qrc:///common/FormatDates.js" as FormatDates

BaseCard {
    requiredHeight: imageData.width

    signal imageViewerSelected(string file)
    signal gallerySelected(string sourceRoot)

    Image {
        id: imageData

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        fillMode: Image.PreserveAspectFit
        asynchronous: true
        clip: true

        onStatusChanged: {
            if (status == Image.Error) {
                getNextPicture(picturesModel.selectedIndex+1);
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            gallerySelected(picturesModel.folder);

            //imageViewerSelected(imageData.source)
        }
    }

    FolderListModel {
        id: picturesModel

        showDirs: false
        sortField: FolderListModel.Time
        sortReversed: true

        property int selectedIndex: -1
    }

    function updateContents() {
        picturesModel.folder = "file://" + paths.pictures;
        getNextPicture(0);
    }

    function getNextPicture(min) {
        if (picturesModel.count > min) {
            picturesModel.selectedIndex = min;
            var url = picturesModel.get(min, 'fileURL');
            imageData.source = url;
            console.log(paths.pictures, picturesModel.folder, url);
        }
    }

    StandardPaths {
        id: paths
    }

    Component.onCompleted: updateContents()
}
