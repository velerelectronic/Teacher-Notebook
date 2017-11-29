import QtQuick 2.6

import 'qrc:///common' as Common
import 'qrc:///modules/suggestions' as Suggestions

Common.ThreePanesNavigator {
    id: annotationListAndShowItem

    property int selectedAnnotation: -1

    firstPane: Common.NavigationPane {
        color: Qt.darker('yellow', 1.4)

        AnnotationsList {
            previewEnabled: false

            onAnnotationSelected: {
                selectedAnnotation = annotation;
                openPane(2);
            }
        }
    }

    secondPane: Common.NavigationPane {
        color: Qt.darker('yellow', 1.8)

        onClosePane: annotationListAndShowItem.openPane(1)

        ShowAnnotation {
            id: showAnnotationItem

            identifier: selectedAnnotation

            onIdentifierChanged: getText()
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
