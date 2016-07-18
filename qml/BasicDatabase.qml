import QtQuick 2.5
import PersonalTypes 1.0

DatabaseBackup {
    id: dataBck

    function initEverything() {
        createTables();

        dataBck.createFunction('Split','@Sep char(1), @S varchar(512)','TABLE','WITH Pieces(pn, start, stop) AS (SELECT 1, 1, CHARINDEX(@Sep, @S) UNION ALL SELECT pn + 1, stop + 1, CHARINDEX(@Sep, @S, stop + 1) FROM Pieces WHERE stop > 0) SELECT pn, SUBSTR(@S, start, CASE WHEN stop > 0 THEN stop-start ELSE 512 END) AS S FROM Pieces');

//        globalProjectsModel.tableName = 'projects';
        globalProjectsModel.fieldNames = ['id', 'name', 'desc'];
        globalProjectsModel.select();
    }

    function createTables() {
        dataBck.dropTable('projects');

        //dataBck.dropTable('rubrics_criteria');
        dataBck.createTable('extended_annotations','title TEXT PRIMARY KEY, created TEXT, desc TEXT, project TEXT, labels TEXT, start TEXT, end TEXT, state INTEGER');

        dataBck.createTable('savedAnnotationsSearches', 'id INTEGER PRIMARY KEY, title TEXT UNIQUE NOT NULL, desc TEXT, terms TEXT, created TEXT');

        dataBck.createTable('characteristics','id INTEGER PRIMARY KEY, title TEXT, desc TEXT, ref INTEGER');
        dataBck.createTable('eventCharacteristics', 'id INTEGER PRIMARY KEY, characteristic INTEGER, event INTEGER, comment TEXT');

        dataBck.createTable('labelsSort', 'id INTEGER PRIMARY KEY, title TEXT, desc TEXT, labels TEXT');

        dataBck.dropTable('rubrics');
        dataBck.dropTable('rubrics_labels');
        dataBck.dropTable('rubrics_criteria');
        dataBck.dropTable('rubrics_levels');
        dataBck.dropTable('rubrics_descriptors');
        dataBck.dropTable('rubrics_assessment');
        dataBck.dropTable('rubrics_scores');
        dataBck.dropTable('individuals_list');


        //dataBck.createTable('rubrics', 'id INTEGER PRIMARY KEY, title TEXT, desc TEXT');
        //dataBck.createTable('rubrics_labels','id INTEGER PRIMARY KEY, label TEXT');
        //dataBck.createTable('rubrics_criteria','id INTEGER PRIMARY KEY, title TEXT, desc TEXT, rubric INTEGER, ord INTEGER, weight INTEGER');
        //dataBck.createTable('rubrics_levels','id INTEGER PRIMARY KEY,title TEXT, desc TEXT, rubric INTEGER, score INTEGER');
        //dataBck.createTable('rubrics_descriptors','id INTEGER PRIMARY KEY, criterium INTEGER, level INTEGER, definition TEXT');

        //dataBck.createTable('rubrics_assessment','id INTEGER PRIMARY KEY, title TEXT, desc TEXT, rubric INTEGER, "group" TEXT, event INTEGER');

        //dataBck.alterTable('rubrics_assessment','annotation','TEXT');

        //dataBck.createTable('rubrics_scores','id INTEGER PRIMARY KEY, assessment INTEGER, descriptor INTEGER, moment TEXT, individual INTEGER, comment TEXT');
        //dataBck.createTable('individuals_list', 'id INTEGER PRIMARY KEY, "group" TEXT NOT NULL, name TEXT, surname TEXT, faceImage BLOB');

        dataBck.createTable('projects','id INTEGER PRIMARY KEY, name TEXT, desc TEXT');


        //dataBck.dropTable('resources');
        //dataBck.dropTable('documentsSources');

        dataBck.createTable('documentsSources', 'title TEXT PRIMARY KEY, desc TEXT, created TEXT, source TEXT, hash TEXT, type TEXT, contents TEXT');
        dataBck.createTable('concurrentDocuments', 'document TEXT PRIMARY KEY, lastAccessTime TEXT, parameters TEXT');

        //dataBck.createTable('resources','id INTEGER PRIMARY KEY, created TEXT, title TEXT, desc TEXT, type TEXT, source TEXT, contents BLOB, hash TEXT, annotation TEXT');

        dataBck.createTable('timetables', 'id INTEGER PRIMARY KEY, annotation TEXT, periodTime INTEGER NOT NULL, periodDay INTEGER NOT NULL, title TEXT NOT NULL, startTime TEXT, endTime TEXT');

        // Views
        dataBck.dropView('rubrics_levels_descriptors');
        // dataBck.createView('rubrics_levels_descriptors',"SELECT rubrics_descriptors.id AS id, rubrics_descriptors.criterium AS criterium, rubrics_criteria.title AS criteriumTitle, rubrics_criteria.desc AS criteriumDesc, rubrics_descriptors.id AS descriptor, rubrics_descriptors.level AS level, rubrics_descriptors.definition AS definition, rubrics_levels.title AS title, rubrics_levels.desc AS desc, rubrics_levels.score AS score FROM rubrics_levels, rubrics_criteria LEFT JOIN rubrics_descriptors ON rubrics_levels.id=rubrics_descriptors.level WHERE rubrics_criteria.id=rubrics_descriptors.criterium");

        dataBck.dropView('rubrics_last_scores');
        dataBck.dropView('rubrics_descriptors_scores');
        dataBck.dropView('rubrics_total_scores');


        // Assessment
        // dataBck.dropTable('assessmentGrid');
        dataBck.createTable('assessmentGrid','id INTEGER PRIMARY KEY, created TEXT, moment TEXT, "group" TEXT, individual TEXT, variable TEXT, value TEXT, comment TEXT');
        dataBck.createView('individuals_groups','SELECT "group" FROM individuals_list GROUP BY "group"');
    }

}
