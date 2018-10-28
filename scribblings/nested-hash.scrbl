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

Provides @racket[hash-ref] and @racket[hash-set] variants that operate on nested hash tables, that is, a hash table inside a hash table.

@defproc[(nested-hash-ref [hash* hash?] [key any/c] ...+ [#:default default any/c #f])
         any?]{
  Accesses a hash table recursively using the given @racket[key]s. @racket[default] is returned if a key does not exist. An error is raised if an access is performed on a non-hash entry.
}

@defproc[(nested-hash-set [hash* hash?] [key any/c] ...+ [value any/c] [#:hash hash any/c hash])
         any?]{
  Functionally edits a hash table using the given @racket[key]s and @racket[value]. Non-existent keys will automatically become new subtables. Existing intermediate keys that are associated with non-hash values will raise an error.
  The @racket[#:hash] keyword specifies a constructor for creating new nested hash tables.
}

@examples[#:eval evaluator
    (nested-hash-ref (hash 'a (hash 'b 123)) 'a 'b)
    (nested-hash-set (hash) 'a 'b 123)
]

Similarly to the previous functions we have similar functions that take actual lists instead of inline-lists. These may be useful to avoid using @racket[apply] when generating lists of accesses.

@defproc[(nested-hash-ref* [hash* hash?] [keys (listof any/c)] [#:default default any/c #f])
         any?]{
  Accesses a hash table recursively using the given @racket[keys]. @racket[default] is returned if a key does not exist. An error is raised if an access is performed on a non-hash entry.
}

@defproc[(nested-hash-set* [hash* hash?] [keys (listof any/c)] [value any/c] [#:hash hash any/c hash])
         any?]{
  Functionally edits a hash table using the given @racket[keys] and @racket[value]. Non-existent keys will automatically become new subtables. Existing intermediate keys that are associated with non-hash values will raise an error.
  The @racket[#:hash] keyword specifies a constructor for creating new nested hash tables.
}

@examples[#:eval evaluator
    (nested-hash-ref* (hash 'a (hash 'b 123)) '(a b))
    (nested-hash-set* (hash) '(a b) 123)
]
