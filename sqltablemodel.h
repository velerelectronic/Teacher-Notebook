/*
 * Example in: http://qt-project.org/wiki/QML_and_QSqlTableModel
 *
 */

#ifndef SQLTABLEMODEL_H
#define SQLTABLEMODEL_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlRelationalTableModel>
#include <QVariantMap>
#include <QMap>

class SqlTableModel : public QSqlRelationalTableModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QStringList fieldNames READ fieldNames WRITE setFieldNames NOTIFY fieldNamesChanged)
    Q_PROPERTY(QStringList filters READ filters WRITE setFilters NOTIFY filtersChanged)
    Q_PROPERTY(int limit READ limit WRITE setLimit NOTIFY limitChanged)
    Q_PROPERTY(QStringList searchFields READ searchFields WRITE setSearchFields NOTIFY searchFieldsChanged)
    Q_PROPERTY(QString searchString READ searchString WRITE setSearchString NOTIFY searchStringChanged)
    Q_PROPERTY(QString tableName READ tableName WRITE setTableName NOTIFY tableNameChanged)
    Q_PROPERTY(QString reference READ reference WRITE setReference NOTIFY referenceChanged)

public:
    explicit SqlTableModel(QObject *parent = 0,QSqlDatabase db = QSqlDatabase());

    int count();
    Q_INVOKABLE QVariant data(const QModelIndex &index, int role) const;
    const QStringList &fieldNames();
    QStringList &filters();
    int limit();

    QString reference();
    virtual QHash<int, QByteArray> roleNames() const;
    QStringList searchFields();
    QString searchString();
    void setFieldNames(const QStringList &fields);
    void setFilters(const QStringList &);
    void setLimit(int);
    void setReference(const QString &);
    void setSearchFields(const QStringList &);
    void setSearchString(const QString &);
    void setTableName(const QString &);
    const QString &tableName();

    Q_INVOKABLE bool setData(const QModelIndex &item,const QVariant &value,int role = Qt::EditRole);

    Q_INVOKABLE QVariantMap getObject(QString key) const;
    Q_INVOKABLE QVariantMap getObjectInRow(int row) const;
    Q_INVOKABLE bool insertObject(const QVariantMap &);
    Q_INVOKABLE bool removeObjectInRow(int);
    Q_INVOKABLE bool removeObjectWithKeyValue(const QVariant &);
    Q_INVOKABLE bool select();
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
    void countChanged();
    void fieldNamesChanged();
    void filtersChanged();
    void limitChanged();
    void referenceChanged();
    void searchFieldsChanged();
    void searchStringChanged();
    void tableNameChanged();
//    void countChanged();

public slots:

private:
    QString innerTableName;
    QStringList innerFieldNames;
    QStringList innerFilters;
    int innerLimit;
    QStringList innerSearchFields;
    QString innerSearchString;
    QString innerReference;
    QHash<int, QByteArray> roles;
    QMap<int,bool> subselectedRows;

    QSqlRecord buildRecord(const QVariantMap &,bool);
    void generateRoleNames();
    void setInnerFilters();
    int searchRowWithKeyValue(const QVariant &);
};

#endif // SQLTABLEMODEL_H
