# Phase 3 Handoff — Prop 4.2 model-independent backward (documented fallback)

- **Task**: 305 (lean4) — plan v37 faithful Rabinovich path
- **Session**: sess_1782337996_6c54a7
- **Date**: 2026-06-24
- **Phase**: 3 of 6 — Prop 4.2 model-independent backward — **COMPLETED-via-documented-fallback, GREEN**
- **Next phase**: 4 (REBUILD Prop 4.3 structural FO induction) — NOT attempted this dispatch (H8 sizing: does not fit one clean green-ending run; see below)

## Phase 3 outcome

Per the dispatch guidance and plan v37 line 226/236, Phase 3 made exactly **one genuine
attempt** to confirm the documented model-independent backward obstruction still holds, then
took the **pre-authorized model-dependent interim path**.

### The one genuine attempt (conclusive negative)

A candidate backward theorem was stated at the live `VVecEA2` level in `NegationIndep.lean`:

```
theorem neg_2var_vec_ea_indep_backward
    (h_INF : HasAttainedINF M atomMap) (v : VVecEA2) (z0 z1 : M.carrier)
    (h_lt : z0 < z1)
    (h_holds : (neg_2var_vec_ea_indep v).holds M atomMap z0 z1) :
    ¬v.holds M atomMap z0 z1
```

`lean_goal` confirmed the goal `⊢ ¬VVecEA2.holds M atomMap v z0 z1`. `lean_multi_attempt`
probed it: `aesop` makes no progress, `exact?` finds nothing. The obstruction is structural,
not a missing-lemma gap:

- `neg_2var_vec_ea_indep v = neg_disjunct_list_indep v.disjuncts` is a **conjunction** over
  the disjuncts of `v`. To prove `¬v.holds` (every disjunct fails) it must show, per disjunct
  `d`, that `(neg_vecEA2_indep d).holds → ¬d.holds`.
- `neg_vecEA2_indep` is a **disjunction** of three cases (1a `endpointLeft.neg`, 1b
  `endpointRight.neg`, 23 `neg_interval_formula_indep`). The forward direction is sorry-free
  precisely because the three cases are *exhaustive*; but the cases are **not disjoint**, so
  the construction is not a biconditional.
- The backward direction bottoms out at the `neg_interval_formula_indep` backward = the **B.1
  interval-mismatch** (report 18 §2.3/§4): the IH gives `bf.tail` failing on `(r0, z1)`, but
  the original bracket witness `w_0` may satisfy `w_0 > r0`, so `bf.tail` could hold on the
  smaller interval `(w_0, z1)`. This is a fundamental obstruction (universal quantification
  over per-model bracket-witness arrangements), not fixable at the `BracketFormula` level.

This is the **same obstruction** the `NegationIndep.lean:331` NOTE and report 18 documented.
H6 churn cap honored: **1 attempt, conclusive negative, stopped** — no looping.

### The pre-authorized model-dependent interim (taken)

`lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.neg_2var_vec_ea` →
axioms `[propext, Classical.choice, Quot.sound]`, sorry-free. The model-**dependent** Prop 4.2
(`neg_2var_vec_ea`, EANegationClosure.lean) is full and sorry-free, and is sufficient to supply
the negation case for Prop 4.3 (Phase 4). The model-independent backward is a **bounded
follow-up**, OFF the live completeness path.

### Edits

- `NegationIndep.lean` `:331` NOTE region: appended a **PHASE 3 RESOLUTION** block recording
  the re-confirmation and the interim decision (comment-only; off the live import path).
- `plans/37_faithful-rabinovich-path.md` Phase 3: marked `[COMPLETED]`; tasks annotated with
  deviations (backward construction skipped/altered per pre-authorized fallback).

## Verification

- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NegationIndep` → GREEN (990 jobs); only
  pre-existing linter warnings, no errors, no new sorry.
- `lake build Bimodal.Metalogic.Metalogic` → GREEN (1671 jobs); baseline unchanged.
- Live-path sorry count: **2** (`KampPrior:391`, `:394`) = baseline. No regression.
- Axiom set unchanged; zero new top-level `axiom`.

## Sorry inventory (live path)

| Site | Status |
|---|---|
| `KampPrior.lean:391` (n=1 arm) | sorry — UNCHANGED (THE critical-path obstruction; Phase 5 target) |
| `KampPrior.lean:394` (n≥2 arm) | sorry — UNCHANGED (documented off-critical-path; Phase 6) |

Net live-path sorry count: **2** (= baseline).

## Phase 4 sizing assessment (why NOT attempted this dispatch — H8)

Phase 4 = "REBUILD Prop 4.3 as structural FO induction over `MonadicFormula sig m`, producing a
disjunction of exists-forall formulas (`VVecEA_m m`), with a correctness biconditional vs
`MonadicFO.eval`." Faithful statement (Rabinovich md:103–106):

> Every first-order formula is equivalent over Dedekind complete chains to a disjunction of
> exists-forall formulas. By structural induction: atomic immediate; disjunction immediate;
> negation via Prop 4.2; exists via Lemma 3.4.

**Building blocks confirmed present**:
- FO type: `MonadicFormula sig : Nat → Type` (constructors atom/lt/not/and/all/ex),
  `MonadicFO.eval` (`MonadicFO.lean:63, :216`).
- Target: `VVecEA_m m` + `VVecEA_m.holds` (`VecEA_m.lean:118, :123`).
- Existential: `VecEA_m.existClosure` + `existClosure_correct`/`_rev` (bidirectional,
  `VecEA_m.lean:208, :245, :314`). Absorbs the rightmost free variable.
- Arity firewall: `VecEA_m.arity_firewall` (Phase 2, `VecEAArityFirewall.lean`) — reduces
  arity-m EA to a conjunction of arity-1 + arity-2 components.
- Translation (Prop 3.5): `ExistsForallSpec.translate_correct` (`RabinovichTranslation.lean:200`).
- Negation (Prop 4.2): `neg_2var_vec_ea` — **arity-2 ONLY** (model-dependent, sorry-free).

**Why it does NOT fit one clean green-ending run** (the honest blocker):

1. **No arbitrary-arity negation closure exists.** Grep confirms only the arity-2
   `neg_2var_vec_ea`/`neg_2var_vec_ea_indep`. Prop 4.3's `not` case requires negating a
   `VVecEA_m m` for arbitrary `m`. The faithful route is: apply Phase 2 `arity_firewall` to
   rewrite the arity-m EA as a conjunction of arity-≤2 components, push negation through
   (De Morgan → disjunction of negated components), negate each arity-≤2 component via
   `neg_2var_vec_ea`, and reassemble as a `VVecEA_m m`. **This reassembly is itself a
   multi-lemma sub-phase** (firewall ↔ conjunction at the `holds` level, De Morgan over the
   `VVecEA_m` disjunction, per-component arity-≤2 negation, arity re-lifting of arity-1/2
   results back to arity m). It is ~150–250 lines on its own and must be sorry-free before the
   `not` case can close — a forbidden new live sorry otherwise.
2. **Existential-case index glue.** `eval (.ex α) env = ∃ x, eval (Fin.cons x env) α`, but
   `existClosure` absorbs the **rightmost** free variable, whereas `.ex` binds De Bruijn
   **index 0** (`Fin.cons` prepends). Aligning these requires a variable-permutation /
   re-indexing lemma between `Fin.cons x env` and the `existClosure` convention. Non-trivial.
3. **Atom/lt base cases** must each be expressed as a concrete `VecEA_m m` with a matching
   `holds`-vs-`eval` proof (smaller, but still real construction).
4. The whole induction is over a 6-constructor `MonadicFormula` with a correctness biconditional
   threaded through each case — comfortably a multi-hundred-line phase, exceeding the H8
   ~100–500-line one-run bound when combined with the unbuilt negation sub-phase.

**Recommended decomposition for Phase 4 (split into 4a/4b/4c, each its own green-ending run)**:
- **Phase 4a** — *Arbitrary-arity negation closure* (the genuine missing piece). Build
  `neg_vec_ea_m : VVecEA_m m → VVecEA_m m` (model-dependent interim) + correctness, via
  `arity_firewall` + De Morgan + per-component `neg_2var_vec_ea`. End GREEN, sorry-free,
  off-path. ~150–250 lines. **This is the true long pole; do it first.**
- **Phase 4b** — *Prop 4.3 easy cases + existential glue*. State Prop 4.3 over
  `MonadicFormula`; close atom/lt/and/or/ex cases (ex via `existClosure` + the re-indexing
  lemma). Leave `not` consuming Phase 4a. End GREEN, sorry-free, off-path.
- **Phase 4c** — *Wire the `not` case + assemble the full Prop 4.3 biconditional* using 4a.
  End GREEN, sorry-free, off-path.
- Then Phase 5 (re-anchor `KampPrior:391` via Prop 4.3 + Prop 3.5) and Phase 6 (verify) as
  originally planned.

If 4a proves to require generalizing Rabinovich §5 directly (rather than the firewall route),
re-confirm the firewall reduction first — `arity_firewall` was built in Phase 2 specifically to
make the arity-≤2 reduction available, so the firewall route should be tried before any §5
generalization.

## Resume point

Plan v37, **Phase 4** (recommend splitting into 4a/4b/4c above). Phases 1–3 COMPLETED and
committed. Build GREEN (1671 jobs); 2 live sorries = baseline; axiom set unchanged.
Start with **Phase 4a (arbitrary-arity negation closure via the Phase 2 arity firewall)** —
it is the genuine long pole and everything else depends on it.
