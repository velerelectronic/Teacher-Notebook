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
    Q_PROPERTY(QString sort READ sort WRITE setSort NOTIFY sortChanged)
    Q_PROPERTY(QString tableName READ tableName WRITE setTableName NOTIFY tableNameChanged)

public:
    explicit SqlTableModel2(QObject *parent = 0, QSqlDatabase db = QSqlDatabase());

    // Subclass

    QVariant                            data(const QModelIndex &index, int role) const;
    Qt::ItemFlags                       flags(const QModelIndex &index) const;
    virtual QHash<int, QByteArray>      roleNames() const;
    bool                                setData(const QModelIndex &item,const QVariant &value,int role = Qt::EditRole);


    // Own methods

    QStringList         bindValues() const;
    int                 count();
    const QStringList   &fieldNames();
    QStringList         &filters();
    QString             getFieldNameByIndex(int index);
    QString             &groupBy();
    int                 limit();
    QString             primaryKey();
    QString             reference();
    QStringList         searchFields();
    QString             searchString();
    void                setBindValues(const QStringList &bindValues);
    void                setFieldNames(const QStringList &fields);
    void                setFilters(const QStringList &);
    void                setGroupBy(const QString &);
    void                setLimit(int);
    void                setPrimaryKey(const QString &);
    void                setReference(const QString &);
    void                setSearchFields(const QStringList &);
    void                setSearchString(const QString &);
    void                setSort(const QString &);
    void                setTableName(const QString &);
    QString             sort();
    const QString       &tableName();

    Q_INVOKABLE QVariantMap getObject(QString key);
    Q_INVOKABLE QVariantMap getObject(QString primaryField, QString key);
    Q_INVOKABLE QVariantMap getObjectInRow(int row) const;
    Q_INVOKABLE QVariant insertObject(const QVariantMap &);
    Q_INVOKABLE int removeObject(const QVariant &);
    Q_INVOKABLE bool select();
    Q_INVOKABLE QStringList selectDistinct(QString field,QString order,QString filter,bool ascending);
    Q_INVOKABLE bool selectUnique(QString);

//    Q_INVOKABLE bool setQuery(const QString query);
    Q_INVOKABLE int updateObject(const QVariant &keyValue, const QVariantMap &);

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
    void sortChanged();
    void tableNameChanged();
    void updated();
//    void countChanged();

public slots:
    void debug();


private:
    QStringList             innerBindValues;
    QStringList             innerFieldNames;
    QStringList             innerFilters;
    QString                 innerGroupBy;
    int                     innerLimit;
    QString                 innerPrimaryKey;
    QString                 innerReference;
    QHash<int, QByteArray>  roles;
    QStringList             innerSearchFields;
    QString                 innerSearchString;
    QString                 innerSort;
    QMap<int,bool>          subselectedRows;
    QString                 innerTableName;

    QSqlRecord      buildRecord(const QVariantMap &,bool);
    void            generateRoleNames();
    int             searchRowWithKeyValue(const QVariant &);

};

#endif // SQLTABLEMODEL2_H
