(in-package :liang.rannger.png)

(defun bytes-to-number (bytes)
  (if (null bytes)
    0
    (logior (ash (first bytes) 
                 (* 8 (1- (length bytes)))) 
            (bytes-to-number (cdr bytes)))))

(defun read-png (path)
  (with-open-file (png-stream path
			      :element-type '(unsigned-byte 8))
    (let ((png-file-flag (loop repeat 8 collect (read-byte png-stream nil 'eof))))
      (when (equal png-file-flag '(137 80 78 71 13 10 26 10))
        (mapcar #'make-chunk-data-instance (read-png-data-chunk png-stream))))))



(defun eof-p (var)
  (eql var 'eof))

(defun read-png-data-chunk (stream)
  (flet ((read-a-chunk (stream)
	   (let* ((data-length (loop repeat 4 collect (read-byte stream nil 'eof)))
		  (type-code (loop repeat 4 collect (read-byte stream nil 'eof)))
                  (chunk-data nil)
                  (crc-code nil))
             (if (member 'eof (append data-length type-code))
               (return-from read-a-chunk 'eof)
	       (progn
		 (setf chunk-data (make-list (bytes-to-number data-length)))
		 (read-sequence chunk-data stream)))
             (if (member 'eof chunk-data)
               (return-from read-a-chunk 'eof)
               (setf crc-code (loop repeat 4 collect (read-byte stream))))
             (if (member 'eof crc-code)
               (return-from read-a-chunk 'eof)
               (make-instance 'png-chunk 
                 :data-length (bytes-to-number data-length)
                 :chunk-data chunk-data
                 :chunk-type (coerce (mapcar #'code-char type-code) 'string)
                 :crc-code (bytes-to-number crc-code))))))
    (loop for chunk = (read-a-chunk stream)
	 until (eof-p chunk)
	 collect chunk)))
	     
	     
	     
