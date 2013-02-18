;; load bundle snippets
(yas/load-directory "~/emacsd/bundles/emacs-lisp/snippets")

(require 'highlight-parentheses)

(highlight-parentheses-mode)

(autoload 'highlight-parentheses-mode "highlight parenthesis"
  "Highlights parenthesis in Lisp code." t)
(add-hook 'emacs-lisp-mode-hook          (lambda () (highlight-parentheses-mode +1)))

(add-hook 'emacs-lisp-mode-hook       (lambda () (paredit-mode +1)))
(add-hook 'lisp-mode-hook             (lambda () (paredit-mode +1)))
(add-hook 'lisp-interaction-mode-hook (lambda () (paredit-mode +1)))
