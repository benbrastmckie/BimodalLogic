# Teammate B Findings: Infrastructure Inventory and Implementation Path

**Task**: 155 — Reynolds Pipeline Activation
**Teammate**: B (Infrastructure Mapping)
**Date**: 2026-05-20
**Session**: sess_1779290650_45e3c8_B

---

## Key Findings

- `chronicle_is_good` is SORRY-FREE and uses `orderIsoIntOfLinearSuccPredArch` directly. The Reynolds Lemma 16 path (`very_good_implies_good`) is NOT on the critical path for `countermodel_discrete`.
- There are exactly 4 sorry sites on the critical path: `succ_cofinal` (deep upstream), `Nonempty sig.preds` (trivial), `chronicle_temporal_truth` (medium), and `z_interval_countermodel` (medium-high with a known architecture bug).
- The `z_interval_countermodel` sorry has a valuation bug: `TM.valuation` uses a fixed witness point `s.val` for ALL time steps. This is architecturally incorrect. Fix: make `WorldState = Int` so the valuation can vary with time.
- `countermodel_dense` and `dd_countermodel_chronicle_mixed_sorry` are BOTH sorry-free. The ONLY remaining sorry source in `bx_completeness` is the discrete case via `countermodel_discrete`.
- The two IntegerModel.lean sorries (`cofinal_decomposition_k_equiv`, `ordered_sum_of_good_bounded_is_good`) are NOT on the critical path — they feed into `very_good_implies_good` which is bypassed by `chronicle_is_good`.
- The most architecturally elegant path to zero sorries requires either (A) proving `succ_cofinal` or (B) removing `IsSuccArchimedean` from `ChronicleAsPriorModel` and routing through the Reynolds Lemma 16 path (which then requires closing the 2 IntegerModel sorries).

---

## Sorry-Free Infrastructure Inventory

Verified via `lean_verify` (no `sorryAx` in axiom list):

| Theorem | File | Verified Axioms |
|---------|------|-----------------|
| `chronicle_is_good` | IntegerModel.lean | propext, Classical.choice, Quot.sound |
| `finite_structures_good` | IntegerModel.lean | propext, Classical.choice, Quot.sound |
| `k_equiv_of_iso` | IntegerModel.lean | propext, Classical.choice, Quot.sound |
| `contemp_equiv_is_equiv` | IntegerModel.lean | propext, Classical.choice, Quot.sound |
| `one_class` | IntegerModel.lean | propext, Classical.choice, Quot.sound |
| `no_gaps_discrete` | IntegerModel.lean | propext, Classical.choice, Quot.sound |
| `no_boundary_at_successor` | IntegerModel.lean | propext, Classical.choice, Quot.sound |
| `good_of_split_at_succ` | IntegerModel.lean | propext, Classical.choice, Quot.sound |
| `good_one` | IntegerModel.lean | propext, Classical.choice, Quot.sound |
| `truth_transfer` | Transfer.lean | propext, Classical.choice, Quot.sound |
| `k_equiv_preserves_sentence` | Transfer.lean | propext, Classical.choice, Quot.sound |
| `table_correctness` | Table.lean | propext, Classical.choice, Quot.sound |
| `doets_lemma_1_1` | NormalForm.lean | propext, Classical.choice, Quot.sound |
| `doets_lemma_1_4` | OrderedSum.lean | propext, Classical.choice, Quot.sound |
| `chronicleAsMonadicStructure_succ_archimedean` | NEquivalence.lean | propext, Classical.choice, Quot.sound |
| `separation_theorem_int` | Separation/SeparationThm.lean | (no axioms at all) |
| `countermodel_dense` | BXCanonical/Chronicle/ChronicleToCountermodel.lean | propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound |
| `dd_countermodel_chronicle_mixed_sorry` | BXCanonical/Chronicle/ChronicleToCountermodel.lean | propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound |

Theorems WITH sorry (sorryAx present):

