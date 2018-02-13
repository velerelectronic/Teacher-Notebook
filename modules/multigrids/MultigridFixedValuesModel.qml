import PersonalTypes 1.0

SqlTableModel {
    id: fixedValuesModel

    tableName: 'multigrid_fixedvalues'
    fieldNames: [
        'id',
        'variable',
        'title',
        'desc',
        'config'
    ]
    primaryKey: 'id'
    creationString: 'id INTEGER PRIMARY KEY, variable INTEGER, title TEXT, desc TEXT, config TEXT, FOREIGN KEY(variable) REFERENCES multigrid_variables(id) ON DELETE RESTRICT'
    initStatements: [
        //'DROP TABLE ' + tableName
    ]

    function getVariablesAndValuesInfo(filterStr, bindValues) {
        var tbVars = "multigrid_variables";
        var filter = (filterStr !== "")?(" WHERE " + filterStr):""

        fixedValuesModel.bindValues = bindValues;
        select("SELECT " + tbVars + ".id AS varId, " + tbVars + ".title AS varTitle, " + tbVars + ".desc AS varDesc, " + tbVars + ".config AS varConfig, "
               + tableName + ".id AS valueId, " + tableName + ".title AS valueTitle, " + tableName + ".desc AS valueDesc, " + tableName + ".config AS valueConfig "
               + "FROM " + tbVars + " LEFT JOIN " + tableName
               + " ON " + tableName + ".variable=" + tbVars + ".id" + filter);
        if (count>0)
            return getObjectInRow(0);
        else
            return null;
    }
}
