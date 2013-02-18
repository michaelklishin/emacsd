(load "go-mode-load")

;; load bundle snippets
(yas/load-directory "~/emacsd/bundles/golang/snippets")

(add-hook 'go-mode-hook (lambda ()
                          (def compile-command "go build .")))
