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
    if (getNextChar())
        return "<p>" + parseToken(QRegExp("$")) + "</p>";
    else
        return "";
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

