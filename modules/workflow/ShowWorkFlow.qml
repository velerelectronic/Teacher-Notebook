import QtQuick 2.6
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.0

import ClipboardAdapter 1.0
import PersonalTypes 1.0

import ImageItem 1.0

import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors
import 'qrc:///modules/documents' as Documents
import 'qrc:///modules/calendar' as Calendar
import 'qrc:///modules/files' as Files
import 'qrc:///modules/connections' as AnnotationsConnections

Item {
    id: showWorkFlowItem

    property alias identifier: showWorkFlowItem.title
    property string title: ''
    property string desc: ''

    signal workFlowAnnotationSelected(int annotation)

    Common.UseUnits {
        id: units
    }

    Models.WorkFlows {
        id: workFlowsModel
    }

    Models.WorkFlowStates {
        id: workFlowStatesModel

        filters: ['workFlow=?']

        function update() {
            bindValues = [showWorkFlowItem.identifier]
            select();
        }

        function addNewState() {
            insertObject({title: qsTr('Nou estat'), workFlow: showWorkFlowItem.identifier});
            update();
        }

        Component.onCompleted: update()
    }

    MarkDownParser {
        id: parser
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: units.nailUnit

        Common.HorizontalStaticMenu {
            id: optionsMenu
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 2

            spacing: units.nailUnit
            underlineColor: 'orange'
            underlineWidth: units.nailUnit

            sectionsModel: workFlowSectionsModel
            connectedList: partsList
        }

        ListView {
            id: partsList
            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true

            spacing: units.fingerUnit

            model: ObjectModel {
                id: workFlowSectionsModel

                Common.BasicSection {
                    width: partsList.width
                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Principal')

                    Rectangle {
                        id: headerData
                        width: parent.width
                        height: childrenRect.height
                        color: 'gray'

                        ColumnLayout {
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                            }
                            height: childrenRect.height
                            spacing: 0

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: titleText.height + descText.height

                                border.color: 'black'

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 0

                                    Text {
                                        id: titleText

                                        Layout.fillWidth: true
                                        Layout.minimumHeight: units.fingerUnit
                                        height: contentHeight
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: units.glanceUnit
                                        font.bold: true
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        padding: units.nailUnit
                                        elide: Text.ElideRight
                                        text: showWorkFlowItem.title
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: workFlowTitleEditorDialog.openEditor()
                                        }
                                    }

                                    Text {
                                        id: descText

                                        Layout.fillWidth: true
                                        Layout.minimumHeight: units.fingerUnit
                                        height: contentHeight
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        padding: units.nailUnit
                                        font.pixelSize: units.readUnit

                                        color: (showWorkFlowItem.desc !== '')?'black':'gray'
                                        text: (showWorkFlowItem.desc !== '')?showWorkFlowItem.desc:qsTr('Edita per a una descripció...')

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: descEditorDialog.openEditor()
                                        }
                                    }

                                }
                            }

                            Item {
                                Layout.preferredHeight: Math.max(units.fingerUnit * 1.5, labelsFilter.height)
                                Layout.fillWidth: true

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: units.nailUnit
                                    spacing: units.nailUnit

                                    Text {
                                        Layout.preferredWidth: contentWidth
                                        Layout.fillHeight: true

                                        font.pixelSize: units.readUnit
                                        text: qsTr('Filtra')
                                    }

                                    LabelsAnnotationsFilter {
                                        id: labelsFilter

                                        Layout.preferredHeight: requiredHeight
                                        Layout.fillWidth: true

                                        labelHeight: units.fingerUnit
                                        workFlow: identifier
                                    }

                                    Common.SearchBox {
                                        id: annotationsSearchBox

                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                    }
                                }
                            }

                            ListView {
                                id: expandedStatesList

                                Layout.fillWidth: true
                                Layout.preferredHeight: showWorkFlowItem.height / 2

                                property int headingsHeight: units.fingerUnit * 2
                                property int commonColumnsWidth: units.fingerUnit * 10

                                clip: true
                                orientation: ListView.Horizontal

                                snapMode: ListView.SnapToItem
                                boundsBehavior: ListView.StopAtBounds

                                ScrollBar.horizontal: ScrollBar {
                                    anchors {
                                        bottom: parent.bottom
                                        left: parent.left
                                        right: parent.right
                                    }

                                    active: true
                                }

                                spacing: units.fingerUnit
                                model: workFlowStatesModel

                                delegate: Item {
                                    id: singleStateRect

                                    width: expandedStatesList.commonColumnsWidth
                                    height: expandedStatesList.height

                                    property int stateId: model.id

                                    AnnotationsList {
                                        id: annotationsList

                                        anchors {
                                            top: parent.top
                                            left: parent.left
                                            right: parent.right
                                            margins: units.nailUnit
                                        }
                                        maximumHeight: singleStateRect.height - 2 * anchors.margins

                                        headingsHeight: expandedStatesList.headingsHeight
                                        parentWorkFlow: showWorkFlowItem.identifier
                                        workFlowState: singleStateRect.stateId
                                        searchString: annotationsSearchBox.text

                                        onWorkFlowAnnotationSelected: showWorkFlowItem.workFlowAnnotationSelected(annotation)
                                        onWorkFlowUpdateRequested: workFlowStatesModel.update()

                                        Connections {
                                            target: annotationsSearchBox

                                            onPerformSearch: annotationsList.update()
                                        }
                                    }
                                }

                                footer: Item {
                                    width: expandedStatesList.commonColumnsWidth + expandedStatesList.spacing
                                    height: expandedStatesList.height

                                    Common.BoxedText {
                                        anchors {
                                            top: parent.top
                                            left: parent.left
                                            right: parent.right
                                            margins: units.nailUnit
                                            leftMargin: expandedStatesList.spacing
                                        }
                                        height: expandedStatesList.headingsHeight
                                        margins: units.nailUnit

                                        color: '#AAFFAA'
                                        text: qsTr('Afegeix estat...')

                                        MouseArea {
                                            anchors.fill: parent

                                            onClicked: workFlowStatesModel.addNewState()
                                        }
                                    }
                                }
                            }

                            Item {
                                id: areaForScrollbar

                                Layout.fillWidth: true
                                Layout.preferredHeight: units.fingerUnit
                            }
                        }

                    }
                }

                Common.BasicSection {
                    id: statesRect

                    width: partsList.width
                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Estats')

                    Common.GeneralListView {
                        id: statesList

                        width: parent.width
                        height: Math.min(statesList.requiredHeight, partsList.height / 2)

                        model: workFlowStatesModel

                        headingBar: Rectangle {
                            width: statesList.width
                            property int requiredHeight: units.fingerUnit

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: units.nailUnit
                                spacing: units.nailUnit

                                Text {
                                    Layout.preferredWidth: parent.width / 3
                                    Layout.fillHeight: true

                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: units.readUnit
                                    font.bold: true

                                    text: qsTr('Títol')
                                }
                                Text {
                                    Layout.preferredWidth: parent.width / 3
                                    Layout.fillHeight: true

                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: units.readUnit
                                    font.bold: true

                                    text: qsTr('Descripció')
                                }
                                Text {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: units.readUnit
                                    font.bold: true

                                    text: qsTr('Transicions')
                                }
                            }
                        }

                        delegate: Rectangle {
                            id: singleStateRect

                            width: statesList.width
                            height: units.fingerUnit * 2

                            color: '#FFAAAA'

                            property int stateId: model.id
                            property int transitionsCount: 0

                            Models.WorkFlowTransitions {
                                id: transitionsModel

                                filters: ['startState=?']

                                function getTransitionsCount() {
                                    bindValues = [singleStateRect.stateId];
                                    select();
                                    return count;
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: units.nailUnit
                                spacing: units.nailUnit

                                Text {
                                    Layout.preferredWidth: parent.width / 3
                                    Layout.fillHeight: true

                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: units.readUnit
                                    font.bold: true

                                    text: model.title

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: stateTitleEditorDialog.openEditor(singleStateRect.stateId, model.title)
                                    }
                                }
                                Text {
                                    Layout.preferredWidth: parent.width / 3
                                    Layout.fillHeight: true

                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: units.readUnit

                                    text: model.desc

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: stateDescEditorDialog.openEditor(singleStateRect.stateId, model.desc)
                                    }
                                }
                                Text {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: units.readUnit

                                    text: singleStateRect.transitionsCount
                                }
                            }
                            Component.onCompleted: {
                                singleStateRect.transitionsCount = transitionsModel.getTransitionsCount();
                            }
                        }

                        Common.SuperposedButton {
                            id: addStateButton
                            anchors {
                                right: parent.right
                                bottom: parent.bottom
                            }
                            size: units.fingerUnit * 2
                            imageSource: 'plus-24844'
                            onClicked: workFlowStatesModel.addNewState()
                        }


                    }
                }

                Common.BasicSection {
                    id: transitionsRect

                    width: partsList.width
                    height: requiredHeight

                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Transicions')

                    Common.GeneralListView {
                        id: transitionsList

                        width: parent.width
                        height: Math.min(transitionsList.requiredHeight, partsList.height / 2)

                    }
                }
            }
        }
    }


    function getText() {
        if (showWorkFlowItem.identifier != "") {
            workFlowsModel.filters = ["title = ?"];
            workFlowsModel.bindValues = [showWorkFlowItem.identifier];
            workFlowsModel.select();
        }

        if (workFlowsModel.count>0) {
            var obj;
            obj = workFlowsModel.getObjectInRow(0);
            showWorkFlowItem.title = obj['title'];
            showWorkFlowItem.desc = obj['desc'];
            console.log('desccccc', obj['desc']);
        }
    }

    function copyWorkFlowDescription() {
        clipboard.copia(showWorkFlowItem.desc);
    }


    QClipboard {
        id: clipboard
    }

    Common.SuperposedMenu {
        id: workFlowTitleEditorDialog

        parentWidth: showWorkFlowItem.width

        title: qsTr('Edita el títol')
        standardButtons: StandardButton.Save | StandardButton.Cancel

        Editors.TextAreaEditor3 {
            id: workFlowTitleEditor
            width: parent.width
            content: showWorkFlowItem.title;
        }

        function openEditor() {
            workFlowTitleEditor.content = showWorkFlowItem.title;
            open();
        }

        onAccepted: {
            workFlowsModel.updateObject(identifier, {title: workFlowTitleEditor.content});
            getText();
        }
    }

    Common.SuperposedMenu {
        id: descEditorDialog

        parentWidth: showWorkFlowItem.width

        title: qsTr('Edita la descripció')
        standardButtons: StandardButton.Save | StandardButton.Cancel

        Editors.TextAreaEditor3 {
            id: descEditor
            width: parent.width
            content: showWorkFlowItem.desc;
        }

        function openEditor() {
            descEditor.content = showWorkFlowItem.desc;
            open();
        }

        onAccepted: {
            workFlowsModel.updateObject(identifier, {desc: descEditor.content});
            getText();
        }
    }

    Common.SuperposedMenu {
        id: stateTitleEditorDialog

        title: qsTr("Edita el títol")
        property int stateId: -1

        standardButtons: StandardButton.Save | StandardButton.Cancel

        Editors.TextAreaEditor3 {
            id: stateTitleEditor
            width: parent.width
        }

        function openEditor(stateId, stateTitle) {
            stateTitleEditorDialog.stateId = stateId;
            stateTitleEditor.content = stateTitle;
            open();
        }

        onAccepted: {
            workFlowStatesModel.updateObject(stateTitleEditorDialog.stateId, {title: stateTitleEditor.content});
            workFlowStatesModel.select();
        }
    }

    Common.SuperposedMenu {
        id: stateDescEditorDialog

        title: qsTr("Edita la descripció")
        property int stateId: -1

        standardButtons: StandardButton.Save | StandardButton.Cancel

        Editors.TextAreaEditor3 {
            id: stateDescEditor
            width: parent.width
        }

        function openEditor(stateId, stateDesc) {
            stateDescEditorDialog.stateId = stateId;
            stateDescEditor.content = stateDesc;
            open();
        }

        onAccepted: {
            workFlowStatesModel.updateObject(stateDescEditorDialog.stateId, {desc: stateDescEditor.content});
            workFlowStatesModel.select();
        }
    }

    Component.onCompleted: getText()
}
