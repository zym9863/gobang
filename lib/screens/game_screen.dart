import 'package:flutter/material.dart';
import '../models/game_model.dart';
import '../widgets/game_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameModel _gameModel = GameModel();
  bool _isAIThinking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('五子棋'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildStatusBar(),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GameBoard(
                  gameModel: _gameModel,
                  onTap: _handleBoardTap,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildControlButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    String statusText = '';
    Color statusColor = Colors.black;

    switch (_gameModel.status) {
      case GameStatus.playing:
        statusText = '当前玩家: ${_gameModel.currentPlayer == PieceType.black ? "黑棋" : "白棋"}';
        statusColor = _gameModel.currentPlayer == PieceType.black ? Colors.black : Colors.grey.shade700;
      case GameStatus.blackWin:
        statusText = '黑棋胜利！';
        statusColor = Colors.black;
      case GameStatus.whiteWin:
        statusText = '白棋胜利！';
        statusColor = Colors.grey.shade700;
      case GameStatus.draw:
        statusText = '平局！';
        statusColor = Colors.blue;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          statusText,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),
        ),
        if (_isAIThinking) ...[  
          const SizedBox(width: 16),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ],
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: _resetGame,
          child: const Text('重新开始'),
        ),
        ElevatedButton(
          onPressed: _undoMove,
          child: const Text('悔棋'),
        ),
          PopupMenuButton<AIDifficulty>(
            initialValue: _gameModel.aiDifficulty,
            onSelected: _changeAIDifficulty,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: AIDifficulty.easy,
                child: Text('简单'),
              ),
              const PopupMenuItem(
                value: AIDifficulty.medium,
                child: Text('中等'),
              ),
              const PopupMenuItem(
                value: AIDifficulty.hard,
                child: Text('困难'),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_getDifficultyText()),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _getDifficultyText() {
    switch (_gameModel.aiDifficulty) {
      case AIDifficulty.easy:
        return '简单';
      case AIDifficulty.medium:
        return '中等';
      case AIDifficulty.hard:
        return '困难';
    }
  }

  void _handleBoardTap(int row, int col) {
    if (_gameModel.status != GameStatus.playing || _isAIThinking) {
      return;
    }

    setState(() {
      bool moveSuccess = _gameModel.placePiece(row, col);
      
      // 如果是AI模式且玩家成功下棋且游戏仍在进行中
      if (moveSuccess && _gameModel.isAIMode && _gameModel.status == GameStatus.playing) {
        _isAIThinking = true;
        
        // 使用Future.delayed来模拟AI思考时间，并避免UI卡顿
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          
          // 获取AI的落子位置
          final aiMove = _gameModel.getAIMove();
          
          setState(() {
            _gameModel.placePiece(aiMove.row, aiMove.col);
            _isAIThinking = false;
          });
        });
      }
    });
  }

  void _resetGame() {
    setState(() {
      _gameModel.resetGame();
      _isAIThinking = false;
    });
  }

  void _undoMove() {
    setState(() {
      _gameModel.undoMove();
      _isAIThinking = false;
    });
  }

  // AI模式相关方法已移除，现在游戏只有AI模式

  void _changeAIDifficulty(AIDifficulty difficulty) {
    setState(() {
      _gameModel.aiDifficulty = difficulty;
    });
  }
}