| Theorem | File | Sorry Source |
|---------|------|-------------|
| `succ_cofinal` | ChronicleToCountermodel.lean:1563 | Leaf sorry (genuine gap) |
| `limitDomSubtype_isSuccArchimedean` | ChronicleToCountermodel.lean:1900 | Inherits from `succ_cofinal` |
| `extract_chronicle_as_prior` | ChronicleExtraction.lean:144 | Inherits from `limitDomSubtype_isSuccArchimedean` |
| `chronicle_temporal_truth` | Transfer.lean:186 | Leaf sorry (needs proof) |
| `z_interval_countermodel` | Transfer.lean:258 | Leaf sorry (needs proof + bug fix) |
| `countermodel_discrete` | Transfer.lean:312 | Aggregates all 4 channel sorries above |
| `very_good_implies_good` | IntegerModel.lean:1154 | Inherits `cofinal_decomposition_k_equiv` + `ordered_sum_of_good_bounded_is_good` |
| `bx_completeness` | BXCanonical/Completeness.lean | Inherits from `countermodel_discrete` |

---

## Reynolds Pipeline Step-by-Step Mapping

Reynolds 1994 Theorem 18 (Weak Completeness) proof structure:

### Step 1: Burgess-Xu Corollary 3 — Countable Discrete Prior Structure
**Reynolds**: From a consistent formula, get a countable discrete structure M_0 without endpoints where Prior-UZ/SZ hold everywhere.
**Lean**: `extract_chronicle_as_prior` → `ChronicleAsPriorModel`. PARTIALLY SORRY: uses `limitDomSubtype_isSuccArchimedean` which has `succ_cofinal` sorry. The structure is correct, the sorry is only in the `IsSuccArchimedean` field.

### Step 2: Standard Translation (Table)
**Reynolds**: Every temporal formula has a monadic FO equivalent (the "table").
**Lean**: `table` + `table_correctness` in Table.lean. SORRY-FREE.

### Step 3: Expressive Completeness (Theorem 5)
**Reynolds**: {U,S} is expressively complete over Prior structures.
**Lean**: `separation_theorem_int` in Separation/SeparationThm.lean. SORRY-FREE (no axioms).

### Step 4: Good/Very Good Definitions (Leading to Theorem 15)
**Reynolds**: Define "good" (k-equiv to Z-interval) and "very good" (all subintervals good).
**Lean**: `good`, `very_good` in IntegerModel.lean. Definitions are SORRY-FREE.

### Step 5: Theorem 15 — Chronicle is Good
**Reynolds**: Countable discrete Prior structure is good (k-equiv to Z-interval).
**Lean**: `chronicle_is_good` in IntegerModel.lean. SORRY-FREE. Uses `orderIsoIntOfLinearSuccPredArch` directly (which requires `IsSuccArchimedean` from the chronicle — this is the sorry dependency, but only if accessed via `extract_chronicle_as_prior`).

**CRITICAL INSIGHT**: `chronicle_is_good` in IntegerModel.lean takes a `ChronicleAsPriorModel` struct and uses `M.domain_succ_archimedean` field directly. Since `ChronicleAsPriorModel.domain_succ_archimedean` is populated from `limitDomSubtype_isSuccArchimedean` (which has the sorry), `chronicle_is_good` itself is sorry-free, but calling it with an `extract_chronicle_as_prior`-produced model propagates the sorry.

### Step 6: k-Equivalence Preserves Sentences (Doets Lemma 1.1)
**Reynolds**: Structures with same k-type satisfy same depth-≤k sentences.
**Lean**: `doets_lemma_1_1` + `k_equiv_preserves_sentence`. SORRY-FREE.

### Step 7: Truth Transfer
**Reynolds**: If ψ true somewhere in M and M ≡_k N, then ψ true somewhere in N (via existential closure).
**Lean**: `truth_transfer` in Transfer.lean. SORRY-FREE.

### Step 8: Chronicle Truth Lemma (connecting MCS to temporal_truth)
**Reynolds**: The truth lemma — formula membership in MCS corresponds to temporal truth in the canonical model.
**Lean**: `chronicle_temporal_truth` in Transfer.lean:178. SORRY (leaf, needs proof by induction on formula).

