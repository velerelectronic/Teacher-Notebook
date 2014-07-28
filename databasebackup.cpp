#include "databasebackup.h"

#include <QFile>
#include <QDateTime>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
#include <QDebug>
#include <QSqlQuery>
#include <QSqlTableModel>
#include <QSqlRecord>
#include <QSqlQueryModel>
#include <QSqlError>
#include <QSqlField>
#include <QDir>
#include <QStandardPaths>

DatabaseBackup::DatabaseBackup(QObject *parent) :
    QObject(parent)
{
}

bool DatabaseBackup::createTable(const QString &table, const QString &fields) {
    QSqlQueryModel model(this);
    model.setQuery(QSqlQuery("CREATE TABLE IF NOT EXISTS " + table + " " + fields));
}

bool DatabaseBackup::dropTable(const QString &table) {
    QSqlQueryModel model(this);
    model.setQuery(QSqlQuery("DROP TABLE IF EXISTS " + table));
}

const QString &DatabaseBackup::homePath() {
    QString *dir = new QString;
    dir->append(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation));
    dir->append("/TeacherNotebook");
    return *dir;
}

bool DatabaseBackup::readContents(const QString &filename) {
    qDebug() << "Read contents from " + filename;
    QFile file(filename);
    QSqlQueryModel query;
    bool res = false;

    if (file.open(QIODevice::ReadOnly)) {
        QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
        if (doc.isObject()) {
            res = true;
            QJsonArray tables = doc.object().take("database").toObject().take("tables").toArray();
            QJsonArray::const_iterator i = tables.constBegin();
            while (i != tables.constEnd()) {
                QString tableName = (*i).toObject().take("name").toString();
                qDebug() << tableName;
                QJsonArray records = (*i).toObject().take("records").toArray();
                QJsonArray::const_iterator recordIterator = records.constBegin();
                while (recordIterator != records.constEnd()) {
                    QVariantMap record = (*recordIterator).toObject().toVariantMap();
                    QStringList fields = record.keys();
                    QStringList values;
                    QStringList::const_iterator fieldIterator = fields.constBegin();
                    while (fieldIterator != fields.constEnd()) {
                        values << record.take(*fieldIterator).toString();
                        ++fieldIterator;
                    }
                    qDebug() << "INSERT INTO " + tableName + " (" + fields.join(',') + ")" + " VALUES ('" + values.join("','") + "')";
                    query.setQuery( QSqlQuery("INSERT INTO " + tableName + " (" + fields.join(',') + ")" + " VALUES ('" + values.join("','") + "')") );
                    qDebug() << "Errors?" << query.lastError();
                    ++ recordIterator;
                }
                ++i;
            }
        }
        query.submit();
    }
    file.close();
    return res;
}

bool DatabaseBackup::saveContents(const QString &directory) {
    bool res = false;
    QDateTime date = QDateTime::currentDateTime();
    qDebug() << directory + date.toString(Qt::ISODate).replace(':','-') + ".backup";
    QFile file(directory + date.toString(Qt::ISODate).replace(':','-') + ".backup");
    QSqlQueryModel model(this);
    model.setQuery(QSqlQuery("SELECT tbl_name FROM sqlite_master WHERE type='table'"));

    QJsonArray jsonAllTables;
    for (int row=0; row<model.rowCount(); row++) {
        QString tableName = model.record(row).value(0).toString();

        QSqlQueryModel table(this);
        table.setQuery(QSqlQuery("SELECT * FROM " + tableName));

        QJsonArray jsonRecordsInTable;
        for (int tableRow=0; tableRow<table.rowCount(); tableRow++) {
            QSqlRecord record = table.record(tableRow);
            QJsonObject jsonRecord;
            for (int col=0; col<record.count(); col++) {
                jsonRecord.insert(record.field(col).name(),QJsonValue(record.value(col).toString()));
            }
            jsonRecordsInTable.append( QJsonValue(jsonRecord) );
        }

        QJsonObject jsonTable;
        jsonTable.insert("name",QJsonValue(tableName));
        jsonTable.insert("records",QJsonValue(jsonRecordsInTable));

        jsonAllTables.append(QJsonValue(jsonTable));
    }

    QJsonObject tables;
    tables.insert("tables",QJsonValue(jsonAllTables));

    QJsonObject database;
    database.insert("database",QJsonValue(tables));

    QJsonDocument doc(database);

    if (file.open(QIODevice::WriteOnly)) {
        qint64 len = file.write(doc.toJson());
        res = (len != -1);
    }
    file.close();
    return res;
}

