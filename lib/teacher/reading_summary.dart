// lib/teacher/reading_summary.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class ReadingSummaryScreen extends StatefulWidget {
  @override
  _ReadingSummaryScreenState createState() => _ReadingSummaryScreenState();
}

class _ReadingSummaryScreenState extends State<ReadingSummaryScreen> {
  Map<String, Map<String, int>> _classRoomData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReadingData();
  }

  Future<void> _loadReadingData() async {
    setState(() => _isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();

      Map<String, Map<String, int>> stats = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final grade = data['grade'] as String?;
        final classRoom = data['classRoom'] as String?;

        if (grade == null || classRoom == null) continue;

        final key = '$grade ห้อง$classRoom';

        if (!stats.containsKey(key)) {
          stats[key] = {'read': 0, 'notRead': 0};
        }

        if (data['bookRead'] == true) {
          stats[key]!['read'] = (stats[key]!['read'] ?? 0) + 1;
        } else {
          stats[key]!['notRead'] = (stats[key]!['notRead'] ?? 0) + 1;
        }
      }

      // เรียงตามชั้นและห้อง
      final sortedKeys = stats.keys.toList()
        ..sort((a, b) {
          final aParts = a.split(' ห้อง');
          final bParts = b.split(' ห้อง');
          if (aParts[0] == bParts[0]) {
            return int.tryParse(aParts[1])?.compareTo(int.tryParse(bParts[1]) ?? 0) ?? 0;
          }
          return aParts[0].compareTo(bParts[0]);
        });

      Map<String, Map<String, int>> sortedStats = {};
      for (final key in sortedKeys) {
        sortedStats[key] = stats[key]!;
      }

      setState(() {
        _classRoomData = sortedStats;
      });

    } catch (e) {
      print('Error loading reading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('โหลดข้อมูลไม่สำเร็จ')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('สรุปการอ่านเนื้อหา'),
        backgroundColor: Color(0xFF6A11CB),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _classRoomData.isEmpty
              ? Center(child: Text('ไม่มีข้อมูลนักเรียน'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _classRoomData.entries.map((entry) {
                        final room = entry.key;
                        final read = entry.value['read'] ?? 0;
                        final notRead = entry.value['notRead'] ?? 0;
                        final total = read + notRead;

                        // คำนวณเปอร์เซ็นต์
                        final readPercent = total > 0 ? (read / total * 100).toStringAsFixed(0) : '0';
                        final notReadPercent = total > 0 ? (notRead / total * 100).toStringAsFixed(0) : '0';

                        return Card(
                          margin: EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  room,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 12),
                                SizedBox(
                                  height: 200,
                                  child: PieChart(
                                    PieChartData(
                                      sections: [
                                        PieChartSectionData(
                                          value: read.toDouble(),
                                          color: Colors.green,
                                          title: '$readPercent%',
                                          radius: 40,
                                        ),
                                        PieChartSectionData(
                                          value: notRead.toDouble(),
                                          color: Colors.red,
                                          title: '$notReadPercent%',
                                          radius: 40,
                                        ),
                                      ],
                                      centerSpaceRadius: 30,
                                      sectionsSpace: 2,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text('✅ อ่านแล้ว: $read คน'),
                                    Text('❌ ยังไม่อ่าน: $notRead คน'),
                                    Text('📊 รวม: $total คน'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
    );
  }
}