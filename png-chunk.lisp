(in-package :liang.rannger.png)

(defclass png-chunk ()
  ((data-length :accessor data-length
	  :initarg :data-length
	  :initform 0)
  (chunk-type :accessor chunk-type
	      :initarg :chunk-type)
  (chunk-data :accessor chunk-data
	      :initarg :chunk-data
	      :initform nil)
  (crc-code :accessor crc-code
	    :initarg :crc-code
	    :initform 0)))
