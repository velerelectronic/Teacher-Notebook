import PersonalTypes 1.0

SqlTableModel {
    tableName: 'annotationTimeMarks'
    fieldNames: [
        'id',
        'annotation',
        'markType',
        'label',
        'timeMark'
    ]
    creationString: 'id INTEGER PRIMARY KEY, annotation INT NOT NULL, markType TEXT, label TEXT, timeMark TEXT, FOREIGN KEY(annotation) REFERENCES annotations_v3(id) ON DELETE RESTRICT'
    primaryKey: 'id'
}
