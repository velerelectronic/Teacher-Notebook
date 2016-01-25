import PersonalTypes 1.0

SqlTableModel {
    id: model

    tableName: 'extended_annotations'
    fieldNames: [
        'title',
        'created',
        'desc',
        'project',
        'labels',
        'start',
        'end',
        'state'
    ]
    primaryKey: 'title'

    function selectAnnotations(sortLabels) {
        // All labels are numbered starting at 1. Number 0 means no label assigned.

        var firstLabel = "";

        var labelCode = "";
        var groupingCode = "";
        var groupLabel = "";

        if (sortLabels != '') {
            var labels = sortLabels.replace(/\s{2,}/,' ').toLowerCase().split(' ');

            var detectFirstLabel = "CASE WHEN labels = '' OR labels IS NULL THEN ";
            labelCode = detectFirstLabel + "0";
            firstLabel = detectFirstLabel + "''";

            for (var i=0; i<labels.length; i++) {
                // Check if the first label is between the record labels
                var detectLabel = " WHEN instr(' '||lower(labels)||' ','" + labels[i] + "')>0 THEN "
                labelCode += detectLabel + (i+1);
                firstLabel += detectLabel + "'" + labels[i] + "'";
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

        model.calculatedFieldNames = [
            firstLabel + " AS firstLabel",
            labelCode + " AS labelCode",
            groupingCode + " AS labelGroup",
            "COUNT(" + groupingCode + ") AS groupCount"
        ]
        model.select();
    }

}
