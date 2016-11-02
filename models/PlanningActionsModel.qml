import PersonalTypes 1.0

SqlTableModel {
    tableName: 'planningActions'
    fieldNames: [
        'id',
        'session',
        'number',
        'field',
        'contents',
        'state',
        'pending',
        'newAction'
    ]
    primaryKey: 'id'
}
