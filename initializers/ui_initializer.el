;;
;; On OS X, windows system is ns (for Next Step, that Cocoa is derived from),
;; and on Linux it is x. In terminal, though, it is nil so
;; it is a good way to detect if we are running in a shell
;; and fix yanking/pasting problem.
;;
(unless window-system
  (progn
    (message "Running in a terminal, disabling x-select-enable-clipboard")
    (setq x-select-enable-clipboard nil)
    (setq interprogram-paste-function nil)))



;;
;; Widgets, controls, menus, toolbars
;;

;; no damn scrollbar, toolbar
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))

;; yes, use transient mark mode
(transient-mark-mode t)

(setq fill-column 79)
(setq font-lock-verbose nil)

(column-number-mode)

;; set dark background
(set-background-color "Black")
(set-foreground-color "White")
(set-cursor-color "yellow")

;; color themes
(add-to-list 'load-path "~/emacsd/bundles/color_themes")
(require 'color-theme)

;; (load "themes/twilight-theme")
(load "themes/vibrant-ink-theme")
;; (load "themes/zenburn-ng-theme")
;; (load "themes/solarized")
;; (load "themes/moe-dark-theme")

;; (color-theme-twilight)
(color-theme-vibrant-ink)
;; (color-theme-zenburn)
;; (color-theme-solarized-dark)
;; (color-theme-solarized-light)
;; (load "themes/purple-haze-theme")

;;
;; Full-screen mode on Cocoa
;;

(setq x-select-enable-clipboard t)
(setq interprogram-paste-function 'x-selection-value)
