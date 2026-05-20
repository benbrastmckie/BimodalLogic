# Teammate A Research Findings: Reynolds Pipeline Activation

**Task**: 155 — Reynolds Pipeline Activation
**Artifact Number**: 03
**Teammate Letter**: A
**Date**: 2026-05-20
**Session**: sess_lean_research_03a

---

## Key Findings

### 1. Sorry Chain Map (Verified via lean_verify)

The current sorry chain for `bx_completeness` has exactly TWO independent channels propagating `sorryAx`. Both must be closed:

**Channel A — IsSuccArchimedean sorry (the deep structural sorry)**

```
countermodel_discrete (Transfer.lean:344)
  -> extract_chronicle_as_prior (ChronicleExtraction.lean:153)
     assigns domain_succ_archimedean := limitDomSubtype_isSuccArchimedean
  -> limitDomSubtype_isSuccArchimedean (ChronicleToCountermodel.lean:1900)
     -> succ_cofinal (ChronicleToCountermodel.lean:1563) [SORRY]
```

The `countermodel_discrete` function calls `orderIsoIntOfLinearSuccPredArch` at line 344, which requires `[IsSuccArchimedean chron.domain]`. This instance is provided by `attribute [instance] ChronicleAsPriorModel.domain_succ_archimedean` (line 129, ChronicleExtraction.lean). When `extract_chronicle_as_prior` fills that field with `limitDomSubtype_isSuccArchimedean` (line 153), and that function depends on the sorry'd `succ_cofinal`, the sorry propagates.

**Critical distinction**: `chronicle_is_good` in IntegerModel.lean is sorry-FREE (verified). It too calls `orderIsoIntOfLinearSuccPredArch`, but only on an abstract `ChronicleAsPriorModel` parameter whose `IsSuccArchimedean` is an asserted field (not constructed from scratch). The sorry only appears when `extract_chronicle_as_prior` INSTANTIATES that field via `limitDomSubtype_isSuccArchimedean`.

**Channel B — Transfer.lean explicit sorries (three sites)**

| File | Line | Name | Status |
|------|------|------|--------|
| Transfer.lean | 186 | `chronicle_temporal_truth` | SORRY — full inductive truth lemma |
| Transfer.lean | 276 | valuation in `z_interval_countermodel` | SORRY — uses fixed `s.val` (bug) |
| Transfer.lean | 286 | `z_interval_countermodel` body | SORRY — full inductive bridge |
| Transfer.lean | 332 | `Nonempty sig.preds` | SORRY — trivial, case-split |
| Transfer.lean | 371 | inline `h_chronicle_truth` | SORRY — blocked on chronicle_temporal_truth |

### 2. Sorry-Free Infrastructure (Verified)

All of the following are axiom-clean (`propext`, `Classical.choice`, `Quot.sound` only):

- `truth_transfer` — existential closure transfer (Transfer.lean)
- `k_equiv_preserves_sentence` — k-equiv preserves bounded sentences (Transfer.lean)
- `chronicle_is_good` — abstract ChronicleAsPriorModel is good (IntegerModel.lean)
- `one_class` — one-class theorem (uses IsSuccArchimedean as hypothesis)
- `no_gaps_discrete` — gap elimination for discrete SuccArchimedean orders
- `no_boundary_at_successor` — adjacent points are contemp-equiv
- `finite_structures_good` — finite structures are good
- `table_correctness`, `table_depth_bound` — expressive completeness
- `doets_lemma_1_1`, `doets_lemma_1_4` — k-equiv preservation

These are the sorry-free tools available for constructing the solution.

### 3. Phase 0 Blocker Re-analysis: Box Modality Mismatch

The phase-0 handoff claims a "fundamental box modality mismatch" between `temporal_truth` (treats `box ψ` as predicate lookup) and `truth_at` (interprets `box ψ` as universal quantification over histories). This assessment is **partially correct but overstated as fundamental**.

