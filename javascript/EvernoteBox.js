var hostName = "http://sandbox.evernote.com";

var options,oauth;
 options = {
    consumerKey: '',
    consumerSecret: '',
    callbackUrl : '',
    signatureMethod : "HMAC-SHA1",
};
oauth = OAuth(options);
oauth.request({'method': 'GET', 'url': hostName + '/oauth', 'success': success, 'failure': failure});
