# Phase 6 handoff — prose correction

- **State**: comment-only edits; `lake build FormalSystem.ProofSystem.Axioms` and
  `lake build FormalSystem.Syntax.Formula` both green, so no comment boundary was crossed.
- **Landed**:
  - `FormalSystem/ProofSystem/Axioms.lean` Layer 9 — the "CONVERSE is NOT claimed" paragraph is
    replaced by (i) the machine-checked statement with pointers to `co_not_derives_prior_U_gap`
    and `co_not_derives_prior_U_gap_schema`, (ii) an explicit record that the ℚ-accumulation /
    Stavi witness was **refuted** and why, so it is not re-attempted, and (iii) the note that the
    countermodel is necessarily a model rather than a frame. The "CONSEQUENCE FOR THE PAPER"
    paragraph is retained, with its opening conditional updated.
  - `FormalSystem/Theorems/DedekindDerived.lean` — module docstring "Direction of the result"
    (which restated the refuted sketch verbatim) and `co_derived`'s "Direction" paragraph.
  - `FormalSystem/Syntax/Formula.lean` — `Formula.co`'s "converse is not claimed" pointer.
- **Scope-hypothesis deviation**: the plan asserted exactly two files carry stale prose; three do.
  Per the plan's own instruction ("if a third site surfaces, correct it too"), all three were
  corrected rather than matching the asserted count.
- **Untouched**: the `\aitem[CO]{TMP-CO}` anchors in `DedekindDerived.lean` and `Formula.lean`;
  every file under `/home/benjamin/Philosophy/Papers/`.
