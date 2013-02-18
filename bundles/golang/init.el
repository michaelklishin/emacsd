(load "go-mode-load")

;; load bundle snippets
(yas/load-directory "~/emacsd/bundles/golang/snippets")

(add-hook 'go-mode (lambda ()
                     (def compile-command "go build .")))
