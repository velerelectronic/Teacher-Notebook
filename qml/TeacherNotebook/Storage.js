.import QtQuick.LocalStorage 2.0 as Sql
.import 'constants/NotebookEvent.js' as NotebookEvent

String.prototype.repeat = function(times) {
    return Array(times+1).join(this);
}

function fillArray (a, times) {
    var vec = [];
    for (var i=0; i<times; i++) {
        // var a = new String(this);
        vec.push(a);
    }
    return vec;
}

// Basic functions for creation and destruction

function getDatabase() {
    var db = Sql.LocalStorage.openDatabaseSync('EsquirolDatabase',"1.0",'EsquirolDatabase',1000 * 1024);
    return db;
}

function initDatabase() {
    var db = getDatabase();
    db.transaction(
            function(tx) {
                // Init the table of the field names
                tx.executeSql('CREATE TABLE IF NOT EXISTS FieldNames (instant TEXT NOT NULL, tblname TEXT NOT NULL, field TEXT NOT NULL, desc TEXT)');
            });
}

function destroyDatabase() {
    getDatabase().transaction(
            function(tx) {
                var rs = tx.executeSql('SELECT DISTINCT tblname FROM FieldNames');
                for (var i=0; i<rs.rows.length; i++) {
                    tx.executeSql('DROP TABLE IF EXISTS ' + rs.rows.item(i).tblname);
                }
                tx.executeSql('DROP TABLE IF EXISTS FieldNames');
                tx.executeSql('DROP TABLE annotations');
            });
}

// Current time in ISO Format

function currentTime() {
    var now = new Date();
    var format = now.toISOString();
    return format;
}

function listTableFields(tx,tblname) {
    var rs = tx.executeSql('SELECT field FROM FieldNames WHERE tblname=?',[tblname]);
    var list = [];
    for (var i=0; i<rs.rows.length; i++) {
        list.push(rs.rows.item(i).field);
    }
    return list;
}

