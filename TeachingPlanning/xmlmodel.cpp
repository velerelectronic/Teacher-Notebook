#include <QDebug>
#include <QVariantMap>
#include <QDomDocument>
#include <QDomElement>
#include "xmlmodel.h"

XmlModel::XmlModel(QObject *parent) :
    QAbstractListModel(parent)
{
}

XmlModel::XmlModel(const XmlModel &other) {
    innerTagName = other.innerTagName;
    innerRootElement = other.innerRootElement;
    innerRoles = other.innerRoles;
}

XmlModel::~XmlModel() {

}

int XmlModel::count() {
    return rowCount();
}

bool XmlModel::append(QVariantMap values) {
    beginInsertRows(this->createIndex(rowCount(),1).parent(),rowCount(),rowCount());
    QDomElement newElement = innerRootElement.ownerDocument().createElement(innerTagName);

    QVariantMap::const_iterator i;
    for (i = values.constBegin(); i != values.constEnd(); ++i) {
        newElement.setAttribute(i.key(), i.value().toString());
    }

    qDebug() << "inserted";
    qDebug() << newElement.attributes().size();
    innerRootElement.appendChild(newElement);
    endInsertRows();
    countChanged();
    return true;
}


QVariant XmlModel::data(const QModelIndex &index, int role = Qt::DisplayRole) const {
    // Select proper element QDomElement;
    QDomElement selectedElement = innerRootElement.elementsByTagName(innerTagName).at(index.row()).toElement();
    return QVariant(selectedElement.attribute(innerRoles[role]));
}

Qt::ItemFlags XmlModel::flags(const QModelIndex &index) const {
    return Qt::ItemIsSelectable | Qt::ItemIsEditable | Qt::ItemNeverHasChildren;
}

QVariantMap XmlModel::get(int index) {
    QVariantMap result;
    int i;
    for (i=Qt::UserRole+1; i<=Qt::UserRole+RolesNumber; i++) {
        result.insert(QString(innerRoles[i]), XmlModel::data(this->createIndex(index,i), i));
    }
    return result;
}

bool XmlModel::insertRows(int row, int count, const QModelIndex &parent) {
    return false;
}


bool XmlModel::removeRows(int row, int count, const QModelIndex &parent) {
    return false;
}


QHash <int, QByteArray> XmlModel::roleNames() const {
    return innerRoles;
}


/*
bool XmlModel::insertObject(int index,const QString &contents) {

}

bool XmlModel::removeObject(int index) {

}

bool XmlModel::updateObject(int index,const QString &contents) {

}
*/


QStringList XmlModel::roles() {

}

int XmlModel::rowCount(const QModelIndex &parent) const {
    int count = innerRootElement.elementsByTagName(innerTagName).count();
    return count;
}

bool XmlModel::setData(const QModelIndex &index, const QVariant &value, int role) {
    return false;
}

bool XmlModel::setHeaderData(int section, Qt::Orientation orientation, const QVariant &value, int role) {
    return false;
}

void XmlModel::setRoles(QStringList roles) {

}

void XmlModel::setRootElement(const QDomElement &newRoot) {
    innerRootElement = newRoot;
    countChanged();
}

void XmlModel::setTagName(const QString &newTagName) {
    innerTagName = newTagName;
    tagNameChanged(innerTagName);
}

const QString &XmlModel::tagName() {
    return innerTagName;
}
