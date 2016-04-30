import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors

Editors.TextAreaEditor3 {
    property var annotationContent

    onContentChanged: {
        annotationContent = {desc: content};
    }
}
