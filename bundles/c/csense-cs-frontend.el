;;; csense-cs-frontend.el --- C# support functions for Code Sense frontend

;; Copyright (C) 2007  

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
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; Require this package to use C# support with the Code Sense
;; frontend.
;;
;; See also the relevant configuration settings in csense.el and
;; csense-cs.el
;; 
;; Tested on Emacs 22.

;;; Code:

(require 'csense-cs)


;;; User configuration

(defconst csense-cs-frontend-msdn-url
  "http://msdn2.microsoft.com/en-us/library/%s.aspx"
  "URL to MSDN documentation.")

(defface csense-cs-frontend-reference-face
  '((t (:bold t)))
  "Face for references in documentation.")

(defface csense-cs-frontend-current-param-face
  '((t (:bold t)))
  "Face for highlighting the current parameter in a function invocation.")

(defface csense-cs-frontend-source-file-path-face
  '((t (:background "moccasin")))
  "Face for file path in documentation for symbols retrieved from the source")

;;;----------------------------------------------------------------------------

(add-hook 'csharp-mode-hook 'csense-cs-frontend-setup)
  

(defun csense-cs-frontend-setup ()
  "Setup CodeSense for the current C# buffer."
  (setq csense-information-function 
        'csense-cs-frontend-information-proxy)
  (setq csense-completion-function 
        'csense-cs-frontend-completion-proxy))


(defun csense-cs-frontend-information-proxy ()
  "Perform various modifications, before passing the retrieved
data for the CSense frontend."
  (mapcar (lambda (info)
            (setq info (csense-cs-frontend-doc-formatter info))

            ;; if it came from an assembly and it's in the
            ;; System. namespace then add the URL for documentation
            (unless (plist-get info 'file)
              (if (csense-cs-frontend-string-begins-with
                   (if (plist-get info 'members)
                       (plist-get info 'name)
                     (plist-get (plist-get info 'class) 'name))
                   "System.")
                  (setq info 
                        (plist-put info 'url
                                   (format csense-cs-frontend-msdn-url
                                           (if (plist-get info 'members)
                                               (plist-get info 'name)
                                             (concat
                                              (plist-get (plist-get info 'class)
                                                         'name)
                                              "."
                                              (plist-get info 'name))))))))

            info)
                                        
          (csense-cs-get-information-at-point)))


(defun csense-cs-frontend-completion-proxy ()
  "Perform various modifications, before passing the retrieved
completion data for the CSense frontend."
  (mapcar (lambda (info)
            (csense-cs-frontend-doc-formatter info))                                        
          (csense-cs-get-completions-for-symbol-at-point)))


(defun csense-cs-frontend-doc-formatter (info)
  "Format documentation for the CSense frontend."
  (plist-put
   info 
   'doc
   (csense-wrap-text
     ;; if it was found in the sources then show the relevant part of
     ;; the source code
     (if (plist-get info 'file)
         (concat (csense-cs-frontend-format-documentation-header info)
                 "\n\n"
                 (propertize 
                  (concat (csense-truncate-path (plist-get info 'file)) ":\n")
                  'face 'csense-cs-frontend-source-file-path-face)
                 "\n"
                 (csense-get-code-context (plist-get info 'file)
                                          (plist-get info 'pos)))

       ;; othewise format the retrieved documentation
       (let ((doc (plist-get info 'doc)))
         (setq doc
               (concat (csense-cs-frontend-format-documentation-header info)
                       "\n\n"
                       (if (not doc)
                           "No documentation"

                         ;; if parameters are documented then add
                         ;; their documentation to doc remove generics
                         (if (and (plist-member info 'params)
                                  (plist-get info 'params)
                                  (plist-get (car (plist-get info 'params))
                                             'doc))
                             (setq doc
                                   (concat 
                                    doc 
                                    "\n\nParameters:\n\n"
                                    (let ((index -1))
                                      (mapconcat 
                                       (lambda (param)
                                         (incf index)
                                         (let ((paramdoc
                                                (concat
                                                 "  "
                                                 (plist-get param 'name)
                                                 " - "
                                                 (plist-get param 'doc))))
                                           (if (eq index (plist-get 
                                                          info
                                                          'current-param))
                                               (propertize
                                                paramdoc
                                                'face
                                                'csense-cs-frontend-current-param-face)
                                             paramdoc)))
                                       (plist-get info 'params)
                                                 "\n\n")))))
                         
                         (replace-regexp-in-string
                          "`[0-9]+" ""
                          ;; format references
                          (let ((pos -1))
                            (while (setq pos (string-match 
                                              (rx "<see cref=\"" nonl ":" 
                                                  (group (*? nonl))
                                                  "\"></see>")
                                              doc (1+ pos)))
                              (setq doc
                                    (replace-match 
                                     (propertize 
                                      (match-string 1 doc) 
                                      'face
                                      'csense-cs-frontend-reference-face)
                                     nil nil doc)))
                            doc)))))

         ;; remove namespace from classnames for readability
         ;; (brute force approach)
         (setq doc (replace-regexp-in-string
                    "\\([a-zA-z]+\\.\\)+\\([a-zA-Z]\\)" "\\2"
                    doc))

         doc)))))


(defun csense-cs-frontend-format-documentation-header (info)
  "Prepare a formatted documentation header for INFO."
  (if (plist-get info 'members)
      (concat "class " 
              (plist-get info 'name))

    ;; class member
    (concat 
     (if (plist-get info 'static)
         "static ")
     (let ((type (csense-cs-frontend-resolve-type-alias (plist-get info 'type))))
       (if type
           (concat type " ")
         ;; constructors have no type
         ""))
     (plist-get info 'name)

     (if (plist-member info 'params)
         (concat "("
                 (let ((index -1))
                   (mapconcat 
                    (lambda (param)
                      (incf index)
                      (let ((paramtext
                             (concat
                              (csense-cs-frontend-resolve-type-alias
                               (plist-get param 'type))
                              " "
                              (plist-get param 'name))))
                        (if (eq index 
                                (plist-get info 'current-param))
                            (propertize
                             paramtext
                             'face
                             'csense-cs-frontend-current-param-face)
                          paramtext)))
                    (plist-get info 'params)
                    ", "))
                 ")")))))


(defun csense-cs-frontend-resolve-type-alias (type)
  "Replace TYPE with the corresponding alias if it has any."
  (or (some (lambda (alias)
              (if (equal (concat "System." (cdr alias)) type)
                  (car alias)))
            csense-cs-type-aliases)

      type))


(defun csense-cs-frontend-string-begins-with (str begin)
  "Return t if STR begins with the string BEGIN, or nil otherwise."
  (let ((begin-length (length begin)))
    (and (>= (length str)
             begin-length)
         (string= (substring str 0 begin-length)
                  begin))))


(provide 'csense-cs-frontend)
;;; csense-cs-frontend.el ends here
