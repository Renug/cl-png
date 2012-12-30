(in-package :liang.rannger.png)

(defclass png-data-input-stream (fundamental-binary-input-stream)
  ((data-list :initform (list)
	      :reader data-list
	      :initarg :data-list)
   (read-position :initform 0
		  :reader read-position)))
	     

(defclass png-data-output-stream (fundamental-binary-output-stream)
  ((data-list :initform (list)
	      :accessor data-list
	      :initarg :data-list)))

(defmethod stream-read-byte ((streams png-data-input-stream))
  (with-slots (data-list read-position) streams
    (if (>= read-position (length data-list))
	(error 'end-of-file :stream streams)
	(progn 
	  (incf read-position)
	  (nth (1- read-position) data-list)))))

(defmethod stream-write-byte ((streams png-data-output-stream) byte-value)
  (with-slots (data-list) streams
    (setf data-list (append data-list (list byte-value)))))