import QtQuick 2.5

Rectangle {
    id: aboveMenu

    property int requiredHeight: 0

    property var options: []

    signal closeMenu()

    function getOption(varname,defaultvalue) {
        console.log('GET OPTION')
        console.log(options);
        for (var prop in options) {
            console.log(prop, "->", options[prop]);
        }

        if (varname.toString() in options) {
            console.log(options[varname]);
        }

        return ((varname.toString()) in options)?options[varname]:defaultvalue;
    }
}

