// lib/teacher/post_test_completion.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class PostTestCompletionScreen extends StatefulWidget {
  @override
  _PostTestCompletionScreenState createState() => _PostTestCompletionScreenState();
}

class _PostTestCompletionScreenState extends State<PostTestCompletionScreen> {
  Map<String, Map<String, int>> _classRoomData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPostTestCompletionData();
  }

  Future<void> _loadPostTestCompletionData() async {
    setState(() => _isLoading = true);

    try {
      // 🔹 ขั้นตอน 1: ดึงรายชื่อนักเรียนจาก users
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();

      Map<String, String> studentInfo = {}; // uid -> "grade ห้องclassRoom"
      Map<String, List<String>> classRooms = {}; // "grade ห้องclassRoom" -> [uid]

      for (final doc in userSnapshot.docs) {
        final data = doc.data();
        final uid = doc.id;
        final grade = data['grade'] as String?;
        final classRoom = data['classRoom'] as String?;

        if (grade == null || classRoom == null) continue;

        final key = '$grade ห้อง$classRoom';
        studentInfo[uid] = key;
        if (!classRooms.containsKey(key)) {
          classRooms[key] = [];
        }
        classRooms[key]!.add(uid);
      }

      // 🔹 ขั้นตอน 2: ดึงคะแนนจาก progress
      Map<String, Map<String, int>> stats = {};

      for (final entry in classRooms.entries) {
        final roomKey = entry.key;
        final uids = entry.value;
        int completed = 0;
        int notCompleted = 0;

        for (final uid in uids) {
          final progressDoc = await FirebaseFirestore.instance
              .collection('progress')
              .doc(uid)
              .get();

          if (progressDoc.exists) {
            final progressData = progressDoc.data()!;
            final postTestScore = progressData['postTestScore'] as int?;
            if (postTestScore != null) {
              completed++;
            } else {
              notCompleted++;
            }
          } else {
            notCompleted++;
          }
        }

        stats[roomKey] = {'completed': completed, 'notCompleted': notCompleted};
      }

      // 🔹 เรียงตามชั้นและห้อง
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
      print('Error loading post-test completion: $e');
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
        title: Text('กราฟจำนวนการสอบหลังเรียน'),
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
                        final completed = entry.value['completed'] ?? 0;
                        final notCompleted = entry.value['notCompleted'] ?? 0;
                        final total = completed + notCompleted;

                        final completedPercent = total > 0 ? (completed / total * 100).toStringAsFixed(0) : '0';
                        final notCompletedPercent = total > 0 ? (notCompleted / total * 100).toStringAsFixed(0) : '0';

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
                                          value: completed.toDouble(),
                                          color: Colors.purple,
                                          title: '$completedPercent%',
                                          radius: 40,
                                        ),
                                        PieChartSectionData(
                                          value: notCompleted.toDouble(),
                                          color: Colors.grey,
                                          title: '$notCompletedPercent%',
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
                                    Text('✅ ทำแล้ว: $completed คน'),
                                    Text('❌ ยังไม่ทำ: $notCompleted คน'),
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