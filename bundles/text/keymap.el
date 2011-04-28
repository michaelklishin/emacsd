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
(global-set-key "\C-x\M-k" 'wipe-out-all-buffers)

(global-set-key (kbd "C-S-k") 'delete-region)


;;
;; Option or Command as Meta
;;

(defun mac-use-command-as-meta ()
  (interactive)
  (setq mac-option-key-is-meta nil)
  (setq mac-command-key-is-meta t)
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier nil))

(defun mac-use-option-as-meta ()
  (interactive)
  (setq mac-option-key-is-meta t)
  (setq mac-command-key-is-meta nil)
  (setq mac-command-modifier nil)
  (setq mac-option-modifier 'meta))

(defun mac-flip-meta-key ()
  (interactive)
  (if mac-option-key-is-meta
      (mac-use-command-as-meta)
    (mac-use-option-as-meta)))

(global-set-key "\C-c§" 'mac-flip-meta-key)

;; default
(mac-use-option-as-meta)