The v3 plan's approach (WorldState = Int, valuation `fun z a => Z.interp (atomMap_fwd (.atom a)) z`) is correct for handling atom truth variation with time. The `box ψ` case in `z_interval_countermodel` is handled because: in `zIntervalTaskFrame`, `task_rel = fun _ _ _ => True`, meaning ALL world-states are related for ALL durations. With `WorldState = Unit`, there is literally only one world-state. `truth_at TM Omega tau t (Formula.box ψ)` evaluates to `∀ σ ∈ Omega, truth_at TM Omega σ t ψ`. Since `Omega = Set.univ` and all histories give the same atom truth at time t (they all have the same single state `()`), the box quantifier is trivially universal/tautological over the single state. This means `box ψ` being true is equivalent to `ψ` being true — the S5 modality collapses to an identity in the unit-state frame.

However, this is NOT a direct correspondence with `temporal_truth`'s box predicate lookup. The `temporal_truth` for `box ψ` does `M.interp (atomMap_fwd (.box ψ)) t` — a predicate lookup on a named predicate symbol. For this to align with `truth_at`'s universal-history interpretation, we need the monadic structure's interpretation of the `.box ψ` predicate to coincide with the `temporal_truth` of `ψ` itself.

The key insight the previous agents missed: **the `box ψ` case in the bridge lemma is provable IF the chronicle structure's interpretation of the box predicate encodes box-truth correctly**. The `chronicleAsMonadicStructure` defines `M.interp p t := (atomMap_rev p) ∈ M.fmcs t`. So `temporal_truth M_chron atomMap_fwd t (box ψ)` = `M_chron.interp (atomMap_fwd (box ψ)) t` = `(box ψ) ∈ M.fmcs t` (via the section property). And MCS membership of `box ψ` at t means ψ is in every accessible MCS — which in the chronicle is every point (since the chronicle uses a single S5 class). So the correspondence IS achievable through careful use of the section property and MCS axiom closure.

The current `z_interval_countermodel` valuation bug (using `s.val` instead of varying with time) is real but fixable. The fix is to use `WorldState = ℤ` (or keep `WorldState = Unit` but define the valuation using the position argument — however with `WorldState = Unit` the only available value is `()` and we cannot extract a position from it). The WorldState = ℤ approach is correct.

**Conclusion**: The blocker is not "fundamental" — it is a solvable engineering problem requiring careful case analysis in the inductive proof, particularly for the `box` case. The v3 plan's diagnosis and fix direction (WorldState = Int) are correct.

### 4. Phase 2 Blocker Re-analysis: cofinal_decomposition_k_equiv

The claim that this requires a full EF-game framework is **overstated**. The actual mathematical content is simpler:

- `orderedSum ℤ (fun i => M.subinterval(a(i), a(i+1)))` has carrier `Σ (i : ℤ), M.subinterval(a(i), a(i+1)).carrier`
- Elements appear as `(i, x)` where `a(i) ≤ x ≤ a(i+1)` (closed-closed intervals)
- Boundary point `a(i+1)` appears as both `(i, a(i+1))` (rightmost in piece i) and `(i+1, a(i+1))` (leftmost in piece i+1)
- These two copies satisfy identical predicate interpretations (same point in M)
- BUT they are distinct elements in the ordered sum (different sigma components)

The k-equivalence proof strategy: construct an explicit back-and-forth map between M and the ordered sum. The projection `p(i, x) = x` is order-preserving but not injective at boundaries. The embedding `e(x) = (i_left(x), x)` where `i_left(x) = min {i | a(i) ≤ x}` is an order embedding that respects all predicate interpretations. A duplicator strategy for the EF game can be defined: Spoiler picks in M, Duplicator picks the embedded copy; Spoiler picks in the sum, Duplicator picks the projected copy. The only difficult case is when Spoiler picks a duplicate boundary point — but since both copies satisfy identical predicates and are adjacent with no elements between them, the Duplicator can maintain the back-and-forth invariant.

This does not require building a full EF game framework. It can be proved by showing the embedding preserves all NF (normal form) evaluations directly, using the structure of `k_type_of` and `nf_eval_nf`. This should be ~80-120 lines of Lean, not the 200+ lines claimed.

