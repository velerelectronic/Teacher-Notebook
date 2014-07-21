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
    Q_PROPERTY(QString tableName READ tableName WRITE setTableName NOTIFY tableNameChanged)
    Q_PROPERTY(QStringList fieldNames READ fieldNames WRITE setFieldNames NOTIFY fieldNamesChanged)
    Q_PROPERTY(QString filter READ filter WRITE setFilter NOTIFY filterChanged)
//    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit SqlTableModel(QObject *parent = 0,QSqlDatabase db = QSqlDatabase());

    const QStringList &fieldNames();
    const QString &filter();
    virtual QHash<int, QByteArray> roleNames() const;
    const QString &tableName();

    Q_INVOKABLE QVariant data(const QModelIndex &index, int role) const;

    Q_INVOKABLE bool setData(const QModelIndex &item,const QVariant &value,int role = Qt::EditRole);

    void setFieldNames(QStringList fields);
    void setFilter(const QString &);
    void setTableName(const QString &);

    Q_INVOKABLE QVariantMap getObject(QString key) const;
    Q_INVOKABLE bool insertObject(const QVariantMap &);
    Q_INVOKABLE bool removeObject(int);
    Q_INVOKABLE bool removeObject(QVariantMap &);
    Q_INVOKABLE bool select();
    Q_INVOKABLE bool updateObject(const QVariantMap &);

    // Subselections
    Q_INVOKABLE void deselectAllObjects();
    Q_INVOKABLE bool isSelectedObject(const int &);
    Q_INVOKABLE void selectObject(const int &, bool);
    Q_INVOKABLE int removeSelectedObjects();

signals:
    void fieldNamesChanged();
    void filterChanged();
    void tableNameChanged();
//    void countChanged();

public slots:

private:
    QString innerTableName;
    QStringList innerFieldNames;
    QHash<int, QByteArray> roles;
    QMap<int,bool> subselectedRows;

    void generateRoleNames();
    int searchRecordWithKey(const QVariantMap &);
};

#endif // SQLTABLEMODEL_H
