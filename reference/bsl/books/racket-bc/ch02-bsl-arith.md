---
title: "第2章 BSL で四則演算と表示"
---

dc では `2 3 +` のように書くと、2 と 3 を積み、`+` が上の 2 つを取り出して 5 を積みます。引き算・割り算では **先に積んだ方が左辺** になる点に注意します（`5 2 -` は 3）。

```racket
;; BSL では関数を引数に渡せないので、演算子は文字列で受け取る
(define (apply-op op a b)
  (cond [(string=? op "+") (+ a b)]
        [(string=? op "-") (- a b)]
        [(string=? op "*") (* a b)]
        [else (/ a b)]))

(define (binop op s)
  (push (apply-op op (second s) (first s)) (rest (rest s))))

(check-expect (binop "-" (list 2 5)) (list 3))
```

トークン列（数と文字列 `"+"` `"p"` など）を左から順に処理する `run` を BSL の構造的再帰で書くと、小さな dc ができあがります。`p` はトップを表示（出力リストに追加）します。

```racket
(check-expect (run (list 2 3 "+" "p") '()) (list 5))
```

完全なコードは `code/ch02-arith.rkt` を参照してください。

（本章は今後加筆予定）
