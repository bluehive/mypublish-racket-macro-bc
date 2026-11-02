# mypublish-racket-macro-bc

**Racket のマクロでつくる bc** — `#lang racket` のマクロで、中置記法の小さな電卓言語を実装する教材です。

## この版の目的

BSL版の [mypublish-racket-bc](https://github.com/bluehive/mypublish-racket-bc) を、2026-11-02時点の `6c949a2f8772c5ea2b77f9a57b2045372619d889` からコピーして独立させた企画です。元の原稿・コード・出版スクリプトは `reference/bsl/` に保存しました。これらは参照資料で、新版のビルド対象ではありません。

- BSL版: リストのトークンを実行時に解釈する dc 風スタック電卓。
- 本版: Racket ソースに書いた中置式をマクロ展開時に Racket の算術式へ変換する bc 風電卓。
- 初期仕様: `(bc 2 + 3 * 4)` と `(bc (2 + 3) * 4)`。四則演算、優先順位、左結合、括弧、数値リテラルを扱います。

GNU bc の完全互換ではありません。文字列入力・独自reader・変数代入・関数・scale・十進切捨て規則・CLI は今後の仕様です。初期版の数値は Racket の実数で、正確な有理数も扱います。

## 試す

Racket（rackunitを含む）を導入してください。

```sh
raco test code/bc.rkt
racket code/example.rkt
```

```racket
#lang racket
(require "code/bc.rkt")
(bc 2 + 3 * 4)       ; 14
(bc (2 + 3) * 4)     ; 20
(bc 8 - 3 - 1)       ; 4
```

初期実装とテストを用意しましたが、作成環境にRacketがないため実行確認は未実施です。

## 原稿と開発

正本は `books/racket-macro-bc/`、構想と引き継ぎは `notes/design.md`。全章ドラフト、Zenn未公開です。

```sh
npm install
npm run preview
mise run test:racket
```

出版工程は新版用に再設計するまで未対応です。元のEPUB検証には本書にない章・付録を要求する既知の問題があるため、そのまま流用しません。

初期BSL教材: Grok・Codex、マクロ版の構想・初期コード・原稿: Codex。企画・監修: bluehive。元の [BSD 2-Clause License](LICENSE) と著作権表示を継承します。

## マクロ解説の追加ドラフト

[第3章 マクロの仕組み](books/racket-macro-bc/ch03-macros.md) を追加しました。[通読用ドラフト](drafts/racket-macro-bc/book-draft.md) は章順に結合したレビュー用文書です。正本の編集は `books/racket-macro-bc/` で行ってください。
