import PersonalTypes 1.0

SqlTableModel {
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
}
