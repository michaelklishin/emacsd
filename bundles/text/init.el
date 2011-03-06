(load "keymap")
(yas/load-directory "~/emacsd/bundles/text/snippets")


;;
;;  Behavior
;;

;; Use TextMate behavior for braces, quotes and so forth.
;; It is very convenient.
;; (require 'textmate)
;; (textmate-mode)

;;
;;  Clipboard
;;
(setq x-select-enable-clipboard t)
(setq interprogram-paste-function 'x-cut-buffer-or-selection-value)

;; Alias for quer-replase-regexp
(defalias 'qrr 'query-replace-regexp)


;;
;;  Indentation
;;

;; display tabs as 2 whitespaces
(setq tab-width 2)
;; no more tabs indentation
(setq indent-tabs-mode nil)

;;
;;  Region operations
;;
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)

(ns-toggle-fullscreen)

;;
;; Buffer operations
;;

(defun untabify-buffer ()
  (interactive)
  (untabify (point-min) (point-max)))

(defun indent-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))

(add-hook 'before-save-hook 'untabify-buffer t)

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