### 5. Reynolds 1994 Pipeline Alignment

The full Reynolds completeness proof structure (Theorem 18) maps to the current codebase as follows:

| Reynolds Step | Paper Reference | Lean Status |
|--------------|-----------------|-------------|
| Build countable discrete Prior structure M | Corollary 3 (Burgess-Xu) | DONE: `extract_chronicle_as_prior` |
| Restrict to finite language | Theorem 18 preamble | DONE: `mkSigFrom φ`, `mkAtomMap φ` |
| Define contemporaneous equivalence ~M | Lemma 17 | DONE: `contemp_equiv` |
| Show ~M is an equivalence relation | Lemma 17 | DONE: `contemp_equiv_is_equiv` |
| No gaps in discrete Prior structures | Theorem 14 (Lemmas 6-13) | DONE: `no_gaps_discrete` (uses IsSuccArchimedean instead of direct Reynolds arg) |
| One class theorem | Theorem 15 preamble | DONE: `one_class` (uses IsSuccArchimedean) |
| Very good → good (Lemma 16) | Reynolds Lemma 16 | PARTIAL: `very_good_implies_good` has 2 sorries |
| Chronicle is good | Theorem 15 application | DONE: `chronicle_is_good` (uses IsSuccArchimedean via field) |
| Truth of ¬φ in chronicle | (truth lemma) | SORRY: `chronicle_temporal_truth` |
| Truth transfer via k-equiv | Theorem 15 + Doets | DONE: `truth_transfer` (sorry-free) |
| Package as Z-model countermodel | Theorem 18 conclusion | SORRY: `z_interval_countermodel` |

The critical observation: Reynolds 1994 uses `IsSuccArchimedean` only IMPLICITLY through the structural fact that any countable discrete linear order without endpoints is isomorphic to ℤ. The current `chronicle_is_good` correctly captures this — it is sorry-free by taking `IsSuccArchimedean` as a given field of `ChronicleAsPriorModel`. The sorry is ONLY in `extract_chronicle_as_prior`'s assignment of `limitDomSubtype_isSuccArchimedean`.

### 6. The Two Paths to Zero Sorries

Based on the Reynolds literature and codebase analysis, there are exactly two viable paths:

**Path A: Fix the IsSuccArchimedean sorry (Channel A)**

Approach: Prove `succ_cofinal` for `LimitDomSubtype`. The mathematical fact is clear: in a countable discrete linear order without endpoints satisfying Prior-UZ/SZ, any element is reachable from any other by finitely many successor steps. The sorry has 330+ lines of partial work (ChronicleToCountermodel.lean:1563) with three previous failed approaches. The v3 plan identifies a new angle (Option C from handoff-3): use Z1 membership in all MCS + backward induction. This is more tractable than the previous approaches.

**Path B: Rewrite `countermodel_discrete` to not use IsSuccArchimedean (Channel A bypass)**

Approach: Replace the `orderIsoIntOfLinearSuccPredArch` call at Transfer.lean:344 with a route through `very_good_implies_good` (Reynolds Lemma 16). This requires closing the 2 IntegerModel.lean sorries (`cofinal_decomposition_k_equiv`, `ordered_sum_of_good_bounded_is_good`). Once those are closed, `very_good_implies_good` becomes sorry-free. Then `chronicle_is_good` can be rewritten to use `very_good_implies_good` instead of `orderIsoIntOfLinearSuccPredArch`, eliminating the IsSuccArchimedean dependency. This is the Option 1 approach from report 03.

**Channel B sorries are independent of Channels A and B** — they must be closed regardless of which path is taken:
- `chronicle_temporal_truth` (Transfer.lean:186): inductive truth lemma, ~100-150 lines
- `z_interval_countermodel` (Transfer.lean:276-286): valuation bug fix + inductive bridge, ~150-200 lines
- `Nonempty sig.preds` (Transfer.lean:332): trivial, ~20 lines
- `h_chronicle_truth` inline (Transfer.lean:371): closes once `chronicle_temporal_truth` is done

