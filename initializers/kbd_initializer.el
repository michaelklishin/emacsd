;;; Text manipulation

(global-set-key (kbd "C-M-h") 'backward-kill-word)
(global-set-key (kbd "C-c l") (lambda () (interactive) (insert "lambda")))
(global-set-key (kbd "C-x \\") 'align-regexp)
(global-set-key (kbd "M-/") 'hippie-expand)
(global-set-key (kbd "C-c n") (lambda () (interactive)
                                (delete-trailing-whitespace)
                                (untabify-buffer)))

(global-set-key (kbd "C-x :") 'ispell-buffer)
(global-set-key (kbd "C-x ;") 'ispell-region)
(global-set-key (kbd "M-DEL") 'backward-kill-word)

(global-set-key (kbd "C-c C-p b") 'gist-buffer-private)
(global-set-key (kbd "C-c C-p r") 'gist-region-private)
(global-set-key (kbd "C-c C-p f") 'gist-fetch)

;;; Text indentation

(global-set-key (kbd "C-M-\\") 'indent-buffer)

;;; Navigation

(global-set-key (kbd "M-g") 'goto-line)
(global-set-key (kbd "C-x C-r") 'jump-to-register)
(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "C-r") 'isearch-backward-regexp)
(global-set-key (kbd "C-M-s") 'isearch-forward)
(global-set-key (kbd "C-M-r") 'isearch-backward)

(global-set-key (kbd "C-x C-i") 'imenu)
(global-set-key (kbd "C-c C-o") 'browse-url-at-point)


;;; Buffers, files and directories management

(defun switch-to-other-buffer ()
  (interactive)
  (switch-to-buffer (other-buffer)))
(global-set-key (kbd "C-'") 'switch-to-other-buffer)
(global-set-key (kbd "C-|") 'switch-to-other-buffer)

(global-set-key (kbd "M-t") 'far-search)

(global-set-key (kbd "C-x C-f") 'ido-find-file)
(global-set-key (kbd "C-x M-f") 'ido-find-file-other-window)
(global-set-key (kbd "C-x d") 'ido-dired)
(global-set-key (kbd "C-c r") 'revert-buffer)
(global-set-key (kbd "C-c C-[") 'find-file-recursively)
;;(global-set-key (kbd "C-c C-]") 'find-file-in-project)
(global-set-key (kbd "C-x C-p") 'find-file-at-point)
(global-set-key (kbd "C-M-k") 'bury-buffer)
;; Rebind `C-x C-b' for `ibuffer'
(global-set-key (kbd "C-x C-b") 'ibuffer)
(global-set-key (kbd "C-c d c") 'make-directory)

(global-set-key (kbd "C-c g l") 'lgrep)
(global-set-key (kbd "C-c g r") 'rgrep)
(global-set-key (kbd "C-c g d") 'find-grep-dired)
(global-set-key (kbd "C-c g f") 'find-grep)
(global-set-key (kbd "C-c g g") 'grep)

(global-set-key (kbd "C-h g") 'man)

;;; Window management

(global-set-key (kbd "C-x O") (lambda () (interactive) (other-window -1)))
(global-set-key (kbd "C-x C-o") (lambda () (interactive) (other-window 2)))
(global-set-key (kbd "C-x .") (lambda () (interactive) (enlarge-window 1 t)))
(global-set-key (kbd "C-x ,") (lambda () (interactive) (shrink-window 1 t)))

(global-set-key (kbd "C-x M-k") (lambda () (interactive) (kill-buffer (current-buffer)) (delete-window)))


;; Compilation

(global-set-key (kbd "C-c C-r") 'compile)
(global-set-key (kbd "M-<f9>") 'compile)


;; Version control

(global-set-key (kbd "C-x C-g") 'magit-status)


;; Web

(global-set-key (kbd "C-x w") 'browse-url-default-macosx-browser)
(global-set-key (kbd "C-c o") 'google-region)


;;; Utility

(global-set-key (kbd "C-c p") (lambda () (interactive) (message "%s" (point))))
(global-set-key (kbd "C-c b") 'bookmark-jump)
(global-set-key (kbd "C-c B") 'bookmark-set)
(global-set-key [f1] 'menu-bar-mode)
(define-key read-expression-map (kbd "TAB") #'lisp-complete-symbol)
(global-set-key (kbd "C-h a") 'apropos)
;;(global-set-key (kbd "C-c a") (lambda () (interactive) (switch-or-start 'autotest "*autotest*")))
;;(global-set-key (kbd "C-c j") (lambda () (interactive) (switch-or-start 'jabber-connect "*-jabber-*")))
;;(global-set-key (kbd "C-c J") 'jabber-send-presence)
;;(global-set-key (kbd "C-c e") 'elunit)
;;(global-set-key (kbd "C-c x") 'elunit-explain-problem)

(define-key isearch-mode-map (kbd "C-o") ;; occur easily inside isearch
  (lambda ()
    (interactive)
    (let ((case-fold-search isearch-case-fold-search))
      (occur (if isearch-regexp isearch-string (regexp-quote isearch-string))))))

(provide 'my-bindings)
