#include "rubricpopulationmodel.h"
#include "rubricxml.h"

#include <QDebug>

RubricPopulationModel::RubricPopulationModel(QObject *parent) : QAbstractListModel(parent) {
    innerRoles[GroupName] = "group";
    innerRoles[Identifier] = "identifier";
    innerRoles[Name] = "name";
}

RubricPopulationModel::RubricPopulationModel(const RubricPopulationModel &original) {
    innerPopulationDomRoot = original.innerPopulationDomRoot;
}

RubricPopulationModel::~RubricPopulationModel() {

}

bool RubricPopulationModel::append(QVariantMap values) {
    beginInsertRows(this->createIndex(rowCount(),1).parent(),rowCount(),rowCount());
    QDomElement newIndividual = innerPopulationDomRoot.ownerDocument().createElement("individual");

    QVariantMap::const_iterator i;
    for (i = values.constBegin(); i != values.constEnd(); ++i) {
        qDebug() << i.key() << i.value().toString() << "\n";
        newIndividual.setAttribute(i.key(), i.value().toString());
    }

    innerPopulationDomRoot.appendChild(newIndividual);
    endInsertRows();
    countChanged();
    return true;
}

int RubricPopulationModel::count() {
    return rowCount();
}

QVariant RubricPopulationModel::data(const QModelIndex &index, int role) const {
    switch(role) {
    case GroupName:
        return QVariant(innerPopulationDomRoot.elementsByTagName("individual").at(index.row()).toElement().attribute("group"));
    case Identifier:
        return QVariant(innerPopulationDomRoot.elementsByTagName("individual").at(index.row()).toElement().attribute("identifier"));
    case Name:
        return QVariant(innerPopulationDomRoot.elementsByTagName("individual").at(index.row()).toElement().attribute("name"));
    default:
        return QVariant();
    }
}

Qt::ItemFlags RubricPopulationModel::flags(const QModelIndex &index) const {
    return Qt::ItemIsSelectable | Qt::ItemIsEditable | Qt::ItemNeverHasChildren;
}


QVariantMap RubricPopulationModel::get(int index) {
    QVariantMap result;
    int i;
    for (i=Qt::UserRole+1; i<=Qt::UserRole+3; i++) {
        result.insert(QString(innerRoles[i]), RubricPopulationModel::data(this->createIndex(index,i), i));
    }
    return result;
}

bool RubricPopulationModel::insertRows(int row, int count, const QModelIndex &parent) {
    return false;
}


bool RubricPopulationModel::removeRows(int row, int count, const QModelIndex &parent) {
    return false;
}

QHash <int, QByteArray> RubricPopulationModel::roleNames() const {
    return innerRoles;
}

int RubricPopulationModel::rowCount(const QModelIndex &parent) const {
    int count = innerPopulationDomRoot.elementsByTagName("individual").count();
    qDebug() << "Population count" << count;
    return count;
}

bool RubricPopulationModel::setData(const QModelIndex &index, const QVariant &value, int role) {
    QDomNodeList individuals = innerPopulationDomRoot.elementsByTagName("individual");
    QDomElement targetElement;
    if (individuals.count() > index.row()) {
        targetElement = individuals.at(index.row()).toElement();
    } else {
        targetElement.setTagName("individual");
        innerPopulationDomRoot.appendChild(targetElement);
    }
    QString attrName;
    switch(role) {
    case GroupName:
        attrName = QString("group");
        break;
    case Identifier:
        attrName = QString("identifier");
        break;
    case Name:
        attrName = QString("name");
        break;
    default:
        break;
    }

    targetElement.setAttribute(attrName, value.toString());
    return true;
}

void RubricPopulationModel::setDomRoot(QDomElement domroot) {
    innerPopulationDomRoot = domroot;
//    emit countChanged();
}

bool RubricPopulationModel::setHeaderData(int section, Qt::Orientation orientation, const QVariant &value, int role) {
    return false;
}

