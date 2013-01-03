(in-package :liang.rannger.png)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defvar *binary-input-stream*
    #+sbcl 'sb-gray:fundamental-binary-input-stream
    #+ccl 'gray:fundamental-binary-input-stream
    #+allegro 'excl:fundamental-binary-input-stream
    #+lispworks 'stream:fundamental-binary-input-stream)
  (defvar *binary-output-stream*
    #+sbcl 'sb-gray:fundamental-binary-output-stream
    #+ccl 'gray:fundamental-binary-output-stream
    #+allegro 'excl:fundamental-binary-output-stream
    #+lispworks 'stream:fundamental-binary-output-stream)
  (defvar *stream-read-byte-function*
    #+sbcl 'sb-gray:stream-read-byte
    #+ccl 'gray:stream-read-byte
    #+allegro 'excl:stream-read-byte
    #+lispworks 'stream:stream-read-byte)
  (defvar *stream-write-byte-function*
    #+sbcl 'sb-gray:stream-write-byte
    #+ccl 'gray:stream-write-byte
    #+allegro 'excl:stream-write-byte
    #+lispworks 'stream:stream-write-byte))

(defclass png-data-input-stream (#.*binary-input-stream*)
  ((data-list :initform (list)
	      :reader data-list
	      :initarg :data-list)
   (read-position :initform 0
		  :reader read-position)))
	     

(defclass png-data-output-stream (#.*binary-output-stream*)
  ((data-list :initform (list)
	      :accessor data-list
	      :initarg :data-list)))

(defmethod #.*stream-read-byte-function* ((streams png-data-input-stream))
  (with-slots (data-list read-position) streams
    (if (>= read-position (length data-list))
	(error 'end-of-file :stream streams)
	(progn 
	  (incf read-position)
	  (nth (1- read-position) data-list)))))

(defmethod #.*stream-write-byte-function* ((streams png-data-output-stream) byte-value)
  (with-slots (data-list) streams
    (setf data-list (append data-list (list byte-value)))))