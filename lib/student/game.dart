// lib/game.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../home.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _currentLevel = 0;
  List<String> _playerCommands = [];
  bool _isRunning = false;
  late Position _robotPosition;
  bool _isCompleted = false;
  bool _canEditCommands = true;

  bool _showStory = true;

  final Map<int, Map<String, int>> _commandUsage = {};
  Set<Position> _visitedPositions = {};

  bool _hasCollided = false;
  String _currentDirection = 'right';

  final List<GameLevel2D> _levels = [
    GameLevel2D(
      name: 'ทดสอบ',
      map: [
        ['S', 'X', '▢', 'F'],
        ['▢', '▢', '▢', 'X'],
      ],
      start: Position(0, 0),
      target: Position(0, 3),
      correctCommands: ['เลี้ยวขวา', 'ไปข้างหน้า', 'เลี้ยวซ้าย', 'ไปข้างหน้า',
                         'ไปข้างหน้า', 'เลี้ยวซ้าย', 'ไปข้างหน้า', 'เลี้ยวขวา', 'ไปข้างหน้า'],
      availableCommands: ['ไปข้างหน้า', 'เลี้ยวขวา', 'เลี้ยวซ้าย', 'เดินถอยหลัง'],
    ),
    GameLevel2D(
      name: 'ถอยหลัง',
      map: [
        ['▢', 'S', 'X'],
        ['▢', 'X', 'X'],
        ['▢', '▢', 'F'],
      ],
      start: Position(0, 1),
      target: Position(2, 2),
      correctCommands: ['เดินถอยหลัง', 'เลี้ยวขวา', 'ไปข้างหน้า', 'ไปข้างหน้า',
                        'เลี้ยวซ้าย', 'ไปข้างหน้า', 'ไปข้างหน้า'],
      availableCommands: ['ไปข้างหน้า', 'เลี้ยวขวา', 'เลี้ยวซ้าย', 'เดินถอยหลัง'],
    ),
    GameLevel2D(
      name: 'ทางใกล้กว่าคือทางลัด',
      map: [
        ['X', '▢', '▢', '▢'],
        ['X', '▢', 'X', '▢'],
        ['S', '▢', 'X', '▢'],
        ['X', '▢', 'X', 'F'],
        ['X', '▢', '▢', '▢'],
      ],
      start: Position(2, 0),
      target: Position(3, 3),
      correctCommands: [
        'ไปข้างหน้า', 'เลี้ยวขวา', 'ไปข้างหน้า', 'ไปข้างหน้า',
        'เลี้ยวซ้าย', 'ไปข้างหน้า', 'ไปข้างหน้า', 'เลี้ยวซ้าย', 'ไปข้างหน้า'
      ],
      availableCommands: ['ไปข้างหน้า', 'เลี้ยวขวา', 'เลี้ยวซ้าย', 'เดินถอยหลัง'],
    ),
    GameLevel2D(
      name: 'ทางใกล้กว่าคือทางลัด',
      map: [
        ['X', 'X',  '▢', '▢', '▢', '▢', '▢'],
        ['X', '▢', '▢', 'X', '▢', 'X', '▢',],
        ['S', '▢', 'X', 'X', '▢', 'X', 'F'],
        ['X', '▢', 'X', 'X',  '▢', '▢','▢'],
        ['X', '▢', '▢', '▢', 'X', 'X', 'X'],
      ],
      start: Position(2, 0),
      target: Position(2, 6),
      correctCommands: [
        'ไปข้างหน้า', 'เลี้ยวซ้าย', 'ไปข้างหน้า', 'เลี้ยวขวา', 'ไปข้างหน้า',
        'เลี้ยวซ้าย', 'ไปข้างหน้า', 'เลี้ยวขวา', 'ไปข้างหน้า', 'ไปข้างหน้า',
        'ไปข้างหน้า','ไปข้างหน้า', 'เลี้ยวขวา', 'ไปข้างหน้า', 'ไปข้างหน้า',
      ],
      availableCommands: ['ไปข้างหน้า', 'เลี้ยวขวา', 'เลี้ยวซ้าย', 'เดินถอยหลัง'],
    ),
    GameLevel2D(
      name: 'ทางใกล้กว่าคือทางลัด',
      map: [
        ['▢', '▢',  '▢', '▢', '▢', '▢', '▢'],
        ['▢', 'X', 'X', 'X',  'X',    'X',   '▢',],
        ['▢', '▢', '▢', 'S', 'X',  'X', 'F'],
        ['X', '▢', 'X',  'X',  '▢', '▢','▢'],
        ['X', '▢', '▢', '▢', '▢', 'X', 'X'],
      ],
      start: Position(2, 3),
      target: Position(2, 6),
      correctCommands: [
        'ถอยหลัง', 'ถอยหลัง', 'เลี้ยวขวา', 'ไปข้างหน้า', 'ไปข้างหน้า', 'เลี้ยวซ้าย', 'ไปข้างหน้า', 
        'ไปข้างหน้า', 'ไปข้างหน้า', 'เลี้ยวซ้าย', 'ไปข้างหน้า', 'เลี้ยวขวา', 'ไปข้างหน้า', 'ไปข้างหน้า', 'เลี้ยวซ้าย', 'ไปข้างหน้า',
      ],
      availableCommands: ['ไปข้างหน้า', 'เลี้ยวขวา', 'เลี้ยวซ้าย', 'เดินถอยหลัง'],
    ),
  ];

  GameLevel2D get _level => _levels[_currentLevel];

  @override
  void initState() {
    super.initState();
    _robotPosition = Position(_levels[0].start.row, _levels[0].start.col);
    _resetLevel();
  }

  void _resetLevel() {
    setState(() {
      _playerCommands = [];
      _isRunning = false;
      _isCompleted = false;
      _canEditCommands = true;
      _robotPosition = Position(_level.start.row, _level.start.col);
      _visitedPositions = {Position(_level.start.row, _level.start.col)};
      _hasCollided = false;
      _currentDirection = 'right';
      _showStory = true;
    });

    if (!_commandUsage.containsKey(_currentLevel)) {
      _commandUsage[_currentLevel] = {};
      for (var command in _level.availableCommands) {
        _commandUsage[_currentLevel]![command] = 0;
      }
    }
  }

  void _addCommand(String command) {
    if (_isRunning || _isCompleted || !_canEditCommands) return;
    
    setState(() {
      _playerCommands.add(command);
      _commandUsage[_currentLevel]![command] = 
          (_commandUsage[_currentLevel]![command] ?? 0) + 1;
    });
  }

  void _removeCommand(int index) {
    if (_isRunning || _isCompleted || !_canEditCommands) return;
    
    setState(() {
      final removedCommand = _playerCommands.removeAt(index);
      if (_commandUsage[_currentLevel]!.containsKey(removedCommand)) {
        _commandUsage[_currentLevel]![removedCommand] = 
            (_commandUsage[_currentLevel]![removedCommand]! - 1).clamp(0, 1000);
      }
    });
  }

  Future<void> _runCommands() async {
    if (_isRunning || _playerCommands.isEmpty || !_canEditCommands) return;

    setState(() {
      _isRunning = true;
      _canEditCommands = false;
      _hasCollided = false;
    });

    Position currentPos = Position(_level.start.row, _level.start.col);
    String currentDir = 'right';

    for (int i = 0; i < _playerCommands.length; i++) {
      final command = _playerCommands[i];
      
      if (command == 'ไปข้างหน้า') {
        Position nextPos = _getNextPositionFromDirection(currentPos, currentDir);
        if (_isValidMove(nextPos)) {
          currentPos = nextPos;
          _visitedPositions.add(Position(currentPos.row, currentPos.col));
          
          if (mounted) {
            setState(() {
              _robotPosition = currentPos;
              _visitedPositions = Set.of(_visitedPositions);
            });
          }
          await Future.delayed(Duration(milliseconds: 600));
        } else {
          _hasCollided = true;
          _showCollisionMessage();
          await Future.delayed(Duration(milliseconds: 300));
        }
      } else if (command == 'เดินถอยหลัง') {
        Position nextPos = _getPreviousPositionFromDirection(currentPos, currentDir);
        if (_isValidMove(nextPos)) {
          currentPos = nextPos;
          _visitedPositions.add(Position(currentPos.row, currentPos.col));
          
          if (mounted) {
            setState(() {
              _robotPosition = currentPos;
              _visitedPositions = Set.of(_visitedPositions);
            });
          }
          await Future.delayed(Duration(milliseconds: 600));
        } else {
          _hasCollided = true;
          _showCollisionMessage();
          await Future.delayed(Duration(milliseconds: 300));
        }
      } else if (command == 'เลี้ยวขวา') {
        currentDir = _turnRight(currentDir);
        if (mounted) {
          setState(() {
            _currentDirection = currentDir;
          });
        }
        await Future.delayed(Duration(milliseconds: 300));
      } else if (command == 'เลี้ยวซ้าย') {
        currentDir = _turnLeft(currentDir);
        if (mounted) {
          setState(() {
            _currentDirection = currentDir;
          });
        }
        await Future.delayed(Duration(milliseconds: 300));
      }
    }

    if (!_hasCollided && currentPos == _level.target) {
      _finishRunning(true);
    } else {
      _finishRunning(false);
    }
  }

  Position _getNextPositionFromDirection(Position pos, String dir) {
    switch (dir) {
      case 'up': return Position(pos.row - 1, pos.col);
      case 'down': return Position(pos.row + 1, pos.col);
      case 'left': return Position(pos.row, pos.col - 1);
      case 'right': return Position(pos.row, pos.col + 1);
      default: return pos;
    }
  }

  Position _getPreviousPositionFromDirection(Position pos, String dir) {
    switch (dir) {
      case 'up': return Position(pos.row + 1, pos.col);
      case 'down': return Position(pos.row - 1, pos.col);
      case 'left': return Position(pos.row, pos.col + 1);
      case 'right': return Position(pos.row, pos.col - 1);
      default: return pos;
    }
  }

  String _turnRight(String dir) {
    switch (dir) {
      case 'up': return 'right';
      case 'right': return 'down';
      case 'down': return 'left';
      case 'left': return 'up';
      default: return dir;
    }
  }

  String _turnLeft(String dir) {
    switch (dir) {
      case 'up': return 'left';
      case 'left': return 'down';
      case 'down': return 'right';
      case 'right': return 'up';
      default: return dir;
    }
  }

  bool _isValidMove(Position pos) {
    final rows = _level.map.length;
    final cols = _level.map[0].length;
    
    if (pos.row < 0 || pos.row >= rows || pos.col < 0 || pos.col >= cols) {
      return false;
    }
    
    final cell = _level.map[pos.row][pos.col];
    return cell != 'X';
  }

  void _showCollisionMessage() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ชนสิ่งกีดขวางหรือกรอบนอก! กด "เริ่มใหม่" เพื่อลองอีกครั้ง', style: TextStyle(fontSize: 16.0)),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _finishRunning(bool success) {
    if (mounted) {
      setState(() {
        _isRunning = false;
        _isCompleted = success;
      });
      
      if (success) {
        _showResult(true);
        if (_currentLevel == _levels.length - 1) {
          _saveFinalGameProgress();
          Future.delayed(Duration(milliseconds: 1500), () {
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
                (route) => false,
              );
            }
          });
        } else {
          _nextLevel();
        }
      } else {
        if (!_hasCollided) {
          _showResult(false);
        }
      }
    }
  }

  void _showResult(bool success) {
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เยี่ยมมาก! คุณพาน้องหมูแจ๋วถึงเป้าหมายแล้ว!', style: TextStyle(fontSize: 18.0)),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ยังไม่ถึงเป้าหมาย ลองวางแผนใหม่อีกครั้ง!', style: TextStyle(fontSize: 18.0)),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _nextLevel() {
    if (_currentLevel < _levels.length - 1) {
      setState(() {
        _currentLevel++;
      });
      _resetLevel();
    }
  }

  int _calculateTotalCommands(int levelIndex) {
    final commands = _commandUsage[levelIndex];
    if (commands == null) return 0;
    return commands.values.fold(0, (sum, count) => sum + count);
  }

  Future<void> _saveFinalGameProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final usageMap = <String, Map<String, dynamic>>{};
      _commandUsage.forEach((levelIndex, commands) {
        final levelKey = 'level_${levelIndex + 1}';
        final total = commands.values.fold(0, (sum, count) => sum + count);
        
        usageMap[levelKey] = {
          ...commands,
          '_total': total,
        };
      });

      await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .set({
            'gamePlayed': true,
            'gameCommandUsage': usageMap,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving final game progress: $e');
    }
  }

  String _getArrowFromDirection(String direction) {
    switch (direction) {
      case 'up': return '👆';
      case 'down': return '👇';
      case 'left': return '👈';
      case 'right': return '👉';
      default: return '👉';
    }
  }

  Widget _buildStoryScreen() {
    final isDesktop = MediaQuery.of(context).size.width >= 600.0;
    final titleSize = isDesktop ? 28.0 : 24.0;
    final storySize = isDesktop ? 28.0 : 24.0;
    final buttonHeight = isDesktop ? 50.0 : 44.0;

    String title = '';
    String story = '';

    switch (_currentLevel) {
      case 0:
        title = 'ด่าน 1:';
        story = 'น้องหมูแจ๋วนั่งรถสองแถวหน้า ราชภัฎสุราษฎร์ธานี🏠ไปลงตลาดเกษตร2🏁';
        break;
      case 1:
        title = 'ด่าน 2:';
        story = 'น้องหมูแจ๋วขึ้นรถเมล์แดง🏠ไปลงสถานีรถไฟพุนพิน🏁';
        break;
      case 2:
        title = 'ด่าน 3:';
        story = 'น้องหมูแจ๋วขึ้นรถไฟจากสุราษฎร์ธานี🏠ไปลงวัดธาตุน้อยที่จังหวัดนครศรีธรรมราช🏁\nเผื่อไหว้สักการะพ่อท่านคล้ายวัดวาจาสิทธิ์ เทวดาเมืองนครศรีธรรมราช';
        break;
      case 3:
        title = 'ด่าน 4:';
        story = 'และในช่วงบ่ายหมูแจ๋วต่อรถไฟ🏠ไปลงสถานีรถไฟ ชุมทางทุ่งสง🏁';
        break;
      case 4:
        title = 'ด่าน 5:';
        story = 'น้องหมูแจ๋วนั่งวินมอเตอร์ไซค์🏠 ไปโรงเรียนวัดเขากลาย🏁 ไปพบปะ สังสรรค์กับเพื่อนที่โรงเรียน วัดเขากลาย';
        break;
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isDesktop ? 20.0 : 16.0),
            Text(
              story,
              style: TextStyle(fontSize: storySize, height: 1.5),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isDesktop ? 40.0 : 32.0),
            SizedBox(
              height: buttonHeight,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showStory = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6A11CB),
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32.0 : 24.0),
                ),
                child: Text(
                  'เริ่มด่าน',
                  style: TextStyle(fontSize: isDesktop ? 18.0 : 16.0, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600.0;
    final titleSize = isDesktop ? 28.0 : 22.0;
    final subtitleSize = isDesktop ? 18.0 : 16.0;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('เกม: อัลกอริทึม', style: TextStyle(fontSize: 22.0)),
          backgroundColor: Color(0xFF6A11CB),
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        body: _showStory 
            ? _buildStoryScreen()
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'ด่าน ${_currentLevel + 1}: ${_level.name}',
                        style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        'รวม: ${_calculateTotalCommands(_currentLevel)} ครั้ง',
                        style: TextStyle(color: Colors.grey, fontSize: subtitleSize),
                      ),
                      SizedBox(height: 8.0),
                      if (_commandUsage.containsKey(_currentLevel))
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: _commandUsage[_currentLevel]!.entries.map((entry) {
                            return Chip(
                              label: Text('${entry.key}: ${entry.value}', style: TextStyle(fontSize: isDesktop ? 16.0 : 14.0)),
                              backgroundColor: Colors.grey[200],
                            );
                          }).toList(),
                        ),
                      SizedBox(height: 16.0),
                      _buildMap2D(),
                      SizedBox(height: 24.0),
                      _buildSelectedCommands(),
                      SizedBox(height: 24.0),
                      _buildCommandButtons(),
                      SizedBox(height: 24.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: isDesktop ? 50.0 : 44.0,
                            child: ElevatedButton(
                              onPressed: _resetLevel,
                              child: Text('เริ่มใหม่', style: TextStyle(fontSize: isDesktop ? 18.0 : 16.0)),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                            ),
                          ),
                          SizedBox(width: 16.0),
                          SizedBox(
                            height: isDesktop ? 50.0 : 44.0,
                            child: ElevatedButton(
                              onPressed: _canEditCommands ? _runCommands : null,
                              child: Text('รันคำสั่ง', style: TextStyle(fontSize: isDesktop ? 18.0 : 16.0)),
                              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2ECC71)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildMap2D() {
    final isDesktop = MediaQuery.of(context).size.width >= 600.0;
    final cellSize = isDesktop ? 100.0 : 70.0;
    final margin = isDesktop ? 3.0 : 2.0;
    final fontSize = isDesktop ? 24.0 : 20.0;
    final headerSize = isDesktop ? 28.0 : 24.0;

    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2.0),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          Text('แผนที่:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: headerSize)),
          SizedBox(height: isDesktop ? 12.0 : 8.0),
          Column(
            children: List.generate(_level.map.length, (rowIndex) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_level.map[rowIndex].length, (colIndex) {
                  final cell = _level.map[rowIndex][colIndex];
                  final isRobotHere = _robotPosition.row == rowIndex && _robotPosition.col == colIndex;
                  final isVisited = _visitedPositions.contains(Position(rowIndex, colIndex));
                  
                  Color bgColor;
                  String text = '';
                  
                  if (isRobotHere) {
                    bgColor = Colors.lightBlue;
                    if (_isRunning) {
                      text = _getArrowFromDirection(_currentDirection);
                    } else {
                      text = '🚶‍♂️‍➡️';
                    }
                  } else if (cell == 'S') {
                    bgColor = Colors.green[100]!;
                    text = '🏠';
                  } else if (cell == 'F') {
                    bgColor = Colors.red[100]!;
                    text = '🏁';
                  } else if (cell == 'X') {
                    bgColor = Colors.grey[400]!;
                    text = '🚧';
                  } else if (isVisited) {
                    bgColor = Colors.yellow[100]!;
                  } else {
                    bgColor = Colors.white;
                  }
                  
                  return Container(
                    width: cellSize,
                    height: cellSize,
                    margin: EdgeInsets.all(margin),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.5),
                      color: bgColor,
                    ),
                    child: Center(child: Text(text, style: TextStyle(fontSize: fontSize))),
                  );
                }),
              );
            }),
          ),
        ],
      ),
    );
  }

