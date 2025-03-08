import 'package:flutter/material.dart';
import '../models/game_model.dart';

class GameBoard extends StatelessWidget {
  final GameModel gameModel;
  final Function(int, int) onTap;

  const GameBoard({
    super.key,
    required this.gameModel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFAF8F1), // 宣纸白色
          borderRadius: BorderRadius.circular(16), // 更大的圆角
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: const Color(0xFF6B5A45).withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFE8E5DA), // 古绢米色边框
            width: 1.5,
          ),
        ),
        child: CustomPaint(
          painter: BoardPainter(gameModel),
          child: GestureDetector(
            onTapUp: (details) {
              _handleTap(context, details);
            },
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, TapUpDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    final boardSize = renderBox.size.width;
    final cellSize = boardSize / GameModel.boardSize;

    // 计算点击的行列
    final row = (localPosition.dy / cellSize).floor();
    final col = (localPosition.dx / cellSize).floor();

    // 确保在有效范围内
    if (row >= 0 && row < GameModel.boardSize && col >= 0 && col < GameModel.boardSize) {
      onTap(row, col);
    }
  }
}

class BoardPainter extends CustomPainter {
  final GameModel gameModel;

  BoardPainter(this.gameModel);

  @override
  void paint(Canvas canvas, Size size) {
    final boardSize = GameModel.boardSize;
    final cellSize = size.width / boardSize;

    // 绘制棋盘背景
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFFAF8F1),
          const Color(0xFFE8E5DA).withOpacity(0.7),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
    
    // 绘制网格线
    final paint = Paint()
      ..color = const Color(0xFF6B5A45).withOpacity(0.5) // 淡墨色
      ..strokeWidth = 0.7 // 更细腻的线条
      ..style = PaintingStyle.stroke;

    // 绘制横线和竖线
    for (int i = 0; i < boardSize; i++) {
      // 横线
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(size.width, i * cellSize),
        paint,
      );

