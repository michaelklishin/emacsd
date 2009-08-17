;;; csense-cs.el --- Opportunistic code sense backend for C#

;; Copyright (C) 2007  

;; Keywords: convenience

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; If you want to use the Code Sense frontend then simply require the
;; C# frontend:
;;
;;    (require 'csense-cs-frontend)
;;
;;
;; The parser here takes a completely opportunistic approach. It
;; doesn't aim completeness or correctness, it simply does what it
;; needs to do by taking shortcuts and making outrageous assumptions.
;;
;; It doesn't do the proper thing in all the cases, it simply does a
;; good enough job in most of the cases.
;;
;; Some assumptions are made. These simplify things and although they
;; could be implemented properly, it is deferred until I actually need
;; them to work correctly. The TODO list should give you an idea
;; what's missing.
;;
;;
;;  Tested on Emacs 22.


;;; Code:

(require 'csense)
(require 'csharp-mode)
(require 'rx)
(require 'cl)


;;; User configuration

(defvar csense-cs-source-files nil
  "List of source files of the project with full path.

You can use `csense-get-files-recursive' to collect the files recursively.")


(defvar csense-cs-assemblies nil
  "List of external assembly files used by the project.

If the assembly has a corresponding XML file in the same
directory then it will be used as well.")


(defvar csense-cs-assembly-parser-program "netsense.exe"
  "Path to program used to load information from assemblies.")


(defvar csense-cs-cache-directory "~/.csense-cs"
  "Path to directory where cache files are stored.")

;;;----------------------------------------------------------------------------

(defconst csense-cs-symbol-regexp
  '(symbol-start 
    (group (syntax word)
           (* (or (syntax word)
                  (syntax symbol)))
           symbol-end))
  "Regular expression for matching a symbol.")


(defconst csense-cs-type-regexp
  '(symbol-start 
    (group 
     (syntax word)
     (* (or (syntax word)
            (syntax symbol))))
    symbol-end
    (group
     (?  (or (and "<" (+ (not (any ">"))) ">")
             (and "[" "]")))))
  "Regular expression for matching a type.")

(defconst csense-cs-type-regexp-type-group 1
  "Index of the grouping within the regexp which holds the
  type.")

(defconst csense-cs-type-regexp-extra-group 2
  "Index of the grouping within the regexp which holds extra
  information for the type. For example, if it's a generic or an
  array.")


(defconst csense-cs-typed-symbol-regexp
  (append csense-cs-type-regexp '((+ space)) csense-cs-symbol-regexp)
  "Regular expression for matching a type.")


(defconst csense-class-base-regexp
  `((zero-or-one (and ,@(append '((* space)) ":" '((* space))
                                csense-cs-symbol-regexp))))
  "Regular expression for the matching the base class of a class.")


(defconst csense-cs-type-aliases
  '(("bool"	. "Boolean")
    ("byte"	. "Byte")
    ("char"	. "Char")
    ("decimal"	. "Decimal")
    ("double"	. "Double")
    ("float"	. "Single")
    ("int"	. "Int32")
    ("long"	. "Int64")
    ("object"	. "Object")
    ("sbyte"	. "SByte")
    ("short"	. "Int16")
    ("string"	. "String")
    ("uint"	. "UInt32")
    ("ulong"	. "UInt64")
    ("ushort"	. "UInt16")
    ("void"	. "Void"))
  "C# type aliases and the corresponding .NET types.")


(defvar csense-cs-type-hash (make-hash-table :test 'equal)
  "Hash containing known type information.")


(defvar csense-cs-newline-whitespace-syntax-table
  (make-syntax-table csharp-mode-syntax-table))

(modify-syntax-entry ?\n " " csense-cs-newline-whitespace-syntax-table)


(defconst csense-cs-type-cache-file "type-cache"
  "Name of cache file containing known type information from the source.")


(add-hook 'csharp-mode-hook 'csense-setup)
(add-hook 'csharp-mode-hook 'csense-cs-setup)
(add-hook 'kill-emacs-hook 'csense-cs-save-cached-types)


(defun csense-cs-setup ()
  "Setup C# backend for the current buffer."
  (csense-cs-initialize))


(defun csense-cs-initialize ()
  "Initialize CSharp support."
  (unless (> (hash-table-count csense-cs-type-hash) 0)
    (dolist (assembly csense-cs-assemblies)    
      (let ((cache-file 
             (concat (file-name-as-directory csense-cs-cache-directory)
                     (file-name-nondirectory assembly))))
        (if (and (file-readable-p cache-file)
                 (< (csense-cs-get-file-modification-time assembly)
                    (csense-cs-get-file-modification-time cache-file)))
            (progn
              (message "Loading cached information for assembly: %s" assembly)
              (with-temp-buffer
                (insert-file-contents cache-file)
                (csense-cs-read-assembly-info)))

          (message "Loading information from assembly: %s" assembly)

          (unless (file-readable-p csense-cs-cache-directory)
            (make-directory csense-cs-cache-directory t))

          (with-temp-file cache-file
            (unless (= (call-process csense-cs-assembly-parser-program
                                     nil t nil assembly)
                       0)
              (error "Cannot load information from assembly: %s" assembly))
            (csense-cs-read-assembly-info)))))

    ;; read types cached from source files
    (let ((cache-file (concat (file-name-as-directory csense-cs-cache-directory)
                              csense-cs-type-cache-file)))
      (message "Loading cached C# type information.")
      (if (file-readable-p cache-file)
          (dolist (type (with-temp-buffer
                          (insert-file-contents cache-file)
                          (read (current-buffer))))
        (puthash (plist-get type 'name) type csense-cs-type-hash))))

    (message "Done.")))


(defun csense-cs-read-assembly-info ()
  "Read assembly information from the current buffer."
  (goto-char (point-min))
  (condition-case nil
      (dolist (type (read (current-buffer)))
        (puthash (plist-get type 'name) type csense-cs-type-hash))
    (error (message (concat "Couldn't parse the following "
                            "line (position: %s): %s ")
                    (- (point) (line-beginning-position))
                    (buffer-substring (line-beginning-position)
                                      (line-end-position)))
           (error (concat "Couldn't read information from "
                          "assembly. See the *Messages* buffer "
                          "for details.")))))


(defun csense-cs-save-cached-types ()
  "Saved cached type information for source files."
  (let ((cache-file (concat (file-name-as-directory csense-cs-cache-directory)
                            csense-cs-type-cache-file)))
      (message "Saving cached C# type information for CSense.")
      (with-temp-file cache-file
        (pp (let (values)
              (maphash (lambda (k v)
                         (if (plist-get v 'file)
                             (push v values)))
                       csense-cs-type-hash)
              values)
            (current-buffer)))))


(defun csense-cs-get-information-at-point ()
  "Return available information at point or nil.

The return value is a list of plists.

The plists can have have the following properties:

  - name

    The name of the item.

  - shortname

    If it's a class then it's the class name without namespace
    prefix. This property is present only in classes retrieved
    from assemblies, because namespaces are not yet handled for
    source classes.

  - type

    The type of the item. For functions this is the return value.

  - array-type

    If type is array the this is the type held by the array.

  - doc

    Documentation. Present only for items retrieved from
    documented assemblies.

  - file

    Path of the source file where the item was found. Only
    present for items which have been found via source lookup.

  - pos

    Position of the item in the source file indicated by
    `file'. 

  - base

    Base class name if the item is a class.

  - members

    List of members if it is a class. The member is a plist
    having the same properties as described above and below.

    In addition the member can have the following properties:

       - class

         A link to the parent class if the member info came from
         an assembly. (It is not added for classes extracted from
         the sources, because there was no need for it there
         yet.)

       - access

         Access level of the member: `private', `protected' or `public'

       - static

         If this property is present (its value is always t) then
         it's a static member.

  - params

    List of plists describing parameters. Only present for
    functions and indexers.

    The plists can have have the following properties:

      - name

        The name of the parameter.

      - type

        The type of the parameter.

      - doc

        Documentation. Present only for items retrieved from
        documented assemblies.

  - current-param

    Zero-based index for the current parameter. Present only if
    the context is a function invocation and index of the current
    parameter could be determined.

  - source-context

    Indicates in which context the symbol has been found in the
    sources. Currently, the only possible value is 'class which
    means the symbol was an actual class name in the source
    code.

"
  (if (csense-cs-get-function-info)
      (let ((char-syntax-after (char-syntax (char-after)))
            (char-syntax-before (char-syntax (char-before))))
        (if (or (eq char-syntax-before ?w)
                (eq char-syntax-before ?_)
                (eq char-syntax-after ?w)
                (eq char-syntax-after ?_))
            (let ((infos (csense-cs-get-information-for-symbol-at-point)))
              ;; if it's a class and invoked as a constructor
              (when (and (plist-member (car infos) 'members)
                         (save-excursion
                           (skip-syntax-forward "w_")
                           (skip-syntax-forward " ")
                           (looking-at "(")))
                ;; in case of a class only single values should be
                ;; returned
                (assert (eq (length infos) 1))
                (let ((class-info (car infos)))
                  ;; return the list of constructors instead of class
                  ;; info
                  (setq infos (plist-get class-info 'constructors))))

              (if infos
                  ;; overloaded function, check possible invocation
                  (let ((numargs (save-excursion
                                   (skip-syntax-forward "w_")
                                   (skip-syntax-forward "")
                                   (if (looking-at "(")                                   
                                       (csense-cs-get-num-of-args)))))
                    (if numargs
                        (or (remove-if-not 
                             (lambda (function)
                               (apply (if (< numargs 0)
                                          '>=
                                        '=)
                                      (list 
                                       (length (plist-get function 'params))
                                       (abs numargs))))
                             infos)
                            (error (concat "No overloaded function matches "
                                           "the number of invocation parameters.")))

                      infos))))

          ;; check if we're in a function invocation argument list
          (let ((index 0))
            (save-excursion
              (condition-case nil
                  (with-syntax-table csense-cs-newline-whitespace-syntax-table
                    (skip-syntax-backward " ")
                    (while (not (eq (char-before) ?\())
                      (if (eq (char-before) ?,)
                          (incf index))
                      (backward-sexp)
                      (skip-syntax-backward " "))

                    ;; we got which argument the cursor is at, now
                    ;; find out what function it is
                    (backward-char)
                    (skip-syntax-backward " ")
                    (mapcar (lambda (function)
                              (plist-put function 'current-param index))
                            (csense-cs-get-information-at-point)))
                (scan-error nil))))))))


(defun csense-cs-get-completions-for-symbol-at-point ()
  "Return list of possible completions for symbol at point."
  (if (csense-cs-get-function-info)
      (save-excursion
        (if (csense-cs-backward-to-container)
            (csense-get-members-for-symbol
             ;; assuming only overloaded functions return more than
             ;; one value (true?), we'll take the first value
             ;; automatically
             (car (csense-cs-get-information-for-symbol-at-point)))
          (csense-cs-get-local-symbol-information-at-point)))

    (error "Completion works only within functions. For now.")))


(defun csense-cs-get-local-symbol-information-at-point ()
  "Return list of information about symbols locally available at point.

The list has the same format as the return value of
`csense-cs-get-information-at-point'."
  (let ((func-info (csense-cs-get-function-info)))
    (if func-info
        (csense-cs-merge-local-symbols
         (csense-cs-get-local-variables func-info)
         (csense-merge-inherited-members 
          (plist-get (csense-get-class-information
                      (plist-get func-info 'class-name))
                     'members)
          (if (plist-get func-info 'base)
              (csense-cs-get-accessible-inherited-members
               (plist-get func-info 'base))))))))


(defun csense-cs-get-local-variables (func-info)
  "Return a list of variables visible in the current scope within
the function."
  (let ((funbegin (plist-get func-info 'func-begin))
        (pos (point))
        result)
    (save-excursion
      (csense-cs-up-scopes 
       (lambda (type)
         (save-excursion
           (if (eq type 'sibling)
               ;; go to the end of the sibling scope to check for any
               ;; local variables bound after it
               ;;
               ;; since `csense-cs-up-scopes' already used
               ;; `backward-sexp' before we got here, this shouldn't
               ;; fail
               (forward-sexp))

           (save-excursion
             (while (re-search-forward
                     (eval `(rx  ,@csense-cs-typed-symbol-regexp
                                 (* space) (or "=" ";")))
                     pos t)
               (let ((var (csense-cs-get-typed-symbol-regexp-result)))
                 ;; avoid matching return statements
                 (unless (equal (plist-get var 'type) "return")
                   (setq result (csense-cs-merge-local-symbols result (list var)))))))
             
           (if (eq type 'parent)
             ;; if it's a parent scope and we're not at the beginning
             ;; of the function yet then check if it's a control
             ;; structure which binds a variable (there can be more
             ;; than one structure, one after the other)
             (unless (<= (point) funbegin)
               (save-excursion
                 (condition-case nil
                     (while (and 
                             (progn
                               (with-syntax-table 
                                   csense-cs-newline-whitespace-syntax-table
                                 (skip-syntax-backward " "))
                               (eq (char-before) ?\)))
                             (progn
                               (backward-sexp)
                               (looking-at 
                                (eval `(rx  "(" (* space) 
                                            ,@csense-cs-typed-symbol-regexp))))
                             (progn
                               (setq result 
                                     (csense-cs-merge-local-symbols 
                                      result 
                                      (list (csense-cs-get-typed-symbol-regexp-result))))
                               (backward-word)
                               t)))

                   (scan-error nil))))))

           (setq pos (point))
           (> (point) funbegin)))

      ;; control structure without curlies
      (save-excursion
        (let ((pos (point)))
          (when (and (re-search-backward (rx (or ";" "{" "}")) funbegin t)
                     (not (looking-at "{")))
            (forward-char)
            (forward-sexp)
            (if (looking-at (eval `(rx  (* space) "(" (* space)
                                        ,@csense-cs-typed-symbol-regexp)))
                (push (csense-cs-get-typed-symbol-regexp-result) result)))))

      ;; function arguments
      (condition-case nil
          (progn
            (goto-char funbegin)
            (backward-sexp)
            (setq result (csense-cs-merge-local-symbols
                          result (csense-cs-get-function-arguments funbegin))))
        (scan-error nil)))

    result))


(defun csense-cs-merge-local-symbols (symbols newsymbols)
  "Add those NEWSYMBOLS to SYMBOLS which has a different
name. Symbols hide other symbols with the same name in outer
scopes."
  (append symbols
          (remove-if 
           (lambda (newsymbol)
             (some (lambda (symbol)
                     (equal (plist-get symbol 'name)
                            (plist-get newsymbol 'name)))
                   symbols))
           newsymbols)))


(defun csense-cs-get-function-arguments (limit)
  "Return arguments of function from definition.

Cursor must be at the beginning paren of the argument list.
LIMIT is a position limiting the search."  
  (save-excursion
    (let ((regexp (eval `(rx ,@csense-cs-typed-symbol-regexp
                             (or "," ")"))))
          result)
      (while (re-search-forward regexp limit t)
        (let* ((arg (csense-cs-get-typed-symbol-regexp-result))
               (type (plist-get arg 'type))
               (alias (some (lambda (alias)                             
                              (if (equal type (car alias))
                                  (concat "System." (cdr alias))))
                            csense-cs-type-aliases)))
          (push (if alias
                    (plist-put arg 'type alias)
                  arg)
                result)))
      result)))


(defun csense-cs-get-members (class)
  "Return a list of members for the current class.
Cursor must be before the opening paren of the class.

CLASS is the name of the class.

Member are returned as a plist which groups normal
members ('members) and constructors ('constructors) separately.
"
  (save-excursion
    (let ((sections (csense-cs-get-declaration-sections))
          constructors members)
    (dolist (section sections)
      (let ((section-begin (car section))
            (section-end (cdr section)))
        (goto-char section-begin)
        ;; member variables
        (while (re-search-forward
                (eval `(rx  ,@csense-cs-typed-symbol-regexp
                            (or (and (* space) "=")
                                ";")))
                section-end t)
          (push (csense-cs-get-typed-symbol-regexp-result) members)
          ;; skip remainder of line if necessary
          (if (eq (char-before) ?=)
              (search-forward ";" section-end t)))

        ;; check possible stuff at end of section

        ;; property
        (if (re-search-forward
             (eval `(rx  ,@csense-cs-typed-symbol-regexp
                         (* (or space ?\n)) "{"))
             ;; the opening brace of the property is
             ;; the section closing brace, so it must
             ;; also be included in the match
             (1+ section-end) t)
            (push (csense-cs-get-typed-symbol-regexp-result) members)

          ;; member function
          ;;
          ;; Note that the code below matches constructors only,
          ;; because they usually have some modifier before their name
          ;; (e.g. public), so the modifier is matched as the "type"
          ;; in the regexp.
          ;;
          ;; This is nasty, of course, but convenient, because the
          ;; same regexp can be used to match constrcutors too, so I
          ;; leave it as is until there is a special need to handle
          ;; private constructors too (which are not matched if they
          ;; haven't any modifier).
          (if (and (re-search-forward
                    (eval `(rx  ,@csense-cs-typed-symbol-regexp
                                (* space) "("))
                    section-end t)
                                   
                   ;; closing paren followed by a
                   ;; an opening brace or colon (base class constructor)
                   (save-match-data
                     (save-excursion
                       (goto-char (1- (match-end 0)))
                       (forward-sexp)
                       (looking-at (rx (* (or space ?\n)) (or ?{ ?:))))))
              (let* ((symbol-info (csense-cs-get-typed-symbol-regexp-result))
                     (name (plist-get symbol-info 'name)))
                ;; weed out Main function
                (unless (equal name "Main")
                  (setq symbol-info 
                        (plist-put symbol-info 'params
                                   (csense-cs-get-function-arguments
                                    section-end)))
                  (if (equal name class)
                      ;; constructors have no type, see the comment
                      ;; above
                      (push (plist-put symbol-info 'type nil) constructors)
                    (push symbol-info members))))))))

    (list 'constructors (mapcar 'csense-cs-get-member-modifiers constructors)
          'members (mapcar 'csense-cs-get-member-modifiers members)))))


(defun csense-cs-get-member-modifiers (symbol-info)
  "Get modifiers for class member described by SYMBOL-INFO."
  (save-excursion
    (goto-char (plist-get symbol-info 'pos))
    (let (modifiers)
      (condition-case nil
          (while (progn (with-syntax-table
                            csense-cs-newline-whitespace-syntax-table
                          (skip-syntax-backward " "))
                        (not (or (eq (char-before) ?\;)
                                 (eq (char-before) ?})
                                 (eq (char-before) ?{))))
            (let ((end (point)))
              (backward-sexp)
              (push (buffer-substring-no-properties (point) end) modifiers)))
        (scan-error nil))

      (append
       (plist-put symbol-info
                  'access (if (member "public" modifiers)
                              'public
                            (if (member "protected" modifiers)
                                'protected
                              'private)))
       (if (member "static" modifiers)
           (list 'static t))))))


(defun csense-cs-get-declaration-sections ()
  "Return list of buffer sections (BEGIN . END) of a class.

Cursor must be at the beginning paren of class which sections are
to be returned."
  (condition-case nil
      (let (sections
            (veryend (save-excursion
                       (forward-sexp)
                       (point)))
            (end 0))

        (save-excursion
          ;; step into structure
          (search-forward "{")

          (while (not (eq veryend end))
            (unless (eq end 0)
              (goto-char end)
              (forward-sexp))

            (let ((begin (point)))        
              (setq end 
                    (or (save-excursion
                          (let (pos)
                            (while (and (search-forward "{" veryend t)
                                        (if (save-excursion
                                              (beginning-of-line)
                                              ;; FIXME: doesn't handle
                                              ;; multiline comments
                                              (looking-at (rx (* space) "//")))
                                            t
                                          (setq pos (1- (point)))
                                          nil)))
                            pos))
                        veryend))

              (push (cons begin end) sections)))
                      
          (nreverse sections)))

    (scan-error)))


(defun csense-cs-get-information-for-symbol-at-point ()  
  "Get information about symbol at point or throw an error if symbol is unknown.

The return value is a list of plists."
  (save-excursion
    (let (array symbol)
      (skip-syntax-backward "w_")
      (when (eq (char-before) ?\])
        (setq array t)
        (backward-sexp))

      (setq symbol (buffer-substring-no-properties
                    (progn (skip-syntax-backward "w_")
                           (point))
                    (save-excursion
                      (skip-syntax-forward "w_")
                      (point))))

      (assert (not (equal symbol "")) nil
                   "Assertion failure: Symbol shouldn't be empty here")

      (if (csense-cs-backward-to-container)
          (let ((parent-info (csense-cs-get-information-for-symbol-at-point)))
            ;; we're interested only in the return type, so it's
            ;; enough to work with the first result
            ;;
            ;; multiple values should only be returned for overloaded
            ;; functions and their return type must be the same
            (setq parent-info (car parent-info))
            
            (or (delete-if
                 'null
                 (mapcar (lambda (symbol-info)
                           (if (equal (plist-get symbol-info 'name) symbol)
                               symbol-info))
                         (csense-get-members-for-symbol parent-info)))

              (error "Don't know what '%s' is." symbol)))

        ;; handle `this'
        (if (equal symbol "this")
            ;; wrap the result in a list for consistency with
            ;; `csense-cs-get-local-symbol-information-at-point' (below)
            ;; which can return multiple results
            (list (let ((function-info (csense-cs-get-function-info)))
                    (if function-info
                        (csense-get-class-information 
                         (plist-get function-info 'class-name)))))

          ;; handle `base'
          (if (equal symbol "base")
              ;; wrap the result in a list for consistency with
              ;; `csense-cs-get-local-symbol-information-at-point' (below)
              ;; which can return multiple results
              (list (let ((function-info (csense-cs-get-function-info)))
                      (if function-info
                          (if (plist-get function-info 'base)
                              (csense-get-class-information 
                               (plist-get function-info 'base))
                            (error (concat "The base keyword is used, but "
                                           "this class has no base class."))))))

            (or
             ;; try it as a local symbol
             (remove-if-not
              (lambda (symbol-info)
                (if (and (equal (plist-get symbol-info 'name) symbol)
                         (or (not array)
                             (plist-get symbol-info 'array-type)))
                    (if array
                        ;; in case of an array reference return the
                        ;; array type, instead of System.Array
                        (plist-put symbol-info
                                   'type (plist-get symbol-info 'array-type))
                      symbol-info)))
              (csense-cs-get-local-symbol-information-at-point))

             ;; let's say it's a class
             ;;
             ;; wrap the result in a list for consistency with
             ;; `csense-cs-get-local-symbol-information-at-point' (above)
             ;; which can return multiple results
             (list (plist-put (csense-get-class-information symbol)
                              'source-context 'class)))))))))


(defun csense-get-members-for-symbol (symbol-info)
  "Return list of members for symbol described by SYMBOL-INFO."
  (let ((class-info (if (plist-member symbol-info 'members)
                        ;; it's a class itself
                        symbol-info
                      (csense-get-class-information
                       (plist-get symbol-info 'type)))))
    (csense-merge-inherited-members 
     (remove-if (lambda (member)
                  (and (eq (plist-get class-info 'source-context) 'class)
                       (or (not (plist-get member 'static))
                           (not (eq (plist-get member 'access) 'public)))))
                (plist-get class-info 'members))

     (if (plist-get class-info 'base)
         (csense-cs-get-accessible-inherited-members
          (plist-get class-info 'base))))))


(defun csense-cs-get-accessible-inherited-members (class)
  "Get members for CLASS which are accessible for descendant
classes."
  (remove-if (lambda (member)
               (eq (plist-get member 'access) 'private))
             (csense-get-members-for-symbol
              (csense-get-class-information class))))


(defun csense-merge-inherited-members (members inherited-members)
  "Merge MEMBERS of current class with INHERITED-MEMBERS from the
base class."
  (append 
   members
   (remove-if 
    (lambda (inherited-member)
      (some (lambda (member)
              (and (equal (plist-get member 'name)
                          (plist-get inherited-member 'name))
                   (or (not (plist-member member 'params))
                       (not (mismatch (plist-get member 'params)
                                      (plist-get inherited-member 'params)
                                      :test (lambda (x y)
                                              (equal (plist-get x 'type)
                                                     (plist-get y 'type))))))))
            members))
    inherited-members)))


(defun csense-cs-backward-to-container ()
  "If standing at a container reference then go bacward to the
container, and return t."
  (when (eq (char-before) ?\.)
    (backward-char)
    (skip-syntax-backward " ")
    (if (eq (char-before) ?\n)
        (backward-char))
    (if (eq (char-before) ?\))
        (backward-sexp))
    t))


(defun csense-get-class-information (class)
  "Look up and return information about CLASS."
  (or (csense-cs-get-class-information-from-cache class)
      (csense-cs-get-class-information-from-source class)
      (error "Class '%s' not found. Are you perhaps missing an assembly?" class)))


(defun csense-cs-get-class-information-from-cache (class)
  "Look up and return information about CLASS from
`csense-cs-type-hash' or nil if no class is found."
  (let ((class-info (gethash class csense-cs-type-hash)))
    (if (plist-get class-info 'file)
        (if class-info
            ;; in case of classes found in the sources check if the source did
            ;; not change in the meantime
            (when (< (plist-get class-info 'timestamp)
                     (csense-cs-get-file-modification-time 
                      (plist-get class-info 'file)))
              (remhash class csense-cs-type-hash)
              (setq class-info nil)
              (csense-debug (concat "Class %s was found in cache, "
                                    "but the entry was obsoleted.") class)))

      (unless class-info
        ;; usings are not tried for source classes, because
        ;; namespaces are not yet handled for the sources
        ;;
        ;; try usings
        (save-excursion
          (goto-char (point-min))
          (while (and (not class-info)
                      (re-search-forward (rx line-start (* space) 
                                             "using" (+ space) 
                                             (group (+ nonl)) (* space) ";")
                                         nil t))
            (let ((class-name (concat (match-string-no-properties 1) 
                                      "." class)))
              ;; handle aliases
              (some (lambda (alias)
                      (if (equal class-name (concat "System." (car alias)))
                          (setq class-name (concat "System." (cdr alias)))))
                    csense-cs-type-aliases)

              (setq class-info (gethash class-name csense-cs-type-hash)))))))

    (when class-info
      (csense-debug "Class %s is found in cache." class)

      ;; copy tree is done, so that destructive operations on the result
      ;; do not affect the hash contents
      (setq class-info (copy-tree class-info))

      (if (plist-get class-info 'file)
          class-info

        ;; a link to the parent class is put into every member
        (setq class-info
              (plist-put class-info
                         'members (mapcar (lambda (member)
                                            (plist-put member 'class class-info))
                                          (plist-get class-info 'members))))
        ;; a link to the parent class is put into every constructor and
        ;; they are named after the class
        (plist-put class-info
                   'constructors 
                   (mapcar (lambda (constructor)
                             (plist-put
                              (plist-put constructor 'class class-info)
                              'name (plist-get class-info 'shortname)))
                           (plist-get class-info 'constructors)))))))


(defun csense-cs-get-class-information-from-source (class)
  "Look up and return information about CLASS from the known
sources or nil if no class is found."
  (some (lambda (file)
          (let* ((buffer (get-file-buffer file))
                 result kill)
            (unless buffer
              (setq buffer (find-file-noselect file t))
              (setq kill t))

            (with-current-buffer buffer
              (save-excursion
                (goto-char (point-min))
                (when (re-search-forward 
                       (eval `(rx "class" (+ space)
                                  symbol-start (group ,class) symbol-end
                                  ,@csense-class-base-regexp))
                       nil t)

                  ;; position the cursor for csense-cs-get-members
                  ;; FIXME: it should be done some other way, it's clumsy
                  (with-syntax-table 
                      csense-cs-newline-whitespace-syntax-table
                    (skip-syntax-forward " "))

                  (let ((base (match-string-no-properties 
                               (1+ (csense-cs-get-regexp-group-num
                                    csense-class-base-regexp))))
                        (pos (match-beginning 1))
                        (member-info (csense-cs-get-members class)))
                    (setq result (list 'name class
                                       'file file
                                       'pos pos
                                       'members 
                                       (plist-get member-info 'members)
                                       'constructors 
                                       (plist-get member-info 'constructors)))
                    (if base
                        (setq result (plist-put result 'base base)))

                    (setq result (plist-put result 'timestamp (float-time)))

                    ;; copy tree is done, so that destructive operations on the result
                    ;; do not affect the hash contents
                    (puthash class (copy-tree result) csense-cs-type-hash)

                    (csense-debug "Class %s is found in sources." class)))))

            (if kill
                (kill-buffer buffer))

            result))
        csense-cs-source-files))


(defun csense-cs-get-function-info ()
  "Return a plist of information about the current function or nil
if point is not in a function.

The plist values:

 `func-begin'

    The position of the beginning paren of the function.

  `class-begin'

    The position of the beginning paren of the class.

  `class-name'

    The name of the containing class.

  `base'

    The base class of the containing class.
"
  (save-excursion
    (let (result)
      (csense-cs-up-scopes
       (lambda (type)
         (if (eq type 'sibling)
             ;; we're not interested in sibling scopes
             t

           (if (and (plist-get result 'func-begin)
                    (save-excursion
                      (beginning-of-line)
                      (if (looking-at (rx (* space) "{"))
                          (forward-line -1))
                      (looking-at (eval `(rx (* not-newline)
                                             "class" (+ space)
                                             ,@csense-cs-symbol-regexp
                                             ,@csense-class-base-regexp)))))
               (progn
                 (setq result (plist-put result 'class-begin open))
                 (setq result (plist-put result 'class-name
                                         (csense-cs-get-match-result
                                          (list csense-cs-symbol-regexp))))
                 (let ((base (csense-cs-get-match-result
                              (list csense-cs-symbol-regexp
                                    csense-class-base-regexp))))
                   (if base
                       (setq result (plist-put result 'base base))))

                 ;; class found, stop search
                 nil)

             (setq result (plist-put result 'func-begin (point)))
             ;; search further for containing class
             t))))

      (if (plist-get result 'class-name)
          result))))


(defun csense-cs-up-scopes (callback)
  "Go up scopes from point invoking CALLBACK every time the
beginning of a new scope is found.

CALLBACK is called with one argument which is the symbol `parent'
or `sibling' indicating the type of scope found,

The traversing of scopes continues if CALLBACK returns non-nil."
  (condition-case nil
      (save-excursion
        (while (let ((open (save-excursion
                             (re-search-backward "{" nil t)))
                     (close (save-excursion
                              (re-search-backward "}" nil t))))
                 (if open
                     (if (and close 
                              (> close open))
                         (progn 
                           (goto-char (1+ close))
                           (backward-sexp)
                           (funcall callback 'sibling))

                       (goto-char open)
                       (funcall callback 'parent))

                   ;; no more parens
                   ;; terminate the search
                   nil))))

    (scan-error nil)))


(defun csense-cs-get-typed-symbol-regexp-result ()
  "Return the result of matching a `csense-cs-typed-symbol-regexp' as a plist."
  (append 
   (list 'name (csense-cs-get-match-result 
                (list csense-cs-type-regexp
                      csense-cs-symbol-regexp))
         'file (buffer-file-name)
         'pos (match-beginning (csense-cs-get-regexp-group-num 
                                (list csense-cs-type-regexp
                                      csense-cs-symbol-regexp))))
   (let ((type (match-string-no-properties csense-cs-type-regexp-type-group))
         (extra (match-string-no-properties csense-cs-type-regexp-extra-group)))
     (if (equal extra "[]")         
         (list 'type "System.Array"
               'array-type type)
       (list 'type type)))))


(defun csense-cs-get-match-result (regexps)
  "Return the last matching group by adding up the number of
matching groups in REGEXPS."
  (match-string-no-properties 
   (apply '+ (mapcar 'csense-cs-get-regexp-group-num regexps))))


(defun csense-cs-get-regexp-group-num (list)
  "Return the number of groups in rx regexp represented as LIST."
  (let ((num 0))
    (mapc (lambda (x)
            (if (listp x)
                (setq num (+ num (csense-cs-get-regexp-group-num x)))
              (if (eq x 'group)
                  (incf num))))
          list)
    num))


(defun csense-cs-get-num-of-args ()
  "Return number of arguments for a function invocation or nil if it cannot be determined.

A negative return value means the invocation as at least that
many arguments. The exact number of arguments could not be
determined.

Cursor must be before the beginning paren of the invocation."
  (save-excursion
    (condition-case nil
        (let ((end (1- (save-excursion
                         (forward-sexp)
                         (point))))
              (count 1))
          (condition-case nil
              (progn
                (skip-syntax-forward " ")
                (assert (looking-at "("))
                (forward-char)
                (skip-syntax-forward " ")

                (if (looking-at ")")
                    0

                  (while (< (point) end)
                    (skip-syntax-forward " ")
                    (forward-sexp)
                    (skip-syntax-forward " ")
                    (if (looking-at ";")
                        (signal 'scan-error nil)
                      (when (looking-at ",")
                        (incf count)
                        (forward-char))))
                  count))
            (scan-error (- 0 count))))
      (scan-error nil))))
           

(defun csense-cs-get-file-modification-time (file)
  "Return the modification time of FILE in seconds since the
epoch."
  (float-time (sixth (file-attributes file))))


(provide 'csense-cs)
;;; csense-cs.el ends here
