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
    signal deletedAnnotation()
    signal duplicatedAnnotation(string annotation,string desc)
    signal openCamera(var receiver)
    signal showEvent(var parameters)
    signal newEvent(var parameters)
    signal newResourceAttachment(var parameters)
    signal openingDocumentExternally(string document)
    signal openRubricGroupAssessment(int assessment, int rubric, var rubricsModel, var rubricsAssessmentModel)
    signal newProject()
    signal annotationTitleChanged(string title)

    property alias title: titleComponent.originalContent
    property alias desc: descComponent.originalContent
    property alias labels: labelsComponent.originalContent
    property alias project: projectComponent.originalContent
    property alias start: projectComponent.originalContent
    property alias end: projectComponent.originalContent
    property alias state: projectComponent.originalContent

    property bool enableDeletion: resourcesComponent.enableDeletion && rubricsComponent.enableDeletion && timetableComponent.enableDeletion

    property var existingLabelsModel: []


    Common.UseUnits { id: units }

    onClosePageRequested: closePage('')

    onIdentifierChanged: fillValues()

    function prepareSaveObject() {
        var obj = {
            title: titleComponent.originalContent,
            desc: descComponent.originalContent,
            project: projectComponent.originalContent['reference'],
            labels: labelsComponent.originalContent,
            start: startComponent.originalContent,
            end: endComponent.originalContent,
            state: stateComponent.originalContent
        }

        return obj;
    }

    function newRecord() {
        var obj = prepareSaveObject();
        obj['created'] = Storage.currentTime();

        return (annotationsModel.insertObject(obj));
    }

    function updateWithObject() {
        var obj = prepareSaveObject();
        console.log('Trying to update');
        console.log('identifier',annotationEditor.identifier,'object',obj);

        return annotationsModel.updateObject(annotationEditor.identifier, obj);
    }

    model: ObjectModel {
        EditTextItemInspector {
            id: titleComponent
            width: annotationEditor.width
            totalCollectionHeight: annotationEditor.totalCollectionHeight
            caption: qsTr('Títol')
            onSaveContents: {
                if (updateWithObject()) {
                    annotationEditor.identifier = titleComponent.originalContent;
                    notifySavedContents();
                } else {
                    console.log('not updated');
                }
            }
        }
        EditTextAreaInspector {
            id: descComponent
            width: annotationEditor.width
            totalCollectionHeight: annotationEditor.totalCollectionHeight
            caption: qsTr('Descripció')
            onSaveContents: {
                console.log('Description');
                if (updateWithObject()) {
                    console.log('Certainly updated');
                    notifySavedContents();
                }
            }

//            onOpenMenu: annotationEditor.openMenu(initialHeight, menu)
        }
        EditListItemInspector {
            id: projectComponent
            width: annotationEditor.width
            totalCollectionHeight: annotationEditor.totalCollectionHeight
            caption: qsTr('Projecte')
            onAddRow: newProject()

            onPerformSearch: {
                projectsModel.searchString = searchString;
                projectsModel.select();
            }
            onSaveContents: {
                if (updateWithObject())
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
                if (updateWithObject())
                    notifySavedContents();
            }
        }
        EditDateTimeItemInspector2 {
            id: startComponent

            width: annotationEditor.width
            totalCollectionHeight: annotationEditor.totalCollectionHeight
            caption: qsTr('Inici')
            onSaveContents: {
                if (updateWithObject())
                    notifySavedContents();
            }

        }
        EditDateTimeItemInspector2 {
            id: endComponent

            width: annotationEditor.width
            totalCollectionHeight: annotationEditor.totalCollectionHeight
            caption: qsTr('Final')
            onSaveContents: {
                if (updateWithObject())
                    notifySavedContents();
            }
        }
        EditStateItemInspector {
            id: stateComponent
            width: annotationEditor.width
            totalCollectionHeight: annotationEditor.totalCollectionHeight
            caption: qsTr('Estat')
            onSaveContents: {
                if (updateWithObject()) {
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
                footer: Common.ImageButton {
                    image: 'plus-24844'
                    size: units.fingerUnit
                    onClicked: openMenu(units.fingerUnit, addRubricMenu, {})
                }
            }
            Models.RubricsAssessmentModel {
                id: assessmentsModel

                filters: ["annotation = ?"]
//                bindValues: [annotationEditor.title]

                // There is a strong need to change the replace() in the previous line by a better solution.
                // I need to use bind-values in the SqlTableModel inner class.
            }
        }

        CollectionInspectorItem {
            id: timetableComponent
            width: annotationEditor.width
            totalCollectionHeight: annotationEditor.totalCollectionHeight
            property bool enableDeletion: false

            caption: qsTr('Horaris')

            visorComponent: Rectangle {
                property int requiredHeight: periodDays.height + 2 * units.nailUnit

                color: 'grey'

                ListView {
                    id: periodDays
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                    height: maxRowsHeight
                    anchors.margins: units.nailUnit

                    property int maxRowsHeight: 0

                    orientation: ListView.Horizontal
                    interactive: false
                    model: ListModel {
                        id: daysModel
                    }

                    spacing: units.nailUnit

                    delegate: ListView {
                        id: periodTimes

                        width: (periodDays.width - periodDays.count * periodDays.spacing) / 7
                        height: periodTimes.contentItem.height

                        spacing: units.nailUnit

                        property string dayName: name
                        property int periodDay: index+1

                        interactive: false
                        model: timetablesModel

                        Models.TimeTablesModel {
                            id: timetablesModel
                            filters: [
                                'annotation=?',
                                'periodDay=?'
                            ]
                            sort: 'periodTime ASC'
                            Component.onCompleted: {
                                bindValues = [
                                    annotationEditor.identifier,
                                    periodTimes.periodDay
                                ];
                                timetablesModel.select();
                                periodDays.getInfo();
                            }
                        }

                        header: Text {
                            width: periodTimes.width
                            height: units.fingerUnit
                            text: periodTimes.dayName
                        }

                        delegate: Rectangle {
                            color: 'white'
                            width: periodTimes.width
                            height: units.fingerUnit * 2
                            Text {
                                anchors.fill: parent
                                clip: true

                                text: model.title
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var obj = {model: timetablesModel, identifier: model.id};
                                    annotationEditor.openMenu(units.fingerUnit * 5, changeTimeTableFields, obj);
                                }
                            }
                        }

                        footer: Common.ImageButton {
                            width: periodTimes.width
                            height: units.fingerUnit
                            image: 'plus-24844'
                            onClicked: {
                                var obj = {
                                    annotation: annotationEditor.identifier,
                                    periodTime: periodTimes.count + 1,
                                    periodDay: periodTimes.periodDay,
                                    title: 'Classe ' + periodTimes.periodDay + "//" + (periodTimes.count + 1),
                                    startTime: '8:00',
                                    endTime: '8:55'
                                }

                                timetablesModel.insertObject(obj);
                                timetablesModel.select();
                                periodDays.getInfo();
                            }
                        }
                    }
                    Component.onCompleted: {
                        daysModel.append({name: qsTr('Dilluns')});
                        daysModel.append({name: qsTr('Dimarts')});
                        daysModel.append({name: qsTr('Dimecres')});
                        daysModel.append({name: qsTr('Dijous')});
                        daysModel.append({name: qsTr('Divendres')});
                        daysModel.append({name: qsTr('Dissabte')});
                        daysModel.append({name: qsTr('Diumenge')});

                        periodDays.getInfo();
                    }

                    function getInfo() {
                        timetableComponent.enableDeletion = true;
                        var maxHeight = 0;
                        for (var i=0; i<periodDays.contentItem.children.length; i++) {
                            var obj = periodDays.contentItem.children[i];
                            if (obj.count > 0) {
                                timetableComponent.enableDeletion = false;
                            }
                            if (maxHeight < obj.height)
                                maxHeight = obj.height;
                        }
                        periodDays.maxRowsHeight = maxHeight;
                    }
                }
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
                closePage(qsTr("S'ha esborrat l'anotació"));
                annotationEditor.deletedAnnotation();
            }
        }
    }

    function fillValues() {
        console.log('Filling values');
        console.log(identifier);

        if (identifier !== "") {
            console.log('With identifier');
            var project = "";

            annotationsModel.select();

            var details = annotationsModel.getObject(identifier);

            console.log(details.title);
            if (details.title !== '') {
                console.log(details.title);
                titleComponent.originalContent = details.title;
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
        } else {
            console.log('No identifer');
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

    Component {
        id: changeTimeTableFields

        Rectangle {
            id: changeTimeTableRect

            property var options: {
                'model': null,
                'identifier': -1
            }

            property int requiredHeight: childrenRect.height + units.fingerUnit * 2
            signal closeMenu()

            GridLayout {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: units.fingerUnit
                }

                rows: 5
                columns: 2

                Text {
                    text: qsTr('Període')
                    Layout.preferredHeight: units.fingerUnit
                    Layout.preferredWidth: units.fingerUnit * 2
                }

                Text {
                    id: identificationData
                    font.bold: true
                    font.pixelSize: units.readUnit
                    Layout.preferredHeight: units.fingerUnit
                    Layout.fillWidth: true
                }

                Text {
                    text: qsTr('Títol')
                    Layout.preferredHeight: units.fingerUnit
                    Layout.preferredWidth: units.fingerUnit * 2
                }

                TextField {
                    id: titleField
                    Layout.preferredHeight: units.fingerUnit
                    Layout.fillWidth: true
                }

                Text {
                    text: qsTr('Inici')
                    Layout.preferredHeight: units.fingerUnit
                    Layout.preferredWidth: units.fingerUnit * 2
                }

                TextField {
                    id: startTimeField
                    Layout.preferredHeight: units.fingerUnit
                    Layout.fillWidth: true
                }

                Text {
                    text: qsTr('Final')
                    Layout.preferredHeight: units.fingerUnit
                    Layout.preferredWidth: units.fingerUnit * 2
                }

                TextField {
                    id: endTimeField
                    Layout.preferredHeight: units.fingerUnit
                    Layout.fillWidth: true
                }
                Common.TextButton {
                    text: qsTr('Desa')
                    onClicked: saveChanges()
                }

                Common.TextButton {
                    Layout.alignment: Qt.AlignRight
                    text: qsTr('Esborra')
                    onClicked: removeField()
                }

            }

            onOptionsChanged: {
                if (changeTimeTableRect.options !== null) {
                    var model = changeTimeTableRect.options['model'];
                    var identifier = changeTimeTableRect.options['identifier'];
                    var obj = model.getObject(identifier);
                    identificationData.text = obj['periodDay'] + "//" + obj['periodTime'];
                    titleField.text = obj['title'];
                    startTimeField.text = obj['startTime'];
                    endTimeField.text = obj['endTime'];
                }
            }

            function saveChanges() {
                var obj = {
                    title: titleField.text,
                    startTime: startTimeField.text,
                    endTime: endTimeField.text
                };

                changeTimeTableRect.options['model'].updateObject(changeTimeTableRect.options['identifier'], obj);
                changeTimeTableRect.options['model'].select();
                closeMenu();
            }

            function removeField() {
                changeTimeTableRect.options['model'].removeObject(changeTimeTableRect.options['identifier']);
                changeTimeTableRect.options['model'].select();
                closeMenu();
            }
        }
    }

    Component {
        id: addRubricMenu

        Rectangle {
            id: addRubricMenuRect

            property int requiredHeight: childrenRect.height
            property var options
            signal closeMenu()

            Models.IndividualsModel {
                id: groupsModel

                fieldNames: ['group']

                sort: 'id DESC'
            }

            ListView {
                id: possibleList
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: units.fingerUnit
                }
                height: contentItem.height

                clip: true
                interactive: false

                model: groupsModel

                delegate: Item {
                    id: singleRubricXGroup

                    width: possibleList.width
                    height: childrenRect.height

                    property string group: model.group

                    ColumnLayout {
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                        }
//                            height: childrenRect.height

                        Text {
                            Layout.fillWidth: true
                            Layout.preferredHeight: units.fingerUnit
                            font.bold: true
                            font.pixelSize: units.readUnit
                            elide: Text.ElideRight
                            text: qsTr('Grup') + " " + model.group
                        }
                        GridView {
                            Layout.fillWidth: true
                            Layout.preferredHeight: contentItem.height

                            model: rubricsModel
                            interactive: false

                            cellWidth: units.fingerUnit * 4
                            cellHeight: cellWidth

                            delegate: Common.BoxedText {
                                width: units.fingerUnit * 3
                                height: width
                                margins: units.nailUnit
                                text: model.title
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        closeMenu();
                                        addRubricMenuRect.newRubricAssessment(model.title, model.desc, model.id, singleRubricXGroup.group, annotationEditor.title);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Text {
                anchors {
                    top: possibleList.bottom
                    left: parent.left
                    right: parent.right
                    margins: units.fingerUnit
                }
                height: units.fingerUnit
                text: qsTr('Avaluació de rúbrica buida')
                font.bold: true
                font.pixelSize: units.readUnit

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        closeMenu();
                        openRubricAssessmentDetails(-1, -1, "", rubricsModel, rubricsAssessmentModel);
                    }
                }
            }

            Component.onCompleted: {
                groupsModel.selectUnique('group');
                console.log('COUNT', groupsModel.count)
            }

            function newRubricAssessment(title, desc, rubric, group, annotation) {
                var obj = {};
                obj = {
                    title: title,
                    desc: desc,
                    rubric: rubric,
                    group: group,
                    annotation: annotation
                };

                var res = rubricsAssessmentModel.insertObject(obj);
                rubricsAssessmentModel.select();
            }
        }

    }

    Models.RubricsModel {
        id: rubricsModel

        Component.onCompleted: select()
    }

    Models.RubricsAssessmentModel {
        id: rubricsAssessmentModel
    }


    Component.onCompleted: {
        console.log('new identifier', identifier);

        fillValues();
    }
}
