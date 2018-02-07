import PersonalTypes 1.0

SqlTableModel {
    tableName: 'multigrids'
    fieldNames: [
        'id',
        'title',
        'desc',
        'config'
    ]
    primaryKey: 'id'
    creationString: 'id INTEGER PRIMARY KEY, title TEXT, desc TEXT, config TEXT'
    initStatements: [
        //'DROP table multigrids'
    ]
}
