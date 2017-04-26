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
        //dataBck.dropTable('workFlowLabels');

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

        // Workflows consist of states and transitions


        dataBck.createTable('workFlows', 'title TEXT PRIMARY KEY, desc TEXT');
        dataBck.createTable('workFlowStates', 'id INTEGER PRIMARY KEY, title TEXT, desc TEXT, workFlow TEXT NOT NULL');
        dataBck.createTable('workFlowTransitions', 'id INTEGER PRIMARY KEY, title TEXT, desc TEXT, startState INTEGER, endState INTEGER');
        dataBck.createTable('workFlowLabels', 'id INTEGER PRIMARY KEY, title TEXT, color TEXT, workFlow TEXT NOT NULL');

        // The new type of annotations are attached to states in workflows.
        // Each annotation has some activities, comments, files and labels

        dataBck.createTable('flowAnnotations', 'id INTEGER PRIMARY KEY, title TEXT, desc TEXT, workFlowState INTEGER, start TEXT, end TEXT, state INTEGER');
        dataBck.createTable('flowAnnotationComments', 'id INTEGER PRIMARY KEY, annotation INTEGER NOT NULL, contents TEXT');
        dataBck.createTable('flowAnnotationLabels', 'id INTEGER PRIMARY KEY, annotation INTEGER NOT NULL, label INTEGER');
        dataBck.createTable('flowAnnotationDocuments', 'id INTEGER PRIMARY KEY, annotation INTEGER NOT NULL, title TEXT, contents BLOB, source TEXT, hash TEXT, docType TEXT');
        //dataBck.createTable('flowAnnotationActivities', '');

        dataBck.createTable('annotationsConnections', 'id INTEGER PRIMARY KEY, annotationFrom INTEGER, annotationTo INTEGER, connectionType TEXT, created TEXT');
        //dataBck.createTable('resources','id INTEGER PRIMARY KEY, created TEXT, title TEXT, desc TEXT, type TEXT, source TEXT, contents BLOB, hash TEXT, annotation TEXT');

        dataBck.createTable('timetables', 'id INTEGER PRIMARY KEY, annotation TEXT, periodTime INTEGER NOT NULL, periodDay INTEGER NOT NULL, title TEXT NOT NULL, startTime TEXT, endTime TEXT');

        // Tables categorizedElements and relatedLists work together as a pair

        dataBck.createTable('categorizedElements', 'id INTEGER PRIMARY KEY, category TEXT, element TEXT, description TEXT');
//        dataBck.dropTable('relatedLists');
        dataBck.createTable('relatedLists', 'id INTEGER PRIMARY KEY, mainCategory TEXT, mainElement TEXT, relatedCategory TEXT, relatedElement TEXT, relationship TEXT');

        dataBck.createTable('pagesFolderContexts', 'id TEXT PRIMARY KEY');
        dataBck.createTable('pagesFolderSections', 'id INTEGER PRIMARY KEY, title TEXT, context TEXT, position INTEGER, page TEXT, parameters TEXT');

        // Assessment
        dataBck.createTable('assessmentGrid','id INTEGER PRIMARY KEY, created TEXT, moment TEXT, "group" TEXT, individual TEXT, variable TEXT, value TEXT, comment TEXT, momentCategory TEXT, variableCategory TEXT');
        dataBck.createView('individuals_groups','SELECT "group" FROM individuals_list GROUP BY "group"');

        // Plannings
        // fields: a comma-separated list of field names
        // fieldSettings: JSDICT of each field and its settings
        dataBck.createTable('plannings', 'title TEXT PRIMARY KEY, desc TEXT, category TEXT, fields TEXT, fieldsSettings TEXT');
        dataBck.createTable('planningItems', 'id INTEGER PRIMARY KEY, planning TEXT, list TEXT, title TEXT, desc TEXT, number INTEGER');
        dataBck.createTable('planningItemsActions', 'id INTEGER PRIMARY KEY, item INTEGER, context STRING, number INTEGER, contents TEXT, state TEXT, result TEXT, start TEXT, end TEXT');
        dataBck.dropTable('planningFields');
        //dataBck.createTable('planningsFields', 'id INTEGER PRIMARY KEY, planning TEXT, row INTEGER, field TEXT, contents TEXT, contentType TEXT');

        dataBck.createTable('recentPages', 'id INTEGER PRIMARY KEY, page TEXT, parameters TEXT, title TEXT, timestamp TEXT, state TEXT');

        dataBck.alterTable('documentAnnotations', 'source','TEXT');
        dataBck.alterTable('documentAnnotations', 'hash', 'TEXT');
        dataBck.alterTable('documentAnnotations', 'contents', 'BLOB');
        dataBck.alterTable('annotationsConnections', 'location', 'TEXT');
    }
}
