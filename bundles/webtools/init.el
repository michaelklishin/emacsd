(load "run_query")
(load "google-search")
(load "wikipedia")
(load "answers.com")

(setq browse-url-browser-function 'browse-url-safari)
(defun browse-url-safari (url &optional new-window)
 "Open URL in a new Safari window."
 (interactive (browse-url-interactive-arg "URL: "))
 (unless
     (string= ""
              (shell-command-to-string
               (concat "open -a Safari " url)))
   (message "Starting Safari...")
   (start-process (concat " open -a Safari " url) nil "open -a Safari " url)
   (message "Starting Safari... done")))
