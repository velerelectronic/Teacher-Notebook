import QtQuick 2.5
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors
import 'qrc:///models' as Models

BasicPage {
    id: combinedTable

    property string pageTitle: qsTr("Quadre d'anotacions");
    signal openRubricGroupAssessment(int assessment, int rubric, var rubricsModel, var rubricsAssessmentModel)

    property SqlTableModel annotationsModel: newAnnotationsModel
    property string sortLabels

    onSortLabelsChanged: {
        annotationsModel.selectAnnotations(sortLabels);
        rebuildTable();
    }

    Models.ExtendedAnnotations {
        id: newAnnotationsModel
        searchFields: ['title', 'desc', 'project']
    }

    onAnnotationsModelChanged: rebuildTable()

    Common.UseUnits {
        id: units
    }

    ColumnLayout {
        anchors.fill: parent

        Common.BoxedText {
            Layout.preferredHeight: units.fingerUnit
            Layout.fillWidth: true
            text: qsTr('Resultats de la combinació')
        }

        ListView {
            id: rowsListView

            Layout.fillHeight: true
            Layout.fillWidth: true

            clip: true
            model: tableRowsModel

            property var extraHeaderData
            property int rowNumberWidth: units.fingerUnit * 1
            property int annotationFieldWidth: rowsListView.width / 8
            property int periodFieldWidth: rowsListView.width / 8
            property int assessmentFieldWidth: units.fingerUnit * 2

            headerPositioning: ListView.OverlayHeader
            header: Rectangle {
                z: 2
                width: rowsListView.width
                height: units.fingerUnit * 2

                border.color: 'black'
                color: '#FFDDDD'

                RowLayout {
                    id: headerRowLayout

                    anchors.fill: parent
                    spacing: 0
                    Common.BoxedText {
                        Layout.fillHeight: true
                        Layout.preferredWidth: rowsListView.rowNumberWidth
                        color: 'transparent'

                        boldFont: true
                        margins: units.nailUnit
                        text: qsTr('Fila')
                    }
                    Common.BoxedText {
                        Layout.fillHeight: true
                        Layout.preferredWidth: rowsListView.annotationFieldWidth
                        color: 'transparent'

                        boldFont: true
                        margins: units.nailUnit
                        text: qsTr('Anotació')
                    }
                    Common.BoxedText {
                        Layout.fillHeight: true
                        Layout.preferredWidth: rowsListView.periodFieldWidth
                        color: 'transparent'

                        boldFont: true
                        margins: units.nailUnit
                        text: qsTr('Període')
                    }
                    Repeater {
                        model: rowsListView.extraHeaderData
                        Common.BoxedText {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: 'transparent'

                            boldFont: true
                            margins: units.nailUnit
                            text: modelData
                        }
                    }
                    Common.BoxedText {
                        Layout.fillHeight: true
                        Layout.preferredWidth: rowsListView.assessmentFieldWidth
                        color: 'transparent'

                        boldFont: true
                        margins: units.nailUnit
                        text: qsTr('Avaluació')
                    }
                }
            }

            delegate: Rectangle {
                id: singleContentsRow

                z: 1
                width: rowsListView.width

                border.color: 'black'
                property string fields: model.fields
                property var fieldsModel
                property string annotation: model.annotation

                onFieldsChanged: {
                    repeater.model = JSON.parse(singleContentsRow.fields);
                }

                Models.RubricsAssessmentModel {
                    id: rubricsAssessmentModel
                    filters: ["annotation=?"]
                    bindValues: [model.annotation]
                }

                onAnnotationChanged: {
                    rubricsAssessmentModel.bindValues = [singleContentsRow.annotation];
                    rubricsAssessmentModel.select();
                }

                RowLayout {
                    id: singleContentsRowLayout

                    anchors.fill: parent

                    property int childrenLength: children.length
                    onChildrenLengthChanged: singleContentsRowLayout.recalculateMaxHeight()

                    spacing: 0

                    function recalculateMaxHeight() {
                        var max = units.fingerUnit * 2;
                        for (var i=0; i<singleContentsRowLayout.children.length; i++) {
                            if (singleContentsRowLayout.children[i].requiredHeight > max)
                                max = singleContentsRowLayout.children[i].requiredHeight;
                        }
                        singleContentsRow.height = max;
                    }

                    Common.BoxedText {
                        Layout.fillHeight: true
                        Layout.preferredWidth: rowsListView.rowNumberWidth
                        property int requiredHeight: contentHeight

                        margins: units.nailUnit
                        elide: Text.ElideNone
                        text: model.row

                        onContentHeightChanged: singleContentsRowLayout.recalculateMaxHeight()
                        onWidthChanged: singleContentsRowLayout.recalculateMaxHeight()
                    }
                    Common.BoxedText {
                        Layout.fillHeight: true
                        Layout.preferredWidth: rowsListView.annotationFieldWidth
                        property int requiredHeight: contentHeight

                        margins: units.nailUnit
                        elide: Text.ElideNone
                        text: model.annotation

                        onContentHeightChanged: singleContentsRowLayout.recalculateMaxHeight()
                        onWidthChanged: singleContentsRowLayout.recalculateMaxHeight()
                    }
                    Common.BoxedText {
                        Layout.fillHeight: true
                        Layout.preferredWidth: rowsListView.periodFieldWidth
                        property int requiredHeight: contentHeight

                        margins: units.nailUnit
                        elide: Text.ElideNone
                        text: {
                            var startSplit = model.start.trim().split(" ");
                            var endSplit = model.end.trim().split(" ");

                            var dateString = "";

                            if (model.start !== "") {
                                var start = new Date();
                                start = start.fromYYYYMMDDFormat(startSplit[0]);
                                dateString += qsTr("Des de ") + start.toShortReadableDate();

                                if (startSplit.length >= 2) {
                                    start = start.fromHHMMFormat(startSplit[1]);
                                    dateString += qsTr(" a les ") + start.toHHMMFormat();
                                }
                            }

                            if (model.end !== "") {
                                if (dateString !== "")
                                    dateString += "\n";

                                var end = new Date();
                                end = end.fromYYYYMMDDFormat(endSplit[0]);
                                dateString += qsTr("Fins a ") + end.toShortReadableDate();

                                if (endSplit.length >= 2) {
                                    end = end.fromHHMMFormat(endSplit[1]);
                                    dateString += qsTr(" a les ") + end.toHHMMFormat();
                                }
                            }
                            return dateString;
                        }

                        onContentHeightChanged: singleContentsRowLayout.recalculateMaxHeight()
                        onWidthChanged: singleContentsRowLayout.recalculateMaxHeight()
                    }
                    Repeater {
                        id: repeater

                        Common.BoxedText {
                            id: fieldText
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            property string contents: (typeof modelData !== 'undefined')?modelData:''
                            property int requiredHeight: contentHeight

                            margins: units.nailUnit
                            elide: Text.ElideNone
                            fontSize: units.readUnit * 2 / 3
                            text: fieldText.contents

                            onContentHeightChanged: singleContentsRowLayout.recalculateMaxHeight()
                            onWidthChanged: singleContentsRowLayout.recalculateMaxHeight()
                        }
                    }
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: rowsListView.assessmentFieldWidth
                        border.color: 'black'
                        property int requiredHeight: childrenRect.height + units.nailUnit * 2

                        ColumnLayout {
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                            }

                            anchors.margins: units.nailUnit
                            spacing: units.nailUnit

                            Repeater {
                                model: rubricsAssessmentModel
                                Common.BoxedText {
                                    Layout.fillWidth: true
                                    height: rowsListView.assessmentFieldWidth
                                    margins: units.nailUnit
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    fontSize: units.readUnit * 2 / 3
                                    text: model.title
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: openRubricGroupAssessment(model.id, model.rubric, rubricsModel, rubricsAssessmentModel)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }


    ListModel {
        id: tableRowsModel

        dynamicRoles: true
    }

    Models.RubricsModel {
        id: rubricsModel

        Component.onCompleted: select()
    }

    Models.CombinedAnnotationsVolatileModel {
        id: annotationsVolatileModel
    }

    function rebuildTable() {
        tableRowsModel.clear();
        annotationsVolatileModel.select();
        annotationsVolatileModel.clear();
        annotationsVolatileModel.fieldNames = ['id', 'annotation', 'heading', 'contents'];

        // Get all the headings from all annotations
        var headings = [];

        for (var i=0; i<annotationsModel.count; i++) {
            var annotationObj = annotationsModel.getObjectInRow(i);
            var desc = annotationObj['desc'];

            // 1st capturing (): a string beginning with # and other characters different from two newlines.
            // 2nd non-capturing (): the extra newlines in groups of two or more, or end of line, whatever happens first: (?:\n{2,}|\n$|$)
            // Capture the remaining contents until the next # when it beggins a new paragraph (after two newlines)

            // Regular expression tool at https://regex101.com/r/eJ4hK8/3

            var re = /#((?:.|\n[^\n])*)((?:[^#]|\n[^#])*)/g;
            var match;
            while ((match = re.exec(desc)) !== null) {
                var headingCandidate = match[1];
                var headingContent = match[2];
                headingContent = headingContent.replace(/^(\n|\r)+|(\n|\r)+$/g,'');

                // Prepare headingCandidate, check whether it is already collected and add it.
                headingCandidate = headingCandidate.trim();
                if (headings.indexOf(headingCandidate)<0)
                    headings.push(headingCandidate);

                var objNew = {annotation: annotationObj['title'], heading: headingCandidate, contents: headingContent}

                annotationsVolatileModel.insertObject(objNew);
            }
        }
        rowsListView.extraHeaderData = headings;

        for (var i=0; i<annotationsModel.count; i++) {
            var annotationObj = annotationsModel.getObjectInRow(i);

            var finalFields = [];
            for (var j=0; j<headings.length; j++) {
                // Filter the appropiate fields
                // ....

                annotationsVolatileModel.filters = ['annotation=?','heading=?'];
                annotationsVolatileModel.bindValues = [annotationObj['title'],headings[j]];
                annotationsVolatileModel.select();

                var fieldContents = "";
                for (var k=0; k<annotationsVolatileModel.count; k++) {
                    var fieldsObj = annotationsVolatileModel.getObjectInRow(k);

                    fieldContents = fieldContents + "\n" + (fieldsObj['contents'].replace(/\n(?=[^\n])/g,' ').replace(/\n{2,}/g,'\n').replace(/[ |\t]{2,}/g,' '));
                }

                finalFields.push(fieldContents.substring(1));
            }

            tableRowsModel.append(
                        {
                            row: i+1,
                            annotation: annotationObj['title'],
                            start: annotationObj['start'],
                            end: annotationObj['end'],
                            singleField: finalFields.length==0,
                            fields: JSON.stringify(finalFields)
                        });
        }
    }
}
