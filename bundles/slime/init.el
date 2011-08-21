(add-to-list 'load-path "~/emacsd/bundles/slime/swank-clojure")
(add-to-list 'load-path "~/emacsd/bundles/slime/slime")

(eval-after-load "slime"
  '(progn (slime-setup '(slime-repl))))

(setq inferior-lisp-program "/usr/local/bin/clj")

(setq swank-clojure-jar-path "~/Tools/clojure-snapshot/clojure.jar")
(require 'swank-clojure-autoload)



(require 'slime)
(slime-setup)
