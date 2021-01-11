#!/usr/bin/clisp

(load "helper.lisp")
(load "config.lisp")
(load "builtin.lisp")


(defun lex (input)
  (let ((pos (search +temper-open+ input)))
    (if (null pos)
      (list (list 'string input))
      (let* ((before  (subseq input 0 pos))
             (input   (subseq input pos))
             (end-pos (search +temper-close+ input))
             (code    (subseq input +temper-close-len+ end-pos))
             (input   (subseq input (+ end-pos +temper-close-len+))))
        (append
          (list
            (list 'string before)
            (if (equal (char code 0) +temper-interpolate+)
              (list 'interpolation (subseq code 1))
              (list 'code code)))
          (lex input))))))


; (defun temper-buf-push (&rest strings)
;   (setf *temper-buf

(defun tokens-to-code-string (tokens)
  (apply #'concatenate 'string
    (map
      'list
      #'(lambda (token)
         (let ((token-type    (first token))
               (token-content (second token)))
             (ecase token-type
               ('code token-content)
               ('interpolation
                (format nil "~S"
                  `(setf *temper-buf*
                    (concatenate 'string
                                 *temper-buf*
                                 (format nil "~A" ,(read-from-string token-content))))))
               ('string
                (format nil "~S"
                  `(setf *temper-buf*
                    (concatenate 'string *temper-buf* ,(string-trim '(#\linefeed) token-content))))))))
      tokens)))


(defvar *temper-buf* "")

(defun generate (tokens &rest args)
  `(let ,(apply #'rest-keys args)
     (progn
      (eval ,(read-from-string
        (concatenate 'string
          "(progn "
          (tokens-to-code-string tokens)
          ")"))))))


(defun render-stream (stream &rest args)
  (setq tokens (lex (read-all-stream stream)))
  (eval (apply #'generate (cons tokens args))))

(defun render (filename &rest args)
  (with-open-file (stream filename)
    (apply #'render-stream (cons stream args))))

(princ (render-stream *standard-input* 'foo "bon" 'bar "jour"))

; (princ (render "test.html" 'foo "bon" 'bar "jour"))

; (print (make-index "d"))
