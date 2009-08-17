(defun search-wikipedia (query)
  "Search wikipedia for given string"
  (interactive (list (search-read-query "wikipedia")))
  (search-run-query "<http://en.wikipedia.org/wiki/Special:Search?go=Go&search=>" query)
)