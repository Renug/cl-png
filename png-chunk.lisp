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


(defmethod print-png-chunk ((chunk png-chunk))
  (format t "data-length:~a chunk-type:~a crc-code:~a ~%~%" 
          (data-length chunk)
          (chunk-type chunk)
          (crc-code chunk)))

(defmethod make-chunk-data-instance ((chunk png-chunk))
  (print-field
   (init-field 
    (make-instance (intern (string-upcase (concatenate 'string "chunk-" (chunk-type chunk))) :liang.rannger.png)
		  :chunk-binary-data (chunk-data chunk)))))

(defmethod check-png-crc ((chunk png-chunk))
  (= (liang.rannger.crc:crc (chunk-data chunk) #x104C11DB7)
     (crc-code chunk)))

(defclass png-data-chunk ()
  ((chunk-binary-data :initarg :chunk-binary-data
                      :accessor chunk-binary-data)))

(defmethod init-field ((chunk png-data-chunk))
  chunk)

(defmethod print-field ((chunk png-data-chunk))
  (format t "~a~%" chunk))

(defclass chunk-IHDR (png-data-chunk)
  ((width :accessor width
          :initarg :width
          :initform 0)
   (height :accessor height
           :initarg :height
           :initform 0)
   (bit-depth :accessor bit-depth
              :initarg :bit-depth
              :initform 0)
   (color-type :accessor color-type
               :initarg :color-type)
   (compression-method :accessor compression-method
                       :initarg :compression-method)
   (filter-method :accessor filter-method
                  :initarg :filter-method)
   (interlace-method :accessor interlace-method
                     :initarg :interlace-method)))

(defmethod init-field ((chunk chunk-IHDR))
  (with-slots (width height bit-depth color-type compression-method filter-method interlace-method chunk-binary-data) chunk
    (setf width (bytes-to-number (subseq chunk-binary-data 0 4)))
    (setf height (bytes-to-number (subseq chunk-binary-data 4 8)))
    (setf bit-depth (bytes-to-number (subseq chunk-binary-data 8 9)))
    (setf color-type (bytes-to-number (subseq chunk-binary-data 9 10)))
    (setf compression-method (bytes-to-number (subseq chunk-binary-data 10 11)))
    (setf filter-method (bytes-to-number (subseq chunk-binary-data 11 12)))
    (setf interlace-method (bytes-to-number (subseq chunk-binary-data 12 13))))
  (return-from init-field chunk))


(defmethod print-field ((chunk chunk-IHDR))
  (with-slots (width height bit-depth color-type compression-method filter-method interlace-method) chunk
    (format t "~%width:~a~%height:~a~%bit-depth:~a~%color-type:~a~%compression-method:~a~%filter-method:~a~%interlace-method:~a~%" 
            width
            height
            bit-depth
            color-type
            compression-method
            filter-method
            interlace-method)))


(defclass chunk-PLTE (png-data-chunk)
  ((color-list :accessor color-list
	       :initarg :color-list
	       :initform nil)))

(defmethod init-field ((chunk chunk-PLTE))
  (labels ((make-color-list (lst)
	     (when (not (null lst))
		 (append (list (subseq lst 0 3)) (make-color-list (cdddr lst))))))
    (with-slots (chunk-binary-data color-list) chunk
      (let ((list-data (copy-list chunk)))
	(unwind-protect
	     (unless (= 0 (mod (length list-data) 3))
	       (error "it's not legitimate")
	       (return-from init-field chunk))
	  (setf color-list (make-color-list list-data))))))
  chunk)

	  
(defclass chunk-IDAT (png-data-chunk)
  ((uncompress-data :accessor uncompress-data
		   :initarg :uncompress-data
		   :initform 0)))


(defmethod init-field ((chunk chunk-IDAT))
  (with-slots (uncompress-data chunk-binary-data) chunk
    (let ((input-stream (make-instance 'png-data-input-stream :data-list chunk-binary-data))
	  (output-stream (make-instance 'png-data-output-stream)))
      (inflate-zlib-stream input-stream output-stream)
      (setf uncompress-data (data-list output-stream))))
  (return-from init-field chunk))
  
(defclass chunk-IEND (png-data-chunk)
  ()) 

(defmethod print-field ((chunk chunk-IEND))
  (format t "it's end.~%"))

(defclass chunk-bKGD (png-data-chunk)
  ())

(defclass chunk-cHRM (png-data-chunk)
  ())

(defclass chunk-gAMA (png-data-chunk)
  ((image-gamma :accessor image-gamma
		:initarg :image-gamma
		:initform nil)))

(defmethod init-field ((chunk chunk-gAMA))
  (with-slots (image-gamma chunk-binary-data) chunk
    (setf image-gamma (bytes-to-number chunk-binary-data)))
  chunk)

(defmethod print-field ((chunk chunk-gAMA))
  (with-slots (image-gamma) chunk
    (format t "Image gamma:~a~%" image-gamma)))

(defclass chunk-hIST (png-data-chunk)
  ())   

(defclass chunk-iCCP (png-data-chunk)
  ())           
  
(defclass chunk-iTXt (png-data-chunk)
  ())

(defclass chunk-pHYs (png-data-chunk)
  ())

(defclass chunk-sBIT (png-data-chunk)
  ())

(defclass chunk-sPLT (png-data-chunk)
  ())

(defclass chunk-sRGB (png-data-chunk)
  ())

(defclass chunk-sTER (png-data-chunk)
  ())

(defclass chunk-tEXt (png-data-chunk)
  ((text-keyword :accessor text-keyword
	    :initform ""
	    :initarg :keyword)
   (text-content :accessor text-content
	    :initform ""
	    :initarg :content)))

(defmethod print-field ((chunk chunk-tEXt))
  (with-slots (text-keyword text-content) chunk
    (format t "keyword:~a~%content:~a~%" text-keyword text-content)))

(defmethod init-field ((chunk chunk-tEXt))
  (flet ((split-by-one-space (string)
	   (loop for i = 0 then (1+ j)
	      as j = (position #\Space string :start i)
	      collect (subseq string i j)
	      while j)))
    (with-slots (text-keyword text-content chunk-binary-data) chunk
	       (let ((str-list (split-by-one-space (concatenate 'string (mapcar #'code-char chunk-binary-data)))))
		 (setf text-keyword (first str-list))
		 (setf text-content (second str-list)))))
  chunk)
	       

(defclass chunk-tIME (png-data-chunk)
  ())

(defclass chunk-tRNS (png-data-chunk)
  ())

(defclass chunk-zTXt (png-data-chunk)
  ())

