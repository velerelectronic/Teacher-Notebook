import QtQuick 2.5
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQml.Models 2.1
import QtQuick.Dialogs 1.2
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import "qrc:///javascript/Storage.js" as Storage
import "qrc:///common/FormatDates.js" as FormatDates
import PersonalTypes 1.0

CollectionInspector {
    id: annotationEditor
    pageTitle: qsTr("Editor d'anotacions (esteses)")

    signal closePage(string message)
    signal savedAnnotation(int id,string annotation,string desc)
    signal duplicatedAnnotation(string annotation,string desc)
    signal openCamera(var receiver)
    signal showEvent(var parameters)
    signal newEvent(var parameters)
    signal newResourceAttachment(var parameters)
    signal openingDocumentExternally(string document)
    signal openRubricGroupAssessment(int assessment, int rubric, var rubricsModel, var rubricsAssessmentModel)
    signal newProject()

    property alias title: titleComponent.originalContent // PRIMARY KEY
    property alias desc: descComponent.originalContent
    property alias labels: labelsComponent.originalContent
    property alias project: projectComponent.originalContent
    property alias start: projectComponent.originalContent
    property alias end: projectComponent.originalContent
    property alias state: projectComponent.originalContent

    property bool enableDeletion: resourcesComponent.enableDeletion && rubricsComponent.enableDeletion

    property var existingLabelsModel: []


    Common.UseUnits { id: units }

    onClosePageRequested: closePage('')

    onTitleChanged: fillValues()

    function save() {
        var res = false;

        var obj = {
            title: titleComponent.editedContent,
            desc: descComponent.editedContent,
            project: projectComponent.editedContent['reference'],
            labels: labelsComponent.editedContent,
            start: startComponent.translatedEditedContent,
            end: endComponent.translatedEditedContent,
            state: stateComponent.editedContent,
            created: Storage.currentTime()
        }

        console.log("OBJECT",obj);
        res = annotationsModel.insertObject(obj);

        return res;
    }

    function updateRecord(field, contents) {
        var obj = {
            title: annotationEditor.title
        };

        obj[field] = contents;

        return annotationsModel.updateObject(obj);
    }

    model: ObjectModel {
        EditTextItemInspector {
            id: titleComponent
            width: annotationEditor.width
            totalCollectionHeight: annotationEditor.totalCollectionHeight
            caption: qsTr('Títol')
            onSaveContents: {
                if (save()) {
                    notifySavedContents();
                    fillValues();
                } else {
                    annotationEditor.title = editedContent;
                    enableShowMode();
                    fillValues();
                }
            }
        }
        EditTextAreaInspector {
            id: descComponent
            width: annotationEditor.width
            totalCollectionHeight: annotationEditor.totalCollectionHeight
            caption: qsTr('Descripció')
            onSaveContents: {
                if (updateRecord('desc',editedContent))
                    notifySavedContents();
            }

//            onOpenMenu: annotationEditor.openMenu(initialHeight, menu)
        }
        EditListItemInspector {
            id: projectComponent
            width: annotationEditor.width
            totalCollectionHeight: annotationEditor.totalCollectionHeight
            caption: qsTr('Projecte')
            onAddRow: newProject()
            originalContent: {
                'reference': project,
                'valued': true,
                'nameAttribute': 'name',
                'model': projectsModel
            }

            onPerformSearch: {
                projectsModel.searchString = searchString;
            }
            onSaveContents: {
                if (updateRecord('project',editedContent.reference))
                    notifySavedContents();
            }
        }
        CollectionInspectorItem {
            id: labelsComponent
            width: annotationEditor.width
            totalCollectionHeight: annotationEditor.totalCollectionHeight
            caption: qsTr('Etiquetes')
            visorComponent: Flow {
                property string shownContent
                property int requiredHeight: Math.max(childrenRect.height, units.fingerUnit)

                onShownContentChanged: {
                    var newLabels = [];
                    var labels = shownContent.split(' ');
                    for (var i=0; i<labels.length; i++) {
                        if (labels[i] !== '') {
                            newLabels.push(labels[i]);
                        }
                    }
                    flowRepeater.model = newLabels;
                }

                spacing: units.nailUnit

                Repeater {
                    id: flowRepeater

                    Rectangle {
                        color: '#AAFFAA'
                        height: units.fingerUnit
                        width: labelText.contentWidth + units.nailUnit * 2
                        Text {
                            id: labelText
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
                            font.pixelSize: units.readUnit
                            verticalAlignment: Text.AlignVCenter
                            text: modelData
                        }
                    }
                }
            }
            editorComponent: ListView {
                id: labelsListItem
                property string editedContent
                property int requiredHeight: contentItem.height

                interactive: false
                delegate: Rectangle {
                    width: labelsListItem.width
                    height: units.fingerUnit + units.nailUnit * 2
                    border.color: 'black'
                    color: 'white'
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: units.nailUnit
                        spacing: units.nailUnit

                        Text {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            verticalAlignment: Text.AlignVCenter
                            text: modelData
                        }
                        Common.ImageButton {
                            Layout.fillHeight: true
                            Layout.preferredWidth: size
                            size: units.fingerUnit * 2
                            available: true
                            image: 'erase-34105'
                            onClicked: deleteLabelDialog.open()
                        }
                    }

                    MessageDialog {
                        id: deleteLabelDialog

                        property string label: modelData
                        title: qsTr('Esborrar etiqueta')
                        text: qsTr("Confirmar l'esborrat d'etiqueta")
                        informativeText: qsTr("S'esborrarà l'etiqueta «" + deleteLabelDialog.label + "». Vols continuar?" )
                        standardButtons: StandardButton.Ok | StandardButton.Cancel
                        onAccepted: eraseLabel(deleteLabelDialog.label)
                    }

                    function eraseLabel(label) {
                        editedContent = editedContent.replace(label,"").replace(/(^\s+)|(\s+$)/g, '').replace(/\s\s+/g, ' ');
                    }

                }
                footer: Item {
                    id: footerItem
                    height: childrenRect.height
                    width: labelsListItem.width
                    ColumnLayout {
                        anchors.margins: units.nailUnit
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                        }
                        //height: childrenRect.height

                        Text {
                            Layout.fillWidth: true
                            Layout.preferredHeight: contentHeight
                            text: qsTr('Altres etiquetes')
                        }

                        Flow {
                            Layout.fillWidth: true
                            Layout.preferredHeight: childrenRect.height

                            spacing: units.nailUnit

                            Repeater {
                                model: existingLabelsModel
                                Rectangle {
                                    border.color: 'black'
                                    radius: units.nailUnit * 2
                                    width: Math.max(units.fingerUnit, labelText.width) + units.nailUnit * 3
                                    height: Math.max(units.fingerUnit, labelText.height) + units.nailUnit
                                    Text {
                                        id: labelText
                                        anchors {
                                            top: parent.top
                                            left: parent.left
                                            margins: units.nailUnit * 2
                                        }
                                        width: contentWidth
                                        height: contentHeight
                                        text: modelData
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            // Add existing label
                                            labelsListItem.editedContent = labelsListItem.editedContent + ((labelsListItem.editedContent == '')?'':' ') + modelData;
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: units.fingerUnit + 2 * units.nailUnit
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: units.nailUnit

                                TextField {
                                    id: newLabelField
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    onAccepted: footerItem.addLabel()
                                }
                                Common.ImageButton {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: units.fingerUnit
                                    size: units.fingerUnit
                                    image: 'plus-24844'
                                    onClicked: footerItem.addLabel()
                                }
                            }
                        }
                    }


                    function addLabel() {
                        var newLabel = newLabelField.text.replace(/\s+/g,'-')
                        if (newLabel !== '') {
                            if (editedContent === '')
                                editedContent = newLabel;
                            else
                                editedContent = editedContent + " " + newLabel;
                        }
                        newLabelField.text = '';
                    }
                }

                onEditedContentChanged: {
                    var labelsArray = editedContent.split(' ');
                    labelsListItem.model = labelsArray;
                }
            }
            onSaveContents: {
                if (updateRecord('labels',editedContent))
                    notifySavedContents();
            }
        }
        EditDateTimeItemInspector2 {
            id: startComponent

            width: annotationEditor.width
            totalCollectionHeight: annotationEditor.totalCollectionHeight
            caption: qsTr('Inici')
            onSaveContents: {
                if (updateRecord('start',editedContent))
                    notifySavedContents();
            }

        }
        EditDateTimeItemInspector2 {
            id: endComponent

            width: annotationEditor.width
            totalCollectionHeight: annotationEditor.totalCollectionHeight
            caption: qsTr('Final')
            onSaveContents: {
                if (updateRecord('end',editedContent))
                    notifySavedContents();
            }
        }
        EditStateItemInspector {
            id: stateComponent
            width: annotationEditor.width
            totalCollectionHeight: annotationEditor.totalCollectionHeight
            caption: qsTr('Estat')
            onSaveContents: {
                if (updateRecord('state', editedContent)) {
                    notifySavedContents();
                }
            }
        }

        CollectionInspectorItem {
            id: resourcesComponent
            width: annotationEditor.width
            totalCollectionHeight: annotationEditor.totalCollectionHeight
            caption: qsTr('Recursos')

            property bool enableDeletion: false

            visorComponent: ListView {
                id: resourcesList

                property int requiredHeight: contentItem.height
                property string shownContent: ''

                model: Models.DetailedResourcesModel {
                    id: resourcesModel
                    filters: ["annotationId='" + title + "'"]
                    onFiltersChanged: select()
                    onCountChanged: resourcesComponent.enableDeletion = (count == 0)

                    Component.onCompleted: select()
                }

                Connections {
                    target: globalResourcesModel
                    onUpdated: resourcesModel.select()
                }
                Connections {
                    target: globalResourcesAnnotationsModel
                    onUpdated: resourcesModel.select()
                }

                delegate: Rectangle {
                    border.color: 'black'
                    width: resourcesList.width
                    height: units.fingerUnit * 2
                    RowLayout {
                        id: resourcesLayout
                        anchors.fill: parent
                        anchors.margins: units.nailUnit
                        Text {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            text: '<b>' + model.resourceTitle + '</b>\n' + model.resourceDesc
                        }
                        Text {
                            Layout.fillHeight: true
                            Layout.preferredWidth: resourcesLayout.width / 4
                            text: model.resourceType
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            openingDocumentExternally(model.resourceSource);
                            Qt.openUrlExternally(model.resourceSource);
                        }
                        onPressAndHold: annotationEditor.newResourceAttachment({attachmentId: model.id})
                    }
                    MessageDialog {
                        id: deleteAttachmentDialog
                        title: qsTr('Esborrar recurs adjunt')
                        text: qsTr("S'esborrarà el recurs adjunt de l'anotació. Vols continuar?")
                        standardButtons: StandardButton.Ok | StandardButton.Cancel
                        onAccepted: {
                            globalResourcesAnnotationsModel.removeObjectWithKeyValue(model.id);
                        }
                    }
                }
                footer: Common.SuperposedButton {
                    id: newResourceButton
                    size: units.fingerUnit
                    imageSource: 'plus-24844'
                    onClicked: {
                        var obj = {annotation: annotationEditor.idAnnotation};
                        newResourceAttachment(obj);
                    }
                }
            }
        }

        CollectionInspectorItem {
            id: rubricsComponent

            width: annotationEditor.width
            totalCollectionHeight: annotationEditor.totalCollectionHeight
            caption: qsTr('Rúbriques')
            property bool enableDeletion: assessmentsModel.count == 0

            visorComponent: ListView {
                id: rubricsList
                interactive: false
                property int requiredHeight: contentItem.height

                header: (assessmentsModel.count == 0)?header:null

                Component {
                    id: header

                    Common.BoxedText {
                        width: rubricsList.width
                        height: units.fingerUnit * 2
                        margins: units.nailUnit
                        text: qsTr('Cap rúbrica està associada a aquesta anotació.')
                    }
                }

                model: assessmentsModel

                delegate: Rectangle {
                    width: rubricsList.width
                    height: units.fingerUnit * 2
                    border.color: 'grey'

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: units.nailUnit
                        spacing: units.nailUnit
                        Text {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: "<b>" + model.title + "</b>&nbsp;" + model.desc
                        }
                        Text {
                            Layout.fillHeight: true
                            Layout.preferredWidth: units.fingerUnit * 4
                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: model.group
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: annotationEditor.openRubricGroupAssessment(model.id, model.rubric, rubricsModel, assessmentsModel)
                    }
                }
            }
            Models.RubricsModel {
                id: rubricsModel

                Component.onCompleted: select()
            }
            Models.RubricsAssessmentModel {
                id: assessmentsModel

                filters: ["annotation = ?"]
//                bindValues: [annotationEditor.title]

                // There is a strong need to change the replace() in the previous line by a better solution.
                // I need to use bind-values in the SqlTableModel inner class.
            }
        }

        EditDeleteItemInspector {
            id: deleteButton
            width: annotationEditor.width
            totalCollectionHeight: annotationEditor.totalCollectionHeight

            enableButton: annotationEditor.enableDeletion
            buttonCaption: qsTr('Esborrar anotació')
            dialogTitle: buttonCaption
            dialogText: qsTr("Esborrareu l'anotació. Voleu continuar?")

            model: annotationsModel
            itemId: annotationEditor.title
            onDeleted: {
                annotationsModel.select();
                closePage(qsTr("S'ha esborrat l'anotació"));
            }
        }
    }

    function fillValues() {
        console.log('Filling values');

        if (annotationEditor.title !== "") {
            var project = "";

            annotationsModel.select();

            var details = annotationsModel.getObject(annotationEditor.title);

            if (details.title !== '') {
                descComponent.originalContent = (details.desc == null)?'':details.desc;

                project = details.project;

                labelsComponent.originalContent = (details.labels == null)?'':details.labels;

                startComponent.originalContent = details.start;
                endComponent.originalContent = details.end;
                stateComponent.originalContent = details.state;

                annotationEditor.setChanges(false);

            }

            projectsModel.select();

            projectComponent.originalContent = {
                reference: project,
                valued: true,
                nameAttribute: 'name',
                model: projectsModel
            }

            assessmentsModel.bindValues = [annotationEditor.title];
            assessmentsModel.select();
        }
  }

    function requestClose() {
        closeItem();
    }

    Models.ProjectsModel {
        id: projectsModel

        searchFields: ['name','desc']
    }

    Models.ExtendedAnnotations {
        id: annotationsModel

        Component.onCompleted: select()

        onCountChanged: {
            var labelsArray = [];
            for (var i=0; i<count; i++) {
                var labelsString = getObjectInRow(i)['labels'];
                var labels = labelsString.split(" ");
                for (var j=0; j<labels.length; j++) {
                    if (labels[j] !== '')
                        labelsArray.push(labels[j]);
                }
            }
            labelsArray.sort();

            // remove duplicates

            var uniqueLabelsArray = [];
            if (labelsArray.length>0) {
                uniqueLabelsArray.push(labelsArray[0]);
                for (var k=1; k<labelsArray.length; k++) {
                    if (labelsArray[k] !== labelsArray[k-1])
                        uniqueLabelsArray.push(labelsArray[k]);
                }
            }

            existingLabelsModel = uniqueLabelsArray;
        }
    }

    Component.onCompleted: fillValues()
}
