import QtQuick 2.5
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors
import 'qrc:///models' as Models
import 'qrc:///modules/basic' as Basic
import "qrc:///javascript/Storage.js" as Storage
import "qrc:///common/FormatDates.js" as FormatDates

Basic.BasicPage {
    id: labelsSortPage
    pageTitle: qsTr('Ordenacions');

    Common.UseUnits { id: units }

    Models.LabelsSortModel {
        id: labelsSortModel

        function update(key, field, value) {
            var obj = {};
            obj[field] = value;
            if (updateObject(key, obj))
                select();
        }

        Component.onCompleted: select();
    }

    mainPage: ListView {
        id: labelsList
        anchors.fill: parent

        model: labelsSortModel

        delegate: Rectangle {
            border.color: 'black'
            width: labelsList.width
            height: units.fingerUnit * 2

            RowLayout {
                anchors.fill: parent
                spacing: units.nailUnit

                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width / 3
                    text: model.title
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            titleEditor.enabled = true;
                            titleEditor.content = model.title;
                        }
                    }
                    Editors.TextLineEditor {
                        id: titleEditor

                        visible: enabled
                        enabled: false

                        onAccepted: {
                            labelsSortModel.update(model.id, 'title', titleEditor.content);
                            titleEditor.enabled = false;
                        }
                    }
                }

                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width / 3
                    text: model.desc
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            descEditor.enabled = true;
                            descEditor.content = model.desc;
                        }
                    }
                    Editors.TextLineEditor {
                        id: descEditor

                        visible: enabled
                        enabled: false

                        onAccepted: {
                            labelsSortModel.update(model.id, 'desc', descEditor.content);
                            descEditor.enabled = false;
                        }
                    }
                }

                Text {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: model.labels
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            labelsEditor.enabled = true;
                            labelsEditor.content = model.labels;
                        }
                    }
                    Editors.TextLineEditor {
                        id: labelsEditor

                        visible: enabled
                        enabled: false

                        onAccepted: {
                            var labels = labelsEditor.content;
                            labels = (labels.split(/(?:\\s|#|\\,|\\.)+/g).join(' ').trim(' '));
                            labelsSortModel.update(model.id, 'labels', labels);
                            labelsEditor.enabled = false;
                        }
                    }
                }
            }
        }

        Common.SuperposedButton {
            anchors {
                bottom: parent.bottom
                right: parent.right
            }
            imageSource: 'plus-24844'
            margins: units.fingerUnit / 2
            size: units.fingerUnit * 2
            onClicked: {
                labelsSortModel.insertObject({title: 'title ' + labelsSortModel.count, desc: '', labels: ''});
                labelsSortModel.select();
            }
        }
    }
}

