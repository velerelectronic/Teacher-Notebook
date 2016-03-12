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

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true

                ListView {
                    id: annotationsList
                    clip: true
                    anchors {
                        top: parent.top
                        left: parent.left
                        bottom: parent.bottom
                    }
                    width: (mainContinuousView.expanded)?(units.fingerUnit * 3):parent.width

                    model: annotationsModel

                    header: Item {
                        width: annotationsList.width
                        height: units.fingerUnit * 2
                        Text {
                            anchors.fill: parent
                            font.pixelSize: units.readUnit
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: headerText
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                periodStart.setDate(periodStart.getDate() - 7);
                                annotationsModel.setupPeriod();
                                beforeAnnotationsModel.setupFilter();

                                headerText = qsTr('A partir de ') + periodStart.toLongDate() + ".\n";

                                if (beforeAnnotationsModel.count == 0)
                                    headerText += qsTr('No hi ha anotacions més enrere.');
                                else
                                    headerText += qsTr("Abans hi ha ") + beforeAnnotationsModel.count + qsTr(" anotacions.");
                            }
                        }
                    }

                    footer: Item {
                        width: annotationsList.width
                        height: units.fingerUnit * 2
                        Text {
                            anchors.fill: parent
                            font.pixelSize: units.readUnit
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: footerText
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var offset = annotationsList.contentY;

                                periodEnd.setDate(periodEnd.getDate() + 7);
                                annotationsModel.setupPeriod();
                                annotationsList.contentY = offset;
                                afterAnnotationsModel.setupFilter();

                                footerText = qsTr('Fins a ') + periodEnd.toLongDate() + ".\n";

                                if (afterAnnotationsModel.count == 0)
                                    footerText += qsTr('No hi ha anotacions més envant.');
                                else
                                    footerText += qsTr("Després hi ha ") + afterAnnotationsModel.count + qsTr(" anotacions.");
                            }
                        }
                    }

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
                                    return qsTr("El darrer any");
                                case -2:
                                    return qsTr("El darrer mes");
                                case -1:
                                    return qsTr("La darrera setmana");
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

                    delegate: Rectangle {
                        id: singleAnnotationRectangle

                        z: 1
                        states: [
                            State {
                                name: 'hidden'
                                when: (!singleAnnotationRectangle.isCurrentItem) && (model.state <= -1)
                                PropertyChanges {
                                    target: singleAnnotationRectangle
                                    height: units.fingerUnit / 2
                                    color: 'gray'
                                }
                                PropertyChanges {
                                    target: annotationRowLayout
                                    visible: false
                                }
                            },
                            State {
                                name: 'minimized'
                                when: (!singleAnnotationRectangle.isCurrentItem) && (model.state > -1)
                                PropertyChanges {
                                    target: singleAnnotationRectangle
                                    height: units.fingerUnit * 2
                                }
                            },
                            State {
                                name: 'lastSelected'
                                extend: 'minimized'
                                when: (singleAnnotationRectangle.isCurrentItem) && (!mainContinuousView.expanded)
                            },

                            State {
                                name: 'expanded'
                                extend: 'minimized'
                                when: (singleAnnotationRectangle.isCurrentItem) && (mainContinuousView.expanded)
                                PropertyChanges {
                                    target: singleAnnotationRectangle
                                }
                            }

                        ]
                        transitions: [
                            Transition {
                                from: 'hidden'
                                to: 'minimized'
                                reversible: true
                                PropertyAnimation {
                                    target: singleAnnotationRectangle
                                    property: 'height'
                                    duration: 500
                                }
                            }
                        ]
                        border.color: 'black'
                        color: (ListView.isCurrentItem)?'yellow':((model.state > -1)?'white':'#BBBBBB')
                        width: annotationsList.width

                        property string desc: model.desc
                        property string htmlContents: ''
                        property bool isCurrentItem: ListView.isCurrentItem

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                switch(singleAnnotationRectangle.state) {
                                case 'hidden':
                                    singleAnnotationRectangle.state = 'minimized';
                                    break;
                                case 'lastSelected':
                                    singleAnnotationRectangle.contentsToExpandedView();
                                    break;
                                case 'minimized':
                                    annotationsList.currentIndex = model.index;
                                    singleAnnotationRectangle.contentsToExpandedView();
                                    break;
                                }
                            }
                        }
                        RowLayout {
                            id: annotationRowLayout
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
                            spacing: units.nailUnit

                            clip: true

                            Text {
                                id: contentsField
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: "<b>" + model.title + "</b> <font color=\"green\">#" + model.labels + "</font><br>" + ((singleAnnotationRectangle.state == 'expanded')?singleAnnotationRectangle.htmlContents:singleAnnotationRectangle.desc)
                                clip: true
                            }
                            Text {
                                Layout.fillHeight: true
                                Layout.preferredWidth: (!mainContinuousView.expanded)?(units.fingerUnit * 3):0
                                text: model.start + "<br>" + model.end
                                clip: true
                            }
                        }

                        function contentsToExpandedView() {
                            mainContinuousView.expand(true);
                            expandedAnnotation.getText(model.title, model.desc, model.start, model.end, model.labels, model.start, model.end, model.state);
                        }
                    }
                }

                Rectangle {
                    anchors {
                        top: parent.top
                        left: annotationsList.right
                        right: parent.right
                        bottom: parent.bottom
                    }
                    clip: true
                    radius: units.nailUnit
                    border.color: 'black'
                    color: 'white'

                    InlineExpandedAnnotation {
                        id: expandedAnnotation
                        anchors {
                            top: parent.top
                            left: parent.left
                            bottom: parent.bottom
                            margins: units.fingerUnit
                        }
                        width: parent.width - 2 * anchors.margins

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

        function closeInlineAnnotation() {
            mainContinuousView.expand(false);
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

    Models.ExtendedAnnotations {
        id: annotationsModel

        sort: 'blockDate ASC, start ASC, end ASC, title ASC'
        filters: ['(start >= ?) OR (start IS NULL)', '(start <= ?) OR (start IS NULL)']
        searchFields: ['title','desc','labels']
        groupBy: 'title'

        function setupPeriod() {
            annotationsModel.bindValues = [periodStart.toYYYYMMDDFormat(), periodEnd.toYYYYMMDDFormat()];
            annotationsModel.searchString = annotations.searchString;
            selectAnnotations('');
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

