Date.prototype.addDays = function(days) {
    this.setDate(this.getDate()+days);
    return this;
}

Date.prototype.copyDate = function(otherDate) {
    this.setDate(otherDate.getDate());
    this.setMonth(otherDate.getMonth());
    this.setFullYear(otherDate.getFullYear());
}

Date.prototype.differenceInDays = function(date2) {
    var oneDay = 24 * 60 * 60 * 1000;

    // Truncating must be done before, to avoid situations where time is defined with a difference of less than 24 hours
    // For example 6/11/2016 at 20:00 and 7/11/2016 at 19:00 should not be considered the same date
    var date1ms = Math.floor(this.getTime() / oneDay);
    var date2ms = Math.floor(date2.getTime() / oneDay);
    return date2ms-date1ms;
}

Date.prototype.differenceInMinutes = function(date2) {
    var oneMinute = 60 * 1000;
    var date1ms = Math.floor(this.getTime() / oneMinute);
    var date2ms = Math.floor(date2.getTime() / oneMinute);
    return date2ms-date1ms;
}

Date.prototype.fromHHMMFormat = function(text) {
    var param = text.split(':');
    if (param.length == 2) {
        var hours = parseInt(param[0]);
        var minutes = parseInt(param[1]);
        this.setHours(hours);
        this.setMinutes(minutes);
        this.definedTime = true;
    }
    return this;
}

Date.prototype.fromYYYYMMDDFormat = function(text) {
    var subDate = text.split(' ')[0];
    console.log('variants', text, subDate);
    var param = subDate.split('-');
    var year = parseInt(param[0]);
    var month = parseInt(param[1])-1;
    var day = parseInt(param[2]);
    console.log("Parsing YMD date", text, year, month, day);
    if (param.length == 3) {
        this.setFullYear(year);
        this.setMonth(month);
        this.setDate(day);
        this.definedDate = true;
        console.log("post parsing", this.getFullYear(), this.getMonth(), this.getDate());
    }
    return this;
}


Date.prototype.fromYYYYMMDDHHMMFormat = function(text) {
    var param = ((typeof text == 'string')?text.trim():'').split(' ');
    this.definedDate = false;
    this.definedTime = false;
    switch (param.length) {
    case 2:
        this.fromHHMMFormat(param[1]);
    case 1:
        this.fromYYYYMMDDFormat(param[0]);
        break;
    default:
        break;
    }
    return this;
}

Date.prototype.hasDate = function() {
    return (typeof this.definedDate !== 'undefined')?this.definedDate:false;
}

Date.prototype.hasTime = function() {
    return (typeof this.definedTime !== 'undefined')?this.definedTime:false;
}


Date.prototype.toDateSpecificFormat = function() {
    return this.getDate() + '/' + (this.getMonth()+1) + '/' + this.getFullYear();
}


Date.prototype.toLongDate = function() {
    var weekdays = ['diumenge','dilluns','dimarts','dimecres','dijous','divendres','dissabte'];
    var months = ['gener','febrer','març','abril','maig','juny','juliol','agost','setembre','octubre','novembre','desembre'];
    return (weekdays[this.getDay()] + ' ' + this.getDate() + ' de ' + months[this.getMonth()] + ' de ' + this.getFullYear());
}

Date.prototype.toShortReadableDate = function() {
    var weekdays = ['dg','dl','dt','dc','dj','dv','ds'];
    var months = ['gen', 'feb', 'març', 'abr','maig','jun','jul','ago','set','oct','nov','des'];
    return (weekdays[this.getDay()] + ' ' + this.getDate() + ' ' + months[this.getMonth()] + ' ' + this.getFullYear());
}

Date.prototype.toHHMMFormat = function() {
    var hours = this.getHours();
    hours = ((hours<10)?'0':'') + hours;
    var minutes = this.getMinutes();
    minutes = ((minutes<10)?'0':'') + minutes;
    return hours + ':' + minutes;
}

Date.prototype.toTimeSpecificFormat = function() {
    return this.getHours() + ':' + ((this.getMinutes()<10)?'0':'') + this.getMinutes();
}


Date.prototype.toYYYYMMDDFormat = function() {
    var month = this.getMonth()+1;
    month = ((month<10)?'0':'') + month;
    var day = this.getDate();
    day = ((day<10)?'0':'') + day;
    return this.getFullYear() + '-' + month + '-' + day;
}


Date.prototype.toYYYYMMDDHHMMFormat = function() {
    return this.toYYYYMMDDFormat() + " " + this.toHHMMFormat();
}

