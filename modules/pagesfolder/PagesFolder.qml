import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors
import 'qrc:///modules/documents' as Documents
import 'qrc:///modules/basic' as Basic
import 'qrc:///modules/pagesfolder' as PagesFolder

Item {
    id: pagesFolderItem

    signal reloadPage()
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

        Common.SuperposedMenuEntry {
            text: qsTr('Recarrega')
            onClicked: {
                sectionOptionsDialog.close();
                reloadPage();
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

                ListModel {
                    id: lastPagesModel
                }

                ColumnLayout {
                    anchors.fill: parent

                    ListView {
                        id: previousPagesList

                        Layout.fillWidth: true
                        Layout.preferredHeight: units.fingerUnit * 2

                        orientation: ListView.Horizontal
                        spacing: units.nailUnit

                        model: lastPagesModel

                        delegate: Rectangle {
                            border.color: 'black'
                            height: previousPagesList.height
                            width: height * 2

                            Text {
                                anchors.fill: parent
                                anchors.margins: units.nailUnit
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.title
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: pageLoader.loadPage(model.page, JSON.parse(model.parameters));
                                onPressAndHold: {
                                    if ((model.index > 0) && (lastPagesModel.count>=2)) {
                                        var prevObj = lastPagesModel.get(model.index-1);
                                        lastPagesModel.remove(model.index);
                                        pageLoader.loadPage(prevObj.page, JSON.parse(prevObj.parameters));
                                    }
                                }
                            }
                        }
                    }

                    Loader {
                        id: pageLoader
                        z: 2
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        property string page: model.page
                        property string parameters: model.parameters

                        function trytoLoadContents() {
                            if (pageLoader.sourceComponent !== null) {
                                if (pageLoader.item.changes)
                                    confirmDiscardChangesDialog.open();
                            } else {
                                pageLoader.appendToLastPages(pageLoader.page, pageLoader.page, pageLoader.parameters);
                                pageLoader.loadContents();
                            }

                        }

                        function loadContents() {
                            var paramArray = {};
                            if (pageLoader.parameters != '') {
                                paramArray = JSON.parse(pageLoader.parameters);
                            }
                            pageLoader.setSource('qrc:///modules/' + pageLoader.page + '.qml', paramArray);
                        }

                        function reloadContents() {
                            pageLoader.sourceComponent = undefined;
                            loadContents();
                        }

                        function loadPage(page, param) {
                            pageLoader.page = page;
                            pageLoader.parameters = JSON.stringify(param);
                            appendToLastPages(page, page, JSON.stringify(param));
                            pageLoader.setSource('qrc:///modules/' + page + '.qml', param);
                        }

                        function appendToLastPages(title, page, param) {
                            var i=0;
                            var found = false;
                            while (i<lastPagesModel.count) {
                                var pageObj = lastPagesModel.get(i);
                                if (pageObj.page == page) {
                                    lastPagesModel.setProperty(i, "parameters", param);
                                    found = true;
                                }
                                i++;
                            }

                            if (!found)
                                lastPagesModel.append({title: title, page: page, parameters: param});
                        }

                        Connections {
                            target: pagesFolderItem

                            onReloadPage: pageLoader.trytoLoadContents()
                        }

                        PageConnections {
                            target: pageLoader.item
                            destination: pageLoader
                        }
                    }
                }

                MessageDialog {
                    id: confirmDiscardChangesDialog

                    title: qsTr('Canviar de pàgina')
                    text: qsTr("Si canvies de pàgina, es perdran els canvis. Estàs segur de voler continuar?")

                    standardButtons: StandardButton.Yes | StandardButton.No

                    onYes: {
                        pageLoader.reloadContents();
                    }

                    onNo: confirmCloseDialog.close()
                }

                onIsCurrentItemChanged: {
                    pageLoader.trytoLoadContents()
                }
            }
        }


    }
}
