# Prose Ledger: Task 608 swap-family rename

Classification of every prose site touched by (or flagged against) the Phase 1 token rename.
Columns: site, classification (reworded / kept), note.

| Site | Class | Note |
|------|-------|------|
| `Syntax/MinusLanguage/Derivation.lean` rule list item 6 | reworded | "via `reflectTime`" -> "via `MinusFormula.reflectTime`" |
| `Syntax/MinusLanguage/Derivation.lean` "TR uses ..." paragraph | reworded | self-contradiction after token replace; now contrasts `MinusFormula.reflectTime` with `Formula.reflectTime` |
| `Syntax/MinusLanguage/Derivation.lean` `time_reflection` constructor docstring | reworded | `reflectTime φ` -> `φ.reflectTime`, names the L⁻ operation |
| `Syntax/MinusLanguage/Translation.lean` Main Results `tr_reflectTime` bullet | reworded | states `tr φ.reflectTime = (tr φ).reflectTime` with each side's namespace |
| `Syntax/MinusLanguage/Translation.lean` `tr_reflectTime` docstring | reworded | "`reflectTime` with the L-side one `reflectTime`" contradiction removed; each side namespaced |
| `Metalogic/Conservativity/Backward.lean` `translate` docstring, `time_reflection` bullet | reworded | both conclusions namespaced |
| `Semantics/MinusLanguage/MinusFrame.lean` module docstring `truth_swap` paragraph | reworded | "swapped formula" -> "time-reflected formula `φ.reflectTime`"; `swap` in name = `MinusFrame.swap` (F⁻) |
| `Semantics/MinusLanguage/MinusFrame.lean` `truth_swap` docstring | reworded | same; cites `lem:temporal-duality`; name kept |
| `Semantics/MinusLanguage/MinusSchemaValidity.lean` module bullet and lemma docstring | reworded | `reflectTime (Axiom.df φ)` -> `(Axiom.df φ).reflectTime` (dot form, unambiguous) |
| `Syntax/MinusLanguage/Formula.lean` module bullet and `reflectTime` definition docstring | reworded | "the L⁻ time reflection", analogue of `Formula.reflectTime` (paper `φ⟨S|U⟩`) |
| `Syntax/MinusLanguage/Formula.lean` push-through docstrings using `swap(Pφ)` shorthand | kept | informal math shorthand, not an identifier reference |
| "swap-validity" / "swap component" phrasing in renamed `_reflect_time_valid` docstrings | kept | optional plan item not taken; phrase remains accurate and is shared with out-of-scope lemmas |
| `Syntax/MinusLanguage.lean` "`reflectTime`" bullet | kept | inside the `MinusLanguage.Formula` bullet, unambiguous |
| All other token-renamed prose (Metalogic, Conservativity, READMEs) | kept | token replace yields correct, non-contrastive text |
