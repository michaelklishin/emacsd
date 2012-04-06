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

;; set dark background
(set-background-color "Black")
(set-foreground-color "White")
(set-cursor-color "yellow")

;; yes, use transient mark mode
(transient-mark-mode t)

(setq fill-column 79)
(setq font-lock-verbose nil)

(add-to-list 'load-path "~/emacsd/bundles/color_themes")
(require 'color-theme)

;; color themes
(load "themes/twilight")
(load "themes/vibrant-ink")
(load "themes/zenburn-ng")
(load "themes/solarized")

;; (color-theme-twilight)
;; (color-theme-vibrant-ink)
(color-theme-zenburn)
;; (color-theme-solarized-dark)
;; (color-theme-solarized-light)


;;
;; Full-screen mode on Cocoa
;;

(global-set-key "\C-\c\C-f\C-s" 'ns-toggle-fullscreen)
;; (ns-toggle-fullscreen)