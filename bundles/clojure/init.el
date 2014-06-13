;; a workaround for a possible Emacs 23.1 bug. MK.
(setq warning-suppress-types nil)

;; for Leiningen to be found
(add-to-list 'exec-path "~/bin/")

(require 'clojure-mode)
(require 'clojure-test-mode)

(add-hook 'clojure-mode-hook (lambda ()
                               (def compile-command "lein compile")))
(add-hook 'cider-mode-hook (lambda ()
                             (def compile-command "lein compile")))

;; load bundle snippets
(yas/load-directory "~/emacsd/bundles/clojure/snippets")

(add-to-list 'auto-mode-alist '("\\.clj$" . clojure-mode))
(add-to-list 'auto-mode-alist '("\\.cljs$" . clojure-mode))
(add-to-list 'auto-mode-alist '("\\.clx$" . clojure-mode))
(add-to-list 'auto-mode-alist '("\\.edn$" . clojure-mode))
(add-to-list 'auto-mode-alist '("config\\.clj$" . clojure-mode))
(add-hook 'clojure-mode-hook   (lambda ()
                                 (highlight-parentheses-mode +1)
                                 (setq buffer-save-without-query t)))
(add-hook 'clojure-mode-hook 'untabify-buffer t)


;;
;; CIDER
;;

;; (unless (package-installed-p 'cider)
;;   (package-refresh-contents)
;;   (package-install 'cider))

(require 'cider)


;;
;; hl-p
;;

(require 'highlight-parentheses)

(autoload 'highlight-parentheses-mode "highlight parenthesis"
  "Highlights parenthesis in Lisp code." t)
(highlight-parentheses-mode)


;;
;; Paredit
;;

(require 'paredit)
(paredit-mode)

(autoload 'paredit-mode "paredit" "Minor mode for pseudo-structurally editing Lisp code." t)
(add-hook 'clojure-mode-hook          (lambda () (paredit-mode +1)))
