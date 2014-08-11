#ifndef STANDARDPATHS_H
#define STANDARDPATHS_H

#include <QStandardPaths>

class StandardPaths : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString desktop READ desktop)
    Q_PROPERTY(QString documents READ documents NOTIFY documentsChanged)
    Q_PROPERTY(QString downloads READ downloads)
    Q_PROPERTY(QString home READ home)
    Q_PROPERTY(QString movies READ movies)
    Q_PROPERTY(QString music READ music)
    Q_PROPERTY(QString pictures READ pictures)

public:
    explicit StandardPaths(QObject *parent = 0);

    QString desktop();
    QString documents();
    QString downloads();
    QString home();
    QString movies();
    QString music();
    QString pictures();

signals:
    void documentsChanged();
    /*
    void downloadsChanged();
    void homeChanged();
    */

public slots:

};

#endif // STANDARDPATHS_H
