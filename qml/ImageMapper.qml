import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import Qt.labs.folderlistmodel 2.1
import 'qrc:///common' as Common
import PersonalTypes 1.0


Rectangle {
    color: 'yellow'
    property string pageTitle: qsTr('Mapa d\'imatge')
    property string document: ''
    property string background: document

    Common.UseUnits {
        id: units
    }

    ColumnLayout {
        anchors.fill: parent
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit

            Button {
                text: qsTr('Zoom')
                menu: Menu {
                    MenuItem {
                        text: qsTr('Zoom -')
                        onTriggered: editArea.imagesScale = (editArea.imagesScale>=0.2)?(editArea.imagesScale - 0.1):0.1
                    }
                    MenuItem {
                        text: qsTr('1:1')
                        onTriggered: editArea.imagesScale = 1
                    }
                    MenuItem {
                        text: qsTr('Zoom +')
                        onTriggered: editArea.imagesScale = (editArea.imagesScale<=2.9)?(editArea.imagesScale + 0.1):3.0
                    }
                    MenuSeparator {}
                    MenuItem {
                        text: qsTr('Ajusta a l\'amplada')
                        onTriggered: editArea.imagesScale = editArea.width / editArea.imagesWidth
                    }
                    MenuItem {
                        text: qsTr('Ajusta a l\'alçada')
                        onTriggered: editArea.imagesScale = editArea.height / editArea.imagesHeight
                    }
                }
            }
            Button {
                text: qsTr('Obre')
                onClicked: Qt.openUrlExternally(folderList.get(editArea.currentIndex,'fileURL'))
            }

            Button {
                id: smoothnessButton
                text: qsTr('Suavitzat')
                checkable: true
            }

            Button {
                id: horizontalButton
                text: qsTr('Horizontal')
                checkable: true
                checked: false
            }
        }

        ListView {
            id: editArea
            Layout.fillWidth: true
            Layout.fillHeight: true

            orientation: (horizontalButton.checked)?ListView.Horizontal:ListView.Vertical
            clip: true
            highlightFollowsCurrentItem: true

//            property real perfectScale: 1
//            property real imagesScale: 1
//            property real imagesHeight: (editArea.height-2*units.nailUnit) * imagesScale
//            property real imagesWidth: (editArea.width-2*units.nailUnit) * imagesScale
            property bool isVertical: orientation == ListView.Vertical
//            property int openedImageIndex: -1
//            property bool allImagesLoaded: false

//            property int delegatesCount: contentItem.children.length

            model: folderList
            delegate: imageDelegate
        }
    }

    FolderListModel {
        id: folderList
        folder: document.substring(0, document.lastIndexOf("/") + 1)
        nameFilters: upperAndLower(["jpg","jpeg","png","gif","svg"])
        showDirs: false
        showFiles: true

        function upperAndLower(vector) {
            var res = [];
            for (var i=0; i<vector.length; i++) {
                var ext = vector[i];
                res.push("*." + ext);
                res.push("*." + ext.toUpperCase());
            }
            return res;
        }
    }

    Component {
        id: imageDelegate

        Rectangle {
            id: mainItem
            objectName: 'imageDelegate'
            width: editArea.width
            height: editArea.height
            color: 'white'
            border.color: 'black'

//            property bool imageIsVisible: editArea.allImagesLoaded != -1 && getVisibilityOfImage(mainItem.x,mainItem.x+mainItem.width,editArea.contentX,editArea.contentX+editArea.width)

            function getVisibilityOfImage(firstX,lastX,areaFirstX,areaLastX) {
                if ((firstX >= areaFirstX) && (firstX <= areaLastX))
                    return true;
                if ((lastX >= areaFirstX && (lastX <= areaLastX)))
                    return true;
                if ((firstX <= areaFirstX) && (lastX >= areaLastX))
                    return true;
                return false;
            }

            Image {
                id: image
                anchors.fill: parent
                anchors.margins: units.nailUnit
                source: model.fileURL

                smooth: smoothnessButton.checked
                fillMode: Image.PreserveAspectFit
            }
        }
    }
}
