import QtQuick 2.5
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors
import 'qrc:///models' as Models

BasicPage {
    id: combinedTable

    property string pageTitle: qsTr("Quadre d'anotacions");

    property SqlTableModel annotationsModel

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
            property int rowNumberWidth: units.fingerUnit * 1.5
            property int annotationFieldWidth: rowsListView.width / 8
            property int periodFieldWidth: rowsListView.width / 8

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
                }
            }

            delegate: Rectangle {
                id: singleContentsRow

                z: 1
                width: rowsListView.width

                border.color: 'black'
                property string fields: model.fields
                property var fieldsModel
                onFieldsChanged: {
                    repeater.model = JSON.parse(singleContentsRow.fields);
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
                        text: model.start + "\n" + model.end

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
                            text: fieldText.contents

                            onContentHeightChanged: singleContentsRowLayout.recalculateMaxHeight()
                            onWidthChanged: singleContentsRowLayout.recalculateMaxHeight()
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

                    fieldContents = fieldContents + "\n" + fieldsObj['contents'];
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
