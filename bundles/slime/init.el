(add-to-list 'load-path "~/emacsd/bundles/slime/swank-clojure")
(add-to-list 'load-path "~/emacsd/bundles/slime/slime")

(require 'clojure-mode)
(require 'swank-clojure-autoload)

(swank-clojure-config
 (setq swank-clojure-jar-path "/usr/local/Cellar/clojure/1.2.1/clojure.jar"))

(eval-after-load "slime"
  '(progn (slime-setup '(slime-repl))))

(setq inferior-lisp-program "/usr/local/bin/clj")

(require 'slime)
(slime-setup)


;; load bundle snippets
(yas/load-directory "~/emacsd/bundles/clojure/snippets")