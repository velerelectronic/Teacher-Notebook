#include <QDebug>
#include <QVariantMap>
#include <QDomDocument>
#include <QDomElement>
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

int XmlModel::count() {
    return rowCount();
}

bool XmlModel::insertObject(int index, const QString &contents) {
    QStringList list = stringList();
    if ((index >= 0) && (index <= list.size())) {
        list.insert(index,contents);
        setStringList(list);
        return true;
    } else
        return false;
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

XmlModel *XmlModel::readList(const QDomElement &baseElement, const QString &tagname) {
    if ((innerTagName != tagname) || (rootElement != baseElement)) {
        setTagName(tagname);
        setRootElement(baseElement);
        recalculateList();
    }
    return this;
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

    // Remove all child elements
    qDebug() << innerTagName;
    QDomElement element = rootElement.firstChildElement(innerTagName);
    while (!element.isNull()) {
        qDebug() << !rootElement.removeChild(element).isNull();
        element = rootElement.firstChildElement(innerTagName);
    }

    qDebug() << rootElement.childNodes().length();

    QStringList::const_iterator index = innerList.constBegin();
    while (index != innerList.constEnd()) {
        QDomElement newElement = document.createElement(innerTagName);
        rootElement.appendChild(newElement).appendChild(document.createTextNode(*index));
        ++index;
    }
    //qDebug() << rootElement.ownerDocument().toString();
    updated();
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

bool XmlModel::toDomElement() {
    recalculateDomElement();
}

bool XmlModel::updateObject(int index, const QString &contents) {
    QModelIndex i = this->createIndex(index,0);
    bool res = setData(i,contents,Qt::DisplayRole);
    return res;
}
