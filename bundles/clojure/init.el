(require 'clojure-mode)

;; load bundle snippets
;; (yas/load-directory "~/emacsd/bundles/clojure/snippets")

(add-to-list 'auto-mode-alist '("\\.clj$" . clojure-mode))

;; (setq hl-paren-colors
;;       '(;"#8f8f8f" ; this comes from Zenburn
;;                                         ; and I guess I'll try to make the far-outer parens look like this
;;         "orange1" "yellow1" "greenyellow" "green1"
;;         "springgreen1" "cyan1" "slateblue1" "magenta1" "purple"))

;; (define-globalized-minor-mode global-highlight-parentheses-mode
;;   highlight-parentheses-mode
;;   (lambda ()
;;     (highlight-parentheses-mode t)))
;; (global-highlight-parentheses-mode t)