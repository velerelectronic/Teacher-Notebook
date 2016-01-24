import QtQuick 2.5
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import "qrc:///javascript/Storage.js" as Storage
import "qrc:///common/FormatDates.js" as FormatDates

BasicPage {
    id: annotations
    property string pageTitle: qsTr('Anotacions (esteses)');

    property bool isVertical: width<height

    property bool onlyEmptyProjects: false
    property bool hideHeader: false
    property bool subList: false

    signal showExtendedAnnotation (var parameters)
//    signal openMenu(int initialHeight, var menu, var options)
    signal chosenAnnotation(string annotation)
    signal combineAnnotationsIntoTable(var annotationsModel)
    signal openRubricGroupAssessment(int assessment, int rubric, var rubricsModel, var rubricsAssessmentModel)
    signal openTimeTable(string annotation)

    property bool chooseMode: false

    property string classifyVariable: 'end'

    property string sortLabels: ''

    property string firstLabelFilter: ''

    property int requiredHeight

    property var stateTypes: {
        'done': "state < 0",
        'active': "(state >= 0 OR state IS NULL)",
        'specific': "state = 0",
        'partial': "(state > 0 AND state < 10)",
        'all': ''
    }

    property string stateFilter: stateTypes.active
    property string project: ''

    property string emptyProjectFilter: "project IS null OR project = ''"
    property bool isDirty: false

    property var sortType: {
        'start': 'start ASC',
        'startRev': 'start DESC',
        'end': 'end ASC',
        'endRev': 'end DESC',
        'state': 'state ASC'
    }

    property string sortOption: sortType.end

    property var labelsFilter: []
    signal exportAnnotations(var fieldNames, var writeModel, var fieldConstants)
    signal importAnnotations(var fieldNames, var writeModel, var fieldConstants)

    /*
    signal deletedAnnotations (int num)

    signal openingDocumentExternally(string document)
    signal showEvent(var parameters)
*/

//    property bool canClose: true

    property string searchString: ''

    function newAnnotation(newTitle, start, end, state) {
        annotationsModel.insertObject({
                                          title: newTitle,
                                          desc: '',
                                          start: start,
                                          end: end,
                                          state: state
                                      });
        return newTitle;
    }

    function refresh() {
        annotations.invokeSubPageFunction('refreshWithLastSelected');
    }

    Common.UseUnits { id: units }

    mainPage: Common.ExpandableListView {
        id: annotationsList
        //anchors.fill: parent

        onRequiredHeightChanged: annotations.requiredHeight = annotationsList.requiredHeight;

        bottomMargin: units.fingerUnit * 3

        interactive: !annotations.subList

        onStateChanged: {
            if ((isDirty) && (state == 'simple')){
                refresh();
                isDirty = false;
            }
        }

        onButtonsModelChanged: {
            console.log('BUTTTONS');
            annotations.buttonsModel = annotationsList.buttonsModel;
        }

        itemComponent: Rectangle {
            id: annotationItem

            property int requiredHeight: Math.max(units.fingerUnit, annotationSubLoader.requiredHeight + annotationSubLoader.anchors.margins * 2)
            clip: true
            property var model: null

            states: [
                State {
                    name: 'minimized'
                },
                State {
                    name: 'expanded'
                    PropertyChanges {
                        target: annotationItem
                        requiredHeight: annotationsList.height
                    }
                }
            ]
            state: 'minimized'

            function sendState(newState) {
                if (newState == '') {
                    annotationItem.state = (annotationItem.state == 'minimized')?'expanded':'minimized';
                } else {
                    annotationItem.state = newState;
                }
                loadContents();
            }

            border.color: 'black'

            onModelChanged: {
/*
                console.log('Printing model');
                for (var prop in model) {
                    console.log(prop, ':', model[prop]);
                }
*/
                modelTitle = coalesceModel(annotationItem.model, 'title', '');
                modelDesc = coalesceModel(annotationItem.model, 'desc', '');
                modelState = coalesceModel(annotationItem.model, 'state', '');
                modelProject = coalesceModel(annotationItem.model, 'project', '');
                modelLabels = coalesceModel(annotationItem.model, 'labels', '');
                modelStart = coalesceModel(annotationItem.model, 'start', '');
                modelEnd = coalesceModel(annotationItem.model, 'end', '');
                modelFirstLabel = coalesceModel(annotationItem.model, 'firstLabel','');
                modelLabelCode = coalesceModel(annotationItem.model, 'labelCode',-1);
                modelLabelGroup = coalesceModel(annotationItem.model, 'labelGroup',-1);
                modelGroupCount = coalesceModel(annotationItem.model, 'groupCount',0);

                console.log('model group count', modelGroupCount);

                loadContents();
            }

            function loadContents() {
                if (annotationItem.state == 'minimized') {
                    switch(modelGroupCount) {
                    case 1:
                        annotationSubLoader.sourceComponent = singleAnnotationComponent;
                        break;
                    case 0:
                        break;
                    default:
                        annotationSubLoader.sourceComponent = annotationGroupComponent;
                        break;
                    }
                } else {
                    switch(modelGroupCount) {
                    case 1:
                        annotationSubLoader.sourceComponent = expandedSingleAnnotationComponent;
                        break;
                    case 0:
                        break;
                    default:
                        annotationSubLoader.setSource('ExtendedAnnotationsList.qml',{firstLabelFilter: modelFirstLabel, hideHeader: true, subList: true});
                        break;
                    }
                }
                annotationSubLoader.getRequiredHeight();
            }

            Loader {
                id: annotationSubLoader

                anchors.fill: parent
                anchors.margins: units.nailUnit

                onLoaded: getRequiredHeight()

                property int requiredHeight: 0

                Connections {
                    target: annotationSubLoader.item
                    onRequiredHeightChanged: {
                        annotationSubLoader.getRequiredHeight();
                    }
                }

                function getRequiredHeight() {
                    if (item !== null)
                        annotationSubLoader.requiredHeight = item.requiredHeight;
                }
            }

            Component {
                id: singleAnnotationComponent

                Item {
                    property int requiredHeight: units.fingerUnit * 2 + ((rubricsAssessmentModel.count>0)?(units.fingerUnit * 2.5):0)
                    property Component expandedComponent: expandedSingleAnnotationComponent

                    RowLayout {
                        id: basicAnnotationInfo

                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            bottom: (rubricsAssessmentModel.count>0)?parent.verticalCenter:parent.bottom
                        }

                        anchors.margins: units.nailUnit
                        spacing: units.nailUnit

                        Text {
                            id: titleText
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: annotationItem.modelTitle
                        }
                        Text {
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width / 4
                            color: 'red'
                            text: annotationItem.modelStart + "\n" + annotationItem.modelEnd
                        }
                        Text {
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width / 4
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            color: 'green'
                            text: "<b>" + annotationItem.modelProject + "</b> &nbsp;" + annotationItem.modelLabels + "-->>" + annotationItem.modelLabelCode + annotationItem.modelFirstLabel + "//" + annotationItem.modelLabelGroup + annotationItem.modelGroupCount
                        }

                        Text {
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width / 8
                            text: {
                                if (annotationItem.modelState<0) {
                                    return qsTr('Finalitzat');
                                } else {
                                    if ((annotationItem.modelState>0) && (annotationItem.modelState<=10)) {
                                        return (annotationItem.model.state * 10) + "%";
                                    } else {
                                        return qsTr('Actiu');
                                    }
                                }
                            }
                        }
                        Common.ImageButton {
                            Layout.fillHeight: true
                            Layout.preferredWidth: units.fingerUnit * 2
                            size: units.fingerUnit
                            image: 'window-27140'
                            onClicked: annotations.openMenu(units.fingerUnit * 4, singleAnnotationMenu, {index: model.index, labels: model.labels})
                        }
                    }

                    ListView {
                        id: rubricsAnnotationInfo

                        anchors {
                            margins: units.nailUnit
                            top: basicAnnotationInfo.bottom
                            bottom: parent.bottom
                            left: parent.left
                            right: parent.right
                        }

                        leftMargin: titleText.width
                        orientation: ListView.Horizontal

                        model: rubricsAssessmentModel
                        spacing: units.nailUnit
                        delegate: Common.BoxedText {
                            height: units.fingerUnit * 2
                            width: units.fingerUnit * 6
                            text: model.title + " (" + model.group + ")"
                            margins: units.nailUnit
                            MouseArea {
                                anchors.fill: parent
                                onClicked: openRubricGroupAssessment(model.id, model.rubric, rubricsModel, rubricsAssessmentModel)
                            }
                        }
                    }
                    Models.RubricsAssessmentModel {
                        id: rubricsAssessmentModel
                        filters: ["annotation=?"]
                    }
                    Connections {
                        target: annotationItem
                        onModelTitleChanged: {
                            rubricsAssessmentModel.bindValues = [annotationItem.modelTitle];
                            rubricsAssessmentModel.select();
                        }
                    }
                }
            }

            Component {
                id: expandedSingleAnnotationComponent

                ShowExtendedAnnotation {
                    id: extendedAnnotationItem

                    property var model
                    embedded: true

                    identifier: annotationItem.modelTitle

                    onRequiredHeightChanged: annotationItem.requiredHeight = extendedAnnotationItem.requiredHeight + 2 * units.nailUnit

                    onOpenMenu: annotations.openMenu(initialHeight, menu, options)

                    onOpenRubricGroupAssessment: {
                        console.log('Now')
                        annotations.openRubricGroupAssessment(assessment, rubric, rubricsModel, rubricsAssessmentModel);
                    }

                    onDeletedAnnotation: {
                        annotationsList.closeItem();
                        annotations.refresh();
                    }

                    onUpdatedContents: {
                        annotationsList.lastSelected = identifier;
                        isDirty = true;
                    }
                }

            }

            Component {
                id: annotationGroupComponent
                Item {
                    property int requiredHeight: units.fingerUnit * 2

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: units.nailUnit
                        spacing: units.nailUnit

                        Text {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            font.pixelSize: units.readUnit
                            font.bold: true
                            text: annotationItem.modelLabelGroup
                        }
                        Text {
                            Layout.fillHeight: true
                            Layout.preferredWidth: units.fingerUnit
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: units.readUnit
                            text: annotationItem.modelGroupCount
                        }
                    }

                }
            }


            function coalesceModel(model, var1, var2) {
                return ((model !== null) && (typeof model[var1] !== 'undefined'))?model[var1]:var2;
            }

            property string modelTitle
            property string modelDesc
            property string modelState
            property string modelProject
            property string modelLabels
            property string modelStart
            property string modelEnd
            property string modelFirstLabel
            property int modelLabelCode
            property string modelLabelGroup
            property int modelGroupCount: 0

            property string identifier: annotationItem.modelTitle
            property bool isLastSelected: (annotationsList.lastSelected != '') && (annotationItem.identifier == annotationsList.lastSelected)

            color: (modelState>=0)?'white':'#AAAAAA'
        }

        header: (annotations.hideHeader)?null:headerComponent

        Component {
            id: headerComponent
            Rectangle {
                id: annotationsListHeader

                z: 300
                color: 'white'
                width: annotationsList.width
                height: units.fingerUnit * 2.5
                visible: annotationsList.currentIndex < 0

                GridLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    columnSpacing: units.nailUnit
                    columns: 3

                    Common.SearchBox {
                        id: searchAnnotations
                        Layout.fillWidth: true
                        Layout.preferredHeight: units.fingerUnit

                        text: annotations.searchString

                        onTextChanged: annotations.searchString = text
                        onPerformSearch: {
                            annotationsListHeader.addSearchTerm(text);

                            var textArray = text.split(/\s+/i);
                            // text.split(/[$|\b+][#\B+][^|\b+]/i);
                            console.log(textArray);
                            var descArray = [];
                            var labelsArray = [];
                            for (var i=0; i<textArray.length; i++) {
                                if (textArray[i].indexOf('#') === 0) {
                                    labelsArray.push(textArray[i].substr(1));
                                } else {
                                    descArray.push(textArray[i]);
                                }
                            }

                            annotationsModel.searchString = descArray.join(' ');

                            var filtersArray = [];
                            for (var i=0; i<labelsArray.length; i++) {
                                filtersArray.push("INSTR(UPPER(labels),UPPER('" + labelsArray[i] + "'))");
                            }

                            annotations.labelsFilter = filtersArray;
                        }
                        onIntroPressed: {
                            console.log('INTRO')
                        }
                    }

                    Common.ImageButton {
                        Layout.fillHeight: true
                        Layout.preferredWidth: height
                        image: 'day-42975'
                        onClicked: {
                            var today = new Date();
                            var todayString = today.toYYYYMMDDFormat() + " " + today.toHHMMFormat();

                            var field = '';
                            var comparisonSign = 0;

                            switch(sortOption) {
                                case sortType.start:
                                    field = 'start';
                                    comparisonSign = -1;
                                    break;
                                case sortType.end:
                                    field = 'end';
                                    comparisonSign = -1;
                                    break;
                                case sortType.startRev:
                                    field = 'start';
                                    comparisonSign = 1;
                                    break;
                                case sortType.endRev:
                                    field = 'end'
                                    comparisonSign = 1;
                                    break;
                            }

                            var row = 0;
                            while (row < annotationsModel.count) {
                                console.log('field',field);
                                var date = annotationsModel.getObjectInRow(row)[field];
                                if (todayString.localeCompare(date) === comparisonSign)
                                    break;
                                else {
                                    row++;
                                }
                            }
                            if (row == annotationsModel.count)
                                row--;
                            annotationsList.lastSelected = annotationsModel.getObjectInRow(row)['title'];
                            annotationsList.positionViewAtIndex(row, ListView.Contain);
                        }
                    }

                    Common.TextButton {
                        Layout.fillHeight: true
                        text: qsTr('Opcions')
                        onClicked: openMenu(units.fingerUnit * 4, annotationsMenu, {})
                    }
                    ListView {
                        id: searchTermsList

                        Layout.fillWidth: true
                        Layout.preferredHeight: units.fingerUnit * 1
                        orientation: ListView.Horizontal
                        model: ListModel { id: searchTermsModel }
                        spacing: units.nailUnit
                        clip: true

                        delegate: Rectangle {
                            height: searchTermsList.height
                            width: searchTermText.width + radius * 2
                            radius: height / 2
                            color: '#81DAF5'
                            Text {
                                id: searchTermText
                                anchors {
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                    margins: parent.radius
                                }
                                width: contentWidth
                                text: model.terms
                                font.pixelSize: units.readUnit
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var newTerms = model.terms;
                                    searchTermsModel.move(model.index, 0, 1);
                                    searchAnnotations.text = newTerms;
                                }
                            }
                        }
                    }
                }

                function addSearchTerm(searchTerm) {
                    if (searchTermsModel.count>0) {
                        if (searchTerm !== searchTermsModel.get(0).terms)
                            searchTermsModel.insert(0, {terms: searchTerm});
                    } else {
                        searchTermsModel.insert(0, {terms: searchTerm});
                    }
                }
            }
        }

        headerPositioning: ListView.OverlayHeader

        section.property: 'firstLabel'
        section.criteria: ViewSection.FullString
        section.delegate: Item {
            width: annotationsList.width
            height: units.fingerUnit * 2
            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignBottom
                color: 'black'
                font.pixelSize: units.readUnit
                text: ((section != "")?section:qsTr('Sense classificar'))
            }
        }

        model: annotationsModel

        Common.SuperposedButton {
            id: addButton
            anchors {
                bottom: parent.bottom
                right: parent.right
            }
            size: units.fingerUnit * 2
            enabled: annotationsList.state == 'simple'
            visible: enabled
            imageSource: 'plus-24844'
            onClicked: annotations.openMenu(units.fingerUnit * 4, addAnnotationMenu, {})
        }

        function refreshUp() {
            annotationsList.lastSelected = "";
            annotationsModel.select();
        }

        function refreshWithLastSelected() {
            annotationsModel.select();
            var row = 0;
            console.log('looking for', annotationsList.lastSelected);

            while (row < annotationsModel.count) {
                if (annotationsModel.getObjectInRow(row)['title'] == annotationsList.lastSelected)
                    break;
                else
                    row++;
            }

            if (row < annotationsModel.count)
                annotationsList.positionViewAtIndex(row, ListView.Contain);
        }

        function requestClose() {
            if (annotationsList.currentIndex>-1) {
                annotationsList.closeItem();
                return false;
            } else
                return true;
        }

        Connections {
            target: annotationsModel
            onSortChanged: annotationsList.refreshUp()
        }

        Connections {
            target: annotations
            onFirstLabelFilterChanged: annotationsList.setUpFilters()
            onStateFilterChanged: annotationsList.setUpFilters()
            onLabelsFilterChanged: annotationsList.setUpFilters()
            onOnlyEmptyProjectsChanged: {
                console.log('only emptyProjects is', annotations.onlyEmptyProjects);
                annotationsList.setUpFilters();
            }
            onProjectChanged: {
                console.log('PROJECT changed to', annotations.project);
                annotationsList.setUpFilters();
            }
        }

        function setUpFilters() {
            var newFilters = annotations.labelsFilter;
            if (annotations.stateFilter !== '')
                newFilters = newFilters.concat(annotations.stateFilter);
            if (annotations.onlyEmptyProjects) {
                console.log('Only empty projects');
                newFilters = newFilters.concat(annotations.emptyProjectFilter);
            }
            if (annotations.project == '') {
                annotationsModel.bindValues = [];
            } else {
                annotationsModel.bindValues = [annotations.project];
                newFilters = newFilters.concat("project=?");
            }
            if (annotations.firstLabelFilter != '') {
                newFilters = newFilters.concat("firstLabel=?");
                annotationsModel.bindValues = [annotations.firstLabelFilter];
            }

            annotationsModel.filters = newFilters;
            console.log('FILTERS');
            console.log(newFilters);
            refreshUp();
        }

        function newIntelligentAnnotation() {
            var date = new Date();
            var newTitle = newAnnotation(qsTr('Anotació ') + date.toISOString(), date.toYYYYMMDDFormat() + " " + date.toHHMMFormat(), date.toYYYYMMDDFormat() + " " + date.toHHMMFormat(), 0)
            annotationsList.lastSelected = newTitle;
            refresh();
        }

        function newEmptyAnnotation() {
            var search = annotations.searchString;
            if (search == "") {
                search = qsTr('Nova anotació ' + annotationsModel.count);
            }

            var newTitle = newAnnotation(search, "", "", 0);

            annotationsModel.select();
            var row = 0;
            while (row < annotationsModel.count) {
                if (annotationsModel.getObjectInRow(row)['title'] == newTitle)
                    break;
                else {
                    row++;
                }
            }

            if (row < annotationsModel.count) {
                annotationsList.expandItem(row, newTitle, {identifier: newTitle});
            }
        }

        Component.onCompleted: setUpFilters()
    }


    Models.ExtendedAnnotations {
        id: annotationsModel

        searchFields: ['title', 'desc', 'project']
        filters: [annotations.stateFilter].concat(annotations.labelsFilter)
        sort: 'labelCode ASC, start ASC, end ASC'

        groupBy: 'labelGroup'

        Component.onCompleted: select()
    }

    Models.SavedAnnotationsSearchesModel {
        id: searchesModel
        Component.onCompleted: select()
    }

    Component {
        id: annotationsMenu

        Rectangle {
            id: menuRect

            property int requiredHeight: childrenRect.height + units.fingerUnit * 2
            property var options

            signal closeMenu()

            color: 'white'

            ColumnLayout {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                anchors.margins: units.fingerUnit

                spacing: units.fingerUnit

                GridView {
                    id: searchesGrid
                    Layout.fillWidth: true
                    Layout.preferredHeight: contentItem.height

                    cellWidth: units.fingerUnit * 4
                    cellHeight: units.fingerUnit * 2

                    model: searchesModel
                    interactive: false

                    delegate: Common.BoxedText {
                        width: searchesGrid.cellWidth
                        height: searchesGrid.cellHeight
                        text: model.title
                        margins: units.nailUnit
                        color: '#FFFFFF'
                        borderColor: 'transparent'

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                menuRect.closeMenu();
                                annotations.searchString = model.terms;
                            }
                        }

                    }

                    Component.onCompleted: searchesModel.select()
                }

                Common.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    fontSize: units.readUnit
                    text: qsTr('Desa la cerca')
                    onClicked: {
                        menuRect.closeMenu();
                        var t = annotations.searchString;
                        if (t !== '') {
                            searchesModel.insertObject({title: t, terms: t, created: Storage.currentTime()});
                        }
                    }
                }

                Rectangle {
                    // Menu separator
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.nailUnit
                    color: 'gray'
                }

                Common.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    fontSize: units.readUnit
                    text: qsTr('Mostra no finalitzats')
                    onClicked: {
                        menuRect.closeMenu();
                        annotations.stateFilter = stateTypes.active;
                    }
                }
                Common.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    fontSize: units.readUnit
                    text: qsTr('Mostra amb algun progrés')
                    onClicked: {
                        menuRect.closeMenu();
                        annotations.stateFilter = stateTypes.partial;
                    }
                }
                Common.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    fontSize: units.readUnit
                    text: qsTr('Mostra només finalitzats')
                    onClicked: {
                        menuRect.closeMenu();
                        annotations.stateFilter = stateTypes.done;
                    }
                }
                Common.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    fontSize: units.readUnit
                    text: qsTr('Mostra amb qualsevol estat')
                    onClicked: {
                        menuRect.closeMenu();
                        annotations.stateFilter = stateTypes.all;
                    }
                }

                Rectangle {
                    // Menu separator
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.nailUnit
                    color: 'gray'
                }

                Common.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    fontSize: units.readUnit
                    text: qsTr("Ordena per moment d'inici: els més antics en primer lloc")
                    onClicked: {
                        menuRect.closeMenu();
                        sortOption = sortType.start;
                        annotations.classifyVariable = 'start';
                    }
                }
                Common.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    fontSize: units.readUnit
                    text: qsTr("Ordena per moment d'inici: els més antics en darrer lloc")
                    onClicked: {
                        menuRect.closeMenu();
                        sortOption = sortType.startRev;
                        annotations.classifyVariable = 'start';
                    }
                }

                Common.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    fontSize: units.readUnit
                    text: qsTr("Ordena per moment final: els més recents en primer lloc")
                    onClicked: {
                        menuRect.closeMenu();
                        sortOption = sortType.end;
                        annotations.classifyVariable = 'end';
                    }
                }

                Common.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    fontSize: units.readUnit
                    text: qsTr("Ordena per moment final: els més recents en darrer lloc")
                    onClicked: {
                        menuRect.closeMenu();
                        sortOption = sortType.endRev;
                        annotations.classifyVariable = 'end';
                    }
                }

                Common.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    fontSize: units.readUnit
                    text: qsTr("Ordena per estat")
                    onClicked: {
                        menuRect.closeMenu();
                        sortOption = sortType.state;
                        annotations.classifyVariable = 'state';
                    }
                }

                Rectangle {
                    // Menu separator
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.nailUnit
                    color: 'gray'
                }

                Common.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    fontSize: units.readUnit
                    text: qsTr("Classifica per projecte")
                    onClicked: {
                        menuRect.closeMenu();
                        annotations.classifyVariable = 'project';
                    }
                }

                Common.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    fontSize: units.readUnit
                    text: qsTr("Classifica per data d'inici")
                    onClicked: {
                        menuRect.closeMenu();
                        annotations.classifyVariable = 'start';
                    }
                }

                Common.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    fontSize: units.readUnit
                    text: qsTr("Classifica per data de final")
                    onClicked: {
                        menuRect.closeMenu();
                        annotations.classifyVariable = 'end';
                    }
                }

                Common.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    fontSize: units.readUnit
                    text: qsTr("Classifica per estat")
                    onClicked: {
                        menuRect.closeMenu();
                        annotations.classifyVariable = 'state';
                    }
                }

                Rectangle {
                    // Menu separator
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.nailUnit
                    color: 'gray'
                }

                Common.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    fontSize: units.readUnit
                    text: qsTr("Combina a una taula...")
                    onClicked: {
                        menuRect.closeMenu();
                        console.log('Compte', annotationsModel.count);
                        annotations.combineAnnotationsIntoTable(annotationsModel)
                    }
                }

                Rectangle {
                    // Menu separator
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.nailUnit
                    color: 'gray'
                }

                Common.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    fontSize: units.readUnit
                    text: qsTr("Exporta...")
                    onClicked: {
                        menuRect.closeMenu();
                        exportAnnotations(['title','desc','image'],annotationsModel,[]);
                    }
                }
                Common.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    fontSize: units.readUnit
                    text: qsTr("Importa...")
                    onClicked: {
                        menuRect.closeMenu();
                        importAnnotations(['title','desc','image'],annotationsModel,[]);
                    }
                }
            }
        }

    }

    Component {
        id: singleAnnotationMenu

        Rectangle {
            id: menuRect

            property int requiredHeight: childrenRect.height + units.fingerUnit * 2
            property var options: {
                'index': -1,
                'labels': ''
            }

            signal closeMenu()

            color: 'white'
            ColumnLayout {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                anchors.margins: units.fingerUnit

                spacing: units.fingerUnit

                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: contentHeight
                    text: qsTr('Cerca similars:')
                }

                GridView {
                    id: searchesGrid
                    Layout.fillWidth: true
                    Layout.preferredHeight: contentItem.height

                    cellWidth: units.fingerUnit * 4
                    cellHeight: units.fingerUnit * 2

                    model: options['labels'].split(' ')
                    interactive: false

                    delegate: Common.BoxedText {
                        width: searchesGrid.cellWidth
                        height: searchesGrid.cellHeight
                        text: '#' + modelData
                        margins: units.nailUnit
                        color: '#FFFFFF'
                        borderColor: 'transparent'

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                menuRect.closeMenu();
                                annotations.searchString = '#' + modelData;
                            }
                        }

                    }

                    Component.onCompleted: searchesModel.select()
                }

                Rectangle {
                    // Menu separator
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.nailUnit
                    color: 'gray'
                }

                Common.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    fontSize: units.readUnit
                    text: qsTr('Marca finalitzat')
                    onClicked: {
                        menuRect.closeMenu();
                        annotationsList.setProperty(menuRect.options.index,'state',-1);
                    }
                }
                Common.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    fontSize: units.readUnit
                    text: qsTr('Duplica')
                    onClicked: {
                        menuRect.closeMenu();
                    }
                }
                Common.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    fontSize: units.readUnit
                    text: qsTr('Horari')
                    onClicked: {
                        menuRect.closeMenu();
                        openTimeTable(options['annotation']);
                    }
                }
            }
        }
    }

    Component {
        id: addAnnotationMenu

        Rectangle {
            id: menuRect

            property int requiredHeight: childrenRect.height + units.fingerUnit * 2
            property var options
            signal closeMenu()

            color: 'white'

            GridLayout {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: units.fingerUnit
                }

                columns: 2
                columnSpacing: units.fingerUnit
                rowSpacing: columnSpacing

                Common.ImageButton {
                    Layout.preferredHeight: units.fingerUnit * 3
                    Layout.preferredWidth: units.fingerUnit * 3
                    image: 'questionnaire-158862'
                    size: units.fingerUnit * 1.5
                    onClicked: {
                        menuRect.closeMenu();
                        annotations.invokeSubPageFunction('newIntelligentAnnotation',[]);
                    }
                }
                Text {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: qsTr('Crea anotació intel·ligent')
                }

                Common.ImageButton {
                    Layout.preferredHeight: units.fingerUnit * 3
                    Layout.preferredWidth: units.fingerUnit * 3
                    image: 'homework-152957'
                    size: units.fingerUnit * 1.5
                    onClicked: {
                        menuRect.closeMenu();
                        annotations.invokeSubPageFunction('newEmptyAnnotation',[]);
                    }
                }

                Text {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: qsTr('Crea anotació sense dades')
                }

                Common.ImageButton {
                    Layout.preferredHeight: units.fingerUnit * 3
                    Layout.preferredWidth: units.fingerUnit * 3
                    image: 'calendar-23684'
                    size: units.fingerUnit * 1.5
                    onClicked: {
                        menuRect.closeMenu();
                        annotations.openMenu(units.fingerUnit * 2, addTimetableAnnotationMenu, {})
                    }
                }

                Text {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: qsTr("Crea anotació a partir d'horari")
                }

                Common.ImageButton {
                    Layout.preferredHeight: units.fingerUnit * 3
                    Layout.preferredWidth: units.fingerUnit * 3
                    image: 'upload-25068'
                    size: units.fingerUnit * 1.5
                    onClicked: {
                        menuRect.closeMenu();
                        importAnnotations(['title','desc','image'],annotationsModel,[]);
                    }
                }

                Text {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: qsTr("Carrega anotacions")
                }

            }
        }
    }

    Component {
        id: addTimetableAnnotationMenu

        Rectangle {
            id: addTimetableAnnotationMenuRect

            property int requiredHeight: columnLayout.height + units.fingerUnit * 4
            property var options

            property var referenceDate
            property string annotation
            property int periodDay

            signal closeMenu()

            ColumnLayout {
                id: columnLayout

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: units.fingerUnit
                }

                GridView {
                    id: annotationsGrid

                    Layout.fillWidth: true
                    Layout.preferredHeight: contentItem.height

                    cellHeight: units.fingerUnit * 4
                    cellWidth: units.fingerUnit * 4

                    interactive: false

                    model: timetableAnnotationsModel

                    delegate: Item {
                        property string annotation: model.annotation

                        width: annotationsGrid.cellWidth
                        height: annotationsGrid.cellHeight
                        Common.BoxedText {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
                            color: 'transparent'
                            text: model.annotation
                            margins: units.nailUnit
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: annotationsGrid.currentIndex = model.index
                        }
                    }

                    highlight: Rectangle {
                        width: units.fingerUnit * 2
                        height: width
                        color: 'yellow'
                    }

                    highlightFollowsCurrentItem: true

                    onCurrentIndexChanged: {
                        addTimetableAnnotationMenuRect.annotation = currentItem.annotation;
                        timePeriodsModel.select();
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit * 2

                    color: 'gray'
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: units.nailUnit
                        Common.ImageButton {
                            Layout.fillHeight: true
                            Layout.preferredWidth: units.fingerUnit
                            image: 'arrow-145769'
                            onClicked: {
                                var newDate = addTimetableAnnotationMenuRect.referenceDate;
                                newDate.setDate(newDate.getDate()-1);
                                addTimetableAnnotationMenuRect.referenceDate = newDate;
                            }
                        }

                        Text {
                            id: dayText

                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter

                            text: addTimetableAnnotationMenuRect.referenceDate.toLongDate()

                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                            MouseArea {
                                anchors.fill: parent
                                onClicked: parent.state = (parent.state == 'selected')?'unselected':'selected'
                            }
                        }

                        Common.ImageButton {
                            Layout.fillHeight: true
                            Layout.preferredWidth: units.fingerUnit
                            image: 'arrow-145766'
                            onClicked: {
                                var newDate = addTimetableAnnotationMenuRect.referenceDate;
                                newDate.setDate(newDate.getDate()+1);
                                addTimetableAnnotationMenuRect.referenceDate = newDate;
                            }
                        }
                    }
                }

                ListView {
                    id: periodTimesList

                    Layout.fillWidth: true
                    Layout.preferredHeight: contentItem.height

                    interactive: false
                    model: timePeriodsModel
                    delegate: Rectangle {
                        width: periodTimesList.width
                        height: units.fingerUnit * 1.5

                        states: [
                            State {
                                name: 'unselected'
                            },
                            State {
                                name: 'selected'
                            }
                        ]
                        state: 'unselected'

                        color: (state == 'selected')?'yellow':'white'
                        border.color: 'black'

                        property string title: model.title
                        property string startTime: model.startTime
                        property string endTime: model.endTime

                        RowLayout {
                            anchors.fill: parent
                            Text {
                                Layout.fillHeight: true
                                Layout.preferredWidth: units.fingerUnit * 2
                                text: model.startTime
                            }

                            Text {
                                Layout.fillHeight: true
                                Layout.preferredWidth: units.fingerUnit * 2
                                text: model.endTime
                            }

                            Text {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                text: model.title
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                parent.state = (parent.state == 'unselected')?'selected':'unselected';
                            }
                        }
                    }

                }

                Common.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit * 2
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr('Crea totes les anotacions')
                    onClicked: {
                        addTimetableAnnotationMenuRect.createAllAnnotations();
                        addTimetableAnnotationMenuRect.closeMenu();
                    }
                }
            }
            Models.TimeTablesModel {
                id: timetableAnnotationsModel

                fieldNames: ['annotation']

                Component.onCompleted: {
                    selectUnique('annotation');
                }
            }
            Models.TimeTablesModel {
                id: timePeriodsModel

                filters: [
                    'annotation=?',
                    'periodDay=?'
                ]
                bindValues: [
                    addTimetableAnnotationMenuRect.annotation,
                    addTimetableAnnotationMenuRect.periodDay
                ]

                sort: 'periodTime ASC'
            }

            Component.onCompleted: {
                addTimetableAnnotationMenuRect.referenceDate = new Date();
            }

            onReferenceDateChanged: {
                periodDay = ((referenceDate.getDay() + 6) % 7) + 1;
                timePeriodsModel.select();
            }

            function createAllAnnotations() {
                var created = false;

                for (var i=0; i<periodTimesList.count; i++) {
                    var periodObj = periodTimesList.contentItem.children[i];
                    if (periodObj.state == 'selected') {
                        console.log(periodObj.title, periodObj.startTime, periodObj.endTime);
                        var date = addTimetableAnnotationMenuRect.referenceDate;
                        var title = periodObj.title;
                        var start = date.toYYYYMMDDFormat() + " " + periodObj.startTime;
                        var end = date.toYYYYMMDDFormat() + " " + periodObj.endTime;
                        annotations.newAnnotation(qsTr('Diari') + " " + title + " " + date.toShortReadableDate(), start, end, 0);
                        created = true;
                    }
                }

                if (created)
                    annotationsModel.select();
            }
        }
    }

    Models.RubricsModel {
        id: rubricsModel

        Component.onCompleted: select()
    }


    onSortLabelsChanged: setUpAnnotations()

    Component.onCompleted: setUpAnnotations()

    function setUpAnnotations() {
        // All labels are numbered starting at 1. Number 0 means no label assigned.

        var firstLabel = "";

//        var firstLabelString = "CASE WHEN labels = '' OR labels IS NULL THEN '' WHEN instr(labels,' ')>1 THEN substr(labels,1,instr(labels,' ')-1) ELSE labels END";
        // First wildcard: position to start searching the first label. It is 1, but it should be changed to other positions.
        // Second wildcard: the labels separator is a single blank space.
        // Instr fins the position of the wildcard. If it is not found, instr returns 0.

        var labelCode = "";
        var groupingCode = "";
        var groupLabel = "";

        if (sortLabels != '') {
            var labels = sortLabels.replace(/\s{2,}/,' ').split(' ');
//            labelCode = "CASE (SELECT " + firstLabelString + ") WHEN '' THEN 0";

            var detectFirstLabel = "CASE WHEN labels = '' OR labels IS NULL THEN ";
            labelCode = detectFirstLabel + "0";
            firstLabel = detectFirstLabel + "''";

            for (var i=0; i<labels.length; i++) {
                // Check if the first label is between the record labels
                var detectLabel = " WHEN instr(' '||labels||' ','" + labels[i] + "')>0 THEN "
                labelCode += detectLabel + (i+1);
                firstLabel += detectLabel + "'" + labels[i] + "'";
                //                labelCode += " WHEN '" + labels[i] + "' THEN " + (i+1);
            }
            labelCode += " ELSE " + (labels.length+1) + " END";

            groupLabel = firstLabel;
            firstLabel += " ELSE labels END";
            groupLabel += " ELSE '' END";

            groupingCode = "CASE (" + groupLabel + ") WHEN '' THEN ROWID ELSE (" + groupLabel + ") END";
        } else {
            labelCode = "0";
            firstLabel = "''";
            groupingCode = "ROWID";
        }

        console.log('grouping code', groupingCode);
        annotationsModel.calculatedFieldNames = [
            firstLabel + " AS firstLabel",
            labelCode + " AS labelCode",
            groupingCode + " AS labelGroup",
            "COUNT(" + groupingCode + ") AS groupCount"
        ]
        annotationsModel.select();
    }
}
