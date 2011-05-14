;; This is needed for Erlang mode setup
(setq erlang-root-dir "/usr/local/Cellar/erlang/R14B02/")
(setq load-path (cons "/usr/local/Cellar/erlang/R14B02/lib/erlang/lib/tools-2.6.6.3/emacs/" load-path))
(setq exec-path (cons "/usr/local/Cellar/erlang/R14B02/bin/" exec-path))

(setq erlang-root-dir "/usr/local/Cellar/erlang/R14B02")

(require 'erlang-start)
(require 'erlang)

;; This is needed for Distel setup
;; (let ((distel-dir "~/Tools/emacsd.git/bundles/erlang/distel"))
;;   (unless (member distel-dir load-path)
;;     ;; Add distel-dir to the end of load-path
;;     (setq load-path (append load-path (list distel-dir)))))


(setq inferior-erlang-machine-options '("-sname" "emacs"))


;; (load "distel/distel")
;; (require 'distel)
;; (distel-setup)

;; load bundle snippets
;; (yas/load-directory "~/Tools/emacsd.git/bundles/erlang/snippets/")
