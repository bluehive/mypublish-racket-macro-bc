#lang htdp/bsl
(require test-engine/racket-tests)
;; 第2章: BSL で四則演算と表示（dc 流 RPN）
;; A Token is one of: Number | "+" | "-" | "*" | "/" | "p" | "d" | "r" | "c"

(define (push n s) (cons n s))
(define (top s) (if (empty? s) (error "stack empty") (first s)))
(define (pop s) (if (empty? s) (error "stack empty") (rest s)))

;; apply-op : String Number Number -> Number
;; BSL は関数を値として渡せないので、演算子を文字列で受け取る
(define (apply-op op a b)
  (cond [(string=? op "+") (+ a b)]
        [(string=? op "-") (- a b)]
        [(string=? op "*") (* a b)]
        [else (/ a b)]))
(check-expect (apply-op "-" 5 2) 3)

;; binop : String Stack -> Stack
;; 先に積んだ値が左辺: 5 2 - => 3
(define (binop op s)
  (push (apply-op op (top (pop s)) (top s)) (pop (pop s))))
(check-expect (binop "+" (list 3 2)) (list 5))
(check-expect (binop "-" (list 2 5)) (list 3))
(check-expect (binop "/" (list 4 8 1)) (list 2 1))

;; step : Token Stack -> Stack   （"p" はスタックを変えない）
(define (step t s)
  (cond [(number? t) (push t s)]
        [(string=? t "+") (binop "+" s)]
        [(string=? t "-") (binop "-" s)]
        [(string=? t "*") (binop "*" s)]
        [(string=? t "/") (binop "/" s)]
        [(string=? t "d") (push (top s) s)]
        [(string=? t "r") (push (top (pop s)) (push (top s) (pop (pop s))))]
        [(string=? t "c") '()]
        [(string=? t "p") s]
        [else (error "unknown token")]))
(check-expect (step 7 '()) (list 7))
(check-expect (step "*" (list 3 4)) (list 12))

;; run : [List-of Token] Stack -> [List-of Number]
;; トークン列を処理し、"p" で表示したトップの値を順に返す
(define (run ts s)
  (cond [(empty? ts) '()]
        [(and (string? (first ts)) (string=? (first ts) "p"))
         (cons (top s) (run (rest ts) s))]
        [else (run (rest ts) (step (first ts) s))]))
(check-expect (run (list 2 3 "+" "p") '()) (list 5))
(check-expect (run (list 1 2 "+" 4 "*" "p") '()) (list 12))
(check-expect (run (list 5 "d" "*" "p" 1 "-" "p") '()) (list 25 24))
(check-expect (run (list 1 2 "r" "-" "p") '()) (list 1))
(check-error (run (list "+") '()) "stack empty")

(test)
