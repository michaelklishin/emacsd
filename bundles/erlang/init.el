;; This is needed for Erlang mode setup
(setq erlang-root-dir "/usr/local/lib/erlang")
(setq load-path (cons "/usr/local/lib/erlang/lib/tools-2.5.1/emacs" load-path))
(setq exec-path (cons "/usr/local/lib/erlang/bin" exec-path))

(load "erlang-start")

;; This is needed for Distel setup
(let ((distel-dir "~/emacsd/bundles/erlang/distel"))
  (unless (member distel-dir load-path)
    ;; Add distel-dir to the end of load-path
    (setq load-path (append load-path (list distel-dir)))))


(require 'erlang-start)
(setq inferior-erlang-machine-options '("-sname" "emacs")


;; (load "distel/distel")
;; (require 'distel)
;; (distel-setup)

;; load bundle snippets
(yas/load-directory "~/emacsd/bundles/erlang/snippets/")
