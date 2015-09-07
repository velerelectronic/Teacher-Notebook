import QtQuick 2.5
import PersonalTypes 1.0

SqlTableModel {
    id: tableModel
    tableName: 'detailedResourcesAnnotations'
    fieldNames: ['id', 'resourceId', 'resourceTitle', 'resourceDesc', 'resourceType', 'resourceSource', 'resourceContents', 'annotationId']

    property SqlTableModel connectUpdatesTo
}
