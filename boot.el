;;
;; Important variables
;;

(setq custom-file (concat emacsd-dir "custom-variables.el"))
(load "custom-variables")

;;
;; Initializers
;;

(defun load-initializer (name)
  "Loads initializer with name NAME"
  (load (concat "initializers/" name "_initializer"))
  (message (concat "Loaded " name)))


;;(load-initializer "bytecode_cache")
(load-initializer "path")
(load-initializer "keymap")
(load-initializer "kdb_macros")
(load-initializer "yasnippet")
(load-initializer "modes")
(load-initializer "ui")
(load-initializer "ido")
(load-initializer "bundles")