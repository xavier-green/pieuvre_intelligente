const User = require('./user.model');
const request = require('request');
const fs = require('fs');

function callback(error, response, body) {
  if (!error && response.statusCode == 200) {
    var info = JSON.parse(body);
    console.log(info.stargazers_count + " Stars");
    console.log(info.forks_count + " Forks");
  }
}
/**
 * Load user and append to req.
 */
function load(req, res, next, username) {
    User.get(username).then((user) => {
        req.user = user;
        return next();
    }).error((e) => {
        e.isPublic = true;
        e.message = 'User not Found';
        return next(e);
    });
}
/**
 * Get user
 * @returns {User}
 */
function get(req, res) {
    return res.json(req.user);
}
/**
 * Create new user
 * @property {string} req.body.username - The username of user.
 * @property {string} req.body.mobileNumber - The mobileNumber of user.
 * @returns {User}
 */
function create(req, res, next) {
  request({
  url: 'https://westus.api.cognitive.microsoft.com/spid/v1.0/identificationProfiles', //URL to hit
  method: 'POST',
  headers: {
      'Ocp-Apim-Subscription-Key': '3d34db2432df4b9e88dc987ca5dd6e4c',
      'Content-Type': 'application/json',
  },
  body: JSON.stringify({"locale":"en-us"}) //Set the body as a string
}, function(error, response, body){
  if(error) {
      console.log("Error Message");
      console.log(error);
  } else {
      console.log("Response Message")
      console.log(response.body)
      const user = new User({
          username: req.body.username,
          identificationProfile: JSON.parse(response.body).identificationProfileId,
      });
      user.saveAsync()
          .then((savedUser) => res.json(savedUser))
          .error((e) => res.json(e));
  }
});
}
/**
 * Update existing user
 * @property {string} req.body.username - The username of user.
 * @property {string} req.body.mobileNumber - The mobileNumber of user.
 * @returns {User}
 */
function update(req, res, next) {
    const user = req.user;
    user.username = req.body.username;
    user.identificationProfile = req.body.identificationProfile;
    user.status = req.body.status;
    user.saveAsync()
        .then((savedUser) => res.json(savedUser))
        .error((e) => next(e));
}
/**
 * Get user list.
 * @property {number} req.query.skip - Number of users to be skipped.
 * @property {number} req.query.limit - Limit number of users to be returned.
 * @returns {User[]}
 */
function list(req, res, next) {
    const { limit = 50, skip = 0 } = req.query;
    User.list({ limit, skip }).then((users) => res.json(users))
        .error((e) => next(e));
}
/**
 * Delete user.
 * @returns {User}
 */
function remove(req, res, next) {
    const user = req.user;
    let uri = 'https://westus.api.cognitive.microsoft.com/spid/v1.0/identificationProfiles/' + req.user.identificationProfile
    request({
        url: uri, //URL to hit
        method: 'DELETE',
        encoding: null,
        headers: {
            'Ocp-Apim-Subscription-Key': '3d34db2432df4b9e88dc987ca5dd6e4c',
        },
      }, function(error, response, body){
      if(error) {
          res.json(error)
      } else {
          res.json(response)
      }
    });
    user.removeAsync()
        .then((deletedUser) => res.json(deletedUser))
        .error((e) => next(e));
}

function enroll(req,res) {
  const user = req.user;
  console.log("gettting file")
  let uri = 'https://westus.api.cognitive.microsoft.com/spid/v1.0/identificationProfiles/' + req.user.identificationProfile + '/enroll?shortAudio=true'
  request({
      url: uri, //URL to hit
      method: 'POST',
      encoding: null,
      headers: {
          'Ocp-Apim-Subscription-Key': '3d34db2432df4b9e88dc987ca5dd6e4c',
          'Content-Type': 'application/octet-stream',
      },
      body: fs.readFileSync(req.file.path) //Set the body as a string
    }, function(error, response, body){
    if(error) {
        res.json(error)
    } else {
        console.log("Got file")
        fs.unlink(req.file.path);
        console.log(response.headers)
        user.status = "Enrolling"
        user.saveAsync()
            .then((savedUser) => {res.json(savedUser)})
            .error((e) => res.json(e));
    }
  });
}

function enrollCheck(req,res) {
  const user = req.user;
  console.log("user:",user)
  request({
      url: 'https://westus.api.cognitive.microsoft.com/spid/v1.0/identificationProfiles/' + req.user.identificationProfile, //URL to hit
      method: 'GET',
      headers: {
          'Ocp-Apim-Subscription-Key': '3d34db2432df4b9e88dc987ca5dd6e4c',
      },
    }, function(error, response, body){
    if(error) {
        console.log('error')
        res.json(error)
    } else {
        console.log("response", response)
        user.status = JSON.parse(response.body).enrollmentStatus
        user.saveAsync()
            .then((savedUser) => {res.json(savedUser)})
            .error((e) => res.json(e));
    }
  });
}

function identify(req,res) {
  const ids = req.body.identificationProfiles
  const uri = ids.join(',')
  console.log("id=",ids.length)
  console.log("uri=",uri)
        request({
                url: 'https://westus.api.cognitive.microsoft.com/spid/v1.0/identify?identificationProfileIds=' + uri + '&shortAudio=true',
                method: 'POST',
                encoding: null,
                headers: {
                    'Ocp-Apim-Subscription-Key': '3d34db2432df4b9e88dc987ca5dd6e4c',
                    'Content-Type': 'application/octet-stream',
                },
                body: fs.readFileSync("uploads/identify") //Set the body as a string
              }, function(error, response, body){
              if(error) {
                  res.json(error)
              } else {
                  fs.unlink("uploads/identify");
                  console.log(response.headers["operation-location"])
                  res.json(response.headers["operation-location"])
              }
            });
}
function checkOperation(req,res) {
  request({
          url: req.body.url,
          method: 'GET',
          headers: {
              'Ocp-Apim-Subscription-Key': '3d34db2432df4b9e88dc987ca5dd6e4c',
          },
        }, function(error, response, body){
        if(error) {
          console.log("error")
          res.json(error2)
        } else {
          if (JSON.parse(response.body).status == "succeeded") {
            console.log("succeded")
            User.findOne({identificationProfile:JSON.parse(response.body).processingResult.identifiedProfileId})
                .then((user) => res.json(user))
          } else {
            res.json(JSON.parse(response.body))
            console.log(req.url)
          }

        }
    })
}
function addIdentifyFile(req,res) {
  fs.renameSync(req.file.path,"uploads/identify")
  res.json(req.file)
}


module.exports = exports = { load, get, create, update, list, remove, enroll, enrollCheck, addIdentifyFile, identify, checkOperation };
