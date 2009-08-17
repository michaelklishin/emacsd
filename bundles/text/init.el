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

;;
;; Buffer operations
;;

(defun untabify-buffer ()
  (interactive)
  (untabify (point-min) (point-max)))

(defun indent-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))

;;
;; FFAP and others
;;

(defun recentf-ido-find-file ()
  "Find a recent file using Ido."
  (interactive)
  (let ((file (ido-completing-read "Choose recent file: " recentf-list nil t)))
    (when file
      (find-file file))))
