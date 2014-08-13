import QtQuick 2.2
import QtQuick.XmlListModel 2.0
import PersonalTypes 1.0

Item {
    property int statusCache: XmlListModel.Null
    property string source: ''
    property string contents: ''
    property string lastUpdate: ''
    property string categoria: ''
    property bool typeFiltra: false

    signal onlineDataLoaded

    onOnlineDataLoaded: {
        llegeixHtml();
    }

    function llegeixHtml() {
        var obj = dbModel.getObjectInRow(0);
        if (obj) {
            contents = obj.continguts;
            lastUpdate = obj.instantDades;
        }
        // Storage.llegeixDadesXML(categoria,cachedModel);
    }

    function currentTime() {
        var now = new Date();
        var format = now.toISOString();
        return format;
    }

    function desaDadesXML(contents) {
        var obj = {
            instantRegistrat: currentTime(),
            instantDades: lastUpdate,
            categoria: categoria,
            continguts: contents
        };
        if (!dbModel.updateObject(obj)) {
            dbModel.insertObject(obj);
        }
    }

    /*
    onStatusChanged: {
        statusCache = status;
    }
    */

    function llegeixOnline() {
        statusCache = XmlListModel.Loading;
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
            }
            if ((doc.readyState === XMLHttpRequest.DONE)) {
                console.log('Estat DONE');
                var text = doc.responseText;
                if (typeFiltra) {
                    if ((text)) {
                        lastUpdate = currentTime();
                        text = text.match(/\<table.*<\/table\>/,'').join('');
                        desaDadesXML(text);
                        statusCache = status;
                    } else
                        statusCache = XmlListModel.Null;
                } else {
                    if ((text) && (text != '')) {
                        lastUpdate = currentTime();
                        desaDadesXML(text);
                        statusCache = status;
                    } else
                        statusCache = XmlListModel.Null;
                }

                onlineDataLoaded();
            }
        }
        console.log('Getting source ' +source);
        doc.open('GET',source);
        doc.send(null);
    }

    SqlTableModel {
        id: dbModel
        tableName: 'cacheData'
        filters: ["categoria='" + categoria + "'"]
    }

    Component.onCompleted: {
        llegeixHtml();
        llegeixOnline();
        dbModel.select();
    }
}

