(flymake-mode 1)
(require 'csharp-mode)

(add-to-list 'auto-mode-alist '("\\.cs$" . csharp-mode))


(add-hook 'csharp-mode-hook
          (lambda ()
            (setq indent-tabs-mode nil)
            (setq tab-width 8)))
