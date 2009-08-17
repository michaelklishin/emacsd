(require 'scala-mode-auto)

;; load bundle snippets
(yas/load-directory "~/emacsd/bundles/scala/snippets")

(add-to-list 'auto-mode-alist '("\\.scala$" . scala-mode))
