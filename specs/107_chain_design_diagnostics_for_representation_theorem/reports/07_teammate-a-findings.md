# Teammate A Findings: Burgess Chronicle Construction Review

**Task**: 107 — Chain Design Diagnostics for BX Representation Theorem
**Artifact**: 07_teammate-a-findings.md
**Scope**: Primary progress review of all 6 Chronicle files + Completeness + ParametricTruthLemma
**Date**: 2026-04-23

---

## Key Findings

### Overall Assessment

The 5-phase implementation produced a structurally correct proof architecture with a clean
pipeline from a single MCS through the omega-chain to a countermodel. The proof wiring in
`Completeness.lean` is correct. The 20 sorry sites are distributed across 5 files and fall
into distinct categories with very different closing difficulty levels.

The 3 previously critical RootScopedChain sorry sites are successfully bypassed. The
ParametricTruthLemma fix (Phase 1) is complete and correct. The overall proof architecture
faithfully represents Burgess 1982 under strict semantics, with well-documented adaptations
where A3a/A4a do not hold.

---

### Sorry Site Inventory (20 total)

| # | File | Line | Name/Description | Category | Blocking? | Difficulty |
|---|------|------|-----------------|----------|-----------|------------|
| 1 | RRelation.lean | 154 | `until_guard_consistent` (Lemma 2.2) | Strict-semantics gap | No | Medium |
| 2 | PointInsertion.lean | 360 | `lemma_2_6_strong` seed consistency | Duality argument | No | Medium |
| 3 | PointInsertion.lean | 807 | `lemma_2_7` D2 guard case | BX7 chain (hard) | No | High |
| 4 | PointInsertion.lean | 814 | `lemma_2_7` D2 witness case | BX7 chain (hard) | No | High |
| 5 | PointInsertion.lean | 936 | `lemma_2_8` eta-in-C case | BX7 variant | No | High |
| 6 | CounterexampleElimination.lean | 78 | `exists_rat_gt_finset` | Mathlib helper | Yes (upstream) | Low |
| 7 | CounterexampleElimination.lean | 89 | `exists_rat_lt_finset` | Mathlib helper | Yes (upstream) | Low |
| 8 | ChronicleConstruction.lean | 115 | `counterexample_enum` | Countability | Yes (upstream) | Low |
| 9 | ChronicleConstruction.lean | 123 | `counterexample_enum_surjective` | Countability | Yes (upstream) | Low |
| 10 | ChronicleConstruction.lean | 319 | `limit_satisfies_c5_weak` | Main C5 theorem | Yes (core) | Medium |
| 11 | ChronicleConstruction.lean | 329 | `limit_satisfies_c5'_weak` | Main C5' theorem | Yes (core) | Medium |
| 12 | ChronicleToCountermodel.lean | 192 | `chronicle_fmcs.forward_G` | FMCS coherence | Yes (core) | Medium |
| 13 | ChronicleToCountermodel.lean | 196 | `chronicle_fmcs.backward_H` | FMCS coherence | Yes (core) | Medium |
| 14 | ChronicleToCountermodel.lean | 234 | `box_stable_in_chronicle_fmcs` | Box stability | Yes (core) | Medium |
| 15 | ChronicleToCountermodel.lean | 320 | `chronicle_bfmcs_restricted_tc` (F) | F-resolution | Yes (core) | Medium |
| 16 | ChronicleToCountermodel.lean | 323 | `chronicle_bfmcs_restricted_tc` (P) | P-resolution | Yes (core) | Medium |
| 17 | ChronicleToCountermodel.lean | 342 | `chronicle_bfmcs_restricted_buc` (U) | Backward Until | Yes (core) | Medium |
| 18 | ChronicleToCountermodel.lean | 345 | `chronicle_bfmcs_restricted_buc` (S) | Backward Since | Yes (core) | Medium |
| 19 | ChronicleToCountermodel.lean | 374 | `chronicle_bfmcs_restricted_fuc` (U) | Forward Until | Yes (core) | Medium |
| 20 | ChronicleToCountermodel.lean | 377 | `chronicle_bfmcs_restricted_fuc` (S) | Forward Since | Yes (core) | Medium |

