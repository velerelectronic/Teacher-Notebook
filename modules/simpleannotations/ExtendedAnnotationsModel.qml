// Model for importing data from previous versions of annotations

import PersonalTypes 1.0

SqlTableModel {
    id: model

    tableName: 'extended_annotations'
    fieldNames: [
        'title',
        'created',
        'desc',
        'project',
        'labels',
        'start',
        'end',
        'state'
    ]
    primaryKey: 'title'

    creationString: 'title TEXT PRIMARY KEY, created TEXT, desc TEXT, project TEXT, labels TEXT, start TEXT, end TEXT, state INTEGER'
}
