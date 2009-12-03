;;; tehom-psgml-link.el --- bare-bones hyperlinks in psgml

;; Copyright (C) 1999 by Tom Breton

;; Author: Tom Breton <Tehom@localhost>
;; Keywords: hypermedia

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; This is a bare-bones hyperlink system.  It does not aspire to be
;; XLL. Its humble virtue is that it is here now and works with psgml
;; in arbitrary SGML and XML documents.  You don't need to have XLL or
;; anything of the sort.

;; What it does is allow you to specify attributes of elements in your
;; various doctypes that will act like local hyperlinks.  IE, when the
;; point is in the proper element, M-x tehom-psgml-follow-link will
;; bring up the file that the element links to.  

;; You set this up by setting the value of tehom-psgml-link-list.  The
;; easiest way to do this is to customize tehom-psgml-link-list, where
;; it should be self-explanatory.

;; NB, this handles links to local files only.  If someone wants to
;; extend this to work with ftap or browse-url or something similar,
;; be my guest.


;; To install, 
;;   Put tehom-psgml-link somewhere on your load path
;;   Set up an autoload for tehom-psgml-follow-link
;;   Customize tehom-psgml-link-list

;; You'll want to re-customize tehom-psgml-link-list every time you
;; want another dtd to act like it has hyperlinks.

;;; Code:

(require 'cl)
(require 'psgml)

(defgroup tehom-psgml nil "Group for local psgml extensions."
  :group 'local
  :group 'hypermedia)

(defcustom tehom-psgml-link-list nil

  "*List of SGML/XML attributes to be treated as hyperlinks.

The command M-x tehom-psgml-follow-link will follow the link to a
local file."

  ;;Setting :version seems to make it blow up.
  ;;:version "20.2"

  :tag "List of attributes that should be treated as hyperlinks."

  ;;I'd like to filter this wrt the elements of a doctype, which would
  ;;make it safer and easier to create, but it would be a PITA to
  ;;write because it's hard to always find a file for each dtd.

  :type 
  '(repeat 
     (cons (string :tag "Links in doctype" ) 
       (repeat  
	 (list
	   (string :tag "...in element" )
	   (repeat ( string :tag "...in attribute" ))))))

  :group 'tehom-psgml)


;;;;;;;;;;;;;;;;;;;;
;;Access functions

;;The following functions use an easy but weak way to find the
;;matching element: They use only the first match.  A stronger way
;;would use the cl function "some" and work on each matching entry.
;;I don't consider that warranted at this time.
;;
;;;;;;;;;;
;;
(defsubst tehom-psgml-get-doc-link-control (doctype-name)
  "Return the link control list for the given doctype.

DOCTYPE-NAME is the name of a doctype."

  (cdr (assoc doctype-name tehom-psgml-link-list)))


(defsubst tehom-psgml-get-element-link-control (doc-link-control el-name)
  "Return the link control list for the given element.

DOC-LINK-CONTROL is a link control list pertaining to a particular
doctype.  EL-NAME is the name of an element."

  (cdr (assoc el-name doc-link-control)))


;;;;;;;;;;;;;;;
(defun tehom-psgml-get-link-string ()
  "Get the string associated with a hyperlink wherever the point is." 

  ;;Ensure we have a doctype
  (sgml-need-dtd)

  (let*
    (
      (dtd (sgml-pstate-dtd sgml-buffer-parse-state))
      (doctype-name (sgml-dtd-doctype dtd))
      (doc-link-control 
	(tehom-psgml-get-doc-link-control doctype-name)) 

      (el (sgml-find-element-of (point)))
      (el-name (sgml-element-gi el))
      (el-link-control
	(tehom-psgml-get-element-link-control doc-link-control el-name))


      (att-list (sgml-element-attribute-specification-list el))

      ;;This search is NxM, but both N and M are usually very small.
      (attribute
	(some
	  ( function
	    ( lambda (x)
	      (if
		(assoc (car x) el-link-control)
		(cdr x))))
	  
	  att-list)))
    
    attribute))



;;;;;;;;;;;;;;;;;;;;
;;The entry point.

;;;###autoload
(defun tehom-psgml-follow-link ()
  "Follow a link to a local file."
  
  (interactive)
  (let*
    ((link-string (tehom-psgml-get-link-string)))
    
    ;;For upward compatibility, it would be nice to strip off a
    ;;"file://" prefix if it exists. 
    (if
      link-string
      (find-file link-string))))

;;;;;;;;;;;;;;;;

(provide 'tehom-psgml-link)

;;; tehom-psgml-link.el ends here
