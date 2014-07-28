#include "sqltablemodel.h"

#include <QDebug>
#include <QSqlField>
#include <QSqlIndex>
#include <QSqlRecord>
#include <QSqlQuery>
#include <QMap>
#include <QSqlError>

SqlTableModel::SqlTableModel(QObject *parent, QSqlDatabase db) :
    QSqlRelationalTableModel(parent,db)
{
    setEditStrategy(QSqlTableModel::OnRowChange);
    innerLimit=0;
    connect(this,SIGNAL(rowsInserted(QModelIndex,int,int)),this,SLOT(select()));
}

QSqlRecord SqlTableModel::buildRecord(const QVariantMap &object,bool autoValue) {
    QSqlRecord record;
    QVariantMap::const_iterator i = object.constBegin();
    while (i != object.constEnd()) {
        QSqlField field(i.key(),QVariant::String);
        field.setValue(i.value());
        record.append(field);
        ++i;
    }
    if (autoValue) {
        QSqlField idfield("id",QVariant::Int);
        idfield.setAutoValue(true);
        idfield.setGenerated(false);
        record.append(idfield);
    }
    return record;
}

int SqlTableModel::count() {
    return rowCount();
}

QVariant SqlTableModel::data(const QModelIndex &index, int role) const {
    if (index.row() >= rowCount())
        return QString("");

    if (role < Qt::UserRole)
        return QSqlQueryModel::data(index, role);
    else {
        // search for relationships
        int nbCols = columnCount();

        if (role == Qt::UserRole + nbCols + 1) {
            return subselectedRows.contains(index.row());
        } else {
            for (int i = 0; i < nbCols; i++) {
                if (this->relation(i).isValid()) {
                    return record(index.row()).value(QString(roles.value(role)));
                }
            }
            // if no valid relationship was found
            return QSqlQueryModel::data(this->index(index.row(), role - Qt::UserRole - 1), Qt::DisplayRole);
        }
    }
}

void SqlTableModel::deselectAllObjects() {
    subselectedRows.clear();
    QModelIndex indexStart = this->createIndex(0,Qt::UserRole + columnCount() + 1);
    QModelIndex indexEnd = this->createIndex(rowCount(),Qt::UserRole + columnCount() + 1);
    this->dataChanged(indexStart,indexEnd);
}

const QStringList &SqlTableModel::fieldNames() {
    return innerFieldNames;
}

QStringList &SqlTableModel::filters() {
    return innerFilters;
}

void SqlTableModel::generateRoleNames() {
    roles.clear();
    int nbCols = this->columnCount();
    for (int i = 0; i < nbCols; i++) {
        roles[Qt::UserRole + i + 1] = QVariant(this->headerData(i, Qt::Horizontal).toString()).toByteArray();
    }
    roles[Qt::UserRole + nbCols + 1] = QByteArray("selected");

#ifndef HAVE_QT5
//    setRoleNames(roles);
#endif

}

