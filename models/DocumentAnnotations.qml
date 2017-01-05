import PersonalTypes 1.0

SqlTableModel {
    tableName: 'documentAnnotations'
    fieldNames: [
        'id',
        'document',
        'title',
        'desc',
        'created',
        'labels',
        'start',
        'end',
        'state',
        'source',
        'contents',
        'hash'
    ]
    searchFields: []
    primaryKey: 'id'
}
