(load-library "haskell-site-file")

(require 'haskell-mode)
(add-to-list 'auto-mode-alist '("\\.hs$" . haskell-mode))

(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)

(yas/load-directory "~/emacsd/bundles/haskell/snippets")

(define-key haskell-mode-map "\C-ch" 'haskell-hoogle)
;(setq haskell-hoogle-command "hoogle")