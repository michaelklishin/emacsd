(require 'mustache-mode)

;; load bundle snippets
(yas/load-directory "~/emacsd/bundles/mustache/snippets")

(add-to-list 'auto-mode-alist '("\\.mustache$" . mustache-mode))
