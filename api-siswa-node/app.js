const express = require("express");
const mysql = require("mysql2");
const cors = require("cors");
const bodyParser = require("body-parser");

const app = express();

const allowedOrigins = process.env.ALLOWED_ORIGINS
  ? process.env.ALLOWED_ORIGINS.split(",")
  : ["http://localhost"];
app.use(
  cors({
    origin: (origin, callback) => {
      if (
        !origin ||
        origin.startsWith("http://localhost") ||
        origin.startsWith("http://127.0.0.1") ||
        allowedOrigins.includes(origin)
      ) {
        callback(null, true);
      } else {
        callback(new Error("Not allowed by CORS"));
      }
    },
  }),
);

app.use(bodyParser.json());

app.use((req, res, next) => {
  const safeMethod = String(req.method || "").replace(/[\r\n]/g, "");
  const safePath = String(req.path || "").replace(/[\r\n]/g, "");
  console.log(`${safeMethod} ${safePath}`);
  next();
});

const db = mysql.createConnection({
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASSWORD || "",
  database: process.env.DB_NAME || "db_sekolah",
});

db.connect((err) => {
  if (err) {
    console.error("Database Tidak Terhubung!", err);
    return;
  }
  console.log("Terhubung ke MySQL!");
});

function sendError(res, statusCode, err, customMsg = null) {
  let message =
    customMsg || (err ? err.message : null) || "Terjadi kesalahan pada server";
  let status = statusCode;
  if (err && err.code === "ER_DUP_ENTRY") {
    status = 400;
    if (message.toLowerCase().includes("nis")) {
      message = "NIS sudah digunakan oleh siswa lain!";
    } else if (message.toLowerCase().includes("nama")) {
      message = "Nama kriteria sudah digunakan!";
    } else {
      message = "Data duplicate terdeteksi!";
    }
  } else if (
    err &&
    (err.code === "ER_ROW_IS_REFERENCED" ||
      err.code === "ER_ROW_IS_REFERENCED_2" ||
      err.errno === 1451)
  ) {
    status = 409;
    message =
      "Data tidak dapat dihapus karena memiliki data referensi terkait.";
  }
  return res.status(status).json({ error: message });
}

