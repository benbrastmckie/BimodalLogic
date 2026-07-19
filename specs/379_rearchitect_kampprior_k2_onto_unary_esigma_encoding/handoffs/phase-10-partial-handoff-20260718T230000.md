# Phase 10a Partial Handoff — Def 4.1 E[Σ] reverse-collapse core landed

**Dispatch:** lean-implementation-hard-agent, single-phase focus (Phase 10, hard mode).
**Status:** PARTIAL — 5 axiom-clean reusable lemmas landed and committed; top-level
`vvecea2_collapse_bridge` not yet assembled. File green, off-path, baseline preserved.

## Immediate next action

Assemble `vvecea2_collapse_bridge` in
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VVecEA2Collapse.lean` on top of the 5 landed
lemmas (see "Remaining assembly" below). Then Phase 10b (`efSat_negation_general`).

## Current state

- **Module:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VVecEA2Collapse.lean` — green.
- **Full `lake build`:** EXIT 0 at **1770 jobs** (baseline).
- **`#print axioms Bimodal.Metalogic.BXCanonical.completeness_discrete`:**
  `[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` —
  **byte-identical to baseline** (sole `sorryAx` = pre-existing `KampPrior.lean:562`, Phase 13).
- **Off live import path:** grep-audit confirms no module imports `VVecEA2Collapse`.
- **New imports added to the module:** `IntervalType`, `Prop35Assembly`, `Prop42ExistsForall`
  (all pre-existing, off-path).
- **No new `sorry`, no vacuous definitions, no new axioms.**

## Lemmas landed this dispatch (all axioms `[propext, Classical.choice, Quot.sound]`)

Committed as `task 379 phase 10a.1 … 10a.4`:

1. **`intervalType_captures_temporalPred`** — lifts `hCapture` (a `Formula`-level `∃ IntervalType`
   capture) to any `TemporalPred`, since `TemporalPred.eval_at = temporal_truth (·.formula)`. The
   reusable wrapper every endpoint/segment predicate routes through.
2. **`intervalHolds_intervalTop`** — every point realizes its own depth-0 characteristic
   (`nf_characteristic` / `nf_characteristic_satisfies`), so `intervalTop = univ` is satisfied
   everywhere ⇒ the two unbounded `ExistsForallFormula` caps are vacuous (Rabinovich trivial caps).
3. **`vvecea2_collapse_of_perClauseList`** — the **List-valued** generalization of the landed
   single-EF `vvecea2_collapse_of_perClause`, flattening per-clause EF lists with `List.flatMap`.
   Reduces the whole bridge to per-clause list-satisfaction correctness.
4. **`exists_piFinset_forall_iff`** — `(∃ f ∈ Fintype.piFinset t, ∀ i, p i (f i)) ↔ ∀ i, ∃ a ∈ t i,
   p i a`; the finite-choice core for interior-witness completion tuples.
5. **`bracket_completion_iff`** — **the crux**: a bracket whose point/segment predicates are captured
   by admissible-completion sets is satisfied iff some point-completion tuple yields a satisfied
   singleton-typed bracket. Proved by cases on witness count, reusing (4) and
   `efPointTP_eval`/`efIntervalSetTP_eval`.

## KEY FINDING (correction to the plan's assembly mechanism)

The plan (Phase 10a) specifies composing through the **landed single-EF**
`vvecea2_collapse_of_perClause` with a pure `trans : (Σn, VecEA2 n) → ExistsForallFormula`. That
interface **cannot** carry the `hCapture`-threaded reverse bridge, for two independent type-level
reasons:

1. **`hCapture` is non-constructive** (`∀ A, ∃ S, …`). A pure `trans` (no access to `N`/`atomMap`/
   `hCapture`) cannot realize the capture. The capture map `cap : Formula → IntervalType` must be
   obtained by `Classical.choice`/`choose` **inside** the bridge and used to build the translation.
2. **Point-type arity mismatch.** An `ExistsForallFormula` point type is a *single* complete
   `UnaryType`, but a captured truth set is a *union* of complete types (`IntervalType`, report 11
   R4). Hence one `VecEA2` clause expands into a **disjunction over point completions** — a `List`
   of EFs, not one. Segments are fine (they are already `IntervalType` slots), only points enumerate.

