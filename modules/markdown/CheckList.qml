import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2

Generic {
    id: checklistbase

    requiredWidth: width
    requiredHeight: innerParagraph.requiredHeight

    property string option
    property string text

    RowLayout {
        anchors.fill: parent

        CheckBox {
            Layout.fillHeight: true
            Layout.fillWidth: true

            checked: (option == 'x')
        }

        Paragraph {
            id: innerParagraph

            Layout.fillHeight: true
            Layout.fillWidth: true

            parameters: checklistbase.text
        }
    }
}
