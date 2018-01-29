import PersonalTypes 1.0

SqlTableModel {
    id: mainMarksModel

    fieldNames: [
        'annotationId',
        'annotationTitle',
        'annotationDesc',
        'markId',
        'timeMark',
        'markLabel',
        'markType'
    ]
    primaryKey: 'markId'

    function selectAnnotations(dateStr) {
        bindValues = [dateStr];
        select("SELECT annotations_v3.id AS annotationId, annotations_v3.title AS annotationTitle, annotations_v3.desc AS annotationDesc, annotationTimeMarks.id AS markId, annotationTimeMarks.timeMark AS timeMark, annotationTimeMarks.label AS markLabel, annotationTimeMarks.markType AS markType FROM annotations_v3, annotationTimeMarks WHERE annotations_v3.id=annotationTimeMarks.annotation AND INSTR(timeMark,?)");
    }
}
