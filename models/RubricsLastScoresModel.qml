import PersonalTypes 1.0

SqlTableModel {
    tableName: 'rubrics_last_scores'
    fieldNames: [
        'assessment',
        'rubric',

        'individual',
        'name',
        'surname',
        '"group"',

        'criterium',
        'criteriumTitle',
        'criteriumDesc',
        'weight',

        'annotationTitle',
        'annotationStart',
        'anotationEnd',

        'lastScoreId',
        'descriptor',
        'moment',
        'comment',

        'level',
        'definition',
        'score'
    ]
    primaryKey: 'id'
}

