import PersonalTypes 1.0

SqlTableModel {
    tableName: 'multigrid_variables'
    fieldNames: [
        'id',
        'multigrid',
        'isKey', // Whether this variable can be a primary key in a multigrid. 0 false and 1 true
        'title',
        'desc',
        'config',
        'parentVariable'
    ]

    // Only one key variable is allowed in a multigrid

    primaryKey: 'id'

    creationString:
        'id INTEGER PRIMARY KEY,
         multigrid INTEGER,
         isKey INTEGER DEFAULT 0,
         title TEXT, desc TEXT, config TEXT,
         parentVariable INTEGER NULL,
         CHECK(isKey=0 OR parentVariable IS NULL),
         FOREIGN KEY(multigrid) REFERENCES multigrids(id) ON DELETE RESTRICT,
         FOREIGN KEY(parentVariable) REFERENCES multigrid_variables(id) ON DELETE RESTRICT'

    // Key variables cannot have a parent variable. Variables attached to parents cannot be key variables.

    initStatements: [
        //'DROP TABLE ' + tableName,
        "DROP TRIGGER IF EXISTS noKeyVariablesOnInsert",
        "CREATE TRIGGER IF NOT EXISTS noKeyVariablesOnInsert
         AFTER INSERT ON " + tableName + " FOR EACH ROW
         BEGIN
            UPDATE " + tableName + " SET isKey=0 WHERE id=NEW.id;
         END",

        "DROP TRIGGER IF EXISTS checkUniqueKeyVariable",
        "CREATE TRIGGER IF NOT EXISTS checkUniqueKeyVariable
         AFTER UPDATE OF isKey ON " + tableName + " FOR EACH ROW
         WHEN NEW.isKey!=0 AND (SELECT count(id) FROM " + tableName + " WHERE isKey!=0 AND multigrid=NEW.multigrid) > 1
         BEGIN
            SELECT RAISE(ROLLBACK, 'Key variable must be unique in a multigrid');
         END"
    ]

    function selectKeyVariable(multigrid) {
        bindValues = [multigrid];
        select("SELECT * FROM " + tableName + " WHERE isKey=1 AND multigrid=?");
        if (count>0) {
            return getObjectInRow(0);
        } else
            return null;
    }
}
