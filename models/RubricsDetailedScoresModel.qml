import PersonalTypes 1.0

SqlTableModel {
    tableName: 'rubrics_descriptors_scores'
    fieldNames: [
        'assessment',
        'rubric',

        'individual',
         'name',
        'surname',
        'group',

        'criterium',
        'criteriumTitle',
        'criteriumDesc',
        'weight',

        'descriptor',
        'moment',
        'comment',
        'scoreId',

        'level',
        'definition',

        'levelTitle',
        'score'

    ]
    primaryKey: 'id'
}
