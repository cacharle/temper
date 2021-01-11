(defun make-index (dirname &key (item-tag "li") (surrounding-tag "ul") (include-date nil))
  (setf filepaths (uiop:directory-files dirname))
  ; (when test (delete-if #'(lambda (x) (not (test x))) filenames))
  (format nil "<~A>~A</~A>"
    surrounding-tag 
    (format nil "~{~A~%~}"
      (mapcar #'(lambda (filepath)
                  (let* ((filename (file-namestring filepath))
                         (name     filename))
                    (format nil "<~A><a href=\"~A/~A\">~A</a></~A>" item-tag dirname filename name item-tag)))
               filepaths))
    surrounding-tag))

; (uiop:run-program (list "seq" "10" "20") :output t)
