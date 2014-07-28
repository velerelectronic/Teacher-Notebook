.import QtQuick.LocalStorage 2.0 as Sql
.import 'qrc:///javascript/NotebookEvent.js' as NotebookEvent

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

// Current time in ISO Format

function currentTime() {
    var now = new Date();
    var format = now.toISOString();
    return format;
}

function currentTimeForFileName() {
    return currentTime().replace(/\:/g,"-");
}



function convertToArray(item) {
    var vector = {};
    for (var prop in item) {
        vector[prop] = item[prop];
    }
    vector.selected = false;
    return vector;
}


function convertNull(str) {
    return (str?str:'');
}
