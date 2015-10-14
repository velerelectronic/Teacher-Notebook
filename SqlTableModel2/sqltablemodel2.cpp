#include "sqltablemodel2.h"

#include "sqltablemodel.h"

#include <QDebug>
#include <QSqlField>
#include <QSqlIndex>
#include <QSqlRecord>
#include <QSqlQuery>
#include <QMap>
#include <QSqlError>

SqlTableModel2::SqlTableModel2(QObject *parent) :
    QSqlQueryModel(parent)
{
    innerLimit=0;
    connect(this,SIGNAL(rowsInserted(QModelIndex,int,int)),this,SLOT(select()));
    connect(this,SIGNAL(rowsInserted(QModelIndex,int,int)),this,SLOT(debug()));
    connect(this,SIGNAL(rowsInserted(QModelIndex,int,int)),this,SIGNAL(updated()));
}

void SqlTableModel2::debug() {
//    qDebug() << "HHOOOLA";
}

QStringList SqlTableModel2::bindValues() const {
    return innerBindValues;
}

QSqlRecord SqlTableModel2::buildRecord(const QVariantMap &object,bool autoValue) {
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

int SqlTableModel2::count() {
    return QSqlQueryModel::rowCount();
}

QVariant SqlTableModel2::data(const QModelIndex &index, int role) const {

    QVariant value = QSqlQueryModel::data(index,role);

    if (role < Qt::UserRole)
        value = QSqlQueryModel::data(index, role);
    else {
        int columnIdx = role - Qt::UserRole - 1;
        QModelIndex modelIndex = this->index(index.row(), columnIdx);
        value = QSqlQueryModel::data(modelIndex, Qt::DisplayRole);
    }
    return value;
}

void SqlTableModel2::deselectAllObjects() {
    subselectedRows.clear();
    QModelIndex indexStart = this->createIndex(0,Qt::UserRole + columnCount() + 1);
    QModelIndex indexEnd = this->createIndex(rowCount(),Qt::UserRole + columnCount() + 1);
    this->dataChanged(indexStart,indexEnd);
}

const QStringList &SqlTableModel2::fieldNames() {
    return innerFieldNames;
}

QStringList &SqlTableModel2::filters() {
    return innerFilters;
}

void SqlTableModel2::generateRoleNames() {
    roles.clear();
    int nbCols = innerFieldNames.size();
    for (int i = 0; i < nbCols; i++) {
        roles[Qt::UserRole + i + 1] = innerFieldNames.at(i).toLocal8Bit();
    }
    roles[Qt::UserRole + nbCols + 1] = QByteArray("selected");
}

QVariantMap SqlTableModel2::getObject(QString key) const {
    QSqlRecord searchRecord;
    bool found = false;
    int row=0;

    qDebug() << "Searching for "  << key << " in " << rowCount() << " rows.";
    while ((!found) && (row<rowCount())) {
        searchRecord = this->record(row);
        qDebug() << searchRecord.value(innerPrimaryKey) << key;
        if (searchRecord.value(innerPrimaryKey)==key)
            found = true;
        else
            row++;
    }

    QVariantMap result;
    if (found) {
        for (int i=0; i<searchRecord.count(); i++) {
            result.insert(searchRecord.fieldName(i),searchRecord.value(i));
        }
    } else {
        qDebug() << "Not found";
    }

    return result;
}

QVariantMap SqlTableModel2::getObject(QString primaryField, QString key) const {
    QSqlRecord searchRecord;
    bool found = false;
    int row=0;
    while ((!found) && (row<rowCount())) {
        searchRecord = this->record(row);
        if (searchRecord.value(primaryField)==key)
            found = true;
        else
            row++;
    }

    QVariantMap result;
    if (found) {
        for (int i=0; i<searchRecord.count(); i++) {
            result.insert(searchRecord.fieldName(i),searchRecord.value(i));
        }
    } else {
        qDebug() << "Not found";
    }

    return result;
}

QVariantMap SqlTableModel2::getObjectInRow(int row) const {
    QSqlRecord rec = record(row);
    QVariantMap result;
    for (int i=0; i<rec.count(); i++) {
        result.insert(rec.fieldName(i),rec.value(i));
    }
    return result;
}

QString &SqlTableModel2::groupBy() {
    return innerGroupBy;
}

QVariant SqlTableModel2::insertObject(const QVariantMap &object) {
    qDebug() << "Object to insert: " << object;

    QStringList keys = object.keys();
    QStringList placeHolders;
    for (int i=0; i<object.size(); i++)
        placeHolders << "?";

    query().prepare("INSERT INTO " + innerTableName + "(" + keys.join(", ") + ") VALUES (" + placeHolders.join(",") + ")");

    QVariantMap::const_iterator values = object.cbegin();
    while ( values != object.cend()) {
        query().addBindValue(*values);
        ++values;
    }

    query().exec();

    QVariant lastId = query().lastInsertId();
    updated();
    return lastId;
}

bool SqlTableModel2::isSelectedObject(const int &row) {
    return subselectedRows.contains(row);
}
int SqlTableModel2::limit() {
    return innerLimit;
}

QString SqlTableModel2::primaryKey() {
    return innerPrimaryKey;
}

QString SqlTableModel2::reference() {
    return innerReference;
}

bool SqlTableModel2::removeObject(const QVariant &identifier) {
    QSqlQuery query;
    query.prepare("DELETE FROM " + innerTableName + " WHERE id=?");
    query.addBindValue(identifier);
    updated();
    return true;
}

int SqlTableModel2::removeSelectedObjects() {
    int i = 0;
    QMap<int,bool>::iterator row = subselectedRows.end();
    while (row != subselectedRows.begin()) {
        --row;
//        if (removeObjectInRow(row.key())) {
//            i++;
//            updated();
//        }
    }
    subselectedRows.clear();
    select();
    return i;
}

QHash<int, QByteArray> SqlTableModel2::roleNames() const {
    qDebug() << "Roles called" << roles;
    return roles;
}

int SqlTableModel2::searchRowWithKeyValue(const QVariant &value) {
    QSqlRecord searchRecord;
    int row=0;
    bool found = false;
    while ((!found) && (row<rowCount())) {
        searchRecord = this->record(row);
        if (searchRecord.value(innerPrimaryKey)==value)
            found = true;
        else
            row++;
    }
    return (found)?row:-1;
}

QStringList SqlTableModel2::searchFields() {
    return innerSearchFields;
}

QString SqlTableModel2::searchString() {
    return innerSearchString;
}

void SqlTableModel2::setPrimaryKey(const QString &key) {
    innerPrimaryKey = key;
    primaryKeyChanged();
}

bool SqlTableModel2::select() {
    deselectAllObjects();

    QStringList filtersList;

    // Attach the common filters
    if (filters().size()>0)
        filtersList << filters().join(" AND ");

    // Filter the search fields
    QStringList searchList;
    QStringList::const_iterator i = innerSearchFields.constBegin();
    while (i != innerSearchFields.constEnd()) {
        searchList << "INSTR(UPPER(" + *i + "),UPPER(?))";
        ++i;
    }
    filtersList << searchList.join(" OR ");

    QSqlQuery query;
    query.prepare("SELECT " + fieldNames().join(", ") + " FROM " + innerTableName + ((filtersList.size()>0)?" WHERE " + filtersList.join(" AND "):""));
    qDebug() << "Last query 1" << query.lastQuery();

    QStringList::const_iterator filtersValues = innerBindValues.constBegin();
    while (filtersValues != innerBindValues.constEnd()) {
        qDebug() << "Bind value" << *filtersValues;
        query.addBindValue(*filtersValues);
        ++filtersValues;
    }
    for (int j=0; j<innerSearchFields.size(); j++) {
        query.addBindValue(innerSearchString);
    }

    query.exec();
    setQuery(query);
    qDebug() << "Last query 2" << query.lastQuery();
    countChanged();
}

bool SqlTableModel2::selectUnique(QString field) {
    QSqlQueryModel::setQuery("SELECT DISTINCT " + field + " FROM " + innerTableName + " GROUP BY " + field);
    countChanged();
    return !query().lastError().isValid();
}

QStringList SqlTableModel2::selectDistinct(QString field,QString order,QString filter,bool ascending) {
/*
    QSqlQueryModel::setQuery("SELECT DISTINCT " + field + " FROM " + this->innerTableName + " ORDER BY " + order + " DESC ");
    qDebug() << "SDIST";
    qDebug() << this->query().lastQuery();
    countChanged();
    return !query().lastError().isValid();
*/

    QStringList vector;
    QSqlQuery query("SELECT DISTINCT " + field + " FROM " + this->innerTableName + ((filter != "")?(" WHERE " + filter):"") + " ORDER BY " + order + ((ascending)?" ASC":" DESC "));
//    qDebug() << query.executedQuery();
    bool iter = query.first();
    while (iter) {
//        qDebug() << ".";
        vector.append(query.record().value(0).toString());
        iter = query.next();
    }
    return vector;
}

void SqlTableModel2::selectObject(int row,bool activate) {
//    qDebug() << "Selecting object in " << row << " " << activate;
    if (activate)
        subselectedRows.insert(row,true);
    else
        subselectedRows.remove(row);
    QModelIndex index = this->createIndex(row,Qt::UserRole + columnCount() + 1);
    this->dataChanged(index,index);
}

void SqlTableModel2::setBindValues(const QStringList &bindValues) {
    innerBindValues = bindValues;
}

bool SqlTableModel2::setData(const QModelIndex &item, const QVariant &value, int role) {
//    query().prepare("UPDATE " + innerTableName)
    qDebug() << "Set data";
    return true;
}

void SqlTableModel2::setFieldNames(const QStringList &fields) {
    innerFieldNames = fields;
    generateRoleNames();
}

void SqlTableModel2::setFilters(const QStringList &filters) {
    innerFilters = filters;
    filtersChanged();
}

void SqlTableModel2::setGroupBy(const QString &group) {
    innerGroupBy = group;
    groupByChanged();
}

void SqlTableModel2::setLimit(int limit) {
    innerLimit = limit;
    limitChanged();
}

void SqlTableModel2::setReference(const QString &keyRef) {
    innerReference = keyRef;
    referenceChanged();
}

void SqlTableModel2::setSearchFields(const QStringList &fields) {
    innerSearchFields = fields;
    searchFieldsChanged();
}

void SqlTableModel2::setSearchString(const QString &search) {
    innerSearchString = search;
    searchStringChanged();
}

void SqlTableModel2::setSort(int column, Qt::SortOrder order) {
//    QSqlTableModel::setSort(column,order);
}

void SqlTableModel2::setTableName(const QString &tableName) {
    innerTableName = tableName;
    tableNameChanged();

    setSort(0,Qt::DescendingOrder);
}

const QString &SqlTableModel2::tableName() {
//    qDebug() << "Returning innerTableName " << innerTableName;
    return innerTableName;
}

bool SqlTableModel2::updateObject(const QVariantMap &object) {
/*
    qDebug() << "Field name" << this->primaryKey();
    int row = searchRowWithKeyValue(object.value(this->primaryKey().fieldName(0)));

    qDebug() << "Updating " << object;
    */
    bool result = false;
/*
    if (row>-1) {
        QSqlRecord record = buildRecord(object,false);
        result = updateRowInTable(row,record);
        qDebug() << lastError();
        selectRow(row);
        updated();
        select();
    }
    */
    return result;
}