function removeDimensionalTable (tblname) {
    getDatabase().transaction(
            function (tx) {
                tx.executeSql('DELETE FROM FieldNames WHERE tblname=?',[tblname]);
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
        tx.executeSql('CREATE TABLE ' + tblname + ' (id INTEGER PRIMARY KEY, created TEXT NOT NULL, ref INTEGER' + textcamps + ')');
        var instant = currentTime();
        for (var i=0; i<camps.length; i++) {
            fillFieldNames(tx,instant,tblname,camps[i],desc[i]);
        }
    }
    catch (err) {
        console.log('Error ' + err);
    }
}

function fillFieldNames (tx,created,table,field,desc) {
    tx.executeSql('INSERT INTO FieldNames VALUES(?,?,?,?)',[created,table,field,desc]);
}

function newDimensionalTable (tblname,camps,desc) {
    getDatabase().transaction(
                function (tx) {
                    createDimensionalTable(tx,tblname,camps,desc);
                });
}

function listTableRecords (model,tblname,limit,filterStr,orderStr,extraStr) {
        // If order is different from "", then the results will be sorted
        // If the limit is 0, all the results will be selected
    getDatabase().transaction(
                function(tx) {
                    var param = [];
                    var limitStr = [];
                    var qStr = "SELECT * FROM " + tblname;
                    var filterQuery = '';
                    var list = [];

                    // Add a filter to look for strings in all fields
                    if ((filterStr != null) && (filterStr != '')) {
                        list = listTableFields(tx,tblname);
                        var filterField = [];
                        for (var i=0; i<list.length; i++) {
                            filterField.push('instr(UPPER('+list[i]+'),UPPER(?))');
                        }

                        filterQuery = ' WHERE (' + filterField.join(' OR ') + ')';
                    }

                    // Add a filter based on extra conditions
                    if (extraStr != '') {
                        if (filterQuery == '')
                            filterQuery = ' WHERE ' + extraStr;
                        else
                            filterQuery += ' AND ' + extraStr;
                    }

                    // Sort results
                    orderStr = (orderStr=='')?" ORDER BY id DESC":" ORDER BY " + orderStr;

                    // Limit the number of results
                    if (limit>0) {
                            limitStr += " LIMIT "+(limit.toString());
                    }
                    var rs = tx.executeSql(qStr + filterQuery + orderStr + limitStr, fillArray(filterStr,list.length));
                    model.clear();
                    for (var i=0; i<rs.rows.length; i++) {
                        model.append(convertToArray(rs.rows.item(i)));
                    }
                });
}

function convertToArray(item) {
    var vector = {};
    for (var prop in item) {
        vector[prop] = item[prop];
    }
    vector.selected = false;
    return vector;
}

function listOneField (tblname, field, model) {
    getDatabase().transaction(
                function(tx) {
                    var rs = tx.executeSql("SELECT DISTINCT " + camp + " FROM " + tblname + " ORDER BY " + camp + " ASC");
                    for (var i=0; i<rs.rows.length; i++) {
                        model.append(convertToArray(rs.rows.item(i)));
                    }
                });
}

function listOneRecord (tblname, id) {
    var res = {};
    getDatabase().transaction(
                function (tx) {
                    var rs = tx.executeSql("SELECT * FROM " + tblname + " WHERE id=?",[id]);
                    if (rs.rows.length>0) {
                        res = rs.rows.item(0);
                    }
                });
    return res;
}

// Save functions

function saveRecordsInTable(tblname,fields,refrowid) {
    getDatabase().transaction(
            function (tx) {
                if (refrowid<0) {
                    var text = '?,'.repeat(fields.length);
                    text += '?,?,?';
                    var instant = currentTime();
                    var rs = tx.executeSql("INSERT INTO " + tblname + " VALUES ("+text+")",[null,instant,((refrowid==null)?'':refrowid)].concat(fields));
                } else {
                    var fieldNames = listTableFields(tx,tblname);
                    for (var i=0; i<fieldNames.length; i++) {
                        var rs = tx.executeSql("UPDATE "+ tblname + " SET " + fieldNames[i] + "=? WHERE id=?",[fields[i],refrowid]);
                    }
                }
            });
}

// Record deletion funcions

function removeRecordFromTable(tblname,id) {
    getDatabase().transaction(
                function (tx) {
                    var rs = tx.executeSql("DELETE FROM " + tblname + " WHERE id=?",[id]);
                });
}

// ----------------
// Education tables
// ----------------

function createEducationTables() {
    getDatabase().transaction(
                function (tx) {
                    createAnnotationsTable(tx);
                    createScheduleTable(tx);
                });
}

// -----------
// Annotations
// -----------

function createAnnotationsTable(tx) {
    createDimensionalTable(tx,'annotations',['title','desc'],['Títol','Descripció']);
}

function saveAnnotation(id,title,desc) {
    saveRecordsInTable('annotations',[title,desc],id);
}

function listAnnotations(model,limit,text) {
    listTableRecords(model,'annotations',limit,text,'','');
}

function getDetailsAnnotationId(id) {
    return listOneRecord('annotations',id);
}

function removeAnnotation(id) {
    removeRecordFromTable('annotations',id);
}

function removeAnnotationsTable() {
    removeDimensionalTable('annotations');
}


// --------
// Schedule
// --------

function createScheduleTable(tx) {
    createDimensionalTable(tx,'schedule',['event','desc','startDate','startTime','endDate','endTime','state'],['Esdeveniment','Descripcio','Data inicial','Hora inicial','Data final','Hora final','Estat']);
}

function saveEvent(id,event,desc,startDate,startTime,endDate,endTime,state) {
    saveRecordsInTable('schedule',[event,desc,startDate,startTime,endDate,endTime,state],id);
}

function listEvents(model,limit,filter,order,stateType) {
    var orderText;
    switch(order) {
    case 4:
        orderText = "endDate DESC, endTime DESC, startDate DESC, startTime DESC, id DESC";
        break;
    case 3:
        orderText = "startDate DESC, startTime DESC, endDate DESC, endTime DESC, id DESC";
        break;
    case 2:
        orderText = "endDate ASC, endTime ASC, startDate ASC, startTime ASC, id ASC";
        break;
    case 1:
    default:
        orderText = "startDate ASC, startTime ASC, endDate ASC, endTime ASC, id ASC";
    }
    var extraFilter;
    switch(stateType) {
    case NotebookEvent.StateDone:
        extraFilter = "state='done'";
        break;
    case NotebookEvent.StateNotDone:
        extraFilter = "(state IS NULL OR state!='done')";
        break;
    case NotebookEvent.StateAll:
    default:
        extraFilter = '';
    }

    listTableRecords(model,'schedule',limit,filter,orderText,extraFilter);
}

function getDetailsEventId(id) {
    return listOneRecord('schedule',id);
}

function removeEvent(id) {
    removeRecordFromTable('schedule',id);
}

function removeScheduleTable() {
    removeDimensionalTable('schedule');
}


// Import and export functions

function exportDatabaseToText() {
    var exportObject = {};
    exportObject.database = {}
    exportObject.database.tables = [];

    getDatabase().readTransaction(
        function (tx) {
            var rs = tx.executeSql("SELECT tbl_name FROM sqlite_master WHERE type='table'");
            for (var i=0; i<rs.rows.length; i++) {
                var tblname = rs.rows.item(i).tbl_name;

                var objectTable = {}
                objectTable.name = tblname;
                objectTable.records = [];

                var rs2 = tx.executeSql('SELECT * FROM ' + tblname);
                for (var j=0; j<rs2.rows.length; j++) {
                    objectTable.records.push(rs2.rows.item(j));
                }
                exportObject.database.tables.push(objectTable);
            }
        });
    return JSON.stringify(exportObject);
}

function importDatabaseFromText(text) {
    var importObject = JSON.parse(text);
    var msgError = '';
    getDatabase().transaction(
        function (tx) {
            // Iterate through the tables
            for (var numTable=0; numTable<importObject.database.tables.length; numTable++) {
                var table = importObject.database.tables[numTable];
                // Iterate through the records of one table
                var rs = tx.executeSql('DELETE FROM ' + table.name);
                for (var numRecord=0; numRecord<table.records.length; numRecord++) {
                    // Iterate through the fields and values of one record
                    var fields = [];
                    var unknowns = [];
                    var values = [];
                    for (var prop in table.records[numRecord]) {
                        fields.push(prop);
                        unknowns.push('?');
                        values.push(table.records[numRecord][prop]);
                    }
                    var importSql = 'INSERT INTO ' + table.name + ' (' + fields.join(',') + ') VALUES (' + unknowns.join(',') +')';
                    try {
                        var rs = tx.executeSql(importSql, values);
                    }
                    catch(error) {
                        msgError += 'Ups! Error ha estat '+error+')\n';
                    }
                }
            }
        });
    return msgError;
}
