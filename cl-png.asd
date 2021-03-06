;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-

(defpackage :png-system (:use #:asdf #:cl))
(in-package :png-system)

(defsystem cl-png-system
  :name "cl-png"
  :version "0.1"
  :author "rannger"
  :depends-on ()
  :components ((:file "package")
	       (:file "deflate" :depends-on ("package"))
	       (:file "read" :depends-on ("package"))
	       (:file "png-chunk" :depends-on ("package"))
	       (:file "streams" :depends-on ("package"))))
