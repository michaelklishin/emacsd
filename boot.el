(setq custom-file (concat emacsd-dir "custom-variables.el"))

(add-to-list 'load-path emacsd-dir)

;;
;; Initializers
;;

(defun load-initializer (name)
  "Loads initializer with name NAME"
  (load (concat "initializers/" name "_initializer"))
  (message (concat "Loaded " name)))

;; These MUST be loaded first if you want to use
;; byte-code-cache.
;;
;; However, idea of precompilation seem to
;; work better.
;; 
(defvar byte-compile-warnings t)
(defvar byte-compile-verbose t)
;; (load-initializer "bytecode_cache")

(load "custom-variables")

(load-initializer "elisp")
(load-initializer "path")
(load-initializer "kbd")
(load-initializer "ido")
(load-initializer "yasnippet")
(load-initializer "package")
(load-initializer "bundles")
(load-initializer "scratches")
(load-initializer "ui")
(load-initializer "server")
