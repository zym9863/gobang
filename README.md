# 五子棋

中文 | [English](README_EN.md)

一个使用Flutter开发的现代化五子棋游戏应用。

## 功能特点

- 标准15x15棋盘
- 人机对战模式
- AI支持多个难度级别（简单/中等/困难）
- 支持悔棋功能
- 实时显示游戏状态
- 优雅的视觉设计
  - 仿宣纸质感的棋盘
  - 流畅的动画效果
  - Material Design 3风格界面

## 技术实现

### 项目结构

```
lib/
├── main.dart          # 应用入口
├── models/            # 数据模型
│   └── game_model.dart # 游戏核心逻辑
├── screens/           # 页面
│   └── game_screen.dart # 游戏主界面
└── widgets/           # 组件
    └── game_board.dart  # 棋盘组件
```

### 核心功能

- **游戏逻辑**: 实现了完整的五子棋规则，包括胜负判定和平局检测
- **AI对战**: 采用评分策略实现智能AI，支持不同难度级别
- **状态管理**: 使用Flutter的状态管理机制，确保UI与游戏状态的同步更新
- **自适应布局**: 支持不同屏幕尺寸，保持最佳的游戏体验

## 开发环境

- Flutter SDK: ^3.7.0
- Dart SDK: ^3.7.0

## 开始使用

1. 确保已安装Flutter开发环境
2. 克隆项目到本地
3. 运行以下命令安装依赖：
   ```bash
   flutter pub get
   ```
4. 运行应用：
   ```bash
   flutter run
   ```

## 贡献

欢迎提交Issue和Pull Request来帮助改进这个项目。

## 许可

本项目采用MIT许可证。
