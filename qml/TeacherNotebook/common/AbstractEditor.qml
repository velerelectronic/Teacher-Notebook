import QtQuick 2.0
import '../common' as Common

Rectangle {
    id: abstractEditor
    width: 100
    height: 62

    Common.UseUnits { id: units }

    property bool changes: true
    property bool closeRequested: false

    signal acceptedCloseEditorRequest()
    signal refusedCloseEditorRequest()

    function acceptOrRefuseRequest() {
        if (changes) {
            console.log('refusing close')
            refusedCloseEditorRequest();
        }
        else {
            console.log('accepting close')
            acceptedCloseEditorRequest();
        }
    }

    function setChanges(value) {
        var prev = changes;
        changes = value;
        return prev;
    }

    function requestCloseEditor() {
        closeRequested = true;
        acceptOrRefuseRequest();
    }

    function showEditMenu(widget) {

    }
}
