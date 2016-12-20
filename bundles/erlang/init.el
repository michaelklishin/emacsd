;; This is needed for Erlang mode setup
(setq        erlang-root-dir (car (file-expand-wildcards "/usr/local/Cellar/erlang/*")))
(add-to-list 'load-path      (car (file-expand-wildcards "/usr/local/Cellar/erlang/*/lib/erlang/lib/tools-*/emacs")))
(add-to-list 'exec-path      (car (file-expand-wildcards "/usr/local/Cellar/erlang/*/bin")))

(defvar erlang-man-dirs
  '(("Man - Commands" "/lib/erlang/man/man1" t)
    ("Man - Modules" "/lib/erlang/man/man3" t)
    ("Man - Files" "/lib/erlang/man/man4" t)
    ("Man - Applications" "/lib/erlang/man/man6" t)))

(require 'erlang-start)
(require 'erlang)

(setq inferior-erlang-machine-options '("-sname" "emacs"))

;; (add-to-list 'load-path "~/emacsd/bundles/erlang/distel/")
;; (require 'distel)
;; (distel-setup)

;; load bundle snippets
(yas/load-directory "~/emacsd/bundles/erlang/snippets/")


(add-to-list 'auto-mode-alist '("\\.src$" . erlang-mode))
(add-to-list 'auto-mode-alist '("\\.app$" . erlang-mode))
(add-to-list 'auto-mode-alist '("rabbitmq.config$" . erlang-mode))
(add-to-list 'auto-mode-alist '("app.config$" . erlang-mode))

(add-hook 'erlang-mode-hook 'highlight-parentheses-mode)
(add-hook 'erlang-mode-hook (lambda ()
                              (setq indent-tabs-mode nil)))
