import PersonalTypes 1.0

SqlTableModel {
    tableName: 'multigrid_variables'
    fieldNames: [
        'id',
        'multigrid',
        'isKey', // Whether this variable can be a primary key in a multigrid. 0 false and 1 true
        'title',
        'desc',
        'config'
    ]
    primaryKey: 'id'
    creationString:
        'id INTEGER PRIMARY KEY,
         multigrid INTEGER,
         isKey INTEGER DEFAULT 0,
         title TEXT, desc TEXT, config TEXT,
         FOREIGN KEY(multigrid) REFERENCES multigrids(id) ON DELETE RESTRICT'
    initStatements: [
        //'DROP TABLE ' + tableName
    ]
}
