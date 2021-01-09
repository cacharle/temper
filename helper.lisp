; read a stream into a string
(defun read-all-stream (stream)
  (let ((line (read-line stream nil)))
    (if line (concatenate 'string line '(#\linefeed) (read-all-stream stream)) "")))


; convert variable arguments into variable keyword arguments
(defun rest-keys (&rest args)
  (if (null args)
    '()
    (destructuring-bind (key value &rest args) args
      (cons (list key value) (apply #'rest-keys args)))))
