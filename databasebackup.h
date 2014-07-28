#ifndef DATABASEBACKUP_H
#define DATABASEBACKUP_H

#include <QObject>

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
    Q_INVOKABLE bool createTable(const QString &, const QString &);
    Q_INVOKABLE bool dropTable(const QString &);
    Q_INVOKABLE bool saveContents(const QString &);
    Q_INVOKABLE bool readContents(const QString &filename);

};

#endif // DATABASEBACKUP_H
