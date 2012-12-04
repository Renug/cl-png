(defpackage :liang.rannger.crc
  (:use :common-lisp)
  (:export :crc))

(in-package :liang.rannger.crc)

(defun crc (data &optional (polynomial-binary-number #b111010101))
  (flet ((binary-string (num) (format nil "~b" num)))
    (let* ((binary-number-length (length (binary-string polynomial-binary-number)))
	   (remainder (ash data (1- binary-number-length))))
      (loop while (>= (length (binary-string remainder)) binary-number-length)
	 do(setf remainder (logxor remainder 
				   (ash polynomial-binary-number 
					(- (length (binary-string remainder)) binary-number-length)))))
      remainder)))

