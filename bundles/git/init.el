;; Magit and git-* packages
(unless (require 'magit nil 'dont-fail)
  (progn
    (package-install 'with-editor)
    (package-install 'git-gutter-fringe+)
    (package-install 'magit)
    (package-install 'magithub)))

(use-package magit
             :ensure t
             :pin melpa-stable)
