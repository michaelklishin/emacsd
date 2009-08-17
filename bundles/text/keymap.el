;;
;; Completion
;;

;; C-. completes tags
(global-set-key (quote [67108910]) (quote complete-tag))


;;
;;  Grep-ing, find-ing and such
;;

;; Bind rgrep to `\C-c\C-l'
(global-set-key "\C-c\C-l" 'rgrep)
