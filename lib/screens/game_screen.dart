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
        elevation: 8,
        shadowColor: Colors.black26,
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      body: SafeArea(
        child: Column(
          children: [
            // 增强状态栏区域
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween(begin: const Offset(0.0, 0.3), end: Offset.zero)
                        .chain(CurveTween(curve: Curves.easeOutCubic)),
                    ),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: _buildEnhancedStatusBar(),
              ),
            ),
            // 游戏统计信息
            _buildGameStats(),
            // 棋盘区域
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
            // 增强控制按钮区域
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildEnhancedControlButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedStatusBar() {
    String statusText = '';
    Color statusColor = Colors.black;
    IconData statusIcon = Icons.circle;

    switch (_gameModel.status) {
      case GameStatus.playing:
        statusText = '当前玩家: ${_gameModel.currentPlayer == PieceType.black ? "黑棋" : "白棋"}';
        statusColor = _gameModel.currentPlayer == PieceType.black ? Colors.black : Colors.grey.shade700;
        statusIcon = _gameModel.currentPlayer == PieceType.black ? Icons.circle : Icons.circle_outlined;
      case GameStatus.blackWin:
        statusText = '🎉 黑棋胜利！';
        statusColor = Colors.black;
        statusIcon = Icons.emoji_events;
      case GameStatus.whiteWin:
        statusText = '🎉 白棋胜利！';
        statusColor = Colors.grey.shade700;
        statusIcon = Icons.emoji_events;
      case GameStatus.draw:
        statusText = '🤝 平局！';
        statusColor = Colors.blue;
        statusIcon = Icons.handshake;
    }

    return Row(
      key: ValueKey('${_gameModel.status}_${_gameModel.currentPlayer}_${_isAIThinking}'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          statusIcon,
          color: statusColor,
          size: 28,
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            statusText,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: statusColor,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (_isAIThinking) ...[  
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text(
                  'AI思考中...',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGameStats() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('步数', '${_gameModel.history.length}', Icons.timeline),
          Container(
            width: 1,
            height: 30,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
          _buildStatItem('难度', _getDifficultyText(), Icons.psychology),
          Container(
            width: 1,
            height: 30,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
          _buildStatItem('模式', 'AI对战', Icons.smart_toy),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            child: Text(value),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedControlButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 主要控制按钮
        Row(
          children: [
            Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  child: ElevatedButton.icon(
                    onPressed: _resetGame,
                    icon: const Icon(Icons.refresh, size: 20),
                    label: const Text('重新开始'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: Colors.black26,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MouseRegion(
                cursor: _gameModel.history.isEmpty 
                  ? SystemMouseCursors.forbidden 
                  : SystemMouseCursors.click,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  child: ElevatedButton.icon(
                    onPressed: _gameModel.history.isEmpty ? null : _undoMove,
                    icon: const Icon(Icons.undo, size: 20),
                    label: const Text('悔棋'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gameModel.history.isEmpty 
                        ? Colors.grey.shade400 
                        : Theme.of(context).colorScheme.secondary,
                      foregroundColor: _gameModel.history.isEmpty 
                        ? Colors.grey.shade600 
                        : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: _gameModel.history.isEmpty ? 0 : 4,
                      shadowColor: Colors.black26,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // AI难度选择器
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: PopupMenuButton<AIDifficulty>(
            initialValue: _gameModel.aiDifficulty,
            onSelected: _changeAIDifficulty,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: AIDifficulty.easy,
                child: Row(
                  children: [
                    Icon(
                      Icons.sentiment_satisfied_alt,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('简单'),
                    if (_gameModel.aiDifficulty == AIDifficulty.easy)
                      const Spacer(),
                    if (_gameModel.aiDifficulty == AIDifficulty.easy)
                      const Icon(Icons.check, color: Colors.green, size: 16),
                  ],
                ),
              ),
              PopupMenuItem(
                value: AIDifficulty.medium,
                child: Row(
                  children: [
                    Icon(
                      Icons.sentiment_neutral,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('中等'),
                    if (_gameModel.aiDifficulty == AIDifficulty.medium)
                      const Spacer(),
                    if (_gameModel.aiDifficulty == AIDifficulty.medium)
                      const Icon(Icons.check, color: Colors.orange, size: 16),
                  ],
                ),
              ),
              PopupMenuItem(
                value: AIDifficulty.hard,
                child: Row(
                  children: [
                    Icon(
                      Icons.sentiment_very_dissatisfied,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('困难'),
                    if (_gameModel.aiDifficulty == AIDifficulty.hard)
                      const Spacer(),
                    if (_gameModel.aiDifficulty == AIDifficulty.hard)
                      const Icon(Icons.check, color: Colors.red, size: 16),
                  ],
                ),
              ),
            ],
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getDifficultyIcon(),
                    size: 20,
                    color: _getDifficultyColor(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI难度: ${_getDifficultyText()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_drop_down, size: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getDifficultyIcon() {
    switch (_gameModel.aiDifficulty) {
      case AIDifficulty.easy:
        return Icons.sentiment_satisfied_alt;
      case AIDifficulty.medium:
        return Icons.sentiment_neutral;
      case AIDifficulty.hard:
        return Icons.sentiment_very_dissatisfied;
    }
  }

  Color _getDifficultyColor() {
    switch (_gameModel.aiDifficulty) {
      case AIDifficulty.easy:
        return Colors.green;
      case AIDifficulty.medium:
        return Colors.orange;
      case AIDifficulty.hard:
        return Colors.red;
    }
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
      // 显示游戏状态反馈
      _showGameStatusFeedback();
      return;
    }

    // 检查位置是否已被占用
    if (_gameModel.board[row][col] != PieceType.none) {
      _showInvalidMoveFeedback();
      return;
    }

    setState(() {
      bool moveSuccess = _gameModel.placePiece(row, col);
      
      // 如果是AI模式且玩家成功下棋且游戏仍在进行中
      if (moveSuccess && _gameModel.isAIMode && _gameModel.status == GameStatus.playing) {
        _isAIThinking = true;
        
        // 使用Future.delayed来模拟AI思考时间，并避免UI卡顿
        Future.delayed(const Duration(milliseconds: 800), () {
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

  void _showInvalidMoveFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.block, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('该位置已有棋子！'),
          ],
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showGameStatusFeedback() {
    String message = '';
    if (_gameModel.status != GameStatus.playing) {
      message = '游戏已结束，请重新开始！';
    } else if (_isAIThinking) {
      message = 'AI正在思考中，请稍候...';
    }

    if (message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(message),
            ],
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.blue.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  void _resetGame() {
    setState(() {
      _gameModel.resetGame();
      _isAIThinking = false;
    });
  }

  void _undoMove() {
    if (_gameModel.history.isEmpty) return;
    
    setState(() {
      _gameModel.undoMove();
      _isAIThinking = false;
    });
  }

  void _changeAIDifficulty(AIDifficulty difficulty) {
    setState(() {
      _gameModel.aiDifficulty = difficulty;
    });
    
    // 显示难度变更提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getDifficultyIcon(),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text('AI难度已设置为: ${_getDifficultyText()}'),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: _getDifficultyColor(),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}