import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors


Common.AbstractEditor {
    id: generalTitleEditor
    property string content: ''

    signal saveAnnotationTitleRequest(string content)

    color: 'white'

    function setContent(newContent) {
        generalTitleEditor.enableChangesTracking(false);
        generalTitleEditor.content = newContent;
        generalTitleEditor.enableChangesTracking(true);
    }

    onChangesChanged: {
        if (!generalTitleEditor.changes) {
            titleEditor.setChanges(false);
        }
    }

    Common.UseUnits {
        id: units
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: units.nailUnit
        spacing: units.nailUnit

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 2

            RowLayout {
                anchors.fill: parent
                spacing: units.nailUnit

                Editors.TextLineEditor {
                    id: titleEditor

                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    content: generalTitleEditor.content
                    onChangesChanged: {
                        if (titleEditor.changes) {
                            generalTitleEditor.setChanges(true);
                        }
                    }
                }

                Common.ImageButton {
                    image: 'floppy-35952'
                    size: units.fingerUnit
                    onClicked: saveAnnotationTitleRequest(titleEditor.content)
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }

        Button {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit
            text: qsTr('Esborrar anotació')
            onClicked: {}
        }
    }
}
