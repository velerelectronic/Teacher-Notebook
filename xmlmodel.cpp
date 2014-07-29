#include <QDebug>
#include <QVariantMap>
#include <QDomDocument>
#include "xmlmodel.h"

XmlModel::XmlModel(QObject *parent) :
    QStringListModel(parent)
{
}

XmlModel::XmlModel(const XmlModel &other) {
    innerTagName = other.innerTagName;
    rootElement = other.rootElement;
}

XmlModel::~XmlModel() {

}

XmlModel &XmlModel::operator=(XmlModel &other) {
// Not sure about this fragment
    // this->QStringListModel::operator=(other);
    // this->innerTagName = other.innerTagName;
    // this->rootElement = other.rootElement;
    return *this;
}

void XmlModel::print() {
    qDebug() << stringList();
}

void XmlModel::recalculateList() {
    QStringList innerList;

    if (innerTagName.isEmpty()) {
        innerList << rootElement.text();
    } else {
        QDomElement traverse = rootElement.firstChildElement(innerTagName);
        int i = 0;
        while (!traverse.isNull()) {
            innerList << traverse.text();
            i++;
            traverse = traverse.nextSiblingElement(innerTagName);
        }
    }
    setStringList(innerList);
}

void XmlModel::recalculateDomElement() {
    QStringList innerList = stringList();
    QDomDocument document = rootElement.ownerDocument();
    rootElement.clear();
    QStringList::const_iterator index = innerList.constBegin();
    while (index != innerList.constEnd()) {
        rootElement.appendChild(document.createElement(innerTagName).appendChild(document.createTextNode(*index)));
        ++index;
    }
}

void XmlModel::setRootElement(const QDomElement &newRoot) {
    rootElement = newRoot;
}

void XmlModel::setTagName(const QString &newTagName) {
    innerTagName = newTagName;
    tagNameChanged(innerTagName);
}

const QString &XmlModel::tagName() {
    return innerTagName;
}

bool XmlModel::toDomElement(const QString &tagName) {
    setTagName(tagName);
    recalculateDomElement();
}

XmlModel *XmlModel::readList(const QDomElement &baseElement, const QString &tagname) {
    setTagName(tagname);
    setRootElement(baseElement);
    recalculateList();
    return this;
}
