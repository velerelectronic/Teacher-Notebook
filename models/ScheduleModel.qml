import PersonalTypes 1.0

SqlTableModel {
    tableName: 'schedule'
    fieldNames: [
        'id',
        'created',
        'event',
        'desc',
        'startDate',
        'startTime',
        'endDate',
        'endTime',
        'state',
        'ref'
    ]
    primaryKey: 'id'
}
