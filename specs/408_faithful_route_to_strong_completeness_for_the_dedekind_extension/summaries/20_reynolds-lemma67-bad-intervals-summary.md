# Phase 20 — Reynolds §6 Lemmas 6 and 7: bad points and bad intervals

**Status**: PARTIAL (one of Lemma 6's four halves blocked; everything else sorry-free and
axiom-clean, tree green)

## What landed

`FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/BadIntervals.lean` — 1343 lines, 42 new
top-level declarations plus one private environment lookup. Zero `sorry`. Zero removals, zero
renames anywhere in the tree.

### Vocabulary (printed p.179)

`IsBadPoint`, `badPointFormula` (+ `_spec`), `IsBadInterval` (+ `IsBadInterval.maximal_among`),
`ClassInteriorToRInterval`, `ClassInteriorToBadInterval`.

### Lemma 6 (printed p.180) — three of four halves

- `not_endsInGapOnRight_of_immediatePredecessor` — *"we can not have a class beginning just after
  a point `r` of `M`"*
- `notLeftEndFormula` / `NotLeftEnd` / `notLeftEndTemporal` (+ checked `_eval`, `_spec`) —
  Reynolds' `B`
- `leftEnd_iff_exists_not_notLeftEnd`, `exists_leftEnd_throughout` — *"throughout the bad interval
  all classes include their left hand end points"*, via Lemma 5 applied to `¬B`
- `false_of_allClassesHaveLeftEnd` — the Prior-U paragraph
- `endsInGapOnLeft_of_endsInGapOnRight` — *"`L` holds wherever `R` does"*
- `reynolds_lemma6_nonsingleton`, `reynolds_lemma6_right_endpoint`, `reynolds_lemma6`

### Lemma 7 (printed pp.180-181) — complete, both statements, both directions

- `false_of_holds_throughout_class_from_bounded` — the **third** gap-crossing form (see below)
- `afterNotHoldsInClassFormula` / `AfterNotHoldsInClass` / `afterNotHoldsInClassTemporal`
  (+ checked `_eval`, `_spec`) — Reynolds' `C`
- `reynolds_lemma7_start`, `reynolds_lemma7_close_to_left`
- Mirror (Prior-S): `endsInGapOnLeft_congr`, `exists_contemp_lt`,
  `false_of_holds_throughout_class_upto_bounded`, `beforeNotHoldsInClass*`,
  `reynolds_lemma7_end`, `reynolds_lemma7_close_to_right`
- `reynolds_lemma7` — all four halves assembled

## The determination the standing instruction asked for

**Lemma 7 licenses neither landed gap-crossing form.** Reynolds' *"`C` will be false for a while
at the beginning of each class and then true for a while at the end"* rules out both: Phase 18's
`false_of_holds_throughout_class` requires the auxiliary formula true **throughout** the class and
false at **every** later point outside it; Phase 19's
`false_of_holds_throughout_class_bounded` weakens only the second. The new
`false_of_holds_throughout_class_from_bounded` weakens both — `hin` from `s` onwards inside the
class, `hout` only *"false arbitrarily soon after the gap"*. Both earlier forms and all their
consumers are untouched.

## Blocked

Lemma 6's fourth half — `R` wherever `L` holds, Reynolds' *"using mirror images of the above and
previous results"* — needs a mirror of **Lemma 5** over maximal intervals of `λ`, which Phase 19
did not land (`reynolds_lemma5_first`'s interval hypothesis is `EndsInGapOnRight`-only). Not a
tactic failure; a module-sized missing asset. No `sorry` was used. **Phase 21 is not blocked by
it**: Lemma 8's thirteen cases consume Lemma 7, which is complete.

## Verification

| Check | Result |
| --- | --- |
| Full `lake build` | green, 1934 jobs; Phase 20's own delta **+1** (the new module) — the rest is a concurrent task-165 session |
| Scoped build | green |
| Live-tree `sorry` count | 3, **0 new from this phase** — `Transfer.lean:1242` (pre-existing, unrelated), `Bridge/IntTruth.lean:434,444` (task 165, commit `1d6655a95`) |
| `sorry` in `BadIntervals.lean` | **0** (one prose occurrence in the header only) |
| New vacuous definitions | 0 |
| New axioms | 0 |
| `#print axioms`, all 42 new names | `[propext, Classical.choice, Quot.sound]` or a strict subset; `sorryAx` absent |

## Literature fidelity

Lemma 6's and Lemma 7's statements **and their full proofs** are block-quoted verbatim in the
module header, read off the page images, with a proof-step → name map. Page map corrected: the
material is on printed **pp.179-181**, not the plan's pp.178-179 (drift of 1-2 pages, extending
Phases 18 and 19). **Corpus defect count stands at two** — Lemmas 6 and 7 contain no displayed
formula, and their inline prose checks out word for word against the page images.
