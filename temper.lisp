#!/usr/bin/clisp

(load "/home/charles/.clisprc.lisp")
(ql:quickload "uiop")
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


(defgeneric render (input &rest args))

(defmethod render ((input stream) &rest args)
  (prog1
    (eval (apply #'generate (cons (lex (read-all-stream input)) args)))
    (setf *temper-buf* "")))

(defmethod render ((filename string) &rest args)
  (with-open-file (input filename)
    (apply #'render (cons input args))))


(when (null *args*)
  (princ (render *standard-input*))
  (exit))


(dolist (arg *args*)
  (if (uiop:directory-pathname-p arg)
    (uiop:collect-sub*directories ; TODO
      dirname
      (constantly t)
      (constantly t)
      (lambda (f) (print f)))
    (princ (render arg))))
