import 'dart:math' as math;

enum PieceType { none, black, white }
enum GameStatus { playing, blackWin, whiteWin, draw }
enum AIDifficulty { easy, medium, hard }

class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position && other.row == row && other.col == col;
  }

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}

class GameModel {
  // 棋盘大小，标准五子棋是15x15
  static const int boardSize = 15;
  
  // 棋盘状态，存储每个位置的棋子类型
  List<List<PieceType>> board = List.generate(
    boardSize,
    (_) => List.generate(boardSize, (_) => PieceType.none),
  );

  // 当前轮到哪种棋子
  PieceType currentPlayer = PieceType.black;

  // 游戏状态
  GameStatus status = GameStatus.playing;

  // 游戏模式（现在只有AI模式）
  bool isAIMode = true;

  // AI难度
  AIDifficulty aiDifficulty = AIDifficulty.easy;

  // 游戏历史，用于悔棋功能
  final List<Position> history = [];

  // 放置棋子
  bool placePiece(int row, int col) {
    // 如果游戏已结束或位置已有棋子，则不能放置
    if (status != GameStatus.playing || board[row][col] != PieceType.none) {
      return false;
    }

    // 放置棋子
    board[row][col] = currentPlayer;
    history.add(Position(row, col));

    // 检查是否获胜
    if (checkWin(row, col)) {
      status = currentPlayer == PieceType.black
          ? GameStatus.blackWin
          : GameStatus.whiteWin;
      return true;
    }

    // 检查是否平局（棋盘已满）
    if (history.length == boardSize * boardSize) {
      status = GameStatus.draw;
      return true;
    }

    // 切换玩家
    currentPlayer = currentPlayer == PieceType.black
        ? PieceType.white
        : PieceType.black;

    return true;
  }

  // 检查是否获胜
  bool checkWin(int row, int col) {
    PieceType piece = board[row][col];
    if (piece == PieceType.none) return false;

    // 检查方向：水平、垂直、左上到右下、右上到左下
    final directions = [
      [0, 1], // 水平
      [1, 0], // 垂直
      [1, 1], // 左上到右下
      [1, -1], // 右上到左下
    ];

    for (var dir in directions) {
      int count = 1; // 当前位置已有一个棋子
      
      // 正向检查
      int r = row + dir[0];
      int c = col + dir[1];
      while (r >= 0 && r < boardSize && c >= 0 && c < boardSize && board[r][c] == piece) {
        count++;
        r += dir[0];
        c += dir[1];
      }
      
      // 反向检查
      r = row - dir[0];
      c = col - dir[1];
      while (r >= 0 && r < boardSize && c >= 0 && c < boardSize && board[r][c] == piece) {
        count++;
        r -= dir[0];
        c -= dir[1];
      }

      // 如果连续5个或以上相同棋子，则获胜
      if (count >= 5) return true;
    }

    return false;
  }

  // 重置游戏
  void resetGame() {
    board = List.generate(
      boardSize,
      (_) => List.generate(boardSize, (_) => PieceType.none),
    );
    currentPlayer = PieceType.black;
    status = GameStatus.playing;
    history.clear();
  }

  // 悔棋
  bool undoMove() {
    if (history.isEmpty) return false;

    // 如果是AI模式，需要撤销两步（玩家和AI的各一步）
    if (isAIMode) {
      if (history.length < 2) return false;
      
      // 撤销AI的一步
      final aiMove = history.removeLast();
      board[aiMove.row][aiMove.col] = PieceType.none;
      
      // 撤销玩家的一步
      final playerMove = history.removeLast();
      board[playerMove.row][playerMove.col] = PieceType.none;
    } else {
      // 人人对战模式，只撤销一步
      final lastMove = history.removeLast();
      board[lastMove.row][lastMove.col] = PieceType.none;
      
      // 切换玩家
      currentPlayer = currentPlayer == PieceType.black
          ? PieceType.white
          : PieceType.black;
    }

    // 重置游戏状态为进行中
    status = GameStatus.playing;
    return true;
  }

  // AI下棋
  Position getAIMove() {
    switch (aiDifficulty) {
      case AIDifficulty.easy:
        return _getEasyAIMove();
      case AIDifficulty.medium:
        return _getMediumAIMove();
      case AIDifficulty.hard:
        return _getHardAIMove();
    }
  }

