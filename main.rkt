#lang racket/base

(provide nested-hash-ref
         nested-hash-set)

(require racket/list)

(module+ test
  (require rackunit))

(define (nested-hash-ref hash #:default [default #f] ref . refs)
  (if hash
    (if (null? refs)
      (hash-ref hash ref default)
      (apply nested-hash-ref
             (hash-ref hash ref default)
             #:default default refs))
    #f))

(define (nested-hash-set hash* ref . refs)
  (define (nested-hash-set* hash* value refs)
    (cond
      ([null? refs] value)
      (else         (hash-set hash*
                              (car refs)
                              (nested-hash-set*
                                (hash-ref hash* (car refs) (hash))
                                value
                                (cdr refs))))))
  (cond
    ([> (length refs) 1]
     (nested-hash-set* hash*
                       (last refs)
                       (cons ref (take refs (sub1 (length refs))))))
    (else (raise-argument-error 'nested-hash-set "(non-empty-listof any/c)" refs))))

(module+ test
  (test-equal? "nested access"
               (nested-hash-ref (hash 'a (hash 'b 123)) 'a 'b)
               123)
  (test-equal? "nested access miss"
               (nested-hash-ref (hash 'a (hash 'b 123)) 'a 'c)
               #f)
  (test-equal? "nested access deep miss"
               (nested-hash-ref (hash 'a (hash 'b 123)) 'a 'c 'd 'e 'f)
               #f)
  (test-exn    "nested access wrong"
               (lambda _ #t)
               (lambda _ (nested-hash-ref (hash 'a (hash 'b 123)) 'a 'b 'c)))
  (test-equal? "nested set"
               (nested-hash-set (hash) 'a 'b 123)
               (hash 'a (hash 'b 123)))
  (test-equal? "nested set existing"
               (nested-hash-set (hash 'a (hash 'b 10)) 'a 'b 123)
               (hash 'a (hash 'b 123)))
  (test-exn    "nested set fail"
               (lambda _ #t)
               (lambda () (nested-hash-set (hash 'a 0) 'a 'b 123)))
  )
