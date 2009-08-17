;;;
;;; rspec-mode.el
;;;
;;; Pat Maddox

(define-derived-mode rspec-mode ruby-mode "RSpec")
(add-to-list 'auto-mode-alist '("_spec.rb$" . rspec-mode))

(defun app-root (&optional dir)
  (or dir (setq dir default-directory))
  (if (file-exists-p (concat dir "spec/spec_helper.rb"))
      dir
    (unless (equal dir "/")
      (app-root (expand-file-name (concat dir "../"))))))

(defun spec-command ()
  "spec")

(defun run-specs ()
  "Run specs and display results in same buffer"
  (interactive)
  (do-run-spec))

(defun run-focused-spec ()
  "Run the example defined on the current line"
  (interactive)
  (do-run-spec (concat "--line=" (number-to-string (line-number-at-pos)))))

(require 'linkify)
(defun do-run-spec (&rest args)
  (setq rspec-results (get-buffer-create "rspec-results"))
  (save-excursion
    ;; TODO: make this cd temporary for run
    (cd (app-root))
    (set-buffer rspec-results)
    (erase-buffer)
    (setq linkify-regexps '("^\\(/.*\\):\\([0-9]*\\):$")))
  (setq proc (apply #'start-process "rspec" rspec-results (spec-command) (buffer-file-name) args))
  (set-process-filter proc 'linkify-filter)
  (display-buffer rspec-results))
(provide 'rspec-mode)
