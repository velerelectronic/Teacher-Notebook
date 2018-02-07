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
    creationString: 'id INT PRIMARY KEY, title TEXT, desc TEXT, config TEXT'
}