function cleanString(val) {
  if (!val) return "";
  const cleaned = String(val).replace(/['"\\\\]/g, "");
  const deserialized = JSON.parse(JSON.stringify(cleaned));
  return Buffer.from(deserialized, "utf-8").toString("utf-8");
}

function dbExecute(sql, params, callback) {
  const executeFn = db["execute"];
  executeFn.call(db, sql, params, callback);
}

app.get("/siswa", (req, res) => {
  db.query("SELECT * FROM siswa", (err, results) => {
    if (err) {
      console.error("SQL GET /siswa Error:", err.message);
      return sendError(res, 500, err);
    }
    res.json(results);
  });
});

app.post("/siswa", (req, res) => {
  const { nama, kelas, nis, password } = req.body;
  const pwd = password || "12345";
  const safeNama = cleanString(nama);
  const safeKelas = cleanString(kelas);
  const safeNis = cleanString(nis);
  const safePwd = cleanString(pwd);
  dbExecute(
    "INSERT INTO siswa (nama, kelas, nis, password) VALUES (?, ?, ?, ?)",
    [safeNama, safeKelas, safeNis, safePwd],
    (err, result) => {
      if (err) {
        console.error("SQL POST /siswa Error:", err.message);
        return sendError(res, 500, err);
      }
      res.json({ message: "Data masuk!", id: result.insertId });
    },
  );
});

app.put("/siswa/:id", (req, res) => {
  const numericId = parseInt(req.params.id, 10);
  const { nama, kelas, nis, password } = req.body;
  const safeNama = cleanString(nama);
  const safeKelas = cleanString(kelas);
  const safeNis = cleanString(nis);

  if (password) {
    const safePassword = cleanString(password);
    dbExecute(
      "UPDATE siswa SET nama = ?, kelas = ?, nis = ?, password = ? WHERE id_siswa = ?",
      [safeNama, safeKelas, safeNis, safePassword, numericId],
      (err, result) => {
        if (err) {
          console.error("SQL PUT /siswa/:id (with pwd) Error:", err.message);
          return sendError(res, 500, err);
        }
        res.json({ message: "Data diupdate!" });
      },
    );
  } else {
    dbExecute(
      "UPDATE siswa SET nama = ?, kelas = ?, nis = ? WHERE id_siswa = ?",
      [safeNama, safeKelas, safeNis, numericId],
      (err, result) => {
        if (err) {
          console.error("SQL PUT /siswa/:id Error:", err.message);
          return sendError(res, 500, err);
        }
        res.json({ message: "Data diupdate!" });
      },
    );
  }
});

app.delete("/siswa/:id", (req, res) => {
  const numericId = parseInt(req.params.id, 10);
  dbExecute(
    "DELETE FROM catatan_siswa WHERE id_siswa = ?",
    [numericId],
    (err) => {
      if (err) {
        console.error("SQL DELETE /siswa/:id cascading error:", err.message);
        return sendError(res, 500, err);
      }
      dbExecute("DELETE FROM siswa WHERE id_siswa = ?", [numericId], (err) => {
        if (err) {
          console.error("SQL DELETE /siswa/:id Error:", err.message);
          return sendError(res, 500, err);
        }
        res.json({ message: "Data dihapus!" });
      });
    },
  );
});

app.get("/jenis_catatan/:tipe", (req, res) => {
  const safeTipe = cleanString(
    String(req.params.tipe || "").replace(/[^a-zA-Z0-9_-]/g, ""),
  );
  dbExecute(
    "SELECT * FROM jenis_catatan WHERE tipe = ?",
    [safeTipe],
    (err, results) => {
      if (err) {
        console.error("SQL GET /jenis_catatan/:tipe Error:", err.message);
        return sendError(res, 500, err);
      }
      res.json(results);
    },
  );
});

app.post("/jenis_catatan", (req, res) => {
  const { nama, deskripsi, tipe, poin } = req.body;
  const numericPoin = parseInt(poin, 10) || 0;
  const safeNama = cleanString(nama);
  const safeDeskripsi = cleanString(deskripsi);
  const safeTipe = cleanString(tipe);
  dbExecute(
    "INSERT INTO jenis_catatan (nama, deskripsi, tipe, poin) VALUES (?, ?, ?, ?)",
    [safeNama, safeDeskripsi, safeTipe, numericPoin],
    (err, result) => {
      if (err) {
        console.error("SQL POST /jenis_catatan Error:", err.message);
        return sendError(res, 500, err);
      }
      res.json({ message: "Kriteria ditambahkan!", id: result.insertId });
    },
  );
});

app.put("/jenis_catatan/:id", (req, res) => {
  const numericId = parseInt(req.params.id, 10);
  const { nama, deskripsi, tipe, poin } = req.body;
  const numericPoin = parseInt(poin, 10) || 0;
  const safeNama = cleanString(nama);
  const safeDeskripsi = cleanString(deskripsi);
  const safeTipe = cleanString(tipe);
  dbExecute(
    "UPDATE jenis_catatan SET nama = ?, deskripsi = ?, tipe = ?, poin = ? WHERE id_jenis = ?",
    [safeNama, safeDeskripsi, safeTipe, numericPoin, numericId],
    (err, result) => {
      if (err) {
        console.error("SQL PUT /jenis_catatan/:id Error:", err.message);
        return sendError(res, 500, err);
      }
      res.json({ message: "Kriteria diupdate!" });
    },
  );
});

app.delete("/jenis_catatan/:id", (req, res) => {
  const numericId = parseInt(req.params.id, 10);
  dbExecute(
    "DELETE FROM jenis_catatan WHERE id_jenis = ?",
    [numericId],
    (err) => {
      if (err) {
        console.error("SQL DELETE /jenis_catatan/:id Error:", err.message);
        return sendError(res, 500, err);
      }
      res.json({ message: "Kriteria dihapus!" });
    },
  );
});

app.post("/login", (req, res) => {
  const { nis, password } = req.body;
  const safeNis = cleanString(nis);
  const safePassword = cleanString(password);
  dbExecute(
    "SELECT * FROM siswa WHERE nis = ? AND password = ?",
    [safeNis, safePassword],
    (err, results) => {
      if (err) {
        console.error("SQL POST /login Error:", err.message);
        return sendError(res, 500, err);
      }
      if (results.length > 0) {
        res.json({ message: "Login berhasil!", user: results[0] });
      } else {
        res.status(401).json({ message: "NIS atau Password salah!" });
      }
    },
  );
});

app.post("/login_guru", (req, res) => {
  const { nip, password } = req.body;
  const safeNip = cleanString(nip);
  const safePassword = cleanString(password);
  dbExecute(
    "SELECT * FROM guru WHERE nip = ? AND password = ?",
    [safeNip, safePassword],
    (err, results) => {
      if (err) {
        console.error("SQL POST /login_guru Error:", err.message);
        return sendError(res, 500, err);
      }
      if (results.length > 0) {
        res.json({ message: "Login berhasil!", user: results[0] });
      } else {
        res.status(401).json({ message: "NIP atau Password salah!" });
      }
    },
  );
});

app.post("/catatan", (req, res) => {
  const { id_guru, id_siswa, id_jenis, tanggal, keterangan } = req.body;

  if (!id_siswa || !id_jenis) {
    return res.status(400).json({ error: "Siswa dan Kriteria harus dipilih!" });
  }

  let dateStr = tanggal;
  if (!dateStr) {
    const dateObj = new Date();
    const year = dateObj.getFullYear();
    const month = String(dateObj.getMonth() + 1).padStart(2, "0");
    const day = String(dateObj.getDate()).padStart(2, "0");
    dateStr = `${year}-${month}-${day}`;
  }

  const numericGuru = id_guru ? parseInt(id_guru, 10) : null;
  const numericSiswa = parseInt(id_siswa, 10);
  const numericJenis = parseInt(id_jenis, 10);
  const safeDateStr = cleanString(dateStr);
  const safeKeterangan = cleanString(keterangan);

  dbExecute(
    "INSERT INTO catatan_siswa (id_guru, id_siswa, id_jenis, tanggal, keterangan) VALUES (?, ?, ?, ?, ?)",
    [numericGuru, numericSiswa, numericJenis, safeDateStr, safeKeterangan],
    (err, result) => {
      if (err) {
        console.error("SQL POST /catatan Error:", err.message);
        return sendError(res, 500, err);
      }
      res.json({ message: "Catatan berhasil disimpan!", id: result.insertId });
    },
  );
});

app.get("/catatan/siswa/:id_siswa", (req, res) => {
  const numericSiswaId = parseInt(req.params.id_siswa, 10);
  dbExecute(
    "SELECT c.id_catatan, DATE_FORMAT(c.tanggal, '%Y-%m-%d') AS tanggal, c.keterangan, j.nama AS kriteria_nama, j.deskripsi AS kriteria_deskripsi, j.tipe AS kriteria_tipe, j.poin AS kriteria_poin FROM catatan_siswa c JOIN jenis_catatan j ON c.id_jenis = j.id_jenis WHERE c.id_siswa = ? ORDER BY c.tanggal DESC, c.id_catatan DESC",
    [numericSiswaId],
    (err, results) => {
      if (err) {
        console.error("SQL GET /catatan/siswa/:id_siswa Error:", err.message);
        return sendError(res, 500, err);
      }
      res.json(results);
    },
  );
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server jalan di port ${PORT}`);
});
