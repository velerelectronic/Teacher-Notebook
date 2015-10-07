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
    pageTitle: qsTr("Editor d'anotacions")

    signal closePage(string message)
    signal savedAnnotation(int id,string annotation,string desc)
    signal duplicatedAnnotation(string annotation,string desc)
    signal openCamera(var receiver)
    signal showEvent(var parameters)
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

    onCopyDataRequested: {
        prepareDataAndSave(-1);
        annotationEditor.setChanges(false);
        duplicatedAnnotation(annotation,desc);
    }

    onClosePageRequested: closePage('')

    onIdAnnotationChanged: fillValues()

    function saveOrUpdate(field, contents) {
        var res = false;
        var obj = {};
        obj[field] = contents;

        if (idAnnotation == -1) {
            obj['created'] = Storage.currentTime();
            res = globalAnnotationsModel.insertObject(obj);
            if (res !== '') {
                idAnnotation = res;
            }
        } else {
            obj['id'] = idAnnotation;
            res = globalAnnotationsModel.updateObject(obj);
        }
        return res;
    }

    Models.ScheduleModel {
        id: eventsModel
        filters: ["ref='" + idAnnotation + "'"]
        onFiltersChanged: {
            setSort(5,Qt.AscendingOrder);
            select();
        }
    }

    Connections {
        target: globalScheduleModel
        onUpdated: eventsModel.select()
    }

    model: ObjectModel {
        EditTextItemInspector {
            id: titleComponent
            width: annotationEditor.width
            caption: qsTr('Títol')
            onSaveContents: {
                if (saveOrUpdate('title',editedContent))
                    notifySavedContents();
            }
        }
        EditTextAreaInspector {
            id: descComponent
            width: annotationEditor.width
            caption: qsTr('Descripció')
            onSaveContents: {
                if (saveOrUpdate('desc',editedContent))
                    notifySavedContents();
            }

//            onOpenMenu: annotationEditor.openMenu(initialHeight, menu)
        }
        EditImageItemInspector {
            id: imageComponent
            width: annotationEditor.width
            caption: qsTr('Imatge')

            onOpenCamera: annotationEditor.openCamera(receiver)
            onSaveContents: {
                if (saveOrUpdate('image',editedContent))
                    notifySavedContents();
            }
        }
        EditListItemInspector {
            id: projectComponent
            width: annotationEditor.width
            caption: qsTr('Projecte')
            onAddRow: newProject()
            onPerformSearch: {
                projectsModel.searchString = searchString;
            }
            onSaveContents: {
                if (saveOrUpdate('ref',editedContent.reference))
                    notifySavedContents();
            }
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
                if (saveOrUpdate('labels',editedContent))
                    notifySavedContents();
            }
        }
        CollectionInspectorItem {
            id: eventsComponent
            width: annotationEditor.width
            caption: qsTr('Esdeveniments')

            property bool enableDeletion: eventsModel.count == 0

            visorComponent: Schedule {
                // Required height defined inside Schedule
                property string shownContent: ''

                interactive: false

                onShownContentChanged: {
                    eventsModel.select();
                }
                onShowEvent: annotationEditor.showEvent(parameters)

                scheduleModel: eventsModel

                Common.SuperposedButton {
                    id: newEventButton
                    anchors {
                        top: parent.top
                        right: parent.right
                    }

                    size: units.fingerUnit
                    imageSource: 'plus-24844'
                    onClicked: {
                        var date = (new Date());
                        var dateStr = date.toYYYYMMDDFormat();
                        var timeStr = date.toHHMMFormat();
                        var obj = {
                            annotation: annotationEditor.idAnnotation,
                            startDate: dateStr,
                            startTime: timeStr,
                            endDate: dateStr,
                            endTime: timeStr
                        };
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

        CollectionInspectorItem {
            id: characteristicsComponent
            width: annotationEditor.width
            caption: qsTr('Característiques')

            visorComponent: ListView {
                model: 3
                property int requiredHeight: contentItem.height
                delegate: Common.BoxedText {
                    width: parent.width
                    height: units.fingerUnit * 2
                    fontSize: units.readUnit
                    margins: units.nailUnit
                    text: modelData
                }
            }
            enableSendClick: true
            onSendClick: showEventCharacteristics(idEvent, eventCharacteristicsModel, writeCharacteristicsModel)
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
        if (annotationEditor.idAnnotation != -1) {
            var details = globalAnnotationsModel.getObject(annotationEditor.idAnnotation);

            titleComponent.originalContent = details.title;
            descComponent.originalContent = (details.desc == null)?'':details.desc;
            imageComponent.originalContent = (details.image == null)?'':details.image;

            reference = (typeof details.ref !== 'undefined')?details.ref:-1;

            labelsComponent.originalContent = (details.labels == null)?'':details.labels;

            eventsComponent.originalContent = details.id.toString();

            annotationEditor.setChanges(false);
        }

        projectComponent.originalContent = {
            reference: reference,
            valued: false,
            nameAttribute: 'name',
            model: projectsModel
        }
    }

    function requestClose() {
        closeItem();
    }

    Models.ProjectsModel {
        id: projectsModel

        searchFields: ['name','desc']

        Component.onCompleted: select()
    }

    SqlTableModel {
        tableName: globalAnnotationsModel.tableName;
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
