import PersonalTypes 1.0

SqlTableModel {
    tableName: 'detailedAnnotations'
    fieldNames: [
        'id',
        'created',
        'title',
        'desc',
        'image',
        'project',
        'labels',
        'projectName',
        'eventsCount',
        'resourcesCount'
    ]
    searchFields: ['title','desc','projectName','labels']
    primaryKey: 'id'
}
