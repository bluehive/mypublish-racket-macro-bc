---
title: "第1章 BSL でスタックをつくる"
---

dc の心臓部はスタックです。BSL ではスタックを数のリストで表し、**先頭がスタックトップ** とします。

```racket
;; A Stack is one of:
;; - '()
;; - (cons Number Stack)

(define (push n s) (cons n s))
(define (top s) (first s))
(define (pop s) (rest s))

(check-expect (push 3 (push 2 '())) (list 3 2))
(check-expect (top (list 3 2)) 3)
(check-expect (pop (list 3 2)) (list 2))
```

`push` は元のリストを壊さず、新しいリストを返します。代入を使わない「関数型のスタック」です。

dc の `d`（複製）、`r`（交換）、`c`（全消去）も同じ要領で書けます。完全なコードは `code/ch01-stack.rkt` を参照してください。

（本章は今後加筆予定）
