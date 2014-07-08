#include <QDebug>
#include <QVariantMap>
#include "xmlmodel.h"

XmlModel::XmlModel(QObject *parent) :
    QObject(parent)
{
}

XmlModel::XmlModel(QObject *parent, const QDomElement &baseElement, const QString &tagname) :
    QObject(parent)
{
    setTagName(tagname);
    setRootElement(baseElement);
    recalculateList();
}

XmlModel::XmlModel(const XmlModel &other) {
    // Not sure about this fragment
    this->innerTagName = other.innerTagName;
    this->rootElement = other.rootElement;
    this->innerList = other.innerList;
}

XmlModel XmlModel::operator=(const XmlModel &other) {
// Not sure about this fragment
    this->innerTagName = other.innerTagName;
    this->rootElement = other.rootElement;
    this->innerList = other.innerList;
    return *this;
}

void XmlModel::setRootElement(const QDomElement &newRoot) {
    rootElement = newRoot;
}

// Tag name
const QString &XmlModel::tagName() {
    return innerTagName;
}

void XmlModel::setTagName(const QString &newTagName) {
    innerTagName = newTagName;
    tagNameChanged(innerTagName);
}


const QVariantList &XmlModel::list() {
    return innerList;
}

void XmlModel::setList(const QVariantList &) {

}

void XmlModel::recalculateList() {
    innerList.clear();
    if (innerTagName.isEmpty()) {
        QVariantMap obj;
        obj["text"] = rootElement.text();
        innerList.append(obj);
        listChanged(innerList);
    } else {
        QDomElement traverse = rootElement.firstChildElement(innerTagName);
        int i = 0;
        while (!traverse.isNull()) {
            QVariantMap obj;
            obj["text"] = traverse.text();
            qDebug() << obj["text"];
            innerList.append(obj);
            i++;
            traverse = traverse.nextSiblingElement(innerTagName);
        }
        listChanged(innerList);
        qDebug() << i;
    }
}
