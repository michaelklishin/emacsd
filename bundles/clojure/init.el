(require 'clojure-mode)

;; load bundle snippets
;; (yas/load-directory "~/emacsd/bundles/clojure/snippets")

(add-to-list 'auto-mode-alist '("\\.clj$" . clojure-mode))