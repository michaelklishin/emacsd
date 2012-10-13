;;
;; bundles
;;

(defun elbundle/path-of (bundle-name)
  (concat emacsd-dir "bundles/" bundle-name "/"))

(defun elbundle/load-elbundle (bundle-name)
  (let* ((bundle-dir (elbundle/path-of bundle-name))
         (bundle-init-file (concat bundle-dir "init"))
         (bundle-keymap-file (concat bundle-dir "keymap"))
         (bundle-grammar-file (concat bundle-dir "grammar")))
    ;; let* body
    ;; (message "Adding %s to load-path..." bundle-dir)
    (add-to-list 'load-path bundle-dir)
    (load bundle-init-file)
    ;; don't break if keymap or grammar are not found
    (load bundle-keymap-file t)
    (load bundle-grammar-file t)))


(add-to-list 'load-path "bundles")

(if (emacs23?)
    (elbundle/load-elbundle "package")
    (require 'package))

(elbundle/load-elbundle "text")
(elbundle/load-elbundle "textile")
(elbundle/load-elbundle "markdown")
(elbundle/load-elbundle "git")

(elbundle/load-elbundle "slime")
(elbundle/load-elbundle "clojure")


(elbundle/load-elbundle "ruby")

(elbundle/load-elbundle "emacs-lisp")
(elbundle/load-elbundle "emacs")

(elbundle/load-elbundle "org")

(elbundle/load-elbundle "linkify")
(elbundle/load-elbundle "hg")

(elbundle/load-elbundle "rspec")
(elbundle/load-elbundle "cucumber")
(elbundle/load-elbundle "rake")

(elbundle/load-elbundle "c")
(elbundle/load-elbundle "cpp")
(elbundle/load-elbundle "golang")
(elbundle/load-elbundle "sql")
(elbundle/load-elbundle "erlang")
(elbundle/load-elbundle "python")
(elbundle/load-elbundle "scala")

;; (elbundle/load-elbundle "ocaml")
(elbundle/load-elbundle "joxa")
(elbundle/load-elbundle "haskell")
(elbundle/load-elbundle "fsharp")
(elbundle/load-elbundle "perl")
(elbundle/load-elbundle "javascript")
(elbundle/load-elbundle "shell-script")

(elbundle/load-elbundle "yaml")
(elbundle/load-elbundle "haml")
(elbundle/load-elbundle "xml")
(elbundle/load-elbundle "mustache")

(elbundle/load-elbundle "far-search")
(elbundle/load-elbundle "find-recursive")
(elbundle/load-elbundle "findr")

(elbundle/load-elbundle "gist")
(elbundle/load-elbundle "webtools")

(elbundle/load-elbundle "erlang")
(elbundle/load-elbundle "ack")
