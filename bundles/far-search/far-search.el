;;; far-search.el --- search incrementally in many buffers at once

;; Copyright (c) 2008 Aemon Cannon, aemoncannon -at- gmail -dot- com

;; Author: Aemon Cannon
;; Keywords: searching, incremental, buffers, matching, lisp, tools

;; This file is part of far-search-mode.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3 of the License, or
;; (at your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.


;;; Commentary:

;; This mode owes much of its structure to regexp-builder, by Detlev Zundel



;;; Basic usage:

;;  (add-to-list 'load-path "~/path/to/far-search/")
;;  (require 'far-search)
;;  M-x far-search



;;; Keyboard shortcuts

;; C-n      move down one result
;; C-p      move up one result
;; C-c 0-9  choose a result by number
;; enter    choose selected result
;; C-c C-q  quit


;;; Code:

(eval-when-compile (require 'cl))

(defcustom far-search-mode-hook nil
  "*Hooks to run on entering far-search-mode."
  :group 'far-search
  :type 'hook)

(defvar far-search-mode nil
  "Enables the far-search minor mode.")

(defvar far-search-buffer-name "*far-search*"
  "Buffer to use for far-search.")

(defvar far-search-target-buffer-name "*far-search-results*"
  "Buffer name for target-buffer.")

(defvar far-search-target-buffer nil
  "Buffer to which the far-search is applied to.")

(defvar far-search-target-window nil
  "Window to which the far-search is applied to.")

(defvar far-search-window-config nil
  "Old window configuration.")

(defvar far-search-mode-string ""
  "String in mode line for additional info.")

(defvar far-search-current-results '()
  "The most recent far-search result list.")

(defvar far-search-current-selected-result '()
  "The currently selected far-search result.")

(defvar far-search-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "\C-c\C-q" 'far-search-quit)
    (define-key map "\C-n" 'far-search-next-match)
    (define-key map "\C-p" 'far-search-prev-match)
    (define-key map [(return)] 'far-search-choose-current-result)
    (mapc (lambda (num)
	    (define-key map (concat "\C-c" (number-to-string num))
	      `(lambda () (interactive) (far-search-choose-by-number ,num))))
	  '(0 1 2 3 4 5 6 7 8 9))
    map)
  "Keymap used by far-search.")


(defstruct far-search-result 
  "A far-search search result.

  * summary
     The full body of text presented in the results list, 
     may contain leading and trailing text, in addition to the match.

  * match-file-name
    The filename of the buffer containing the match

  * match-start
    The point in buffer at which the match started

  * match-end
    The point in buffer at which the match ended

  * match-line
    The line number in buffer match started

  * match-summary-offset
    Within summary, the offset at which the match begins

  * match-length
    The length of the match

  * summary-start
    The offset at which summary begins in the results buffer.
  "
  (summary nil) 
  (match-file-name nil)
  (match-start nil)
  (match-end nil)
  (match-line nil)
  (match-summary-offset nil)
  (match-length nil)
  (summary-start 0)
  )

(defface far-search-result-file-name-face
  '((t (:foreground "slate gray")))
  "Used for displaying the source file-name of a match."
  :group 'far-search
  )

(defface far-search-result-seperator-lines-face
  '((t (:foreground "slate gray")))
  "Used for displaying the seperation lines between search results."
  :group 'far-search
  )

(defface far-search-result-numbers-face
  '((t (:foreground "orange")))
  "Used for displaying the quick number links for results."
  :group 'far-search
  )

(defface far-search-result-match-face
  '((t (:foreground "light green")))
  "Used for displaying the matched substring."
  :group 'far-search
  )

(defun far-search ()
  "The main entrypoint for far-search-mode.
   Initiate an incremental search of all live buffers."
  (interactive)
  (if (and (string= (buffer-name) far-search-buffer-name)
	   (memq major-mode '(far-search-mode)))
      (message "Already in far-search buffer")

    (setq far-search-target-buffer (switch-to-buffer (get-buffer-create far-search-target-buffer-name)))
    (setq far-search-target-window (selected-window))
    (setq far-search-window-config (current-window-configuration))

    (select-window (split-window (selected-window) (- (window-height) 4)))
    (switch-to-buffer (get-buffer-create far-search-buffer-name))
    (far-search-initialize-buffer)))


(defun far-search-mode ()
  "Major mode for incrementally seaching through all open buffers."
  (interactive)
  (kill-all-local-variables)
  (setq major-mode 'far-search-mode
        mode-name "far-search-mode")
  (use-local-map far-search-mode-map)
  (far-search-mode-common)
  (run-mode-hooks 'far-search-mode-hook))


(defun far-search-quit ()
  "Quit the far-search mode."
  (interactive)
  (kill-buffer far-search-buffer-name)
  (set-window-configuration far-search-window-config))


(defun far-search-choose-current-result ()
  "Jump to the target of the currently selected far-search-result."
  (interactive)
  (if (and (far-search-result-p far-search-current-selected-result)
	   (get-buffer far-search-buffer-name))
      (progn
	(switch-to-buffer far-search-buffer-name)
	(kill-buffer-and-window)
	(let* ((r far-search-current-selected-result)
	       (file-name (far-search-result-match-file-name r))
	       (offset (far-search-result-match-start r)))
	  (find-file file-name)
	  (goto-char offset)))))


(defun far-search-choose-by-number (num)
  "Select result by number."
  (if (and far-search-current-results
	   (< num (length far-search-current-results)))
      (let ((next (nth num far-search-current-results)))
	(setq far-search-current-selected-result next)
	(far-search-update-result-selection)
	(far-search-choose-current-result)
	)))


(defun far-search-next-match ()
  "Go to next match in the far-search target window."
  (interactive)
  (if (and far-search-current-results
	   far-search-current-selected-result)
      (let* ((i (position far-search-current-selected-result far-search-current-results))
	     (len (length far-search-current-results))
	     (next (if (< (+ i 1) len) 
		       (nth (+ i 1) far-search-current-results)
		     (nth 0 far-search-current-results))))
	(setq far-search-current-selected-result next)
	(far-search-update-result-selection)
	)))


(defun far-search-prev-match ()
  "Go to previous match in the far-search target window."
  (interactive)
  (if (and far-search-current-results
	   far-search-current-selected-result)
      (let* ((i (position far-search-current-selected-result far-search-current-results))
	     (len (length far-search-current-results))
	     (next (if (> i 0)
		       (nth (- i 1) far-search-current-results)
		     (nth (- len 1) far-search-current-results))))
	(setq far-search-current-selected-result next)
	(far-search-update-result-selection)
	)))


;;
;; Non-interactive functions below
;;


(defun far-search-mode-common ()
  "Setup functions common to function `far-search-mode'."
  (setq	far-search-mode-string  ""
	far-search-mode-valid-string ""
	mode-line-buffer-identification
	'(25 . ("%b" far-search-mode-string far-search-valid-string)))
  (far-search-update-modestring)
  (make-local-variable 'after-change-functions)
  (add-hook 'after-change-functions
	    'far-search-auto-update)
  (make-local-variable 'far-search-kill-buffer)
  (add-hook 'kill-buffer-hook 'far-search-kill-buffer)
  )


(defun far-search-initialize-buffer ()
  "Initialize the current buffer as a far-search buffer."
  (erase-buffer)
  (far-search-mode)
  )


(defun far-search-update-result-selection ()
  "Move cursor to current result selection in target buffer."
  (if (far-search-result-p far-search-current-selected-result)
      (with-current-buffer far-search-target-buffer
	(let ((target-point (far-search-result-summary-start 
			     far-search-current-selected-result)))
	  (set-window-point far-search-target-window target-point)
	  ))))


(defun far-search-update-regexp ()
  "Update the regexp for the target buffer."
  (let* ((re-src (far-search-read-regexp)))
    (with-current-buffer far-search-target-buffer
      (if re-src
	  (setq far-search-regexp re-src))
      far-search-regexp
      )))

(defun far-search-do-update (&optional subexp)
  "Update matches in the far-search target window."
  (far-search-assert-buffer-in-window)
  (far-search-update-regexp))

(defun far-search-auto-update (beg end lenold &optional force)
  "Called from `after-update-functions' to update the display.
BEG, END and LENOLD are passed in from the hook.
An actual update is only done if the regexp has changed or if the
optional fourth argument FORCE is non-nil."
  (progn
    (if (or (far-search-update-regexp) force)
	(progn
	  (far-search-assert-buffer-in-window)
	  (far-search-do-update)
	  (far-search-update-target-buffer)
	  ))
    (force-mode-line-update)))

(defun far-search-assert-buffer-in-window ()
  "Assert that `far-search-target-buffer' is displayed in `far-search-target-window'."
  (if (not (eq far-search-target-buffer (window-buffer far-search-target-window)))
      (set-window-buffer far-search-target-window far-search-target-buffer)))

(defun far-search-update-modestring ()
  "Update the variable `far-search-mode-string' displayed in the mode line."
  (force-mode-line-update))

(defun far-search-kill-buffer ()
  "When the far-search buffer is killed, kill the target buffer."
  (remove-hook 'kill-buffer-hook 'far-search-kill-buffer)
  (if (buffer-live-p far-search-target-buffer)
      (kill-buffer far-search-target-buffer)))

(defun far-search-read-regexp ()
  "Read current RE."
  (buffer-string))

(defun far-search-buffers-to-search ()
  "Return the list of buffers that are suitable for searching."
  (let ((all-buffers (buffer-list)))
    (remove-if
     (lambda (b)
       (let ((b-name (buffer-name b)))
	 (or (null (buffer-file-name b))
	     (equal b-name far-search-target-buffer-name)
	     (equal b-name far-search-buffer-name)
	     (equal b-name "*Messages*"))))
     all-buffers)))


(defun far-search-update-target-buffer ()
  "This is where the magic happens. Update the result list."
  (save-excursion
    (set-buffer far-search-target-buffer)
    (setq buffer-read-only nil)
    (goto-char (point-min))
    (erase-buffer)
    (setq far-search-current-results '())

    (let ((buffers (far-search-buffers-to-search)))

      (mapc 
       (lambda (b)
	 (with-current-buffer b
	   (goto-char (point-min))
	   (let ((search-result (re-search-forward far-search-regexp nil t)))
	     (if search-result
		 (let ((text (buffer-substring-no-properties 
			      (point-at-bol)
			      (min (point-max)
				   (+ (match-end 0) 20))
			      )))
		   (push (make-far-search-result 
			  :summary text
			  :match-file-name (buffer-file-name)
			  :match-start (match-beginning 0)
			  :match-end (match-end 0)
			  :match-line (line-number-at-pos (match-beginning 0))
			  :match-summary-offset (- (match-beginning 0) (point-at-bol))
			  :match-length (length (match-string 0))) far-search-current-results)
		   )))
	   )) buffers)

      (if far-search-current-results 
	  (setq far-search-current-selected-result (first far-search-current-results)))

      (let ((counter 0))
	(mapc
	 (lambda (r)
	   ;; Save this for later use, for next/prev actions
	   (setf (far-search-result-summary-start r) (point))

	   ;; Insert item numbers
	   (if (< counter 10)
	       (let ((p (point)))
		 (insert (format "%s) " counter))
		 (add-text-properties p (point) '(comment nil face far-search-result-numbers-face))))

	   (let ((p (point)))
	     ;; Insert the actual text, highlighting the matched substring
	     (insert (format "%s....  \n" (far-search-result-summary r))) 
	     (add-text-properties (+ p (far-search-result-match-summary-offset r))
				  (+ p (far-search-result-match-summary-offset r) (far-search-result-match-length r)) 
				  '(comment nil face far-search-result-match-face)))

	   ;; Insert metadata, filename, line number
	   (let ((p (point)))
	     (insert (format "[%s : %s]" 
			     (far-search-result-match-file-name r) 
			     (far-search-result-match-line r)))
	     (add-text-properties p (point) '(comment nil face far-search-result-file-name-face)))

	   ;; Insert a seperator line
	   (let ((p (point)))	   
	     (insert (format "\n\n%s\n\n" (make-string (window-width) ?-)))
	     (add-text-properties p (point) '(comment nil face far-search-result-seperator-lines-face)))

	   (incf counter)
	   )
	 far-search-current-results))

      (setq buffer-read-only t)
      )))



(provide 'far-search)