QVariantMap SqlTableModel::getObject(QString key) const {
    QSqlRecord searchRecord;
    bool found = false;
    int row=0;
    while ((!found) && (row<rowCount())) {
        searchRecord = this->record(row);
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
    qDebug() << "Object to insert: " << object;
    QSqlRecord record = buildRecord(object,true);
    qDebug() << record;
    qDebug() << record.field("id").isAutoValue();
    bool result = insertRowIntoTable(record); // Append the record
    qDebug() << lastError();
    select();
    return result;
}

bool SqlTableModel::isSelectedObject(const int &row) {
    return subselectedRows.contains(row);
}
int SqlTableModel::limit() {
    return innerLimit;
}

QString SqlTableModel::reference() {
    return innerReference;
}

bool SqlTableModel::removeObjectInRow(int row) {
    return removeRows(row,1);
}

bool SqlTableModel::removeObjectWithKeyValue(const QVariant &value) {
    int row = searchRowWithKeyValue(value);

    if (row>-1)
        return removeRows(row,1);
    else
        return false;
}

int SqlTableModel::removeSelectedObjects() {
    int i = 0;
    QMap<int,bool>::iterator row = subselectedRows.end();
    while (row != subselectedRows.begin()) {
        --row;
        if (removeObjectInRow(row.key()))
            i++;
    }
    subselectedRows.clear();
    select();
    return i;
}

QHash<int, QByteArray> SqlTableModel::roleNames() const {
    return roles;
}

int SqlTableModel::searchRowWithKeyValue(const QVariant &value) {
    QSqlRecord searchRecord;
    int row=0;
    bool found = false;
    while ((!found) && (row<rowCount())) {
        searchRecord = this->record(row);
        QString pk = primaryKey().fieldName(0);
        if (searchRecord.value(pk)==value)
            found = true;
        else
            row++;
    }
    return (found)?row:-1;
}

QStringList SqlTableModel::searchFields() {
    return innerSearchFields;
}

QString SqlTableModel::searchString() {
    return innerSearchString;
}

bool SqlTableModel::select() {
    deselectAllObjects();
    qDebug() << "Se seleccionara" << selectStatement();

    if (innerLimit==0) {
        bool res = QSqlRelationalTableModel::select();
        countChanged();
        return res;
    } else {
        QSqlQueryModel::setQuery(selectStatement() + " LIMIT " + QString::number(innerLimit));
        countChanged();
        qDebug() << query().lastError();
        return !query().lastError().isValid();
    }
}

void SqlTableModel::selectObject(int row,bool activate) {
    qDebug() << "Selecting object in " << row << " " << activate;
    if (activate)
        subselectedRows.insert(row,true);
    else
        subselectedRows.remove(row);
    QModelIndex index = this->createIndex(row,Qt::UserRole + columnCount() + 1);
    this->dataChanged(index,index);
}

bool SqlTableModel::setData(const QModelIndex &item, const QVariant &value, int role) {
    qDebug() << "Set data";
    return true;
}

void SqlTableModel::setFieldNames(const QStringList &fields) {
    innerFieldNames = fields;
}

void SqlTableModel::setFilters(const QStringList &filters) {
    innerFilters = filters;
    filtersChanged();
    setInnerFilters();
}

void SqlTableModel::setInnerFilters() {
    QStringList filterList;

    // Filter the reference
    if (!innerReference.isEmpty()) {
        QString key = QSqlTableModel::primaryKey().field(0).name();
        filterList << key + "='" + innerReference + "'";
    }

    // Filter the inner filters
    filterList << innerFilters;

    // Filter the search fields
    if (!innerSearchString.isEmpty()) {
        QString ff("0=1");
        QStringList::const_iterator i = innerSearchFields.constBegin();
        while (i != innerSearchFields.constEnd()) {
            ff += " OR instr(UPPER(" + *i + "),UPPER('" + innerSearchString + "'))";
            ++i;
        }
        filterList << ff;
    }

    // Set all filters toghether
    QString fieldFilter;

    if (!filterList.isEmpty()) {
        fieldFilter.append(filterList.join(") AND ("));

        if (filterList.count()>1)
            fieldFilter.prepend("(").append(")");
    }

    QSqlTableModel::setFilter(fieldFilter);
}

void SqlTableModel::setLimit(int limit) {
    innerLimit = limit;
    limitChanged();
}

void SqlTableModel::setReference(const QString &keyRef) {
    innerReference = keyRef;
    referenceChanged();
    setInnerFilters();
}

void SqlTableModel::setSearchFields(const QStringList &fields) {
    innerSearchFields = fields;
    searchFieldsChanged();
    setInnerFilters();
}

void SqlTableModel::setSearchString(const QString &search) {
    innerSearchString = search;
    searchStringChanged();
    setInnerFilters();
}

void SqlTableModel::setSort(int column, Qt::SortOrder order) {
    QSqlTableModel::setSort(column,order);
}

void SqlTableModel::setTableName(const QString &tableName) {
    innerTableName = tableName;
    setTable(tableName);
    generateRoleNames();
    tableNameChanged();

    setSort(0,Qt::DescendingOrder);
}

const QString &SqlTableModel::tableName() {
    return innerTableName;
}

bool SqlTableModel::updateObject(const QVariantMap &object) {
    int row = searchRowWithKeyValue(object.value(this->primaryKey().fieldName(0)));

    bool result = false;
    if (row>-1) {
        QSqlRecord record = buildRecord(object,false);
        result = updateRowInTable(row,record);
        selectRow(row);
        select();
    }
    return result;
}
