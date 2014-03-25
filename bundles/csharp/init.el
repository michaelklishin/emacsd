(flymake-mode 1)
(require 'csharp-mode)

(add-to-list 'auto-mode-alist '("\\.cs$" . csharp-mode))

(add-hook 'csharp-mode-hook
          (lambda ()
            (setq c-basic-offset 4)
            ;; no extra indentation before a substatement (e.g. the
            ;; opening brace in the consequent block of an if
            ;; statement)
            (c-set-offset 'substatement-open 0)
            (setq indent-tabs-mode nil)
            (highlight-parentheses-mode)))
