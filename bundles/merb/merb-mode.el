;;
;; merb-mode.el
;;
(eval-when-compile (require 'cl))
(require 'ruby-mode)


;;
;; router
;;

(setq merb-router-mode-syntax-table (make-syntax-table ruby-mode-syntax-table))

(cond
 ((featurep 'font-lock)
  (or (boundp 'font-lock-variable-name-face)
      (setq font-lock-variable-name-face font-lock-type-face)))
 (set (make-local-variable 'font-lock-syntax-table) merb-router-font-lock-syntax-table))

(defconst merb-router-mode-font-lock-keywords
  '("resources\\?" "match" "to" "name" "defer_to"))

(define-derived-mode merb-router-mode ruby-mode "merb-router"
  "Major mode for editing Merb routes file (derived from ruby-mode)"
  :syntax-table merb-router-mode-syntax-table
  :group "merb")

(defun merb-mode/install-extra-font-lock-keywords-for-router()
  "adds merb router specific keywords to the font lock map"
  (message "merb-mode: installing extra font lock keywords for router")
  (set (make-local-variable 'font-lock-defaults) '((merb-router-mode-font-lock-keywords) nil nil)))


(add-hook 'merb-router-mode
          'merb-mode/install-extra-font-lock-keywords-for-router)

(add-to-list 'auto-mode-alist '("router\\.rb$" . merb-router-mode))
(provide 'merb-router-mode)



;;
;; init file
;;

(define-derived-mode merb-init-mode ruby-mode "merb-init"
  "Major mode for editing Merb init file (derived from ruby-mode)"
  :syntax-table ruby-mode-syntax-table
  :group "merb")

(add-to-list 'auto-mode-alist '("init\\.rb$" . merb-init-mode))
(provide 'merb-init-mode)