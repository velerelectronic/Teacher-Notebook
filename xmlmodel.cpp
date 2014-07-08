#include <QDebug>
#include <QVariantMap>
#include "xmlmodel.h"

XmlModel::XmlModel(QObject *parent) :
    QObject(parent)
{
}

XmlModel::XmlModel(const XmlModel &other) {
    // Not sure about this fragment
    this->innerSource = other.innerSource;
    this->innerTagName = other.innerTagName;
    this->rootElement = other.rootElement;
}

XmlModel &XmlModel::operator=(const XmlModel &other) {
// Not sure about this fragment
    this->innerSource = other.innerSource;
    this->innerTagName = other.innerTagName;
    this->rootElement = other.rootElement;
    return *this;
}

XmlModel::~XmlModel() {

}

void XmlModel::setRootElement(const QDomElement &newRoot) {
    rootElement = newRoot;
    recalculateList();
}

QString XmlModel::source() {
    return innerSource;
}

void XmlModel::setSource(const QString &newSource) {
    innerSource = newSource;
    sourceChanged(innerSource);
    recalculateList();
}

QString XmlModel::tagName() {
    return innerTagName;
}

void XmlModel::setTagName(const QString &newTagName) {
    innerTagName = newTagName;
    tagNameChanged(innerTagName);
    recalculateList();
}

const QVariantList &XmlModel::list() {
    return innerList;
}

void XmlModel::setList(const QVariantList &) {

}

void XmlModel::recalculateList() {
    qDebug() << "recalculating... " << rootElement.tagName();
    QDomElement traverse = rootElement.firstChildElement(innerTagName);
    innerList.clear();
    int i = 0;
    while (!traverse.isNull()) {
        QVariantMap obj;
        obj["text"] = traverse.text();
        innerList.append(obj);
        i++;
        traverse = traverse.nextSiblingElement(innerTagName);
    }
    listChanged(innerList);
    qDebug() << i;
}
