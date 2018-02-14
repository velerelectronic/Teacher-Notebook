import PersonalTypes 1.0

SqlTableModel {
    tableName: 'multigrid_variables_and_values'
    fieldNames: [
        'varId',
        'varTitle',
        'varDesc',
        'varConfig',
        'valueId',
        'valueTitle',
        'valueDesc',
        'valueConfig'
    ]
    primaryKey: 'id'
    property string tbVars: "multigrid_variables"
    property string tbValues: "multigrid_fixedvalues"

    initStatements: [
        "DROP VIEW multigrid_variables_and_values",
        "CREATE TEMP VIEW IF NOT EXISTS " + tableName + " AS "
        + "SELECT " + tbVars + ".id AS varId, " + tbVars + ".title AS varTitle, " + tbVars + ".desc AS varDesc, " + tbVars + ".config AS varConfig, "
        + tbValues + ".id AS valueId, " + tbValues + ".title AS valueTitle, " + tbValues + ".desc AS valueDesc, " + tbValues + ".config AS valueConfig "
        + "FROM " + tbVars + " LEFT JOIN " + tbValues
        + " ON " + tbValues + ".variable=" + tbVars + ".id"
    ]

    function getVariablesAndValuesInfo(newFilters, newBindValues) {
        filters = newFilters;
        bindValues = newBindValues;
        select();

        /*
        if (count>0)
            return getObjectInRow(0);
        else
            return null;
            */
    }
}
