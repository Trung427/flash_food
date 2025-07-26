const pool = require('./db');

async function addGoogleIdColumn() {
  try {
    console.log('Đang thêm cột google_id vào bảng users...');
    
    // Kiểm tra xem cột đã tồn tại chưa
    const [columns] = await pool.query("SHOW COLUMNS FROM users LIKE 'google_id'");
    
    if (columns.length === 0) {
      // Thêm cột google_id nếu chưa có
      await pool.query("ALTER TABLE users ADD COLUMN google_id VARCHAR(255) UNIQUE");
      console.log('✅ Đã thêm cột google_id thành công!');
    } else {
      console.log('ℹ️ Cột google_id đã tồn tại.');
    }
    
    // Hiển thị cấu trúc bảng sau khi thêm
    const [tableStructure] = await pool.query("DESCRIBE users");
    console.log('\n📋 Cấu trúc bảng users:');
    tableStructure.forEach(col => {
      console.log(`  - ${col.Field}: ${col.Type} ${col.Null === 'YES' ? 'NULL' : 'NOT NULL'}`);
    });
    
  } catch (error) {
    console.error('❌ Lỗi khi thêm cột google_id:', error);
  } finally {
    await pool.end();
  }
}

addGoogleIdColumn(); 