import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors
import 'qrc:///modules/documents' as Documents
import 'qrc:///modules/basic' as Basic
import 'qrc:///modules/pagesfolder' as PagesFolder

Item {
    id: pagesFolderItem

    property string selectedContext: ''
    //property int selectedSection: sectionsList.currentIndex
    property string selectedPageTitle: ''

    signal publishMessage(string message)
    signal minimizePage()

    Common.UseUnits {
        id: units
    }

    Models.PagesFolderContextsModel {
        id: contextsModel

        Component.onCompleted: select()
    }

    Models.PagesFolderSectionsModel {
        id: sectionsModel

        filters: ['context=?']

        sort: 'position ASC'

        function reselect() {
            bindValues = [selectedContext];
            select();
        }

        function deleteSection(section, title) {
            sectionsModel.removeObject(section);
            sectionsModel.reselect();
            pagesFolderItem.publishMessage("S'ha esborrat la secció «" + title + "».");
        }
    }

    ListModel {
        id: openPagesModel

        function addPage(page, parameters, title) {
            console.log('add page', page, parameters);
            var found = false;
            for (var i=0; i<count; i++) {
                var obj = get(i);
                if ((obj['page'] == page) && (obj['parameters'] == parameters)) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                append({page: page, parameters: parameters, title: title});
                openPagesGrid.selectPage(count-1);
            } else {
                openPagesGrid.selectPage(i);
            }
        }
    }

    ColumnLayout {
        id: mainSelectorsLayout

        anchors.fill: parent

        Item {
            id: contextSelectorItem

            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 1.5

            Common.TextButton {
                id: invisibleFolderButton
                anchors {
                    top: parent.top
                    left: parent.right
                    margins: folderButton.anchors.margins
                }
                visible: false

                text: folderButton.text
                font.pixelSize: folderButton.fontSize
                font.bold: folderButton.font.bold
            }
            Common.TextButton {
                id: folderButton
                anchors.fill: parent
                anchors.margins: units.nailUnit
                text: qsTr('Carpeta') + ((selectedContext !== '')?(' ' + selectedContext):'')
                fontSizeMode: Text.Fit
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                fontSize: units.glanceUnit
                font.bold: true
                onClicked: contextSelectorDialog.open()
            }
        }

        GridView {
            id: sectionsGrid

            Layout.fillWidth: true
            Layout.fillHeight: true

            cellWidth: width / 5
            cellHeight: cellWidth * (pagesFolderItem.height / pagesFolderItem.width)

            clip: true
            model: sectionsModel

            delegate: Item {
                width: openPagesGrid.cellWidth
                height: openPagesGrid.cellHeight

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit

                    Text {
                        anchors.fill: parent
                        anchors.margins: units.nailUnit
                        font.pixelSize: units.readUnit
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                        text: model.title
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: openPagesModel.addPage(model.page, model.parameters, model.title)
                }
            }

        }
        GridView {
            id: openPagesGrid

            Layout.fillWidth: true
            Layout.preferredHeight: contentItem.height

            cellWidth: width / 5
            cellHeight: cellWidth * (pagesFolderItem.height / pagesFolderItem.width)

            model: openPagesModel
            interactive: false

            delegate: Rectangle {
                id: openPageRect

                width: openPagesGrid.cellWidth
                height: openPagesGrid.cellHeight

                property string pageTitle: model.title

                states: [
                    State {
                        name: 'minimized'

                        ParentChange {
                            target: openPageLoader
                            parent: openPageRect
                        }
                    },
                    State {
                        name: 'maximized'

                        ParentChange {
                            target: openPageLoader
                            parent: showPageItem
                        }
                        PropertyChanges {
                            target: mainSelectorsLayout
                            visible: false
                        }
                    }
                ]

                transitions: Transition {
                    ParentAnimation {
                        NumberAnimation {
                            properties: 'x,y,width,height'
                            duration: 500
                        }
                    }
                }

                Loader {
                    id: openPageLoader

                    z: 1
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    clip: true

                    Component.onCompleted: {
                        console.log('completed', model.page, model.parameters);
                        var parameters = (model.parameters !== '')?JSON.parse(model.parameters):{};
                        setSource("qrc:///modules/" + model.page + ".qml", parameters);
                    }
                }
                MouseArea {
                    z: 2
                    anchors.fill: parent
                    onClicked: {
                        selectedPageTitle = model.title;
                        openPageRect.state = 'maximized';
                    }
                    onPressAndHold: openPagesModel.remove(model.index)
                }

                Connections {
                    target: pagesFolderItem

                    onMinimizePage: openPageRect.state = 'minimized'
                }
            }

            function selectPreviousPage() {
                if (currentIndex>0)
                    selectPage(currentIndex-1);
            }

            function selectNextPage() {
                if (currentIndex<openPagesGrid.contentItem.children.length-1)
                    selectPage(currentIndex+1);
            }

            function selectPage(index) {
                if (currentIndex>=0)
                    openPagesGrid.contentItem.children[openPagesGrid.currentIndex].state = 'minimized';
                openPagesGrid.currentIndex = index;
                var obj = openPagesGrid.contentItem.children[openPagesGrid.currentIndex];
                obj.state = 'maximized';
                selectedPageTitle = obj.pageTitle;
            }
        }
    }

    ColumnLayout {
        id: showPageLayout

        anchors.fill: parent
        visible: !mainSelectorsLayout.visible

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit + units.nailUnit * 2
            RowLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                spacing: units.fingerUnit
                Text {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    font.pixelSize: units.glanceUnit
                    font.bold: true
                    text: selectedPageTitle
                }
                Common.ImageButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                    image: 'arrow-145769'
                    onClicked: openPagesGrid.selectPreviousPage()
                }

                Common.ImageButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                    image: 'arrow-145766'
                    onClicked: openPagesGrid.selectNextPage()
                }

                Common.ImageButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                    image: 'menu-145772'
                    onClicked: minimizePage()
                }
            }
        }

        Item {
            id: showPageItem

            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    Common.SuperposedMenu {
        id: contextSelectorDialog

        title: qsTr('Contexts')

        ListView {
            id: contextsList

            height: contentItem.height
            width: contextSelectorDialog.parentWidth * 0.8

            model: contextsModel
            delegate: Rectangle {
                width: contextsList.width
                height: units.fingerUnit * 2
                color: (ListView.isCurrentItem)?'yellow':'white'
                Text {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    verticalAlignment: Text.AlignVCenter
                    text: model.id
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        selectedContext = model.id;
                        contextSelectorDialog.close();
                        sectionsModel.reselect();
                    }
                }
            }
        }
        Common.SuperposedButton {
            size: units.fingerUnit * 1.5
            imageSource: 'plus-24844'

            onClicked: {
                contextSelectorDialog.close();
                newContextDialog.open();
            }
        }
    }

    Common.SuperposedMenu {
        id: newContextDialog

        title: qsTr('Crea context')

        RowLayout {
            width: newContextDialog.parentWidth * 0.5

            Editors.TextLineEditor {
                id: newContextText
                Layout.fillWidth: true
                Layout.preferredHeight: units.fingerUnit * 1.5
            }
            Common.TextButton {
                Layout.preferredWidth: units.fingerUnit * 3
                Layout.preferredHeight: units.fingerUnit * 1.5
                text: qsTr('Desa')
                onClicked: {
                    var newContext = newContextText.content.trim();
                    if (newContext !== '') {
                        contextsModel.insertObject({id: newContext});
                        contextsModel.select();
                        newContextDialog.close();
                        contextSelectorDialog.open();
                    }
                }
            }
        }

    }

}