Widget _buildSelectedCommands() {
  final isDesktop = MediaQuery.of(context).size.width >= 600.0;
  final fontSize = isDesktop ? 18.0 : 16.0;

  // 🔹 ฟังก์ชันแปลงคำสั่งเป็นข้อความ + อิโมจิ
  String getDisplayText(String command) {
    switch (command) {
      case 'ไปข้างหน้า': return 'ไปข้างหน้า 👉';
      case 'เลี้ยวขวา': return 'เลี้ยวขวา 👇';
      case 'เลี้ยวซ้าย': return 'เลี้ยวซ้าย 👆';
      case 'เดินถอยหลัง': return 'เดินถอยหลัง 👈';
      default: return command;
    }
  }

  return Container(
    padding: EdgeInsets.all(12.0),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(12.0),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('คำสั่งที่เลือก:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize)),
        SizedBox(height: 8.0),
        _playerCommands.isEmpty
            ? Text('ยังไม่มีคำสั่ง', style: TextStyle(color: Colors.grey, fontSize: fontSize - 2.0))
            : Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: List.generate(_playerCommands.length, (index) {
                  final command = _playerCommands[index];
                  return Chip(
                    label: Text(getDisplayText(command), style: TextStyle(fontSize: fontSize - 2.0)),
                    onDeleted: _canEditCommands ? () => _removeCommand(index) : null,
                    deleteIcon: Icon(Icons.close, size: 16.0),
                  );
                }),
              ),
      ],
    ),
  );
}

  Widget _buildCommandButtons() {
    final isDesktop = MediaQuery.of(context).size.width >= 600.0;
    final buttonHeight = isDesktop ? 50.0 : 40.0;
    final fontSize = isDesktop ? 18.0 : 16.0;

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _level.availableCommands.map((command) {
        Color color;
        String displayText = command;
        switch (command) {
        case 'ไปข้างหน้า':
          displayText = 'ไปข้างหน้า 👉';
          color = Colors.blue;
          break;

          case 'เลี้ยวขวา': 
          displayText = 'เลี้ยวขวา 👇';
          color = Colors.green; break;

          case 'เลี้ยวซ้าย': 
          displayText = 'เลี้ยวซ้าย 👆';
          color = Colors.orange; break;

          case 'เดินถอยหลัง': 
          displayText = 'เดินถอยหลัง 👈';
          color = Colors.purple; break;

          default: color = Colors.grey;
        }
        return SizedBox(
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: _canEditCommands ? () => _addCommand(command) : null,
            style: ElevatedButton.styleFrom(backgroundColor: color),
            child: Text(displayText, style: TextStyle(color: Colors.white, fontSize: fontSize)),
          ),
        );
      }).toList(),
    );
  }
}

class Position {
  final int row;
  final int col;
  
  Position(this.row, this.col);
  
  @override
  bool operator ==(Object other) =>
      other is Position && other.row == row && other.col == col;
  
  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}

class GameLevel2D {
  final String name;
  final List<List<String>> map;
  final Position start;
  final Position target;
  final List<String> correctCommands;
  final List<String> availableCommands;

  GameLevel2D({
    required this.name,
    required this.map,
    required this.start,
    required this.target,
    required this.correctCommands,
    required this.availableCommands,
  });
}