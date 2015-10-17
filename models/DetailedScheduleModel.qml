import QtQuick 2.5
import PersonalTypes 1.0

SqlTableModel {
    id: tableModel
    tableName: 'detailedSchedule'
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
        'annotationId',
        'annotationTitle',
        'annotationDesc',
        'annotationLabels'
    ]
    primaryKey: 'id'

}
