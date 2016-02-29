import QtQuick 2.5
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors
import "qrc:///javascript/Storage.js" as Storage
import "qrc:///common/FormatDates.js" as FormatDates

BasicPage {
    id: annotations

    pageTitle: qsTr('Anotacions (esteses)');

    property bool isVertical: width<height

    property bool hideHeader: false

    onHideHeaderChanged: console.log('hide header has changed to', hideHeader)

    property bool subList: false

    function showExtendedAnnotation (parameters) {
        annotations.openPageArgs('ShowExtendedAnnotation', parameters)
    }

//    signal openMenu(int initialHeight, var menu, var options)
    signal chosenAnnotation(string annotation)
    signal combineAnnotationsIntoTable(var annotationsModel)

    function openRubricGroupAssessment(assessment, rubric, rubricsModel, rubricsAssessmentModel) {
        annotations.openPageArgs('RubricGroupAssessment',{assessment: assessment, rubric: rubric, rubricsModel: rubricsModel, rubricsAssessmentModel: rubricsAssessmentModel});
    }

    signal openTimeTable(string annotation)
    function showExtendedAnnotationsList(parameters) {
        openPageArgs('ExtendedAnnotationsList', parameters);
    }

    property bool chooseMode: false

    property string classifyVariable: 'end'

    property string sortLabels: ''

    property int firstLabelCodeFilter: 0

    property int requiredHeight

    property var stateTypes: {
        'done': "state < 0",
        'active': "(state >= 0 OR state IS NULL)",
        'specific': "state = 0",
        'partial': "(state > 0 AND state < 10)",
        'all': ''
    }

    property string stateFilter: stateTypes.active

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

    property var acumulatedLabels: []

    signal exportAnnotations(var fieldNames, var writeModel, var fieldConstants)
    signal importAnnotations(var fieldNames, var writeModel, var fieldConstants)

    /*
    signal deletedAnnotations (int num)

    signal openingDocumentExternally(string document)
    signal showEvent(var parameters)
*/

//    property bool canClose: true

    property string searchString: ''

    onSearchStringChanged: {
        var textArray = searchString.split(/\s+/i);
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

        onRequiredHeightChanged: {
            annotations.requiredHeight = annotationsList.requiredHeight;
            console.log('Required height changed', requiredHeight);
        }

        property int firstLabelCodeFilter: annotations.firstLabelCodeFilter

        bottomMargin: units.fingerUnit * 3

        onStateChanged: {
            if ((isDirty) && (state == 'simple')){
                refresh();
                isDirty = false;
            }
        }

        itemComponent: Rectangle {
            id: annotationItem

            border.color: (annotationItem.isCurrentItem)?'green':'black'
            border.width: (annotationItem.isCurrentItem)?units.nailUnit:1

            property bool isCurrentItem: false
            property int requiredHeight: units.fingerUnit

            function calculateRequiredHeight() {
                annotationItem.requiredHeight = Math.max(units.fingerUnit, annotationSubLoader.requiredHeight + annotationSubLoader.anchors.margins * 2);
            }

            function itemSelected() {
                switch(modelGroupCount) {
                case 1:
                    annotations.showExtendedAnnotation({identifier: modelTitle});
                    break;
                case 0:
                    break;
                default:
                    if (subList) {
                        annotations.showExtendedAnnotation({identifier: modelTitle});
                    } else {
                        annotations.showExtendedAnnotationsList({firstLabelCodeFilter: annotationItem.modelLabelCode, hideHeader: true, subList: true, sortLabels: annotations.sortLabels, acumulatedLabels: [annotationItem.modelFirstLabel]});
                    }
                    break;
                }

            }

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
                switch(modelGroupCount) {
                case 1:
                    annotationSubLoader.sourceComponent = singleAnnotationComponent;
                    break;
                case 0:
                    break;
                default:
                    if (subList)
                        annotationSubLoader.sourceComponent = singleAnnotationComponent;
                    else
                        annotationSubLoader.sourceComponent = annotationGroupComponent;
                    break;
                }
                annotationSubLoader.getRequiredHeight();
            }

            Loader {
                id: annotationSubLoader

                anchors.fill: parent
                anchors.margins: units.nailUnit

                onLoaded: getRequiredHeight()

                property int requiredHeight: 0

                onRequiredHeightChanged: annotationItem.calculateRequiredHeight()

                Connections {
                    target: annotationSubLoader.item
                    ignoreUnknownSignals: true
                    onRequiredHeightSignal: {
                        annotationSubLoader.getRequiredHeight();
                    }
                }

                function getRequiredHeight() {
                    console.log('needed required height');
                    if (annotationSubLoader.item !== null) {
                        console.log('needed 2 required height');
                        annotationSubLoader.requiredHeight = annotationSubLoader.item.requiredHeight;
                    }
                }
            }

            Component {
                id: singleAnnotationComponent

                Item {
                    id: singleAnnotationItem

                    property int requiredHeight: units.fingerUnit * 2 + ((rubricsAssessmentModel.count>0)?(units.fingerUnit * 2.5):0)

                    property string title: annotationItem.modelTitle

                    onRequiredHeightChanged: {
                        annotationSubLoader.getRequiredHeight();
                    }
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

                    onTitleChanged: {
                        rubricsAssessmentModel.bindValues = [annotationItem.modelTitle];
                        rubricsAssessmentModel.select();
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

                    onOpenMenu: annotations.openMenu(initialHeight, menu, options)

                    onOpenPageArgs: annotations.openPageArgs(page, args)

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

        header: ((annotations.hideHeader) || (annotations.searchString == ''))?null:headerComponent

        Component {
            id: headerComponent
            Rectangle {
                id: annotationsListHeader

                z: 10
                color: '#9999FF'
                width: annotationsList.width
                height: units.fingerUnit * 2
                Text {
                    anchors.fill: parent
                    text: annotations.searchString
                }
            }
        }

        headerPositioning: ListView.OverlayHeader

        section.property: 'blockDate'
        section.criteria: ViewSection.FullString
        section.delegate: Item {
            width: annotationsList.width
            height: units.fingerUnit * 2
            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignBottom
                color: 'black'
                font.pixelSize: units.readUnit
                text: {
                    switch(parseInt(section)) {
                    case -4:
                        return qsTr("Fa més d'un any");
                    case -3:
                        return qsTr("L'any passat");
                    case -2:
                        return qsTr("El mes passat");
                    case -1:
                        return qsTr("La setmana passada");
                    case 0:
                        return qsTr('Avui');
                    case 1:
                        return qsTr("Aquesta setmana");
                    case 2:
                        return qsTr("Aquest mes");
                    case 3:
                        return qsTr("Aquest any");
                    case 4:
                        return qsTr("Molt més tard");
                    default:
                        return '';
                    }
                }

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
            imageSource: 'plus-24844'
            onClicked: annotations.openMenu(units.fingerUnit * 4, addImmediateAnnotationMenu, {labels: acumulatedLabels})
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

        onFirstLabelCodeFilterChanged: annotationsList.setUpFilters()

        Connections {
            target: annotations

            onStateFilterChanged: annotationsList.setUpFilters()
            onLabelsFilterChanged: annotationsList.setUpFilters()
        }

        function setUpFilters() {
            var newFilters = annotations.labelsFilter;
            if (annotations.stateFilter !== '')
                newFilters = newFilters.concat(annotations.stateFilter);
            if (annotationsList.firstLabelCodeFilter !== 0) {
                console.log("last before", annotationsList.firstLabelCodeFilter);
                newFilters = newFilters.concat("labelCode=" + annotationsList.firstLabelCodeFilter + "");
//                annotationsModel.bindValues = [annotationsList.firstLabelCodeFilter];
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

        Component.onCompleted: {
            setUpFilters();
        }

        onNewButtonsModel: {
            console.log('new buttons model----',buttonsModel);
            annotations.buttonsModel = buttonsModel;
        }
    }


    Models.ExtendedAnnotations {
        id: annotationsModel

        searchFields: ['title', 'desc', 'project']
        filters: [annotations.stateFilter].concat(annotations.labelsFilter)
        sort: 'labelCode ASC, blockDate ASC, start ASC, end ASC'

        groupBy: (annotations.subList)?'title':'labelGroup'

        Component.onCompleted: annotationsModel.refreshAnnotations()

        function refreshAnnotations() {
            annotationsModel.selectAnnotations(sortLabels);
        }
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
        id: addImmediateAnnotationMenu

        AboveMenu {
            id: menuRect

            requiredHeight: units.fingerUnit * 10

//            onOptionsChanged:

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: units.fingerUnit

                Editors.TextAreaEditor3 {
                    id: newAnnotationEditor
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    border.color: 'black'
                }
                Flow {
                    id: flow
                    Layout.fillWidth: true
                    Layout.preferredHeight: flow.childrenRect.height
                    spacing: units.nailUnit

                    Text {
                        text: qsTr('Etiquetes')
                    }

                    Repeater {
                        id: flowRepeater

                        model: {
                            return menuRect.getOption('labels', []);
                        }

                        delegate: Rectangle {
                            width: childrenRect.width + units.nailUnit
                            height: units.fingerUnit
                            color: '#AAFFAA'
                            Text {
                                anchors {
                                    top: parent.top
                                    bottom: parent.bottom
                                    left: parent.left
                                    margins: units.nailUnit
                                }
                                width: contentWidth
                                verticalAlignment: Text.AlignVCenter

                                text: modelData
                            }
                        }
                    }
                }

                Flow {
                    Layout.fillWidth: true
                    Layout.preferredHeight: childrenRect.height

                    spacing: units.fingerUnit

                    Common.ImageButton {
                        width: units.fingerUnit * 1.5
                        height: width
                        image: 'floppy-35952'
                        onClicked: {
                            var re = new RegExp("^(.+)\n+((?:.|\n|\r)*)$","g");
                            console.log(newAnnotationEditor.content);
                            var res = re.exec(newAnnotationEditor.content);
                            var date = (new Date()).toYYYYMMDDHHMMFormat();
                            var newObj = {
                                labels: flowRepeater.model.join(' ').trim(),
                                start: date,
                                end: date
                            }

                            if (res != null) {
                                newObj['title'] = res[1].trim();
                                newObj['desc'] = res[2];
                                if (annotationsModel.insertObject(newObj)) {
                                    annotations.refresh();
                                    menuRect.closeMenu();
                                }
                            } else {
                                newObj['title'] = newAnnotationEditor.content;
                                newObj['desc'] = '';
                                if (annotationsModel.insertObject(newObj)) {
                                    annotations.refresh();
                                    menuRect.closeMenu();
                                }
                            }
                        }
                    }
                    Common.ImageButton {
                        width: units.fingerUnit * 1.5
                        height: width
                        image: 'questionnaire-158862'
                        size: units.fingerUnit * 1.5
                        onClicked: {
                            menuRect.closeMenu();
                            annotations.invokeSubPageFunction('newIntelligentAnnotation',[]);
                        }
                    }

                    Common.ImageButton {
                        width: units.fingerUnit * 1.5
                        height: width
                        image: 'calendar-23684'
                        size: units.fingerUnit * 1.5
                        onClicked: {
                            menuRect.closeMenu();
                            annotations.openMenu(units.fingerUnit * 2, addTimetableAnnotationMenu, {})
                        }
                    }

                    Common.ImageButton {
                        width: units.fingerUnit * 1.5
                        height: width
                        image: 'upload-25068'
                        size: units.fingerUnit * 1.5
                        onClicked: {
                            menuRect.closeMenu();
                            importAnnotations(['title','desc','image'],annotationsModel,[]);
                        }
                    }

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

//    onSortLabelsChanged: annotationsModel.refreshAnnotations()

    function openOmniboxSearch() {
        annotations.openPageArgs('OmniboxSearch',{});
    }

    function openOptions() {
        annotations.openMenu(units.fingerUnit * 4, annotationsMenu, {})
    }

    Component.onCompleted: {
        annotations.buttonsModel.append({icon: 'magnifying-glass-481818', object: annotations, method: 'openOmniboxSearch'});
        annotations.buttonsModel.append({icon: 'cog-147414', object: annotations, method: 'openOptions'});
    }
}
