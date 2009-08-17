;;   (snippet-with-abbrev-table 'python-mode-abbrev-table
;;     ("for" .  "for $${element} in $${sequence}:")
;;     ("im"  .  "import $$")
;;     ("if"  .  "if $${True}:")
;;     ("wh"  .  "while $${True}:"))

(snippet-with-abbrev-table 'ruby-mode-abbrev-table
													 ("each" . "$${enumerable}.each { |$${item}| $${code} }")
													 ("while" . "while $${condition}\n$>$.\nend$>")
													 ("when" . "when $${condition}\n$>$.")
													 ("w" . "attr_writer :$${attr_names}")
													 ("y" . " :yields: $${arguments}")
													 ("r" . "attr_reader :$${attr_names}")
													 ("lam" . "lambda { |$${args}|$. }"))
													 