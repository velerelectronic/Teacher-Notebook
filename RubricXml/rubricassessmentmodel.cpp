#include "rubricassessmentmodel.h"

#include <QDebug>
#include <QVariantMap>

RubricAssessmentModel::RubricAssessmentModel(RubricXml *parent) : QAbstractListModel(parent)
{
    innerRoles[Criterium] = "criterium";
    innerRoles[Individual] = "individual";
    innerRoles[Descriptor] = "descriptor";
    innerRoles[Comment] = "comment";
    innerRoles[Time] = "time";
}

RubricAssessmentModel::RubricAssessmentModel(const RubricAssessmentModel &original) {
    innerAssessmentDomRoot = original.innerAssessmentDomRoot;
    innerRoles = original.innerRoles;
}

RubricAssessmentModel::~RubricAssessmentModel() {

}

bool RubricAssessmentModel::append(QVariantMap values) {
    beginInsertRows(this->createIndex(rowCount(),1).parent(),rowCount(),rowCount());
    QDomElement newGradeElement = innerAssessmentDomRoot.ownerDocument().createElement("grade");

    QVariantMap::const_iterator i;
    for (i = values.constBegin(); i != values.constEnd(); ++i) {
        newGradeElement.setAttribute(i.key(), i.value().toString());
    }

    innerAssessmentDomRoot.appendChild(newGradeElement);
    endInsertRows();
    countChanged();
    return true;
}

int RubricAssessmentModel::count() {
    return rowCount();
}


QVariant RubricAssessmentModel::data(const QModelIndex &index, int role = Qt::DisplayRole) const {
    QString attribute;
    switch(role) {
    case Criterium:
        attribute = "criterium";
        break;
    case Individual:
        attribute = "individual";
        break;
    case Descriptor:
        attribute = "descriptor";
        break;
    case Comment:
        attribute = "comment";
        break;
    case Time:
        attribute = "time";
        break;
    default:
        break;
    }

    return QVariant(innerAssessmentDomRoot.elementsByTagName("grade").at(index.row()).toElement().attribute(attribute, ""));
}

Qt::ItemFlags RubricAssessmentModel::flags(const QModelIndex &index) const {
    return Qt::ItemIsSelectable | Qt::ItemIsEditable | Qt::ItemNeverHasChildren;
}

QVariantMap RubricAssessmentModel::get(int index) {
    QVariantMap result;
    int i;
    for (i=Qt::UserRole+1; i<=Qt::UserRole+5; i++) {
        result.insert(QString(innerRoles[i]), RubricAssessmentModel::data(this->createIndex(index,i), i));
    }
    qDebug() << "GET::" << result;
    return result;
}

bool RubricAssessmentModel::insertRows(int row, int count, const QModelIndex &parent) {
    return false;
}

QString RubricAssessmentModel::periodEnd() {
    return innerAssessmentDomRoot.attribute("from", "");
}

QString RubricAssessmentModel::periodStart() {
    return innerAssessmentDomRoot.attribute("to", "");
}

void RubricAssessmentModel::processXmlChanges() {
    countChanged();
    periodEndChanged();
    periodStartChanged();
}

bool RubricAssessmentModel::removeRows(int row, int count, const QModelIndex &parent) {
    return false;
}

QHash <int, QByteArray> RubricAssessmentModel::roleNames() const {
    return innerRoles;
}

int RubricAssessmentModel::rowCount(const QModelIndex &parent) const {
    int count = innerAssessmentDomRoot.elementsByTagName("grade").count();
    return count;
}

bool RubricAssessmentModel::setData(const QModelIndex &index, const QVariant &value, int role) {
    return false;
}

void RubricAssessmentModel::setDomRoot(QDomElement domroot) {
    innerAssessmentDomRoot = domroot;
    countChanged();
    periodEndChanged();
    periodStartChanged();
}

void RubricAssessmentModel::setPeriodEnd(QString end) {
    innerAssessmentDomRoot.setAttribute("periodEnd",end);
    periodEndChanged();
}

void RubricAssessmentModel::setPeriodStart(QString start) {
    innerAssessmentDomRoot.setAttribute("periodStart",start);
    periodStartChanged();
}

bool RubricAssessmentModel::setHeaderData(int section, Qt::Orientation orientation, const QVariant &value, int role) {
    return false;
}
