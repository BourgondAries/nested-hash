#lang info
(define collection "nested-hash")
(define deps '("base"))
(define build-deps '("sandbox-lib" "scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("scribblings/nested-hash.scrbl" ())))
(define pkg-desc "A way to easily access nested hash tables")
(define version "1.1.1")
(define pkg-authors '("Kevin R. Stravers"))
