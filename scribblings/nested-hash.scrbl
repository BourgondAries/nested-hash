#lang scribble/manual
@require[@for-label[nested-hash
                    racket/base
                    racket/contract/base]
          racket/sandbox
          scribble/example]

@(define evaluator (parameterize ([sandbox-output 'string]
                                  [sandbox-error-output 'string]
                                  [sandbox-memory-limit 500])
                     (make-evaluator 'racket '(require nested-hash))))

@title{nested-hash}
@author{Kevin R. Stravers}

@defmodule[nested-hash]

@defproc[(nested-hash-ref [hash* hash?] [key any/c] ...+ [#:default default any/c #f])
         any?]{
  Accesses a hash table recursively using the given keys. @racket[default] is returned if a key does not exist. An error is raised if an access is performed on a non-hash entry.
}

@defproc[(nested-hash-set [hash* hash?] [key any/c] ...+ [value any/c])
         any?]{
  Functionally edits a hash table using the given @racket[key]s and @racket[value]. Non-existent keys will automatically become new subtables. Existing intermediate keys that are associated with non-hash values will raise an error.
}

@examples[#:eval evaluator
(nested-hash-ref (hash 'a (hash 'b 123)) 'a 'b)
(nested-hash-set (hash) 'a 'b 123)
]
