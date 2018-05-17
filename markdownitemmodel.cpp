#include <QDebug>
#include "markdownitemmodel.h"

MarkDownItemModel::MarkDownItemModel(QObject *parent) : QAbstractListModel(parent)
{

}


QVariant MarkDownItemModel::data(const QModelIndex &index, int role) const {
    if (index.row() < innerItems.length()) {
        switch(role) {
        case ParametersRole:
            qDebug() << "VAR LIST";
            qDebug() << innerItems.at(index.row()).getType();
            qDebug() << innerItems.at(index.row()).getParameters();
            return QVariant(innerItems.at(index.row()).getParameters());
            break;
        case TextRole:
            return QVariant(innerItems.at(index.row()).getText());
        case TypeRole:
        default:
            return QVariant(innerItems.at(index.row()).getType());
        }
    }
    else
        return QVariant();
}

Qt::ItemFlags MarkDownItemModel::flags(const QModelIndex &index) const {
    return Qt::ItemIsEditable | Qt::ItemIsEnabled;
}

QVariant MarkDownItemModel::headerData(int section, Qt::Orientation orientation, int role) const {
    Q_UNUSED(section);

    if (orientation == Qt::Orientation::Vertical) {
        switch(role) {
        case MarkDownRoles::TypeRole:
            return QVariant("type");
        case MarkDownRoles::TextRole:
            return QVariant("text");
        case MarkDownRoles::ParametersRole:
            return QVariant("parameters");
        }
    } else {
        return QVariant();
    }
}

int MarkDownItemModel::parseMarkDown(QString text) {
    beginRemoveRows(QModelIndex(), 0, innerItems.length());
    innerItems.clear();
    endRemoveRows();

    int relativePos = 0;
    while (relativePos > -1) {
        MarkDownItem item = mdParser.parseSingleToken(text, relativePos);
        beginInsertRows(QModelIndex(), innerItems.length(), innerItems.length());
        innerItems.append(item);
        endInsertRows();
    }
    QVector<int> roles;
    roles.append(TextRole);
    roles.append(TypeRole);
    roles.append(ParametersRole);
    dataChanged(index(0), index(innerItems.length()-1), roles);
}

QHash<int,QByteArray> MarkDownItemModel::roleNames() const {
    QHash<int,QByteArray> roles;
    roles[TypeRole] = QByteArray("type");
    roles[TextRole] = QByteArray("text");
    roles[ParametersRole] = QByteArray("parameters");
    return roles;
}

int MarkDownItemModel::rowCount(const QModelIndex &parent) const {
    Q_UNUSED(parent);
    return innerItems.length();
}

bool MarkDownItemModel::setData(const QModelIndex &index, const QVariant &value, int role) {
    if (index.row() < innerItems.length()) {
        MarkDownItem item(value.toString(), 0);
        innerItems.replace(index.row(), item);
        QVector<int> roles;
        roles.append(0);
        roles.append(1);
        dataChanged(index, index, roles);
        return true;
    } else
        return false;
}
