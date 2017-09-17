# What is emacsd

This is a yet another collection of Emacs modes, settings, extensions, color themes
and everything in between. It has been accumulated over the period of 11 years
by Michael Klishin, used and modified by several other smart people and supports
machine-specific settings.

Many parts of this codebase need refactoring, documentation, upgrades to various
3rd party modes and so on. It is, however, mature and does not change very often.


## Installation

Clone this repo to `~/emacsd`, `touch ~/emacsd/custom-variables.el`.

Add the following code to you ~/.emacs

``` emacs-lisp
(defvar emacsd-dir     "~/emacsd/")

(add-to-list 'load-path "~/.emacs.d")
(add-to-list 'load-path emacsd-dir)

(load "boot")
```

This should initialize the necessary package repositories
and install the non-bundled dependencies.



## License & Copyright

Released under the MIT license.

* (c) Michael S. Klishin, 2007-2017
* (c) Dmitriy Dzema, 2009-2011
