;; Magit and git-* packages
(unless (require 'magit nil 'dont-fail)
  (progn
    (package-install 'git-commit-mode)
    (package-install 'git-rebase-mode)
    (require 'magit)))
