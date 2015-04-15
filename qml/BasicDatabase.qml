import QtQuick 2.0
import PersonalTypes 1.0

DatabaseBackup {
    id: dataBck

    function initEverything() {
        createTables();

        annotationsModel.tableName = 'annotations';
        annotationsModel.fieldNames =  ['created','id','title','desc','image'];
        annotationsModel.select();

        scheduleModel.tableName = 'schedule';
        scheduleModel.fieldNames = ['created','id','event','desc','startDate','startTime','endDate','endTime','state','ref'];
        scheduleModel.setSort(5,Qt.AscendingOrder);
        scheduleModel.select();
    }

    function createTables() {
        //dataBck.dropTable('annotations');
        //dataBck.dropTable('schedule');
        //dataBck.dropTable('rubrics_criteria');
        dataBck.createTable('annotations','id INTEGER PRIMARY KEY, created TEXT, title TEXT, desc TEXT, image BLOB, ref INTEGER');
        dataBck.createTable('schedule','id INTEGER PRIMARY KEY, created TEXT, event TEXT, desc TEXT, startDate TEXT, startTime TEXT, endDate TEXT, endTime TEXT, state TEXT, ref INTEGER');

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
        dataBck.createTable('rubrics_scores','id INTEGER PRIMARY KEY, assessment INTEGER, descriptor INTEGER, moment TEXT, individual INTEGER, comment TEXT');

        dataBck.createTable('projects','id INTEGER PRIMARY KEY, name TEXT, desc TEXT');

        dataBck.createTable('individuals_list', 'id INTEGER PRIMARY KEY, "group" TEXT NOT NULL, name TEXT, surname TEXT, faceImage BLOB');

        // Views
        dataBck.createView('rubrics_levels_descriptors',"SELECT rubrics_descriptors.id AS id, rubrics_descriptors.criterium AS criterium, rubrics_criteria.title AS criteriumTitle, rubrics_criteria.desc AS criteriumDesc, rubrics_descriptors.level AS level, rubrics_descriptors.definition AS definition, rubrics_levels.title AS title, rubrics_levels.desc AS desc, rubrics_levels.score AS score FROM rubrics_levels, rubrics_criteria LEFT JOIN rubrics_descriptors ON rubrics_levels.id=rubrics_descriptors.level WHERE rubrics_criteria.id=rubrics_descriptors.criterium");
        dataBck.createView('rubrics_descriptors_scores',
            "SELECT rubrics_scores.assessment       AS assessment,
                    individuals_list.id             AS individual,
                    individuals_list.name           AS name,
                    individuals_list.surname        AS surname,
                    individuals_list.\"group\"      AS \"group\",
                    rubrics_scores.descriptor       AS descriptor,
                    rubrics_scores.moment           AS moment,
                    rubrics_scores.comment          AS comment,
                    rubrics_descriptors.criterium   AS criterium,
                    rubrics_criteria.title          AS criteriumTitle,
                    rubrics_criteria.desc           AS criteriumDesc,
                    rubrics_criteria.weight         AS weight,
                    rubrics_descriptors.level       AS level,
                    rubrics_descriptors.definition  AS definition,
                    rubrics_levels.score            AS score

                    FROM individuals_list, rubrics_assessment
                    LEFT JOIN rubrics_criteria      ON rubrics_criteria.rubric=rubrics_assessment.rubric,
                    rubrics_descriptors,
                    rubrics_scores,
                    rubrics_levels

                    WHERE   rubrics_assessment.\"group\"=individuals_list.\"group\"
                    AND     rubrics_scores.individual=individuals_list.id
                    AND     rubrics_criteria.id=rubrics_descriptors.criterium
                    AND     rubrics_scores.descriptor=rubrics_descriptors.id
                    AND     rubrics_levels.id=rubrics_descriptors.level

                    ORDER BY individual, moment DESC
            ");

        dataBck.createView('rubrics_total_scores','SELECT assessment, individual, name, surname, \"group\", SUM(weight) AS weight, SUM(score) AS score, SUM(weight * score) AS points FROM rubrics_descriptors_scores GROUP BY assessment, individual');

        // Assessment
        // dataBck.dropTable('assessmentGrid');
        dataBck.createTable('assessmentGrid','id INTEGER PRIMARY KEY, created TEXT, moment TEXT, "group" TEXT, individual TEXT, variable TEXT, value TEXT, comment TEXT');
        dataBck.createView('individuals_groups','SELECT "group" FROM individuals_list GROUP BY "group"');

        annotationsModel.tableName = 'annotations';
        annotationsModel.fieldNames = ['id', 'created' ,'title', 'desc', 'image', 'ref'];
        annotationsModel.setSort(0,Qt.AscendingOrder);
        scheduleModel.tableName = 'schedule';
        scheduleModel.fieldNames = ['id', 'created', 'event', 'desc', 'startDate', 'startTime', 'endDate', 'endTime', 'state', 'ref'];
        scheduleModel.setSort(4,Qt.AscendingOrder);
    }

}
