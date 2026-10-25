# Time Flow

饥荒联机版（DST）mod：调节昼夜/季节流速与食物腐烂速度，不冻结世界。

## 功能

- 时间流速：暂停 / 0.5x / 0.75x / 1x / 1.5x / 2x
- 腐烂速度：不烂 / 0.1x / 0.25x / 0.5x / 0.75x / 1x
- 按 **F7** 打开面板（可在模组配置中改为 F8/F9/P/O）
- 打开面板自动暂停，关闭后恢复
- 只影响昼夜与季节，玩家、生物和建造不受影响
- 设置变更会通过角色说话通知同世界玩家
- 中英双语：默认英文，简体/繁体中文自动切换

## 目录

```
TimeFlow/
├── mod/                     ← 上传内容（唯一真源）
│   ├── modinfo.lua          元数据、图标、配置
│   ├── modmain.lua          逻辑、RPC、时钟与腐烂 hook
│   ├── modicon.tex/xml      模组图标（256×256）
│   └── widgets/
│       └── pausepanel.lua   面板 UI
├── assets/                  ← 发布素材，不打包
│   ├── preview.png          工坊预览图（1024×1024）
│   └── preview_512.png      备用预览图
└── README.md
```

## 本地测试

游戏 mods 目录通过 junction 指向项目目录：

```powershell
New-Item -ItemType Junction `
  -Path "D:\Games\SteamLibrary\steamapps\common\Don't Starve Together\mods\TimeFlow" `
  -Target "D:\Games\Mods\DST\DST-TimeFlow\mod"
```

进游戏后在「模组 → 本地模组」启用。

## 上传工坊

1. 运行 `D:\Games\SteamLibrary\steamapps\common\Don't Starve Mod Tools\ModUploader.exe`
2. 选择 `mod\` 目录
3. 标题填 `Time Flow`
4. 描述复制下方「工坊描述」中的 BBCode
5. 预览图选择 `assets\preview.png`

## 工坊描述

复制下面代码块中的内容到创意工坊描述框：

```bbcode
[h1]Time Flow[/h1]
[b]Slow down, speed up, or pause time — without freezing the world.[/b]

Time Flow lets you adjust the day/night cycle and season progression, so you can build your base in peace without the night or winter rushing in. It also lets you control how fast food spoils.

[h2]Features[/h2]
[list]
[*][b]Time speed[/b]: Pause / 0.5x / 0.75x / 1x / 1.5x / 2x
[*][b]Rot speed[/b]: No Rot / 0.1x / 0.25x / 0.5x / 0.75x / 1x
[*]Open the panel with [b]F7[/b] (configurable in mod settings)
[*]Opening the panel automatically pauses the game, closing resumes it
[*]Only day/night and seasons are affected — players, creatures and building are untouched
[*]Changes are announced to other players through character speech
[/list]

[h2]Notes[/h2]
[list]
[*]Server-side mod — all clients should install it
[*]Only single-player (local online world) has been tested; multiplayer has not been tested
[*]No full compatibility test with other mods; no issues observed with the author's own common mod set
[/list]

[hr][/hr]

[h1]Time Flow（时间流速）[/h1]
[b]暂停、减慢或加快时间，而不用冻结整个世界。[/b]

Time Flow 可以调节昼夜与季节的流逝速度，让你安心建家，不必担心天黑或冬天突然到来。同时也可以调节食物腐烂速度。

[h2]功能[/h2]
[list]
[*][b]时间流速[/b]：暂停 / 0.5x / 0.75x / 1x / 1.5x / 2x
[*][b]腐烂速度[/b]：不烂 / 0.1x / 0.25x / 0.5x / 0.75x / 1x
[*]按 [b]F7[/b] 打开面板（可在模组配置中修改）
[*]打开面板时自动暂停，关闭后恢复
[*]只影响昼夜与季节，玩家、生物和建造不受影响
[*]设置变更会通过角色说话通知其他玩家
[/list]

[h2]注意[/h2]
[list]
[*]服务器端模组，建议所有客户端安装
[*]仅测试了单人（本地在线世界），未测试联机效果
[*]未做完整的模组兼容性测试；作者自用的一些通用模组下暂未遇到问题
[/list]
```

## 更新日志

- **0.3.0** — 中英双语（简体/繁体自动切换）
- **0.2.0** — 新的控制面板，时间与腐烂控制
- **0.1.0** — 初版
