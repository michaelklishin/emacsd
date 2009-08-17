(load "rspec-mode")
(load "bundles/rspec/keymap")

;; load bundle snippets
(yas/load-directory "~/emacsd/bundles/rspec/snippets")

(add-to-list 'auto-mode-alist '("_spec\\.rb$" . rspec-mode))
;; SEG is shared examples group
(add-to-list 'auto-mode-alist '("_seg\\.rb$" . rspec-mode))