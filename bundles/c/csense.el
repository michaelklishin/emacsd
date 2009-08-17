;;; csense.el --- Coding assistant front-end

;; Copyright (C) 2007  

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; Generic Code Sense frontend for assistance during coding.
;;
;; Install it by requiring one of the language-specific frontends.
;;
;; F1 shows help for the symbol at point.
;;
;; C-F1 goes to the definition (using the etag ring, so you can use
;; M-* to jump back)
;;
;; C-. completes the symbol at point
;;

;;  Tested on Emacs 22.

;;; Code:

(require 'etags)
(require 'cl)

;;; User configuration

(defvar csense-max-tooltip-line-length 70
  "Maximum length of lines in tooltips.")

(defvar csense-completion-tooltip-delay 0.5
  "Idle delay in seconds before showing tooltip help for the
  currently selected completion.")

;; this should be a keymap, but I'm lazy
(defvar csense-bindings
  `((,(kbd "<f1>") . csense-show-help)
    (,(kbd "C-<f1>") . csense-go-to-definition)
    (,(kbd "C-.") . csense-complete))
  "Keybindings for commond Code Sense tasks.")


(defvar csense-completion-bindings
  `((,(kbd "<down>") . csense-completion-next-line)
    (,(kbd "<up>") . csense-completion-previous-line)
    (,(kbd "<next>") . csense-completion-next-page)
    (,(kbd "<prior>") . csense-completion-previous-page)
    (,(kbd "<ESC>") . csense-completion-cancel)
    (,(kbd "<RET>") . csense-completion-insert-selection))
  "Keybindings for code completion.")


(defvar csense-multi-tooltip-bindings
  `((,(kbd "<down>") . csense-multi-tooltip-next)
    (,(kbd "<up>") . csense-multi-tooltip-previous))
  "Keybindings for controlling multi tooltips.")


(defface csense-multiple-tooltip-indicator-face
  '((t (:background "lawn green")))
  "Face for indicator field which shows the number of current
  tooltip in case of multiple results.")

(defvar csense-tooltip-current-line-color "honeydew2"
  "Color of the current line in tooltips for which information is shown.")


(defvar csense-information-function nil
  "Function called with no arguments to get available information at point.

The function should return a list of plists with information
available at point. If the returned list has more than one plists
then the information is shown in a multi tooltip where the user
can switch between tooltips.

If there is no help available the function should return nil.

The plist should have the following porperties:

  - doc

    Formated textual documentation which is shown in the tooltip.

  - url

    URL to be opened in web browser when the user wants to go to
    the definition. Not mandatory. See property `file'.

  - file

    Path of the source file to be opened when the user wants to
    jump to the definition. Not mandatory. See property `url'.

  - pos

    Position of the definition in the source file indicated by
    `file'. Must be given if `file' is given.
")

(make-variable-buffer-local 'csense-information-function)


(defvar csense-completion-function nil
  "Function called with no arguments to get completions for the symbol at point.

The function should return a list of plists with information
about completions available at point.

The plist should have the following properties:

   - name

     Name of the item shown in the completion window.

   - doc

     Documentation of the item shown in a tooltip when the item
     is selected and the user hesitates.
")

(make-variable-buffer-local 'csense-completion-function)

(defvar csense-completion-editing-commands
  '(self-insert-command
    c-electric-backspace)
  "These commands can be used during completion to edit the pattern.")

;;;----------------------------------------------------------------------------


(defvar csense-completion-candidates nil
  "List of candidates for the current completion.")

(defvar csense-completion-symbol-beginning-position nil
  "Beginning position of the symbol currently being completed.")

(defvar csense-completion-frame nil
  "The frame showing the completion list.")

(defvar csense-completions-buffer "*csense-completions*"
  "Buffer holding the completions.")

(defvar csense-selection-overlay nil
  "Overlay used to highligh the current selection.")

(defvar csense-completion-just-started nil
  "Used to prevent the post command hook to kick in when the
  completion list is shown for the first time.")

(defvar csense-saved-keys nil
  "The original keybindings are saved here when CSense rebinds
  some keys temporarily.")

(defvar csense-debug nil
  "Whether to show debug messages.")


(defun csense-setup ()
  "Setup Code Sense for the current buffer."
  (interactive)
  (dolist (binding csense-bindings)
    (local-set-key (car binding) (cdr binding))))


(defun csense-show-help ()
  "Do something clever at point."
  (interactive)
  (let* ((infos (funcall csense-information-function)))
    (if infos
        (let ((docs (mapcar (lambda (info)
                              (plist-get info 'doc))
                            infos)))                             
          (if (> (length docs) 1)
              (csense-show-multi-tooltip docs)
            (csense-show-tooltip-at-pos (car docs))))
         
      (message "No help available."))))


(defun csense-go-to-definition ()
  "Go to definition of symbol at point."
  (interactive)
  (let* ((info (car (funcall csense-information-function))))
    (if info
        (if (plist-get info 'file)
            (progn (ring-insert find-tag-marker-ring (point-marker))
                   (switch-to-buffer (find-file (plist-get info 'file)))
                   (goto-char (plist-get info 'pos)))

          (if (plist-get info 'url)
              (browse-url (plist-get info 'url))

            (assert nil nil "Assertion failure: No file or url found.")))

      (message "There is nothing at point."))))


(defun csense-complete ()
  "Do completion at point."
  (interactive)
  (save-excursion
    (skip-syntax-backward "w_")
    (setq csense-completion-symbol-beginning-position (point))
    (setq csense-completion-candidates
          (sort (funcall csense-completion-function)
                (lambda (first second)
                  (string< (downcase (plist-get first 'name))
                           (downcase (plist-get second 'name)))))))

  ;; collapse items with the same name into a single item
  ;; the list must already be sorted here
  (let (collapsed)
    (setq csense-completion-candidates
          (nreverse                     ; keep the sort order
           (reduce (lambda (result item)
                     (if (equal (plist-get (car result) 'name)
                                (plist-get item 'name))
                         ;; I tried to do it within the reduce itself,
                         ;; but probably due to the modifications of
                         ;; the currently reduced list it got into an
                         ;; infinite loop or something
                         (let ((count (assoc (plist-get item 'name) collapsed)))
                           (if count
                               (setcdr count (1+ (cdr count)))
                             (push (cons (plist-get item 'name) 1)
                                   collapsed))
                           result)
                       (cons item result)))
                   `(() ,@csense-completion-candidates))))

    ;; add count for collapsed items
    (setq csense-completion-candidates
          (mapcar (lambda (candidate)
                    (let ((count (assoc-default (plist-get candidate 'name)
                                                collapsed)))
                      (if (and count
                               (plist-get candidate 'doc))
                          (plist-put candidate 
                                     'doc
                                     (concat (propertize
                                              (concat " + " 
                                                      (int-to-string count)
                                                      " variant"
                                                      (if (> count 1) "s")
                                                      " ")
                                              'face
                                              'csense-multiple-tooltip-indicator-face)
                                             "\n" (plist-get candidate 'doc)))
                        candidate)))
                  csense-completion-candidates)))

  (if csense-completion-candidates
      (csense-show-completion-for-point)
    (message "No completions for symbol before point.")))


(defun csense-show-completion-for-point ()
  (let* ((maxlinelen 
          (apply 'max (mapcar (lambda (candidate)
                                (length (plist-get candidate 'name)))
                              csense-completion-candidates)))
         (width (max (+ maxlinelen 2) ; padding
                     15))
         (height (max (min (length csense-completion-candidates) 20) 5))
         (pixel-width (* width (frame-char-width)))
         (pixel-height (* 
                        ;; let's say the titlebar has the same
                        ;; height as a text line
                        (1+ height)
                        (frame-char-height)))
         (position (csense-calculate-popup-position pixel-width
                                                    pixel-height))
         (frame-params (list (cons 'top             (cdr position))
                             (cons 'left            (car position))
                             (cons 'width           width)
                             (cons 'height          height)
                             (cons 'minibuffer      nil)
                             (cons 'menu-bar-lines  0)
                             (cons 'tool-bar-lines  0)
                             (cons 'title           "Completions")))
         (orig-frame (selected-frame)))

    (csense-update-completion-buffer
     (if (eq (selected-frame) csense-completion-frame)
         ""
       (csense-completion-get-filter)))

    (if (with-current-buffer csense-completions-buffer
          (save-excursion
            (goto-char (point-min))
            (and (not (eobp))
                 (progn (forward-line 1)
                        (eobp)))))
        (progn
          (csense-completion-insert-selection)
          (csense-completion-cleanup)
          (message "Unique completion."))
      
      (if (not csense-completion-frame)
          (setq csense-completion-frame (make-frame frame-params))

        (modify-frame-parameters csense-completion-frame frame-params)
        (make-frame-visible csense-completion-frame))

      (select-frame csense-completion-frame)
      (switch-to-buffer csense-completions-buffer)
      (setq cursor-type nil)
      (setq mode-line-format nil)
      (set-window-fringes nil 0 0)
      (if csense-selection-overlay
          ;; make sure the overlay belongs to the completion buffer if
          ;; it's newly created
          (move-overlay csense-selection-overlay (point-min) (point-min))

        (setq csense-selection-overlay 
              (make-overlay (point-min) (point-min)))
        (overlay-put csense-selection-overlay 'face 'highlight))
 
      (redirect-frame-focus csense-completion-frame orig-frame)
      (select-frame orig-frame)

      (add-hook 'pre-command-hook 'csense-completion-pre-command)
      (add-hook 'post-command-hook 'csense-completion-post-command)

      (setq csense-saved-keys nil)
      (dolist (binding csense-completion-bindings)
        (let ((key (car binding))
              (command (cdr binding)))
          (push (cons key (lookup-key (current-local-map) key))
                csense-saved-keys)
          (define-key (current-local-map) key command)))

      (csense-completion-previous-line)

      (setq csense-completion-just-started t))))


(defun csense-completion-pre-command ()
  "Guard function which terminates the completion if any other
command is used than the allowed ones."
  (unless (or (eq this-command 'handle-switch-frame)
              (memq this-command csense-completion-editing-commands)
              (get this-command 'csense-allowed-during-completion))
   (csense-completion-cleanup)))


(defun csense-completion-post-command ()
  "Guard function which updates the completion list after typing,
or terminates the completion if any other command is used than
the allowed ones."
  (if csense-completion-just-started
      (setq csense-completion-just-started nil)

    (if (or (< (point) csense-completion-symbol-beginning-position)
            (and (eq this-command 'self-insert-command)
                 (let ((syntax (char-syntax (char-before))))
                   (not (or (eq syntax ?w)
                            (eq syntax ?_))))))
        (csense-completion-cleanup)

      (if (memq this-command csense-completion-editing-commands)
          (csense-update-completion-list)))))


(defun csense-update-completion-list ()
  "Update the displayed completion list."
  (csense-update-completion-buffer
   (if (eq (selected-frame) csense-completion-frame)
       ""
     (csense-completion-get-filter)))
  (csense-completion-previous-line))


(defun csense-update-completion-buffer (filter)
  "Update the contents of the completion buffer according to
FILTER."
  (let ((case-fold-search t))
    (with-current-buffer (get-buffer-create csense-completions-buffer)
      (erase-buffer)

      (dolist (candidate csense-completion-candidates)
        (when (or (equal "" filter)
                  (string-match filter (plist-get candidate 'name)))
          (let ((start (point)))                      
            (let ((start (point)))                      
              (insert (plist-get candidate 'name) "\n")
              (put-text-property start (1+ start)
                                 'csense-completion-candidate candidate)))))

      (goto-char (point-min))

      (if (eobp)
          (message "No completions. Try deleting some characters.")))))


(defun csense-completion-get-filter ()
  "Return the current filter from the source buffer for the
completion."
  (buffer-substring csense-completion-symbol-beginning-position (point)))


(defun csense-completion-cleanup ()
  "Hide the completion frame and restore keybindings."
  (remove-hook 'pre-command-hook 'csense-completion-pre-command)
  (remove-hook 'post-command-hook 'csense-completion-post-command)

  (if csense-completion-frame
   (make-frame-invisible csense-completion-frame))

  (dolist (binding csense-saved-keys)
    (define-key (current-local-map) (car binding) (cdr binding)))
  (setq csense-saved-keys nil)

  (tooltip-hide)

  (with-current-buffer csense-completions-buffer
    (setq cursor-type t)
    (kill-local-variable 'mode-line-format)))


(defun csense-completion-mark-current-line ()
  "Highlight current line in the completion list."
  (let ((orig-frame (selected-frame)))
    (unwind-protect
        (progn          
          (select-frame csense-completion-frame)
          (move-overlay csense-selection-overlay
                        (line-beginning-position)
                        (1+ (line-end-position))))
      (select-frame orig-frame))))


(defun csense-completion-next-line ()
  "Move to next item in the completion list."
  (interactive)
  (csense-completion-move-selection (lambda () (forward-line 1))))

(put 'csense-completion-next-line 'csense-allowed-during-completion t)


(defun csense-completion-previous-line ()
  "Move to previous item in the completion list."
  (interactive)
  (csense-completion-move-selection (lambda () (forward-line -1))))

(put 'csense-completion-previous-line 'csense-allowed-during-completion t)


(defun csense-completion-next-page ()
  "Move to next page in the completion list."  
  (interactive)
  (csense-completion-move-selection (lambda ()
                               (condition-case nil
                                   (scroll-up)
                                 (end-of-buffer (goto-char (point-max)))))))

(put 'csense-completion-next-page 'csense-allowed-during-completion t)


(defun csense-completion-previous-page ()
  "Move to previous page in the completion list."  
  (interactive)
  (csense-completion-move-selection (lambda ()
                               (condition-case nil
                                   (scroll-down)
                                 (beginning-of-buffer (goto-char (point-min)))))))

(put 'csense-completion-previous-page 'csense-allowed-during-completion t)


(defun csense-completion-move-selection (func)
  "Move current selection in the completion list according to FUNC."  
  (interactive)

  (tooltip-hide)

  (let ((orig-frame (selected-frame)))
    (unwind-protect
        (progn
          (select-frame csense-completion-frame)
          (funcall func)
          (if (eobp)
              (forward-line -1))
          (csense-completion-mark-current-line))
      (select-frame orig-frame)))
  
  (with-current-buffer csense-completions-buffer    
    (unless (eq (overlay-start csense-selection-overlay)
                (overlay-end csense-selection-overlay))
      (let ((candidate (get-text-property (line-beginning-position)
                                          'csense-completion-candidate)))
        (if (and candidate
                 (sit-for csense-completion-tooltip-delay))
            (let ((orig-frame (selected-frame)))
              (unwind-protect
                  (progn
                    (select-frame csense-completion-frame)
                    (save-excursion
                      (end-of-line)
                      (csense-show-tooltip-at-pos (or (plist-get candidate 'doc)
                                                      "No documentation.")))))
                (select-frame orig-frame)))))))


(defun csense-completion-insert-selection ()
  "Insert selected item at point into the buffer."
  (interactive)
  (let ((candidate (with-current-buffer csense-completions-buffer
                     (get-text-property (line-beginning-position)
                                        'csense-completion-candidate))))
    (when candidate
      (delete-region csense-completion-symbol-beginning-position (point))
      (insert (plist-get candidate 'name)))))


(defun csense-completion-cancel ()
  "Cancel completion in progress."
  ;; post command hook will take care of it
  (interactive))


(defun csense-show-tooltip-at-pos (message &optional x y)
  "Show MESSAGE in popup at X;Y or at point if coordinates are
not given."
  (let* ((old-propertize (symbol-function 'propertize))
         (x-max-tooltip-size '(120 . 40))
         (xy (if x
                 (cons x y)

               (let* ((dimensions (csense-get-text-dimensions message))
                      (tooltip-width (car dimensions))
                      (tooltip-height (cdr dimensions)))
                 (csense-calculate-popup-position tooltip-width
                                                  tooltip-height))))
         (tooltip-hide-delay 600)
         (tooltip-frame-parameters (append `((left . ,(car xy))
                                             (top . ,(cdr xy)))
                                           tooltip-frame-parameters)))

    ;; move the mouse cursor from the way
    (set-mouse-position (selected-frame) 0 100)

    ;; the definition of `propertize' is substituted with a dummy
    ;; function temporarily, so that tooltip-show doesn't override the
    ;; properties of msg
    (fset 'propertize (lambda (string &rest properties)
                        string))
    (unwind-protect
        (tooltip-show message)
      (fset 'propertize old-propertize))))


(defun csense-get-text-dimensions (text)
  "Return text width and height in pixels."
  (let* ((lines (split-string text "\n"))
         (width (* (frame-char-width)
                   (apply 'max (mapcar 'length lines))))
         (height (* (frame-char-height) (length lines))))
    (cons width height)))


(defun csense-calculate-popup-position (width height)
  "Calculate pixel position of popup at point with size HEIGHT
and WIDTH in characters."
  (let* ((point-pos (posn-at-point))
         (point-xy (posn-x-y point-pos))
         (x (let ((x (+ (car point-xy) (frame-parameter nil 'left))))
              (if (> (+ x width) (x-display-pixel-width))
                  (- (x-display-pixel-width) width 10)
                x)))
         (y (let* ((point-y (+ (cdr point-xy) (frame-parameter nil 'top)))
                   (y (- point-y height)))
              (if (< y 0)
                  (+ point-y (* 4 (frame-char-height)))
                y))))
    (cons x y)))



(defun csense-wrap-text (text)
  "Wrap text if some of its lines are longer than
`csense-max-tooltip-line-length'."
  (let ((count 0)
        (pos 0)
        prevspace)
    (while (< pos (length text))
      (let ((char (aref text pos)))
        (cond ((= char ?\n)
               (setq count 0))
              ((= char ? )
               (if (< count csense-max-tooltip-line-length)
                   (progn (setq prevspace pos)
                          (incf count))

                 ;; insert newline
                 (if prevspace
                     (progn (aset text prevspace ?\n)
                            (setq count (- pos prevspace)))
                   (aset text pos ?\n)
                   (setq count 0))

                 (setq prevspace nil)))
              (t
               (incf count)))
        (incf pos))))
  text)


(defun csense-get-code-context (file pos)
  "Return colored line context from FILE around POS."
  (let* ((buffer (get-file-buffer file))
         result kill)
    (unless buffer
      (setq buffer (find-file-noselect file))
      (setq kill t))

    (with-current-buffer buffer
      (save-excursion
        (goto-char pos)
        (setq result
              (concat (csense-remove-leading-whitespace
                       (concat
                        (buffer-substring (save-excursion
                                            (forward-line -5)
                                            (point))
                                          (line-beginning-position))
                        (csense-color-string-background
                         (buffer-substring (line-beginning-position)
                                           (1+ (line-end-position)))
                         csense-tooltip-current-line-color)
                        (buffer-substring (1+ (line-end-position))
                                          (save-excursion
                                            (forward-line +5)
                                            (point)))))))))

    (if kill
        (kill-buffer buffer))

    result))


(defun csense-color-string-background (oldstr color)
  "Color OLDSTR with COLOR and return it."
  (let ((prevpos 0)
        pos 
        (str (copy-sequence oldstr))
        (continue t))
    (while continue
      (setq pos (next-single-property-change prevpos 'face str))
      (unless pos
        (setq pos (length str))
        (setq continue nil))
              
      (let ((face (get-text-property prevpos 'face str)))
        (put-text-property prevpos pos 'face
                           (list (cons 'background-color color)
                                 (cons 'foreground-color (if face
                                                             (face-foreground face))))
                           str))
      (setq prevpos pos))
    str))


(defun csense-truncate-path (path &optional length)
  "If PATH is too long truncate some components from the
beginning."
  (let ((maxlength (if length
                       length
                     70)))
    (if (<= (length path) maxlength)
        path

      (let* ((components (reverse (split-string path "/")))
             (tmppath (car components)))
        (setq components (cdr components))

        (while (and components
                    (< (length tmppath) maxlength))
          (setq path tmppath)
          (setq tmppath (concat (car components)
                                "/"
                                tmppath))
          (setq components (cdr components)))

        (concat ".../" path)))))


(defun csense-remove-leading-whitespace (str)
  "Remove leading identical whitespace from lines of STR."
  (let* ((lines (split-string str "\n"))
         char (count 0)) 
    (while (every (lambda (line)
                    (or (<= (length line) count)
                        (if char
                            (eq (aref line count) char)
                      
                          (setq char (aref line count))
                          (eq (char-syntax char) ?\ ))))
                  lines)
      (incf count)
      (setq char nil))

    (if (= count 0)
        str

      (let ((result (mapconcat (lambda (line)
                                 (if (>= count (length line))
                                     line
                                   (substring line count)))
                               lines "\n"))
            (oldpos -1)
            (newpos -1))
        ;; put back text properties to newlines
        (while (setq newpos (string-match "\n" result (1+ newpos)))
          (setq oldpos (string-match "\n" str (1+ oldpos)))
          (assert oldpos nil "Assertion failure: Old newline not found.")
          (put-text-property newpos (1+ newpos)
                             'face (get-text-property oldpos 'face str)
                             result))
        result))))


;; multi tooltip

(defvar csense-multi-tooltip-texts nil
  "List of texts shown in the current multi tooltip.")

(defvar csense-multi-tooltip-current nil
  "Index of current text shown in the tooltip. 0-based")

(defvar csense-multi-tooltip-saved-keys nil
  "Saved bindings for keys rebound by `csense-multi-tooltip-bindings'.")

(defvar csense-multi-tooltip-position nil
  "It's a list (X . Y) describing the position of the tooltip.")


(defun csense-show-multi-tooltip (texts)
  "Show several alternate texts in a tooltip. The current text
can be selected by the user."
  (let ((count 0))
    (setq csense-multi-tooltip-texts 
          (mapcar (lambda (text)
                    (concat (propertize
                             (concat " "
                                     (int-to-string (incf count))
                                     "/"
                                     (int-to-string (length texts))
                                     " ")
                             'face 'csense-multiple-tooltip-indicator-face)
                            "\n" text))
                  texts)))

  (let ((dimensions (mapcar (lambda (text)
                              (csense-get-text-dimensions text))
                            csense-multi-tooltip-texts)))
    (setq csense-multi-tooltip-position
          (csense-calculate-popup-position 
           (apply 'max (mapcar 'car dimensions))
           (apply 'max (mapcar 'cdr dimensions)))))

  (csense-multi-tooltip-show 0)

  (setq csense-multi-tooltip-saved-keys nil)
  (dolist (binding csense-multi-tooltip-bindings)
    (let ((key (car binding))
          (command (cdr binding)))
      (push (cons key (lookup-key (current-local-map) key))
            csense-multi-tooltip-saved-keys)
      (define-key (current-local-map) key command)))

  (message 
   (substitute-command-keys 
    (concat "Use keys \\[csense-multi-tooltip-previous]/"
            "\\[csense-multi-tooltip-next] to display "
            "other help texts in tooltip.")))

  (add-hook 'pre-command-hook 'csense-multi-tooltip-pre-command))


(defun csense-multi-tooltip-pre-command ()
  "Pre-command hook for monitoring multi tooltips."
  (unless (or (eq this-command 'csense-multi-tooltip-next)
              (eq this-command 'csense-multi-tooltip-previous))
    (remove-hook 'pre-command-hook 'csense-multi-tooltip-pre-command)

    (dolist (binding csense-multi-tooltip-saved-keys)
      (define-key (current-local-map) (car binding) (cdr binding)))))


(defun csense-multi-tooltip-show (index)
  "Show the INDEXth tooltip from `csense-multi-tooltip-texts'."
  (setq csense-multi-tooltip-current index)
  (csense-show-tooltip-at-pos (nth index csense-multi-tooltip-texts)
                              (car csense-multi-tooltip-position)
                              (cdr csense-multi-tooltip-position)))


(defun csense-multi-tooltip-next ()
  "Show next tooltip."
  (interactive)
  (csense-multi-tooltip-show
   (let ((next (1+ csense-multi-tooltip-current)))    
     (if (= next (length csense-multi-tooltip-texts))
         0
       next))))


(defun csense-multi-tooltip-previous ()
  "Show previous tooltip."
  (interactive)
  (csense-multi-tooltip-show
   (1- (if (= csense-multi-tooltip-current 0)
           (length csense-multi-tooltip-texts)
         csense-multi-tooltip-current))))


(defun csense-debug (message &optional args)
  "Show MESSAGE if `csense-debug' is non-nil."
  (if csense-debug
      (message (concat "CSense debug: "
                       (format message args)))))


(defun csense-get-files-recursive (directory regexp)
  "Return all files from DIRECTORY and its subdirectories which
match regexp."
  (delete-if-not (lambda (file)
                   (string-match regexp file))

                 (mapcan (lambda (file)
                           (if (and (file-readable-p file)
                                    (file-directory-p file))
                               (csense-get-files-recursive file regexp)
                             (list file)))

                         (delete-if (lambda (file)
                                      (string-match "/[.]+$" file))
                                    (directory-files directory t)))))

(provide 'csense)
;;; csense.el ends here