### Step 9: Z-Interval to TaskFrame Int Bridge
**Reynolds**: The k-equivalent Z-interval structure provides the integer-flow countermodel.
**Lean**: `z_interval_countermodel` in Transfer.lean:258. SORRY (leaf, has architecture bug).

### Reynolds Lemma 16 — Very Good Implies Good (NOT on critical path)
**Reynolds**: If M is countable, without endpoints, and very good, then M is good.
**Lean**: `very_good_implies_good` in IntegerModel.lean:1154. SORRY (inherits from `cofinal_decomposition_k_equiv` and `ordered_sum_of_good_bounded_is_good`). NOT USED by `countermodel_discrete`.

---

## Sorry Sites: Full Analysis

### Sorry 1: `succ_cofinal` (ChronicleToCountermodel.lean:1563) — DEEP, HARD

**Mathematical content**: In a countable discrete linear order where every point has an immediate successor, the orbit of `succ`-iteration from any point `a` is cofinal below any `b > a`.

**Why it's hard**: The proof requires ruling out a "gap" scenario where the succ-orbit converges to a limit `L < b` with a descending pred-chain above `L`. Three approaches have been tried and all fail in the "constant-MCS case" (all limit_dom points have identical MCS labels). The gap scenario is consistent with all temporal axioms under strict semantics in this degenerate case.

**What's available**: ~330 lines of partial proof infrastructure including backward_G, backward_F, backward_P lemmas, orbit_below_L, pred-chain analysis. The sorry is at line 1892 after all this infrastructure.

**Bypass route**: Remove `IsSuccArchimedean` from `ChronicleAsPriorModel` and route through the Reynolds Lemma 16 path (`very_good_implies_good`). This requires closing the 2 IntegerModel.lean sorries instead.

### Sorry 2: `Nonempty sig.preds` (Transfer.lean:332) — TRIVIAL

**Mathematical content**: The signature built from formula φ (whose predicate symbols are `predFormulas φ`) is nonempty.

**Why it matters**: `atomMap_fwd` needs `Classical.arbitrary sig.preds` as a fallback for formulas not in `predFormulas φ`. This requires `Nonempty sig.preds`.

**Fix**: Case split on whether `φ.predFormulas` is empty. If empty, φ has no atoms or box-subformulas — it is purely propositional (bot/imp). In this case, construct a direct propositional countermodel (e.g., the trivially false model). If nonempty, `Nonempty sig.preds` follows immediately.

**Effort**: 1–2 hours.

### Sorry 3: `chronicle_temporal_truth` (Transfer.lean:186) — MEDIUM

**Mathematical content**: `temporal_truth` on the chronicle-as-monadic-structure (where `interp p x = atomMap_rev p ∈ M.fmcs x`) agrees with MCS membership, for all subformulas of the root.

**Key ingredients needed**:
- **Atom case**: `temporal_truth M_chron atomMap_fwd t (atom a) ↔ (atom a) ∈ M.fmcs t`. Follows from `M_chron.interp (atomMap_fwd (atom a)) t = (atomMap_rev (atomMap_fwd (atom a))) ∈ M.fmcs t = (atom a) ∈ M.fmcs t` using the section property `h_section`.
- **Box case**: `temporal_truth M_chron atomMap_fwd t (box ψ) ↔ (box ψ) ∈ M.fmcs t`. Same argument with `atomMap_fwd (box ψ)`.
- **Bot case**: `temporal_truth M_chron atomMap_fwd t bot ↔ bot ∈ M.fmcs t`. Since `bot ∉ A` for consistent MCS, this reduces to `False ↔ False`.
- **Imp case**: Standard MCS properties (implication_property, negation_complete).
- **Until case**: Requires Prior-UZ validity (`M.prior_UZ_valid`). The argument: if `F(ψ) ∈ fmcs t`, then by Prior-UZ, `U(ψ, ¬ψ) ∈ fmcs t`, which by MCS-coherence gives a witness point `s > t` with `ψ ∈ fmcs s` and `¬ψ ∈ fmcs r` for all `t < r < s`.
- **Since case**: Symmetric, uses Prior-SZ.

