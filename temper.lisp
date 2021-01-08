(defun read-all ()
  (let ((line (read-line *standard-input* nil)))
    (if line
      (concatenate 'string line '(#\linefeed) (read-all))
      "")))


(defconstant +temper-open+ "<%")
(defconstant +temper-close+ "%>")
(defconstant +temper-close-len+ (length +temper-close+))
(defconstant +temper-interpolate+ #\=)

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
                                 (format nil "~A" ,(read-from-string token-content))
                                 '(#\linefeed)))))
               ((eql token-type 'string)
                (format nil "~S"
                  `(setf buf
                    (concatenate 'string
                                 buf
                                 ,(string-trim '(#\linefeed #\space) token-content)
                                 '(#\linefeed))))))))
      tokens)))

(defun generate (tokens)
  `(progn
    (setq buf "")
    (eval ,(read-from-string
      (concatenate 'string
        "(progn "
        (tokens-to-code-string tokens)
        ")")))))


; (format t "~A" (tokens-to-code-string (lex (read-all))))
(setq res (generate (lex (read-all))))
(format t "~A" (eval res))
