import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import QtQuick.Dialogs 1.2

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

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: units.fingerUnit * 4

                                border.color: 'black'

                                GridLayout {
                                    anchors.fill: parent

                                    columns: 3

                                    columnSpacing: units.nailUnit * 2
                                    rowSpacing: units.nailUnit * 2

                                    Text {
                                        width: headerData.width / 2
                                        height: units.fingerUnit
                                        font.pixelSize: units.readUnit
                                        text: qsTr('Títol:')
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        height: contentHeight
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: units.readUnit
                                        elide: Text.ElideRight
                                        text: showWorkFlowItem.title
                                    }

                                    Common.ImageButton {
                                        id: changeTitleButton
                                        Layout.fillHeight: true
                                        Layout.preferredWidth: size
                                        size: units.fingerUnit
                                        image: 'edit-153612'
                                        onClicked: workFlowTitleEditorDialog.openEditor()
                                    }

                                    Text {
                                        font.pixelSize: units.readUnit
                                        text: qsTr('Descripció:')
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        height: contentHeight
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        font.pixelSize: units.readUnit

                                        text: showWorkFlowItem.desc
                                    }
                                    Common.ImageButton {
                                        id: changePeriodButton
                                        Layout.fillHeight: true
                                        Layout.preferredWidth: size
                                        size: units.fingerUnit
                                        image: 'edit-153612'
                                        onClicked: descEditorDialog.openEditor()
                                    }
                                }
                            }

                            ListView {
                                id: expandedStatesList

                                Layout.fillWidth: true
                                Layout.preferredHeight: partsList.height

                                property int headingsHeight: units.fingerUnit * 1.5

                                clip: true
                                orientation: ListView.Horizontal

                                snapMode: ListView.SnapToItem
                                boundsBehavior: ListView.StopAtBounds

                                spacing: units.fingerUnit
                                model: workFlowStatesModel

                                delegate: Item {
                                    id: singleStateRect

                                    width: units.fingerUnit * 5
                                    height: expandedStatesList.height

                                    property int stateId: model.id

                                    Models.WorkFlowAnnotations {
                                        id: annotationsModel

                                        filters: ['workFlowState=?']

                                        function addAnnotation() {
                                            insertObject({title: qsTr('Nova anotació'), workFlowState: singleStateRect.stateId});
                                            update();
                                        }

                                        function update() {
                                            bindValues = [singleStateRect.stateId];
                                            select();
                                        }

                                        Component.onCompleted: update()
                                    }

                                    ColumnLayout {
                                        anchors.fill: parent

                                        Common.BoxedText {
                                            Layout.preferredHeight: expandedStatesList.headingsHeight
                                            Layout.fillWidth: true
                                            margins: units.nailUnit

                                            boldFont: true

                                            text: model.title
                                        }

                                        ListView {
                                            id: annotationsList

                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            model: annotationsModel
                                            spacing: units.nailUnit

                                            delegate: Common.BoxedText {
                                                width: annotationsList.width
                                                height: contentHeight + 2 * margins
                                                margins: units.nailUnit

                                                text: model.title
                                            }

                                            footer: Common.BoxedText {
                                                width: annotationsList.width
                                                height: contentHeight

                                                text: qsTr('Afegeix anotació')

                                                MouseArea {
                                                    anchors.fill: parent
                                                    onClicked: annotationsModel.addAnnotation()
                                                }
                                            }
                                        }
                                    }
                                }

                                footer: Item {
                                    width: units.fingerUnit * 5 + expandedStatesList.spacing
                                    height: expandedStatesList.height

                                    Common.BoxedText {
                                        anchors {
                                            top: parent.top
                                            left: parent.left
                                            right: parent.right
                                            leftMargin: expandedStatesList.spacing
                                        }
                                        height: expandedStatesList.headingsHeight
                                        margins: units.nailUnit

                                        text: qsTr('Afegeix estat...')

                                        MouseArea {
                                            anchors.fill: parent

                                            onClicked: workFlowStatesModel.addNewState()
                                        }
                                    }
                                }
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

                        Common.SuperposedMenu {
                            id: stateTitleEditorDialog

                            title: qsTr("Edita el títol")
                            property int workFlow: -1

                            standardButtons: StandardButton.Save | StandardButton.Cancel

                            Editors.TextAreaEditor3 {
                                id: stateTitleEditor
                                width: parent.width
                            }

                            function openEditor(workFlow, stateTitle) {
                                stateTitleEditorDialog.workFlow = workFlow;
                                stateTitleEditor.content = stateTitle;
                                open();
                            }

                            onAccepted: {
                                workFlowStatesModel.updateObject(stateTitleEditorDialog.workFlow, {title: stateTitleEditor.content});
                                workFlowStatesModel.select();
                            }
                        }

                        Common.SuperposedMenu {
                            id: stateDescEditorDialog

                            title: qsTr("Edita la descripció")
                            property int workFlow: -1

                            standardButtons: StandardButton.Save | StandardButton.Cancel

                            Editors.TextAreaEditor3 {
                                id: stateDescEditor
                                width: parent.width
                            }

                            function openEditor(workFlow, stateDesc) {
                                stateDescEditorDialog.workFlow = workFlow;
                                stateDescEditor.content = stateDesc;
                                open();
                            }

                            onAccepted: {
                                workFlowStatesModel.updateObject(stateDescEditorDialog.workFlow, {desc: stateDescEditor.content});
                                workFlowStatesModel.select();
                            }
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

        parentWidth: parent.width

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

        parentWidth: parent.width

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


    Component.onCompleted: getText()
}
