(defun autoci/package (package)
  (interactive "sName of the package?: ")
  "executes autoci script for a given package"
  (shell-command (concat "~/bin/autoci/autoci.sh " package)))
