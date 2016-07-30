import QtQuick 2.5
import QtQuick.Layouts 1.1
import RubricXml 1.0
import FileIO 1.0
import ClipboardAdapter 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors
import 'qrc:///modules/files' as Files
import "qrc:///common/FormatDates.js" as FormatDates
import "qrc:///javascript/Storage.js" as Storage

Common.SteppedPage {
    id: rubricExportHtmlPage

    property RubricXml rubricModel
    property string htmlContents: ''
    property string folderName
    property string fileName

    signal close()

    Common.SteppedSection {
        id: convertSection

        Common.UseUnits {
            id: units
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: units.nailUnit

            Common.TextButton {
                Layout.fillWidth: true
                Layout.preferredHeight: units.fingerUnit * 2
                text: qsTr('Converteix a HTML')
                onClicked: {
                    convertSection.convertToHtml()
                }
            }

            Editors.TextAreaEditor3 {
                Layout.fillWidth: true
                Layout.fillHeight: true

                content: htmlContents
            }
            Common.TextButton {
                Layout.fillWidth: true
                Layout.preferredHeight: units.fingerUnit * 2
                text: qsTr('Copia HTML')
                onClicked: {
                    clipboard.copia(htmlContents);
                }
            }
        }
        QClipboard {
            id: clipboard
        }

        function convertToHtml() {
            htmlContents = '<html><head>';
            htmlContents += '<meta charset="UTF-8">';
            htmlContents += '<style>';
            htmlContents += 'table { border: solid 1pt black; border-collapse: collapse; width: 100% }\n';
            htmlContents += 'th { border: solid 1pt black; padding: 1ex; background-color: #D0FA58 }\n';
            htmlContents += 'td { border: solid 1pt black; padding: 1ex }\n';
            htmlContents += '</style>';
            htmlContents += '</head><body>';
            htmlContents += '<h1>Rúbrica d\'avaluació</h1>';
            htmlContents += '<p>' + rubricModel.title + '</p><p>' + rubricModel.description + '</p>';
            htmlContents += '<p>Generada: ' + Storage.currentTime() + '</p>\n';
            var date = new Date();
            htmlContents += '<p>' + date.toShortReadableDate() + " " + date.toTimeSpecificFormat() + '</p>\n';

            htmlContents += "<h2>Graella d'avaluació</h2>";
            htmlContents += '<table>';
            htmlContents += '<tr><td></td>';
            for (var i=0; i<rubricModel.population.count; i++) {
                var individualObj = rubricModel.population.get(i);
                htmlContents += '<th>';
                htmlContents += '<p><b>' + individualObj['identifier'] + '</b></p>';
                htmlContents += '<p>' + individualObj['name'] + '</p>';
                htmlContents += '<p>' + individualObj['surname'] + '</p>';
                htmlContents += '</th>';
            }
            htmlContents += "</tr>";
            for  (var j=0; j<rubricModel.criteria.count; j++) {
                var criteriumObj = rubricModel.criteria.get(j);
                htmlContents += '<tr>';
                htmlContents += '<th>';
                htmlContents += '<p>' + criteriumObj['identifier'] + '</p>';
                htmlContents += '<p><b>' + criteriumObj['title'] + '</b></p>';
                htmlContents += '<p>' + criteriumObj['description'] + '</p>';
                htmlContents += '</th>';

                for (var i=0; i<rubricModel.population.count; i++) {
                    var individualObj = rubricModel.population.get(i);
                    htmlContents += '<td>';
                    var gradeText = '';
                    for (var k=0; k<rubricModel.assessment.count; k++) {
                        var gradeObj = rubricModel.assessment.get(k);
                        if ((gradeObj['individual'] == individualObj['identifier']) && (gradeObj['criterium'] == criteriumObj['identifier'])) {
                            gradeText = '<p>' + gradeObj['descriptor'] + '</p>';
                            gradeText += '<p>' + gradeObj['comment'] + '</p>';
                            gradeText += '<p>' + gradeObj['moment'] + '</p>';
                        }
                    }
                    htmlContents += gradeText;
                    htmlContents += '</td>';
                }

                htmlContents += '</tr>';
            }

            htmlContents += '</table>';

            htmlContents += "<h2>Criteris d'avaluació</h2>";
            htmlContents += '<p>Hi ha ' + rubricModel.criteria.count + " criteris d'avaluació.</p>";
            htmlContents += '<table>';
            htmlContents += '<tr><th>Identificador<th>Títol<th>Descripció<th>Pes<th>Ordre</tr>\n';
            for (var i=0; i<rubricModel.criteria.count; i++) {
                var criteriumObj = rubricModel.criteria.get(i);
                htmlContents += '<tr>';
                htmlContents += '<td>' + criteriumObj['identifier'] + '</td>\n';
                htmlContents += '<td>' + criteriumObj['title'] + '</td>\n';
                htmlContents += '<td>' + criteriumObj['description'] + '</td>\n';
                htmlContents += '<td>' + criteriumObj['weight'] + '</td>\n';
                htmlContents += '<td>' + criteriumObj['order'] + '</td>\n';
                htmlContents += '</tr>\n';
            }
            htmlContents += '</table>\n';

            htmlContents += "<h2>Descriptors de cada criteri</h2>";
            htmlContents += '<table>';
            htmlContents += "<tr><th>Criteri d'avaluació<th colspan=\"5\">Descriptors</tr>";
            for (var i=0; i<rubricModel.criteria.count; i++) {
                var criteriumObj = rubricModel.criteria.get(i);
                htmlContents += '<tr>';
                htmlContents += '<td rowspan="' + (criteriumObj['descriptors'].count+1) + '">';
                htmlContents += '<p>' + criteriumObj['identifier'] + '</p>';
                htmlContents += '<p>' + criteriumObj['title'] + '</p>';
                htmlContents += '<p>' + criteriumObj['description'] + '</p>';
                htmlContents += '<p>' + criteriumObj['weight'] + '</p>';
                htmlContents += '<p>' + criteriumObj['order'] + '</p>';
                htmlContents += '</td>';
                htmlContents += '<th>Identificador<th>Títol<th>Descripció<th>Nivell<th>Puntuació</tr>';

                for (var j=0; j<criteriumObj['descriptors'].count; j++) {
                    var descriptorObj = criteriumObj['descriptors'].get(j);
                    htmlContents += '<tr>';
                    htmlContents += '<td>' + descriptorObj['identifier'] + '</td>';
                    htmlContents += '<td>' + descriptorObj['title'] + '</td>';
                    htmlContents += '<td>' + descriptorObj['description'] + '</td>';
                    htmlContents += '<td>' + descriptorObj['level'] + '</td>';
                    htmlContents += '<td>' + descriptorObj['score'] + '</td>';
                    htmlContents += '</tr>';
                }
            }
            htmlContents += '</table>\n';


            htmlContents += "<h2>Població avaluable</h2>";
            htmlContents += '<p>Hi ha ' + rubricModel.population.count + " individus avaluables.</p>";
            htmlContents += '<table>';
            htmlContents += '<tr><th>Identificador<th>Grup<th>Nom<th>Llinatges<th>Imatge de cara</tr>\n';
            for (var i=0; i<rubricModel.population.count; i++) {
                var inidividualObj = rubricModel.population.get(i);
                htmlContents += '<tr>';
                htmlContents += '<td>' + inidividualObj['identifier'] + '</td>\n';
                htmlContents += '<td>' + inidividualObj['group'] + '</td>\n';
                htmlContents += '<td>' + inidividualObj['name'] + '</td>\n';
                htmlContents += '<td>' + inidividualObj['surname'] + '</td>\n';
                htmlContents += '<td>' + inidividualObj['faceImage'] + '</td>\n';
                htmlContents += '</tr>\n';
            }
            htmlContents += '</table>\n';

            htmlContents += "<h2>Historial d'avaluacions</h2>";
            htmlContents += '<p>Hi ha ' + rubricModel.assessment.count + " avaluacions enregistrades.</p>";
            htmlContents += '<table>';
            htmlContents += '<tr><th>Moment<th>Individu<th>Criteri<th>Descriptor<th>Comentari</tr>\n';
            for (var i=0; i<rubricModel.assessment.count; i++) {
                var gradeObj = rubricModel.assessment.get(i);
                htmlContents += '<tr>';
                htmlContents += '<td>' + gradeObj['moment'] + '</td>\n';
                htmlContents += '<td>' + gradeObj['individual'] + '</td>\n';
                htmlContents += '<td>' + gradeObj['criterium'] + '</td>\n';
                htmlContents += '<td>' + gradeObj['descriptor'] + '</td>\n';
                htmlContents += '<td>' + gradeObj['comment'] + '</td>\n';
                htmlContents += '</tr>\n';
            }
            htmlContents += '</table>\n';
            htmlContents += '</body></html>';
        }
    }

    Common.SteppedSection {
        ColumnLayout {
            anchors.fill: parent
            spacing: units.nailUnit
            Text {
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                font.pixelSize: units.readUnit
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: qsTr('Tria el nom del fitxer')
            }

            Editors.TextLineEditor {
                Layout.fillHeight: true
                Layout.fillWidth: true

                content: fileName

                onAccepted: {
                    fileName = content.trim();
                    rubricExportHtmlPage.moveForward();
                }
            }
        }
    }

    Common.SteppedSection {
        ColumnLayout {
            anchors.fill: parent
            spacing: units.nailUnit
            Text {
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                font.pixelSize: units.readUnit
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: qsTr('Tria la ubicació')
            }

            Files.FileSelector {
                Layout.fillHeight: true
                Layout.fillWidth: true

                onFolderSelected: {
                    folderName = folder;
                    rubricExportHtmlPage.moveForward();
                }
            }
        }
    }

    Common.SteppedSection {
        ColumnLayout {
            anchors.fill: parent
            spacing: units.nailUnit
            Text {
                Layout.fillHeight: true
                Layout.fillWidth: true
                text: qsTr("La rúbrica es desarà dins:")
            }
            Text {
                Layout.fillHeight: true
                Layout.fillWidth: true
                text: exportFile.source
            }
            Common.TextButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr('Exporta i desa')
                onClicked: {
                    if (exportFile.write(htmlContents))
                        rubricExportHtmlPage.close();
                }
            }
        }
        FileIO {
            id: exportFile

            source: folderName + '/' + fileName
        }
    }
}
