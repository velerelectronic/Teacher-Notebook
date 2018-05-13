#include <QDebug>
#include "markdownitemmodel.h"

MarkDownItemModel::MarkDownItemModel(QObject *parent) : QAbstractListModel(parent)
{

}


QVariant MarkDownItemModel::data(const QModelIndex &index, int role = 0) const {
    if (index.row() < innerItems.length()) {
        switch(role) {
        case 1:
            return QVariant(innerItems.at(index.row()).getParameters());
            break;
        case 0:
        default:
            return QVariant(innerItems.at(index.row()).getType());
        }
    }
    else
        return QVariant();
}

Qt::ItemFlags MarkDownItemModel::flags(const QModelIndex &index) const {
    return Qt::ItemIsEditable;
}

int MarkDownItemModel::parseMarkDown(QString text) {
    qDebug() << "PARSING";
    beginRemoveRows(QModelIndex(), 0, innerItems.length());
    innerItems.clear();
    endRemoveRows();

    int relativePos = 0;
    while (relativePos > -1) {
        MarkDownItem item = mdParser.parseSingleToken(text, relativePos);
        beginInsertRows(QModelIndex(), innerItems.length(), innerItems.length()+1);
        innerItems.append(item);
        endInsertRows();
    }
    QVector<int> roles;
    roles.append(0);
    roles.append(1);
    qDebug() << "INNER ITEMS" << innerItems.length();
    dataChanged(index(0), index(innerItems.length()-1), roles);
}

QHash<int,QByteArray> MarkDownItemModel::roleNames() const {
    QHash<int,QByteArray> roles;
    roles[0] = QByteArray("type");
    roles[1] = QByteArray("parameters");
    return roles;
}

int MarkDownItemModel::rowCount(const QModelIndex &parent) const {
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
