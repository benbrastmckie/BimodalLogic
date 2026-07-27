/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Lean

/-!
# Lemma Database for Proof Search (`@[tm_lemma]`)

This leaf module declares the `@[tm_lemma]` label attribute used by the
`modal_search` family of tactics to enumerate derived theorems for
backward chaining (see `FormalSystem.Automation.Tactics.Helpers.tryLemmaMatch`).

**Import discipline**: this module imports ONLY `Lean`. Theorem modules
under `FormalSystem.Theorems.*` import this module to tag their declarations,
while `FormalSystem.Automation.Tactics.*` (which imports `FormalSystem.Theorems.*`)
reads the database via `Lean.labelled `tm_lemma`. Keeping this module a
leaf avoids the `Theorems -> Automation -> Theorems` import cycle.

## Tagging Policy

Tag ONLY:
- fc-polymorphic (`⊢[fc] φ`) or Base-stated (`⊢ φ`) EMPTY-CONTEXT theorems,
  and inference-rule lemmas whose premises are themselves empty-context
  derivability statements (e.g. `imp_trans`).

Never tag:
- Context-specific theorems (`ContextualProofs.lean`) — context-subset
  unification is out of scope for this database.
- fc-pinned theorems (stated at a specific non-Base frame class), which
  fail silently under `apply` for other frame classes.
- Generalized necessitation rules already special-cased by
  `tryModalK`/`tryTemporalK` (duplicative search branches).
-/

namespace FormalSystem.Automation.LemmaDB

/--
Declarations labelled `@[tm_lemma]` are enumerated by `modal_search`'s
`tryLemmaMatch` strategy and applied via backward chaining. See the module
docstring for the tagging policy.
-/
register_label_attr tm_lemma

end FormalSystem.Automation.LemmaDB
