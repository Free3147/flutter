// lib/teacher/post_test_average_score.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class PostTestAverageScoreScreen extends StatefulWidget {
  @override
  _PostTestAverageScoreScreenState createState() => _PostTestAverageScoreScreenState();
}

class _PostTestAverageScoreScreenState extends State<PostTestAverageScoreScreen> {
  Map<String, Map<String, dynamic>> _classRoomData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPostTestAverageScoreData();
  }

  Future<void> _loadPostTestAverageScoreData() async {
    setState(() => _isLoading = true);

    try {
      // 🔹 ขั้นตอน 1: ดึงรายชื่อนักเรียนจาก users
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();

      Map<String, List<String>> classRooms = {}; // "grade ห้องclassRoom" -> [uid]

      for (final doc in userSnapshot.docs) {
        final data = doc.data();
        final uid = doc.id;
        final grade = data['grade'] as String?;
        final classRoom = data['classRoom'] as String?;

        if (grade == null || classRoom == null) continue;

        final key = '$grade ห้อง$classRoom';
        if (!classRooms.containsKey(key)) {
          classRooms[key] = [];
        }
        classRooms[key]!.add(uid);
      }

      // 🔹 ขั้นตอน 2: คำนวณคะแนนเฉลี่ยและจำนวนคน
      Map<String, Map<String, dynamic>> stats = {};

      for (final entry in classRooms.entries) {
        final roomKey = entry.key;
        final uids = entry.value;
        int totalScore = 0;
        int testedCount = 0;
        int notTestedCount = 0;

        for (final uid in uids) {
          final progressDoc = await FirebaseFirestore.instance
              .collection('progress')
              .doc(uid)
              .get();

          if (progressDoc.exists) {
            final progressData = progressDoc.data()!;
            final postTestScore = progressData['postTestScore'] as int?;

            if (postTestScore != null) {
              totalScore += postTestScore;
              testedCount++;
            } else {
              notTestedCount++;
            }
          } else {
            notTestedCount++;
          }
        }

        // 🔹 คำนวณคะแนนเฉลี่ย
        final average = testedCount > 0 ? totalScore / testedCount : 0.0;
        final percentage = (average / 20 * 100).clamp(0.0, 100.0);

        stats[roomKey] = {
          'averageScore': average,
          'percentage': percentage,
          'testedCount': testedCount,
          'notTestedCount': notTestedCount,
          'totalStudents': uids.length,
        };
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

      Map<String, Map<String, dynamic>> sortedStats = {};
      for (final key in sortedKeys) {
        sortedStats[key] = stats[key]!;
      }

      setState(() {
        _classRoomData = sortedStats;
      });

    } catch (e) {
      print('Error loading post-test average score: $e');
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
        title: Text('คะแนนเฉลี่ยการสอบหลังเรียน'),
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
                        final averageScore = entry.value['averageScore'] ?? 0.0;
                        final percentage = entry.value['percentage'] ?? 0.0;
                        final testedCount = entry.value['testedCount'] ?? 0;
                        final notTestedCount = entry.value['notTestedCount'] ?? 0;
                        final totalStudents = entry.value['totalStudents'] ?? 0;

                        return Card(
                          margin: EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  room,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 16),
                                // 🔹 กราฟวงแหวน
                                SizedBox(
                                  height: 200,
                                  child: PieChart(
                                    PieChartData(
                                      sections: [
                                        PieChartSectionData(
                                          value: percentage,
                                          color: Color(0xFF9C27B0),
                                          title: '${percentage.toStringAsFixed(0)}%',
                                          radius: 40,
                                        ),
                                        PieChartSectionData(
                                          value: 100.0 - percentage, // 🔹 แก้ไขเป็น 100.0
                                          color: Colors.grey[300]!,
                                          title: '',
                                          radius: 40,
                                        ),
                                      ],
                                      centerSpaceRadius: 30,
                                      sectionsSpace: 2,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12),
                                // 🔹 แสดงคะแนนเฉลี่ย
                                Text(
                                  'ทั้งห้องได้ ${averageScore.toStringAsFixed(2)} / 20',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 12),
                                // 🔹 แสดงจำนวนคน
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      '✅ ทำแล้ว: $testedCount คน',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                    Text(
                                      '❌ ยังไม่ทำ: $notTestedCount คน',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    Text(
                                      '📊 รวม: $totalStudents คน',
                                      style: TextStyle(color: Colors.blue),
                                    ),
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