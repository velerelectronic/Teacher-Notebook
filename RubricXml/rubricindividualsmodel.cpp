#include "rubricxml.h"
#include "rubricindividualsmodel.h"

#include <QDebug>

RubricIndividualsModel::RubricIndividualsModel(QObject *parent) : QAbstractListModel(parent) {

}

RubricIndividualsModel::RubricIndividualsModel(const RubricIndividualsModel &original) {
    innerGroupDomRoot = original.innerGroupDomRoot;
    innerGroupName = original.innerGroupName;
}

RubricIndividualsModel::~RubricIndividualsModel() {

}

int RubricIndividualsModel::count() {
    return rowCount();
}

QVariant RubricIndividualsModel::data(const QModelIndex &index, int role) const {
    switch(role) {
    case GroupName:
        return QVariant(innerGroupName);
    case Identifier:
        return QVariant(innerGroupDomRoot.elementsByTagName("individual").at(index.row()).toElement().attributeNode("id").value());
    case Name:
        return QVariant(innerGroupDomRoot.elementsByTagName("individual").at(index.row()).toElement().attributeNode("name").value());
    default:
        return QVariant();
    }
}

Qt::ItemFlags RubricIndividualsModel::flags(const QModelIndex &index) const {
    return Qt::ItemIsSelectable | Qt::ItemIsEditable | Qt::ItemNeverHasChildren;
}

QString RubricIndividualsModel::groupName() {
    return innerGroupName;
}

bool RubricIndividualsModel::insertRows(int row, int count, const QModelIndex &parent) {
    return false;
}


bool RubricIndividualsModel::removeRows(int row, int count, const QModelIndex &parent) {
    return false;
}

QHash <int, QByteArray> RubricIndividualsModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[GroupName] = "groupName";
    roles[Identifier] = "identifier";
    roles[Name] = "name";
    return roles;
}

int RubricIndividualsModel::rowCount(const QModelIndex &parent) const {
    int count = innerGroupDomRoot.elementsByTagName("individual").count();
    qDebug() << "individuals count" << count;
    return count;
}

bool RubricIndividualsModel::setData(const QModelIndex &index, const QVariant &value, int role) {
    return false;
}

void RubricIndividualsModel::setDomRoot(QDomElement domroot) {
    innerGroupDomRoot = domroot;
    innerGroupName = domroot.attribute("name", "");
//    emit countChanged();
}

bool RubricIndividualsModel::setHeaderData(int section, Qt::Orientation orientation, const QVariant &value, int role) {
    return false;
}

void RubricIndividualsModel::setGroupName(QString name) {
    innerGroupName = name;
}
