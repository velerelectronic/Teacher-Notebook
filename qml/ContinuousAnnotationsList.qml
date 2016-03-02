import QtQuick 2.5
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors
import "qrc:///javascript/Storage.js" as Storage
import "qrc:///common/FormatDates.js" as FormatDates

BasicPage {
    id: annotations

    pageTitle: qsTr('Anotacions continues');

    Common.UseUnits {
        id: units
    }

    property var periodStart: new Date();
    property var periodEnd: new Date();

    property string headerText: qsTr('Més enrere')
    property string footerText: qsTr('Més envant')

    mainPage: Item {
        ColumnLayout {
            anchors.fill: parent
            Common.SearchBox {
                Layout.fillWidth: true
                Layout.preferredHeight: units.fingerUnit
                onIntroPressed: {
                    annotationsModel.searchString = text;
                    annotationsModel.select();
                }
            }
            ListView {
                id: annotationsList
                Layout.fillHeight: true
                Layout.fillWidth: true

                model: annotationsModel

                header: Item {
                    width: annotationsList.width
                    height: units.fingerUnit
                    Text {
                        anchors.fill: parent
                        font.pixelSize: units.readUnit
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: headerText
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            periodStart.setDate(periodStart.getDate() - 7);
                            annotationsModel.setupPeriod();
                            beforeAnnotationsModel.setupFilter();
                            if (beforeAnnotationsModel.count == 0)
                                headerText = qsTr('No hi ha anotacions més enrere de ') + periodStart.toLongDate();
                            else
                                headerText = qsTr('Mirar més enrere de ') + periodStart.toLongDate();
                        }
                    }
                }

                footer: Item {
                    width: annotationsList.width
                    height: units.fingerUnit
                    Text {
                        anchors.fill: parent
                        font.pixelSize: units.readUnit
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: qsTr('Més envant de ') + footerText
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var offset = annotationsList.contentY;

                            periodEnd.setDate(periodEnd.getDate() + 7);
                            annotationsModel.setupPeriod();
                            annotationsList.contentY = offset;
                            afterAnnotationsModel.setupFilter();

                            if (afterAnnotationsModel.count == 0)
                                footerText = qsTr('No hi ha anotacions més envant de ') + periodEnd.toLongDate();
                            else
                                footerText = qsTr('Mirar més envant de ') + periodEnd.toLongDate();
                        }
                    }
                }

                delegate: Rectangle {
                    id: singleAnnotationRectangle

                    z: 1
                    states: [
                        State {
                            name: 'hidden'
                            PropertyChanges {
                                target: singleAnnotationRectangle
                                height: units.fingerUnit / 2
                                color: 'gray'
                            }
                        },
                        State {
                            name: 'minimized'
                            PropertyChanges {
                                target: singleAnnotationRectangle
                                height: units.fingerUnit * 2
                            }
                        },
                        State {
                            name: 'expanded'
                            PropertyChanges {
                                target: singleAnnotationRectangle
                                height: Math.max(contentsField.contentHeight + units.nailUnit * 2, units.fingerUnit * 2)
                            }
                        }

                    ]
                    transitions: [
                        Transition {
                            from: 'hidden'
                            to: 'minimized'
                            reversible: true
                            PropertyAnimation {
                                target: singleAnnotationRectangle
                                property: 'height'
                                duration: 500
                            }
                        },
                        Transition {
                            from: 'minimized'
                            to: 'expanded'
                            PropertyAnimation {
                                target: singleAnnotationRectangle
                                property: 'height'
                                duration: 500
                            }
                        },
                        Transition {
                            from: 'expanded'
                            to: 'minimized'
                            PropertyAnimation {
                                target: singleAnnotationRectangle
                                property: 'height'
                                duration: 500
                            }
                        }
                    ]
                    border.color: 'black'
                    color: (model.state > -1)?'white':'#BBBBBB'
                    width: annotationsList.width
                    state: {
                        if (model.state > -1) {
                            return 'minimized';
                        } else
                            return 'hidden';
                    }

                    property string desc: model.desc
                    property string htmlContents: ''

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: units.nailUnit
                        spacing: units.nailUnit

                        clip: true

                        Text {
                            id: contentsField
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: "<b>" + model.title + "</b> <font color=\"green\">#" + model.labels + "</font><br>" + ((singleAnnotationRectangle.state == 'expanded')?singleAnnotationRectangle.htmlContents:singleAnnotationRectangle.desc)
                            clip: true
                        }
                        Text {
                            Layout.fillHeight: true
                            Layout.preferredWidth: units.fingerUnit * 3
                            text: model.start + "<br>" + model.end
                            clip: true
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (model.state > -1) {
                                if (singleAnnotationRectangle.state == 'expanded')
                                    singleAnnotationRectangle.state = 'minimized';
                                else {
                                    singleAnnotationRectangle.htmlContents = parser.toHtml(singleAnnotationRectangle.desc);
                                    singleAnnotationRectangle.state = 'expanded';
                                }
                            } else {
                                if (singleAnnotationRectangle.state == 'hidden')
                                    singleAnnotationRectangle.state = 'minimized';
                                else
                                    singleAnnotationRectangle.state = 'hidden';
                            }
                        }
                        onPressAndHold: {
                            annotations.openPageArgs('ShowExtendedAnnotation', {identifier: model.title});
                        }
                    }
                }

            }
        }
    }


    MarkDownParser {
        id: parser
    }

    Models.ExtendedAnnotations {
        id: annotationsModel

        sort: 'start ASC, end ASC, title ASC'
        filters: ['(start >= ?) OR (start IS NULL)', '(start <= ?) OR (start IS NULL)']
        searchFields: ['title','desc','labels']

        function setupPeriod() {
            annotationsModel.bindValues = [periodStart.toYYYYMMDDFormat(), periodEnd.toYYYYMMDDFormat()];
            select();
        }

        Component.onCompleted: {
            setupPeriod();
        }
    }

    Models.ExtendedAnnotations {
        id: beforeAnnotationsModel

        sort: annotationsModel.sort
        filters: ['start < ?']

        function setupFilter() {
            beforeAnnotationsModel.bindValues = [periodStart.toYYYYMMDDFormat()];
            select();
        }

        Component.onCompleted: {
            setupFilter();
        }
    }

    Models.ExtendedAnnotations {
        id: afterAnnotationsModel

        sort: annotationsModel.sort
        filters: ['start > ?']

        function setupFilter() {
            afterAnnotationsModel.bindValues = [periodEnd.toYYYYMMDDFormat()];
            select();
        }

        Component.onCompleted: {
            setupFilter();
        }
    }

    Component.onCompleted: {
        periodStart.setDate(periodStart.getDate() - 7);
        periodEnd.setDate(periodEnd.getDate() + 30);

        annotationsModel.setupPeriod();
    }
}

