(require 'tuareg)

;; TODO: if /usr/local/Cellar exists, set ocaml
;; tuareg-library-path to "/usr/local/Cellar/objective-caml/lib/ocaml"


(add-to-list 'auto-mode-alist '("\\.c?ml" . tuareg-mode))