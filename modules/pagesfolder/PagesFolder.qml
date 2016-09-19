import QtQuick 2.5
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors
import 'qrc:///modules/documents' as Documents
import 'qrc:///modules/basic' as Basic
import 'qrc:///modules/pagesfolder' as PagesFolder

Item {
    property string selectedContext: ''
    property int selectedSection: sectionsList.currentIndex

    onSelectedContextChanged: {
        sectionsModel.reselect();
        sectionsList.chooseSection(0);
    }

    Common.UseUnits {
        id: units
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

    Common.SuperposedMenu {
        id: sectionOptionsDialog

        title: qsTr('Opcions de la secció')
        property int section
        property string sectionTitle: ''

        function openSectionOptions(section, title) {
            sectionOptionsDialog.section = section;
            sectionOptionsDialog.sectionTitle = title;
            sectionOptionsDialog.open();
        }

        Common.SuperposedMenuEntry {
            text: qsTr('Edita el títol')
            onClicked: {
                sectionOptionsDialog.close();
                sectionEditorDialog.openTitleEditor(sectionOptionsDialog.section, sectionOptionsDialog.sectionTitle);
            }
        }

        Common.SuperposedMenuEntry {
            text: qsTr('Edita els paràmetres')
            onClicked: {
                sectionOptionsDialog.close();
            }
        }

        Common.SuperposedMenuEntry {
            text: qsTr('Esborra (directament)')
            onClicked: {
                sectionsModel.deleteSection(sectionOptionsDialog.section);
                sectionOptionsDialog.close();
            }
        }

        Common.SuperposedMenuEntry {
            text: qsTr('Reordena les seccions')
            onClicked: {
                sectionOptionsDialog.close();
                sectionsListDialog.openReordering();
            }
        }
    }

    Common.SuperposedWidget {
        id: newSectionDialog

        function openNewSection() {
            load(qsTr('Nova secció'), 'pagesfolder/NewPageSection', {});
            open();
        }

        Connections {
            target: newSectionDialog.mainItem
            ignoreUnknownSignals: true

            onSectionSelected: {
                sectionsModel.insertObject({context: selectedContext, page: page, parameters: parameters, title: title, position: sectionsModel.count+1});
                sectionsModel.reselect();
                sectionsList.chooseSection(sectionsModel.count-1);
                newSectionDialog.close();
            }
        }
    }

    Common.SuperposedWidget {
        id: sectionEditorDialog

        function openTitleEditor(section, title) {
            load(qsTr('Edita el títol'), 'pagesfolder/TitleSectionEditor', {section: section, title: title, sectionsModel: sectionsModel});
        }

        Connections {
            target: sectionEditorDialog.mainItem
            ignoreUnknownSignals: true

            onSectionTitleChanged: {
                sectionsModel.reselect();
                sectionsList.chooseSection(selectedSection);
                sectionEditorDialog.close();
            }
        }
    }

    Common.SuperposedWidget {
        id: sectionsListDialog

        function openReordering() {
            console.log('reopening')
            load(qsTr('Reordena les seccions'), 'pagesfolder/SectionsList', {sectionsModel: sectionsModel});
        }

        Connections {
            target: sectionsListDialog.mainItem

            onSectionsReordered: {
                sectionsModel.reselect();
                sectionsList.chooseSection(0);
            }
        }
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

        function deleteSection(section) {
            sectionsModel.removeObject(section);
            sectionsModel.reselect();
            sectionsList.chooseSection(0);
        }
    }

    Item {
        id: contextSelectorItem

        anchors {
            top: parent.top
            left: parent.left
            leftMargin: units.fingerUnit + units.nailUnit
        }
        width: Math.min(parent.width / 3, invisibleFolderButton.contentWidth + 2 * units.nailUnit)
        height: units.fingerUnit * 1.5

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

    ListView {
        id: sectionsList

        anchors {
            top: parent.top
            left: contextSelectorItem.right
            right: parent.right
            leftMargin: units.nailUnit
        }
        height: units.fingerUnit * 1.5

        clip: true
        orientation: ListView.Horizontal
        spacing: units.nailUnit

        boundsBehavior: Flickable.StopAtBounds

        model: sectionsModel

        delegate: Item {
            id: sectionItem

            z: 1
            width: units.fingerUnit * 4
            height: sectionsList.height
            Rectangle {
                anchors.fill: parent
                color: 'white'
                opacity: (sectionItem.ListView.isCurrentItem)?1:0.2
            }
            Text {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                font.pixelSize: units.readUnit
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.bold: sectionItem.ListView.isCurrentItem
                text: model.title
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    sectionsList.chooseSection(model.index);
                }
                onPressAndHold: {
                    sectionOptionsDialog.openSectionOptions(model.id, model.title);
                }
            }
        }

        footerPositioning: ListView.OverlayFooter
        footer: Common.SuperposedButton {
            id: addSectionButton
            z: 2
            height: sectionsList.height
            width: addSectionButton.height
            margins: units.nailUnit
            imageSource: 'plus-24844'
            onClicked: {
                newSectionDialog.openNewSection()
            }
        }

        function chooseSection(newSection) {
            sectionsList.currentIndex = newSection;
            sectionPages.currentIndex = newSection;
        }
    }
    Item {
        id: sectionPages

        anchors {
            top: contextSelectorItem.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        property int currentIndex: -1

        Repeater {
            model: sectionsModel

            Item {
                id: pageItem

                z: 1
                anchors.fill: parent

                property bool isCurrentItem: (sectionPages.currentIndex == model.index)
                visible: isCurrentItem

                MouseArea {
                    id: mouseAreaPrevent
                    anchors.fill: parent
                    // The view should only be draggable on the sides
                    anchors.leftMargin: units.fingerUnit
                    anchors.rightMargin: units.fingerUnit
                    propagateComposedEvents: false
                    preventStealing: true
                    onPressed: {
                        console.log('ohhh')
                        mouse.accepted = true;
                    }
                }

                Loader {
                    id: pageLoader
                    z: 2
                    anchors.fill: parent

                    function loadContents() {
                        console.log('loading contents');
                        var paramArray = {};
                        if (model.parameters != '') {
                            paramArray = JSON.parse(model.parameters);
                        }
                        pageLoader.setSource('qrc:///modules/' + model.page + '.qml', paramArray);
                        loadPageButton.visible = false;
                    }
                }

                onIsCurrentItemChanged: {
                    if (pageLoader.sourceComponent == null) {
                        console.log('loading...');
                        pageLoader.loadContents();
                    }
                }

                Text {
                    id: loadPageButton

                    anchors.centerIn: parent
                    text: qsTr('Carregant...')
                }
            }
        }


    }
}
