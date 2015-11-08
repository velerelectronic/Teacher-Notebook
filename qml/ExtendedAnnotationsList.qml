import QtQuick 2.5
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import "qrc:///javascript/Storage.js" as Storage
import "qrc:///common/FormatDates.js" as FormatDates

Rectangle {
    id: annotations
    property string pageTitle: qsTr('Anotacions (esteses)');

    property bool isVertical: width<height

    signal showExtendedAnnotation (var parameters)
    signal openMenu(int initialHeight, var menu, var options)
    signal chosenAnnotation(string annotation)
    signal openRubricGroupAssessment(int assessment, int rubric, var rubricsModel, var rubricsAssessmentModel)

    property bool chooseMode: false

    property string classifyVariable: 'end'

    property var stateTypes: {
        'done': "state < 0",
        'active': "(state >= 0 OR state IS NULL)",
        'specific': "state = 0",
        'partial': "(state > 0 AND state < 10)",
        'all': ''
    }

    property string stateFilter: stateTypes.active

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

    function newAnnotation() {
        annotations.showExtendedAnnotation({title: annotationsModel.searchString.replace('#',' ')});
    }

    function refresh() {
        annotationsModel.select();
        if (annotationsList.lastSelected > -1)
            annotationsList.positionViewAtIndex(annotationsList.lastSelected, ListView.Contain)
    }

    function refreshUp() {
        annotationsList.lastSelected = -1;
        annotationsModel.select();
    }

    Common.UseUnits { id: units }

    color: '#F2F2F2'

    Common.ExpandableListView {
        id: annotationsList
        anchors.fill: parent
        anchors.margins: units.nailUnit

        bottomMargin: units.fingerUnit * 3
        clip: true

        itemComponent: Rectangle {
            id: annotationItem

            property int requiredHeight: units.fingerUnit * 2 + ((rubricsAssessmentModel.count>0)?(units.fingerUnit * 2.5):0)
            property var model: annotationsModel.fieldNames
            property string title: annotationItem.model.title
            property bool isLastSelected: annotationsList.lastSelected == annotationItem.model.index

            onIsLastSelectedChanged: {
                console.log('Last selected', isLastSelected);
            }

            color: (annotationItem.model.state>=0)?'white':'#AAAAAA'
            clip: true

            states: [
                State {
                    name: 'unselected'
                    PropertyChanges {
                        target: annotationItem
                        border.color: 'gray'
                    }
                },
                State {
                    name: 'selected'
                    PropertyChanges {
                        target: annotationItem
                        border.color: 'green'
                        border.width: units.nailUnit
                    }
                }
            ]
            state: (isLastSelected)?'selected':'unselected'

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (annotationItem.state === 'unselected') {
                        if (chooseMode) {
                            annotationsList.lastSelected = annotationItem.model.index;
                            chosenAnnotation(model.title);
                        } else {
                            annotationsList.expandItem(annotationItem.model.index, {title: annotationItem.model.title});
                        }
                    } else {
                        annotationsList.expandItem(annotationItem.model.index, {title: annotationItem.model.title});
                    }
                }
            }

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
                    text: annotationItem.model.title
                }
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width / 4
                    color: 'red'
                    text: annotationItem.model.start + "\n" + annotationItem.model.end
                }
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width / 4
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    color: 'green'
                    text: "<b>" + annotationItem.model.project + "</b> &nbsp;" + annotationItem.model.labels
                }

                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width / 8
                    text: {
                        if (annotationItem.model.state<0) {
                            return qsTr('Finalitzat');
                        } else {
                            if ((annotationItem.model.state>0) && (annotationItem.model.state<=10)) {
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
                rubricsAssessmentModel.bindValues = [annotationItem.title];
                rubricsAssessmentModel.select();
            }

        }

        expandedComponent: ShowExtendedAnnotation {
            onOpenMenu: annotations.openMenu(initialHeight, menu, {})

            onOpenRubricGroupAssessment: {
                console.log('Now')
                annotations.openRubricGroupAssessment(assessment, rubric, rubricsModel, rubricsAssessmentModel);
            }

            onDeletedAnnotation: {
                annotationsList.closeItem();
                refresh();
            }
        }

        header: Item {
            id: annotationsListHeader

            z: 300
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
                        var row = 0;
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
                        annotationsList.lastSelected = row;
                        annotationsList.positionViewAtIndex(row, ListView.Center);
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
        headerPositioning: ListView.PullBackHeader

        section.property: (annotationsList.state == 'simple')?annotations.classifyVariable:''

        section.delegate: Item {
            width: annotationsList.width
            height: units.fingerUnit * 2
            Text {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: units.fingerUnit

                verticalAlignment: Text.AlignVCenter
                font.pixelSize: units.readUnit
//                font.bold: true
                color: 'black'
                text: section
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
    }

    Models.ExtendedAnnotations {
        id: annotationsModel

        searchFields: ['title', 'desc', 'project']
        sort: sortOption

        onSortChanged: refreshUp()

        Component.onCompleted: select()
    }

    onStateFilterChanged: {
        annotationsModel.filters = [stateFilter].concat(labelsFilter);
        refreshUp();
    }
    onLabelsFilterChanged: {
        annotationsModel.filters = [stateFilter].concat(labelsFilter);
        refreshUp();
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
            }
        }
    }

    Component {
        id: addAnnotationMenu

        Rectangle {
            id: menuRect

            property int requiredHeight: childrenRect.height + units.fingerUnit * 2

            signal closeMenu()

            color: 'white'

            Flow {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: units.fingerUnit
                }

                spacing: units.fingerUnit

                Common.ImageButton {
                    Layout.preferredHeight: units.fingerUnit * 3
                    Layout.preferredWidth: units.fingerUnit * 3
                    image: 'questionnaire-158862'
                    size: units.fingerUnit * 2
                    onClicked: {
                        menuRect.closeMenu();
                        var date = new Date();
                        var newTitle = qsTr('Anotació ' + date.toISOString());
                        annotationsModel.insertObject({
                                                          title: newTitle,
                                                          desc: '',
                                                          start: date.toYYYYMMDDFormat(),
                                                          end: date.toYYYYMMDDFormat(),
                                                          state: 0
                                                      });
                        refreshUp();

                        var row = 0;
                        while (row < annotationsModel.count) {
                            if (annotationsModel.getObjectInRow(row)['title'] == newTitle) {
                                break;
                            } else {
                                row++;
                            }
                        }
                        if (row < annotationsModel.count) {
                            annotationsList.lastSelected = row;
                            console.log('Setting last selected', row);
                            annotationsList.positionViewAtIndex(row, ListView.Center);
                        }
                    }
                }

                Common.ImageButton {
                    Layout.preferredHeight: units.fingerUnit * 3
                    Layout.preferredWidth: units.fingerUnit * 3
                    image: 'homework-152957'
                    size: units.fingerUnit * 2
                    onClicked: {
                        menuRect.closeMenu();
                        newAnnotation();
                    }
                }

                Common.ImageButton {
                    Layout.preferredHeight: units.fingerUnit * 3
                    Layout.preferredWidth: units.fingerUnit * 3
                    image: 'upload-25068'
                    size: units.fingerUnit * 2
                    onClicked: {
                        menuRect.closeMenu();
                        importAnnotations(['title','desc','image'],annotationsModel,[]);
                    }
                }

                Common.ImageButton {
                    Layout.preferredHeight: units.fingerUnit * 3
                    Layout.preferredWidth: units.fingerUnit * 3
                    image: ''
                    size: units.fingerUnit * 2
                }
            }
        }
    }

    Models.RubricsModel {
        id: rubricsModel

        Component.onCompleted: select()
    }
}
