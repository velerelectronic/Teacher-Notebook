#include "rubricassessmentmodel.h"

RubricAssessmentModel::RubricAssessmentModel(RubricXml *parent) : QAbstractListModel(parent)
{

}

RubricAssessmentModel::RubricAssessmentModel(const RubricAssessmentModel &original) {
    innerAssessmentDomRoot = original.innerAssessmentDomRoot;
}

RubricAssessmentModel::~RubricAssessmentModel() {

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
    case Level:
        attribute = "level";
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

bool RubricAssessmentModel::insertRows(int row, int count, const QModelIndex &parent) {
    return false;
}

QString RubricAssessmentModel::periodEnd() {
    return innerAssessmentDomRoot.attribute("from", "");
}

QString RubricAssessmentModel::periodStart() {
    return innerAssessmentDomRoot.attribute("to", "");
}

bool RubricAssessmentModel::removeRows(int row, int count, const QModelIndex &parent) {
    return false;
}

QHash <int, QByteArray> RubricAssessmentModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[Criterium] = "criterium";
    roles[Individual] = "individual";
    roles[Level] = "level";
    roles[Comment] = "comment";
    roles[Time] = "time";
    return roles;
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

}

void RubricAssessmentModel::setPeriodStart(QString start) {

}

bool RubricAssessmentModel::setHeaderData(int section, Qt::Orientation orientation, const QVariant &value, int role) {
    return false;
}
