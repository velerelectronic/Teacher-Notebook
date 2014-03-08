import QtQuick 2.0
import QtWebKit 3.0
import FileIO 1.0

Rectangle {
    id: xmlViewer
    property string pageTitle: qsTr('Visor XML');
    width: 100
    height: 62
    FileIO {
        id: myFile
        source: '/Users/jmpayeras/Dropbox/Esquirol/MA 1r UD 01 - Nombres naturals.html'
        onError: console.log(msg)
    }

    WebView {
        id: webview
        anchors.fill: parent
        Component.onCompleted: {
            // webview.url = 'file:///Users/jmpayeras/Dropbox/Esquirol/MA%201r%20UD%2001%20-%20Nombres%20naturals.html'
            console.log(myFile.read())
            var doc = XMLHttpRequest();
            doc.open('get','file:///Users/jmpayeras/Dropbox/Esquirol/MA%201r%20UD%2001%20-%20Nombres%20naturals.html',false);
            if (doc.readyState==XMLHttpRequest.DONE) {
                var root = doc.responseXML.documentElement;
                console.log(root.innerHTML);
            }
        }
    }
}
