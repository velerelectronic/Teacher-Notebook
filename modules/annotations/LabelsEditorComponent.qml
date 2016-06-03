import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors
import 'qrc:///models' as Models


Common.AbstractEditor {
    id: labelsEditor

    property var annotationContent

    property string content

    ListView {
        id: labelsListItem

        anchors.fill: parent

        delegate: Rectangle {
            width: labelsListItem.width
            height: units.fingerUnit + units.nailUnit * 2
            border.color: 'black'
            color: 'white'
            RowLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                spacing: units.nailUnit

                Text {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    verticalAlignment: Text.AlignVCenter
                    text: modelData
                }
                Common.ImageButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: size
                    size: units.fingerUnit * 2
                    available: true
                    image: 'erase-34105'
                    onClicked: deleteLabelDialog.open()
                }
            }

            MessageDialog {
                id: deleteLabelDialog

                property string label: modelData
                title: qsTr('Esborrar etiqueta')
                text: qsTr("Confirmar l'esborrat d'etiqueta")
                informativeText: qsTr("S'esborrarà l'etiqueta «" + deleteLabelDialog.label + "». Vols continuar?" )
                standardButtons: StandardButton.Ok | StandardButton.Cancel
                onAccepted: eraseLabel(deleteLabelDialog.label)
            }

            function eraseLabel(label) {
                content = content.replace(label,"").replace(/(^\s+)|(\s+$)/g, '').replace(/\s\s+/g, ' ');
            }

        }
        footer: Item {
            id: footerItem
            height: childrenRect.height
            width: labelsListItem.width

            Models.ExtendedAnnotations {
                id: labelsModel

                // Incorporate this solution: http://stackoverflow.com/questions/24258878/how-to-split-comma-separated-value-in-sqlite

                Component.onCompleted: {
                    select();
                    labelsRepeater.model = labelsModel.getUniqueLabels();
                }

                function getUniqueLabels() {
                    var labelsArray = [];
                    for (var i=0; i<count; i++) {
                        var labelsString = getObjectInRow(i)['labels'].toLowerCase();
                        var labels = labelsString.split(" ");
                        for (var j=0; j<labels.length; j++) {
                            if (labels[j] !== '')
                                labelsArray.push(labels[j]);
                        }
                    }
                    labelsArray.sort();

                    // remove duplicates

                    var uniqueLabelsArray = [];
                    if (labelsArray.length>0) {
                        uniqueLabelsArray.push(labelsArray[0]);
                        for (var k=1; k<labelsArray.length; k++) {
                            if (labelsArray[k] !== labelsArray[k-1])
                                uniqueLabelsArray.push(labelsArray[k]);
                        }
                    }
                    return uniqueLabelsArray;
                }
            }

            ColumnLayout {
                anchors.margins: units.nailUnit
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                //height: childrenRect.height

                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: contentHeight
                    text: qsTr('Altres etiquetes')
                }

                Flow {
                    Layout.fillWidth: true
                    Layout.preferredHeight: childrenRect.height

                    spacing: units.nailUnit

                    Repeater {
                        id: labelsRepeater

                        Rectangle {
                            border.color: 'black'
                            radius: units.nailUnit * 2
                            width: Math.max(units.fingerUnit, labelText.width) + units.nailUnit * 3
                            height: Math.max(units.fingerUnit, labelText.height) + units.nailUnit
                            Text {
                                id: labelText
                                anchors {
                                    top: parent.top
                                    left: parent.left
                                    margins: units.nailUnit * 2
                                }
                                width: contentWidth
                                height: contentHeight
                                text: modelData
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    // Add existing label
                                    content = content + ((content == '')?'':' ') + modelData;
                                }
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit + 2 * units.nailUnit
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: units.nailUnit

                        TextField {
                            id: newLabelField
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            onAccepted: footerItem.addLabel()
                        }
                        Common.ImageButton {
                            Layout.fillHeight: true
                            Layout.preferredWidth: units.fingerUnit
                            size: units.fingerUnit
                            image: 'plus-24844'
                            onClicked: footerItem.addLabel()
                        }
                    }
                }
            }


            function addLabel() {
                var newLabel = newLabelField.text.replace(/\s+/g,'-')
                if (newLabel !== '') {
                    if (content === '')
                        content = newLabel;
                    else
                        content = content + " " + newLabel;
                }
                newLabelField.text = '';
            }
        }

    }
    onContentChanged: {
        labelsEditor.setChanges(true);
        var labelsArray = content.split(/\s+/g);
        labelsListItem.model = labelsArray;
        annotationContent = {labels: content};
    }
}
