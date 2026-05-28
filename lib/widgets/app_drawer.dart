import 'package:flutter/material.dart';
import '../models/siswa.dart';
import '../screens/home_page.dart';
import '../screens/jenis_catatan_page.dart';
import '../screens/login_page.dart';
import '../screens/student_home_page.dart';

class AppDrawer extends StatelessWidget {
  final String role;
  final Siswa? siswa;
  const AppDrawer({super.key, required this.role, this.siswa});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Color(0xFF8A6E6A),
                  ),
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                if (role == 'guru')
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Data Siswa'),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage(role: role)),
                      );
                    },
                  ),
                if (role == 'siswa') ...[
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Beranda'),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      if (siswa != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => StudentHomePage(siswa: siswa!)),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.warning_amber_rounded),
                    title: const Text('Jenis Pelanggaran'),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => JenisCatatanPage(tipe: 'pelanggaran', role: role, siswa: siswa)),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.emoji_events),
                    title: const Text('Jenis Prestasi'),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => JenisCatatanPage(tipe: 'prestasi', role: role, siswa: siswa)),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
