Installation
============

1. Clone this repo to ~/emacsd dir.
2. Add the following code to you ~/.emacs

    (defvar emacsd-dir     "~/emacsd/")

    (add-to-list 'load-path "~/.emacs.d")
    (add-to-list 'load-path emacsd-dir)

    ;; These MUST be loaded first
    (defvar byte-compile-warnings t)
    (defvar byte-compile-verbose t)
    ;;(load "byte-code-cache")

    (load "boot")

    (put 'set-goal-column 'disabled nil)
