(in-package :png-system)

(defpackage :liang.rannger.png
  (:use :common-lisp
	#+sbcl :sb-gray
	#+ccl :gray)
  (:export :read-png
	   :png-chunk
           :chunk-IHDR
           :chunk-tEXt
           :chunk-IDAT
           :chunk-IEND
           :chunk-ITXT
           :chunk-bKGD
           :chunk-cHRM
           :chunk-gAMA
           :chunk-hIST
           :chunk-iCCP
           :chunk-iTXt
           :chunk-pHYs
           :chunk-sPLT
           :chunk-sRGB
           :chunk-sTER
           :chunk-tEXt
           :chunk-tIME
           :chunk-tRNS
           :chunk-zTXt))


