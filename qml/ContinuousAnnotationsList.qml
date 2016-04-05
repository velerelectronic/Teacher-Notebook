import QtQuick 2.5
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors
import "qrc:///javascript/Storage.js" as Storage
import "qrc:///common/FormatDates.js" as FormatDates
import ClipboardAdapter 1.0

BasicPage {
    id: annotations

    pageTitle: qsTr('Anotacions continues');

    Common.UseUnits {
        id: units
    }

    property var periodStart: new Date();
    property var periodEnd: new Date();

    property string searchString: ''

    property string firstAnnotation: ''
    property string headerText: qsTr('Més enrere')
    property string footerText: qsTr('Més envant')

    property alias annotationsModel2: annotationsModel

    mainPage: Item {
        id: mainContinuousView
        property bool expanded: false

        function expand(value) {
            mainContinuousView.expanded = value;
            if (value) {
                annotations.pushButtonsModel();
                annotations.buttonsModel.append({icon: 'copy-97584', object: mainContinuousView, method: 'copyAnnotationDescription'});
                annotations.buttonsModel.append({icon: 'questionnaire-158862', object: mainContinuousView, method: 'openRubricAssessmentMenu'});
                annotations.buttonsModel.append({icon: 'road-sign-147409', object: mainContinuousView, method: 'closeInlineAnnotation'});
            } else {
                annotations.popButtonsModel();
            }
        }

        Connections {
            target: annotations
            onSearchStringChanged: {
                annotationsModel.searchString = annotations.searchString;
                annotationsModel.selectAnnotations('');
            }
        }

        ColumnLayout {
            anchors.fill: parent
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: units.fingerUnit
                color: '#DDDDFF'
                Text {
                    anchors.fill: parent
                    font.pixelSize: units.readUnit
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: qsTr('Paraules de cerca: ') + annotationsModel.searchString
                }
            }
            InlineExpandedAnnotation {
                id: expandedAnnotation
                Layout.fillHeight: true
                Layout.fillWidth: true

                annotationsModel: annotationsModel2

                onGotoPreviousAnnotation: {
                    annotationsList.currentIndex = annotationsList.currentIndex - 1;
                    annotationsList.currentItem.contentsToExpandedView();
                }

                onGotoNextAnnotation: {
                    annotationsList.currentIndex = annotationsList.currentIndex + 1;
                    annotationsList.currentItem.contentsToExpandedView();
                }

                onCloseView: {
                    mainContinuousView.closeInlineAnnotation();
                }

                onOpenExternalViewer: {
                    annotations.openPageArgs('ShowExtendedAnnotation', {identifier: identifier});
                }

                onOpenTitleEditor: {
                    annotations.pushButtonsModel();
                    annotations.buttonsModel.append({icon: 'floppy-35952', object: expandedAnnotation, method: 'saveEditorContents'});
                }

                onOpenDescriptionEditor: {
                    annotations.pushButtonsModel();
                    annotations.buttonsModel.append({icon: 'floppy-35952', object: expandedAnnotation, method: 'saveEditorContents'});
                }

                onOpenLabelsEditor: {
                    annotations.pushButtonsModel();
                    annotations.buttonsModel.append({icon: 'floppy-35952', object: expandedAnnotation, method: 'saveEditorContents'});
                }

                onOpenPeriodEditor: {
                    annotations.pushButtonsModel();
                    annotations.buttonsModel.append({icon: 'floppy-35952', object: expandedAnnotation, method: 'saveEditorContents'});
                }

                onOpenStateEditor: {
                    annotations.pushButtonsModel();
                    annotations.buttonsModel.append({icon: 'floppy-35952', object: expandedAnnotation, method: 'saveEditorContents'});
                }

                onCloseEditor: {
                    annotations.popButtonsModel();
                }

                onOpenRubricGroupAssessment: {
                    annotations.openPageArgs('RubricGroupAssessment',{assessment: assessment});
                }
            }
        }
        Common.SuperposedButton {
            id: addButton
            anchors {
                bottom: parent.bottom
                right: parent.right
            }
            size: units.fingerUnit * 2
            imageSource: 'plus-24844'
            onClicked: annotations.openMenu(units.fingerUnit * 4, addImmediateAnnotationMenu, {labels: ''})
        }

        function copyAnnotationDescription() {
            clipboard.copia(expandedAnnotation.descText);
        }

        function openRubricAssessmentMenu() {
            console.log('open menu')
            annotations.openMenu(units.fingerUnit * 2, addRubricMenu, {})
        }

        function closeInlineAnnotation() {
            mainContinuousView.expand(false);
        }

        Component {
            id: addRubricMenu

            Rectangle {
                id: addRubricMenuRect

                property int requiredHeight: childrenRect.height
                property var options
                signal closeMenu()

                onOptionsChanged: {
                    console.log('opcions 2');
                    console.log(options);
                }

                Models.IndividualsModel {
                    id: groupsModel

                    fieldNames: ['group']

                    sort: 'id DESC'
                }

                Models.RubricsModel {
                    id: rubricsModel

                    Component.onCompleted: select();
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
                                            expandedAnnotation.newRubricAssessment(model.title, model.desc, model.id, singleRubricXGroup.group)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Component.onCompleted: {
                    console.log('opcions 1');
                    console.log(options);
                    groupsModel.selectUnique('group');
                    console.log('COUNT', groupsModel.count)
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
                            var labels = "";
                            console.log('typeof', typeof flowRepeater.model);
                            if (typeof flowRepeater.model == 'string')
                                labels = flowRepeater.model.trim();
                            else
                                labels = flowRepeater.model.join(' ').trim();
                            var newObj = {
                                labels: labels,
                                start: date,
                                end: date
                            }

                            if (res != null) {
                                newObj['title'] = res[1].trim();
                                newObj['desc'] = res[2];
                                if (annotationsModel.insertObject(newObj)) {
                                    annotationsModel.selectAnnotations('');
                                    menuRect.closeMenu();
                                }
                            } else {
                                newObj['title'] = newAnnotationEditor.content;
                                newObj['desc'] = '';
                                if (annotationsModel.insertObject(newObj)) {
                                    annotationsModel.selectAnnotations('');
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


    Models.ExtendedAnnotations {
        id: annotationsModel

        sort: 'blockDate ASC, start ASC, end ASC, title ASC'
        filters: ['(start >= ?) OR (start IS NULL)', '(start <= ?) OR (start IS NULL)', "title != ''"]
        searchFields: ['title','desc','labels']
        groupBy: 'title'

        function setupPeriod() {
            annotationsModel.bindValues = [periodStart.toYYYYMMDDFormat(), periodEnd.toYYYYMMDDFormat()];
            annotationsModel.searchString = annotations.searchString;
            selectAnnotations('');
            firstAnnotation = annotationsModel.getObjectInRow(0)['title'];
        }

        Component.onCompleted: {
            setupPeriod();
        }
    }

    Models.ExtendedAnnotations {
        id: beforeAnnotationsModel

        sort: annotationsModel.sort
        filters: ['start < ?']
        searchFields: ['title','desc','labels']
        searchString: annotationsModel.searchString

        function setupFilter() {
            beforeAnnotationsModel.bindValues = [periodStart.toYYYYMMDDFormat()];
            select();
        }

        Component.onCompleted: {
            setupFilter();
        }
    }

    Models.ExtendedAnnotations {
        id: afterAnnotationsModel

        sort: annotationsModel.sort
        filters: ['start > ?']
        searchFields: ['title','desc','labels']
        searchString: annotationsModel.searchString

        function setupFilter() {
            afterAnnotationsModel.bindValues = [periodEnd.toYYYYMMDDFormat()];
            select();
        }

        Component.onCompleted: {
            setupFilter();
        }
    }

    QClipboard {
        id: clipboard
    }

    function newAnnotation(title, start, end, state) {
        annotationsModel.insertObject({title: title, start: start, end: end, state: state});
        annotationsModel.setupPeriod();
    }

    Component.onCompleted: {
        periodStart.setDate(periodStart.getDate() - 7);
        periodEnd.setDate(periodEnd.getDate() + 30);

        annotationsModel.setupPeriod();
    }
}

