;;
;; datamapper-mode.el
;;
(eval-when-compile (require 'cl))
(require 'ruby-mode)

;;
;; syntax table
;;

(setq ruby-datamapper-mode-syntax-table (make-syntax-table ruby-mode-syntax-table))

;;
;; font locking
;;

(cond
 ((featurep 'font-lock)
  (or (boundp 'font-lock-variable-name-face)
      (setq font-lock-variable-name-face font-lock-type-face)))
 (set (make-local-variable 'font-lock-syntax-table) ruby-datamapper-font-lock-syntax-table))

(defconst ruby-datamapper-mode-font-lock-keywords
  (list
   ;;
   ;; dm-core
   ;;
   '("property"              . font-lock-keyword-face)
   '("DataMapper"            . font-lock-keyword-face)
   '("Resource"              . font-lock-keyword-face)
   '("after"                 . font-lock-keyword-face)
   '("before"                . font-lock-keyword-face)
   '("has"                   . font-lock-keyword-face)
   '("belongs_to"            . font-lock-keyword-face)
   '("attribute_set"         . font-lock-keyword-face)
   ;;
   ;; dm-validations
   ;;
   '("validates_present"     . font-lock-keyword-face)
   '("validates_absent"       . font-lock-keyword-face)
   '("validates_is_confirmed" . font-lock-keyword-face)
   '("validates_length"       . font-lock-keyword-face)
   '("validates_format"       . font-lock-keyword-face)
   '("validates_is_number"    . font-lock-keyword-face)
   '("validates_is_primitive" . font-lock-keyword-face)
   '("validates_is_unique"    . font-lock-keyword-face)
   '("validates_with_block"   . font-lock-keyword-face)
   '("validates_with_method"  . font-lock-keyword-face)
   '("validates_within"       . font-lock-keyword-face)
   '("validates_is_accepted"  . font-lock-keyword-face)
   ;;
   ;; dm-timestamps
   ;;
   '("timestamps"             . font-lock-keyword-face))
   ;;
   ;; dm-adjust
   ;;
   '("adjust!"                . font-lock-keyword-face))

;;
;; derived mode
;;

(define-derived-mode datamapper-mode ruby-mode "Datamapper"
  "Major mode for editing DataMapper models (derived from ruby-mode)"
  :syntax-table ruby-datamapper-mode-syntax-table
  :group        "datamapper")

;;
;; hooks
;;

(defun merb-mode/install-extra-font-lock-keywords-for-router()
  "adds merb router specific keywords to the font lock map"
  (message "merb-mode: installing extra font lock keywords for router")
  (set (make-local-variable 'font-lock-defaults) '((ruby-datamapper-mode-font-lock-keywords) nil nil)))


;; (add-to-list 'auto-mode-alist '("app/models" . datamapper-mode))
