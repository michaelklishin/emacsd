(add-to-list 'load-path "~/emacsd/bundles/slime/swank-clojure")
(add-to-list 'load-path "~/emacsd/bundles/slime/slime")

(require 'clojure-mode)
(require 'swank-clojure-autoload)

(swank-clojure-config
 (setq swank-clojure-jar-path "~/lib/lang/clojure.jar")
 (setq swank-clojure-extra-classpaths
       (list "~/lib/lang/clojure-contrib.jar")))

(eval-after-load "slime"
  '(progn (slime-setup '(slime-repl))))

(setq inferior-lisp-program "~java -jar /Users/antares/lib/lang/clojure.jar")

(require 'slime)
(slime-setup)