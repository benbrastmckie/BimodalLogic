# Implementation Plan: Task #129

- **Task**: 129 - weak_reflexive_completeness_conservative_extension
- **Status**: [COMPLETED]
- **Effort**: 35-50 hours
- **Dependencies**: None (uses only existing Core/ and ProofSystem/ infrastructure)
- **Research Inputs**:
  - specs/129_weak_reflexive_completeness_conservative_extension/reports/01_weak-reflexive-findings.md
  - specs/129_weak_reflexive_completeness_conservative_extension/reports/02_team-research.md
  - specs/129_weak_reflexive_completeness_conservative_extension/reports/03_reynolds-deep-dive.md
- **Artifacts**: plans/03_doets-reynolds-plan.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Prove discrete completeness for the TM bimodal logic by constructing a reflexive canonical model and applying the Reynolds/Doets compression to produce a Z-countermodel, bypassing the chronicle construction's `succ_cofinal` sorry entirely. The approach builds a standard Henkin canonical model where the accessibility relation is reflexive (defined via G_w = phi AND G(phi)), proves a truth lemma, then applies Reynolds's Theorem 15 "good/very good" argument to produce a k-equivalent model on Z. The final deliverable is `doets_countermodel_discrete` — a drop-in replacement for `dd_countermodel_chronicle_discrete` in `bx_completeness` (Completeness.lean:159) with identical type signature. The old `succ_cofinal` sorry becomes dead code.

**Supersedes**: plans/01_weak-completeness-plan.md (which had incorrect integration strategy, misidentified Doets claims, and unnecessary weak axiom system).

### Research Integration

Key findings from reports 02 and 03:
- Reynolds 1994 (not raw Doets 1989) is the primary reference — Theorem 15 directly targets Z
- Gap elimination is trivially unnecessary in discrete models (no Dedekind gaps when immediate successors exist)
- Same axiom system throughout — only the canonical model's R changes (reflexive via G_w)
- n-equivalence operates at the monadic first-order level via temporal formula "tables"
- All MCS infrastructure (`SetMaximalConsistent`, `set_lindenbaum`, 12+ closure properties) reused unchanged

### Prior Plan Reference

Plan v1 (01_weak-completeness-plan.md) proposed 7 phases / 40 hours. Team research identified critical gaps: the integration targeted `succ_cofinal` (wrong level), used "Doets Claims 9-11" (nonexistent), and built unnecessary WeakMCS/WeakAxioms infrastructure. This plan replaces it with a 4-phase approach based on the Reynolds deep-dive findings.

### Roadmap Alignment

This plan advances the critical-path sorry in the discrete completeness branch (ROADMAP.md Phase 1). Success unblocks tasks 122 (discrete BFMCS), 130 (Boneyard archival), and 131 (module reorganization), achieving sorry-free `bx_completeness` for the first time.

## Goals & Non-Goals

**Goals**:
- Build a reflexive canonical model (domain = all MCS, R via G_w, reflexive preorder)
- Prove a full truth lemma for all Formula constructors in the reflexive model
- Implement Reynolds Theorem 15: k-types, "good/very good", contemporaneous equivalence, one-class argument, Z-model extraction
- Prove the model-theoretic transfer: consistent neg(phi) → Z-countermodel falsifying phi
- Create `doets_countermodel_discrete` with identical signature to `dd_countermodel_chronicle_discrete`
- Replace the call in `bx_completeness` (Completeness.lean:159) — 1 line change

