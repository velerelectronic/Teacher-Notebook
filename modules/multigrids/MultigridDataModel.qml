import PersonalTypes 1.0

SqlTableModel {
    tableName: 'multigrid_data'
    fieldNames: [
        'id',
        'multigrid',
        'mainVariable',
        'mainValue',
        'secondVariable',
        'secondValue',
        'updated'
    ]
    primaryKey: 'id'
    creationString:
        'id INTEGER PRIMARY KEY, multigrid INTEGER,
         mainVariable INTEGER NOT NULL, mainValue INTEGER NOT NULL,
         secondVariable INTEGER NOT NULL, secondValue TEXT NOT NULL,
         updated TEXT NOT NULL,
         UNIQUE(multigrid, mainVariable, mainValue, secondVariable),
         FOREIGN KEY(mainVariable) REFERENCES multigrid_variables(id) ON DELETE RESTRICT,
         FOREIGN KEY(mainValue) REFERENCES multigrid_fixedvalues(id) ON DELETE RESTRICT,
         FOREIGN KEY(secondVariable) REFERENCES multigrid_variables(id) ON DELETE RESTRICT'

    initStatements: [
        //"DROP TABLE " + tableName,
        "DROP TRIGGER IF EXISTS multigrid_data_avoid_duplicates",
        "DROP TRIGGER IF EXISTS multigrid_data_updated",

        "CREATE TRIGGER IF NOT EXISTS multigrid_data_avoid_duplicates
         INSERT ON " + tableName + " FOR EACH ROW
         WHEN EXISTS (SELECT id FROM " + tableName + "
             WHERE multigrid=NEW.multigrid
                AND mainVariable=NEW.mainVariable
                AND mainValue=NEW.mainValue
                AND secondVariable=NEW.secondVariable)
         BEGIN
             UPDATE " + tableName + " SET secondValue=NEW.secondValue, updated=strftime('%Y-%m-%dT%H:%M:%fZ','now');
         END",

        "CREATE TRIGGER IF NOT EXISTS multigrid_data_updated
         AFTER UPDATE OF multigrid, mainVariable, mainValue, secondVariable, secondValue ON " + tableName + " FOR EACH ROW
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


}
