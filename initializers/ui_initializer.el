;;
;; On Mac, windows system is ns (next step, origin of Cocoa),
;; and on Linux it is x. In terminal, though, it is nil so
;; it is a good way to detect if we are running in a shell
;; and fix yanking/pasting problem.
;;
(unless window-system
  (message "Running in a terminal, disabling x-select-enable-clipboard")
  (setq x-select-enable-clipboard nil)
  (setq interprogram-paste-function nil))



;;
;; Widgets, controls, menus, toolbars
;; 

;; no damn scrollbar, toolbar
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))

;; I love yellow cursor on black background
(set-cursor-color "yellow")

;; set dark background
(set-background-color "Black")
(set-foreground-color "White")

;; yes, use transient mark mode
(transient-mark-mode t)

(add-to-list 'load-path "~/emacsd/bundles/color_themes")
(require 'color-theme)

;; load twilight theme
(load "themes/vibrant-ink")
(color-theme-vibrant-ink)