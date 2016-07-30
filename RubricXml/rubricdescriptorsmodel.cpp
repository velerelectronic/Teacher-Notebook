#include <QDebug>

#include "rubricdescriptorsmodel.h"
#include "rubricxml.h"
#include "rubriccriteria.h"

RubricDescriptorsModel::RubricDescriptorsModel(QAbstractListModel *parent) : QAbstractListModel(parent) {
    innerRoles[Title] = "title";
    innerRoles[Description] = "description";
    innerRoles[Level] = "level";
    innerRoles[Definition] = "definition";
    innerRoles[Score] = "score";
    innerRoles[Identifier] = "identifier";
}

RubricDescriptorsModel::RubricDescriptorsModel(const RubricDescriptorsModel &original) {
    innerCriteriumDomRoot = original.innerCriteriumDomRoot;
}

RubricDescriptorsModel::~RubricDescriptorsModel() {

}

bool RubricDescriptorsModel::append(QVariantMap values) {
    beginInsertRows(this->createIndex(rowCount(),1).parent(),rowCount(),rowCount());
    QDomElement newDescriptor = innerCriteriumDomRoot.ownerDocument().createElement("descriptor");

    qDebug() << values;

    QVariantMap::const_iterator i;
    for (i = values.constBegin(); i != values.constEnd(); ++i) {
        qDebug() << i.key() << i.value().toString() << "\n";
        newDescriptor.setAttribute(i.key(), i.value().toString());
    }

    qDebug() << "inserted";
    qDebug() << newDescriptor.attributes().size();
    innerCriteriumDomRoot.appendChild(newDescriptor);
    qDebug() << innerCriteriumDomRoot.ownerDocument().toString();
    endInsertRows();
    countChanged();
    return true;

}

int RubricDescriptorsModel::count() {
    return rowCount();
}

QVariant RubricDescriptorsModel::data(const QModelIndex &index, int role = Qt::DisplayRole) const {
    return QVariant(innerCriteriumDomRoot.elementsByTagName("descriptor").at(index.row()).toElement().attributeNode(fieldNameForRole(role)).value());
}

Qt::ItemFlags RubricDescriptorsModel::flags(const QModelIndex &index) const {
    return Qt::ItemIsSelectable | Qt::ItemIsEditable | Qt::ItemNeverHasChildren;
}

QString RubricDescriptorsModel::fieldNameForRole(int role) const {
    switch (role) {
    case Identifier:
        return "identifier";
    case Title:
        return "title";
    case Description:
        return "description";
    case Level:
        return "level";
    case Definition:
        return "definition";
    case Score:
        return "score";
    default:
        return "";
    }
}

QVariantMap RubricDescriptorsModel::get(int index) {
    QVariantMap result;
    int i;
    for (i=Qt::UserRole+1; i<=Qt::UserRole+6; i++) {
        result.insert(QString(innerRoles[i]), RubricDescriptorsModel::data(this->createIndex(index,i), i));
    }
    return result;
}


bool RubricDescriptorsModel::insertRows(int row, int count, const QModelIndex &parent) {
    return false;
}


bool RubricDescriptorsModel::removeRows(int row, int count, const QModelIndex &parent) {
    return false;
}

QHash <int, QByteArray> RubricDescriptorsModel::roleNames() const {
    return innerRoles;
}

int RubricDescriptorsModel::rowCount(const QModelIndex &parent) const {
    int count = innerCriteriumDomRoot.elementsByTagName("descriptor").count();
    qDebug() << "Row count" << count;
    return count;
}

bool RubricDescriptorsModel::setData(const QModelIndex &index, const QVariant &value, int role) {
    return false;
}

void RubricDescriptorsModel::setDomRoot(QDomElement domroot) {
    innerCriteriumDomRoot = domroot;
//    emit countChanged();
}

bool RubricDescriptorsModel::setHeaderData(int section, Qt::Orientation orientation, const QVariant &value, int role) {
    return false;
}
