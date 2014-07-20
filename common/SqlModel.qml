import QtQuick.LocalStorage 2.0 as Sql
import QtQuick 2.2

ListModel {
    id: sqlModel
    property string tableName: ''
    property string select: ''
    property var database
    property string primaryKey
    property var fields: []
    property var results: []

    function getDB() {
        return Sql.LocalStorage.openDatabaseSync('EsquirolDatabase',"1.0",'EsquirolDatabase',1000 * 1024);
    }

    function selectQuery() {
        getDB().transaction(
                    function(tx) {
                        var allfields = fields.join(',');
                        console.log("SELECT " + allfields + " FROM " + tableName + " ORDER BY ?");
                        var results = tx.executeSql("SELECT " + allfields + " FROM " + tableName + " ORDER BY ?" ,[primaryKey]);
                        clear();
                        for (var i=0; i<results.rows.length; i++) {
                            var newObj = {};
                            for (var j=0; j<fields.length; j++) {
                                newObj[fields[j]] = results.rows.item(i)[fields[j]];
                            }
                            append(newObj);
                        }
                    }
                    );
    }

    function setPropertyNotifiable(index,prop,value) {
        var primaryKeyValue = get(index)[primaryKey];
        getDB().transaction(
                    function(tx) {
                        var results = tx.executeSql("UPDATE " + tableName + " SET ?=? WHERE ?=?",[prop,value,primaryKey,primaryKeyValue]);
                        setProperty(index,prop,value);
                    }
                    );
    }

    function removeNotifiable(index) {
        var primaryKeyValue = get(index)[primaryKey];
        getDB().transaction(
                    function(tx) {
                        var results = tx.executeSql("DELETE " + tableName + " WHERE ?=?",[primaryKey,primaryKeyValue]);
                        remove(index,1);
                    }
                    );
    }

    function updateModelRow(primaryKeyValue) {
        getDB().transaction(
                    function(tx) {
                        var allfields = fields.join(',');
                        var results = tx.executeSql("SELECT " + allfields + " FROM " + tableName + " WHERE ?=?" ,[primaryKey,primaryKeyValue]);
                        if (results.rows.length==1) {
                            var found = false;
                            var i=0;
                            while ((!found) && (i<count)) {
                                if (get(i)[primaryKey]==primaryKeyValue) {
                                    found = true;
                                } else {
                                    i++;
                                }
                            }

                            if (found) {
                                set(i,results.rows.item(0));
                            }
                        }
                    });
    }
}
