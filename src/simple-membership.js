/*global require, JSON, module, process*/
var fs = require('safefs');
var path = require('path');

var users = [];
var membershipFile = "";
var createAccountURL = '/createAccount';
var signUpURL = '/sign-up';
var afterAuthenticateURL = '/';

function writeMembershipFile() {
    if (membershipFile) {
        var jsonString = JSON.stringify(users, null, 2);
        fs.writeFile(membershipFile, jsonString);
    }
}

function loadMembershipFile(dataPath) {
    dataPath = path.join(dataPath, 'membership');
    membershipFile = path.join(dataPath, 'membership.json');

    var jsonString = "[]";
    fs.ensurePath(dataPath, function (err) {
        if (err) {
            throw err;
        }
        try {
            jsonString = fs.readFileSync(membershipFile, 'utf-8');
        } catch(e) {
            fs.writeFileSync(membershipFile, jsonString, 'utf-8');
        }

        users = JSON.parse(jsonString);
    });

}

function findOne(id, service) {
    for (var i = 0; i < users.length; i++) {
        var item = users[i];
        if (item.service_id == id && item.service == service) {
            return item;
        }
    }
    return false;
}


function saveNewUser(user) {
    if (user.isNew && !findOne(user.service_id, user.service)) {
        user.our_id = users.length + 1;
        user.isNew = false;
        users.push(user);
        writeMembershipFile();
    }
}

function findOrCreateUser(opts, callback) {
    var user = findOne(opts.profile[opts.property], opts.type);
    if (!user) {
        user = {
            our_id: null,
            service_id: opts.profile[opts.property],
            service: opts.type,
            name: opts.profile.name || opts.profile.username || opts.profile.screen_name,
            email: opts.profile.email,
            adminUser: false,
            linked_ids: [],
            isNew: true
        };
    }

    callback(user);
}

function makeAdmin(id, service) {
    var user = findOne(id, service);
    user.adminUser = true;
    writeMembershipFile();
    return findOne(id, service);
}

function serverCreateAccount(req, res, next) {
    var name = req.body.NickName;
    if (name && req.user && req.user.isNew) {
        req.user.name = name;
        saveNewUser(req.user);
        res.redirect(afterAuthenticateURL);
    } else {
        next();
    }
}

//when a new user authenticates when have
//to redirect them to a sign-up page
function serverSignUpNewUser(req, res, next) {
    try {
        if (req.user && req.user.isNew) {
            res.redirect(signUpURL);
        } else {
            next();
        }
    } catch (err) {
        console.log(err);
        next(err);
    }

}

function init(userList, server, dataPath) {
    users = userList || [];
    dataPath = dataPath || process.cwd();
    loadMembershipFile(dataPath);


    server.post(createAccountURL, serverCreateAccount);
    server.get(afterAuthenticateURL, serverSignUpNewUser);
}

function getUsers() {
    return users;
}

module.exports.init = init;
module.exports.saveNewUser = saveNewUser;
module.exports.findOrCreateUser = findOrCreateUser;
module.exports.makeAdmin = makeAdmin;
module.exports.getUsers = getUsers;