(yas/load-directory "~/emacsd/bundles/shell-script/snippets")

(add-to-list 'auto-mode-alist '("\\.sh$" . shell-script-mode))
(add-to-list 'auto-mode-alist '("\\.zsh$" . shell-script-mode))

(add-to-list 'auto-mode-alist '("\\.zshrc$" . shell-script-mode))
(add-to-list 'auto-mode-alist '("\\.zshenv$" . shell-script-mode))


(add-hook 'sh-mode-hook 'flycheck-mode)
