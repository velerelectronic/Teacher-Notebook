Date.prototype.differenceInDays = function(date2) {
    var oneDay = 24 * 60 * 60 * 1000;
    var date1ms = this.getTime();
    var date2ms = date2.getTime();
    return Math.floor((date2ms-date1ms)/oneDay);
}

Date.prototype.toDateSpecificFormat = function() {
    return this.getDate() + '/' + (this.getMonth()+1) + '/' + this.getFullYear();
}

Date.prototype.toYYYYMMDDFormat = function() {
    var month = this.getMonth()+1;
    month = ((month<10)?'0':'') + month;
    var day = this.getDate();
    day = ((day<10)?'0':'') + day;
    return this.getFullYear() + '-' + month + '-' + day;
}

Date.prototype.toHHMMFormat = function() {
    var hours = this.getHours();
    hours = ((hours<10)?'0':'') + hours;
    var minutes = this.getMinutes();
    minutes = ((minutes<10)?'0':'') + minutes;
    return hours + ':' + minutes;
}

Date.prototype.fromYYYYMMDDFormat = function(text) {
    var param = text.split('-');
    var year = param[0];
    var month = param[1]-1;
    var day = param[2];
    this.setDate(day);
    this.setMonth(month);
    this.setFullYear(year);
    return this;
}

Date.prototype.fromHHMMFormat = function(text) {
    var param = text.split(':');
    var hours = param[0];
    var minutes = param[1];
    this.setHours(hours);
    this.setMinutes(minutes);
    return this;
}

Date.prototype.toTimeSpecificFormat = function() {
    return this.getHours() + ':' + this.getMinutes();
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
