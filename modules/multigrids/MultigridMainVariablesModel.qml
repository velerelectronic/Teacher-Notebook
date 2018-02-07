import PersonalTypes 1.0

SqlTableModel {
    tableName: 'multigrid_variable_candidates'

    property string mgVariablesTable: 'multigrid_variables'
    property string mgDataTable: 'multigrid_data'


    initStatements: [
        "CREATE VIEW " + tableName + " AS SELECT id, title, desc FROM " + mgVariablesTable + " WHERE id NOT IN (SELECT secondVariable FROM " + mgDataTable + ")"
    ]
}
