(global-set-key (kbd "C-h C-s") 'ruby-stdlib-help)
(global-set-key (kbd "C-h C-c") 'ruby-core-help)

(define-key ruby-mode-map (kbd "C-c C-c") 'comment-region)
(define-key ruby-mode-map (kbd "C-c C-u") 'uncomment-region)