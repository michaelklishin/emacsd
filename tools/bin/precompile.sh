#!/bin/sh

COMPILATION_RUN_FLAGS="--directory . --directory ~/emacsd -batch -f batch-byte-compile"

case `printenv SHELL` in
    /bin/zsh)
        emacs $COMPILATION_RUN_FLAGS  *.el initializers/*.el themes/*.el
        emacs $COMPILATION_RUN_FLAGS  bundles/**/*.el
        ;;
    /bin/bash)
        emacs $COMPILATION_RUN_FLAGS  *.el
        for bundle in bundles/*; do
            emacs $COMPILATION_RUN_FLAGS  $bundle/*.el
        done
        emacs $COMPILATION_RUN_FLAGS  initializers/*.el
        emacs $COMPILATION_RUN_FLAGS  themes/*.el
        ;;
esac

