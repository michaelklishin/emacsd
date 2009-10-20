(require 'ruby-mode)
(require 'pcmpl-rake)

;; load bundle snippets
;; (yas/load-directory "~/emacsd/bundles/rake/snippets")

(add-to-list 'auto-mode-alist '("Rakefile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode))