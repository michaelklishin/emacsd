;; makes pending RSpec example from each line in region
(fset 'make-pending-examples-from-region
   [?\C-  ?\C-e ?\C-w ?i ?t ?  ?\" ?\C-y ?\" ?\C-a ?\C-n])

;; makes org-mode todos from each line in region (in org-mode)
(fset 'todos-from-region
   "\C-a\C-c\C-t\C-p")

