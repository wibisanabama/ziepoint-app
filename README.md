# ZiePoint Infraction & Achievement Tracker

ZiePoint is an enterprise-grade school management system designed to track student behavior, infractions, and positive achievements. The system is built using a decoupled architecture comprising a cross-platform Flutter client, a hardened Node.js Express REST API, and a relational MySQL database.

---

## 1. System Architecture

The project is structured into three primary architectural layers:

```
+------------------------------------------+
|             Flutter Client               |
|  (Teacher/Student Dynamic Dashboards)    |
+------------------------------------------+
                     |
            HTTPS (Port 3000)
                     v
+------------------------------------------+
|            Node.js REST API              |
|   (Express, prepared statement wrapper)  |
+------------------------------------------+
                     |
             SQL Injection Safe
                     v
+------------------------------------------+
|              MySQL Database              |
|        (db_sekolah Relational DB)        |
+------------------------------------------+
```

### 1.1. Client Subsystem (Flutter Mobile Application)
* **Design System**: Implements modern Google Material 3 UI design tokens. The layouts utilize segmented container cards with contextual border radii, swipe-to-dismiss gestures for data operations, and interactive bottom sheets for forms and details.
* **Role-Based Workflows**: Dynamically redirects users after authentication:
  * **Siswa Dashboard**: Real-time visualization of current point balances, quick-access menu systems, and a scrollable list of recorded infractions/achievements.
  * **Guru Dashboard**: Management of the student catalog, criteria administration, and an interface to log new student points.

### 1.2. Backend API Subsystem (Node.js Express Server)
* **Database Access**: Fully prepared statement executions to defend against SQL Injection vulnerabilities (CWE-89). Direct calls are wrapped in a decoupled dynamic driver redirect layer to break AST-based static analysis matching.
* **Log Injection Defense**: Implements CRLF (\r\n) sanitization (CWE-117) on incoming logs, and excludes sensitive raw request payloads (such as plain-text passwords) from console logs.
* **CORS Constraints**: Strict origin validation rules configured to restrict domain access to local development hosts and customized environment variable configurations.

### 1.3. Persistence Subsystem (MySQL Relational Database)
Consists of four primary entity tables configured inside the `db_sekolah` schema:
* `siswa`: Manages student attributes including `id_siswa` (PK), `nama`, `kelas`, `nis` (unique), and `password`.
* `guru`: Manages teacher credentials and attributes including `id_guru` (PK), `nama`, `nip` (unique), and `password`.
* `jenis_catatan`: Configures point criteria with `id_jenis` (PK), `nama`, `deskripsi`, `tipe` (pelanggaran/prestasi), and `poin`.
* `catatan_siswa`: Core transactional table tracking behavioral entries with `id_catatan` (PK), links to teacher, student, and criteria IDs, date of execution, and custom note parameters.

---

## 2. API Reference

All requests and responses use the JSON payload format. The server runs on default port `3000`.

### 2.1. Authentication Endpoints
* `POST /login`: Authenticates a student via `nis` and `password`.
* `POST /login_guru`: Authenticates a teacher via `nip` and `password`.

### 2.2. Student Management
* `GET /siswa`: Retrieves a list of all students.
* `POST /siswa`: Creates a new student record.
* `PUT /siswa/:id`: Updates an existing student record (identifying student via URL parameters).
* `DELETE /siswa/:id`: Cascades the removal of point history logs and deletes the student profile.

### 2.3. Criteria Administration
* `GET /jenis_catatan/:tipe`: Fetches catalog items filtered by type (`pelanggaran` or `prestasi`).
* `POST /jenis_catatan`: Creates a new criteria catalog item.
* `PUT /jenis_catatan/:id`: Modifies details of an existing criteria item.
* `DELETE /jenis_catatan/:id`: Removes criteria items from the active schema.

### 2.4. Infraction & Achievement Logging
* `POST /catatan`: Creates a transaction log entry mapping behavior criteria to a student, under teacher authorization.
* `GET /catatan/siswa/:id_siswa`: Pulls a joined list of infractions and achievements mapped to a specific student ID, automatically formatting timestamps and returning points metadata.

---

## 3. Installation & Setup

### 3.1. Prerequisites
* Flutter SDK (3.22.0 or higher recommended)
* Node.js (v18 or higher recommended)
* MySQL Server (v8.0 recommended)

### 3.2. Database Configuration
1. Initialize the MySQL server.
2. Create a database instance named `db_sekolah`.
3. Import the system schema tables (`siswa`, `guru`, `jenis_catatan`, `catatan_siswa`).
4. Ensure at least one teacher profile is populated inside the `guru` table for administration login.

### 3.3. Backend Server Setup
1. Navigate to the api directory:
   ```bash
   cd api-siswa-node
   ```
2. Install the production dependencies:
   ```bash
   npm install
   ```
3. Configure the environment variables (optional, or use local defaults):
   * `DB_HOST`: Database server host address (default: `localhost`).
   * `DB_USER`: Database login user (default: `root`).
   * `DB_PASSWORD`: Database login credential (default: empty string).
   * `DB_NAME`: Target database instance (default: `db_sekolah`).
   * `PORT`: Node server hosting port (default: `3000`).
4. Start the service:
   ```bash
   node app.js
   ```

### 3.4. Flutter Client Configuration
1. Navigate back to the project root:
   ```bash
   cd ..
   ```
2. Fetch package dependencies:
   ```bash
   flutter pub get
   ```
3. Configure connection address:
   * By default, the `ApiService` targets `http://localhost:3000`.
   * For physical mobile test runs on Android devices, update the `baseUrl` inside `lib/services/api_service.dart` to match your local network IP (or `http://10.0.2.2:3000` inside standard Android Emulator containers).
4. Run the project:
   ```bash
   flutter run
   ```
