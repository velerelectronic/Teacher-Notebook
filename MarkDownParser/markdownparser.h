#ifndef MARKDOWNPARSER_H
#define MARKDOWNPARSER_H

#include <QObject>
#include <QString>
#include <QChar>
#include <QTextBlock>
#include <QTextCursor>
#include "MarkDownItem/markdownitem.h"

class MarkDownParser : public QObject
{
    Q_OBJECT
public:
    explicit MarkDownParser(QObject *parent = 0);

signals:

public slots:
    Q_INVOKABLE QStringList getParagraphs();
    Q_INVOKABLE QString toHtml(QString text);

public:
    void            parseIntoCursor(const QString &text, QTextCursor &cursor);
    MarkDownItem    parseSingleToken(QString text, int &relativePos);

private:
    QChar nextChar;
    QString interText;

    QString parseToken(QRegExp suffix);
    QString parseTokenAlt(QString suffix, int relativePos = 0);


    bool getNextChar();
    /*
    QString parseParagrah();
    QString parseWord();
    QString parseEmphasis();
    QString parseHeading();
    QString parseLink();
    */
};

#endif // MARKDOWNPARSER_H
