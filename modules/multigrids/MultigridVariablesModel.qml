import PersonalTypes 1.0

SqlTableModel {
    tableName: 'multigrid_variables'
    fieldNames: [
        'id',
        'multigrid',
        'title',
        'desc',
        'config'
    ]
    primaryKey: 'id'
    creationString: 'id INT PRIMARY KEY, multigrid INT, title TEXT, desc TEXT, config TEXT, FOREIGN KEY(multigrid) REFERENCES multigrids(id) ON DELETE RESTRICT'
}