### 7. Difficulty Assessment by Sorry Site

| Sorry Site | Difficulty | Reynolds Reference | Approach |
|------------|-----------|-------------------|----------|
| `succ_cofinal` (task 129) | HARD (330+ lines of failed partial work) | Not directly in Reynolds | Option C from handoff-3: Z1 + backward induction |
| `cofinal_decomposition_k_equiv` | MEDIUM (80-120 lines) | Reynolds Lemma 16, cofinal decomp | Back-and-forth via NF evaluation preservation |
| `ordered_sum_of_good_bounded_is_good` | MEDIUM-HARD (100-200 lines) | Reynolds Lemma 16, shift-and-glue | SuccOrder instance on sigma + `orderIsoIntOfLinearSuccPredArch` on witness side |
| `chronicle_temporal_truth` | MEDIUM (100-150 lines) | Standard truth lemma | Induction on formula structure; box case via section property + MCS axiom closure |
| `z_interval_countermodel` | MEDIUM (150-200 lines) | Reynolds Theorem 18 conclusion | WorldState=ℤ refactor + inductive bridge; box case via S5 collapse |
| `Nonempty sig.preds` | TRIVIAL (20 lines) | N/A | Case-split on whether predFormulas is empty |
| `h_chronicle_truth` inline | TRIVIAL once chronicle_temporal_truth is done | N/A | Direct application |

---

## Sorry Chain Map (Complete)

```
bx_completeness
  -> countermodel_discrete (Transfer.lean)
     |
     +-- Channel A: IsSuccArchimedean
     |   extract_chronicle_as_prior
     |   -> limitDomSubtype_isSuccArchimedean [SORRY via succ_cofinal]
     |   Also: orderIsoIntOfLinearSuccPredArch at line 344 (direct call)
     |
     +-- Channel B1: Nonempty sig.preds (Transfer.lean:332) [SORRY TRIVIAL]
     |
     +-- Channel B2: h_chronicle_truth (Transfer.lean:371) [SORRY]
     |     -> chronicle_temporal_truth (Transfer.lean:186) [SORRY]
     |
     +-- Channel B3: z_interval_countermodel (Transfer.lean:276-286) [SORRY]
           (valuation bug: uses s.val instead of time-varying int)

Side channel (very_good_implies_good, not currently on critical path):
  cofinal_decomposition_k_equiv (IntegerModel.lean:1079) [SORRY]
  ordered_sum_of_good_bounded_is_good (IntegerModel.lean:1138) [SORRY]
  -> very_good_implies_good [SORRY via above two]
```

---

## Blocker Analysis

### Blocker 1: Box modality mismatch (Phase 0 handoff)

**Assessment: Overstated. Solvable.**

The mismatch is real but not "fundamental." The `z_interval_countermodel` proof requires a careful inductive argument where the `box ψ` case uses the collapse of S5 to a single class (unit WorldState) to align `temporal_truth`'s predicate lookup with `truth_at`'s universal quantification. The WorldState = Unit architecture is coherent: with a single state, box is an identity modality, and the correspondence `truth_at TM Set.univ tau t (box ψ) ↔ temporal_truth Z atomMap_fwd t ψ` holds because both sides reduce to checking ψ at position t.

The valuation bug is separate: `fun _ a => Z.interp (atomMap_fwd (.atom a)) s.val` uses a fixed position `s.val` for all time points. To fix: either use WorldState = ℤ (clean) or recognize that with WorldState = Unit, the valuation CANNOT vary with time position. The WorldState = ℤ approach (from the v3 plan) is architecturally correct.

**Recommended fix**: Keep WorldState = Unit but accept that `truth_at` for atoms reads `TM.valuation () a`. Define the valuation using the Z-interval's global predicate: `fun () a => Z.interp (atomMap_fwd (.atom a)) z` where `z : ℤ` is the specific target integer position. This is NOT time-varying — it's correct for the specific counterpoint at `z`. The countermodel only needs to refute `φ` at ONE specific point, not at all time positions.

