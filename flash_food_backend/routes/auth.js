const express = require('express');
const jwt = require('jsonwebtoken');
const pool = require('../db');
const router = express.Router();
const SECRET = process.env.JWT_SECRET || 'your_secret_key';
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { authenticateToken } = require('../middleware/auth');
const axios = require('axios');
const FIREBASE_API_KEY = 'AIzaSyDmp61DSCZu1FpazgC1Ym7QcxX-qBejBgI'; // Từ Firebase Web config


// Thiết lập lưu file avatar
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const dir = 'uploads/avatars/';
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: function (req, file, cb) {
    const ext = path.extname(file.originalname);
    cb(null, 'user_' + req.user.id + '_' + Date.now() + ext);
  }
});
const upload = multer({ storage: storage });

// Đăng ký tài khoản
router.post('/register', async (req, res) => {
  const { email, username, password, phone } = req.body;

  if (!email || !password || !username || !phone) {
    return res.status(400).json({ message: 'Thiếu thông tin' });
  }

  const passwordRegex = /^(?=.*[A-Z])(?=.*[!@#$%^&*()_+{}\[\]:;<>,.?~\\/-]).{8,}$/;
  if (!passwordRegex.test(password)) {
    return res.status(400).json({
      message: 'Mật khẩu phải có ít nhất 8 ký tự, 1 chữ hoa và 1 ký tự đặc biệt'
    });
  }

  const [users] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
  if (users.length > 0) {
    return res.status(409).json({ message: 'Email đã tồn tại' });
  }

  try {
    // 1. Đăng ký Firebase để gửi xác minh
    const fbRes = await axios.post(`https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${FIREBASE_API_KEY}`, {
      email,
      password,
      returnSecureToken: true
    });

    const idToken = fbRes.data.idToken;

    // 2. Gửi email xác minh
    await axios.post(`https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=${FIREBASE_API_KEY}`, {
      requestType: 'VERIFY_EMAIL',
      idToken
    });

    // 3. Lưu user vào MySQL
    await pool.query(
      'INSERT INTO users (email, username, password, phone, role) VALUES (?, ?, ?, ?, ?)',
      [email, username, password, phone, 'user']
    );

    res.status(201).json({
      message: 'Đăng ký thành công. Vui lòng xác minh email.',
      verify_sent: true
    });
  } catch (error) {
    console.error('Firebase error:', error.response?.data || error);
    res.status(500).json({ message: 'Lỗi xác minh email với Firebase' });
  }
});



router.post('/login', async (req, res) => {
  console.log('Login request:', req.body);
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ message: 'Thiếu thông tin' });
  }
  const [users] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
  if (users.length === 0) {
    return res.status(401).json({ message: 'Sai tài khoản hoặc mật khẩu' });
  }
  const user = users[0];
  if (user.password !== password) {
    return res.status(401).json({ message: 'Sai tài khoản hoặc mật khẩu' });
  }
  const token = jwt.sign({ id: user.id, role: user.role }, SECRET, { expiresIn: '7d' });
  res.json({
    message: 'Đăng nhập thành công',
    token,
    role: user.role,
    username: user.username,
    email: user.email
  });
});

// Lấy thông tin cá nhân
router.get('/me', authenticateToken, async (req, res) => {
  const userId = req.user.id;
  const [users] = await pool.query('SELECT id, email, username, full_name, birthday, phone, avatar FROM users WHERE id = ?', [userId]);
  if (users.length === 0) return res.status(404).json({ message: 'User not found' });
  res.json(users[0]);
});

// Cập nhật thông tin cá nhân
router.put('/me', authenticateToken, async (req, res) => {
  const userId = req.user.id;
  const { full_name, birthday, phone, avatar } = req.body;
  // Validate phone là số
  if (phone && !/^[0-9]+$/.test(phone)) {
    return res.status(400).json({ message: 'Số điện thoại không hợp lệ' });
  }
  // Validate birthday là ngày hợp lệ
  if (birthday && isNaN(Date.parse(birthday))) {
    return res.status(400).json({ message: 'Ngày sinh không hợp lệ' });
  }
  await pool.query(
    'UPDATE users SET full_name = ?, birthday = ?, phone = ?, avatar = ? WHERE id = ?',
    [full_name, birthday, phone, avatar, userId]
  );
  res.json({ success: true, message: 'Cập nhật thông tin thành công' });
});

