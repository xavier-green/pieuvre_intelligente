const express = require('express');
const validate = require('express-validation');
const paramValidation = require('./user.validation');
const multer = require('multer')
const upload = multer({ dest: 'uploads/' })
const userCtrl = require('./user.controller');

const router = express.Router(); // eslint-disable-line new-cap
router.route('/')
    /** GET /api/users - Get list of users */
    .get(userCtrl.list)
    /** POST /api/users - Create new user */
    .post(validate(paramValidation.createUser), userCtrl.create);
router.route('/:userId')
    /** GET /api/users/:userId - Get user */
    .get(userCtrl.get)
    /** PUT /api/users/:userId - Update user */
    .put(validate(paramValidation.updateUser), userCtrl.update)
    /** DELETE /api/users/:userId - Delete user */
    .delete(userCtrl.remove);

router.route('/:userId/upload')
      .post(upload.single('audiofile'), userCtrl.enroll)

router.route('/:userId/enrollCheck')
      .get(userCtrl.enrollCheck)
router.route('/identify')
      .post(validate(paramValidation.identify),userCtrl.identify)
router.route('/addIdentify')
      .post(upload.single('identifyfile'), userCtrl.addIdentifyFile)
router.route('/checkOperation')
      .post(validate(paramValidation.checkOperation),userCtrl.checkOperation)
/** Load user when API with userId route parameter is hit */
router.param('userId', userCtrl.load);
module.exports = exports = router;
