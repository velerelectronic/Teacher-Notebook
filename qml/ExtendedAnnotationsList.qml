import QtQuick 2.5
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import "qrc:///javascript/Storage.js" as Storage

Rectangle {
    id: annotations
    property string pageTitle: qsTr('Anotacions (esteses)');

    property bool isVertical: width<height

    signal showExtendedAnnotation (var parameters)
    signal openMenu(int initialHeight, var menu)
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

    /*
    signal deletedAnnotations (int num)

    signal importAnnotations(var fieldNames, var writeModel, var fieldConstants)
    signal exportAnnotations(var fieldNames, var writeModel, var fieldConstants)
    signal openingDocumentExternally(string document)
    signal showEvent(var parameters)
*/

//    property bool canClose: true

    property string searchString: ''

    function newAnnotation() {
        annotations.showExtendedAnnotation({title: annotationsModel.searchString.replace('#',' ')});
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
            border.color: 'gray'

            property int requiredHeight: units.fingerUnit * 2 + ((rubricsAssessmentModel.count>0)?(units.fingerUnit * 2.5):0)
            property var model: annotationsModel.fieldNames
            property string title: annotationItem.model.title

            color: (annotationItem.model.state>=0)?'white':'#AAAAAA'
            clip: true

            states: [
                State {
                    name: 'unselected'
                    PropertyChanges {
                        target: annotationItem
                    }
                },
                State {
                    name: 'selected'
                    PropertyChanges {
                        target: annotationItem
                        color: 'yellow'
                    }
                }
            ]
            state: 'unselected'
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
                    Layout.preferredWidth: parent.width / 4
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
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (annotationItem.state === 'unselected') {
                        annotationItem.state = 'selected';
                        if (chooseMode) {
                            chosenAnnotation(model.title);
                        } else {
                            annotationsList.expandItem(annotationItem.model.index, {title: annotationItem.model.title});
                        }
                    } else {
                        annotationItem.state = 'unselected';
                    }
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
            onOpenMenu: annotations.openMenu(initialHeight, menu)

            onOpenRubricGroupAssessment: {
                console.log('Now')
                annotations.openRubricGroupAssessment(assessment, rubric, rubricsModel, rubricsAssessmentModel);
            }
        }

        header: Item {
            z: 300
            width: annotationsList.width
            height: units.fingerUnit * 1.5
            visible: annotationsList.currentIndex < 0

            RowLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                spacing: units.nailUnit

                Common.SearchBox {
                    id: searchAnnotations
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit

                    text: annotations.searchString

                    onTextChanged: annotations.searchString = text
                    onPerformSearch: {
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
                Common.TextButton {
                    Layout.fillHeight: true
                    text: qsTr('Opcions')
                    onClicked: openMenu(units.fingerUnit * 4, annotationsMenu)
                }
            }
        }
        headerPositioning: ListView.OverlayHeader

        section.property: annotations.classifyVariable

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
            imageSource: 'plus-24844'
            onClicked: newAnnotation()
            onPressAndHold: importAnnotations(['title','desc','image'],annotationsModel,[])
        }
        Common.SuperposedButton {
            anchors {
                bottom: parent.bottom
                left: parent.left
            }
            size: units.fingerUnit * 2
            imageSource: 'box-24557'
            onClicked: exportAnnotations(['title','desc','image'],annotationsModel,[])
        }
    }

    Models.ExtendedAnnotations {
        id: annotationsModel

        searchFields: ['title', 'desc', 'project']
        sort: sortOption

        onSortChanged: {
            select();
        }

        Component.onCompleted: {
            select();
            console.log('count', count);
        }
    }

    onStateFilterChanged: {
        annotationsModel.filters = [stateFilter].concat(labelsFilter);
        annotationsModel.select();
    }
    onLabelsFilterChanged: {
        annotationsModel.filters = [stateFilter].concat(labelsFilter);
        annotationsModel.select();
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
            }
        }

    }
    Models.RubricsModel {
        id: rubricsModel

        Component.onCompleted: select()
    }
}
