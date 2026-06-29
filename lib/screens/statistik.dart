import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class StatistikScreen extends StatelessWidget {
  Future<Map<String, int>> _getStats() async {
    final data = await DBHelper.getData();
    Map<String, int> stats = {};
    for (var item in data) {
      String date = item['tanggal'];
      stats[date] = (stats[date] ?? 0) + 1;
    }
    return stats;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Statistik Aktivitas")),
      body: FutureBuilder(
        future: _getStats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          var stats = snapshot.data as Map<String, int>;
          return ListView(
            children: stats.entries
                .map(
                  (e) => ListTile(
                    title: Text("Tanggal: ${e.key}"),
                    trailing: Text("${e.value} Aktivitas"),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
