(defun search-run-query (baseurl query)
  (browse-url (concat baseurl (url-hexify-string query)))
)