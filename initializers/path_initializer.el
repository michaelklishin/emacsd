(add-to-list 'load-path "~/.emacs.d")

(setq exec-path (cons "/opt/local/bin" exec-path))
(setq exec-path (cons "/usr/local/bin" exec-path))

(setenv "PATH" (concat (getenv "PATH") ":/usr/local/bin"))