Resolution (landed): the **List/`flatMap`** assembly `vvecea2_collapse_of_perClauseList` (lemma 3)
is the correct vehicle; the interior-point enumeration uses `exists_piFinset_forall_iff` (lemma 4)
and the bracket collapse `bracket_completion_iff` (lemma 5). This is a genuine plumbing correction,
not a mathematical gap — the result is fully dischargeable given `hCapture`.

## Remaining assembly (well-scoped, de-risked)

To state and prove `vvecea2_collapse_bridge` (signature per plan Phase 10a):

1. `choose cap hcap using hCapture` ⇒ `cap : Formula → IntervalType sig F`,
   `hcap : ∀ A y, intervalHolds N (cap A) y ↔ temporal_truth N atomMap y A`.
2. Per clause `vea : VecEA2 m`: `S_L = cap vea.endpointLeft.formula`,
   `S_R = cap vea.endpointRight.formula`, `Sp i = cap (vea.bracket.pointTypes i).formula`,
   `Ss j = cap (vea.bracket.segmentTypes j).formula`; captures via `intervalType_captures_temporalPred`.
3. Per completion tuple `(τ_L ∈ S_L, τ_R ∈ S_R, g ∈ Fintype.piFinset Sp)` build the endpoint-pinned
   `ψ : ExistsForallFormula sig F 2`: `n = m+1`, `pin = ![0, Fin.last (m+1)]`,
   `pointType = Fin.cons τ_L (Fin.snoc g τ_R)`, `intervalType` = `intervalTop` caps at slots
   `0`/`last` and `Ss` on interior slots. Prove `EndpointPinnedCapTrivial N ψ` (pins by `rfl`,
   caps by `intervalHolds_intervalTop`). Then `translateProp42_correct` gives
   `efSat ψ ↔ (translateProp42 atomMap h_surj ψ).holds`, and `translateProp42 ψ` computes to the
   completed clause (`efPointTP τ_L`, `efPointTP τ_R`, bracket `efPointTP (g i)` / `efIntervalSetTP (Ss j)`).
4. `clauseToEFList vea := (S_L ×ˢ S_R ×ˢ Fintype.piFinset Sp).toList.map (fun ⟨τ_L,τ_R,g⟩ => ψ …)`.
5. `htrans`: `(∃ ψ ∈ clauseToEFList vea, efSat N env ψ) ↔ vea.holds N atomMap (env 0)(env 1)` for
   `env 0 < env 1`, by 3-way `∃`-distribution over the product ⇒
   `intervalHolds S_L (env 0) ∧ intervalHolds S_R (env 1) ∧ (∃ g ∈ piFinset Sp, bracketC[g].holds)`,
   then `bracket_completion_iff` (lemma 5) on the third conjunct and the endpoint captures (lemma 1)
   on the first two ⇒ `vea.holds`.
6. Conclude via `vvecea2_collapse_of_perClauseList` (lemma 3).

**Main risk:** the `ψ`-field reduction inside `translateProp42` (which reads `ψ.pointType 0`,
`ψ.pointType (Fin.last ψ.n)`, `ψ.pointType ⟨i+1⟩`, `ψ.intervalSet ⟨j+1⟩`). Use `Fin.cons`/`Fin.snoc`
with `Fin.cons_zero`/`Fin.snoc_last`/`Fin.snoc_castSucc` simp lemmas rather than raw `dite`, and
mirror the index bookkeeping already proved in `translateProp42_forward`
(`Prop42ExistsForall.lean`).

Estimated ~120–180 further lines. After 10a: Phase 10b (`efSat_negation_general`) threads the same
`hCapture` through `prop42_efSat_negation_general` + `vvecea2_collapse_bridge` + `veeSat_append`.

## Reuse anchors (verified this dispatch)

- `translateProp42` / `translateProp42_correct` / `EndpointPinnedCapTrivial`
  (`Prop42ExistsForall.lean`) — forward EF↔VecEA2 bridge, reused in reverse per-tuple.
- `efPointTP` / `efPointTP_eval`, `efIntervalSetTP` / `efIntervalSetTP_eval` (`Prop35Assembly.lean`).
- `IntervalPattern.holds_eq_zero` / `holds_eq_succ` (`ExistsForallNF.lean`).
- `intervalTop`, `ofComplete`, `intervalHolds_ofComplete_iff` (`IntervalType.lean`).
- Faithfulness: Rabinovich 2014 Def 4.1 (PDF p.5–6). Companion `.md` is corrupt — cite PDF page.
