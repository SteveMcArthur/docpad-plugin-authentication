/*global F, module, test, equal,ok*/
var iCount = 0;
module("login", {
    setup: function () {

        if (iCount < 1) {
            F.open('/logout');
            iCount++;
            F.open('/login');
        } else {
            F.open('/tests');
        }


    }
});

test("Login", function () { 
    F('.git a').exists().click(function () {
            equal(this[0].innerHTML.trim(), 'Sign in with Github', 'Github signin button');
    });
    F('#logout').exists().text('Logout', 'Should see logout button if logged in');
});


test("Click link", function () {
    F('#tests ul:nth-child(2) li:nth-child(1) a').click(function () {
        ok(true, this[0].innerHTML);
    });
    F('article > h1').text('Analytics', 'Should be Analytics page');
});

test("Click link", function () {
    F('#tests ul:nth-child(2) li:nth-child(2) a').click(function () {
        ok(true, this[0].innerHTML);
    });
    F('article > h1').text('Admin Page', 'Should be Admin page');
});

test("Click link", function () {
    F('#tests ul:nth-child(2) li:nth-child(3) a').click(function () {
        ok(true, this[0].innerHTML);
    });
    F('article > h1').text('Super Secret URL', 'Should be Super Secret URL page');
});

test("Click link", function () {
    F('#tests ul:nth-child(2) li:nth-child(4) a').click(function () {
        ok(true, this[0].innerHTML);
    });
    F('article > h1').text('Edit Page', 'Should be Edit page');
});

test("Click link", function () {
    F('#tests ul:nth-child(2) li:nth-child(5) a').click(function () {
        ok(true, this[0].innerHTML);
    });
    F('article > h1').text('More Secrets', 'Should be More Secrets page');
});


//second list
test("Click link", function () {
    F('#tests ul:nth-child(4) li:nth-child(1) a').click(function () {
        ok(true, this[0].innerHTML);
    });
    F('article > h1').text('Analytics', 'Should be Analytics page');
});

test("Click link", function () {
    F('#tests ul:nth-child(4) li:nth-child(2) a').click(function () {
        ok(true, this[0].innerHTML);
    });
    F('article > h1').text('Admin Page', 'Should be Admin page');
});

test("Click link", function () {
    F('#tests ul:nth-child(4) li:nth-child(3) a').click(function () {
        ok(true, this[0].innerHTML);
    });
    F('article > h1').text('Super Secret URL', 'Should be Super Secret URL page');
});

test("Click link", function () {
    F('#tests ul:nth-child(4) li:nth-child(4) a').click(function () {
        ok(true, this[0].innerHTML);
    });
    F('article > h1').text('Edit Page', 'Should be Edit page');
});

test("Click link", function () {
    F('#tests ul:nth-child(4) li:nth-child(5) a').click(function () {
        ok(true, this[0].innerHTML);
    });
    F('article > h1').text('More Secrets', 'Should be More Secrets page');
});


//third list
test("Click link", function () {
    F('#tests ul:nth-child(6) li:nth-child(1) a').click(function () {
        ok(true, this[0].innerHTML);
    });
    F('article > h1').text('Analytics', 'Should be Analytics page');
});

test("Click link", function () {
    F('#tests ul:nth-child(6) li:nth-child(2) a').click(function () {
        ok(true, this[0].innerHTML);
    });
    F('article > h1').text('Admin Page', 'Should be Admin page');
});

test("Click link", function () {
    F('#tests ul:nth-child(6) li:nth-child(3) a').click(function () {
        ok(true, this[0].innerHTML);
    });
    F('article > h1').text('Super Secret URL', 'Should be Super Secret URL page');
});

test("Click link", function () {
    F('#tests ul:nth-child(6) li:nth-child(4) a').click(function () {
        ok(true, this[0].innerHTML);
    });
    F('article > h1').text('Edit Page', 'Should be Edit page');
});

test("Click link", function () {
    F('#tests ul:nth-child(6) li:nth-child(5) a').click(function () {
        ok(true, this[0].innerHTML);
    });
    F('article > h1').text('More Secrets', 'Should be More Secrets page');
});