**Challenge**: The Until/Since cases require careful use of the chronicle construction's resolution lemmas (`limit_F_resolution`, `limit_P_resolution`, `limit_satisfies_c5_strong`). These are buried in ChronicleToCountermodel.lean and may need to be re-expressed in terms of the `ChronicleAsPriorModel` abstraction.

**Effort**: 4–6 hours.

### Sorry 4: `z_interval_countermodel` (Transfer.lean:258-286) — MEDIUM-HIGH

**Mathematical content**: Given a Z-interval structure with unbounded carrier where `temporal_truth Z atomMap_fwd s φ.neg`, construct a `TaskFrame Int` countermodel where `truth_at TM Omega τ t φ` is false.

**The architecture bug**: The current valuation is:
```lean
let TM : TaskModel zIntervalTaskFrame :=
  { valuation := fun _ a => Z.interp (atomMap_fwd (.atom a)) s.val }
```
This uses the fixed witness point `s.val` for ALL time steps. Since `TaskModel.valuation : WorldState → Atom → Prop` and `WorldState = Unit`, there is only one state, and the valuation CANNOT vary with time. For atoms, `truth_at TM Omega τ t (atom a)` needs `Z.interp (atomMap_fwd (atom a)) t.val` (varying with `t`), not a constant.

**The fix**: Change `WorldState = ℤ` in `zIntervalTaskFrame`. Then:
```lean
noncomputable def zIntervalTaskFrame : TaskFrame ℤ where
  WorldState := ℤ
  task_rel := fun w1 w2 delta => w2 = w1 + delta
  nullity_identity := fun w u => ...
  ...

noncomputable def zIntervalHistory : WorldHistory zIntervalTaskFrame where
  domain := fun _ => True
  states := fun t _ => t  -- WorldState = ℤ, state at time t is t itself
  ...
```

Then the valuation varies correctly:
```lean
let TM : TaskModel zIntervalTaskFrame :=
  { valuation := fun (z : ℤ) a => Z.interp (atomMap_fwd (.atom a)) z }
```

**The bridge correspondence**: With this fix, the inductive truth correspondence becomes:
```
truth_at TM Set.univ zIntervalHistory t φ ↔ temporal_truth (Z.toOrdered sig) atomMap_fwd ⟨t, trivial, trivial⟩ φ
```

Proof by induction on φ:
- **Atom**: `truth_at` checks `∃ (ht : τ.domain t), TM.valuation (τ.states t ht) a`. Since `domain = fun _ => True`, `ht = trivial`, and `states t _ = t`, so `valuation t a = Z.interp (atomMap_fwd (.atom a)) t`. Matches `temporal_truth` atom case.
- **Bot**: Both false.
- **Imp**: Both material conditional.
- **Box**: `truth_at` is `∀ σ ∈ Set.univ, truth_at TM Set.univ σ t (box φ)`. With `Set.univ` and `WorldState = ℤ`, all histories agree on box truth since `TM.valuation` doesn't depend on the history. The `temporal_truth` for box is `Z.interp (atomMap_fwd (.box ψ)) t.val`, which by the valuation corresponds to `TM.valuation t (.box ψ)` — but `valuation` is defined for atoms, not box-formulas. **This is the remaining conceptual gap**: how box formulas (treated as predicates in `temporal_truth`) correspond to the universal quantification in `truth_at`.
- **Until/Since**: Both use the same linear order on ℤ, so they correspond directly.

**The box case challenge**: `temporal_truth` treats `box ψ` as a predicate lookup: `M.interp (atomMap (.box ψ)) t`. The valuation in `TaskModel` is `Atom → Prop`, not `Formula → Prop`. Box formulas are NOT atoms in the `TaskFrame`/`TaskModel` sense.

This is the fundamental mismatch described in the Phase 0 handoff. The `zIntervalTaskFrame` with `WorldState = ℤ` fixes the atom case but does NOT fix the box case, because:
- `temporal_truth` treats `box ψ` as a predicate (atomic lookup in the Z-interval)
- `truth_at` interprets `box ψ` as `∀ σ ∈ Omega, truth_at TM Omega σ t ψ` (universal quantification over histories)

