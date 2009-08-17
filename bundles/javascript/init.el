(load "js2-mode")
(require 'js2-mode)

(yas/load-directory "~/emacsd/bundles/javascript/snippets")

(add-to-list 'auto-mode-alist '("\\.js" js2-mode))
