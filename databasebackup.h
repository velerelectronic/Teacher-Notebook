#ifndef DATABASEBACKUP_H
#define DATABASEBACKUP_H

#include <QObject>
#include <QSqlError>

class DatabaseBackup : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString homePath READ homePath NOTIFY homePathChanged)

public:
    explicit DatabaseBackup(QObject *parent = 0);

    const QString &homePath();

signals:
    void homePathChanged();

public slots:
    Q_INVOKABLE bool createFunction(const QString &name, const QString &args, const QString &returnType, const QString &definition);
    Q_INVOKABLE bool createTable(const QString &, const QString &);
    Q_INVOKABLE bool createView(const QString &, const QString &);
    Q_INVOKABLE bool dropTable(const QString &);
    Q_INVOKABLE bool alterTable(const QString &, const QString &, const QString &);
    Q_INVOKABLE bool dropView(const QString &);
    Q_INVOKABLE QString lastError();
    Q_INVOKABLE bool saveContents(const QString &);
    Q_INVOKABLE bool readContents(const QString &filename);

private:
    QSqlError innerLastError;

};

#endif // DATABASEBACKUP_H
