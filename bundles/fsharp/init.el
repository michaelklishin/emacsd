

(setq auto-mode-alist (cons '("\\.fs[iylx]?$" . fsharp-mode) auto-mode-alist))

(autoload 'fsharp-mode "fsharp" "Major mode for editing F# code." t)
(autoload 'run-fsharp "inf-fsharp" "Run an inferior F# process." t)

(setq inferior-fsharp-program "mono ~/Tools/fsharp/fsi.exe --readline-")
(setq fsharp-compiler "mono ~/Tools/fsharp/fsc.exe")