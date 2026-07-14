# Task 350 Phase 9 Summary: negBoundedRightFix + negBoundedLeftFix (Cor 5.4 mirrors)

## Scope

Single-phase hard-mode dispatch (H1): Phase 9 only — (B / P2b), Rabinovich 2014
Corollary 5.4(1)/(2) in fixed-formula iff form, appended to
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationFix.lean`.

## Delivered API

| Identifier | Statement shape |
|---|---|
| `TemporalPred.untl` / `.snce` + `eval_at_untl` / `eval_at_snce` | native `Formula.untl`/`.snce` builders with unfolded semantics |
| `HasAttainedSUP.last_occ_tp` | TemporalPred wrapper for the Phase-8 SUP walk |
| `chainAllTrue_nil_holds`, `chainAllTrue_cons(_holds_iff)`, `chainAllTrue_snoc_holds_iff`, `chainAllTrue_holds_mono_{left,right}` | structural kit for all-top chains |
| `untilFold`, `untilChainPreds(_nil,_cons,_head_cons)` | Rabinovich `F_i` Until folds + suffix chain predicates |
| `sinceFold`, `sinceChainPreds(_nil,_cons,_last_snoc)` | mirror `G_i` Since folds |
| `bracketOf` (+ nil/cons holds iffs) | prepend-recursion list brackets |
| `bracketSnocOf` (+ nil/cons holds iffs) | snoc-recursion list brackets |
| `BracketFormula.foldPairs(_succ)`, `eq_prepend_tail`, `holds_iff_bracketOf` | bridge: arbitrary bracket → prepend-list form |
| `BracketFormula.foldPairsRev`, `holds_iff_bracketSnocOf` | mirror bridge (recursion through `front`, definitional cons) |
| `exists_bracketOf_right_iff` | **Cor 5.4(1) chain observation**: `∃z∈(z0,z1), bf.holds z0 z ↔ (β₀ Untl F₁)(z0) ∧ chain` — ⇐ is the chunk_0015 relink induction |
| `exists_bracketSnocOf_left_iff` | mirror observation at `z1` via Since |
| `rightPinBracket(_holds_iff)`, `leftPinBracket(_holds_iff)` | attained first-`¬β₀` / last-`¬β_n` pin disjuncts |
| `negBoundedRightFix` + `negBoundedRightFix_iff (h_INF)` | **Cor 5.4(1)**: `↔ ¬∃ z, z0 < z ∧ z < z1 ∧ bf.holds M atomMap z0 z` |
| `negBoundedLeftFix` + `negBoundedLeftFix_iff (h_INF) (h_SUP)` | **Cor 5.4(2)**: `↔ ¬∃ z, z0 < z ∧ z < z1 ∧ bf.holds M atomMap z z1` |

## Key decisions

1. **Endpoint-free encoding**: Rabinovich's `¬F₀(z0)` endpoint disjunct is not expressible in
   this codebase's endpoint-free `VBracketFormula`; on attained structures it is equivalent to
   the first-`¬β₀` pin bracket `[β₀ ∧ ¬F₁, (¬β₀ ∧ ¬F₁), ⊤]` (mirror: last-`¬β_n` pin). This is
   where `HasAttainedINF`/`HasAttainedSUP` substitute for Dedekind completeness.
2. **List-recursion strategy**: all inductions run over pair lists (`bracketOf`/`bracketSnocOf`)
   consuming the existing `prepend_holds(_inv)` / `snoc_holds_iff`; arbitrary `BracketFormula n`
   inputs enter through two bridge lemmas — no new Fin witness surgery was needed.
3. **Left mirror truly consumes Phase 8's `HasAttainedSUP`** (`last_occ_tp` walk); the right
   mirror needs only `h_INF` (deviation from the plan's sketched signature, annotated inline).
4. `negChainOn` (Phase 8, Lemma 5.3) is consumed as-is for both mirrors' chain negation.

## Verification

| Check | Result |
|---|---|
| `lake build` (full) | green |
| sorries in EANegationFix.lean | 0 (file sorry-free; task inventory remains empty) |
| vacuous definitions introduced | 0 |
| new axioms | 0; `lean_verify` on `negBoundedRightFix_iff`, `negBoundedLeftFix_iff` = exactly `[propext, Classical.choice, Quot.sound]` |
| territory guard (G6) | respected — no edits to KampPrior.lean / ExteriorPinnedConverse*.lean |

## Commits

- `b0e106288` — task 350 phase 9.1: negBoundedRightFix (Cor 5.4(1))
- final phase commit — task 350 phase 9: left mirror + verification (see git log)

## Consumers (Phase 10)

`BracketFormula.negFix` Case 2 consumes `negBoundedRightFix`/`negBoundedLeftFix` with the peeled
bracket in endpoint-free form; if a point type at the moving endpoint is needed, fold it into
the first/last fold pair (the `F`/`G` folds accept arbitrary `TemporalPred`s).
