#lang racket
(require "bc.rkt")
(displayln (bc 2 + 3 * 4))
(displayln (bc (2 + 3) * 4))
(displayln (bc 8 - 3 - 1))
