(load "yaml-mode")

;; load bundle snippets
;; (yas/load-directory "~/emacsd/bundles/yaml/snippets")

(add-to-list 'auto-mode-alist '("\\.yml$"  . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.yaml$" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.yaml.erb$" . yaml-mode))
