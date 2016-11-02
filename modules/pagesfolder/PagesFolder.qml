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

    signal publishMessage(string message)
    signal reloadPage()

    property string selectedContext: ''
    property int selectedSection: sectionsList.currentIndex
    property int sectionId
    property int sectionTitleWidth: units.fingerUnit * 5

    property bool pageMenuVisible: false

    onSelectedContextChanged: {
        sectionPages.clear();
        sectionsModel.reselect();
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
                var section = selectedSection;
                sectionsModel.reselect();
                console.log('editada seccio', section);
                sectionsList.chooseSection(section);
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

    Common.SuperposedWidget {
        id: parametersDialog

        title: qsTr('Edita els paràmetres')

        function openParametersEditor() {
            parametersDialog.load(qsTr('Edita els paràmetres'), 'pagesfolder/ParametersEditor', {sectionId: sectionId});
        }

        Connections {
            target: parametersDialog.mainItem

            onParametersSaved: {
                parametersDialog.close();
                pagesFolderItem.publishMessage(qsTr("Nous paràmetres desats."));
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
            sectionsList.chooseSection(0);
        }

        function deleteSection(section, title) {
            sectionsModel.removeObject(section);
            sectionsModel.reselect();
            sectionsList.chooseSection(0);
            pagesFolderItem.publishMessage("S'ha esborrat la secció «" + title + "».");
        }
    }

    Item {
        id: contextSelectorItem

        anchors {
            top: parent.top
            left: parent.left
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
            top: contextSelectorItem.bottom
            left: parent.left
            right: sectionButtons.left
            rightMargin: units.nailUnit
        }
        height: units.fingerUnit * 1.5

        onWidthChanged: sectionsList.positionViewAtIndex(selectedSection, ListView.Contain)

        orientation: ListView.Horizontal
        clip: true

        model: sectionsModel
        spacing: units.fingerUnit

        onMovementStarted: pageMenuVisible = false

        delegate: Item {
            id: sectionItem

            objectName: 'section'

            z: 1
            width: sectionTitleWidth
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
                    if (sectionId == model.id) {
                        pageMenuVisible = true;
                    } else {
                        pageMenuVisible = false;
                        sectionItem.chooseThisSection();
                    }
                }
            }
            function chooseThisSection() {
                sectionId = model.id;
                sectionsList.currentIndex = model.index;
                sectionPages.replacePage(model.page, model.parameters);
            }
        }

        function chooseSection(newSection) {
            var sectionObjects = sectionsList.currentItem.children;
            var sectionIdx = 0;
            for (var i=0; i<sectionObjects.length; i++) {
                if (sectionObjects.objectName == 'section') {
                    if (sectionIdx == newSection) {
                        sectionObjects[sectionIdx].chooseThisSection();
                        break;
                    }
                    sectionIdx++;
                }
            }
        }
    }

    Basic.ButtonsRow {
        id: sectionButtons

        anchors {
            top: contextSelectorItem.bottom
            right: parent.right
        }
        height: units.fingerUnit * 1.5
        width: (pageMenuVisible)?parent.width - sectionTitleWidth - sectionsList.anchors.rightMargin:0
        margins: units.fingerUnit / 4
        visible: pageMenuVisible

        clip: true

        Common.ImageButton {
            width: size
            height: size
            size: units.fingerUnit

            image: 'plus-24844'

            onClicked: {
                newSectionDialog.openNewSection();
            }
        }

        Common.ImageButton {
            width: size
            height: size
            size: units.fingerUnit

            image: 'edit-153612'

            onClicked: {
                var object = sectionsModel.getObjectInRow(sectionsList.currentIndex);
                sectionEditorDialog.openTitleEditor(object.id, object.title);
            }
        }

        Common.ImageButton {
            width: size
            height: size
            size: units.fingerUnit

            image: 'cog-147414'

            onClicked: parametersDialog.openParametersEditor()
        }

        Common.TextButton {
            height: units.fingerUnit
            text: qsTr('Ordena')
            onClicked: sectionsListDialog.openReordering();
        }

        Common.TextButton {
            height: units.fingerUnit
            text: qsTr('Actualitza')
            onClicked: {
                reloadPage();
                pageMenuVisible = false;
            }
        }

        Common.ImageButton {
            width: size
            height: size
            size: units.fingerUnit

            image: 'garbage-1295900'

            onClicked: confirmSectionDeletion.openConfirmDeletion();

            MessageDialog {
                id: confirmSectionDeletion

                property string sectionTitle

                title: qsTr("Esborrat de secció")

                standardButtons: StandardButton.Ok | StandardButton.Cancel

                function openConfirmDeletion() {
                    sectionTitle = sectionsModel.getObjectInRow(selectedSection)['title'];
                    text = qsTr("S'esborrarà la secció «" + sectionTitle + "». Vols continuar?");
                    open();
                }

                onAccepted: {
                    sectionsModel.deleteSection(sectionId, sectionTitle);
                }
            }
        }

        Common.ImageButton {
            width: size
            height: size
            size: units.fingerUnit

            image: 'road-sign-147409'

            onClicked: pageMenuVisible = false
        }
    }

    Common.SuperposedButton {
        id: sectionOptionsButton

        z: 2
        anchors {
            top: parent.top
            right: parent.right
        }
        size: units.fingerUnit

        margins: units.nailUnit
        backgroundColor: 'white'
        imageSource: 'comment-27179'
        onClicked: {
            if (sectionsModel.count > 0)
                pageMenuVisible = true;
            else
                newSectionDialog.openNewSection();
        }
    }


    StackView {
        id: sectionPages

        z: 3

        anchors {
            top: sectionsList.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        function replacePage(page, parameters) {
            // Parameters must be a JSON array
            var parsedParameters = {};
            try {
                parsedParameters = JSON.parse(parameters);
            }catch(e) {
            }

            clear();
            push({item: 'qrc:///modules/' + page + '.qml', properties: parsedParameters}, replace);
        }

        function addPage(page, parameters) {
            // Parameters must be an associative array
            push({item: 'qrc:///modules/' + page + '.qml', properties: parameters});
        }

        function goBack() {
            if (depth>1) {
                pop();
                console.log('reload', typeof currentItem.reload);
                if (typeof currentItem.reload == 'function') {
                    console.log('Reloading...');
                    currentItem.reload();
                }
            }
        }

        onCurrentItemChanged: {
            pageConnections.target = sectionPages.currentItem;

            pageConnections.destination = sectionPages;
            pageConnections.primarySource = sectionPages.get((depth>1)?sectionPages.depth-1:0)
        }

        Common.ImageButton {
            id: subPagePositionImage

            z: 5
            anchors {
                top: parent.top
                left: parent.left
            }
            size: units.fingerUnit * 1.5
            image: 'arrow-145769'
            visible: sectionPages.depth>1
            onClicked: {
                sectionPages.goBack();
            }
        }

        Connections {
            target: sectionPages.currentItem
            ignoreUnknownSignals: true

            onPublishMessage: pagesFolderItem.publishMessage(message)
        }

        PageConnections {
            id: pageConnections

            stack: sectionPages
        }

        MouseArea {
            anchors.fill: parent

            z: 200

            onPressed: {
                console.log('hola');
                mouse.accepted = false;
                pageMenuVisible = false;
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

    }

    function closeCurrentPage() {
        sectionPages.goBack();
    }
}
