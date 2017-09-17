;; Magit and git-* packages
(unless (require 'magit nil 'dont-fail)
  (progn
    (package-install 'git-gutter-fringe+)
    (package-install 'magit)
    (package-install 'magithub)))

(require 'git-modes)
(require 'magit)