**Resolution for the box case**: Restrict `Omega` to a specific set of histories that are "in the same S5 class" (i.e., all agree on `box`-subformula truth at all times). Since the chronicle's box-closure is a consequence of the axiom `□φ → φ` (Modal T) and the S5 structure, all MCS-coherent histories in the chronicle model satisfy the same box-formulas everywhere. The key insight: in the discrete bimodal setting, the `task_rel` on `zIntervalTaskFrame` relates states `w1, w2, delta` by `w2 = w1 + delta`. A history satisfies `box ψ` at t iff in ALL histories in Omega, `ψ` holds at t. If Omega is taken to be all histories with the same predicates as the Z-interval, then box truth reduces to the Z-interval's predicate for `box ψ`.

**Concretely**: Define Omega as the singleton `{zIntervalHistory}`. Then `truth_at TM {zIntervalHistory} zIntervalHistory t (box ψ) = truth_at TM {zIntervalHistory} zIntervalHistory t ψ` (since the only history in Omega is the current one). Now `box ψ` and `ψ` have the same truth, but that is NOT what `temporal_truth` says (which has `box ψ` as a predicate lookup, independent of `ψ`'s truth).

**Alternative**: Use `Omega = Set.univ` but arrange `TM.valuation` to be constant across histories (since `WorldState = ℤ` does not depend on which history is active). Then `∀ σ ∈ Set.univ, truth_at TM Set.univ σ t ψ` holds for box-subformulas iff every shifted history satisfies `ψ` at `t`. This requires that box-subformula truth is "shift-invariant" in the Z-interval — which it is, since the Z-interval's interp for `box ψ` does not depend on the history.

The cleanest resolution requires proving: for box-subformulas of φ, the Z-interval's predicate `Z.interp (atomMap_fwd (box ψ)) t` equals `∀ t', temporal_truth Z atomMap_fwd ⟨t', _⟩ ψ`. This is a semantic content claim about the Z-interval that needs to be established from the chronicle's MCS properties (specifically that `□ψ ∈ fmcs t` iff `ψ ∈ fmcs t'` for all `t'` in the same S5-class — which in the chronicle is the entire domain).

**Effort**: 5–8 hours.

---

## Missing Pieces (Summary)

To achieve zero sorries in `bx_completeness`, ALL of the following must be completed:

### Critical Path (in dependency order)

1. **`succ_cofinal`** OR bypass via `very_good_implies_good` route:
   - Option A: Prove `succ_cofinal` — has 3 failed approaches; likely requires construction-level argument.
   - Option B: Remove `IsSuccArchimedean` from `ChronicleAsPriorModel` + close 2 IntegerModel sorries.
   - Option C: Prove `IsSuccArchimedean` for the chronicle domain using `separation_theorem_int` (expressive completeness now available sorry-free).

2. **`Nonempty sig.preds`** (Transfer.lean:332): Handle empty `predFormulas` case separately.

3. **`chronicle_temporal_truth`** (Transfer.lean:186): Inductive proof over formula structure.

4. **`z_interval_countermodel`** (Transfer.lean:258): Architecture fix (`WorldState = ℤ`) + inductive truth correspondence proof + box case resolution.

### Non-Critical Path (for completeness of Reynolds pipeline)

5. **`cofinal_decomposition_k_equiv`** (IntegerModel.lean:1079): Needed only if bypassing `succ_cofinal` via Option B above.
6. **`ordered_sum_of_good_bounded_is_good`** (IntegerModel.lean:1138): Needed only if bypassing via Option B.
7. **`countermodel_discrete_enriched`** (Completeness.lean:225): Trivial wrapper once (4) is done.

---

## Reynolds Pipeline Architecture: The Real Picture

The existing codebase has a two-track architecture for `chronicle_is_good`:

**Track A (Current — uses IsSuccArchimedean directly)**:
```
ChronicleAsPriorModel.domain_succ_archimedean [SORRY via succ_cofinal]
  -> orderIsoIntOfLinearSuccPredArch : M.domain ≃o ℤ
  -> chronicle_is_good (uses the iso directly, k_equiv_of_iso)
```

**Track B (Reynolds Lemma 16 path — bypasses IsSuccArchimedean)**:
```
very_good_implies_good [SORRY: cofinal_decomposition + ordered_sum]
  -> chronicle_is_good would not need IsSuccArchimedean
```

Track A is currently used. It is shorter but requires `succ_cofinal`. Track B is longer but is the "mathematically elegant" Reynolds approach. Track B currently has 2 sorries in IntegerModel.lean.

The user directive says "the mathematically elegant and correct approach is easier to implement than a collection of hacks." Track B (Reynolds Lemma 16) IS the correct approach, but both tracks need substantial work. The question is whether closing `cofinal_decomposition_k_equiv` + `ordered_sum_of_good_bounded_is_good` is easier than proving `succ_cofinal`.

---

## Implementation Path

### Recommended Order

**Phase 1: Fix the architecture (no sorry closed, but unblocks phases 2-4)**
- Rewrite `zIntervalTaskFrame` with `WorldState = ℤ`
- Rewrite `zIntervalHistory` with `states t _ = t`
- Check that `zIntervalOmega_shiftClosed` still holds
- Estimated effort: 1 hour

**Phase 2: Close `Nonempty sig.preds` (Transfer.lean:332)**
- Add case split: if `predFormulas φ = ∅` then φ is purely propositional; construct a trivial countermodel. Otherwise `predFormulas φ` is nonempty.
- Estimated effort: 1–2 hours

**Phase 3: Prove `chronicle_temporal_truth` (Transfer.lean:178)**
- Structural induction on formula. Atom and Box cases use the section property. Bot/Imp use MCS properties.
- Until/Since cases require the chronicle's resolution lemmas. These need to be extracted from `ChronicleAsPriorModel` fields (the chronicle model has `prior_UZ_valid` and `prior_SZ_valid` as explicit fields).
- Key sub-lemma needed: "if `F(ψ) ∈ fmcs t` then there exists `s > t` with `ψ ∈ fmcs s` and `¬ψ ∈ fmcs r` for all intermediates `r`." This follows from Prior-UZ + the chronicle's MCS chain properties.
- Estimated effort: 4–6 hours

**Phase 4: Prove `z_interval_countermodel` (Transfer.lean:258)**
- After Phase 1 (architecture fix), prove the inductive truth correspondence.
- Atom case: straightforward given `states t _ = t`.
- Box case: requires establishing that Z-interval predicates for box-subformulas match the universal quantification in `truth_at`. Resolution: show that in the Z-interval model, the box-subformula predicate at position t is equivalent to `ψ` holding at ALL histories in Omega — which holds when Omega is the singleton history, because the single history is the only one.
- Alternative box approach: use `Omega = {zIntervalHistory}` (singleton set) and prove box truth for `ψ` reduces to `ψ` truth when there's only one history. Then map this to the Z-interval predicate via the chronicle's S5 properties.
- Estimated effort: 5–8 hours

**Phase 5: Close `succ_cofinal` OR switch to Reynolds Lemma 16 path**
- This is the hardest choice. Recommendation: attempt Option C first (prove `IsSuccArchimedean` using `separation_theorem_int`), then fall back to Option B (Reynolds Lemma 16 + close IntegerModel sorries).
- Estimated effort: 4–8 hours

**Phase 6: Wire and verify**
- Fix `countermodel_discrete_enriched` (Completeness.lean:225)
- Run `#print axioms bx_completeness`
- Estimated effort: 0.5 hours

### Total Estimated Effort: 15–25 hours

---

## Confidence Level

**HIGH** — the sorry inventory is complete and verified via `lean_verify`. The architecture issues are clearly identified. The mathematical content of each sorry is well-understood. The implementation paths are concrete, drawing on prior research in reports 03_post-157-status.md, 06_option-*.md, and 08_gap-elimination-detailed.md.

The two most uncertain parts are:
1. The box case in `z_interval_countermodel` — the S5/Omega relationship needs careful thinking.
2. The `succ_cofinal` bypass — both Options B and C require significant new lemmas.

The chronicle truth lemma (Phase 3) and the z_interval truth bridge (Phase 4) are the CORE Reynolds pipeline work. They are mathematically standard but require careful Lean 4 implementation.
