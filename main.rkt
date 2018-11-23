#lang racket/base

(provide
  nested-hash-ref
  nested-hash-ref*
  nested-hash-set
  nested-hash-set*
  )

(require racket/list)

(module+ test
  (require rackunit))

(define (nested-hash-ref hash #:default [default #f] ref . refs)
  (nested-hash-ref* hash #:default default (cons ref refs)))

(define (nested-hash-ref* hash refs #:default [default #f])
  (cond
    [(null? refs) hash]
    [(= (length refs) 1) (hash-ref hash (car refs) default)]
    [(hash-has-key? hash (car refs))
     (nested-hash-ref*
       (hash-ref hash (car refs) default)
       (cdr refs)
       #:default default)]
    [else default]))

(define (nested-hash-set hash* #:hash [hash hash] ref . refs)
  (cond
    ([>= (length refs) 1]
     (nested-hash-set* hash*
                       (cons ref (take refs (sub1 (length refs))))
                       (last refs)
                       #:hash hash))
    (else (raise-argument-error 'nested-hash-set "(non-empty-listof any/c)" refs))))

(define (nested-hash-set* hash* refs value #:hash [hash hash])
  (cond
    ([null? refs] value)
    (else         (hash-set hash*
                            (car refs)
                            (nested-hash-set*
                              (hash-ref hash* (car refs) (hash))
                              (cdr refs)
                              value
                              #:hash hash)))))
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
  (test-equal? "nested access deep miss with default"
               (nested-hash-ref (hash 'a (hash 'b 123)) 'a 'c 'd 'e 'f #:default 246)
               246)
  (test-exn    "nested access wrong"
               (lambda _ #t)
               (lambda _ (nested-hash-ref (hash 'a (hash 'b 123)) 'a 'b 'c)))
  (test-equal? "nested set"
               (nested-hash-set (hash) 'a 'b 123)
               (hash 'a (hash 'b 123)))
  (test-equal? "nested set table consistency"
               (nested-hash-set (hasheq) #:hash hasheq 'a 'b 'c 123)
               (hasheq 'a (hasheq 'b (hasheq 'c 123))))
  (test-equal? "nested set existing"
               (nested-hash-set (hash 'a (hash 'b 10)) 'a 'b 123)
               (hash 'a (hash 'b 123)))
  (test-equal? "nested set shallow"
               (nested-hash-set (hash 'a (hash 'b 10)) 'c 123)
               (hash 'a (hash 'b 10) 'c 123))
  (test-exn    "nested set fail"
               (lambda _ #t)
               (lambda () (nested-hash-set (hash 'a 0) 'a 'b 123)))

  (test-equal? "identity"
               (nested-hash-ref* (hash 'a (hash 'b 123)) '())
               (hash 'a (hash 'b 123)))
  (test-equal? "nested access - star functions"
               (nested-hash-ref* (hash 'a (hash 'b 123)) '(a b))
               123)
  (test-equal? "nested access miss - star functions"
               (nested-hash-ref* (hash 'a (hash 'b 123)) '(a c))
               #f)
  (test-equal? "nested access deep miss - star functions"
               (nested-hash-ref* (hash 'a (hash 'b 123)) '(a c d e f))
               #f)
  (test-equal? "nested access deep miss with default - star functions"
               (nested-hash-ref* (hash 'a (hash 'b 123)) '(a c d e f) #:default 246)
               246)
  (test-exn    "nested access wrong - star functions"
               (lambda _ #t)
               (lambda _ (nested-hash-ref* (hash 'a (hash 'b 123)) '(a b c))))
  (test-equal? "nested set - star functions"
               (nested-hash-set* (hash) '(a b) 123)
               (hash 'a (hash 'b 123)))
  (test-equal? "nested set existing - star functions"
               (nested-hash-set* (hash 'a (hash 'b 10)) '(a b) 123)
               (hash 'a (hash 'b 123)))
  (test-equal? "nested set shallow - star functions"
               (nested-hash-set* (hash 'a (hash 'b 10)) '(c) 123)
               (hash 'a (hash 'b 10) 'c 123))
  (test-exn    "nested set fail - star functions"
               (lambda _ #t)
               (lambda () (nested-hash-set* (hash 'a 0) '(a b) 123)))
  )
