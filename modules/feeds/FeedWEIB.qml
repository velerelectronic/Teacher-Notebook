import QtQuick 2.0
import QtQuick.XmlListModel 2.0

FeedView {
    property string pageTitle: qsTr('Web Educatiu Illes Balears')
    model: feedModel
    formatSectionDate: true

    feedDelegate: FeedDelegate {
        width: parent.width
        textTitol: titol
        textContingut: contingut
        enllac: urlAlternate
        index: model.index
    }

    CachedModel {
        id: cachedModel

        source: 'http://weib.caib.es/Novetats/index.rss'
        categoria: 'weib'
        typeFiltra: false
    }

    XmlListModel {
        id: feedModel
        query: '/rss/channel/item'
//        namespaceDeclarations: "declare default element namespace 'http://www.w3.org/2005/Atom';"
        xml: cachedModel.contents

        XmlRole { name: 'titol'; query: 'title/string()' }
        XmlRole { name: 'contingut'; query: 'description/string()' }
        XmlRole { name: 'updated'; query: 'updated/string()' }
        XmlRole { name: 'publicat'; query: 'published/string()' }
        XmlRole { name: 'grup'; query: 'published/substring-before(string(),"T")' }
        XmlRole { name: 'urlAlternate'; query: "link[@rel='alternate']/@href/string()" }
    }

    onReload: cachedModel.llegeixOnline()

}
