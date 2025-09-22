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
          // 更丰富的背景渐变
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFAF8F1), // 宣纸白色
              const Color(0xFFE8E5DA), // 古绢米色
              const Color(0xFFF5F3EB), // 淡象牙色
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
          borderRadius: BorderRadius.circular(20), // 更大的圆角
          boxShadow: [
            // 多层阴影效果
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: const Color(0xFF6B5A45).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
            // 内阴影效果
            BoxShadow(
              color: Colors.white.withOpacity(0.5),
              blurRadius: 6,
              offset: const Offset(-2, -2),
            ),
          ],
          border: Border.all(
            color: const Color(0xFF8B4513).withOpacity(0.3), // 深褐色边框
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: CustomPaint(
            painter: BoardPainter(gameModel),
            child: GestureDetector(
              onTapUp: (details) {
                _handleTap(context, details);
              },
            ),
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

    // 绘制棋盘纹理背景
    _drawBoardTexture(canvas, size);
    
    // 绘制网格线
    _drawGridLines(canvas, size, cellSize, boardSize);
    
    // 绘制标记点
    _drawStarPoints(canvas, cellSize, boardSize);

    // 绘制棋子
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (gameModel.board[row][col] != PieceType.none) {
          _drawPiece(canvas, row, col, cellSize, gameModel.board[row][col]);
        }
      }
    }
    
    // 绘制获胜线
    _drawWinningLine(canvas, cellSize, boardSize);
  }

  void _drawBoardTexture(Canvas canvas, Size size) {
    // 添加细微的纹理效果
    final texturePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFFAF8F1).withOpacity(0.8),
          const Color(0xFFE8E5DA).withOpacity(0.6),
          const Color(0xFFF5F3EB).withOpacity(0.9),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), texturePaint);
    
    // 添加古典纸张质感的细微线条
    final paperTexturePaint = Paint()
      ..color = const Color(0xFF6B5A45).withOpacity(0.03)
      ..strokeWidth = 0.3;
    
    for (int i = 0; i < size.width; i += 4) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paperTexturePaint,
      );
    }
  }

  void _drawGridLines(Canvas canvas, Size size, double cellSize, int boardSize) {
    final paint = Paint()
      ..color = const Color(0xFF6B5A45).withOpacity(0.6) // 更深的墨色
      ..strokeWidth = 1.0 // 稍微加粗线条
      ..style = PaintingStyle.stroke;

    // 绘制横线和竖线
    for (int i = 0; i < boardSize; i++) {
      // 边框线条稍微加粗
      final lineWidth = (i == 0 || i == boardSize - 1) ? 1.5 : 1.0;
      paint.strokeWidth = lineWidth;
      
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
  }

  void _drawStarPoints(Canvas canvas, double cellSize, int boardSize) {
    final dotPaint = Paint()
      ..color = const Color(0xFF8B4513).withOpacity(0.8) // 深褐色星位
      ..style = PaintingStyle.fill;

    // 标准五子棋的天元和星位
    final centerPoint = boardSize ~/ 2;
    final starPoints = [
      [3, 3], [3, centerPoint], [3, boardSize - 4],
      [centerPoint, 3], [centerPoint, centerPoint], [centerPoint, boardSize - 4],
      [boardSize - 4, 3], [boardSize - 4, centerPoint], [boardSize - 4, boardSize - 4],
    ];

    for (var point in starPoints) {
      final centerOffset = Offset(point[1] * cellSize, point[0] * cellSize);
      
      // 绘制主圆点，天元稍大
      final isCenter = (point[0] == centerPoint && point[1] == centerPoint);
      final radius = isCenter ? 3.2 : 2.8;
      
      canvas.drawCircle(centerOffset, radius, dotPaint);
      
      // 绘制外圈光晕
      final outerPaint = Paint()
        ..color = const Color(0xFF8B4513).withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
        
      canvas.drawCircle(centerOffset, radius + 2, outerPaint);
    }
  }

  void _drawWinningLine(Canvas canvas, double cellSize, int boardSize) {
    // 如果游戏结束且有获胜者，添加庆祝效果
    if (gameModel.status == GameStatus.blackWin || gameModel.status == GameStatus.whiteWin) {
      // 绘制胜利光芒效果
      _drawVictoryEffects(canvas, cellSize, boardSize);
    }
  }

  void _drawVictoryEffects(Canvas canvas, double cellSize, int boardSize) {
    final center = Offset(
      boardSize * cellSize / 2,
      boardSize * cellSize / 2,
    );
    
    // 绘制胜利光芒
    final victoryPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.amber.withOpacity(0.1),
          Colors.orange.withOpacity(0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(
        center: center,
        radius: boardSize * cellSize * 0.6,
      ));
    
    canvas.drawCircle(center, boardSize * cellSize * 0.6, victoryPaint);
    
    // 绘制星光效果
    final sparkles = [
      Offset(center.dx - 50, center.dy - 80),
      Offset(center.dx + 60, center.dy - 60),
      Offset(center.dx - 40, center.dy + 70),
      Offset(center.dx + 45, center.dy + 55),
      Offset(center.dx - 70, center.dy + 20),
      Offset(center.dx + 80, center.dy - 20),
    ];
    
    final sparklePaint = Paint()
      ..color = Colors.amber.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    for (final sparkle in sparkles) {
      _drawSparkle(canvas, sparkle, sparklePaint);
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, Paint paint) {
    const sparkleSize = 8.0;
    final path = Path();
    
    // 绘制四角星
    path.moveTo(center.dx, center.dy - sparkleSize);
    path.lineTo(center.dx + sparkleSize * 0.3, center.dy - sparkleSize * 0.3);
    path.lineTo(center.dx + sparkleSize, center.dy);
    path.lineTo(center.dx + sparkleSize * 0.3, center.dy + sparkleSize * 0.3);
    path.lineTo(center.dx, center.dy + sparkleSize);
    path.lineTo(center.dx - sparkleSize * 0.3, center.dy + sparkleSize * 0.3);
    path.lineTo(center.dx - sparkleSize, center.dy);
    path.lineTo(center.dx - sparkleSize * 0.3, center.dy - sparkleSize * 0.3);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  void _drawPiece(Canvas canvas, int row, int col, double cellSize, PieceType type) {
    final center = Offset(col * cellSize, row * cellSize);
    final radius = cellSize * 0.44; // 稍微增大棋子

    // 绘制棋子阴影 - 更真实的阴影效果
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    
    canvas.drawCircle(
      Offset(center.dx + 1.5, center.dy + 2),
      radius - 1,
      shadowPaint
    );

    if (type == PieceType.black) {
      // 黑棋 - 深邃玄黑渐变
      final gradient = RadialGradient(
        colors: [
          const Color(0xFF1A1A1A), // 深黑色中心
          const Color(0xFF2C2C2C), // 过渡色
          const Color(0xFF404040), // 边缘略亮
          const Color(0xFF0D0D0D), // 最外圈最深
        ],
        stops: const [0.0, 0.4, 0.8, 1.0],
        focal: Alignment(-0.3, -0.3),
      );

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..shader = gradient.createShader(Rect.fromCircle(
          center: center,
          radius: radius,
        ));

      // 绘制黑棋主体
      canvas.drawCircle(center, radius, paint);

      // 添加高光 - 模拟玉石光泽
      final highlightPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(
          center: Offset(center.dx - radius * 0.35, center.dy - radius * 0.35),
          radius: radius * 0.45,
        ));

      canvas.drawCircle(
        Offset(center.dx - radius * 0.35, center.dy - radius * 0.35),
        radius * 0.45,
        highlightPaint,
      );
      
      // 添加细微的纹理效果
      final texturePaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF555555).withOpacity(0.3)
        ..strokeWidth = 0.5;
      
      // 绘制弧形纹理
      for (int i = 0; i < 2; i++) {
        final startAngle = 0.3 + i * 0.8;
        final sweepAngle = 0.8;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius * (0.6 + i * 0.2)),
          startAngle,
          sweepAngle,
          false,
          texturePaint,
        );
      }
      
      // 绘制边缘高光
      final edgeHighlightPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF666666).withOpacity(0.4)
        ..strokeWidth = 0.8;
      
      canvas.drawCircle(center, radius - 0.5, edgeHighlightPaint);
      
    } else {
      // 白棋 - 温润象牙白渐变
      final gradient = RadialGradient(
        colors: [
          const Color(0xFFFFFFF8), // 略带暖色的白
          const Color(0xFFF8F6F0), // 象牙白
          const Color(0xFFEFEDE6), // 米白色
          const Color(0xFFE8E4DC), // 边缘稍深
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
        focal: Alignment(-0.2, -0.2),
      );

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..shader = gradient.createShader(Rect.fromCircle(
          center: center,
          radius: radius,
        ));

      // 绘制白棋主体
      canvas.drawCircle(center, radius, paint);

      // 添加高光 - 温润玉石光泽
      final highlightPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.3),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(
          center: Offset(center.dx - radius * 0.3, center.dy - radius * 0.3),
          radius: radius * 0.4,
        ));

      canvas.drawCircle(
        Offset(center.dx - radius * 0.3, center.dy - radius * 0.3),
        radius * 0.4,
        highlightPaint,
      );
      
      // 添加玉石纹理
      final texturePaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFDDD8CF).withOpacity(0.5)
        ..strokeWidth = 0.6;
      
      // 绘制弧形纹理
      for (int i = 0; i < 2; i++) {
        final startAngle = 1.0 + i * 0.9;
        final sweepAngle = 0.9;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius * (0.65 + i * 0.15)),
          startAngle,
          sweepAngle,
          false,
          texturePaint,
        );
      }
    }

    // 绘制棋子边缘 - 更精致的边框
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = type == PieceType.black 
          ? const Color(0xFF000000).withOpacity(0.8) 
          : const Color(0xFF8B4513).withOpacity(0.4)
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius, borderPaint);

    // 添加落子动效和最新棋子标记
    if (gameModel.history.isNotEmpty) {
      final lastMove = gameModel.history.last;
      if (row == lastMove.row && col == lastMove.col) {
        // 绘制最新落子标记 - 脉动效果
        for (int i = 0; i < 3; i++) {
          final effectPaint = Paint()
            ..style = PaintingStyle.stroke
            ..color = type == PieceType.black 
                ? const Color(0xFFFFFFFF).withOpacity(0.4 - i * 0.1) 
                : const Color(0xFF8B4513).withOpacity(0.5 - i * 0.1)
            ..strokeWidth = 2.0 - i * 0.5;

          canvas.drawCircle(center, radius * (1.15 + i * 0.1), effectPaint);
        }
        
        // 中心标记点
        final centerMarkPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = type == PieceType.black 
              ? Colors.white.withOpacity(0.8) 
              : const Color(0xFF8B4513).withOpacity(0.8);

        canvas.drawCircle(center, 2.5, centerMarkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) {
    return true; // 简化处理，每次都重绘
  }
}