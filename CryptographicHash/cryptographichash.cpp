#include "cryptographichash.h"
#include <QCryptographicHash>

CryptographicHash::CryptographicHash(QObject *parent) : QObject(parent)
{

}

QString CryptographicHash::md5(QString text) {
    return QString(QCryptographicHash::hash(text.toUtf8(), QCryptographicHash::Md5).toBase64());
}
