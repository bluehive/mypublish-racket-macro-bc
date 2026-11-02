#lang racket
(require (for-syntax racket/base racket/list))
(provide bc)

;; Compile an infix expression at expansion time. Operators are DSL tokens;
;; generated arithmetic identifiers retain this module's lexical bindings.
(begin-for-syntax
  (define (operator? token operators)
    (and (identifier? token) (memq (syntax-e token) operators)))

  (define (rightmost tokens operators)
    (for/fold ([found #f]) ([token (in-list tokens)] [i (in-naturals)])
      (if (operator? token operators) i found)))

  (define (compile-infix tokens origin)
    (define split
      (or (rightmost tokens '(+ -)) (rightmost tokens '(* /))))
    (cond
      [split
       (when (or (zero? split) (= split (sub1 (length tokens))))
         (raise-syntax-error 'bc "binary operator needs two operands" origin))
       (define left (compile-infix (take tokens split) origin))
       (define right (compile-infix (drop tokens (add1 split)) origin))
       (case (syntax-e (list-ref tokens split))
         [(+) #`(+ #,left #,right)]
         [(-) #`(- #,left #,right)]
         [(*) #`(* #,left #,right)]
         [(/) #`(/ #,left #,right)])]
      [(= (length tokens) 1)
       (define token (car tokens))
       (define nested (syntax->list token))
       (cond
         [(real? (syntax-e token)) token]
         [nested (compile-infix nested origin)]
         [else (raise-syntax-error 'bc "expected a real number or parenthesized expression" origin token)])]
      [else (raise-syntax-error 'bc "expected an infix arithmetic expression" origin)])))

(define-syntax (bc stx)
  (syntax-case stx ()
    [(_ token ...) (compile-infix (syntax->list #'(token ...)) stx)]))

(module+ test
  (require rackunit syntax/macro-testing)
  (check-equal? (bc 2 + 3 * 4) 14)
  (check-equal? (bc (2 + 3) * 4) 20)
  (check-equal? (bc 8 - 3 - 1) 4)
  (check-equal? (bc 8 / 2 / 2) 2)
  (check-equal? (bc 3 / 2) 3/2)
  (check-equal? (bc -2 * (3 + 1)) -8)
  ;; Locally shadowed + must not capture the generated addition.
  (check-equal? (let ([+ (lambda (_a _b) 'captured)]) (bc 2 + 3)) 5)
  (check-exn exn:fail:syntax? (lambda () (convert-compile-time-error (bc))))
  (check-exn exn:fail:syntax? (lambda () (convert-compile-time-error (bc 2 +))))
  (check-exn exn:fail:syntax? (lambda () (convert-compile-time-error (bc 2 3))))
  (check-exn exn:fail:syntax? (lambda () (convert-compile-time-error (bc x + 2))))
  (check-exn exn:fail:syntax? (lambda () (convert-compile-time-error (bc 2 ^ 3))))
  (check-exn exn:fail:contract:divide-by-zero? (lambda () (bc 1 / 0))))
