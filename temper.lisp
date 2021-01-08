(defun read-all ()
  (let ((line (read-line *standard-input* nil)))
    (if line
      (concatenate 'string line '(#\linefeed) (read-all))
      "")))


(defconstant +temper-open+ "<%")
(defconstant +temper-close+ "%>")
(defconstant +temper-close-len+ (length +temper-close+))

(defun lex (input)
  (let ((pos (search +temper-open+ input)))
    (if (null pos)
      (list (list 'string input))
      (let* ((before    (subseq input 0 pos))
             (input     (subseq input pos))
             (end-pos   (search +temper-close+ input))
             (code      (subseq input +temper-close-len+ end-pos))
             (input     (subseq input (+ end-pos +temper-close-len+))))
        (append (list (list 'string before) (list 'code code)) (lex input))))))


(defun generate (tokens)
  `(progn
    (setq buf "")
    (eval ,(read-from-string
      (concatenate 'string
        (map
          'string
          #'(lambda (token)
             (let ((token-type    (first token))
                   (token-content (second token)))
                 (if (eql token-type 'string)
                   (format nil "~A"
                     `(setf buf (concatenate 'string buf ,token-content)))
                   token-content)))
          tokens))))))


(setq res (generate (lex (read-all))))
(setq str (format t "~{~A~^ ~}" res))

; (princ str)

; (print (eval (read-from-string str)))

; (read-from-string (lex (read-all)))
