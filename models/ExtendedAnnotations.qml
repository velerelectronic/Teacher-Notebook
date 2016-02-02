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

        // Block date:
        // 0: just today
        // 1: this week
        // 2: this month
        // 3: this year
        // 4: after this year
        // -1: last week
        // -2: last month
        // -3: last year
        // -4: before last year

        var firstLabel = "";

        var labelCode = "";
        var groupingCode = "";
        var groupLabel = "";

        var date = new Date();

        var today = date.toYYYYMMDDFormat();

        // Get last and next week dates
        date.setDate(date.getDate() + 7);
        var nextWeek = date.toYYYYMMDDFormat();
        date.setDate(date.getDate() - 14);
        var lastWeek = date.toYYYYMMDDFormat();
        date.setDate(date.getDate() + 7);

        // Get last and next month dates
        date.setMonth(date.getMonth() + 1);
        var nextMonth = date.toYYYYMMDDFormat();
        date.setMonth(date.getMonth() - 2);
        var lastMonth = date.toYYYYMMDDFormat();
        date.setMonth(date.getMonth() + 1);

        // Get last and next year dates
        date.setFullYear(date.getFullYear()  +1);
        var nextYear = date.toYYYYMMDDFormat();
        date.setFullYear(date.getFullYear() - 2);
        var lastYear = date.toYYYYMMDDFormat();

        var blockDate = "CASE WHEN substr(start,1,10)='" + today + "' THEN 0"
        + " WHEN substr(start,1,10)>'" + nextYear + "' THEN 4"
        + " WHEN substr(start,1,10)>'" + nextMonth + "' THEN 3"
        + " WHEN substr(start,1,10)>'" + nextWeek + "' THEN 2"
        + " WHEN substr(start,1,10)>'" + today + "' THEN 1"
        + " WHEN substr(start,1,10)<'" + lastYear + "' THEN -4"
        + " WHEN substr(start,1,10)<'" + lastMonth + "' THEN -3"
        + " WHEN substr(start,1,10)<'" + lastWeek + "' THEN -2"
        + " WHEN substr(start,1,10)<'" + today + "' THEN -1"
        + " ELSE -1000 END";

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
            blockDate + " AS blockDate",
            "COUNT(" + groupingCode + ") AS groupCount"
        ]
        model.select();
    }

}
