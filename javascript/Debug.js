function printSqlModel(sqlModel) {
    console.log('Printing fields for ' + sqlModel.tableName);
    var fields = sqlModel.fieldNames;
    for (var i=0; i<sqlModel.count; i++) {
        var obj = sqlModel.getObjectInRow(i);
        var row = "Row " + i;
        for (var j=0; j<fields.length; j++) {
            row += "[" + fields[j] + "]: " + obj[fields[j]] + "; "
        }
        console.log(row);
    }
    console.log('---------');
}

