import QtQuick 2.0
import '../common' as Common

Rectangle {
    id: abstractEditor
    width: 100
    height: 62
    color: 'transparent'

    Common.UseUnits { id: units }

    property bool changes: false
    property bool trackChanges: false
    property bool closeRequested: false
    property bool autoEnableChangeTracking: true

    signal acceptedCloseEditorRequest()
    signal refusedCloseEditorRequest()
    signal newChanges()

    onChangesChanged: {
        if (changes) {
            abstractEditor.newChanges();
        }
    }

    function acceptOrRefuseRequest() {
        if (changes) {
            refusedCloseEditorRequest();
        }
        else {
            acceptedCloseEditorRequest();
        }
    }

    function enableChangesTracking(value) {
        trackChanges = value;
    }

    function setChanges(value) {
        if (trackChanges) {
            var prev = changes;
            changes = value;
            return prev;
        } else {
            return false;
        }
    }

    function requestCloseEditor() {
        closeRequested = true;
        acceptOrRefuseRequest();
    }

    function showEditMenu(widget) {

    }

    Component.onCompleted: {
        if (autoEnableChangeTracking)
            enableChangesTracking(true);
        // Enabling the changes tracking is important because when the main content is initialized, the variable changes is set to true,
        // but it shouldn't be, because it is not a real change.

    }
}
