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

        dataBck.createTable('extended_annotations','title TEXT PRIMARY KEY, created TEXT, desc TEXT, project TEXT, labels TEXT, start TEXT, end TEXT, state INTEGER');

        dataBck.createTable('savedAnnotationsSearches', 'id INTEGER PRIMARY KEY, title TEXT UNIQUE NOT NULL, desc TEXT, terms TEXT, created TEXT');

        dataBck.createTable('characteristics','id INTEGER PRIMARY KEY, title TEXT, desc TEXT, ref INTEGER');
        dataBck.createTable('eventCharacteristics', 'id INTEGER PRIMARY KEY, characteristic INTEGER, event INTEGER, comment TEXT');

        dataBck.createTable('labelsSort', 'id INTEGER PRIMARY KEY, title TEXT, desc TEXT, labels TEXT');


        //dataBck.dropTable('resources');
        //dataBck.dropTable('documentsSources');

        dataBck.createTable('documentsSources', 'title TEXT PRIMARY KEY, desc TEXT, created TEXT, source TEXT, hash TEXT, type TEXT, contents TEXT');
        dataBck.createTable('concurrentDocuments', 'document TEXT PRIMARY KEY, lastAccessTime TEXT, parameters TEXT');
        dataBck.createTable('documentAnnotations', 'id INTEGER PRIMARY KEY, document TEXT, title TEXT, desc TEXT, created TEXT, labels TEXT, start TEXT, end TEXT, state INTEGER');

        //dataBck.createTable('resources','id INTEGER PRIMARY KEY, created TEXT, title TEXT, desc TEXT, type TEXT, source TEXT, contents BLOB, hash TEXT, annotation TEXT');

        dataBck.createTable('timetables', 'id INTEGER PRIMARY KEY, annotation TEXT, periodTime INTEGER NOT NULL, periodDay INTEGER NOT NULL, title TEXT NOT NULL, startTime TEXT, endTime TEXT');

        // Tables categorizedElements and relatedLists work together as a pair

        dataBck.createTable('categorizedElements', 'id INTEGER PRIMARY KEY, category TEXT, element TEXT, description TEXT');
//        dataBck.dropTable('relatedLists');
        dataBck.createTable('relatedLists', 'id INTEGER PRIMARY KEY, mainCategory TEXT, mainElement TEXT, relatedCategory TEXT, relatedElement TEXT, relationship TEXT');

        dataBck.createTable('pagesFolderContexts', 'id TEXT PRIMARY KEY');
        dataBck.createTable('pagesFolderSections', 'id INTEGER PRIMARY KEY, title TEXT, context TEXT, position INTEGER, page TEXT, parameters TEXT');

        // Assessment
        // dataBck.dropTable('assessmentGrid');
        dataBck.createTable('assessmentGrid','id INTEGER PRIMARY KEY, created TEXT, moment TEXT, "group" TEXT, individual TEXT, variable TEXT, value TEXT, comment TEXT');
        dataBck.createView('individuals_groups','SELECT "group" FROM individuals_list GROUP BY "group"');

    }
}