**Critical path dependency chain**:
`exists_rat_gt/lt` (#6,7) → `eliminate_C5/C5'_counterexample` → `omega_chain` → `limit_satisfies_c5_weak` (#10)
→ `chronicle_bfmcs_restricted_tc/fuc` (#15,16,19,20) → `dd_countermodel_chronicle` → `bx_completeness`

`counterexample_enum` (#8,9) → `omega_chain` → `limit_satisfies_c5_weak` (#10) (same downstream)

`chronicle_fmcs.forward_G/backward_H` (#12,13) → `chronicle_bfmcs` (fields `forward_G/backward_H`)
→ `chronicle_bfmcs_restricted_tc` → `dd_countermodel_chronicle` → `bx_completeness`

---

## Per-File Analysis

### ChronicleTypes.lean (0 sorries) — COMPLETE

**Status**: Fully sorry-free. 325 lines.

**Accomplished**:
- `SetDeductivelyClosed`: Correct definition (consistent + closed under derivation).
- `mcs_is_dcs`, `dcs_contains_theorems`, `dcs_modus_ponens`, `dcs_conj_closed`: All proved cleanly.
- `Adjacent`, `rRelation`, `rRelationSince`, `rMaximal`, `rMaximalSince`: Definitions are mathematically correct and faithful to Burgess 1982 Section 2.
- `Chronicle` structure and all conditions `c0`–`c5'`: Well-defined.
- `ValidChronicle`: Collects all conditions into a structure.
- `rRelation_subset`, `rRelation_of_superset_mcs`, `rRelationSince_of_superset_mcs`: All proved.

**Mathematical correctness**: The `rRelation` definition (for Until: either delta in B, or gamma and gamma-U-delta both in B) correctly captures the "guard continues or resolves" property. Under strict semantics this is the right notion since BX9 provides gamma-or-delta, not gamma alone.

**No issues**.

---

### RRelation.lean (1 sorry) — NEARLY COMPLETE

**Status**: 1 sorry at line 154 (`until_guard_consistent`). All other 14 theorems sorry-free.

**Accomplished**:
- `until_disjunction_in_mcs` through `since_implies_P_in_mcs`: 6 BX axiom instantiation lemmas, all clean.
- `rRelation_guard_continues'`: Core Lemma 2.3 consequence, proved.
- `deductiveClosure_is_dcs`: Proved via Zorn chain argument.
- `rMaximal_extension_exists` (Zorn's lemma): Fully proved with helper `chain_finite_subset_in_element`. This is a substantial proof (~100 lines) and it is correct.
- `rMaximalSince_extension_exists`: Mirror, also proved.

**Sorry #1 — `until_guard_consistent`** (Lemma 2.2):

_Mathematical obligation_: Show `{gamma}` is set-consistent given `gamma U delta in MCS A`.

_Why it is hard_: Under strict (irreflexive) Until semantics, `gamma U delta` does not
syntactically imply `gamma` in BX. BX9 gives only `gamma or delta`. The comment in the
file is correct: `bot U delta` is semantically absurd on dense orders but NOT derivably
inconsistent from the BX axioms (there is no axiom `bot U delta -> bot`). This is a genuine
adaptation gap relative to reflexive Until.

_Is it blocking?_ No. The file comment documents this correctly — the downstream lemmas
(in particular `until_witness_seed_consistent` in PointInsertion.lean) use `F(delta) in A`
from BX10 rather than `{gamma} consistent`, so Lemma 2.2 is not actually invoked in the
downstream chain.

_Proof strategy to close it_:
Option A (add derived axiom): Show `gamma U delta -> gamma` is derivable in BX under
strict semantics by checking whether BX5 + BX9 + BX12 suffice:
- BX5: `(gamma U delta) -> (gamma ^ (gamma U delta)) U delta`
- BX9: `(gamma ^ (gamma U delta)) U delta -> (gamma ^ (gamma U delta)) or delta`
- Case gamma: done. Case delta: We need gamma-at-current-time, which isn't given.
This derivation fails. The correct resolution is:

Option B (document as non-theorem): Formally prove `until_guard_consistent` is not a theorem
in BX under strict semantics by exhibiting a model where `gamma U delta` holds but `{gamma}` is
inconsistent. (Under strict semantics with dense time, `delta U delta` holds whenever
`F(delta)` holds, and `delta = bot` is excluded by MCS consistency. But the formal
proof of failure requires constructing a Kripke model.) The lemma is structurally not
needed downstream, so marking it `sorry` with a clear impossibility note is acceptable.

Option C (prove the weaker needed form): Replace with `until_or_in_mcs` (already proved as
`until_disjunction_in_mcs`) and document that this is what downstream requires.

**Recommendation**: Leave as sorry with clear documentation that it is non-critical and
possibly non-provable in BX. Focus effort on the critical-path sorries.

---

### PointInsertion.lean (4 sorries) — MOSTLY COMPLETE

**Status**: 4 sorries. Most significant lemmas (2.4, 2.5b, 2.6, 2.7 D1/D3, 2.8 eta-not-C) proved.

**Accomplished**:
- Helper lemmas (`F_neg_of_G_not`, `until_witness_seed_consistent`, BX axiom instantiations,
  `lemma_2_7_guard`): All proved, well-written.
- `lemma_2_4`: Fully proved. Correctly adapted for strict semantics: provides `P(U(gamma,beta)) in C`
  via BX4 instead of guaranteeing `gamma in C` (which is semantically wrong at the endpoint).
- `lemma_2_5b` and `lemma_2_5b_past`: Both proved cleanly using `all_future_all_future`.
- `lemma_2_6`: Proved. Correctly uses `F_neg_of_G_not` + `forward_temporal_witness_seed_consistent`.
- `lemma_2_7` D1 case: Fully proved. The 80-line derivation chain establishing that
  `F(eta ^ neg eta)` contradicts `G(neg neg(eta -> neg neg eta))` is correct and complete.
- `lemma_2_7` D3 case: Fully proved. Extracts `xi` from the conjunction `(xi ^ U(xi,eta)) ^ neg eta`.
- `lemma_2_8` eta-not-C case: Correctly reduces to `lemma_2_7`.

**Sorry #2 — `lemma_2_6_strong`** (line 360):

_Mathematical obligation_: Show `{neg delta} union g_content(A) union h_content(C)` is
consistent given `g_content(A) subset C` and `delta not in C`.

_Why it is hard_: Requires the duality lemma `g_content_subset_implies_h_content_reverse`
(available in `WitnessSeed.lean`) plus a careful consistency argument for the three-component
seed. The key step: `g_content(A) subset C` implies `h_content(C) subset A` (by
`g_content_subset_implies_h_content_reverse`), so the seed reduces to
`{neg delta} union g_content(A)` modulo `h_content(C) subset A`. From there,
`F(neg delta) in A` (via `F_neg_of_G_not`) gives seed consistency via
`forward_temporal_witness_seed_consistent`.

_Is it blocking?_ No. `lemma_2_6` (the weaker version without `g_content(D) subset C`)
is proved and is used in Phase 4. `lemma_2_6_strong` is not called downstream.

_Proof strategy_:
```
1. G(delta) not in A (from g_content(A) subset C and delta not in C)
2. F(neg delta) in A (by F_neg_of_G_not)
3. h_content(C) subset A (by g_content_subset_implies_h_content_reverse h_mcs_A h_mcs_C h_g_AC)
4. Seed = {neg delta} union g_content(A) union h_content(C)
        subset {neg delta} union A (since g_content(A) subset A and h_content(C) subset A)
5. Consistency of seed follows from F(neg delta) in A + forward_temporal_witness_seed_consistent
   after observing h_content(C) items are all in A.
```
The issue is step 5: `forward_temporal_witness_seed_consistent` requires `{neg delta} union g_content(A)`,
not the three-component set. The additional `h_content(C)` items must be bundled in.
The extended `enriched_resolving_seed_consistent` or a custom consistency argument is needed.
This is 20-40 lines of work.

**Sorry #3 & #4 — `lemma_2_7` D2 cases** (lines 807, 814):

_Mathematical obligation_: D2 arises from BX7 when `U(xi^top, eta^top)` is in `A` but
neither D1 nor D3. Must find MCS `D` with `xi in D` and `g_content(A) subset D`.

_Why it is hard_: The D2 case means the Until-witness comes strictly before the neg-eta witness.
At the guard positions (before the eta-witness), `xi` holds semantically but this is not
directly available syntactically from the Until formula in `A`. The file documents two sub-cases:
- Guard case (phi^top in A): xi is in A itself, but propagating it to a FUTURE D requires
  showing the Until's guard persists at intermediate future points. This requires a second
  application of BX7 on `U(phi^top, eta^top)` and `top U neg eta`, or using BX5 to get
  the accumulated Until and then BX10 to get `F(phi^top)`.
- Witness case (eta^top in A): eta is at the current time, and the Until still requires
  xi at intermediate future positions. This is the same structural difficulty.

_Key insight_: In both D2 sub-cases, `xi in A` is either directly available (guard sub-case)
or can be extracted via BX9 on D2 (since the guard `phi^top = (xi ^ U(xi,eta)) ^ top`
contains `xi`). For a future witness D:
- Apply BX10 to D2 = `U(phi^top, eta^top)`: get `F(eta^top) in A`, hence `F(eta) in A`.
- Apply BX4 to xi (which IS in A in both sub-cases): get `G(P(xi)) in A`.
- `P(xi) in g_content(A)`. At any D with `g_content(A) subset D`: `P(xi) in D`.
- But `P(xi) in D` does not give `xi in D`.

The gap is that `P(xi)` records xi was true in the past of D, not that xi is true AT D.
The correct approach uses `F(xi)` not `P(xi)`:
- If xi in A: BX4 gives `G(P(xi)) in A`, but we need `F(xi) in A`.
- Can we get `F(xi) in A`? Under strict semantics: `xi U eta in A` and BX5 gives
  `U(xi^U(xi,eta), eta) in A`. BX9 on this: `xi^U(xi,eta) or eta in A`, giving xi in A or eta in A.
  If xi in A: use BX4 on xi to get `G(P(xi))`. The issue is F vs G(P).
- A possible route: if xi in A, and `U(phi^top, eta) in A` from D2 self-accum,
  then by BX5 on `U(phi^top,eta)`: `U((phi^top)^(phi^top U eta), eta) in A`.
  By BX10: `F(eta) in A`. But we have this from D2 directly. We still can't get `F(xi)`.

_Assessment_: The D2 cases are **genuinely hard** under strict semantics. They represent the
deepest mathematical gap in the implementation. The guard propagation problem is the core
difficulty: the Until formula stays in `A` but the guard doesn't propagate to future MCS
via g_content (since Until formulas are not G-formulas). A complete proof likely requires
either:
(a) A new auxiliary lemma proving that if `U(phi, eta) in A` and the witness comes after
    position D, then `phi in D` via a second BX7 application (recursive use of Lemma 2.7).
(b) Restructuring the oracle at the chronicle level so D2 situations are handled by the
    interval DCS `g(x,y)` rather than the point function `f`.

_Is it blocking?_ For the chronicle completeness theorem, `lemma_2_7` appears to be only
invoked from `lemma_2_8`, and `lemma_2_8` is invoked in Phase 4's counterexample elimination
to ensure the guard holds at intermediate domain points (the strong form of C5). However,
examining `CounterexampleElimination.lean` and `ChronicleConstruction.lean`, neither file
directly calls `lemma_2_7` or `lemma_2_8`. The current Phase 4 uses only `lemma_2_4`
(which is sorry-free). Therefore, sorries #3 and #4 are **not currently on the critical path**.

**Sorry #5 — `lemma_2_8` eta-in-C case** (line 936):

_Mathematical obligation_: When `eta in C` but `U(xi,eta) not in C` (given `xi not in C`
and `(xi or (eta ^ U(xi,eta))) not in C`), find MCS D with `xi in D` and `g_content(A) subset D`.

_Why it is hard_: Same structural issue as D2 of Lemma 2.7 — need to propagate xi to a
future point. The comment correctly identifies this reduces to a BX7 variant on
`U(xi,eta)` and `top U neg U(xi,eta)`.

_Is it blocking?_ Same as #3,4 — not currently on the critical path.

---

### CounterexampleElimination.lean (2 sorries) — MOSTLY COMPLETE

**Status**: 2 sorries (both in helper lemmas). Core constructions `eliminate_C5_counterexample`,
`eliminate_C5'_counterexample`, `eliminate_potential_counterexample` are sorry-free.

**Mathematical correctness**: The elimination constructions correctly use `lemma_2_4` to build
the witness MCS and append the new point at a fresh rational. The `C5Counterexample` and
`C5'Counterexample` structures correctly capture the missing-witness condition.

**Sorry #6 — `exists_rat_gt_finset`** (line 78):

_Mathematical obligation_: For any finite set of rationals `S`, `∃ q : Rat, ∀ s ∈ S, s < q`.

_Why it is easy_: Mathlib provides `Finset.exists_lt_sum` and related lemmas. The standard
approach: take `q = S.fold (· + 1) 0 max` or `q = (S.sup' ⟨⟩ id) + 1`. Under `LinearOrder Rat`
from `Mathlib.Algebra.Order.Ring.Rat`, `Finset.sup'` and `lt_add_one` suffice.

_Proof strategy_:
```lean
obtain ⟨a, ha⟩ := S.exists_max  -- or use S.sup' / S.fold max
exact ⟨a + 1, fun s hs => lt_of_le_of_lt (S.le_max hs) (lt_add_one a),
       fun h => (lt_add_one a).ne (le_antisymm (S.le_max h) (le_refl a))⟩
```
More precisely, for an empty `S`, pick `q = 0`; for nonempty, pick `S.max' h_ne + 1`.

**Sorry #7 — `exists_rat_lt_finset`** (line 89): Symmetric, same difficulty and approach.

_Both are low-difficulty, non-mathematical sorries that can be closed with 10-15 lines using
Mathlib's `Finset.max'` and `Rat.lt_add_one`._

---

### ChronicleConstruction.lean (4 sorries, 1 trivial) — MOSTLY COMPLETE

**Status**: 4 sorries. Core chain infrastructure (omega_chain, limit_f, limit_c0,
limit_f_zero, limit_f_eq) fully proved and correct. The `claim_2_11` sorry is trivial
(the theorem statement is reflexivity — line 363: `exact Iff.rfl`).

**Mathematical correctness**: The omega-chain construction is architecturally correct.
`limit_f_eq` is correctly proved by using `omega_chain_f_agrees_le` at `max(m, n)`.
`limit_c0` correctly delegates to `omega_chain_c0`.

**Sorry #8 — `counterexample_enum`** (line 115):

_Mathematical obligation_: Define a surjective function `Nat -> PotentialCounterexample`
where `PotentialCounterexample = {x : Rat, xi eta : Formula, dir : Bool}`.

_Why it is easy_: Both `Rat` and `Formula` are `Countable` (declared in Atom.lean and
Formula.lean via `deriving Countable`). `Bool` is finite hence countable. The product
`Rat × Formula × Formula × Bool` is therefore countable. Mathlib's `Countable.exists_surjective_nat`
(or equivalent) gives the enumeration.

_Proof strategy_:
```lean
noncomputable def counterexample_enum : Nat → PotentialCounterexample :=
  let f : Nat → Rat × Formula × Formula × Bool :=
    (Countable.exists_surjective_nat (Rat × Formula × Formula × Bool)).choose
  fun n => let ⟨x, xi, eta, dir⟩ := f n; ⟨x, xi, eta, dir⟩
```
Or construct an `Encodable` instance and use `Encodable.decode`.

**Sorry #9 — `counterexample_enum_surjective`** (line 123): Follows directly from the
surjectivity of the encoding. 5-10 lines once #8 is proved.

**Sorry #10 — `limit_satisfies_c5_weak`** (line 319):

_Mathematical obligation_: For `x in limit_dom` with `xi U eta in limit_f(x)`, show
`∃ y in limit_dom, x < y ∧ eta in limit_f(y)`.

_Proof strategy_: This is a direct consequence of the omega-chain construction.
1. `x in limit_dom` means `x in dom(n0)` for some n0.
2. `xi U eta in limit_f(x) = f_{n0}(x)`.
3. Enumerate: `counterexample_enum k = ⟨x, xi, eta, true⟩` for some k (by surjectivity).
4. Let `n1 = max(n0, k)`. At step `n1`, `x in dom(n1)` (by domain monotonicity) and
   `f_{n1}(x) = f_{n0}(x)` (by f-agreement), so `xi U eta in f_{n1}(x)`.
5. At step `n1 + 1`, `eliminate_potential_counterexample` is called with the enum entry for k.
   Since `x in dom(n1)` and `xi U eta in f_{n1}(x)`, the counterexample IS actual.
6. By `eliminate_C5_counterexample`: a new point `y` is inserted with `eta in f_{n1+1}(y)`
   and `x < y` and `y in dom(n1+1)`.
7. `y in limit_dom` (witnessed by n1+1), `limit_f(y) = f_{n1+1}(y)` contains eta.

The key technical gap: step 6 uses `eliminate_C5_counterexample` which itself depends on
`exists_rat_gt_finset` (sorry #6). So #10 depends on #6. Also need to verify that
the `eliminate_potential_counterexample` dispatch correctly identifies the counterexample
at step n1 (the `by_cases h_actual` branch).

_This is a medium-difficulty proof, approximately 40-60 lines._

**Sorry #11 — `limit_satisfies_c5'_weak`** (line 329): Mirror of #10 for Since.
Depends on `exists_rat_lt_finset` (#7).

---

### ChronicleToCountermodel.lean (9 sorries) — FRAMEWORK COMPLETE

**Status**: 9 sorries. The overall wiring (`dd_countermodel_chronicle`) is complete and
correct. The sorry sites are all in proof obligations within the components.

**Mathematical correctness**: The architecture is sound:
- `extended_limit_f`: Correctly extends `limit_f` to all rationals using root MCS as default.
- `extended_limit_f_mcs`: Proved (case-split on domain membership).
- `chronicle_bfmcs`: The BFMCS structure is correctly defined. `modal_backward` is proved
  (uses `bx_modal_witness` and `box_stable_in_chronicle_fmcs`).
- `dd_countermodel_chronicle`: The final wiring theorem is correct given the components.

**Integration quality**: The connection from `dd_countermodel_chronicle` to `bx_completeness`
in Completeness.lean is correct and clean. The parametric representation theorem is correctly
invoked.

**Sorry #12 — `chronicle_fmcs.forward_G`** (line 192):

_Mathematical obligation_: `G(phi) in extended_limit_f(t)` and `t < t'` implies
`phi in extended_limit_f(t')`.

_Case analysis_:
- If t in limit_dom: `extended_limit_f(t) = limit_f(t)`. G(phi) in limit_f(t) means
  `G(phi) in f_n(t)` for some n. By g_content: `phi in g_content(f_n(t))`.
  At t' in limit_dom with t < t': `phi in limit_f(t') = f_m(t')`. Need the chronicle's
  g_content propagation between adjacent/non-adjacent domain points. The key missing piece
  is that the omega-chain's point assignments were made by Lindenbaum extension from g_content
  seeds, not that g_content propagates across ALL pairs. For points NOT in limit_dom at t':
  `extended_limit_f(t') = A` (root MCS). Need `phi in A`. This holds if `G(G(phi)) in A`
  (temp_4), i.e., if `G(phi) in g_content(A) = limit_f(0)`. But t could be any domain point,
  not just 0. This case requires showing that g_content propagates through the entire chain.
- If t not in limit_dom: `extended_limit_f(t) = A`. G(phi) in A means `phi in g_content(A)`.
  At any t' in limit_dom: `phi in f_{n0}(t')` where n0 witnesses t' in dom(n0). This holds
  if `g_content(A) subset f_{n0}(t')`. At step 0: `f_0(0) = A`, so `g_content(A) subset A`.
  For other domain points, they are inserted by Lindenbaum extension starting from
  `{eta} union g_content(f(x))` seeds. The g_content coherence requires knowing that
  g_content(A) propagates to all subsequent MCS insertions — which is true at step 0 (trivially)
  and at subsequent steps by `lemma_2_4` (which ensures `g_content(f(x)) subset C`).
  If `g_content(A) subset g_content(f(x))` for all domain x... this would follow from
  the g_content ordering being transitive (`lemma_2_5b`).

_Assessment_: This is a medium-difficulty proof requiring careful case analysis and use of
`lemma_2_5b` and the g_content coherence structure of the omega-chain. Approximately 50-80 lines.
The key lemma needed: "for any point x inserted by the omega-chain, `g_content(A) subset f(x)`".
This can be proved by induction on the insertion step.

**Sorry #13 — `chronicle_fmcs.backward_H`** (line 196): Mirror of #12 for H/h_content.

**Sorry #14 — `box_stable_in_chronicle_fmcs`** (line 234):

_Mathematical obligation_: `Box phi in (shifted_chronicle_fmcs N h_N s).mcs t ↔ Box phi in N`
for all t.

_Proof strategy_: This follows from the S5 properties:
- Forward: `Box phi in extended_limit_f(t-s)` → `Box phi in A`. Use `modal_4`:
  `Box phi → Box Box phi`. If Box phi in mcs(t), then `G(Box phi) in mcs(t)` (by TF axiom:
  `Box phi → G(Box phi)`). So by forward_G: `Box phi in mcs(t')` for all t' > t. Similarly
  backward by `H(Box phi)`. At t=0 (offset s): `Box phi in extended_limit_f(0) = A`.
- Backward: `Box phi in A` → `Box phi in extended_limit_f(t-s)`. Similar by G/H stability.

_Depends on_ #12 and #13 (forward_G and backward_H). Once those are proved, this should
be ~20 lines using `temporal_necessitation` for `Box phi → G(Box phi)` and the inversion.

**Sorries #15, #16 — `chronicle_bfmcs_restricted_tc`** (F and P resolution):

_Mathematical obligation_: Given `F(phi) in (shifted_chronicle_fmcs N h_N s).mcs t`,
show `∃ t' > t, phi in (shifted_chronicle_fmcs N h_N s).mcs t'`.

_Proof strategy_:
1. `F(phi) in extended_limit_f(t-s)` (unfolding shifted_chronicle_fmcs).
2. Case t-s in limit_dom: `F(phi) in limit_f(t-s)`. F(phi) = neg G neg phi.
   `neg G neg phi in limit_f(t-s)`. By MCS negation complete: `G neg phi not in limit_f(t-s)`.
   So `neg phi not in g_content(limit_f(t-s))`. Use `F_neg_of_G_not`-style argument.
   Actually: need `∃ s' > t-s, phi in limit_f(s')`. This uses `limit_satisfies_c5_weak`
   ONLY if we have `phi U phi = F(phi)` equivalence, or use `some_future` directly.
   Actually, `some_future phi = neg all_future neg phi`. We have `F(phi) in mcs(t-s)`.
   By BX10 reverse: F(phi) ↔ ⊤ U phi (BX12). So `top U phi in mcs(t-s)`.
   By `limit_satisfies_c5_weak` with xi=top, eta=phi: `∃ y > t-s in limit_dom, phi in limit_f(y)`.
3. Transfer: `phi in extended_limit_f(y)` and `phi in (shifted_chronicle_fmcs N h_N s).mcs (y+s)`.

_Depends on_: `limit_satisfies_c5_weak` (#10), BX12 (`F_until_equiv`).

_Difficulty_: Medium, ~30-50 lines per direction.

**Sorries #17, #18 — `chronicle_bfmcs_restricted_buc`** (backward Until/Since):

_Mathematical obligation_: Given a semantic witness pattern (t' > t with eta in mcs(t'), and
xi in mcs(r) for all r in (t,t')), derive `xi U eta in mcs(t)`.

_Proof strategy_: Use the `until_intro` axiom (if it exists in the BX system) or the BX
axiom BX6 (`absorb_until`) combined with the witness. Check for `until_intro` in BX axioms.

```
-- If eta in mcs(t') and xi in mcs(r) for all intermediate r, need xi U eta in mcs(t).
-- BX axiom structure suggests: until_intro would be xi ∧ G(xi ∨ eta) → xi U eta.
-- Actually: the canonical completeness proof typically uses the semantics directly:
-- "there exists t' > t with eta at t'" but "for ALL r in (t,t'), xi at r" →
-- by BX8 (until_join? or BX5 reverse?) get xi U eta at t.
```

The backward direction of Until coherence is typically the harder direction in canonical
completeness proofs. Check whether BX has an axiom directly supporting "if semantically
U(xi,eta) holds, then it's in the MCS". This is actually the BACKWARD direction of the
truth lemma, which requires the full coherence argument. In the RestrictedParametricTruthLemma,
backward U/S uses `h_buc : B.restricted_backward_until_since_coherent`. The content
of `restricted_backward_until_since_coherent` is exactly this obligation.

_Assessment_: This is a medium-hard proof. The key insight is that at t:
- `xi U eta not in mcs(t)` would give `neg(xi U eta) in mcs(t)`.
- By BX10: `neg F(eta) in mcs(t)` → `G(neg eta) in mcs(t)`.
- But `eta in mcs(t')` and `t < t'` means by forward_G: `neg eta in mcs(t')`. Contradiction.
So the backward direction can be proved by contradiction using the FMCS forward_G property.

More carefully: if `xi U eta not in mcs(t)`, need to derive contradiction. The BX system
provides `(neg(xi U eta)) → (neg(xi) ∧ neg(eta)) ∨ ...` via BX9 contrapositive. The
exact derivation depends on what BX provides for the negation of Until.

**Sorries #19, #20 — `chronicle_bfmcs_restricted_fuc`** (forward Until/Since):

_Mathematical obligation_: From `xi U eta in mcs(t)`, produce semantic witness.

_Proof strategy_: The most direct proof uses `limit_satisfies_c5_weak`:
1. `xi U eta in extended_limit_f(t-s)`.
2. By `limit_satisfies_c5_weak`: `∃ y > t-s in limit_dom, eta in limit_f(y)`.
3. Transfer to FMCS: set `t' = y + s`.

The guard condition (xi at intermediate points) requires the interval function `g` which
is NOT currently constructed. The guard condition in `restricted_forward_until_since_coherent`
needs: `∀ r in (t, t'), xi in mcs(r)`. This requires the chronicle's C5 full condition,
not just the weak version. Since `limit_satisfies_c5_weak` only provides the endpoint `y`,
the guard needs either:
(a) The full `limit_satisfies_c5` (with guard condition), which requires the interval
    function `g` to be constructed and C2/C3 to hold.
(b) A reformulation that avoids needing the guard at all intermediate points.

Looking at the `restricted_forward_until_since_coherent` definition, it likely quantifies
over the specific `xi` in the `Until` formula. The guard requirement may be satisfied
vacuously or via BX9 (which at any mcs between t and t' gives xi or eta, and if eta is
only at t', then xi must hold at intermediate MCS... but this is a semantic argument).

_Assessment_: This depends critically on whether the interval function `g` needs to be
constructed, or whether `limit_satisfies_c5_weak` + BX properties suffice. If the guard
condition is required, this is HIGH difficulty and may require completing the full chronicle
construction (interval DCS). If the guard can be derived from the FMCS structure without
the interval function, it is MEDIUM.

---

### Completeness.lean (0 sorries) — CORRECT

**Status**: No sorries. The rewiring is correct and clean.

`neg_consistent_of_not_derivable` is fully proved (handles both the L=[neg phi] and L=[]
cases via deduction theorem and double negation).

`bx_completeness` correctly chains: not derivable → consistent → Lindenbaum MCS M →
`dd_countermodel_chronicle M` → countermodel → contradiction with `h_valid`.

The `#print axioms` annotations at the end are useful for tracking sorry propagation.

---

### ParametricTruthLemma.lean (0 new sorries) — CONFIRMED FIXED

Phase 1 correctly eliminated the 2 sorry sites. The fix (using
`temporal_backward_G_with_fwd_F` and `temporal_backward_H_with_bwd_P` with strict
quantifiers) is the right approach for strict semantics. Confirmed sorry-free.

---

## Recommended Approach

### Priority 1: Easy Mathlib helpers (sorries #6, #7) — Est. 1-2 hours

Close `exists_rat_gt_finset` and `exists_rat_lt_finset` using `Finset.max'` and `Rat.lt_add_one`.
These are prerequisites for `eliminate_C5_counterexample` being fully sorry-free.

```lean
theorem exists_rat_gt_finset (S : Finset Rat) :
    ∃ q : Rat, (∀ s ∈ S, s < q) ∧ q ∉ S := by
  by_cases h : S = ∅
  · exact ⟨0, by simp [h], by simp [h]⟩
  · obtain h_ne := Finset.nonempty_of_ne_empty h
    let m := S.max' h_ne
    exact ⟨m + 1, fun s hs => lt_of_le_of_lt (S.le_max' s hs) (lt_add_one m),
           fun hq => absurd (S.le_max' (m+1) hq) (lt_add_one m).not_le⟩
```

### Priority 2: Countability enumeration (sorries #8, #9) — Est. 2-3 hours

Use `Rat.instCountable` + `Formula.instCountable` + product countability to build the
enumeration. The `PotentialCounterexample` type is definitionally isomorphic to
`Rat × Formula × Formula × Bool`, all of which are countable.

```lean
noncomputable def counterexample_enum : Nat → PotentialCounterexample :=
  let f := (Classical.choice (Countable.exists_surjective_nat
    (Rat × Formula × Formula × Bool)))
  fun n => let t := f n; ⟨t.1, t.2.1, t.2.2.1, t.2.2.2⟩

theorem counterexample_enum_surjective : ∀ pc, ∃ n, counterexample_enum n = pc := by
  intro ⟨x, xi, eta, dir⟩
  obtain ⟨n, hn⟩ := (Classical.choice (Countable.exists_surjective_nat _)) |>.surjective ⟨x, xi, eta, dir⟩
  exact ⟨n, by simp [counterexample_enum, hn]⟩
```

### Priority 3: limit_satisfies_c5_weak (sorries #10, #11) — Est. 4-6 hours

Follow the proof sketch in the phase results document:
1. Use `counterexample_enum_surjective` to find `k` where `enum(k) = ⟨x, xi, eta, true⟩`.
2. Let `n = max(n0, k)`.
3. Show `xi U eta in f_n(x)` by `omega_chain_f_agrees_le`.
4. Show `eliminate_potential_counterexample` at step `n` adds witness.
5. Extract `y` from the result and show `y in limit_dom` and `eta in limit_f(y)`.

The main subtlety: step 4 requires showing that the `by_cases h_actual` branch in
`eliminate_potential_counterexample` takes the "actual counterexample" branch. This requires
showing `no_witness` holds at step `n` (i.e., the witness does NOT already exist at step `n`).
If a witness already exists at step `n`, then `limit_satisfies_c5_weak` is already satisfied.
This case split is the main technical challenge.

### Priority 4: FMCS coherence (sorries #12, #13, #14) — Est. 6-8 hours

Prove `chronicle_fmcs.forward_G` first. Key lemma needed:

_"Auxiliary lemma: for any point x inserted into the omega-chain, g_content(A) subset f(x)"_

This can be proved by induction on the insertion step, using `lemma_2_4` which guarantees
`g_content(f(source)) subset f(new_point)`, combined with `lemma_2_5b` transitivity.

Once forward_G and backward_H are proved, `box_stable_in_chronicle_fmcs` follows from
the TF axiom `phi → G(P(phi))` (BX4) variant for Box: `Box phi → G(Box phi)`.

### Priority 5: Restricted coherence conditions (sorries #15-#20) — Est. 8-12 hours

The restricted temporal coherence (#15, #16) follows from `limit_satisfies_c5_weak` + BX12.
The forward Until/Since (#19, #20) requires deciding whether the guard condition needs the
interval function `g`. If the guard is not required by the `restricted_forward_until_since_coherent`
definition, this is ~20 lines per case.

The backward Until/Since (#17, #18) requires showing the implication from semantic witness
pattern to Until/Since membership. This uses a contradiction argument via BX10 + forward_G.

### Non-Priority: lemma_2_7 D2 cases (sorries #3, #4, #5)

These are mathematically hard and not currently on the critical path. Leave as sorry
with documentation. If needed for the full C5 guard condition, address after Priority 4-5.

---

## Evidence and Examples

### Proof structure for `exists_rat_gt_finset`

The Mathlib lemma `Finset.max'_lt_iff` and `Finset.mem_insert` are relevant:
- `Finset.max' S h_ne : Rat` exists and satisfies `∀ x ∈ S, x ≤ Finset.max' S h_ne`.
- `lt_add_one (Finset.max' S h_ne) : Finset.max' S h_ne < Finset.max' S h_ne + 1`.

### Key auxiliary lemma for forward_G

The `g_content` coherence along the omega-chain can be proved by induction:
- Base: `g_content(A) subset f_0(0) = A`. True since `G phi in A → phi in g_content(A) subset A`.
  Wait: `g_content(A) = {phi | G phi in A}`. Is `g_content(A) subset A`? Only if `G phi in A → phi in A`,
  which holds by MCS + `modal_t` axiom (`G phi → phi`). So yes, `g_content(A) subset A`.
- Step: new MCS `C` inserted by `lemma_2_4` satisfies `g_content(f(x)) subset C`. By induction
  and `lemma_2_5b`, `g_content(A) subset g_content(f(x)) subset C`. But this requires
  `G phi in A → G phi in f(x)` i.e. `G phi in f(x)` for domain x, which is the forward_G
  property itself. This is circular at the FMCS level.

The actual correct approach: prove an inductive invariant along the chain that
`∀ x in dom(n), g_content(f_0(0)) subset f_n(x)`, proved by induction on how x was inserted.

---

## Confidence Level

| Finding | Confidence |
|---------|-----------|
| Overall architecture is correct | High |
| ParametricTruthLemma fix is correct | High |
| Completeness.lean wiring is correct | High |
| 20 sorry sites correctly inventoried | High |
| `exists_rat_gt/lt_finset` are easy closes | High |
| Countability enumeration approach will work | High |
| `limit_satisfies_c5_weak` proof strategy | Medium |
| FMCS forward_G/backward_H proof strategy | Medium |
| `box_stable_in_chronicle_fmcs` proof strategy | Medium |
| Restricted coherence sorries are closeable | Medium |
| Lemma 2.7 D2 cases are genuinely hard | High |
| Lemma 2.7 D2 cases are not on critical path | Medium |
| `until_guard_consistent` is non-provable in BX | Medium |

The implementation represents substantial progress. The 7 "low and medium difficulty"
sorry sites on the critical path (sorries #6-16 excluding D2) are all closeable with
careful Lean proof work within the existing architecture. The 4 hard sorry sites
(#3-5, #1) are not currently blocking `bx_completeness` and can be addressed after
the critical-path sorries are resolved.
