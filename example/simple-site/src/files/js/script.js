/*global XMLHttpRequest, window, document*/
(function () {

    function ajax(url, callback) {
        var httpRequest;

        function requestReturned() {
            if (httpRequest.readyState === XMLHttpRequest.DONE) {
                callback(httpRequest);
            }
        }

        function makeRequest() {
            httpRequest = new XMLHttpRequest();

            if (!httpRequest) {
                callback('Giving up :( Cannot create an XMLHTTP instance');
                return false;
            }
            httpRequest.onreadystatechange = requestReturned;
            httpRequest.open('GET', url);
            httpRequest.send();
        }

        makeRequest();
    }

    window.onload = function () {

        ajax('/isLoggedIn', function (req) {
            if (req.status === 200) {
                var txt = req.responseText;
                var el;
                if (txt == "true") {
                    el = document.getElementById("loggedin");
                    el.style = "";
                } else {
                    el = document.getElementById("loggedout");
                    el.style = "";
                }
            } else {
                alert('Request Failed');
            }
        });
    };

})();