import QtQuick 2.0
import PersonalTypes 1.0

DatabaseBackup {
    id: dataBck

    function initEverything() {
        createTables();
        createVolatileTables();

        dataBck.createFunction('Split','@Sep char(1), @S varchar(512)','TABLE','WITH Pieces(pn, start, stop) AS (SELECT 1, 1, CHARINDEX(@Sep, @S) UNION ALL SELECT pn + 1, stop + 1, CHARINDEX(@Sep, @S, stop + 1) FROM Pieces WHERE stop > 0) SELECT pn, SUBSTR(@S, start, CASE WHEN stop > 0 THEN stop-start ELSE 512 END) AS S FROM Pieces');

//        globalAnnotationsModel.tableName = 'annotations';
        console.log("SELECTING in annotations")
        globalAnnotationsModel.fieldNames =  ['created','id','title','desc','image','labels'];
        globalAnnotationsModel.select();

//        globalScheduleModel.tableName = 'schedule';
        globalScheduleModel.fieldNames = ['created','id','event','desc','startDate','startTime','endDate','endTime','state','ref'];
        globalScheduleModel.setSort(5,Qt.AscendingOrder);
        globalScheduleModel.filters = [];
        globalScheduleModel.select();

//        globalProjectsModel.tableName = 'projects';
        globalProjectsModel.fieldNames = ['id', 'name', 'desc'];
        globalProjectsModel.select();
    }

    function configureEventCharacteristics(model) {
        model.tableName = 'eventCharacteristics';
        model.fieldNames = ['id','characteristic','event','comment'];
    }

    function configureDetailedEventCharacteristics(model) {
        model.tableName = 'detailedEventCharacteristics';
        model.fieldNames = ['id','comment','characteristicId','characteristicTitle','characteristicDesc','eventId','eventTitle','eventDesc','startDate','startTime','endDate','endTime','eventState','eventRef'];
    }

    function createTables() {
        //dataBck.dropTable('annotations');
        //dataBck.dropTable('schedule');
        //dataBck.dropTable('rubrics_criteria');
        dataBck.createTable('annotations','id INTEGER PRIMARY KEY, created TEXT, title TEXT, desc TEXT, image BLOB, ref INTEGER, labels TEXT');

        dataBck.createTable('extended_annotations','title TEXT PRIMARY KEY, created TEXT, desc TEXT, project TEXT, labels TEXT, start TEXT, end TEXT, state INTEGER');

        dataBck.createTable('savedAnnotationsSearches', 'id INTEGER PRIMARY KEY, title TEXT UNIQUE NOT NULL, desc TEXT, terms TEXT, created TEXT');
        dataBck.createTable('schedule','id INTEGER PRIMARY KEY, created TEXT, event TEXT, desc TEXT, startDate TEXT, startTime TEXT, endDate TEXT, endTime TEXT, state TEXT, ref INTEGER');

        dataBck.createTable('characteristics','id INTEGER PRIMARY KEY, title TEXT, desc TEXT, ref INTEGER');
        dataBck.createTable('eventCharacteristics', 'id INTEGER PRIMARY KEY, characteristic INTEGER, event INTEGER, comment TEXT');

        dataBck.createTable('labelsSort', 'id INTEGER PRIMARY KEY, title TEXT, desc TEXT, labels TEXT');

        createView('detailedSchedule',
                   "SELECT  schedule.id         AS id,
                            schedule.created    AS created,
                            schedule.event      AS event,
                            schedule.desc       AS desc,
                            schedule.startDate  AS startDate,
                            schedule.startTime  AS startTime,
                            schedule.endDate    AS endDate,
                            schedule.endTime    AS endTime,
                            schedule.state      AS state,
                            schedule.ref        AS annotationId,
                            annotations.title   AS annotationTitle,
                            annotations.desc    AS annotationDesc,
                            annotations.labels  AS annotationLabels
                    FROM    schedule
                    LEFT JOIN   annotations     ON annotations.id = schedule.ref
                    ");
        createView('detailedEventCharacteristics',
            "SELECT eventCharacteristics.id             AS id,
                    eventCharacteristics.comment        AS comment,
                    characteristics.id                  AS characteristicId,
                    characteristics.title               AS characteristicTitle,
                    characteristics.desc                AS characteristicDesc,
                    schedule.id                         AS eventId,
                    schedule.event                      AS eventTitle,
                    schedule.desc                       AS eventDesc,
                    schedule.startDate                  AS startDate,
                    schedule.startTime                  AS startTime,
                    schedule.endDate                    AS endDate,
                    schedule.endTime                    AS endTime,
                    schedule.state                      AS eventState,
                    schedule.ref                        AS eventRef
            FROM    eventCharacteristics, characteristics, schedule
            WHERE   eventCharacteristics.characteristic = characteristics.id AND
                    eventCharacteristics.event = schedule.id
            ORDER BY    startDate ASC,
                        startTime ASC,
                        endDate ASC,
                        endTime ASC,
                        state ASC
            ");

        //dataBck.dropTable('rubrics');
        //dataBck.dropTable('rubrics_labels');
        //dataBck.dropTable('rubrics_criteria');
        //dataBck.dropTable('rubrics_levels');
        //dataBck.dropTable('rubrics_descriptors');
        //dataBck.dropTable('rubrics_assessment');
        //dataBck.dropTable('rubrics_scores');


        dataBck.createTable('rubrics', 'id INTEGER PRIMARY KEY, title TEXT, desc TEXT');
        dataBck.createTable('rubrics_labels','id INTEGER PRIMARY KEY, label TEXT');
        dataBck.createTable('rubrics_criteria','id INTEGER PRIMARY KEY, title TEXT, desc TEXT, rubric INTEGER, ord INTEGER, weight INTEGER');
        dataBck.createTable('rubrics_levels','id INTEGER PRIMARY KEY,title TEXT, desc TEXT, rubric INTEGER, score INTEGER');
        dataBck.createTable('rubrics_descriptors','id INTEGER PRIMARY KEY, criterium INTEGER, level INTEGER, definition TEXT');

        dataBck.createTable('rubrics_assessment','id INTEGER PRIMARY KEY, title TEXT, desc TEXT, rubric INTEGER, "group" TEXT, event INTEGER');

        console.log('ALTERING table');
        dataBck.alterTable('rubrics_assessment','annotation','TEXT');

        dataBck.createTable('rubrics_scores','id INTEGER PRIMARY KEY, assessment INTEGER, descriptor INTEGER, moment TEXT, individual INTEGER, comment TEXT');

        dataBck.createTable('projects','id INTEGER PRIMARY KEY, name TEXT, desc TEXT');

        dataBck.createTable('individuals_list', 'id INTEGER PRIMARY KEY, "group" TEXT NOT NULL, name TEXT, surname TEXT, faceImage BLOB');

//        dataBck.dropTable('resources');
        dataBck.createTable('resources','id INTEGER PRIMARY KEY, created TEXT, title TEXT, desc TEXT, type TEXT, source TEXT, contents BLOB, hash TEXT');
        dataBck.createTable('resourcesAnnotations', 'id INTEGER PRIMARY KEY, resource INTEGER, annotation INTEGER');

        dataBck.createTable('timetables', 'id INTEGER PRIMARY KEY, annotation TEXT, periodTime INTEGER NOT NULL, periodDay INTEGER NOT NULL, title TEXT NOT NULL, startTime TEXT, endTime TEXT');

        // VIEWS

        dataBck.createView('detailedResourcesAnnotations',
                           "SELECT  resourcesAnnotations.id         AS  id,
                                    resourcesAnnotations.resource   AS  resourceId,
                                    resources.title                 AS  resourceTitle,
                                    resources.desc                  AS  resourceDesc,
                                    resources.type                  AS  resourceType,
                                    resources.source                AS  resourceSource,
                                    resources.contents              AS  resourceContents,
                                    resourcesAnnotations.annotation AS  annotationId
                            FROM    resources,
                                    resourcesAnnotations
                            WHERE   resourcesAnnotations.resource = resources.id
                            ");

        // Views
        dataBck.createView('rubrics_levels_descriptors',"SELECT rubrics_descriptors.id AS id, rubrics_descriptors.criterium AS criterium, rubrics_criteria.title AS criteriumTitle, rubrics_criteria.desc AS criteriumDesc, rubrics_descriptors.id AS descriptor, rubrics_descriptors.level AS level, rubrics_descriptors.definition AS definition, rubrics_levels.title AS title, rubrics_levels.desc AS desc, rubrics_levels.score AS score FROM rubrics_levels, rubrics_criteria LEFT JOIN rubrics_descriptors ON rubrics_levels.id=rubrics_descriptors.level WHERE rubrics_criteria.id=rubrics_descriptors.criterium");

        dataBck.createView('rubrics_last_scores',
            "SELECT ra.id           AS assessment,
                    ra.rubric       AS rubric,

                    il.id           AS individual,
                    il.name         AS name,
                    il.surname      AS surname,
                    il.\"group\"    AS \"group\",

                    rc.id           AS criterium,
                    rc.title        AS criteriumTitle,
                    rc.desc         AS criteriumDesc,
                    rc.ord          AS criteriumOrder,
                    rc.weight       AS weight,

                    lastScores.*,

                    ea.title        AS annotationTitle,
                    ea.start        AS annotationStart,
                    ea.end          AS annotationEnd

                    FROM rubrics_assessment AS ra, individuals_list AS il, rubrics_criteria AS rc

                    LEFT JOIN   extended_annotations    AS ea
                        ON      ra.annotation = ea.title

                    LEFT JOIN (
                        SELECT  MAX(rubrics_scores.id)          AS lastScoreId,
                                rubrics_scores.assessment       AS assessment,
                                rubrics_scores.individual       AS individual,
                                rubrics_scores.descriptor       AS descriptor,
                                rubrics_scores.moment           AS moment,
                                rubrics_scores.comment          AS comment,

                                rubrics_descriptors.criterium   AS criterium,
                                rubrics_descriptors.level       AS level,
                                rubrics_descriptors.definition  AS definition,
                                rubrics_levels.score            AS score

                        FROM    rubrics_scores,
                                rubrics_descriptors,
                                rubrics_levels

                        WHERE   rubrics_scores.descriptor = rubrics_descriptors.id
                            AND rubrics_descriptors.level = rubrics_levels.id

                        GROUP BY    rubrics_scores.individual,
                                    rubrics_scores.assessment,
                                    rubrics_descriptors.criterium
                        ) lastScores

                        ON lastScores.individual = il.id
                        AND lastScores.assessment = ra.id
                        AND lastScores.criterium = rc.id

                    WHERE   ra.\"group\" = il.\"group\"
                    AND     ra.rubric = rc.rubric

                    ORDER BY annotationStart ASC, assessment, criterium, individual ASC
            ");

        dataBck.dropView('rubrics_descriptors_scores');
        dataBck.createView('rubrics_descriptors_scores',
                    "SELECT rubrics_assessment.id           AS assessment,
                            rubrics_assessment.rubric       AS rubric,
                            rubrics_assessment.annotation   AS annotationTitle,

                            extended_annotations.start      AS annotationStart,
                            extended_annotations.end        AS annotationEnd,

                            individuals_list.id             AS individual,
                            individuals_list.name           AS name,
                            individuals_list.surname        AS surname,
                            individuals_list.\"group\"      AS \"group\",

                            rubrics_criteria.id             AS criterium,
                            rubrics_criteria.title          AS criteriumTitle,
                            rubrics_criteria.desc           AS criteriumDesc,
                            rubrics_criteria.weight         AS weight,

                            rubrics_scores.descriptor       AS descriptor,
                            rubrics_scores.moment           AS moment,
                            rubrics_scores.comment          AS comment,
                            rubrics_scores.id               AS scoreId,

                            rubrics_descriptors.level       AS level,
                            rubrics_descriptors.definition  AS definition,

                            rubrics_levels.score            AS score,
                            rubrics_levels.title            AS levelTitle

                            FROM    rubrics_assessment,
                                    individuals_list,
                                    rubrics_criteria,
                                    rubrics_scores,
                                    rubrics_descriptors,
                                    rubrics_levels

                            LEFT JOIN   extended_annotations
                                ON      rubrics_assessment.annotation = extended_annotations.title

                            WHERE       rubrics_assessment.id = rubrics_scores.assessment
                                AND     rubrics_assessment.\"group\" = individuals_list.\"group\"
                                AND     rubrics_assessment.rubric = rubrics_criteria.rubric

                                AND     rubrics_criteria.id = rubrics_descriptors.criterium
                                AND     rubrics_descriptors.level = rubrics_levels.id

                                AND     rubrics_scores.individual = individuals_list.id
                                AND     rubrics_scores.descriptor = rubrics_descriptors.id

                            ORDER BY annotationStart DESC, assessment, criterium, individual ASC
                        ");

        dataBck.createView('rubrics_total_scores','SELECT assessment, individual, name, surname, \"group\", SUM(weight) AS weight, SUM(score) AS score, SUM(weight * score) AS points FROM rubrics_descriptors_scores GROUP BY assessment, individual');

        // Detailed Annotations

        dataBck.dropView('detailedAnnotations');
        dataBck.createView('detailedAnnotations',
                    "SELECT annotations.id                          AS id,
                            annotations.created                     AS created,
                            annotations.title                       AS title,
                            annotations.desc                        AS desc,
                            annotations.image                       AS image,
                            annotations.ref                         AS project,
                            annotations.labels                      AS labels,
                            projects.name                           AS projectName,
                            COUNT(DISTINCT schedule.id)             AS eventsCount,
                            COUNT(DISTINCT resourcesAnnotations.id) AS resourcesCount
                        FROM        annotations
                        LEFT JOIN   projects
                            ON      annotations.ref = projects.id
                        LEFT JOIN   schedule
                            ON      schedule.ref = annotations.id
                        LEFT JOIN   resourcesAnnotations
                            ON      resourcesAnnotations.annotation = annotations.id
                        GROUP BY    annotations.id, schedule.ref, resourcesAnnotations.annotation
                    ");


        // Assessment
        // dataBck.dropTable('assessmentGrid');
        dataBck.createTable('assessmentGrid','id INTEGER PRIMARY KEY, created TEXT, moment TEXT, "group" TEXT, individual TEXT, variable TEXT, value TEXT, comment TEXT');
        dataBck.createView('individuals_groups','SELECT "group" FROM individuals_list GROUP BY "group"');
    }

    function createVolatileTables() {
        dataBck.dropTable('combinedAnnotationsVolatileTable')
        dataBck.createTable('combinedAnnotationsVolatileTable','id INTEGER PRIMARY KEY, annotation TEXT, heading TEXT, contents TEXT');
    }
}