**Non-Goals**:
- Modifying Formula, Axiom, truth_at, or any soundness theorems
- Changing the dense completeness branch (remains chronicle-based, sorry-free)
- Closing `succ_cofinal` directly (it becomes dead code)
- Formalizing full Ehrenfeucht games (restricted n-equivalence suffices)
- Formalizing Kamp's expressive completeness theorem (unnecessary in discrete canonical model)
- Building a separate "weak axiom system" or "weak MCS" type

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Truth lemma for Until/Since backward direction is harder than expected | HIGH | MEDIUM | Follow existing WitnessSeed pattern from `Bundle/WitnessSeed.lean`; BX5 (self-accumulation) + BX6 (absorption) handle eventuality resolution. Existing `forward_temporal_witness_seed_consistent` provides template. |
| Ordered-sum n-equivalence preservation (Doets 1.4) formalization is harder than expected | MEDIUM | MEDIUM | Can use isolated sorry initially and close as follow-up; mathematical content is textbook. Restricted version (finite k-type sets only) is simpler. |
| Packaging Z-model as TaskFrame/TaskModel/WorldHistory has type mismatches | LOW | HIGH | TaskFrame/TaskModel are simple structures; existing `dd_countermodel_chronicle_discrete` proof at ChronicleToCountermodel.lean:3293 shows the exact packaging pattern with `ParametricCanonicalTaskFrame Int`. |
| Reflexive R transitivity proof is non-trivial | LOW | MEDIUM | Requires G(phi) → G(G(phi)) (temp_4 axiom) and G distributes over conjunction. Both are standard derivable facts already used in MCSProperties.lean. |
| Compilation time increase from ~2000 new lines | LOW | LOW | Separate files under WeakCanonical/ minimize recompilation; no changes to existing heavy files. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4 | 3 |

Phases 1 and 2 are independent and can execute in parallel.

---

### Phase 1: Reflexive Canonical Model and Truth Lemma [COMPLETED]

**Goal**: Build the reflexive canonical model (domain = all MCS of the unchanged axiom system, R defined via G_w making it reflexive) and prove the truth lemma for all Formula constructors.

**Tasks**:
- [ ] Create directory `Theories/Bimodal/Metalogic/WeakCanonical/`
- [ ] Create `WeakCanonical/ReflexiveCanonical.lean`:
  - Define `ReflCanDomain := { S : Set Formula // SetMaximalConsistent S }` (reuse `SetMaximalConsistent` from `Core/MaximalConsistent.lean`)
  - Define `g_w_content (x : ReflCanDomain) : Set Formula := { psi | Formula.and psi (Formula.all_future psi) mem x.val }` (the "weak G" content: formulas psi such that psi AND G(psi) is in x)
  - Define `reflCanR (x y : ReflCanDomain) : Prop := g_w_content x subseteq y.val`
  - Prove `reflCanR_refl`: G_w(psi) implies psi is a propositional tautology ((psi AND G(psi)) implies psi), hence in every MCS by `theorem_in_mcs` + `closed_under_derivation`. So `g_w_content x subseteq x.val`.
  - Prove `reflCanR_trans`: If psi AND G(psi) in x, then psi in y AND G(psi) in y (by MCS conjunction). G(psi) in y implies G(G(psi)) in y (by `all_future_all_future` from MCSProperties.lean). So psi AND G(psi) in y, thus g_w_content y contains psi, giving psi in z.
  - Prove `reflCanR_linear`: From BX11 temporal linearity axiom, show that for any x, y, either g_w_content x subseteq y.val or g_w_content y subseteq x.val.
  - Define canonical valuation: `reflCanV (p : Atom) : Set ReflCanDomain := { x | Formula.atom p mem x.val }`
  - Prove discreteness: If `Formula.box next_top mem A` for the root MCS A, then `next_top mem x.val` for all x box-related to A (by S5 box closure). This means every point has an immediate R-successor (from U(Top, Bot) semantics).
