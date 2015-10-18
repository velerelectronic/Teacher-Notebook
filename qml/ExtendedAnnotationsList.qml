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
        'endRev': 'end DESC'
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

    GridLayout {
        id: mainGrid

        anchors.fill: parent

        states: [
            State {
                name: 'simple'

                PropertyChanges {
                    target: mainGrid
                    rows: 1
                    columns: 1
                }

                PropertyChanges {
                    target: selectedAnnotationsList
                    width: 0
                    height: 0
                }
            },
            State {
                name: 'split'

                PropertyChanges {
                    target: mainGrid
                    rows: (isVertical)?2:1
                    columns: 3-rows
                }

                PropertyChanges {
                    target: selectedAnnotationsList
                    width: (!isVertical)?(mainGrid.width/2):mainGrid.width
                    height: (isVertical)?(mainGrid.height/2):mainGrid.height
                }
            }
        ]
        state: (selectedAnnotationsModel.count==0)?'simple':'split'

        ListView {
            id: annotationsList
            Layout.fillWidth: true
            Layout.fillHeight: true

            bottomMargin: units.fingerUnit * 3
            clip: true

            header: Item {
                z: 300
                width: annotationsList.width
                height: units.fingerUnit * 1.5

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

                            selectedAnnotationsModel.clear();

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

            section.property: 'project'

            section.delegate: Common.BoxedText {
                color: 'green'
                width: annotationsList.width
                height: units.fingerUnit
                text: section
                fontSize: units.readUnit
                margins: units.nailUnit
                textColor: 'white'
            }

            delegate: Rectangle {
                id: annotationItem
                width: annotationsList.width
                height: units.fingerUnit * 2
                border.color: 'black'
                color: (model.state>=0)?'white':'#AAAAAA'
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
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit

                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.title
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 4
                        color: 'red'
                        text: model.start + "\n" + model.end
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 4
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: 'green'
                        text: model.labels
                    }

                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 4
                        text: {
                            if (model.state<0) {
                                return qsTr('Finalitzat');
                            } else {
                                if ((model.state>0) && (model.state<=10)) {
                                    return (model.state * 10) + "%";
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
                                selectedAnnotationsModel.clear();
                                chosenAnnotation(model.title);
                            }

                            selectedAnnotationsModel.append({title: model.title, fake: model.index});
                            console.log('Appended',model.title);
                        } else {
                            annotationItem.state = 'unselected';
                            for (var i=0; i<selectedAnnotationsModel.count; i++) {
                                if (selectedAnnotationsModel.get(i)['title'] == model.title) {
                                    selectedAnnotationsModel.remove(i);
                                }
                            }
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

        ListView {
            id: selectedAnnotationsList

            Layout.preferredWidth: width
            Layout.preferredHeight: height

            clip: true
            orientation: ListView.Horizontal

            snapMode: ListView.SnapOneItem

            Behavior on width {
                NumberAnimation { duration: 200 }
            }

            Behavior on height {
                NumberAnimation { duration: 200 }
            }

            model: selectedAnnotationsModel

            delegate: Item {
                property string thisTitle: model.title

                width: selectedAnnotationsList.width
                height: selectedAnnotationsList.height

                Common.BoxedText {
                    id: numberBar
                    color: 'green'
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                    height: units.fingerUnit

                    margins: units.nailUnit
                    textColor: 'white'
                    text: (model.index+1).toString() + qsTr(' de ') + selectedAnnotationsModel.count
                }

                ShowExtendedAnnotation {
                    anchors {
                        top: numberBar.bottom
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }

                    title: parent.thisTitle

                    onOpenMenu: annotations.openMenu(initialHeight,menu)
                    onOpenRubricGroupAssessment: annotations.openRubricGroupAssessment(assessment, rubric, rubricsModel, rubricsAssessmentModel)
                }
            }
        }
    }

    ListModel {
        id: selectedAnnotationsModel
    }

    Models.ExtendedAnnotations {
        id: annotationsModel

        searchFields: ['title', 'desc', 'project']
        sort: sortOption

        onSortChanged: {
            selectedAnnotationsModel.clear();
            select();
        }

        Component.onCompleted: select();
    }

    onStateFilterChanged: {
        annotationsModel.filters = [stateFilter].concat(labelsFilter);
        selectedAnnotationsModel.clear();
        annotationsModel.select();
    }
    onLabelsFilterChanged: {
        annotationsModel.filters = [stateFilter].concat(labelsFilter);
        selectedAnnotationsModel.clear();
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
                    }
                }

            }
        }

    }
}
