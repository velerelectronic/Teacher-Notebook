#include <QDebug>
#include "xmlmodel.h"

XmlModel::XmlModel(QObject *parent) :
    QObject(parent)
{
    xmlQuery = QXmlQuery(QXmlQuery::XQuery10);
}

QString XmlModel::source() {
    return innerSource;
}

void XmlModel::setSource(QString &newSource) {
    innerSource = newSource;
    xmlQuery.setFocus(innerSource);
    sourceChanged(innerSource);
    recalculateList();
}

QString XmlModel::tagName() {
    return innerTagName;
}

void XmlModel::setTagName(QString &newTagName) {
    innerTagName = newTagName;
    // xmlQuery.bindVariable("tagname",&innerTagName);
    tagNameChanged(innerTagName);
    recalculateList();
}

QStringList XmlModel::list() {
    recalculateList();
    return innerList;
}

void XmlModel::setList(QStringList &) {

}

void XmlModel::recalculateList() {
    if (!innerTagName.isEmpty() && !innerSource.isEmpty()) {
        qDebug() << "Recalculant llista";
        xmlQuery.setQuery(".//" + innerTagName + "/string()");
        xmlQuery.evaluateTo(&innerList);
        qDebug() << "Llista " << innerList;
        listChanged(innerList);
    }
}
