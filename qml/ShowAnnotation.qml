import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQml.Models 2.1
import QtQuick.Dialogs 1.2
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import "qrc:///javascript/Storage.js" as Storage
import PersonalTypes 1.0

CollectionInspector {
    id: annotationEditor
    pageTitle: qsTr("Editor d'anotacions")

    signal closePage(string message)
    signal savedAnnotation(int id,string annotation,string desc)
    signal duplicatedAnnotation(string annotation,string desc)
    signal openCamera(var receiver)
    signal showEvent(int idEvent, string event, string desc, string startDate, string startTime, string endDate, string endTime, int project)
    signal newEvent(var parameters)
    signal newResourceAttachment(var parameters)
    signal openingDocumentExternally(string document)
    signal newProject()

    property int idAnnotation: -1
    property string annotation: ''
    property string desc: ''
    property string image: ''
    property string labels: ''
    property bool enableDeletion: eventsComponent.enableDeletion & resourcesComponent.enableDeletion

    property var existingLabelsModel: []

    Common.UseUnits { id: units }

    onSaveDataRequested: {
        prepareDataAndSave(idAnnotation);
        savedAnnotation(idAnnotation,annotation,desc);
        closePage('');
    }

    onCopyDataRequested: {
        prepareDataAndSave(-1);
        annotationEditor.setChanges(false);
        duplicatedAnnotation(annotation,desc);
    }

    onDiscardDataRequested: {
        if (changes) {
            annotationEditor.closePage(qsTr("S'han descartat els canvis en l'anotació"));
        } else {
            closePage('');
        }
    }

    onClosePageRequested: closePage('')

    onIdAnnotationChanged: fillValues()

    function prepareDataAndSave(idCode) {
        var obj = {
            title: titleComponent.editedContent,
            desc: descComponent.editedContent,
            image: imageComponent.editedContent,
            ref: projectComponent.editedContent['reference'],
            labels: labelsComponent.editedContent
        };

        if (idCode == -1) {
            globalAnnotationsModel['created'] = Storage.currentTime();
            globalAnnotationsModel.insertObject(obj);
        } else {
            obj['id'] = idCode;
            globalAnnotationsModel.updateObject(obj);
        }
    }

    model: ObjectModel {
        EditTextItemInspector {
            id: titleComponent
            width: annotationEditor.width
            caption: qsTr('Títol')
        }
        EditTextAreaInspector {
            id: descComponent
            width: annotationEditor.width
            caption: qsTr('Descripció')
        }
        EditImageItemInspector {
            id: imageComponent
            width: annotationEditor.width
            caption: qsTr('Imatge')

            onOpenCamera: annotationEditor.openCamera(receiver)
        }
        EditListItemInspector {
            id: projectComponent
            width: annotationEditor.width
            caption: qsTr('Projecte')
            onAddRow: newProject()
        }
        CollectionInspectorItem {
            id: labelsComponent
            width: annotationEditor.width
            caption: qsTr('Etiquetes')
            visorComponent: Text {
                property string shownContent
                property int requiredHeight: Math.max(contentHeight, units.fingerUnit)
                font.pixelSize: units.readUnit
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: shownContent
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
                        height: childrenRect.height

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
                                    width: Math.max(units.fingerUnit, childrenRect.width) + units.nailUnit * 2
                                    height: Math.max(units.fingerUnit, childrenRect.height) + units.nailUnit
                                    Text {
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
                    console.log('Splitting ' + editedContent);
                    var labelsArray = editedContent.split(' ');
                    labelsListItem.model = labelsArray;
                }
            }
        }
        CollectionInspectorItem {
            id: eventsComponent
            width: annotationEditor.width
            caption: qsTr('Esdeveniments')

            property bool enableDeletion: false

            visorComponent: ListView {
                id: eventsList

                property int requiredHeight: contentItem.height
                property string shownContent: ''

                model: SqlTableModel {
                    id: eventsModel
                    tableName: globalScheduleModel.tableName
                    filters: ["ref='" + eventsList.shownContent + "'"]
                    onFiltersChanged: select()
                    onCountChanged: eventsComponent.enableDeletion = (count == 0)
                }

                Connections {
                    target: globalScheduleModel
                    onUpdated: eventsModel.select()
                }

                delegate: Rectangle {
                    border.color: 'black'
                    width: eventsList.width
                    height: units.fingerUnit * 2
                    RowLayout {
                        id: eventLayout
                        anchors.fill: parent
                        anchors.margins: units.nailUnit
                        Text {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            text: model.event
                        }
                        Text {
                            Layout.fillHeight: true
                            Layout.preferredWidth: eventLayout.width / 6
                            text: model.startDate
                        }
                        Text {
                            Layout.fillHeight: true
                            Layout.preferredWidth: eventLayout.width / 6
                            text: model.startTime
                        }
                        Text {
                            Layout.fillHeight: true
                            Layout.preferredWidth: eventLayout.width / 6
                            text: model.endDate
                        }
                        Text {
                            Layout.fillHeight: true
                            Layout.preferredWidth: eventLayout.width / 6
                            text: model.endTime
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: annotationEditor.showEvent(model.id,'','','','','','','')
                    }
                }

                footer: Common.SuperposedButton {
                    id: newEventButton
                    size: units.fingerUnit
                    imageSource: 'plus-24844'
                    onClicked: {
                        var obj = {annotation: annotationEditor.idAnnotation};
                        console.log(obj);
                        newEvent(obj);
                    }
                }
            }
        }
        CollectionInspectorItem {
            id: resourcesComponent
            width: annotationEditor.width
            caption: qsTr('Recursos')

            property bool enableDeletion: false

            visorComponent: ListView {
                id: resourcesList

                property int requiredHeight: contentItem.height
                property string shownContent: ''

                model: Models.DetailedResourcesModel {
                    id: resourcesModel
                    filters: ["annotationId='" + idAnnotation + "'"]
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

        EditDeleteItemInspector {
            id: deleteButton
            width: annotationEditor.width

            enableButton: annotationEditor.enableDeletion
            buttonCaption: qsTr('Esborrar anotació')
            dialogTitle: buttonCaption
            dialogText: qsTr("Esborrareu l'anotació. Voleu continuar?")

            model: globalAnnotationsModel
            itemId: idAnnotation
            onDeleted: closePage(qsTr("S'ha esborrat l'anotació"))
        }
    }

    function fillValues() {
        var reference = -1;
        console.log("ID: " + idAnnotation);
        if (annotationEditor.idAnnotation != -1) {
            var details = globalAnnotationsModel.getObject(annotationEditor.idAnnotation);
            console.log("FIELD names " + globalAnnotationsModel.fieldNames);
            for (var prop in details) {
                console.log('Prop ' + prop + "->" + details[prop]);
            }

            titleComponent.originalContent = details.title;
            descComponent.originalContent = (details.desc == null)?'':details.desc;
            imageComponent.originalContent = (details.image == null)?'':details.image;

            reference = (typeof details.ref !== 'undefined')?details.ref:-1;

            labelsComponent.originalContent = (details.labels == null)?'':details.labels;

            eventsComponent.originalContent = details.id;

            annotationEditor.setChanges(false);
        }

        projectComponent.originalContent = {
            reference: reference,
            valued: false,
            nameAttribute: 'name',
            model: globalProjectsModel
        }
    }

    function requestClose() {
        closeItem();
    }

    SqlTableModel {
        tableName: globalAnnotationsModel.tableName;
        Component.onCompleted: select()

        onCountChanged: {
            console.log('Now');
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
            existingLabelsModel = labelsArray;
            console.log(labelsArray);
        }
    }
}
