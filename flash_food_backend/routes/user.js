const express = require('express');
const router = express.Router();
const db = require('../db');
const { authenticateToken, requireAdmin } = require('../middleware/auth');
// const bcrypt = require('bcrypt'); // Bỏ bcrypt hoàn toàn

// Lưu FCM token cho user đã đăng nhập
router.post('/save-fcm-token', authenticateToken, async (req, res) => {
  const userId = req.user.id;
  const { fcm_token } = req.body;
  if (!fcm_token) return res.status(400).json({ error: 'FCM token is required' });
  try {
    await db.query('UPDATE users SET fcm_token = ? WHERE id = ?', [fcm_token, userId]);
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Lấy danh sách nhân viên
router.get('/staffs', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const [staffs] = await db.query('SELECT id, email, username, password, full_name, birthday, phone, avatar FROM users WHERE role = ?', ['staff']);
    res.json({ staffs });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Tạo tài khoản nhân viên
router.post('/staffs', authenticateToken, requireAdmin, async (req, res) => {
  const { email, username, password, full_name, birthday, phone } = req.body;
  if (!email || !username || !password) {
    return res.status(400).json({ error: 'Thiếu thông tin bắt buộc' });
  }
  try {
    // Kiểm tra email đã tồn tại chưa
    const [users] = await db.query('SELECT id FROM users WHERE email = ?', [email]);
    if (users.length > 0) {
      return res.status(409).json({ error: 'Email đã tồn tại' });
    }
    await db.query(
      'INSERT INTO users (email, username, password, full_name, birthday, phone, role) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [email, username, password, full_name || '', birthday || null, phone || '', 'staff']
    );
    res.status(201).json({ message: 'Tạo tài khoản nhân viên thành công' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Sửa thông tin nhân viên
router.put('/staffs/:id', authenticateToken, requireAdmin, async (req, res) => {
  const staffId = req.params.id;
  const { username, full_name, phone, password, role } = req.body;
  try {
    let query = 'UPDATE users SET username = ?, full_name = ?, phone = ?';
    const params = [username, full_name, phone];
    if (typeof password === 'string' && password.trim() !== '') {
      query += ', password = ?';
      params.push(password); // Lưu plain text
    }
    if (role) {
      query += ', role = ?';
      params.push(role);
    }
    query += ' WHERE id = ? AND role = ?';
    params.push(staffId, 'staff');
    await db.query(query, params);
    res.json({ message: 'Cập nhật thông tin nhân viên thành công' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Xoá nhân viên
router.delete('/staffs/:id', authenticateToken, requireAdmin, async (req, res) => {
  const staffId = req.params.id;
  try {
    await db.query('DELETE FROM users WHERE id = ? AND role = ?', [staffId, 'staff']);
    res.json({ message: 'Đã xoá nhân viên thành công' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Lấy danh sách khách hàng
router.get('/customers', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const [customers] = await db.query('SELECT id, email, username, password, full_name, birthday, phone, avatar FROM users WHERE role = ?', ['user']);
    res.json({ customers });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Tạo tài khoản khách hàng
router.post('/customers', authenticateToken, requireAdmin, async (req, res) => {
  const { email, username, password, full_name, birthday, phone } = req.body;
  if (!email || !username || !password) {
    return res.status(400).json({ error: 'Thiếu thông tin bắt buộc' });
  }
  try {
    // Kiểm tra email đã tồn tại chưa
    const [users] = await db.query('SELECT id FROM users WHERE email = ?', [email]);
    if (users.length > 0) {
      return res.status(409).json({ error: 'Email đã tồn tại' });
    }
    await db.query(
      'INSERT INTO users (email, username, password, full_name, birthday, phone, role) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [email, username, password, full_name || '', birthday || null, phone || '', 'user']
    );
    res.status(201).json({ message: 'Tạo tài khoản khách hàng thành công' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Sửa thông tin khách hàng
router.put('/customers/:id', authenticateToken, requireAdmin, async (req, res) => {
  const customerId = req.params.id;
  const { username, full_name, phone, password, role } = req.body;
  try {
    let query = 'UPDATE users SET username = ?, full_name = ?, phone = ?';
    const params = [username, full_name, phone];
    if (typeof password === 'string' && password.trim() !== '') {
      query += ', password = ?';
      params.push(password); // Lưu plain text
    }
    if (role) {
      query += ', role = ?';
      params.push(role);
    }
    query += ' WHERE id = ? AND role = ?';
    params.push(customerId, 'user');
    await db.query(query, params);
    res.json({ message: 'Cập nhật thông tin khách hàng thành công' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Xoá khách hàng
router.delete('/customers/:id', authenticateToken, requireAdmin, async (req, res) => {
  const customerId = req.params.id;
  try {
    await db.query('DELETE FROM users WHERE id = ? AND role = ?', [customerId, 'user']);
    res.json({ message: 'Đã xoá khách hàng thành công' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router; 