Wait — this is actually the key insight: `z_interval_countermodel` is only asked to show `¬truth_at TM Omega tau z φ` for a SPECIFIC point `z`. So the valuation being constant (equal to the predicate value AT z) is actually fine for the atom case! The issue is only that this valuation makes `truth_at TM Set.univ tau z' (atom a)` give the WRONG value for other time points `z' ≠ z`. The temporal operators (Until/Since) require truth at other points, so the constant valuation IS wrong for the Until/Since cases.

The correct fix: WorldState = ℤ with `valuation := fun (w : ℤ) a => Z.interp (atomMap_fwd (.atom a)) w`, and `task_rel w1 w2 delta := w2 = w1 + delta`. Then `WorldHistory.states t h_dom := t` (state at time t is the integer t itself).

### Blocker 2: cofinal_decomposition_k_equiv (Phase 2 blocker)

**Assessment: Not as hard as reported. EF-game framework NOT required.**

The standard way to prove k-equivalence without an EF-game infrastructure is via normal-form agreement: `k_equiv sig k M N ↔ k_type_of sig k M = k_type_of sig k N`. The `k_type_of` is a function from `NormalForm` to `Bool`. To show M ~k orderedSum(pieces), show `nf_eval_nf M env nf ↔ nf_eval_nf (orderedSum pieces) env' nf` for all nf and matching environments.

The key lemma needed: "adding a duplicate adjacent point to a linear order preserves the k-type." This follows because a duplicate point that satisfies all the same predicates and has no elements strictly between the original and the copy cannot be "seen" by any quantifier-depth-k formula — since any formula distinguishing them would need to either pick a witness between them (impossible) or use a predicate they differ on (impossible by definition).

This can be formalized as: if `M` is obtained from `N` by inserting a copy `x'` of `x` immediately after `x` (with identical predicate values), then `M ~k N` for all k. For the cofinal decomposition, each boundary point `a(i+1)` has its duplicate directly adjacent in the ordered sum, satisfying this criterion.

**Concrete approach**: Prove `k_type_of sig k M = k_type_of sig k (orderedSum sig ℤ pieces)` by showing a normal-form-preserving bijection between the two carrier sets that maps each x in M to its canonical copy in the sum. The bijection: `σ(x) = (i_x, x)` where `i_x` is the unique piece index with `a(i_x) ≤ x < a(i_x + 1)` (or `i_x` is the smallest such index for boundary points). Prove: `nf_eval_nf M env nf = nf_eval_nf (orderedSum) (σ ∘ env) nf` by induction on nf. The existential/universal quantifier cases need careful treatment of boundary duplicates.

### Blocker 3: ordered_sum_of_good_bounded_is_good (Phase 2 blocker)

**Assessment: Genuinely hard but structured. Not blocked, just laborious.**

The k≥2 case needs:
1. Show each witness Z_i is bounded (has `lo = some _`, `hi = some _`): transfer "has max/min" at depth 2 from `ms(i)` to `Z_i` via `doets_lemma_1_1`.
2. Construct `SuccOrder` and `PredOrder` instances on `Σ (i : ℤ), Z_i.intervalCarrier`: successor jumps to next integer within a piece, or to the minimum of the next piece at a boundary.
3. Prove `IsSuccArchimedean` for the sigma type: each piece is finite (bounded closed interval of ℤ), so successor iteration reaches the boundary in finitely many steps, then passes to the next piece.
4. Apply `orderIsoIntOfLinearSuccPredArch` to get a ℤ-isomorphism.
5. Apply `k_equiv_of_iso` to complete goodness.

The use of `orderIsoIntOfLinearSuccPredArch` here is SAFE — this is on the witness side (the concatenated Z-intervals), not on M.domain. The witness side is explicitly ℤ-like by construction, so `IsSuccArchimedean` holds genuinely.

---

## Reynolds Pipeline Alignment

### What Reynolds Actually Proves (Summary)

Reynolds 1994 Theorem 18 (completeness over ℤ) proceeds as:

