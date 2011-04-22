;; Port of TextMate Vibrant ink colour theme for Emacs.
;;
;; MIT License Copyright (c) 2008 Michael Klishin <michael.s.klishin@gmail.com>
;; Credits due to the excellent TextMate Vibrant Ink theme
;;

(defun color-theme-vibrant-ink ()
  "Color theme by Michael Klishin, based off the TextMate Vibrant Ink theme"
  (interactive)
  (color-theme-install
   '(color-theme-vibrant-ink
     ((background-color . "#040404")
      (background-mode . dark)
      (border-color . "black")
      (cursor-color . "yellow")
      (foreground-color . "#FFFFFF")
      (mouse-color . "sienna1"))
     (default ((t (:background "black" :foreground "#9933CC"))))
     (blue ((t (:foreground "blue"))))
     (bold ((t (:bold t))))
     (bold-italic ((t (:bold t))))
     (border-glyph ((t (nil))))
     (buffers-tab ((t (:background "black" :foreground "#9933CC"))))
     (font-lock-builtin-face ((t (:foreground "white"))))
     (font-lock-comment-face ((t (:foreground "#9933CC"))))
     (font-lock-constant-face ((t (:bold t :foreground "#339999"))))
     (font-lock-doc-string-face ((t (:foreground "DarkOrange"))))
     (font-lock-function-name-face ((t (:foreground "#FFCC00"))))
     (font-lock-keyword-face ((t (:foreground "#FF6600"))))
     (font-lock-preprocessor-face ((t (:foreground "#EDF8F9"))))
     (font-lock-reference-face ((t (:foreground "SlateBlue"))))

     (font-lock-regexp-grouping-backslash ((t (:foreground "#E9C062"))))
     (font-lock-regexp-grouping-construct ((t (:foreground "red"))))

     (font-lock-string-face ((t (:foreground "#CCCC33"))))
     (font-lock-type-face ((t (:foreground "#9B703F"))))
     (font-lock-variable-name-face ((t (:foreground "#7587A6"))))
     (font-lock-warning-face ((t (:bold t :foreground "Pink"))))
     (gui-element ((t (:background "#D4D0C8" :foreground "black"))))
     (region ((t (:background "blue2"))))
     (mode-line ((t (:background "black" :foreground "white"))))
     (highlight ((t (:background "#222222"))))
     (highline-face ((t (:background "SeaGreen"))))
     (italic ((t (nil))))
     (left-margin ((t (nil))))
     (text-cursor ((t (:background "yellow" :foreground "black"))))
     (toolbar ((t (nil))))
     (underline ((nil (:underline nil))))
     (zmacs-region ((t (:background "snow" :foreground "ble")))))))