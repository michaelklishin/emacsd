;; This is needed for Erlang mode setup
(setq        erlang-root-dir (car (file-expand-wildcards "/usr/local/Cellar/erlang/R1*")))
(add-to-list 'load-path      (car (file-expand-wildcards "/usr/local/Cellar/erlang/R*/lib/erlang/lib/tools-*/emacs")))
(add-to-list 'exec-path      (car (file-expand-wildcards "/usr/local/Cellar/erlang/R*/bin")))

(setq erlang-root-dir (car (file-expand-wildcards "/usr/local/Cellar/erlang/R*")))

(require 'erlang-start)
(require 'erlang)

(setq inferior-erlang-machine-options '("-sname" "emacs"))

;; (add-to-list 'load-path "~/emacsd/bundles/erlang/distel/")
;; (require 'distel)
;; (distel-setup)

;; load bundle snippets
(yas/load-directory "~/emacsd/bundles/erlang/snippets/")


(add-to-list 'auto-mode-alist '("\\.src$" . erlang-mode))