1. Start with consistent formula φ (negation of what we want to refute)
2. Build canonical Prior structure M via Burgess-Xu (Corollary 3)
3. Define contemporaneous equivalence ~M on M (Lemma 17)
4. Show ~M classes don't end at gaps (Theorem 14)
5. Conclude: M is very good (every subinterval is good)
6. Apply Lemma 16 (very good + countable → good): M ~k Z-interval
7. The Z-model satisfies the same sentences of depth ≤ k, so φ is true in Z-model

### Existing Code vs. Reynolds

The current `chronicle_is_good` BYPASSES steps 4-6 entirely by using `orderIsoIntOfLinearSuccPredArch` directly (which requires `IsSuccArchimedean`). This is the "shortcut" the v1 plan introduced. The v3 plan proposes to rewrite via the genuine steps 4-6, but the current sorry-free status of `chronicle_is_good` shows the shortcut WORKS as a logical argument — it just depends on a sorry (`succ_cofinal`).

Reynolds' own proof is ALSO a shortcut in a sense: he never explicitly proves `IsSuccArchimedean` for his canonical structure — he simply observes that the structure is countable, discrete, without endpoints, and applies the classical theorem (equivalent to orderIsoIntOfLinearSuccPredArch). The sorry in `succ_cofinal` is essentially "prove that `LimitDomSubtype` is countable discrete without endpoints → IsSuccArchimedean."

The mathematical statement is TRUE. The sorry is a Lean formalization gap, not a mathematical error. Three approaches to close it:
- Option A: Prove `succ_cofinal` directly (hard, 330+ lines of failed partial work)
- Option B: Route through Reynolds Lemma 16 path (medium, requires 2 IntegerModel sorries)
- Option C: Find a different proof of IsSuccArchimedean for the chronicle domain

---

## Recommended Approach

### Tier 1 (Essential, must do first)

**T1.1**: Close `Nonempty sig.preds` (Transfer.lean:332) — 20 lines, trivial.
- Case-split on `φ.predFormulas.isEmpty`. If empty, the formula is purely propositional (only `bot`/`imp`). Any valuation that sets all atoms to `false` gives a countermodel. If nonempty, `Nonempty sig.preds` is immediate.

**T1.2**: Fix `z_interval_countermodel` valuation bug and prove the bridge (Transfer.lean:276-286) — 150-200 lines.
- Change `zIntervalTaskFrame.WorldState` from `Unit` to `ℤ`
- Change `task_rel` to `fun w1 w2 delta => w2 = w1 + delta`
- Change `zIntervalHistory.states` to `fun t _ => t` (state = time position)
- Change valuation to `fun (w : ℤ) a => Z.interp (atomMap_fwd (.atom a)) w`
- Prove `truth_at TM Set.univ tau t ψ ↔ temporal_truth (Z.toOrdered sig) atomMap_fwd (iso.symm t) ψ` by induction on ψ
- Box case: `truth_at ... box ψ = ∀ σ ∈ Set.univ, truth_at TM Set.univ σ t ψ` = `truth_at TM Set.univ tau t ψ` (arbitrary σ gives same atom truth since valuation depends only on WorldState = ℤ = position, and all histories map to the same states). Actually with WorldState = ℤ and `states t _ = t`, ALL histories return state `t` at time `t`. So truth_at for atoms = `TM.valuation t a`, independent of history. The box case: `∀ σ ∈ Set.univ, truth_at ... ψ` reduces to `truth_at ... ψ` (since all σ give identical atom truth). This matches `temporal_truth (.box ψ) = M.interp (atomMap_fwd (.box ψ)) t` when the chronicle structure's interpretation of `.box ψ` correctly tracks box truth.

