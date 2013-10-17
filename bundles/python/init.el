(require 'python-mode)
;;(require 'pymacs)
;;(require 'pycomplete)
;;(require 'doctest-mode)

(add-to-list 'auto-mode-alist '("wscript$" . python-mode))
(add-to-list 'auto-mode-alist '("SConstruct$" . python-mode))

;; load bundle snippets
(yas/load-directory "~/emacsd/bundles/python/snippets")

(add-hook 'python-mode-hook 'untabify-buffer t)
