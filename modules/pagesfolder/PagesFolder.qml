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

    signal goBack()
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
                id: singlePageItem

                width: openPagesGrid.cellWidth
                height: openPagesGrid.cellHeight

                states: [
                    State {
                        name: 'editable'
                        PropertyChanges {
                            target: editLayout
                            visible: true
                        }
                    },
                    State {
                        name: 'selectable'
                        PropertyChanges {
                            target: editLayout
                            visible: false
                        }
                    }
                ]

                state: 'selectable'

                property string sectionId: model.id
                property string sectionTitle: model.title

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

                    enabled: singlePageItem.state == 'selectable'

                    onClicked: openPagesModel.addPage(model.page, model.parameters, model.title)
                    onPressAndHold: {
                        singlePageItem.state = 'editable';
                    }
                }

                GridLayout {
                    id: editLayout

                    anchors.fill: parent

                    rows: 3
                    columns: 3

                    Common.ImageButton {
                        Layout.preferredHeight: units.fingerUnit
                        Layout.preferredWidth: units.fingerUnit

                        image: 'edit-153612'

                        onClicked: sectionEditorDialog.openTitleEditor(singlePageItem.sectionId, singlePageItem.sectionTitle)
                    }

                    Common.ImageButton {
                        Layout.preferredHeight: units.fingerUnit
                        Layout.fillWidth: true

                        image: 'cog-147414'

                        onClicked: parametersDialog.openParametersEditor(singlePageItem.sectionId)
                    }

                    Common.ImageButton {
                        Layout.preferredHeight: units.fingerUnit
                        Layout.preferredWidth: units.fingerUnit

                        image: 'road-sign-147409'

                        onClicked: singlePageItem.state = 'selectable'
                    }

                    Common.ImageButton {
                        Layout.fillHeight: true
                        Layout.preferredWidth: units.fingerUnit

                        image: 'arrow-145769'
                    }

                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }

                    Common.ImageButton {
                        Layout.fillHeight: true
                        Layout.preferredWidth: units.fingerUnit

                        image: 'arrow-145766'
                    }

                    Common.ImageButton {
                        Layout.preferredHeight: units.fingerUnit
                        Layout.preferredWidth: units.fingerUnit

                        image: 'garbage-1295900'

                        onClicked: confirmSectionDeletion.openConfirmDeletion();

                        MessageDialog {
                            id: confirmSectionDeletion

                            title: qsTr("Esborrat de secció")

                            standardButtons: StandardButton.Ok | StandardButton.Cancel

                            function openConfirmDeletion() {
                                text = qsTr("S'esborrarà la secció «" + singlePageItem.sectionTitle + "». Vols continuar?");
                                open();
                            }

                            onAccepted: {
                                sectionsModel.deleteSection(singlePageItem.sectionId, singlePageItem.sectionTitle);
                            }
                        }
                    }
                }
            }

            footer: (selectedContext !== '')?footerComponent:null

            Component {
                id: footerComponent

                Common.ImageButton {
                    width: openPagesGrid.cellWidth
                    height: openPagesGrid.cellHeight

                    padding: units.nailUnit
                    border.width: units.nailUnit
                    border.color: 'gray'
                    color: 'transparent'

                    image: 'plus-24844'

                    onClicked: newSectionDialog.openNewSection()
                }
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height

            color: 'gray'

            GridView {
                id: openPagesGrid

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                height: contentItem.height

                cellWidth: width / 5
                cellHeight: cellWidth * (pagesFolderItem.height / pagesFolderItem.width)

                model: openPagesModel
                interactive: false

                delegate: Item {
                    id: openPageRect

                    width: openPagesGrid.cellWidth
                    height: openPagesGrid.cellHeight

                    property string pageTitle: model.title

                    states: [
                        State {
                            name: 'minimized'

                            ParentChange {
                                target: openPageLoader
                                parent: openPageBackground
                            }
                            PropertyChanges {
                                target: openPageLoader
                                scale: openPageBackground.width / showPageItem.width
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
                            PropertyChanges {
                                target: openPageLoader
                                scale: 1
                            }
                        }
                    ]

                    state: 'minimized'
                    /*
                    transitions: Transition {
                        ParentAnimation {
                            NumberAnimation {
                                duration: 1000
                                properties: 'x, y'
                            }
                            NumberAnimation {
                                duration: 1000
                                properties: 'scale'
                            }
                            via: pagesFolderItem

                        }
                    }
                    */

                    PageConnections {
                        id: pageConnections

                        destination: openPageLoader
                        stack: openPageLoader
                    }

                    Rectangle {
                        id: openPageBackground

                        anchors.fill: parent
                        anchors.margins: units.nailUnit

                        StackView {
                            id: openPageLoader

                            z: 1
                            anchors {
                                top: parent.top
                                left: parent.left
                            }

                            width: showPageItem.width
                            height: showPageItem.height

                            transformOrigin: Item.TopLeft

                            function addPage(page, parameters) {
                                // Parameters must be an associative array
                                console.log('page--->');
                                console.log('qrc:///modules/' + page + '.qml', parameters);
                                openPageLoader.push({item: 'qrc:///modules/' + page + '.qml', properties: parameters});
                            }

                            function goBack() {
                                if (depth>1) {
                                    pop();
                                }
                            }

                            onCurrentItemChanged: {
                                console.log('current item changed');
                                pageConnections.target = openPageLoader.currentItem;

                                pageConnections.destination = openPageLoader;
                                pageConnections.primarySource = openPageLoader.get((depth>1)?openPageLoader.depth-1:0)
                            }

                            Component.onCompleted: {
                                console.log('opening', model.page, model.parameters);
                                var parameters = (model.parameters !== '')?JSON.parse(model.parameters):{};
                                openPageLoader.addPage(model.page, parameters);
                            }


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

                        onGoBack: openPageLoader.goBack()
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

                Common.ImageButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                    image: 'arrow-145769'
                    onClicked: goBack()
                }

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
                    image: 'menu-145772'
                    onClicked: minimizePage()
                }

                Common.ImageButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                    image: 'arrow-145766'
                    onClicked: openPagesGrid.selectNextPage()
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
                sectionsModel.insertObject({context: selectedContext, page: page, title: title, position: sectionsModel.count+1});
                sectionsModel.reselect();
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
                pagesFolderItem.publishMessage(qsTr("S'ha canviat el títol a «") + sectionEditorDialog.mainItem.title + "».");
                sectionsModel.reselect();
                sectionEditorDialog.close();
            }
        }
    }

    Common.SuperposedWidget {
        id: parametersDialog

        title: qsTr('Edita els paràmetres')

        function openParametersEditor(section) {
            parametersDialog.load(qsTr('Edita els paràmetres'), 'pagesfolder/ParametersEditor', {sectionId: section});
        }

        Connections {
            target: parametersDialog.mainItem

            onParametersSaved: {
                parametersDialog.close();
                pagesFolderItem.publishMessage(qsTr("Nous paràmetres desats."));
            }
        }
    }

}
