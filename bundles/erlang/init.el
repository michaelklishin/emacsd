;; This is needed for Erlang mode setup
(setq erlang-root-dir "/opt/local/lib/erlang")
(setq load-path (cons "/opt/local/lib/erlang/lib/tools-2.6.5/emacs" load-path))
(setq exec-path (cons "/opt/local/lib/erlang/bin" exec-path))

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
