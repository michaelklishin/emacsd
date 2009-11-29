(load-library "haskell-site-file")

(require 'haskell-mode)
(add-to-list 'auto-mode-alist '("\\.hs$" . haskell-mode))

(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)

(yas/load-directory "~/emacsd/bundles/haskell/snippets")

(define-key haskell-mode-map "\C-ch" 'haskell-hoogle)
;(setq haskell-hoogle-command "hoogle")

(setq browse-url-browser-function 'browse-url-safari)
(defun browse-url-safari (url &optional new-window)
 "Open URL in a new Safari window."
 (interactive (browse-url-interactive-arg "URL: "))
 (unless
     (string= ""
              (shell-command-to-string
               (concat "open -a Safari " url)))
   (message "Starting Safari...")
   (start-process (concat " open -a Safari " url) nil "open -a Safari " url)
   (message "Starting Safari... done")))