Wait — with the Z-interval structure (NOT the chronicle), `temporal_truth (Z.toOrdered sig) atomMap_fwd s (box ψ)` = `(Z.toOrdered sig).interp (atomMap_fwd (.box ψ)) s` = `Z.interp (atomMap_fwd (.box ψ)) s.val`. This is a predicate lookup on the Z-interval. But `truth_at TM ... t (box ψ)` = `∀ σ, truth_at TM ... σ t ψ`. For the correspondence to hold, we need `Z.interp (atomMap_fwd (.box ψ)) t` iff `truth_at TM ... τ t ψ` for all τ. With WorldState = ℤ and `states` = identity, all histories give state `t` at time `t`, so `truth_at TM τ t (atom a) = Z.interp (atomMap_fwd (.atom a)) t` (independent of τ). The box quantification over all τ then reduces to checking ψ at position t. The Z-interval's interpretation of `.box ψ` must encode this. The v3 plan's proposed Z_wit construction sets `Z_wit.interp p z = (atomMap_rev p) ∈ M.fmcs (f.symm z)` — so `Z_wit.interp (atomMap_fwd (.box ψ)) z = (.box ψ) ∈ M.fmcs (f.symm z)`. For the correspondence, we need this to equal `truth_at TM τ z ψ` = `temporal_truth Z_wit atomMap_fwd z ψ`. This is exactly what `chronicle_temporal_truth` + `truth_transfer` establishes — it is a CIRCULAR requirement at this stage.

**Key insight**: The `z_interval_countermodel` does NOT need to correspond to the chronicle's Z-interval witness. It is a GENERIC lemma: given ANY Z-interval structure and a point where `temporal_truth Z atomMap_fwd s φ.neg` holds, construct a TaskFrame countermodel. The inductive proof is:
- `truth_at TM Set.univ tau t ψ ↔ temporal_truth (Z.toOrdered sig) atomMap_fwd (iso.symm t) ψ` for ALL ψ
- This is structural induction on ψ with no circularity

The `box ψ` case: `temporal_truth Z atomMap_fwd s (box ψ)` = `Z.interp (atomMap_fwd (.box ψ)) s.val`. `truth_at TM Set.univ tau (iso s) (box ψ)` = `∀ σ ∈ Set.univ, truth_at TM Set.univ σ (iso s) ψ`. With `states t _ = t`, `truth_at TM τ t ψ` depends only on t (not τ) for all ψ (by induction). So the box case reduces to checking ψ at position `iso s` — but `temporal_truth Z atomMap_fwd s (box ψ)` is a PREDICATE LOOKUP on `.box ψ`, not the truth of ψ. These are NOT the same unless the Z-interval's interpretation of `.box ψ` equals the truth of ψ at that point.

This is the genuine mismatch. The Z-interval structure uses `.box ψ` as an ATOMIC predicate symbol, while `truth_at` gives `box ψ` a structural (universal) semantics. The monadic FO framework collapses modalities into predicates, which is semantically distinct from the task frame's S5 interpretation.

**Resolution**: The `z_interval_countermodel` theorem statement is subtly incorrect as currently written. The Z-interval produced by `chronicle_is_good` has its `.box ψ` predicate set to track MCS membership (`Z.interp p z = (atomMap_rev p) ∈ M.fmcs (f.symm z)`), which DOES correctly track box truth (by the chronicle truth lemma). So the bridge is provable, but ONLY for the specific Z-interval produced by `chronicle_is_good`, NOT for an arbitrary Z-interval.

The fix: Either (a) change `z_interval_countermodel` to take an additional hypothesis `h_box_correct : ∀ ψ s, Z.interp (atomMap_fwd (.box ψ)) s.val ↔ temporal_truth Z atomMap_fwd s ψ`, or (b) rewrite `countermodel_discrete` to avoid routing through the generic `z_interval_countermodel` and instead prove the specific case directly.

