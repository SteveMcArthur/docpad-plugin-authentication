/*global F, module, test, ok*/
module("main", {
    setup: function () {
        F.open('/logout');
        F.open('/tests');
    }
});


test("Click link", function () {
   F('#tests ul:nth-child(2) li:nth-child(1) a').click(function(){
       ok(true,this[0].innerHTML);
   });
   F('article > h1').text('Login Page','Should be redirected to login page');
});

test("Click link", function () {
  F('#tests ul:nth-child(2) li:nth-child(2) a').click(function(){
       ok(true,this[0].innerHTML);
   });
   F('article > h1').text('Login Page','Should be redirected to login page');
});

test("Click link", function () {
   F('#tests ul:nth-child(2) li:nth-child(3) a').click(function(){
       ok(true,this[0].innerHTML);
   });
   F('article > h1').text('Login Page','Should be redirected to login page');
});

test("Click link", function () {
   F('#tests ul:nth-child(2) li:nth-child(4) a').click(function(){
       ok(true,this[0].innerHTML);
   });
   F('article > h1').text('Login Page','Should be redirected to login page');
});

test("Click link", function () {
  F('#tests ul:nth-child(2) li:nth-child(5) a').click(function(){
       ok(true,this[0].innerHTML);
   });
   F('article > h1').text('Login Page','Should be redirected to login page');
});

//second list
test("Click link", function () {
   F('#tests ul:nth-child(4) li:nth-child(1) a').click(function(){
       ok(true,this[0].innerHTML);
   });
   F('article > h1').text('Login Page','Should be redirected to login page');
});

test("Click link", function () {
  F('#tests ul:nth-child(4) li:nth-child(2) a').click(function(){
       ok(true,this[0].innerHTML);
   });
   F('article > h1').text('Login Page','Should be redirected to login page');
});

test("Click link", function () {
   F('#tests ul:nth-child(4) li:nth-child(3) a').click(function(){
       ok(true,this[0].innerHTML);
   });
   F('article > h1').text('Login Page','Should be redirected to login page');
});

test("Click link", function () {
   F('#tests ul:nth-child(4) li:nth-child(4) a').click(function(){
       ok(true,this[0].innerHTML);
   });
   F('article > h1').text('Login Page','Should be redirected to login page');
});

test("Click link", function () {
  F('#tests ul:nth-child(4) li:nth-child(5) a').click(function(){
       ok(true,this[0].innerHTML);
   });
   F('article > h1').text('Login Page','Should be redirected to login page');
});


//third list
test("Click link", function () {
   F('#tests ul:nth-child(6) li:nth-child(1) a').click(function(){
       ok(true,this[0].innerHTML);
   });
   F('article > h1').text('Login Page','Should be redirected to login page');
});

test("Click link", function () {
  F('#tests ul:nth-child(6) li:nth-child(2) a').click(function(){
       ok(true,this[0].innerHTML);
   });
   F('article > h1').text('Login Page','Should be redirected to login page');
});

test("Click link", function () {
   F('#tests ul:nth-child(6) li:nth-child(3) a').click(function(){
       ok(true,this[0].innerHTML);
   });
   F('article > h1').text('Login Page','Should be redirected to login page');
});

test("Click link", function () {
   F('#tests ul:nth-child(6) li:nth-child(4) a').click(function(){
       ok(true,this[0].innerHTML);
   });
   F('article > h1').text('Login Page','Should be redirected to login page');
});

test("Click link", function () {
  F('#tests ul:nth-child(6) li:nth-child(5) a').click(function(){
       ok(true,this[0].innerHTML);
   });
   F('article > h1').text('Login Page','Should be redirected to login page');
});






