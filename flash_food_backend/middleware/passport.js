const passport = require('passport');
const GoogleStrategy = require('passport-google-oauth20').Strategy;
const FacebookStrategy = require('passport-facebook').Strategy;
const pool = require('../db'); // DB connection của bạn

// Serialize
passport.serializeUser((user, done) => {
  done(null, user.id);
});

// Deserialize
passport.deserializeUser(async (id, done) => {
  const [users] = await pool.query('SELECT * FROM users WHERE id = ?', [id]);
  done(null, users[0]);
});

// GOOGLE
passport.use(new GoogleStrategy({
    clientID: process.env.GOOGLE_CLIENT_ID,
    clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    callbackURL: '/auth/google/callback'
  },
  async (accessToken, refreshToken, profile, done) => {
    const email = profile.emails[0].value;
    const [users] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);

    if (users.length > 0) {
      return done(null, users[0]);
    } else {
      const username = profile.displayName;
      const result = await pool.query(
        'INSERT INTO users (email, username, role) VALUES (?, ?, ?)',
        [email, username, 'user']
      );
      const insertedId = result[0].insertId;
      const [newUser] = await pool.query('SELECT * FROM users WHERE id = ?', [insertedId]);
      return done(null, newUser[0]);
    }
  }
));

// FACEBOOK
//passport.use(new FacebookStrategy({
//   clientID: process.env.FB_APP_ID,
//   clientSecret: process.env.FB_APP_SECRET,
//   callbackURL: '/auth/facebook/callback',
//   profileFields: ['id', 'emails', 'displayName']
// },
// async (accessToken, refreshToken, profile, done) => {
//   const email = profile.emails[0].value;
//   const [users] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
//
//   if (users.length > 0) {
//     return done(null, users[0]);
//   } else {
//     const result = await pool.query(
//       'INSERT INTO users (email, username, role) VALUES (?, ?, ?)',
//       [email, username, 'user']
//     );
//     const insertedId = result[0].insertId;
//     const [newUser] = await pool.query('SELECT * FROM users WHERE id = ?', [insertedId]);
//     return done(null, newUser[0]);
//   }
// }
//)); 