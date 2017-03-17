const Joi = require('joi');
module.exports = exports = {
    // POST /api/users
    createUser: {
        body: {
            username: Joi.string().regex(/[A-Za-z0-9]+/).required(),
        },
    },
    // UPDATE /api/users/:userId
    updateUser: {
        body: {
            username: Joi.string().required(),
        },
        params: {
            userId: Joi.string().required(),
        },
    },

    // POST /api/users/checkOperation
    checkOperation: {
        body: {
          url: Joi.string().required()
        },
    },
    identify: {
      body: {
        identificationProfiles: Joi.array().required()
      },
    },
};
