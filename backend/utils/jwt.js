const jwt = require('jsonwebtoken');

// Generate JWT Token
exports.generateToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET, {
        expiresIn: process.env.JWT_EXPIRE || '7d'
    });
};

// Send token response
exports.sendTokenResponse = (user, statusCode, res, message = 'Success') => {
    const token = this.generateToken(user._id);

    const userData = {
        _id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        profileImage: user.profileImage,
        address: user.address
    };

    res.status(statusCode).json({
        success: true,
        message,
        token,
        user: userData
    });
};