- [ ] Create `WeakCanonical/TruthLemma.lean`:
  - Define `SubCl (phi : Formula) : Finset Formula` — subformula closure of phi (reuse existing `SubformulaClosure` if available, otherwise define: all subformulas + their negations)
  - Prove truth lemma: for all psi in SubCl(phi), for all x : ReflCanDomain,
    `psi mem x.val <-> reflCanModel_truth_at x psi`
    where `reflCanModel_truth_at` evaluates under the reflexive preorder R.
  - Cases to prove:
    - **atom p**: By definition of canonical valuation. (~5 lines)
    - **bot**: MCS consistency — bot not-in x.val. (~5 lines)
    - **imp (psi1 psi2)**: MCS implication property — (psi1 -> psi2) in x iff (psi1 in x -> psi2 in x). (~10 lines)
    - **box psi**: S5 canonical model — box(psi) in x iff for all y box-related to x, psi in y. Reuse existing `box_closure` and `diamond_box_duality` from Completeness.lean. (~30 lines)
    - **all_future (G) psi**: Forward: G(psi) in x implies for all y with x R y and y != x, psi in y (by definition of R using g_content, not g_w_content). Backward: G(psi) not-in x implies F(neg(psi)) in x, extend {chi | G(chi) in x} union {neg(psi)} to MCS y by Lindenbaum (`set_lindenbaum`); y satisfies x R y and psi not-in y, and y != x (since neg(psi) in y). (~50 lines)
    - **all_past (H) psi**: Symmetric to G case using h_content. (~50 lines)
    - **untl (Until) psi1 psi2**: Forward: U(psi1, psi2) in x implies F(psi1) in x, giving witness. Backward: U(psi1, psi2) not-in x. This is the hardest case. Use BX5 self-accumulation: neg(U(psi1, psi2)) AND psi2 implies neg(U(psi1, psi2)) AND U(neg(U(psi1, psi2)) AND psi2, psi2). Build a chain of MCS witnessing psi2 holds everywhere and psi1 never holds. Follow the pattern from `forward_temporal_witness_seed_consistent` in `Bundle/WitnessSeed.lean`. (~150 lines)
    - **snce (Since) psi1 psi2**: Symmetric to Until. (~150 lines)
  - Prove the truth lemma is total over SubCl(phi). (~20 lines)
- [ ] Create `WeakCanonical/FrameProperties.lean`:
  - Prove Z1 holds in canonical frame: `Axiom.z1 psi` is a theorem, hence in every MCS by `theorem_in_mcs`. By truth lemma, canonical frame validates Z1. (~20 lines)
  - Prove Prior-UZ/SZ hold: `Axiom.prior_UZ psi` and `Axiom.prior_SZ psi` are theorems, hence in every MCS. By truth lemma, canonical frame validates Prior-UZ/SZ. (~20 lines)
  - Prove discrete canonical model has no endpoints: From serial_future and serial_past axioms in every MCS. (~20 lines)

