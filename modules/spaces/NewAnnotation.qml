import QtQuick 2.7
import QtQuick.Layouts 1.3
import 'qrc:///modules/simpleannotations' as SimpleAnnotations
import 'qrc:///common' as Common

Item {
    id: newAnnotationBaseItem

    signal closeNewAnnotation()
    signal openPage(string caption, string qmlPage, var properties)

    Common.UseUnits {
        id: units
    }

    SimpleAnnotations.SimpleAnnotationsModel {
        id: annotationsModel
    }

    ColumnLayout {
        anchors.fill: parent

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 4

            Flow {
                anchors.fill: parent
                spacing: units.fingerUnit

                Common.ImageButton {
                    size: units.fingerUnit * 2
                    image: 'edit-153612'

                    onClicked: {
                        console.log('edit');
                        mainTextEditor.text = "";
                        mainTextEditor.activateEditor();
                    }
                }

                Common.ImageButton {
                    size: units.fingerUnit * 2
                    image: 'paste-35946'

                    onClicked: {
                        console.log('paste');
                        mainTextEditor.activateEditor();
                        mainTextEditor.pasteClipboard();
                    }
                }

                Common.ImageButton {
                    size: units.fingerUnit * 2
                    image: 'calendar-23684'

                    onClicked: {
                        var date = new Date();
                        var currentTimeStamp = date.toLocaleString();
                        mainTextEditor.text = currentTimeStamp;
                        mainTextEditor.activateEditor();
                    }
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true

            color: 'yellow'

            Common.EditableText {
                id: mainTextEditor

                anchors.fill: parent

                onTextChangeAccepted: {
                    var newTitle = qsTr('Nova anotació');
                    if (text !== "") {
                        var re = /^(.*)$/m;
                        var match = re.exec(text);
                        if (match != null) {
                            newTitle = match[0].trim();
                        }

                        var newAnnot = annotationsModel.insertObject({title: newTitle, desc: text});
                        newAnnotationBaseItem.openPage(newTitle, 'simpleannotations/ShowAnnotation', {identifier: newAnnot});
                        closeNewAnnotation();
                    } else {
                        activateEditor();
                    }
                }

                onEditorClosed: {
                    closeNewAnnotation();
                }
            }
        }
    }

}
