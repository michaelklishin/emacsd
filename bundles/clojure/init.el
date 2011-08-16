(require 'clojure-mode)
(require 'clojure-test-mode)

(require 'paredit)
(require 'highlight-parentheses)

;; load bundle snippets
;; (yas/load-directory "~/emacsd/bundles/clojure/snippets")

(highlight-parentheses-mode)
(paredit-mode)

(add-to-list 'auto-mode-alist '("\\.clj$" . clojure-mode))
