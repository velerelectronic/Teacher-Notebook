.import QtQuick.LocalStorage 2.0 as Sql

// Basic functions for creation and destruction

function getDatabase() {
    var db = Sql.LocalStorage.openDatabaseSync('ReceptesCuina',"1.0",'ReceptesCuina',1000 * 1024);
    return db;
}

function initDatabase() {
    var db = getDatabase();
    db.transaction(
            function(tx) {
                // Init the table of the field names
                createDimensionalTable(tx,'FieldNames',['table','field','desc'],['Table','Field','Description']);
            });
}

function destroyTables() {
    getDatabase().transaction(
            function(tx) {
                tx.executeSql('DROP TABLE IF EXISTS FieldNames');
            });
}

// Current time in ISO Format

function currentTime() {
    var now = new Date();
    var format = now.toISOString();
    return format;
}

function removeDimensionalTable (tblname) {
    getDatabase().transaction(
            function (tx) {
                tx.executeSql('DELETE FROM NomsCamps WHERE taula=?',[tblname]);
                tx.executeSql('DROP TABLE IF EXISTS ' + tblname);
            });
}

function createDimensionalTable (tx,tblname,camps,desc) {
    // fields:
    // * created: the timestamp of the creation of the record
    // * ref: a reference to a previous row that is being updated

    var textcamps = '';
    for (var i=0; i<camps.length; i++) {
        textcamps += ', ' + camps[i];
        textcamps += ' TEXT';
    }

    // REF: If this row updates another row, then ref is the rowid of the latter
    try {
        tx.executeSql('CREATE TABLE ' + tblname + ' (created TEXT NOT NULL, ref INTEGER' + textcamps + ')');
        if (desc!=null) {
            var instant = currentTime();
            for (var i=0; i<camps.length; i++) {
                fillFieldNames(instant,'',nom,camps[i],desc[i]);
            }
        }
    }
    catch (err) { }
}

function fillFieldNames (tx,created,ref,table,field,desc) {
    tx.executeSql('INSERT INTO FieldNames VALUES(?,?,?,?,?)',[created,ref,table,field,desc]);
}

function newDimensionalTable (tblname,camps,desc) {
    getDatabase().transaction(
                function (tx) {
                    createDimensionalTable(tx,tblname,camps,desc);
                });
}

function listTableRecords (tblname,limit,sqlFilter,model) {
        // If order is different from "", then the results will be sorted
        // If the limit is 0, all the results will be selected
    getDatabase().transaction(
                function(tx) {
                    var param = [];
                    var limitStr = [];
                    var qStr = "SELECT ROWID, * FROM " + tblname;
                    var filterStr = sqlFilter[0];
                    var param = sqlFilter[1];
                    var orderStr = " ORDER BY ROWID DESC";
                    if (limit>0) {
                            limitStr += " LIMIT "+(limit.toString());
                    }
                    var rs = tx.executeSql(qStr + filterStr + orderStr + limitStr,param);
                    for (var i=0; i<rs.rows.length; i++) {
                        model.append(convertToArray(rs.rows.item(i)));
                    }
                });
}

function convertToArray(item) {
    var vector = Array();
    for (var prop in item) {
        vector[prop] = item[prop];
    }
    return vector;
}

function listOneField (tblname, field, model) {
    getDatabase().transaction(
                function(tx) {
                    var rs = tx.executeSql("SELECT DISTINCT " + camp + " FROM " + taula + " ORDER BY " + camp + " ASC");
                    for (var i=0; i<rs.rows.length; i++) {
                        model.append(convertToArray(rs.rows.item(i)));
                    }
                });
}
