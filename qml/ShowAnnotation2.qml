import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import ClipboardAdapter 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors
import 'qrc:///models' as Models

BasicPage {
    id: annotationView

    pageTitle: qsTr('Anotació')

    signal openExternalViewer(string identifier)

    property string identifier: ''
    property string descText: ''
    property string labels: ''
    property string periodStart: ''
    property string periodEnd: ''
    property string stateValue: ''


    Common.UseUnits {
        id: units
    }

    Models.ExtendedAnnotations {
        id: annotationsModel

        Component.onCompleted: {
            select();
            if (identifier == "") {
                if (count>0)
                    identifier = getObjectInRow(0)['title'];
            }
        }
    }

    Models.RubricsAssessmentModel {
        id: rubricsAssessmentModel
        filters: ["annotation=?"]
    }

//    color: 'yellow'

    mainPage: Item {
        id: mainItem

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: units.nailUnit
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: units.fingerUnit
                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: units.readUnit
                    text: annotationView.identifier
                    elide: Text.ElideRight
                }
            }

            Flickable {
                id: flickableText
                Layout.fillHeight: true
                Layout.fillWidth: true
                contentHeight: groupAnnotationItem.height
                contentWidth: groupAnnotationItem.width
                clip: true

                visible: flickableText.enabled
                enabled: !editorArea.enabled

                Item {
                    id: groupAnnotationItem

                    property int interspacing: units.nailUnit
                    width: flickableText.width
                    height: Math.max(headerData.height + titleRect.height + contentText.requiredHeight + 2 * groupAnnotationItem.interspacing, flickableText.height)

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: groupAnnotationItem.interspacing

                        Rectangle {
                            id: headerData
                            Layout.preferredHeight: Math.max(startText.height, endText.height, labelsText.height, stateItem.height, units.fingerUnit) + 2 * units.nailUnit
                            Layout.fillWidth: true
                            border.color: 'black'

                            MouseArea {
                                anchors.fill: parent
                                onClicked: annotationView.openExternalViewer(identifier)
                            }
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: units.nailUnit
                                spacing: units.nailUnit
                                Text {
                                    id: startText
                                    Layout.preferredHeight: contentHeight
                                    Layout.preferredWidth: parent.width / 3
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    font.pixelSize: units.readUnit
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: editorArea.changeEditor('periodEditor', {start: annotationView.periodStart, end: annotationView.periodEnd})
                                    }
                                }
                                Text {
                                    id: endText
                                    Layout.preferredHeight: contentHeight
                                    Layout.preferredWidth: parent.width / 3
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    font.pixelSize: units.readUnit
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: editorArea.changeEditor('periodEditor', {start: annotationView.periodStart, end: annotationView.periodEnd})
                                    }
                                }
                                Text {
                                    id: labelsText
                                    Layout.preferredHeight: contentHeight
                                    Layout.fillWidth: true
                                    color: 'green'
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    font.pixelSize: units.readUnit
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: editorArea.changeEditor('labelsEditor', annotationView.labels)
                                    }
                                }
                                Rectangle {
                                    id: stateItem
                                    Layout.preferredWidth: units.fingerUnit * 2
                                    Layout.preferredHeight: stateText.contentHeight + 2 * units.nailUnit

                                    Rectangle {
                                        anchors {
                                            bottom: parent.bottom
                                            left: parent.left
                                            right: parent.right
                                        }
                                        color: 'orange'
                                        height: {
                                            var value = parseInt(stateValue);
                                            if ((value>0) && (value<=10)) {
                                                return stateItem.height * value / 10;
                                            } else {
                                                if (value<0)
                                                    return stateItem.height;
                                                else
                                                    return 0;
                                            }
                                        }
                                    }

                                    Text {
                                        id: stateText
                                        anchors.fill: parent
                                        anchors.margins: units.nailUnit
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                        font.pixelSize: units.readUnit
                                        text: {
                                            switch(stateValue) {
                                            case '-1':
                                                return qsTr('Finalitzat');
                                            case '1':
                                                return qsTr('10%');
                                            case '2':
                                                return qsTr('20%');
                                            case '3':
                                                return qsTr('30%');
                                            case '4':
                                                return qsTr('40%');
                                            case '5':
                                                return qsTr('50%');
                                            case '6':
                                                return qsTr('60%');
                                            case '7':
                                                return qsTr('70%');
                                            case '8':
                                                return qsTr('80%');
                                            case '9':
                                                return qsTr('90%');
                                            case '10':
                                                return qsTr('100%');
                                            default:
                                                return qsTr('Actiu');
                                            }
                                        }
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: editorArea.changeEditor('stateEditor', annotationView.identifier)
                                    }
                                }

                            }
                        }

                        Item {
                            id: titleRect

                            Layout.preferredHeight: titleText.height + 2
                            Layout.fillWidth: true

                            Text {
                                id: titleText
                                anchors {
                                    top: parent.top
                                    left: parent.left
                                    right: parent.right
                                }

                                height: Math.max(contentHeight, units.fingerUnit)
                                font.pixelSize: units.glanceUnit
                                font.bold: true
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                Common.ImageButton {
                                    anchors {
                                        top: parent.top
                                        right: parent.right
                                    }
                                    size: units.fingerUnit
                                    image: 'edit-153612'
                                    onClicked: editorArea.changeEditor('titleEditor', annotationView.identifier)
                                }
                            }
                            Rectangle {
                                anchors {
                                    top: titleText.bottom
                                    left: parent.left
                                    right: parent.right
                                }
                                height: 2
                                color: 'black'
                            }

                        }

                        Text {
                            id: contentText
                            property int requiredHeight: Math.max(contentHeight, units.fingerUnit)

                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            onLinkActivated: openExternalViewer(link)
                            Common.ImageButton {
                                anchors {
                                    top: parent.top
                                    right: parent.right
                                }

                                size: units.fingerUnit
                                image: 'edit-153612'
                                onClicked: editorArea.changeEditor('descEditor', annotationView.descText)
                            }
                        }
                    }
                }

            }
            Item {
                id: rubricsArea

                Layout.fillWidth: true
                Layout.preferredHeight: (rubricsAssessmentModel.count>0)?units.fingerUnit * 2:0

                ListView {
                    id: rubricsAnnotationInfo

                    anchors.fill: parent
                    orientation: ListView.Horizontal

                    model: rubricsAssessmentModel
                    spacing: units.nailUnit
                    delegate: Common.BoxedText {
                        height: rubricsAnnotationInfo.height
                        width: units.fingerUnit * 6
                        text: model.title + " (" + model.group + ")"
                        margins: units.nailUnit
                        MouseArea {
                            anchors.fill: parent
                            onClicked: annotationView.openPageArgs('RubricGroupAssessment', {assessment: model.id})
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: units.fingerUnit * 3 + units.nailUnit * 2
                GridLayout {
                    anchors.fill: parent
                    columns: 2
                    columnSpacing: units.nailUnit
                    rowSpacing: columnSpacing

                    Rectangle {
                        id: beforeAnnotationRect
                        Layout.preferredHeight: units.fingerUnit
                        Layout.fillWidth: true

                        property string beforeAnnotation: ''
                        Text {
                            id: beforeAnnotationText
                            anchors.fill: parent
                            text: qsTr('AZ << ') + beforeAnnotationRect.beforeAnnotation
                            MouseArea {
                                anchors.fill: parent
                                onClicked: identifier = beforeAnnotationRect.beforeAnnotation
                            }
                        }
                    }
                    Rectangle {
                        id: afterAnnotationRect
                        Layout.preferredHeight: units.fingerUnit
                        Layout.fillWidth: true
                        property string afterAnnotation: ''
                        Text {
                            id: afterAnnotationText
                            anchors.fill: parent
                            text: qsTr('AZ >> ') + afterAnnotationRect.afterAnnotation
                            MouseArea {
                                anchors.fill: parent
                                onClicked: identifier = afterAnnotationRect.afterAnnotation
                            }
                        }
                    }

                    Rectangle {
                        id: beforeAnnotationStartRect
                        Layout.preferredHeight: units.fingerUnit
                        Layout.fillWidth: true
                        property string beforeAnnotationStart: ''
                        Text {
                            anchors.fill: parent
                            text: qsTr('Inici << ') + beforeAnnotationStartRect.beforeAnnotationStart
                            MouseArea {
                                anchors.fill: parent
                                onClicked: identifier = beforeAnnotationStartRect.beforeAnnotationStart
                            }
                        }
                    }
                    Rectangle {
                        id: afterAnnotationStartRect
                        Layout.preferredHeight: units.fingerUnit
                        Layout.fillWidth: true
                        property string afterAnnotationStart: ''
                        Text {
                            anchors.fill: parent
                            text: qsTr('Inici >> ') + afterAnnotationStartRect.afterAnnotationStart
                            MouseArea {
                                anchors.fill: parent
                                onClicked: identifier = afterAnnotationStartRect.afterAnnotationStart
                            }
                        }
                    }
                    Rectangle {
                        id: beforeAnnotationEndRect
                        Layout.preferredHeight: units.fingerUnit
                        Layout.fillWidth: true
                        property string beforeAnnotationEnd: ''
                        Text {
                            anchors.fill: parent
                            text: qsTr('Final << ') + beforeAnnotationEndRect.beforeAnnotationEnd
                            MouseArea {
                                anchors.fill: parent
                                onClicked: identifier = beforeAnnotationEndRect.beforeAnnotationEnd
                            }
                        }
                    }
                    Rectangle {
                        id: afterAnnotationEndRect
                        Layout.preferredHeight: units.fingerUnit
                        Layout.fillWidth: true
                        property string afterAnnotationEnd: ''
                        Text {
                            anchors.fill: parent
                            text: qsTr('Final >> ') + afterAnnotationEndRect.afterAnnotationEnd
                            MouseArea {
                                anchors.fill: parent
                                onClicked: identifier = afterAnnotationEndRect.afterAnnotationEnd
                            }
                        }
                    }
                }
                Models.ExtendedAnnotations {
                    id: afterAndBeforeAnnotationsModel
                    filters: ["title != ''"]
                }
            }
        }

        Rectangle {
            id: editorArea
            anchors.fill: parent
            anchors.margins: units.nailUnit
            border.color: 'black'
            visible: editorArea.enabled

            property var newContent: ''

            states: [
                State {
                    name: 'viewer'
                    PropertyChanges {
                        target: editorArea
                        enabled: false
                    }
                },
                State {
                    name: 'titleEditor'
                    PropertyChanges {
                        target: editorLoader
                        sourceComponent: titleEditorComponent
                    }
                },
                State {
                    name: 'descEditor'
                    PropertyChanges {
                        target: editorLoader
                        sourceComponent: descEditorComponent
                    }
                },
                State {
                    name: 'periodEditor'
                    PropertyChanges {
                        target: editorLoader
                        sourceComponent: periodEditorComponent
                    }
                },
                State {
                    name: 'labelsEditor'
                    PropertyChanges {
                        target: editorLoader
                        sourceComponent: labelsEditorComponent
                    }
                },
                State {
                    name: 'stateEditor'
                    PropertyChanges {
                        target: editorLoader
                        sourceComponent: stateEditorComponent
                    }
                }

            ]
            state: 'viewer'

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                spacing: units.nailUnit

                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: contentHeight
                    font.pixelSize: units.readUnit
                    font.bold: true
                    text: qsTr('Editor')
                }
                Loader {
                    id: editorLoader

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    onLoaded: {
                        item.content = editorArea.newContent;
                        item.setChanges(false);
                    }
                }
            }

            function changeEditor(newEditor, newContent) {
                if (editorArea.state == 'viewer') {
                    editorArea.newContent = newContent;
                    editorArea.state = newEditor;
                    editorArea.enabled = true;

                    annotationView.pushButtonsModel();
                    annotationView.buttonsModel.append({icon: 'floppy-35952', object: editorArea, method: 'saveEditorContents'});
                    annotationView.buttonsModel.append({icon: 'road-sign-147409', object: editorArea, method: 'discardEditorContents'})
                }
            }

            function getEditedContent() {
                return editorLoader.item.content;
            }

            function saveEditorContents() {
                if (editorLoader.item.changes) {
                    switch(editorArea.state) {
                    case 'titleEditor':
                        var newIdentifier = editorArea.getEditedContent();
                        annotationsModel.updateObject(annotationView.identifier, {title: newIdentifier});
                        annotationView.identifier = newIdentifier;
                        break;
                    case 'descEditor':
                        annotationsModel.updateObject(annotationView.identifier, {desc: editorArea.getEditedContent()});
                        break;
                    case 'periodEditor':
                        var period = editorArea.getEditedContent();
                        annotationsModel.updateObject(annotationView.identifier, {start: period.start, end: period.end});
                        break;
                    case 'labelsEditor':
                        annotationsModel.updateObject(annotationView.identifier, {labels: editorArea.getEditedContent()});
                        break;
                    case 'stateEditor':
                        annotationsModel.updateObject(annotationView.identifier, {state: editorArea.getEditedContent()});
                        break;
                    }
                    if (editorArea.state !== 'viewer') {
                        editorArea.state = 'viewer';
                        annotationView.popButtonsModel();
                    }
                    mainItem.getText();
                }
            }

            function discardEditorContents() {
                if (editorArea.state !== 'viewer') {
                    editorArea.state = 'viewer';
                    annotationView.popButtonsModel();
                }
            }
        }

        Connections {
            target: annotationView
            onIdentifierChanged: {
                console.log('new identifier', identifier)
                mainItem.getText();
            }
        }

        function getText() {
            console.log('gt text');
            if (identifier != '') {
                annotationsModel.filters = ["title = ?"];
                annotationsModel.bindValues = [identifier];

            } else {
                annotationsModel.filters = ["title != ''"];
                annotationsModel.bindValues = [];
            }

            annotationsModel.select();
            if (annotationsModel.count>0) {
                var obj = annotationsModel.getObjectInRow(0);
                identifier = obj['title'];
                startText.text = qsTr('Inici: ') + obj['start'];
                endText.text = qsTr('Final: ') + obj['end'];
                labelsText.text = '# ' + obj['labels'];
                titleText.text = identifier;
                annotationView.labels = obj['labels'];
                periodStart = obj['start'];
                periodEnd = obj['end'];
                descText = obj['desc'];
                contentText.text = parser.toHtml(obj['desc']);
                stateValue = obj['state'];
            }

            // Get rubrics
            rubricsAssessmentModel.bindValues = [identifier];
            rubricsAssessmentModel.select();

            // Look for the previous and next annotations in TITLE
            afterAndBeforeAnnotationsModel.sort = 'title ASC';
            afterAndBeforeAnnotationsModel.select();
            for (var i=0; i<afterAndBeforeAnnotationsModel.count; i++) {
                var obj = afterAndBeforeAnnotationsModel.getObjectInRow(i);
                if (obj['title'] == identifier) {
                    console.log('index', i);
                    if (i>0) {
                        var beforeObj = afterAndBeforeAnnotationsModel.getObjectInRow(i-1);
                        beforeAnnotationRect.beforeAnnotation = beforeObj['title'];
                    }
                    if (i<afterAndBeforeAnnotationsModel.count-1) {
                        var afterObj = afterAndBeforeAnnotationsModel.getObjectInRow(i+1);
                        afterAnnotationRect.afterAnnotation = afterObj['title'];
                    }
                    break;
                }
            }

            // Look for the previous and next annotations in START
            afterAndBeforeAnnotationsModel.sort = 'start ASC, end ASC, title ASC';
            afterAndBeforeAnnotationsModel.select();
            for (var i=0; i<afterAndBeforeAnnotationsModel.count; i++) {
                var obj = afterAndBeforeAnnotationsModel.getObjectInRow(i);
                if (obj['title'] == identifier) {
                    if (i>0) {
                        var beforeObj = afterAndBeforeAnnotationsModel.getObjectInRow(i-1);
                        beforeAnnotationStartRect.beforeAnnotationStart = beforeObj['title'];
                    }
                    if (i<afterAndBeforeAnnotationsModel.count-1) {
                        var afterObj = afterAndBeforeAnnotationsModel.getObjectInRow(i+1);
                        afterAnnotationStartRect.afterAnnotationStart = afterObj['title'];
                    }
                    break;
                }
            }

            // Look for the previous and next annotations in END
            afterAndBeforeAnnotationsModel.sort = 'end ASC, start ASC, title ASC';
            afterAndBeforeAnnotationsModel.select();
            for (var i=0; i<afterAndBeforeAnnotationsModel.count; i++) {
                var obj = afterAndBeforeAnnotationsModel.getObjectInRow(i);
                if (obj['title'] == identifier) {
                    if (i>0) {
                        var beforeObj = afterAndBeforeAnnotationsModel.getObjectInRow(i-1);
                        beforeAnnotationEndRect.beforeAnnotationEnd = beforeObj['title'];
                    }
                    if (i<afterAndBeforeAnnotationsModel.count-1) {
                        var afterObj = afterAndBeforeAnnotationsModel.getObjectInRow(i+1);
                        afterAnnotationEndRect.afterAnnotationEnd = afterObj['title'];
                    }
                    break;
                }
            }

        }

        function copyAnnotationDescription() {
            clipboard.copia(annotationView.descText);
        }

        function openRubricAssessmentMenu() {
            annotationView.openMenu(units.fingerUnit * 2, addRubricMenu, {})
        }

        QClipboard {
            id: clipboard
        }

        Component.onCompleted: {
            getText();
            annotationView.buttonsModel.append({icon: 'copy-97584', object: mainItem, method: 'copyAnnotationDescription'});
            annotationView.buttonsModel.append({icon: 'questionnaire-158862', object: mainItem, method: 'openRubricAssessmentMenu'});
        }
    }

    Component {
        id: titleEditorComponent

        Common.AbstractEditor {
            id: generalTitleEditor
            property alias content: titleEditor.content

            onChangesChanged: {
                if (!generalTitleEditor.changes) {
                    titleEditor.setChanges(false);
                }
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: units.nailUnit

                Editors.TextLineEditor {
                    id: titleEditor
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit * 2

                    onChangesChanged: {
                        if (titleEditor.changes) {
                            generalTitleEditor.setChanges(true);
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    text: qsTr('Esborrar anotació')
                    onClicked: {}
                }
            }
        }

    }

    Component {
        id: descEditorComponent

        Editors.TextAreaEditor3 {

        }
    }

    Component {
        id: periodEditorComponent

        Common.AbstractEditor {
            id: periodEditorItem

            property var content

            onContentChanged: {
                var re = /([0-9]{1,4}-[0-9]{1,2}-[0-9]{1,2})|([0-9]{1,2}\:[0-9]{1,2}(?:\:[0-9]{1,2})?)/g;

                var start = new Date();
                var parts = content.start.match(re);
                if ((parts == null) || (parts.length == 0)) {
                    startDateCheckbox.checked = false;
                } else {
                    startDateCheckbox.checked = true;
                    start.fromYYYYMMDDFormat(parts[0]);
                    if (parts.length == 1) {
                        startTimeCheckbox.checked = false;
                    } else {
                        startTimeCheckbox.checked = true;
                        start.fromHHMMFormat(parts[1]);
                    }
                }
                startDate.selectedDate = start;
                startTimePicker.setDateTime(start);

                var end = new Date();
                var parts = content.end.match(re);
                if ((parts == null) || (parts.length == 0)) {
                    endDateCheckbox.checked = false;
                } else {
                    endDateCheckbox.checked = true;
                    end.fromYYYYMMDDFormat(parts[0]);
                    if (parts.length == 1) {
                        endTimeCheckbox.checked = false;
                    } else {
                        endTimeCheckbox.checked = true;
                        end.fromHHMMFormat(parts[1]);
                    }
                }
                endDate.selectedDate = end;
                endTimePicker.setDateTime(end);

                startReadableText.text = (startDateCheckbox.checked)?((start.toShortReadableDate()) + ((startTimeCheckbox.checked)?(qsTr(" a les ") + start.toTimeSpecificFormat()):'')):qsTr('No especificat');
                endReadableText.text = (endDateCheckbox.checked)?((end.toShortReadableDate()) + ((endTimeCheckbox.checked)?(qsTr(" a les ") + end.toTimeSpecificFormat()):'')):qsTr('No especificat');
            }

            GridLayout {
                anchors.fill: parent
                columns: 2
                columnSpacing: units.fingerUnit
                Text {
                    Layout.preferredHeight: units.fingerUnit
                    Layout.fillWidth: true
                    font.pixelSize: units.readUnit
                    font.bold: true
                    text: qsTr('Inici')
                }
                Text {
                    Layout.preferredHeight: units.fingerUnit
                    Layout.fillWidth: true
                    font.pixelSize: units.readUnit
                    font.bold: true
                    text: qsTr('Final')
                }
                Text {
                    id: startReadableText
                    Layout.preferredHeight: contentHeight
                    Layout.fillWidth: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.pixelSize: units.readUnit
                }

                Text {
                    id: endReadableText
                    Layout.preferredHeight: contentHeight
                    Layout.fillWidth: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.pixelSize: units.readUnit
                }

                CheckBox {
                    id: startDateCheckbox
                    text: qsTr('Especificar data')

                    onClicked: periodEditorItem.copyContentsToParentEditor()
                }

                CheckBox {
                    id: endDateCheckbox
                    text: qsTr('Especificar data')

                    onClicked: periodEditorItem.copyContentsToParentEditor()
                }

                Calendar {
                    id: startDate
                    Layout.fillWidth: true
                    Layout.preferredHeight: width

                    enabled: startDateCheckbox.checked

                    onClicked: periodEditorItem.copyContentsToParentEditor()
                }

                Calendar {
                    id: endDate

                    Layout.fillWidth: true
                    Layout.preferredHeight: width

                    enabled: endDateCheckbox.checked

                    onClicked: periodEditorItem.copyContentsToParentEditor()
                }

                CheckBox {
                    id: startTimeCheckbox
                    enabled: startDateCheckbox.checked
                    text: qsTr('Especificar hora')

                    onClicked: periodEditorItem.copyContentsToParentEditor()
                }

                CheckBox {
                    id: endTimeCheckbox
                    enabled: endDateCheckbox.checked
                    text: qsTr('Especificar hora')

                    onClicked: periodEditorItem.copyContentsToParentEditor()
                }

                Editors.TimePicker {
                    id: startTimePicker

                    Layout.fillWidth: true
                    Layout.preferredHeight: width

                    enabled: startTimeCheckbox.checked

                    onUpdatedByUser: periodEditorItem.copyContentsToParentEditor()
                }
                Editors.TimePicker {
                    id: endTimePicker

                    Layout.fillWidth: true
                    Layout.preferredHeight: width

                    enabled: endTimeCheckbox.checked

                    onUpdatedByUser: periodEditorItem.copyContentsToParentEditor()
                }
            }
            function copyContentsToParentEditor() {
                var start = "";
                if (startDateCheckbox.checked) {
                    start = startDate.selectedDate.toYYYYMMDDFormat();
                    if (startTimeCheckbox.checked) {
                        start +=  " " + startTimePicker.getTime().toHHMMFormat();
                    }
                }
                var end = "";
                if (endDateCheckbox.checked) {
                    end = endDate.selectedDate.toYYYYMMDDFormat();
                    if (endTimeCheckbox.checked) {
                        end += " " + endTimePicker.getTime().toHHMMFormat();
                    }
                }

                periodEditorItem.content = {start: start, end: end};
                periodEditorItem.setChanges(true);
            }
        }

    }

    Component {
        id: labelsEditorComponent

        Common.AbstractEditor {
            id: labelsEditor
            property string content

            ListView {
                id: labelsListItem

                anchors.fill: parent

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
                        content = content.replace(label,"").replace(/(^\s+)|(\s+$)/g, '').replace(/\s\s+/g, ' ');
                    }

                }
                footer: Item {
                    id: footerItem
                    height: childrenRect.height
                    width: labelsListItem.width

                    Models.ExtendedAnnotations {
                        id: labelsModel

                        // Incorporate this solution: http://stackoverflow.com/questions/24258878/how-to-split-comma-separated-value-in-sqlite

                        Component.onCompleted: {
                            select();
                            labelsRepeater.model = labelsModel.getUniqueLabels();
                        }

                        function getUniqueLabels() {
                            var labelsArray = [];
                            for (var i=0; i<count; i++) {
                                var labelsString = getObjectInRow(i)['labels'].toLowerCase();
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
                            return uniqueLabelsArray;
                        }
                    }

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
                                id: labelsRepeater

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
                                            content = content + ((content == '')?'':' ') + modelData;
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
                            if (content === '')
                                content = newLabel;
                            else
                                content = content + " " + newLabel;
                        }
                        newLabelField.text = '';
                    }
                }

            }
            onContentChanged: {
                labelsEditor.setChanges(true);
                var labelsArray = content.split(' ');
                labelsListItem.model = labelsArray;
            }

        }
    }

    Component {
        id: stateEditorComponent

        Common.AbstractEditor {
            id: eventDoneList

            property string content

            Row {
                anchors.fill: parent

                Repeater {
                    model: 12
                    Common.BoxedText {
                        id: boxedText

                        states: [
                            State {
                                name: 'completed'
                                PropertyChanges {
                                    target: boxedText
                                    text: qsTr('Finalitzat')
                                }
                            },
                            State {
                                name: 'active'
                                PropertyChanges {
                                    target: boxedText
                                    text: qsTr('Actiu')
                                }
                            },
                            State {
                                name: 'percentage'
                                PropertyChanges {
                                    target: boxedText
                                    text: ((model.index - 1) * 10) + "%"
                                }
                            }
                        ]
                        state: {
                            switch(model.index-1) {
                            case -1:
                                return 'completed';
                            case 0:
                                return 'active';
                            default:
                                return 'percentage';
                            }
                        }

                        width: eventDoneList.width / 12
                        height: eventDoneList.height
                        color: (content == model.index-1)?'yellow':'transparent'

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                eventDoneList.content = model.index-1;
                                eventDoneList.setChanges(true);
                            }
                        }
                    }
                }
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


    function saveDescriptionContent() {
        saveEditorContents();
    }


    function newRubricAssessment(title, desc, rubric, group) {
        var obj = {};
        obj = {
            title: title,
            desc: desc,
            rubric: rubric,
            group: group,
            annotation: annotationView.identifier
        };

        rubricsAssessmentModel.insertObject(obj);
        rubricsAssessmentModel.select();
    }

    MarkDownParser {
        id: parser
    }
}

