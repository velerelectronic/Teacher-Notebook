#ifndef CRYPTOGRAPHICHASH_H
#define CRYPTOGRAPHICHASH_H

#include <QObject>

class CryptographicHash : public QObject
{
    Q_OBJECT
public:
    explicit CryptographicHash(QObject *parent = 0);

signals:

public slots:
    Q_INVOKABLE QString md5(QString text);

private:

};

#endif // CRYPTOGRAPHICHASH_H
