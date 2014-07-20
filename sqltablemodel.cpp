#include "sqltablemodel.h"

#include <QDebug>
#include <QSqlRecord>
#include <QSqlField>
#include <QSqlIndex>
#include <QMap>
#include <QSqlError>

SqlTableModel::SqlTableModel(QObject *parent, QSqlDatabase db) :
    QSqlRelationalTableModel(parent,db)
{
    connect(this,SIGNAL(rowsInserted(QModelIndex,int,int)),this,SLOT(select()));
}

const QStringList &SqlTableModel::fieldNames() {
    return innerFieldNames;
}

const QString &SqlTableModel::filter() {
    return QSqlRelationalTableModel::filter();
}

const QString &SqlTableModel::tableName() {
    return innerTableName;
}

bool SqlTableModel::setData(const QModelIndex &item, const QVariant &value, int role) {
    qDebug() << "Set data";
    return true;
}

void SqlTableModel::setFieldNames(QStringList fields) {
    innerFieldNames = fields;
    fieldNamesChanged();
}

void SqlTableModel::setFilter(const QString &filter) {
    QSqlRelationalTableModel::setFilter(filter);
}

void SqlTableModel::setTableName(const QString &tableName) {
    innerTableName = tableName;
    setTable(tableName);
    generateRoleNames();
    tableNameChanged();

    setEditStrategy(QSqlTableModel::OnFieldChange);
    setSort(1,Qt::DescendingOrder);
    setFilter("");
}


QVariant SqlTableModel::data(const QModelIndex &index, int role) const {
    if (index.row() >= rowCount())
        return QString("");

    if (role < Qt::UserRole)
        return QSqlQueryModel::data(index, role);
    else {
        // search for relationships
        for (int i = 0; i < columnCount(); i++) {
            if (this->relation(i).isValid()) {
                return record(index.row()).value(QString(roles.value(role)));
            }
        }
        // if no valid relationship was found
        return QSqlQueryModel::data(this->index(index.row(), role - Qt::UserRole - 1), Qt::DisplayRole);
    }
}

QHash<int, QByteArray> SqlTableModel::roleNames() const {
    return roles;
}

QVariantMap SqlTableModel::getObject(QString key) const {
    QSqlRecord searchRecord;
    bool found = false;
    int row=0;
    while ((!found) && (row<rowCount())) {
        searchRecord = this->record(row);
        qDebug() << primaryKey().fieldName(0);
        if (searchRecord.value(primaryKey().fieldName(0))==key)
            found = true;
        else
            row++;
    }

    QVariantMap result;
    if (found) {
        for (int i=0; i<searchRecord.count(); i++) {
            result.insert(searchRecord.fieldName(i),searchRecord.value(i));
        }
    }

    return result;
}

bool SqlTableModel::insertObject(const QVariantMap &object) {
    QSqlRecord record;
    QVariantMap::const_iterator i = object.constBegin();
    while (i != object.constEnd()) {
        QSqlField field(i.key(),QVariant::String);
        field.setValue(i.value());
        record.append(field);
        ++i;
    }
    QSqlField idfield("id",QVariant::Int);
    idfield.setAutoValue(true);
    record.append(idfield);
    bool result = insertRowIntoTable(record);
    select();
    return result;
}

int SqlTableModel::searchRecordWithKey(const QVariantMap &object) {
    QSqlRecord searchRecord;
    int row=0;
    bool found = false;
    while ((!found) && (row<rowCount())) {
        searchRecord = this->record(row);
        QString pk = primaryKey().fieldName(0);
        if (searchRecord.value(pk)==object[pk])
            found = true;
        else
            row++;
    }
    return (found)?row:-1;
}

bool SqlTableModel::removeObject(int row) {
    return removeRows(row,1);
}

bool SqlTableModel::removeObject(QVariantMap &object) {
    int row = searchRecordWithKey(object);
    if (row>-1)
        return removeRows(row,1);
    else
        return false;
}

bool SqlTableModel::select() {
    qDebug() << "Select";
    return QSqlRelationalTableModel::select();
}

bool SqlTableModel::updateObject(const QVariantMap &object) {
    int row = searchRecordWithKey(object);
    bool result = false;
    if (row>-1) {
        qDebug() << "Updating";
        QSqlRecord record;
        QVariantMap::const_iterator i = object.constBegin();
        while (i != object.constEnd()) {
            QSqlField field(i.key(),QVariant::String);
            field.setValue(i.value());
            record.append(field);
            ++i;
        }
//        QSqlField idfield("id",QVariant::Int);
//        idfield.setAutoValue(true);
//        record.append(idfield);
        qDebug() << record;
        result = updateRowInTable(row,record);
        selectRow(row);
        select();
    }
    return result;
}

void SqlTableModel::generateRoleNames() {
    qDebug() << "Defining role names";
    roles.clear();
    qDebug() << this->columnCount();
    int nbCols = this->columnCount();
    for (int i = 0; i < nbCols; i++) {
        roles[Qt::UserRole + i + 1] = QVariant(this->headerData(i, Qt::Horizontal).toString()).toByteArray();
    }
#ifndef HAVE_QT5
//    setRoleNames(roles);
#endif

}
