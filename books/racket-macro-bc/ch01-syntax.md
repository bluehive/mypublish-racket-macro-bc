---
title: "第1章 構文を受け取り、構文を返す"
---

普通の関数は引数の値を受け取ります。マクロは、評価される前の式を構文オブジェクトとして受け取ります。構文オブジェクトには式の形だけでなく、ソース位置や識別子の束縛の情報もあります。

たとえば中置式 `2 + 3` を `(+ 2 3)` の構文へ変換すれば、実際の足し算はRacketが実行できます。マクロの担当は構文の変換、実行時の担当は数値の計算です。

最小の実験をしてみましょう。

```racket
#lang racket
(define-syntax-rule (add left right)
  (+ left right))
(add 2 3)
```

次に `raco expand code/example.rkt` で、実装したbcマクロの展開結果を確認します。詳細な展開形にはRacket内部の構文も現れます。ここでは、どの算術演算がどの順序で組み合わされているかを探してください。

この章の今後の加筆: syntax と datum、衛生的マクロ、展開時と実行時の違いを、同じ式の前後を比較して解説します。

参照: [The Racket Guide: Macros](https://docs.racket-lang.org/guide/macros.html)、[Syntax Objects](https://docs.racket-lang.org/guide/stx-obj.html)。
