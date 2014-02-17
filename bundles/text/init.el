(load "keymap")
(yas/load-directory "~/emacsd/bundles/text/snippets")


(require 'undo-tree)

;;
;;  Clipboard
;;

(setq x-select-enable-clipboard t)
(setq interprogram-paste-function 'x-selection-value)

;; Alias for query-replace-regexp
(defalias 'qrr 'query-replace-regexp)


;;
;;  Indentation
;;

;; display tabs as 2 whitespaces
(setq tab-width 2)
;; by default indentat with spaces
(setq indent-tabs-mode nil)

;;
;;  Region operations
;;
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)

;;
;; Buffer operations
;;

(defun untabify-buffer ()
  (interactive)
  (untabify (point-min) (point-max)))

(defun indent-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))

;; (add-hook 'before-save-hook 'delete-trailing-whitespace t)

(defun wipe-out-all-buffers ()
  "Kills all active buffers"
  (interactive)
  (if (yes-or-no-p "Are you sure you want to kill _all_ buffers?")
      (dolist (i (buffer-list))
        (kill-buffer i))))


;;
;; FFAP and others
;;

(defun recentf-ido-find-file ()
  "Find a recent file using Ido."
  (interactive)
  (let ((file (ido-completing-read "Choose recent file: " recentf-list nil t)))
    (when file
      (find-file file))))
