#include "markdownparser.h"

#include <QString>
#include <QRegExp>
#include <QDebug>

MarkDownParser::MarkDownParser(QObject *parent) :
    QObject(parent)
{
}

bool MarkDownParser::getNextChar() {
    if (interText.size()>0) {
        nextChar = interText.at(0);
        interText.remove(0,1);
        return true;
    } else
        return false;
}

QString MarkDownParser::toHtml(QString text) {
    interText = text;
    return parseTokenAlt(text);
    if (getNextChar())
        return "<p>" + parseToken(QRegExp("$")) + "</p>";
    else
        return "";
}

QString MarkDownParser::parseTokenAlt(QString infix) {
    QString output = "";

    int pos = 0;

    QRegExp rx("(\\n*#\\s+([^\\n\\n]+)\\n{2,})|(\\*\\s+((?:[^\\n]|\\n[^\\n])+\\n{2,}))|(((?:\\n[^\\n]|[^\\n])+)\\n{2,})|(\\*{2}([^\\*]+)\\*{2})|(_{2}([^_]+)_{2})");
    while (pos >= 0) {
        int newPos = rx.indexIn(infix, pos);
        qDebug() << "CAP";

        if (newPos >= pos) {
            output += infix.mid(pos,newPos-pos);

            int n = 1;
            if (rx.cap(n) != "") {
                output += "<h1>" + parseTokenAlt(rx.cap(n+1)) + "</h1>";
            }
            n = n + 2;
            if (rx.cap(n) != "") {
                output += "<ul>";

                QRegExp rxsub("^\\*(?:\\s*)([^\\n]+)(?:\\n|$)");
                int posSub = 0;
                while (posSub >= 0) {
                    posSub = rxsub.indexIn(rx.cap(n),posSub,QRegExp::CaretAtOffset);
                    if (posSub >= 0) {
                        output += "<li>" + parseTokenAlt(rxsub.cap(1)) + "</li>";
                        posSub = posSub + rxsub.matchedLength();
                    }
                }
                output += "</ul>";
            }
            n = n + 2;
            if (rx.cap(n) != "") {
                output += "<p>" + parseTokenAlt(rx.cap(n+1)) + "</p><br/>";
            }
            n = n + 2;
            if (rx.cap(n) != "") {
                output += "<b>" + parseTokenAlt(rx.cap(n+1)) + "</b>";
            }
            n = n + 2;
            if (rx.cap(n) != "") {
                output += "<u>" + parseTokenAlt(rx.cap(n+1)) + "</u>";
            }

            pos = newPos + rx.matchedLength();
        } else {
            output += infix.mid(pos);
            pos = -1;
        }
    }


    return output;
}

QString MarkDownParser::parseToken(QRegExp suffix) {
    QString output = "";

    bool sameToken = true;

    while (sameToken) {
        QString partialOutput = "";
        if (suffix.indexIn(interText)==0) {
            interText.remove(0,suffix.matchedLength());
            partialOutput = nextChar;
            sameToken = false;
        } else {
            QChar prefix = nextChar;
            if ((prefix == '\n') || (prefix == '\r')) {
                if (getNextChar()) {
                    if ((nextChar == '\n') || (nextChar == '\r')) {
                        partialOutput = "</p>";
                        if (getNextChar()) {
                            if ((nextChar == ' ') || (nextChar == '\t')) {
                                if (getNextChar()) {
                                    partialOutput += "<blockquote>" + parseToken(QRegExp("(\\n|\\r)(\\n|\\r)")) + "</blockquote>";
                                    if (!getNextChar())
                                        sameToken = false;
                                } else {
                                    sameToken = false;
                                }
                            }
                            partialOutput += "<p>";
                        } else
                            sameToken = false;
                    } else {
                        partialOutput = " ";
                    }
                } else {
                    partialOutput = "";
                    sameToken = false;
                }
            } else if ((prefix==' ') || (prefix == '\t')) {
                // Remove initial spaces
                bool removing = true;
                while ((removing) && (getNextChar())) {
                    if ((nextChar!=' ') && (nextChar!='\t')) {
                        removing = false;
                    }
                }
                if (removing) {
                    sameToken = false;
                } else {
                    partialOutput = " ";
                }
            } else if (prefix == '*') {
                if (getNextChar()) {
                    if (nextChar == '*') {
                        if (getNextChar()) {
                            partialOutput = "<b>" + parseToken(QRegExp("\\*\\*")) + "</b>";
                            if (!getNextChar())
                                sameToken = false;
                        } else {
                            partialOutput = "**";
                            sameToken = false;
                        }
                    } else {
                        partialOutput += prefix;
                        partialOutput += nextChar;
                    }
                } else {
                    partialOutput = prefix;
                }
            } else if (prefix == '_') {
                if (getNextChar()) {
                    if (nextChar == '_') {
                        if (getNextChar()) {
                            partialOutput = "<u>" + parseToken(QRegExp("\\_\\_")) + "</u>";
                            if (!getNextChar())
                                sameToken = false;
                        } else {
                            partialOutput = "__";
                            sameToken = false;
                        }
                    } else {
                        partialOutput += prefix;
                        partialOutput += nextChar;
                    }
                } else {
                    partialOutput = prefix;
                }
            } else if (prefix == '@') {
                if (getNextChar()) {
                    if (nextChar == '@') {
                        if (getNextChar()) {
                            partialOutput = "<mark style=\"background-color: yellow\">" + parseToken(QRegExp("@@")) + "</mark>";
                            if (!getNextChar())
                                sameToken = false;
                        } else {
                            partialOutput = "@@";
                            sameToken = false;
                        }
                    } else {
                        partialOutput += prefix;
                        partialOutput += nextChar;
                    }
                } else {
                    partialOutput = prefix;
                }
            } else if (prefix == '#') {
                if (getNextChar()) {
                    if (nextChar == '#') {
                        if (getNextChar()) {
                            partialOutput = "<h2>" + parseToken(QRegExp("(\\n|\\r)")) + "</h2>";
                            if (!getNextChar())
                                sameToken = false;
                        } else {
                            partialOutput = "##";
                        }
                    } else {
                        partialOutput = "<h1>" + parseToken(QRegExp("(\\n|\\r)")) + "</h1>";
                        if (!getNextChar())
                            sameToken = false;
                    }
                } else {
                    partialOutput = prefix;
                }
            } else if (prefix == '[') {
                if (getNextChar()) {
                    if (nextChar == '[') {
                        if (getNextChar()) {
                            QString reference = parseToken(QRegExp("\\]\\]"));
                            partialOutput = "<a href=\"" + reference + "\">" + reference + "</a>";
                            if (!getNextChar())
                                sameToken = false;
                        } else {
                            sameToken = false;
                        }
                    } else {
                        partialOutput += prefix;
                        partialOutput += nextChar;
                    }
                } else {
                    partialOutput = prefix;
                }
            } else if (prefix == '!') {
                partialOutput = prefix;
                if (!getNextChar())
                    sameToken = false;
            } else {
                partialOutput = prefix;
                if (!getNextChar())
                    sameToken = false;
            }
        }
        output += partialOutput;
    }

    return output;
}

