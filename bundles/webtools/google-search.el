(require 'url-util)

; read the user's query string, defaulting to the word under the point
(defun search-read-query (name)
  (let ((default (current-word))
        (enable-recursive-minibuffers t))
    (read-string (if default 
                   (format "Search %s (default %s): " name default) 
                 (format "Search %s: " name))
                 nil nil default)))

(defun search-google (query)
  "Search google for given string"
  (interactive (list (search-read-query "google")))
  (search-run-query "<http://www.google.com/search?q=>" query)
)

(defun search-google-lucky (query)
  "Search google for given string when you're feeling lucky"
  (interactive (list (search-read-query "google (feeling lucky)")))
  (search-run-query "<http://www.google.com/search?btnI=y&q=>" query)
)


(defun search-emacs-manuals (query)
  "Search online emacs manuals for given string"
  (interactive (list (search-read-query "online emacs manuals")))
  (search-run-query "<http://www.google.com/search?q=site:http://www.gnu.org/software/emacs/manual/> " query)
)