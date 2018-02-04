import QtQuick 2.7
import PersonalTypes 1.0

SqlTableModel {
    id: model

    signal updatedAnnotation(int annotation)

    tableName: 'annotations_v3'
    fieldNames: [
        'id',
        'title',
        'desc',
        'owner',
        'created',
        'updated',
        'state'
    ]
    primaryKey: 'id'

    creationString: 'id INTEGER PRIMARY KEY, title TEXT, desc TEXT, owner TEXT, created TEXT, updated TEXT, state INTEGER'
    initStatements: [
        "DROP TRIGGER changeCreatedField",
        "DROP TRIGGER changeUpdatedField",
        "CREATE TRIGGER changeCreatedField AFTER INSERT ON annotations_v3 FOR EACH ROW BEGIN UPDATE annotations_v3 SET created=strftime('%Y-%m-%dT%H:%M:%fZ','now'), updated=strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id=NEW.id; END",
        "CREATE TRIGGER changeUpdatedField AFTER UPDATE OF id, title, desc, owner, state ON annotations_v3 FOR EACH ROW BEGIN UPDATE annotations_v3 SET updated=strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id=NEW.id; END"
    ]

    function getModTime() {
        var now = new Date();
        return now.toISOString();
    }

    function newAnnotation(title, desc, owner) {
        var obj = insertObject({title: title, desc: desc, owner: owner, state: 0});
        update();
        updatedAnnotation(obj);
        return obj;
    }

}
