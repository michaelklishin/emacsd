;; a workaround for a possible Emacs 23.1 bug. MK.
(setq warning-suppress-types nil)

(require 'clojure-mode)
(require 'clojure-test-mode)

;; (require 'paredit)
(require 'highlight-parentheses)

;; load bundle snippets
(yas/load-directory "~/emacsd/bundles/clojure/snippets")

(highlight-parentheses-mode)
;; (paredit-mode)

(add-to-list 'auto-mode-alist '("\\.clj$" . clojure-mode))

(autoload 'highlight-parentheses-mode "highlight parenthesis"
  "Highlights parenthesis in Lisp code." t)
(add-hook 'clojure-mode-hook          (lambda () (highlight-parentheses-mode +1)))

;; (autoload 'paredit-mode "paredit" "Minor mode for pseudo-structurally editing Lisp code." t)
;; (add-hook 'clojure-mode-hook          (lambda () (paredit-mode +1)))
;; (add-hook 'emacs-lisp-mode-hook       (lambda () (paredit-mode +1)))
;; (add-hook 'lisp-mode-hook             (lambda () (paredit-mode +1)))
;; (add-hook 'lisp-interaction-mode-hook (lambda () (paredit-mode +1)))
