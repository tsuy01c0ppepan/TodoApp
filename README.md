# TodoApp

iOS向けのシンプルで実用的なTODOアプリ（SwiftUI + SwiftData）。

## 場所

`~/projects/TodoApp`

## 機能

- TODOの追加・編集・削除
- 完了トグル（タップ / 左スワイプ）
- 優先度（低 / 普通 / 高）
- 期限日
- フィルター（すべて / 未完了 / 完了）
- タイトル・メモ検索
- SwiftDataによる端末内永続化

## 要件

- iOS 17.0+
- Xcode 16+

## ビルド・実行

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
open ~/projects/TodoApp/TodoApp.xcodeproj
# またはシミュレータ向け:
xcodebuild -project TodoApp.xcodeproj -scheme TodoApp -destination 'platform=iOS Simulator,name=iPhone 16' build
```

XcodeBuildMCP 利用時は project / scheme `TodoApp` をセットして `build_run_sim`。

## 構成

```
TodoApp/
├── TodoAppApp.swift          # エントリ + ModelContainer
├── ContentView.swift         # 一覧・フィルタ・検索
├── Models/TodoItem.swift     # SwiftDataモデル
├── Views/
│   ├── TodoRowView.swift
│   └── TodoEditorSheet.swift
└── Assets.xcassets
```
