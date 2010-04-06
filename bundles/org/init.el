(require 'org)
;; use org-mode for .org files
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(add-to-list 'auto-mode-alist '("\\.org.erb$" . org-mode))
(add-to-list 'auto-mode-alist '("\\.notes?$" . org-mode))

;; load bundle snippets
(yas/load-directory "~/emacsd/bundles/org/snippets")