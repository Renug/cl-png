(in-package :liang.rannger.png)

(defun read-png (path)
  (with-open-file (png-stream path
			      :element-type '(unsigned-byte 8))
    (let ((png-file-flag (loop repeat 8 collect (read-byte png-stream nil 'eof))))
      (when (equal png-file-flag '(137 80 78 71 13 10 26 10))
	(print "it's a png file")))))

(defun read-png-data-chunk (stream)
  (flet ((read-a-chunk (stream)
	   (let* ((data-length (loop repeat 4 collect (read-byte stream nil 'eof)))
		  (type-code (loop repeat 4 collect (read-byte stream nil 'eof)))
		  (chunk (make-instance 'png-chunk)))
	     (setf (data-length chunk) (logior (ash (first data-length) 24) 
					       (ash (second data-length) 16)
					       (ash (third data-length) 8)
					       (fourth data-length)))
	     (setf (chunk-data chunk) (loop repeat (data-length chunk) collect (read-byte stream)))
	     (setf (crc-code chunk) (loop repeat 4 collect (read-byte stream))))))
    (loop for chunk = (read-a-chunk stream)
	 while chunk 
	 collect chunk)))
	     
	     