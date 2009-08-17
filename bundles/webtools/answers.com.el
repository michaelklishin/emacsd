(defun search-dictionary (word)
  "Search dictionary for given word"
  (interactive (list (search-read-query "dictionary")))
  (browse-url (concat "<http://answers.com/>" word))
)