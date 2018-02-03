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
        'markType',
        'justDate'
    ]
    primaryKey: 'markId'

    function selectAnnotations(dateStr) {
        bindValues = [dateStr];
        select("SELECT annotations_v3.id AS annotationId, annotations_v3.title AS annotationTitle, annotations_v3.desc AS annotationDesc, annotationTimeMarks.id AS markId, annotationTimeMarks.timeMark AS timeMark, annotationTimeMarks.label AS markLabel, annotationTimeMarks.markType AS markType FROM annotations_v3, annotationTimeMarks WHERE annotations_v3.id=annotationTimeMarks.annotation AND INSTR(timeMark,?)");
    }

    function selectAnnotationsBetweenDates(start, end) {
        bindValues = [start, start, end, end];
        select("SELECT annotations_v3.id AS annotationId, annotations_v3.title AS annotationTitle, annotations_v3.desc AS annotationDesc, annotationTimeMarks.id AS markId, annotationTimeMarks.timeMark AS timeMark, annotationTimeMarks.label AS markLabel, annotationTimeMarks.markType AS markType, substr(annotationTimeMarks.timeMark, 1, 10) AS justDate FROM annotations_v3, annotationTimeMarks WHERE annotations_v3.id=annotationTimeMarks.annotation AND (timeMark > ? OR INSTR(timeMark,?)) AND (timeMark < ? OR INSTR(timeMark,?))");
    }
}