**Timing**: 14-18 hours (truth lemma Until/Since is the primary effort)

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean` — NEW (~350 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/TruthLemma.lean` — NEW (~500-700 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/FrameProperties.lean` — NEW (~80 lines)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.TruthLemma` compiles without errors
- `lake build Bimodal.Metalogic.WeakCanonical.FrameProperties` compiles without errors
- Truth lemma covers all Formula constructors (atom, bot, imp, box, all_future, all_past, untl, snce)
- No sorries in any of the three files

---

### Phase 2: n-Equivalence and Ordered Sum Infrastructure [COMPLETED]

**Goal**: Define monadic first-order k-equivalence, k-types, and prove that k-equivalence is preserved by ordered sums (Doets Lemma 1.4). This is pure order theory / finite combinatorics with no dependency on the canonical model.

**Tasks**:
- [ ] Create `WeakCanonical/NEquivalence.lean`:
  - Define `MonadicSentence` — monadic first-order sentences over a finite signature (finitely many unary predicates + binary <). For our purposes, the signature has |SubCl(phi)| unary predicates.
  - Define `quantifier_depth : MonadicSentence -> Nat`
  - Define `KType (k : Nat) (sig : MonadicSignature)` — a k-type is a maximal consistent set of monadic sentences of quantifier depth <= k. Represent as `Finset MonadicSentence`.
  - Prove `ktype_finite`: There are finitely many k-types for a finite signature. (From: finitely many sentences of depth <= k up to logical equivalence, by induction on k.)
  - Define `k_equiv (k : Nat) (M N : MonadicStructure) : Prop` — M and N satisfy the same monadic sentences of quantifier depth <= k. Equivalently, they have the same k-type.
  - Define `k_type_of (k : Nat) (M : MonadicStructure) : KType k` — the k-type realized by M.
  - Prove `k_equiv_iff_same_type`: `k_equiv k M N <-> k_type_of k M = k_type_of k N`
- [ ] Create `WeakCanonical/OrderedSum.lean`:
  - Define `OrderedSum (I : LinearOrder) (m : I -> MonadicStructure) : MonadicStructure` — the ordered sum Sigma_i m(i), domain = Union (m(i).domain x {i}), order = lexicographic.
  - Prove Doets Lemma 1.4 (restricted): If for all i in I, `k_equiv k (m i) (m' i)`, then `k_equiv k (OrderedSum I m) (OrderedSum I m')`. Prove by induction on k using the structure of monadic quantifiers: an existential witness in m(i) transfers to m'(i) since they are k-1-equivalent. The ordering between different summands is preserved since I is the same.
  - Prove Doets Lemma 1.5 (variant used in Reynolds Lemma 16): If I and J are ordered sets and the distribution of k-types matches (for each type sigma, {i in I | k_type_of k (m i) = sigma} and {j in J | k_type_of k (m' j) = sigma} have the same order-theoretic properties), then the sums are k-equivalent.
  - Prove finite structures are k-equivalent to Z-intervals: A finite discrete linear structure of size n is k-equivalent to the Z-interval [0, n-1] (trivially — they're isomorphic after adding the monadic predicates).
- [ ] Create `WeakCanonical/Table.lean`:
  - Define `table : Formula -> MonadicFormula` — the standard translation of temporal formulas to monadic first-order formulas. Induction on Formula:
    - `table (atom p) = P(t)` (unary predicate at free variable)
    - `table (bot) = false`
    - `table (imp a b) = table(a) -> table(b)`
    - `table (box a) = forall s, table(a)[t:=s]` (S5 box = universal)
    - `table (all_future a) = forall s > t, table(a)[t:=s]`
    - `table (all_past a) = forall s < t, table(a)[t:=s]`
    - `table (untl a b) = exists s > t, table(a)[t:=s] AND forall r, t < r < s -> table(b)[t:=r]`
    - `table (snce a b)` = dual of untl
  - Prove `table_depth_bound`: `quantifier_depth (table phi) <= table_depth phi` where `table_depth` is a simple recursive function on Formula.
  - Prove `table_correctness`: For all structures M, all t, `truth_at M t phi <-> M |= table(phi)(t)`. By induction on phi matching the truth_at definition.

**Timing**: 10-14 hours

**Depends on**: none (pure order theory + logic infrastructure)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` — NEW (~200 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` — NEW (~350 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` — NEW (~150 lines)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.OrderedSum` compiles without errors
- `lake build Bimodal.Metalogic.WeakCanonical.Table` compiles without errors
- Doets Lemma 1.4 is sorry-free (or has at most one isolated sorry for the quantifier induction step, flagged for follow-up)
- Table correctness links truth_at to monadic formula satisfaction

---

### Phase 3: Reynolds Z-Model Construction [COMPLETED]

**Goal**: Apply Reynolds Theorem 15 to the reflexive canonical model: define "good/very good", the contemporaneous equivalence ~M, prove one equivalence class (using the trivial discrete gap elimination), and extract the Z-model.

**Tasks**:
- [ ] Create `WeakCanonical/IntegerModel.lean`:
  - Fix k = `table_depth phi + 1` where phi is the target formula.
  - Define `good (k : Nat) (M : DiscreteStructure) : Prop := exists N : ZIntervalStructure, k_equiv k M.toMonadic N.toMonadic` — M has a k-equivalent with Z-interval flow.
  - Define `very_good (k : Nat) (M : DiscreteStructure) : Prop := forall a b in M.domain, a <= b -> good k (M.restrict [a,b])` — all subintervals are good.
  - Prove `finite_structures_good`: Every finite discrete structure is good (finite discrete = Z-interval of same size). (~20 lines)
  - Define contemporaneous equivalence: `contemp_equiv (k : Nat) (M : DiscreteStructure) (a b : M.domain) : Prop := a = b OR (a < b AND very_good k (M.restrict [a,b])) OR (b < a AND very_good k (M.restrict [b,a]))`.
  - Prove `contemp_equiv_is_equiv`: ~M is an equivalence relation with convex classes. Transitivity uses ordered-sum preservation (Doets 1.4 from Phase 2): if [a,b] and [b+1,c] are both very good, then [a,c] is very good because any subinterval [t,u] spanning b decomposes as [t,b] + [b+1,u], each good, whose ordered sum is good by Lemma 1.4. (~80 lines)
  - Prove `no_gaps_discrete`: In a discrete linear order with immediate successors, ~M classes cannot end at Dedekind gaps (there are no gaps — every boundary is a successor jump c to c+1). (~30 lines)
  - Prove `no_boundary_at_successor`: If c and c+1 are in different ~M classes, then M|[c,c+1] is a 2-element structure (finite), hence good by `finite_structures_good`, so c ~ c+1 by transitivity. Contradiction. (~30 lines)
  - Prove `one_class`: Combining `no_gaps_discrete` and `no_boundary_at_successor`: if M has more than one ~M class, there exists a boundary point. It can't be a gap (no gaps in discrete orders) and can't be a successor jump (contradicts transitivity). So M has exactly one ~M class. (~20 lines)
  - Prove `very_good_implies_good` (Reynolds Lemma 16): If M is countable and very good, then M is good. Choose cofinal sequence a_0 < a_1 < a_2 < ..., each M|[a_i, a_{i+1}-1] is good, choose k-equivalent Z-intervals Z_i, form ordered sum Sigma_i Z_i which has Z-flow and is k-equivalent to M by Doets 1.4. Handle backward direction symmetrically for the negative part. (~80 lines)
  - Prove `canonical_model_is_good`: The reflexive canonical model (restricted to the box-class of A) is very good (by `one_class`) and countable (formula language is countable, MCS are countable), hence good by `very_good_implies_good`. Extract the Z-model N with N =_k M. (~30 lines)
- [ ] Create `WeakCanonical/Transfer.lean`:
  - Prove `truth_transfer`: Given the Z-model N with `k_equiv k M.toMonadic N.toMonadic` and k > `table_depth phi`, and `neg(phi) mem A_0` in M, conclude `exists b : Z, NOT truth_at N b phi`. Argument: neg(phi) true at root in M (by truth lemma). By table correctness, M |= table(neg(phi))(t_0). So M |= exists t, table(neg(phi))(t). Since quantifier_depth(table(neg(phi))) <= k, N |= exists t, table(neg(phi))(t) (by k-equivalence). So exists b in Z with N |= table(neg(phi))(b). By table correctness, NOT truth_at N b phi. (~80 lines)
  - Prove `z_is_valid_discrete_frame`: Z with standard < satisfies AddCommGroup, LinearOrder, IsOrderedAddMonoid, Nontrivial, SuccOrder, PredOrder, IsSuccArchimedean, IsPredArchimedean. All are standard Mathlib instances. (~10 lines of instance declarations)
  - Prove `doets_countermodel_discrete`:
    ```
    theorem doets_countermodel_discrete (A : Set Formula) (h_mcs : SetMaximalConsistent A)
        (phi : Formula) (h_neg_in : phi.neg mem A)
        (h_box_discrete : Formula.box next_top mem A) :
        exists (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
          (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
          (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
          (tau : WorldHistory F) (_ : tau mem Omega) (t : D),
          NOT truth_at TM Omega tau t phi
    ```
    Wire together: build canonical model, apply Reynolds compression, get Z-model, package as TaskFrame/TaskModel on Int with the exact existential structure matching `dd_countermodel_chronicle_discrete`. (~40 lines)

**Timing**: 8-12 hours

**Depends on**: 1, 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` — NEW (~300 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` — NEW (~130 lines)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Transfer` compiles without errors
- `doets_countermodel_discrete` type-checks with the exact signature of `dd_countermodel_chronicle_discrete`
- `one_class` proof is sorry-free
- `truth_transfer` proof is sorry-free (may depend on Doets 1.4 sorry if Phase 2 used one)

---

### Phase 4: Integration and Cleanup [COMPLETED]

**Goal**: Replace `dd_countermodel_chronicle_discrete` with `doets_countermodel_discrete` in `bx_completeness`, create the root import file, verify full build.

**Tasks**:
- [ ] Create `WeakCanonical/WeakCanonical.lean` — root import file importing all WeakCanonical modules (~15 lines)
- [ ] Modify `Metalogic/Metalogic.lean` — add `import Bimodal.Metalogic.WeakCanonical` (1 line)
- [ ] Modify `Metalogic/BXCanonical/Completeness.lean` line 159:
  - Replace `Chronicle.dd_countermodel_chronicle_discrete M hM_mcs phi h_neg_in h_box_discrete`
  - With `WeakCanonical.doets_countermodel_discrete M hM_mcs phi h_neg_in h_box_discrete`
  - Also add import: `import Bimodal.Metalogic.WeakCanonical` at top of file
- [ ] Run `lake build` on full project — verify no regressions
- [ ] Run `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/` to audit sorry count
- [ ] If any sorries remain, document them with comments explaining the mathematical content and create follow-up task
- [ ] Verify `#print axioms bx_completeness` shows reduced axiom set (the chronicle's `succ_cofinal` sorry should no longer appear)
- [ ] Update docstring in Completeness.lean to reference the Doets/Reynolds construction

**Timing**: 3-5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/WeakCanonical.lean` — NEW (~15 lines)
- `Theories/Bimodal/Metalogic/Metalogic.lean` — MODIFY (1 line: add import)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` — MODIFY (2 lines: add import + replace call at line 159)

**Verification**:
- `lake build` succeeds with zero errors on full project
- `bx_completeness` no longer transitively depends on `succ_cofinal` sorry
- `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/` shows zero sorries (ideal) or documented isolated sorries (acceptable)
- Dense completeness path (`dd_countermodel_chronicle_dense`) is unaffected
- All existing tests pass

---

## Testing & Validation

- [ ] Each phase: `lake build` on the specific module compiles without errors
- [ ] Phase 1: Truth lemma covers all 8 Formula constructors (atom, bot, imp, box, all_future, all_past, untl, snce)
- [ ] Phase 2: Doets Lemma 1.4 (ordered-sum preservation) type-checks
- [ ] Phase 3: `doets_countermodel_discrete` matches exact signature of `dd_countermodel_chronicle_discrete`
- [ ] Phase 4: Full `lake build` with zero errors; `#print axioms bx_completeness` shows no `succ_cofinal` dependency
- [ ] Sorry audit: `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/` with zero results (target) or documented isolations

## Artifacts & Outputs

- `specs/129_weak_reflexive_completeness_conservative_extension/plans/03_doets-reynolds-plan.md` (this file)
- `specs/129_weak_reflexive_completeness_conservative_extension/summaries/03_doets-reynolds-summary.md` (created after implementation)
- New Lean files:
  - `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean` (~350 lines)
  - `Theories/Bimodal/Metalogic/WeakCanonical/TruthLemma.lean` (~500-700 lines)
  - `Theories/Bimodal/Metalogic/WeakCanonical/FrameProperties.lean` (~80 lines)
  - `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` (~200 lines)
  - `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` (~350 lines)
  - `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` (~150 lines)
  - `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` (~300 lines)
  - `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (~130 lines)
  - `Theories/Bimodal/Metalogic/WeakCanonical/WeakCanonical.lean` (~15 lines)
- Modified files:
  - `Theories/Bimodal/Metalogic/Metalogic.lean` (1 line)
  - `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (2 lines)
- Total new code: ~2075-2275 lines

## Rollback/Contingency

- **If truth lemma Until/Since case proves intractable**: Fall back to using a sorry for the Until backward direction and create a follow-up task. The rest of the construction works independently of this case.
- **If Doets Lemma 1.4 formalization is too hard**: Use an isolated sorry for ordered-sum preservation (mathematically uncontroversial, textbook result). This sorry would be strictly cleaner than the current `succ_cofinal` sorry (which is a genuine mathematical gap, not just unformalized known mathematics).
- **If integration type-mismatch occurs**: The `doets_countermodel_discrete` signature matches `dd_countermodel_chronicle_discrete` exactly (both produce the same existential over TaskFrame/TaskModel on Int). If the types diverge during implementation, add adapter lemmas in Transfer.lean.
- **Full rollback**: Delete `Theories/Bimodal/Metalogic/WeakCanonical/` directory and revert the 3 lines changed in Completeness.lean and Metalogic.lean. No other files are modified.