// Upload avatar
router.post('/avatar', authenticateToken, upload.single('avatar'), async (req, res) => {
  if (!req.file) return res.status(400).json({ message: 'No file uploaded' });
  const avatarPath = '/uploads/avatars/' + req.file.filename;
  await pool.query('UPDATE users SET avatar = ? WHERE id = ?', [avatarPath, req.user.id]);
  res.json({ success: true, avatar: avatarPath });
});

// Đăng nhập bằng Firebase ID Token
router.post('/google-login', async (req, res) => {
  const { token } = req.body; // Chỉ nhận token từ frontend
  if (!token) {
    return res.status(400).json({ message: 'Thiếu Firebase ID Token' });
  }

  try {
    // Dùng Firebase Admin để xác thực token
    const admin = require('firebase-admin');
    const decodedToken = await admin.auth().verifyIdToken(token);

    // Lấy thông tin user từ token đã giải mã
    const google_id = decodedToken.uid; // <-- CHÍNH LÀ DÒNG NÀY!
    const email = decodedToken.email;
    const name = decodedToken.name || '';

    // Kiểm tra user đã tồn tại trong DB của bạn bằng google_id chưa
    let [users] = await pool.query('SELECT * FROM users WHERE google_id = ?', [google_id]);
    let user;

    if (users.length === 0) {
      // Nếu chưa có, tạo mới user
      // Có thể kiểm tra thêm email có tồn tại với phương thức đăng nhập khác không
      const [existingEmail] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
      if (existingEmail.length > 0) {
          // Nếu email đã tồn tại nhưng google_id thì chưa -> nối tài khoản
          await pool.query('UPDATE users SET google_id = ? WHERE email = ?', [google_id, email]);
          user = existingEmail[0];
          user.google_id = google_id; // gán lại để tạo token
      } else {
          // Tạo mới hoàn toàn
          const result = await pool.query(
            'INSERT INTO users (email, username, role, google_id) VALUES (?, ?, ?, ?)',
            [email, name, 'user', google_id]
          );
          const [newUsers] = await pool.query('SELECT * FROM users WHERE id = ?', [result[0].insertId]);
          user = newUsers[0];
      }
    } else {
      // Nếu user đã tồn tại, lấy thông tin ra
      user = users[0];
    }

    // Tạo JWT token của chính backend và trả về cho client
    const backendToken = jwt.sign({ id: user.id, role: user.role }, SECRET, { expiresIn: '7d' });

    res.json({
      message: 'Đăng nhập Google thành công',
      token: backendToken, // Trả về token của backend
      role: user.role,
      username: user.username,
      email: user.email
    });

  } catch (error) {
    // Nếu token không hợp lệ
    console.error('Lỗi xác thực Firebase token:', error);
    return res.status(401).json({ message: 'Token không hợp lệ hoặc đã hết hạn' });
  }
});

// Kiểm tra email đã xác minh chưa
router.get('/check-verified', async (req, res) => {
  const { email } = req.query;
  if (!email) return res.status(400).json({ message: 'Thiếu email' });

  try {
    const admin = require('firebase-admin');
    const user = await admin.auth().getUserByEmail(email);

    res.json({
      emailVerified: user.emailVerified,
      message: user.emailVerified ? 'Email đã được xác minh' : 'Email chưa xác minh'
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Lỗi khi kiểm tra trạng thái xác minh' });
  }
});


router.post('/resend-verification', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ message: 'Thiếu thông tin' });

  try {
    // Đăng nhập Firebase để lấy idToken
    const fbRes = await axios.post(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${FIREBASE_API_KEY}`, {
      email,
      password,
      returnSecureToken: true
    });

    const idToken = fbRes.data.idToken;

    await axios.post(`https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=${FIREBASE_API_KEY}`, {
      requestType: 'VERIFY_EMAIL',
      idToken
    });

    res.json({ message: 'Đã gửi lại email xác minh' });
  } catch (err) {
    console.error(err.response?.data || err);
    res.status(500).json({ message: 'Không thể gửi lại email xác minh' });
  }
});


module.exports = router;