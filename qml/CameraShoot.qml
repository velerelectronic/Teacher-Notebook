import QtQuick 2.5
import 'qrc:///common' as Common

Common.CameraShoot {
    signal closePage(string message)

    onCloseCamera: closePage('')
}
