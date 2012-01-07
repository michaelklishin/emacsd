# emacsd

## Installation

Clone this repo to ~/emacsd.

Add the following code to you ~/.emacs

    (defvar emacsd-dir     "~/emacsd/")

    (add-to-list 'load-path "~/.emacs.d")
    (add-to-list 'load-path emacsd-dir)

    (load "boot")
