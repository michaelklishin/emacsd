(load "haml-mode")

;; load bundle snippets
(yas/load-directory "~/emacsd/bundles/haml/snippets")

(add-to-list 'auto-mode-alist '("\\.haml$" . haml-mode))