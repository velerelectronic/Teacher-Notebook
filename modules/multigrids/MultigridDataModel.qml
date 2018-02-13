import PersonalTypes 1.0

SqlTableModel {
    tableName: 'multigrid_data'
    fieldNames: [
        'id',
        'mainVariable',
        'mainValue',
        'secondVariable',
        'secondValue',
        'updated'
    ]
    primaryKey: 'id'
    creationString:
        "id INTEGER PRIMARY KEY,
         mainVariable INTEGER NOT NULL, mainValue INTEGER NOT NULL,
         secondVariable INTEGER NOT NULL, secondValue INTEGER NOT NULL,
         updated TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
         UNIQUE(mainVariable, mainValue, secondVariable) ON CONFLICT REPLACE,
         FOREIGN KEY(mainVariable) REFERENCES multigrid_variables(id) ON DELETE RESTRICT,
         FOREIGN KEY(mainValue) REFERENCES multigrid_fixedvalues(id) ON DELETE RESTRICT,
         FOREIGN KEY(secondVariable) REFERENCES multigrid_variables(id) ON DELETE RESTRICT"

    initStatements: [
        //"DROP TABLE " + tableName,
        "DROP TRIGGER IF EXISTS multigrid_data_avoid_duplicates",
        "DROP TRIGGER IF EXISTS multigrid_data_updated",

        /*
        "CREATE TRIGGER IF NOT EXISTS multigrid_data_avoid_duplicates
         BEFORE INSERT ON " + tableName + " FOR EACH ROW
         WHEN EXISTS (SELECT id FROM " + tableName + "
             WHERE mainVariable=NEW.mainVariable
                AND mainValue=NEW.mainValue
                AND secondVariable=NEW.secondVariable)
         BEGIN
             SELECT raise(IGNORE);
             UPDATE " + tableName + " SET secondValue=NEW.secondValue, updated=strftime('%Y-%m-%dT%H:%M:%fZ','now')
             WHERE mainVariable=NEW.mainVariable
                 AND mainValue=NEW.mainValue
                 AND secondVariable=NEW.secondVariable;
         END",
         */

        "CREATE TRIGGER IF NOT EXISTS multigrid_data_updated
         AFTER UPDATE OF mainVariable, mainValue, secondVariable, secondValue ON " + tableName + " FOR EACH ROW
         BEGIN
             UPDATE " + tableName + " SET updated=strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id=NEW.id;
         END",

        "DROP TRIGGER IF EXISTS multigrid_check_mainvariable",
        "CREATE TRIGGER IF NOT EXISTS multigrid_check_mainvariable
         BEFORE INSERT ON " + tableName + " FOR EACH ROW
         WHEN NEW.mainVariable NOT IN (SELECT id FROM multigrid_variables WHERE isKey=1)
         BEGIN
             SELECT RAISE(ROLLBACK, 'Main variable must be key');
         END",

        "DROP TRIGGER multigrid_ensure_keys",
        "CREATE TRIGGER IF NOT EXISTS multigrid_ensure_keys
         AFTER UPDATE OF isKey ON multigrid_variables FOR EACH ROW
         WHEN OLD.isKey=1 AND NEW.isKey!=1
         BEGIN
             UPDATE multigrid_variables SET isKey=1 WHERE id=NEW.id;
         END"
    ]


    function getAllDataInfo(keyVar, keyValue, secondVar) {
        var fixValTable = "multigrid_fixedvalues";

        bindValues = [keyVar, keyValue, secondVar];
        select("SELECT " + tableName + ".id AS id, " + tableName + ".mainVariable AS mainVariable, " + tableName + ".mainValue AS mainValue, "
               + tableName + ".secondVariable AS secondVariable, " + tableName + ".secondValue AS secondValue, "
               + fixValTable + ".title AS secondValueTitle, " + fixValTable + ".desc AS secondValueDesc"
               + " FROM " + tableName + ", " + fixValTable
               + " WHERE secondValue=" + fixValTable + ".id AND mainVariable=? AND mainValue=? AND secondVariable=?");

        if (count>0)
            return getObjectInRow(0);
        else
            return null;
    }

    function lookFor(keyVar, keyVal, secondVar) {
        filters = [
                    'mainVariable=?',
                    'mainValue=?',
                    'secondVariable=?'
                ];
        bindValues = [keyVar, keyVal, secondVar];
        select();
        if (count>0) {
            var obj = getObjectInRow(0);
            return obj;
        } else
            return null;
    }

}
