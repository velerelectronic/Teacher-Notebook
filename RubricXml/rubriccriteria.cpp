#include <QDebug>

#include "rubricxml.h"
#include "rubriccriteria.h"
#include "rubricdescriptorsmodel.h"

RubricCriteria::RubricCriteria(RubricXml *parent) : QAbstractListModel(parent) {
    innerRubricXmlParent = parent;
}

RubricCriteria::RubricCriteria(const RubricCriteria &original) {
    innerRubricXmlParent = original.innerRubricXmlParent;
}

RubricCriteria::~RubricCriteria() {

}

bool RubricCriteria::append(QVariantMap values) {
    beginInsertRows(this->createIndex(rowCount(),1).parent(),rowCount(),rowCount());
    QDomElement newCriterium = innerRubricDomRoot.ownerDocument().createElement("criterium");

    qDebug() << values;

    QVariantMap::const_iterator i;
    for (i = values.constBegin(); i != values.constEnd(); ++i) {
        qDebug() << i.key() << i.value().toString() << "\n";
        newCriterium.setAttribute(i.key(), i.value().toString());
    }

    qDebug() << "inserted";
    qDebug() << newCriterium.attributes().size();
    innerRubricDomRoot.appendChild(newCriterium);
    qDebug() << innerRubricDomRoot.ownerDocument().toString();
    endInsertRows();
    countChanged();
    return true;
}

void RubricCriteria::setDomRoot(QDomElement domroot) {
    innerRubricDomRoot = domroot;
    countChanged();
}

int RubricCriteria::count() {
    return rowCount();
}

QVariant RubricCriteria::data(const QModelIndex &index, int role = Qt::DisplayRole) const {
    // Select proper criterium QDomElement;
    QDomElement selectedCriteriumDomElement = innerRubricDomRoot.elementsByTagName("criterium").at(index.row()).toElement();
    if (role == RubricCriteria::Descriptors) {
        RubricDescriptorsModel *innerDescriptorsModel;
        innerDescriptorsModel = new RubricDescriptorsModel();
        innerDescriptorsModel->setDomRoot(selectedCriteriumDomElement);
        return QVariant::fromValue(innerDescriptorsModel);
    } else {
        return QVariant(selectedCriteriumDomElement.attributeNode(fieldNameForRole(role)).value());
    }
}

RubricDescriptorsModel *RubricCriteria::descriptors(int index) {
    RubricDescriptorsModel *descriptorsModel = new RubricDescriptorsModel(this);
    descriptorsModel->setDomRoot(innerRubricDomRoot.elementsByTagName("criterium").at(index).toElement());
    return descriptorsModel;
}

Qt::ItemFlags RubricCriteria::flags(const QModelIndex &index) const {
    return Qt::ItemIsSelectable | Qt::ItemIsEditable | Qt::ItemNeverHasChildren;
}

QString RubricCriteria::fieldNameForRole(int role) const {
    switch (role) {
    case Title:
        return "title";
    case Description:
        return "desc";
    case Weight:
        return "weight";
    case Order:
        return "ord";
    case Descriptors:
        return "";
    default:
        return "";
    }
}

bool RubricCriteria::insertRows(int row, int count, const QModelIndex &parent) {
    return false;
}


bool RubricCriteria::removeRows(int row, int count, const QModelIndex &parent) {
    return false;
}

QHash <int, QByteArray> RubricCriteria::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[Title] = "title";
    roles[Description] = "description";
    roles[Weight] = "weight";
    roles[Order] = "order";
    roles[Descriptors] = "descriptors";
    return roles;
}

int RubricCriteria::rowCount(const QModelIndex &parent) const {
    int count = innerRubricDomRoot.elementsByTagName("criterium").count();
    qDebug() << "Row count" << count;
    return count;
}

bool RubricCriteria::setData(const QModelIndex &index, const QVariant &value, int role) {
    return false;
}

bool RubricCriteria::setHeaderData(int section, Qt::Orientation orientation, const QVariant &value, int role) {
    return false;
}
