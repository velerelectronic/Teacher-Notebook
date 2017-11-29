import QtQuick 2.6

import 'qrc:///common' as Common
import 'qrc:///modules/suggestions' as Suggestions

Common.ThreePanesNavigator {
    id: filesystemBrowserBase

    property string selectedFile: ''

    firstPane: Common.NavigationPane {
        color: Qt.darker('yellow', 1.4)

        Gallery {
            anchors.fill: parent

            onFileSelected: {
                filesystemBrowserBase.selectedFile = file;
                filesystemBrowserBase.openPane(2);
            }
        }
    }

    secondPane: Common.NavigationPane {
        color: Qt.darker('yellow', 1.8)

        onClosePane: openPane(1)

        FileViewer {
            anchors.fill: parent

            fileURL: selectedFile
        }
    }

    thirdPane: Common.NavigationPane {
        color: 'yellow'

        onClosePane: annotationListAndShowItem.openPane(2)

        Suggestions.MainSuggester {
            anchors.fill: parent

            suggestionsEnabled: true
            onSelectedPage: {
                mainNavigator.addPage(page, parameters, qsTr('Suggerència'));
            }
        }
    }

}
