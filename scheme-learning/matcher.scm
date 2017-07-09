#lang scheme

(define (atom? x)
  (and (not (pair? x))
       (not (null? x))))

(define (match pat exp dict)
  (cond
    ((eq? dict 'failed) 'failed)
    ((atom? pat)
     (if (and (atom? exp)
              (eq? pat exp))
         dict
         'failed))
    ((and (null? pat)
          (null? exp))
     dict)
    ((null? pat) 'failed)
    ((null? exp) 'failed)
    ;; ... to handle more predicates ...
    ((arbitary-atom? pat)
     (if (atom? exp)
         (extend-dict pat exp dict)
         'failed))
    ((arbitary-pair? pat)
     (if (pair? exp)
         (extend-dict pat exp dict)
         'failed))
    ((arbitary-expression? pat)
     (extend-dict pat exp dict))
    ((atom? exp)
     'failed)
    (else
     (match (cdr pat)
            (cdr exp)
            (match (car pat)
                   (car exp)
                   dict)))))

(define (instantiate skeleton dict)
  (define (sub-instantiate s)
    (cond
      ((atom? s) s)
      ((null? s) '())
      ((skeleton-evaluation? s)
       (skeleton-evaluate (cadr s) dict))
      (else (cons (sub-instantiate (car s))
                  (sub-instantiate (cdr s))))))
  (sub-instantiate skeleton))

(define (extend-dict pat exp dict)
  (let ((name (cadr pat)))
    (let ((v (assq name dict)))
      (cond ((not v)
             (cons (list name exp) dict))
            ((equal? (cadr v) exp) dict)
            (else 'failed)))))

(define (simplifier the-rules)
  (define (simplify-exp exp)
    (try-rules (if (pair? exp)
                   (map simplify-exp exp)
                   exp)))
  (define (try-rules exp)
    (define (scan rules)
      (if (null? rules)
          exp
          (let ((dict (match (pattern-of (car rules))
                             exp
                             '())))
            (if (eq? dict 'failed)
                (scan (cdr rules))
                (begin
                 (write exp)
                 (newline)
                 (display "|> ")
                 (write (caar rules))
                 (newline)
                 (display "-> ")
                 (write (cadar rules))
                 (newline)
                 (newline)
                 (simplify-exp
                  (instantiate
                      (skeleton-of (car rules))
                    dict)))))))
    (scan the-rules))
  simplify-exp)

(define (arbitary-atom? pat)
  (eq? (car pat) '?a))

(define (arbitary-pair? pat)
  (eq? (car pat) '?p))

(define (arbitary-expression? pat)
  (eq? (car pat) '?))

(define (skeleton-evaluation? s)
  (eq? (car s) ':))

(define (skeleton-evaluate s dict)
  (if (atom? s)
      (lookup s dict)
      (eval
       `(let ,(map (lambda (s)
                     (list (car s)
                           (list 'quote
                                 (cadr s))))
                   dict)
          ,s))))

(define (lookup s dict)
  (let ((t (assq s dict)))
    (if t
        (cadr t)
        s)))

(define (pattern-of rule)
  (car rule))

(define (skeleton-of rule)
  (cadr rule))