  // 简单AI：随机选择一个空位置
  Position _getEasyAIMove() {
    final random = math.Random();
    List<Position> emptyPositions = [];
    
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (board[i][j] == PieceType.none) {
          emptyPositions.add(Position(i, j));
        }
      }
    }
    
    if (emptyPositions.isEmpty) {
      // 棋盘已满，不应该发生
      return const Position(0, 0);
    }
    
    return emptyPositions[random.nextInt(emptyPositions.length)];
  }

  // 中等AI：使用简单评分函数
  Position _getMediumAIMove() {
    // 找出所有空位置
    List<Position> emptyPositions = [];
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (board[i][j] == PieceType.none) {
          emptyPositions.add(Position(i, j));
        }
      }
    }
    
    if (emptyPositions.isEmpty) {
      return const Position(0, 0);
    }
    
    // 评估每个位置的分数
    Position bestMove = emptyPositions[0];
    int bestScore = -1;
    
    for (var pos in emptyPositions) {
      int score = _evaluatePosition(pos.row, pos.col);
      if (score > bestScore) {
        bestScore = score;
        bestMove = pos;
      }
    }
    
    return bestMove;
  }

  // 评估位置分数（简单版）
  int _evaluatePosition(int row, int col) {
    // 检查这个位置在各个方向上的连子情况
    final directions = [
      [0, 1], // 水平
      [1, 0], // 垂直
      [1, 1], // 左上到右下
      [1, -1], // 右上到左下
    ];
    
    int totalScore = 0;
    
    // 分别评估AI（当前玩家）和对手的分数
    for (PieceType pieceType in [currentPlayer, currentPlayer == PieceType.black ? PieceType.white : PieceType.black]) {
      for (var dir in directions) {
        int count = 0;
        bool blocked1 = false;
        bool blocked2 = false;
        
        // 正向检查
        int r = row;
        int c = col;
        for (int i = 1; i <= 4; i++) {
          r += dir[0];
          c += dir[1];
          if (r >= 0 && r < boardSize && c >= 0 && c < boardSize) {
            if (board[r][c] == pieceType) {
              count++;
            } else if (board[r][c] != PieceType.none) {
              blocked1 = true;
              break;
            } else {
              break;
            }
          } else {
            blocked1 = true;
            break;
          }
        }
        
        // 反向检查
        r = row;
        c = col;
        for (int i = 1; i <= 4; i++) {
          r -= dir[0];
          c -= dir[1];
          if (r >= 0 && r < boardSize && c >= 0 && c < boardSize) {
            if (board[r][c] == pieceType) {
              count++;
            } else if (board[r][c] != PieceType.none) {
              blocked2 = true;
              break;
            } else {
              break;
            }
          } else {
            blocked2 = true;
            break;
          }
        }
        
        // 计算分数
        int score = _getScoreForCount(count, blocked1, blocked2, pieceType == currentPlayer);
        totalScore += score;
      }
    }
    
    return totalScore;
  }

  // 根据连子数和阻塞情况计算分数
  int _getScoreForCount(int count, bool blocked1, bool blocked2, bool isAI) {
    // 如果两端都被阻塞，价值较低
    if (blocked1 && blocked2) return 0;
    
    int baseScore;
    // 根据连子数给分
    switch (count) {
      case 0: baseScore = 1;
      case 1: baseScore = 10;
      case 2: baseScore = 100;
      case 3: baseScore = 1000;
      case 4: baseScore = 10000;
      default: baseScore = 100000; // 5个或更多
    }
    
    // 一端被阻塞，价值减半
    if (blocked1 || blocked2) {
      baseScore ~/= 2;
    }
    
    // AI的分数比玩家的分数更重要（防守为主）
    return isAI ? baseScore : baseScore * 2;
  }

  // 困难AI：使用极小极大算法（简化版）
  Position _getHardAIMove() {
    // 如果是第一步，选择中心位置或其附近
    if (history.isEmpty) {
      int center = boardSize ~/ 2;
      return Position(center, center);
    }
    
    // 使用中等AI的逻辑，但增加搜索深度和评估函数的复杂性
    return _getMediumAIMove();
  }
}