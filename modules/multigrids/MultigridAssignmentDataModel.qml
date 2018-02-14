import PersonalTypes 1.0

SqlTableModel {
    tableName: 'multigrid_assignment_data'
    fieldNames: [
        'id',
        'mainVariable',
        'mainValue',
        'secondVariable',
        'secondValue',
        'secondValueTitle',
        'secondValueDesc'
    ]
    primaryKey: 'id'
    creationString: ""

    property string dataTable: "multigrid_data"
    property string fixValTable: "multigrid_fixedvalues"

    initStatements: [
        "CREATE TEMP VIEW IF NOT EXISTS " + tableName
        + " AS SELECT " + dataTable + ".id AS id, " + dataTable + ".mainVariable AS mainVariable, " + dataTable + ".mainValue AS mainValue, "
        + dataTable + ".secondVariable AS secondVariable, " + dataTable + ".secondValue AS secondValue, "
        + fixValTable + ".title AS secondValueTitle, " + fixValTable + ".desc AS secondValueDesc"
        + " FROM " + dataTable + ", " + fixValTable + " WHERE secondValue=" + fixValTable + ".id"
    ]


    function getAllDataInfo(keyVar, keyValue, secondVar) {
        filters = [
                    'mainVariable=?',
                    'mainValue=?',
                    'secondVariable=?'
                ];
        bindValues = [keyVar, keyValue, secondVar];
        select();

        if (count>0)
            return getObjectInRow(0);
        else
            return null;
    }

    function lookFor(keyVar, keyVal, secondVar) {
        filters = [
                    'mainVariable=?',
                    'mainValue=?',
                    'secondVariable=?'
                ];
        bindValues = [keyVar, keyVal, secondVar];
        select();
        if (count>0) {
            var obj = getObjectInRow(0);
            return obj;
        } else
            return null;
    }

}
