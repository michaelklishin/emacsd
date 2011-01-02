(yas/load-directory "~/emacsd/bundles/javascript/snippets")

(require 'js2-mode)
(add-to-list 'auto-mode-alist '("\\.js" js2-mode))
(add-to-list 'auto-mode-alist '("\\.json" js2-mode))
