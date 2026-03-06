const mongoose = require('mongoose');

const getMongoHostForLog = (uri) => {
    if (!uri) return 'MONGODB_URI not set';
    try {
        if (uri.startsWith('mongodb+srv://')) {
            const afterAt = uri.split('@')[1];
            if (!afterAt) return 'invalid mongodb+srv uri';
            return afterAt.split('/')[0] || 'invalid mongodb+srv uri';
        }
        const parsed = new URL(uri);
        return parsed.host || 'invalid mongodb uri';
    } catch (e) {
        return 'invalid mongodb uri';
    }
};

const connectDB = async () => {
    try {
        if (!process.env.MONGODB_URI) {
            throw new Error('MONGODB_URI is not set');
        }

        console.log(`MongoDB URI Host: ${getMongoHostForLog(process.env.MONGODB_URI)}`);

        const conn = await mongoose.connect(process.env.MONGODB_URI, {
            useNewUrlParser: true,
            useUnifiedTopology: true
        });

        console.log(`MongoDB Connected: ${conn.connection.host}`);
    } catch (error) {
        console.error(`Error: ${error.message}`);
        process.exit(1);
    }
};

module.exports = connectDB;
