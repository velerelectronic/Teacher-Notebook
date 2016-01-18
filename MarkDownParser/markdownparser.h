#ifndef MARKDOWNPARSER_H
#define MARKDOWNPARSER_H

#include <QObject>
#include <QString>
#include <QChar>

class MarkDownParser : public QObject
{
    Q_OBJECT
public:
    explicit MarkDownParser(QObject *parent = 0);

signals:

public slots:
    Q_INVOKABLE QString toHtml(QString text);

private:
    QChar nextChar;
    QString interText;

    QString parseToken(QRegExp suffix);
    QString parseTokenAlt(QString suffix);
    QString parseAsParagraph(QString text);

    bool getNextChar();
    QString parseParagrah();
    QString parseWord();
    QString parseEmphasis();
    QString parseHeading();
    QString parseLink();
};

#endif // MARKDOWNPARSER_H
