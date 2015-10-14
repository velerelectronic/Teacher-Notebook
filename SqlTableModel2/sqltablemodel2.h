#ifndef SQLTABLEMODEL2_H
#define SQLTABLEMODEL2_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlRelationalTableModel>
#include <QSqlQueryModel>
#include <QVariantMap>
#include <QMap>

class SqlTableModel2 : public QSqlQueryModel
{
    Q_OBJECT

    Q_PROPERTY(QStringList bindValues READ bindValues WRITE setBindValues NOTIFY bindValuesChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QStringList fieldNames READ fieldNames WRITE setFieldNames NOTIFY fieldNamesChanged)
    Q_PROPERTY(QStringList filters READ filters WRITE setFilters NOTIFY filtersChanged)
    Q_PROPERTY(QString groupBy READ groupBy WRITE setGroupBy NOTIFY groupByChanged)
    Q_PROPERTY(int limit READ limit WRITE setLimit NOTIFY limitChanged)
    Q_PROPERTY(QString primaryKey READ primaryKey WRITE setPrimaryKey NOTIFY primaryKeyChanged)
    Q_PROPERTY(QStringList searchFields READ searchFields WRITE setSearchFields NOTIFY searchFieldsChanged)
    Q_PROPERTY(QString reference READ reference WRITE setReference NOTIFY referenceChanged)
    Q_PROPERTY(QString searchString READ searchString WRITE setSearchString NOTIFY searchStringChanged)
    Q_PROPERTY(QString tableName READ tableName WRITE setTableName NOTIFY tableNameChanged)

public:
    explicit SqlTableModel2(QObject *parent = 0);

    int count();
    QStringList             bindValues() const;
    Q_INVOKABLE QVariant    data(const QModelIndex &index, int role) const;
    const QStringList       &fieldNames();
    QStringList             &filters();
    QString                 &groupBy();
    int                     limit();
    QString                 primaryKey();

    QString reference();
    virtual QHash<int, QByteArray> roleNames() const;
    QStringList searchFields();
    QString searchString();
    void setBindValues(const QStringList &bindValues);
    void setFieldNames(const QStringList &fields);
    void setFilters(const QStringList &);
    void setGroupBy(const QString &);
    void setLimit(int);
    void setPrimaryKey(const QString &);
    void setReference(const QString &);
    void setSearchFields(const QStringList &);
    void setSearchString(const QString &);
    void setTableName(const QString &);
    const QString &tableName();

    Q_INVOKABLE bool setData(const QModelIndex &item,const QVariant &value,int role = Qt::EditRole);

    Q_INVOKABLE QVariantMap getObject(QString key) const;
    Q_INVOKABLE QVariantMap getObject(QString primaryField, QString key) const;
    Q_INVOKABLE QVariantMap getObjectInRow(int row) const;
    Q_INVOKABLE QVariant insertObject(const QVariantMap &);
    Q_INVOKABLE bool removeObject(const QVariant &);
    Q_INVOKABLE bool select();
    Q_INVOKABLE QStringList selectDistinct(QString field,QString order,QString filter,bool ascending);
    Q_INVOKABLE bool selectUnique(QString);

//    Q_INVOKABLE bool setQuery(const QString query);
    Q_INVOKABLE bool updateObject(const QVariantMap &);

    // Subselections
    Q_INVOKABLE void deselectAllObjects();
    Q_INVOKABLE bool isSelectedObject(const int &);
    Q_INVOKABLE void selectObject(int, bool);
    Q_INVOKABLE int removeSelectedObjects();

    // Filter
    Q_INVOKABLE void setSort(int, Qt::SortOrder);

signals:
    void bindValuesChanged();
    void countChanged();
    void fieldNamesChanged();
    void filtersChanged();
    void groupByChanged();
    void limitChanged();
    void primaryKeyChanged();
    void referenceChanged();
    void searchFieldsChanged();
    void searchStringChanged();
    void tableNameChanged();
    void updated();
//    void countChanged();

public slots:
    void debug();


private:
    QString innerTableName;
    QStringList innerFieldNames;
    QStringList innerFilters;
    QString innerGroupBy;
    int innerLimit;
    QStringList innerSearchFields;
    QString innerSearchString;
    QString innerReference;
    QString innerPrimaryKey;
    QHash<int, QByteArray> roles;
    QMap<int,bool> subselectedRows;

    QSqlRecord buildRecord(const QVariantMap &,bool);
    void generateRoleNames();
    int searchRowWithKeyValue(const QVariant &);

    QStringList innerBindValues;
};

#endif // SQLTABLEMODEL2_H
