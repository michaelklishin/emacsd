(require 'markdown-mode)

(yas/load-directory "~/emacsd/bundles/markdown/snippets")

(add-to-list 'auto-mode-alist '("\\.markdown$" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode))