      // 竖线
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, size.height),
        paint,
      );
    }

    // 绘制棋盘上的标记点
    final dotPaint = Paint()
      ..color = const Color(0xFF6B5A45).withOpacity(0.7) // 淡墨色
      ..style = PaintingStyle.fill;

    // 标准五子棋的天元和星位
    final centerPoint = boardSize ~/ 2;
    final starPoints = [
      [3, 3], [3, centerPoint], [3, boardSize - 4],
      [centerPoint, 3], [centerPoint, centerPoint], [centerPoint, boardSize - 4],
      [boardSize - 4, 3], [boardSize - 4, centerPoint], [boardSize - 4, boardSize - 4],
    ];

    for (var point in starPoints) {
      // 绘制阴阳鱼变形符号
      final centerOffset = Offset(point[1] * cellSize, point[0] * cellSize);
      
      // 绘制小圆点
      canvas.drawCircle(
        centerOffset,
        2.2,
        dotPaint,
      );
      
      // 绘制外圈
      final outerPaint = Paint()
        ..color = const Color(0xFF6B5A45).withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
        
      canvas.drawCircle(
        centerOffset,
        3.5,
        outerPaint,
      );
    }

    // 绘制棋子
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (gameModel.board[row][col] != PieceType.none) {
          _drawPiece(canvas, row, col, cellSize, gameModel.board[row][col]);
        }
      }
    }
  }

  void _drawPiece(Canvas canvas, int row, int col, double cellSize, PieceType type) {
    final center = Offset(col * cellSize, row * cellSize);
    final radius = cellSize * 0.42; // 调整棋子大小
    
    // 绘制棋子阴影
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    
    canvas.drawCircle(
      Offset(center.dx + 0.5, center.dy + 0.8),
      radius - 1,
      shadowPaint
    );

    if (type == PieceType.black) {
      // 黑棋 - 玄青色渐变效果
      final gradient = RadialGradient(
        colors: [
          const Color(0xFF2A2D34), // 玄青色
          const Color(0xFF3F4553), // 过渡色
          const Color(0xFF1A1C20), // 更深的玄青色
        ],
        stops: const [0.3, 0.7, 1.0],
        focal: Alignment(-0.2, -0.2),
      );

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..shader = gradient.createShader(Rect.fromCircle(
          center: center,
          radius: radius,
        ));

      // 绘制黑棋
      canvas.drawCircle(center, radius, paint);

      // 添加微光泽 - 更自然的高光
      final highlightPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.0),
          ],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(
          center: Offset(center.dx - radius * 0.3, center.dy - radius * 0.3),
          radius: radius * 0.4,
        ));

      canvas.drawCircle(
        Offset(center.dx - radius * 0.3, center.dy - radius * 0.3),
        radius * 0.4,
        highlightPaint,
      );
      
      // 添加金属质感纹理
      final texturePaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF515A6B).withOpacity(0.2)
        ..strokeWidth = 0.3;
      
      // 绘制几条弧线模拟金属纹理
      for (int i = 0; i < 3; i++) {
        final startAngle = 0.2 + i * 0.4;
        final sweepAngle = 0.6;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius * (0.5 + i * 0.15)),
          startAngle,
          sweepAngle,
          false,
          texturePaint,
        );
      }
    } else {
      // 白棋 - 象牙白色渐变
      final gradient = RadialGradient(
        colors: [
          const Color(0xFFF0EDE5), // 象牙白
          const Color(0xFFFFFFFF), // 纯白过渡
          const Color(0xFFE8E4DC), // 稍深的象牙白
        ],
        stops: const [0.3, 0.6, 1.0],
        focal: Alignment(-0.1, -0.1),
      );

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..shader = gradient.createShader(Rect.fromCircle(
          center: center,
          radius: radius,
        ));

      // 绘制白棋
      canvas.drawCircle(center, radius, paint);

      // 优化高光效果 - 更自然的玉石光泽
      final highlightPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(0.8),
            Colors.white.withOpacity(0.0),
          ],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(
          center: Offset(center.dx - radius * 0.25, center.dy - radius * 0.25),
          radius: radius * 0.35,
        ));

      canvas.drawCircle(
        Offset(center.dx - radius * 0.25, center.dy - radius * 0.25),
        radius * 0.35,
        highlightPaint,
      );
      
      // 添加玉石纹理
      final texturePaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFDCD8CF).withOpacity(0.4)
        ..strokeWidth = 0.4;
      
      // 绘制几条弧线模拟玉石纹理
      for (int i = 0; i < 2; i++) {
        final startAngle = 0.8 + i * 0.7;
        final sweepAngle = 0.8;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius * (0.6 + i * 0.15)),
          startAngle,
          sweepAngle,
          false,
          texturePaint,
        );
      }
    }

    // 绘制棋子边缘 - 更细腻的边缘
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = type == PieceType.black 
          ? const Color(0xFF1A1C20).withOpacity(0.6) 
          : const Color(0xFF6B5A45).withOpacity(0.25)
      ..strokeWidth = 0.7;

    canvas.drawCircle(center, radius, borderPaint);

    // 添加落子动效 - 同心圆扩散
    if (gameModel.history.isNotEmpty) {
      final lastMove = gameModel.history.last;
      if (row == lastMove.row && col == lastMove.col) {
        // 绘制外圈动效 - 多层同心圆
        for (int i = 0; i < 2; i++) {
          final effectPaint = Paint()
            ..style = PaintingStyle.stroke
            ..color = type == PieceType.black 
                ? const Color(0xFF2A2D34).withOpacity(0.2 - i * 0.05) 
                : const Color(0xFFF0EDE5).withOpacity(0.3 - i * 0.1)
            ..strokeWidth = 1.2 - i * 0.3;

          canvas.drawCircle(center, radius * (1.2 + i * 0.15), effectPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) {
    return true; // 简化处理，每次都重绘
  }
}