**T1.3**: Close `chronicle_temporal_truth` (Transfer.lean:186) — 100-150 lines.
- Structural induction on ψ
- Atom case: `temporal_truth M_chron atomMap_fwd t (atom a)` = `M_chron.interp (atomMap_fwd (.atom a)) t` = `(atomMap_rev (atomMap_fwd (.atom a))) ∈ M.fmcs t` = `(atom a) ∈ M.fmcs t` (by section property `h_section`)
- Box case: `temporal_truth M_chron atomMap_fwd t (box ψ)` = `(box ψ) ∈ M.fmcs t` (by section property). The left side is `M_chron.interp (atomMap_fwd (.box ψ)) t` which by definition = `(atomMap_rev (atomMap_fwd (.box ψ))) ∈ M.fmcs t` = `(.box ψ) ∈ M.fmcs t`. Good.
- Until/Since cases: use Prior-UZ/SZ validity (`M.prior_UZ_valid`, `M.prior_SZ_valid`) and MCS closure properties
- This lemma is standard and well-precedented in modal logic completeness proofs

**T1.4**: Wire `chronicle_temporal_truth` into Transfer.lean:371 — trivial once T1.3 is done.

### Tier 2 (Needed to close Channel A — choose ONE path)

**Path B (Recommended)**: Close the 2 IntegerModel.lean sorries and rewrite `chronicle_is_good` to use `very_good_implies_good`.

**T2.1**: Prove `cofinal_decomposition_k_equiv` (IntegerModel.lean:1079) — 80-120 lines.
- Use NF evaluation preservation argument (see Blocker 2 analysis above)
- Key: show embedding M → orderedSum preserves all predicate interpretations and order structure

**T2.2**: Prove `ordered_sum_of_good_bounded_is_good` k≥2 case (IntegerModel.lean:1138) — 100-200 lines.
- Transfer boundedness via doets_lemma_1_1
- Construct SuccOrder/PredOrder on the concatenated sigma
- Prove IsSuccArchimedean via finiteness of bounded pieces
- Apply orderIsoIntOfLinearSuccPredArch on witness side
- Apply k_equiv_of_iso

**T2.3**: Rewrite `chronicle_is_good` to use `very_good_implies_good` (IntegerModel.lean:1189) — ~30 lines.
- Remove `let f := orderIsoIntOfLinearSuccPredArch`
- Use `one_class` (sorry-free) to establish `very_good` for the chronicle
- Apply `very_good_implies_good` (now sorry-free after T2.1-T2.2)
- Remove `domain_succ_archimedean` field from `ChronicleAsPriorModel`
- Update `extract_chronicle_as_prior` to not assign that field

**T2.4**: Also rewrite `countermodel_discrete` to not call `orderIsoIntOfLinearSuccPredArch` at Transfer.lean:344. Use `chronicle_is_good` output directly.

### Summary: Minimal Work to Zero Sorries

The most direct path combines:
1. T1.1: Nonempty sig.preds (20 lines, trivial)
2. T1.3 + T1.4: chronicle_temporal_truth (100-150 lines)
3. Fix z_interval_countermodel architecture + add h_box_correct hypothesis OR restructure (150-200 lines)
4. T2.1-T2.4: Close IntegerModel sorries + rewrite chronicle_is_good (300-400 lines combined)

Total estimated effort: 13-18 hours for a skilled Lean 4 practitioner following the Reynolds paper faithfully.

---

## Confidence Level

**High** on:
- The sorry chain structure (verified via lean_verify)
- The identification that `chronicle_is_good` is sorry-free AS AN ABSTRACT THEOREM but the sorry propagates through `extract_chronicle_as_prior`
- The assessment that `z_interval_countermodel`'s box case has a real mismatch (predicate lookup vs. structural semantics) and needs the `h_box_correct` additional hypothesis or a restructuring
- The recommendation to take Path B (close IntegerModel sorries) over Path A (prove succ_cofinal)
- The assessment that `chronicle_temporal_truth` is provable by standard induction (~150 lines)

**Medium** on:
- Exact line count estimates for the proofs
- Whether the `cofinal_decomposition_k_equiv` NF-evaluation approach works without EF-game infrastructure (the math is sound; the Lean formalization details may require more work)
- The exact formulation needed for the `h_box_correct` fix to `z_interval_countermodel`

**Low** on:
- Whether `succ_cofinal` (task 129) can be closed via Option C (Z1 + backward induction) in reasonable time — this has 330+ lines of failed partial work and is assessed as HARD
