;; Various Emacs Lisp code bundles or other initializers may depend on.
;;
;; It may contain code that helps with compatibility with different Emacs versions
;; on different machines (OS X 23.4 vs Linux 24/snapshot, for example), etc.
;;
;; Some bits are shameless attempts to make Emacs Lisp look a little bit more like
;; Clojure.

(global-set-key (kbd "C-c v") 'eval-buffer)
(define-key emacs-lisp-mode-map (kbd "C-c C-c") 'comment-region)
(define-key emacs-lisp-mode-map (kbd "C-c C-u") 'uncomment-region)

;;
;; Clojurify all the things
;;

(defalias 'def  'setq)
(defalias 'str  'concat)
(defalias 'defn 'defun)


;;
;; Emacs versions
;;

(defn emacs24? ()
  "Returns true if Emacs version is at least 24.0"
  (if (>= emacs-major-version 24)
  t
  nil))

(defn emacs23? ()
  (not (emacs24?)))
