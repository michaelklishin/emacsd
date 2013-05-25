(require 'rust-mode)

(add-to-list 'auto-mode-alist '("\\.rs$" . rust-mode))

;; load bundle snippets
(yas/load-directory "~/emacsd/bundles/rustlang/snippets")
