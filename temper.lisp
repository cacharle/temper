(defun read-all ()
  (let ((line (read-line *standard-input* nil)))
    (if line
      (concatenate 'string line '(#\linefeed) (read-all))
      "")))


(setq *temper-open* "{%")
(setq *temper-close* "%}")

(defun parse (input)
  (let ((pos (search *temper-open* input)))
    (if (null pos)
      (list "\"" input "\"")
      (let* ((before    (subseq input 0 pos))
             (input     (subseq input pos))
             (end-pos   (search *temper-close* input))
             (close-len (length *temper-close*))
             (code      (subseq input close-len end-pos))
             (input     (subseq input (+ end-pos close-len))))
        (append (list "\"" before "\"" code) (parse input))))))



(setq res (append '("(concatenate 'string ") (parse (read-all)) '(" ) ")  ))
(setq str (format nil "~{~A~^ ~}" res))
(princ str)
; (print (eval (read-from-string str)))

; (read-from-string (parse (read-all)))
