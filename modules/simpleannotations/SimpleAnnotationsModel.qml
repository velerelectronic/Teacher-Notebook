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

    function getModTime() {
        var now = new Date();
        return now.toISOString();
    }

    function newAnnotation(title, desc, owner) {
        var modtime = getModTime();
        var obj = insertObject({title: title, desc: desc, owner: owner, created: modtime, updated: modtime, state: 0});
        update();
        updatedAnnotation(obj);
        return obj;
    }
}
