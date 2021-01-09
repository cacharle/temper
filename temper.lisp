#!/usr/bin/env clisp

(load "helper.lisp")
(load "config.lisp")


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


(defun tokens-to-code-string (tokens)
  (apply #'concatenate 'string
    (map
      'list
      #'(lambda (token)
         (let ((token-type    (first token))
               (token-content (second token)))
             (cond
               ((eql token-type 'code) token-content)
               ((eql token-type 'interpolation)
                (format nil "~S"
                  `(setf buf
                    (concatenate 'string
                                 buf
                                 (format nil "~A" ,(read-from-string token-content))))))
               ((eql token-type 'string)
                (format nil "~S"
                  `(setf buf
                    (concatenate 'string buf ,(string-trim '(#\linefeed) token-content))))))))
      tokens)))


(defun generate (tokens &rest args)
  `(let ,(apply #'rest-keys args)
     (progn
      (setq buf "")
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


; (princ (render-stream *standard-input* 'foo "bon" 'bar "jour"))

(princ (render "test.html" 'foo "bon" 'bar "jour"))
