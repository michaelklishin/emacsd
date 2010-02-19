#!/bin/sh

COMPILATION_RUN_FLAGS="--directory . --directory ~/emacsd -batch -f batch-byte-compile"

emacs $COMPILATION_RUN_FLAGS *.el emacs $COMPILATION_RUN_FLAGS  initializers/*.el themes/*.el

case `printenv SHELL` in
    /bin/zsh)
        emacs $COMPILATION_RUN_FLAGS  bundles/**/*.el
        ;;
    /bin/bash)
        for bundle in bundles/*; do
            emacs $COMPILATION_RUN_FLAGS  $bundle/*.el
        done
        ;;
esac

