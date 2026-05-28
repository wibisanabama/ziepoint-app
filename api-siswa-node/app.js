const express = require("express");
const mysql = require("mysql2");
const cors = require("cors");
const bodyParser = require("body-parser");

const app = express();
app.use(cors());
app.use(bodyParser.json());

// --- KONEKSI KE MYSQL HOSTING ---
const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "db_sekolah",
});

db.connect((err) => {
  if (err) {
    console.error("Database Tidak Terhubung!", err);
    return;
  }
  console.log("Terhubung ke MySQL!");
});

// --- ROUTES ---

// 1. Get All Siswa
app.get("/siswa", (req, res) => {
  db.query("SELECT * FROM siswa", (err, results) => {
    if (err) return res.status(500).send(err);
    res.json(results);
  });
});

// 2. Post Siswa (Tambah Data)
app.post("/siswa", (req, res) => {
  const { nama, kelas, nis, password } = req.body;
  const pwd = password || "12345";
  const sql = "INSERT INTO siswa (nama, kelas, nis, password) VALUES (?, ?, ?, ?)";
  db.query(sql, [nama, kelas, nis, pwd], (err, result) => {
    if (err) return res.status(500).send(err);
    res.json({ message: "Data masuk!", id: result.insertId });
  });
});

// 3. Put Siswa (Update Data)
app.put("/siswa/:id", (req, res) => {
  const { id } = req.params;
  const { nama, kelas, nis, password } = req.body;
  
  if (password) {
    const sql = "UPDATE siswa SET nama = ?, kelas = ?, nis = ?, password = ? WHERE id_siswa = ?";
    db.query(sql, [nama, kelas, nis, password, id], (err, result) => {
      if (err) return res.status(500).send(err);
      res.json({ message: "Data diupdate!" });
    });
  } else {
    const sql = "UPDATE siswa SET nama = ?, kelas = ?, nis = ? WHERE id_siswa = ?";
    db.query(sql, [nama, kelas, nis, id], (err, result) => {
      if (err) return res.status(500).send(err);
      res.json({ message: "Data diupdate!" });
    });
  }
});

// 4. Delete Siswa
app.delete("/siswa/:id", (req, res) => {
  const { id } = req.params;
  db.query("DELETE FROM siswa WHERE id_siswa = ?", [id], (err) => {
    if (err) return res.status(500).send(err);
    res.json({ message: "Data dihapus!" });
  });
});

// Get Jenis Catatan Berdasarkan Tipe
app.get("/jenis_catatan/:tipe", (req, res) => {
  const { tipe } = req.params;

  const sql = "SELECT * FROM jenis_catatan WHERE tipe = ?";
  db.query(sql, [tipe], (err, results) => {
    if (err) return res.status(500).send(err);
    res.json(results);
  });
});

// Login Siswa
app.post("/login", (req, res) => {
  const { nis, password } = req.body;
  const sql = "SELECT * FROM siswa WHERE nis = ? AND password = ?";
  db.query(sql, [nis, password], (err, results) => {
    if (err) return res.status(500).send(err);
    if (results.length > 0) {
      res.json({ message: "Login berhasil!", user: results[0] });
    } else {
      res.status(401).json({ message: "NIS atau Password salah!" });
    }
  });
});

// Login Guru
app.post("/login_guru", (req, res) => {
  const { nip, password } = req.body;
  const sql = "SELECT * FROM guru WHERE nip = ? AND password = ?";
  db.query(sql, [nip, password], (err, results) => {
    if (err) return res.status(500).send(err);
    if (results.length > 0) {
      res.json({ message: "Login berhasil!", user: results[0] });
    } else {
      res.status(401).json({ message: "NIP atau Password salah!" });
    }
  });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server jalan di port ${PORT}`);
});