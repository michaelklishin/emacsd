(require 'elixir-mode)
(require 'elixir-smie)

;; load bundle snippets
(yas/load-directory "~/emacsd/bundles/elixir/snippets/")

(add-hook 'elixir-mode-hook 'highlight-parentheses-mode)
(add-hook 'elixir-mode-hook (lambda ()
                              (setq indent-tabs-mode nil)))
