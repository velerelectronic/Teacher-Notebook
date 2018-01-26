import PersonalTypes 1.0

SqlTableModel {
    id: model

    signal updatedAnnotation(int annotation)

    tableName: 'annotations_v2'
    fieldNames: [
        'id',
        'title',
        'desc',
        'owner',
        'modified',
        'state'
    ]
    primaryKey: 'id'

    creationString: 'id INTEGER PRIMARY KEY, title TEXT, desc TEXT, owner TEXT, modified TEXT, state INTEGER'

    function getModTime() {
        var now = new Date();
        return now.toISOString();
    }

    function newAnnotation(title, desc, owner) {
        var modtime = getModTime();
        var obj = insertObject({title: title, desc: desc, owner: owner, modified: modtime, state: 0});
        update();
        updatedAnnotation(obj);
        return obj;
    }
}
