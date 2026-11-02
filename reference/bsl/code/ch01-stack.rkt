#lang htdp/bsl
(require test-engine/racket-tests)
;; 第1章: BSL でスタック（dc のスタック機械モデル）
;; A Stack is one of: '() | (cons Number Stack) — 先頭がトップ

;; push : Number Stack -> Stack
(define (push n s) (cons n s))
(check-expect (push 3 (push 2 '())) (list 3 2))

;; top : Stack -> Number
(define (top s)
  (if (empty? s) (error "stack empty") (first s)))
(check-expect (top (list 3 2)) 3)
(check-error (top '()) "stack empty")

;; pop : Stack -> Stack
(define (pop s)
  (if (empty? s) (error "stack empty") (rest s)))
(check-expect (pop (list 3 2)) (list 2))

;; dup : Stack -> Stack   ; dc の d
(define (dup s) (push (top s) s))
(check-expect (dup (list 4 1)) (list 4 4 1))

;; swap : Stack -> Stack  ; dc の r
(define (swap s) (push (top (pop s)) (push (top s) (pop (pop s)))))
(check-expect (swap (list 1 2 3)) (list 2 1 3))

;; clear : Stack -> Stack ; dc の c
(define (clear s) '())
(check-expect (clear (list 1 2)) '())

(test)
