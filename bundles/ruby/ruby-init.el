(defvar datamapper-mode-dir "~/dev/emacs.d/programming/ruby/datamapper-mode/")
(defvar merb-mode-dir "~/dev/emacs.d/programming/ruby/merb-mode/")

(add-to-list 'load-path merb-mode-dir)
(add-to-list 'load-path datamapper-mode-dir)
 

(load "inf-ruby")
(load "ruby-mode")
(load "ruby-electric")
(load "pcmpl-rake")
(require 'pcmpl-rake)

(load "toggle")

;; Ruby C VM style
(load "ruby-style")
;;(load "autotest")
;; TODO: add DataMapper library.
(setq auto-mode-alist  (cons '("\\.rb$" . ruby-mode) auto-mode-alist))

(defun rake (task)
  (interactive (list (completing-read "Rake (default: default): "
                                      (pcmpl-rake-tasks))))
  (shell-command-to-string (concat "rake " (if (= 0 (length task)) "default" task))))

(load "ruby-mode")
(setq auto-mode-alist
			(append '(("\\.thor$" . ruby-mode))
							auto-mode-alist))


(defun ruby-newline-and-indent ()
  (interactive)
  (newline)
  (ruby-indent-command))

(defun ruby-toggle-string-to-symbol ()
  "Easy to switch between strings and symbols."
  (interactive)
  (let ((initial-pos (point)))
    (save-excursion
      (when (looking-at "[\"']") ;; skip beggining quote
        (goto-char (+ (point) 1))
        (unless (looking-at "\\w")
          (goto-char (- (point) 1))))
      (let* ((point (point))
             (start (skip-syntax-backward "w"))
             (end (skip-syntax-forward "w"))
             (end (+ point start end))
             (start (+ point start))
             (start-quote (- start 1))
             (end-quote (+ end 1))
             (quoted-str (buffer-substring-no-properties start-quote end-quote))
             (symbol-str (buffer-substring-no-properties start end)))
        (cond
         ((or (string-match "^\"\\w+\"$" quoted-str)
              (string-match "^\'\\w+\'$" quoted-str))
          (setq quoted-str (substring quoted-str 1 (- (length quoted-str) 1)))
          (kill-region start-quote end-quote)
          (goto-char start-quote)
          (insert (concat ":" quoted-str)))
         ((string-match "^\:\\w+$" symbol-str)
          (setq symbol-str (substring symbol-str 1))
          (kill-region start end)
          (goto-char start)
          (insert (format "'%s'" symbol-str))))))
    (goto-char initial-pos)))


(global-set-key (kbd "C-c k") 'ruby-toggle-string-to-symbol)


;; setup align for ruby-mode
(require 'align)

(defconst align-ruby-modes '(ruby-mode)
  "align-perl-modes is a variable defined in `align.el'.")

(defconst ruby-align-rules-list
  '((ruby-comma-delimiter
     (regexp . ",\\(\\s-*\\)[^/ \t\n]")
     (modes  . align-ruby-modes)
     (repeat . t))
    (ruby-string-after-func
     (regexp . "^\\s-*[a-zA-Z0-9.:?_]+\\(\\s-+\\)['\"]\\w+['\"]")
     (modes  . align-ruby-modes)
     (repeat . t))
    (ruby-symbol-after-func
     (regexp . "^\\s-*[a-zA-Z0-9.:?_]+\\(\\s-+\\):\\w+")
     (modes  . align-ruby-modes)))
  "Alignment rules specific to the ruby mode.
See the variable `align-rules-list' for more details.")

(add-to-list 'align-perl-modes 'ruby-mode)
(add-to-list 'align-dq-string-modes 'ruby-mode)
(add-to-list 'align-sq-string-modes 'ruby-mode)
(add-to-list 'align-open-comment-modes 'ruby-mode)
(dolist (it ruby-align-rules-list)
  (add-to-list 'align-rules-list it))


(add-to-list 'auto-mode-alist '("\\.rb$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode)) ; d'oh!
(add-to-list 'auto-mode-alist '("Rakefile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Thorfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Capfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.god$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.builder$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.mab$" . ruby-mode))
 
(add-to-list 'interpreter-mode-alist '("ruby" . ruby-mode))
(add-to-list 'interpreter-mode-alist '("jruby" . ruby-mode))
(add-to-list 'interpreter-mode-alist '("ruby1.9" . ruby-mode))
 
(add-to-list 'completion-ignored-extensions ".rbc")
(add-to-list 'completion-ignored-extensions ".rba")


(font-lock-add-keywords
 'ruby-mode
 '(("\\<\\(FIX\\|TODO\\|FIXME\\|HACK\\|REFACTOR\\):"
    1 font-lock-warning-face t)))