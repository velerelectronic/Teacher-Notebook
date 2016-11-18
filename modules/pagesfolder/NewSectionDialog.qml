import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors
import 'qrc:///models' as Models

Rectangle {
    id: chooseSectionDialog

    property string selectedContext: ''
    property int selectedContextIndex: -1

    signal contextSelected(string context)

    color: '#DDDDDD'
    clip: true

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

    ColumnLayout {
        anchors.fill: parent

        ListView {
            id: contextsList
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 2

            model: contextsModel
            spacing: units.fingerUnit
            orientation: ListView.Horizontal

            delegate: Common.BoxedText {
                height: contextsList.height
                width: contextsList.height * 3
                margins: units.nailUnit

                border.width: 0
                text: model.id

                color: (ListView.isCurrentItem)?'white':'#999999'

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        selectedContextIndex = model.index;
                        contextsList.currentIndex = model.index;
                        selectedContext = model.id;
                        contextSelected(selectedContext);
                        sectionsModel.reselect();
                    }
                }

                Component.onCompleted: {
                    if (selectedContext == model.id) {
                        selectedContextIndex = model.index;
                        contextsList.currentIndex = selectedContextIndex;
                    }
                }
            }

            onCurrentIndexChanged: {
                if (selectedContextIndex !== contextsList.currentIndex) {
                    contextsList.currentIndex = selectedContextIndex;
                }
            }

            footer: Common.SuperposedButton {
                size: units.fingerUnit * 1.5
                imageSource: 'plus-24844'

                onClicked: {
                    //sectionsDialog.close();
                    newContextDialog.open();
                }
            }

        }

        GridView {
            id: sectionsGrid

            Layout.fillHeight: true
            Layout.fillWidth: true

            cellWidth: width / 5
            cellHeight: cellWidth * (pagesFolderItem.height / pagesFolderItem.width)

            clip: true
            model: sectionsModel

            delegate: Item {
                id: singlePageItem

                width: sectionsGrid.cellWidth
                height: sectionsGrid.cellHeight

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

                    onClicked: {
                        openPagesModel.addPage(model.page, model.parameters, model.title)
                    }
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
                    width: sectionsGrid.cellWidth
                    height: sectionsGrid.cellHeight

                    padding: units.nailUnit
                    border.width: units.nailUnit
                    border.color: 'gray'
                    color: 'transparent'

                    image: 'plus-24844'

                    onClicked: newSectionDialog.openNewSection()
                }
            }

            Component.onCompleted: sectionsModel.reselect()
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
