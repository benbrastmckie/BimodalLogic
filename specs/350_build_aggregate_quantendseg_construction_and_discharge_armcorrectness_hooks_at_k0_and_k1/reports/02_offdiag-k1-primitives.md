# Research Report: Off-Diagonal k=1 Aggregate — Three Missing Primitives (blk-350-p4-offdiag-k1-aggregate)

- **Task**: 350 (lean4), blocker `blk-350-p4-offdiag-k1-aggregate`
- **Session**: sess_1783979891_6ad95e_350
- **Agent**: lean-research-hard-agent (H2/H3/H4 contracts active)
- **Reference grounding tier**: Tier 1 (literature-backed — Rabinovich 2014, corpus doc `rabinovich_2014`, chunks read directly)
- **Date**: 2026-07-13

## Executive Summary

All three missing primitives are **transcribable** from Rabinovich 2014 with the codebase's
attained-INF/SUP surrogate for Dedekind completeness, with **one material restatement** (H4
finding): primitive 2 (negation closure) must be the **general-n fixed-formula Lemma 5.1 stack**,
not merely the "single-interior-witness fragment" — bit-false qnf whose carriers contain interior
arrangement witness slots force negation of multi-witness brackets. The root cause of the
previously archived fixed-formula negation attempt (`Boneyard/NegationIndep.lean`) is identified
precisely: **its disjuncts omit the paper's `Cond_i` case gates** (first/last-occurrence pins),
which is exactly what makes the backward direction provable. A worked n=1 gate-complete disjunct
list is given below (Section P2) with a full cover argument, including a counterexample showing
the naive 4-disjunct list is incomplete and the crossing disjunct B4 is required.

Dependency order: **P1 (conjFull) → P2 (negFix) → P3 (per-qnf carriers) → aggregate assembly**.
P3's interior rung already exists green (`bracketEndChar_kv_correct_one_prior` /
`endInterval_correct` k=1 arm) and only needs instantiation.

## Findings

### H3 Lemma Mapping Table (Tier 1, 5 columns)

| Source (Rabinovich 2014) | Paper statement / proof technique | Existing Lean asset (verified) | Gap | Proposed Lean statement (exact signature) |
|---|---|---|---|---|
| **Lemma 3.2(1)** (chunk_0009 md:11-13): conjunction of →∃∀-formulas ≡ **disjunction** of →∃∀-formulas. Technique: enumerate all interleavings-with-coincidences of the two witness tuples; merged points take conjoined point types **plus the other bracket's ambient segment type**; segments take conjoined segment types. | Equivalence (iff), order-generic — no Dedekind completeness used. | `VVecEA2.conj_struct` (VecEAClosure.lean:195) + `conj_struct_holds` (:205) — **one-directional**: `(0,n2+1)` case (:115-117) conjoins segments but NOT points; `(n1+1,n2+1)` case (:121-122) replaces bf2's content with `TemporalPred.top`. `conj_holds_vvecEA2` (:238) is existential, not structural. `lean_local_search conjFull` = 0 hits. | **iff form absent** (confirmed: no `conjFull` declaration repo-wide). | `def BracketFormula.snoc {n} (bf : BracketFormula n) (p s : TemporalPred) : BracketFormula (n+1)`; `theorem BracketFormula.snoc_holds_iff : (bf.snoc p s).holds M atomMap z0 z1 ↔ ∃ x, z0 < x ∧ x < z1 ∧ bf.holds M atomMap z0 x ∧ p.eval_at M atomMap x ∧ ∀ y, x < y → y < z1 → s.eval_at M atomMap y`; `def BracketFormula.conjFull {n1 n2} (bf1 : BracketFormula n1) (bf2 : BracketFormula n2) : VBracketFormula` (snoc-recursion on `n1+n2`, 3-way last-witness trichotomy); `theorem BracketFormula.conjFull_iff (M) (atomMap) (bf1) (bf2) (z0 z1) : (conjFull bf1 bf2).holds M atomMap z0 z1 ↔ bf1.holds M atomMap z0 z1 ∧ bf2.holds M atomMap z0 z1`; lifted `def VVecEA2.conjFull (v1 v2 : VVecEA2) : VVecEA2` + `theorem VVecEA2.conjFull_iff : (v1.conjFull v2).holds M atomMap z0 z1 ↔ v1.holds M atomMap z0 z1 ∧ v2.holds M atomMap z0 z1` (endpoints via `TemporalPred.eval_at_conj`, VecEAClosure.lean:22, already iff). |
| **Lemma 3.4** (chunk_0010 md:3-5): ∨→∃∀ closed under ∨, ∧, ∃. Proof: "By (1) and (3) of Lemma 3.2, and distributivity of ∃ over ∨." | Corollary of 3.2(1). | `VVecEA2.disj` + `disj_holds` (VecEAFormula.lean:282/286) — iff, green. | Only the ∧ leg is open (= row above). | (covered by row above; disjunction leg already landed) |
| **Prop 4.2 / Lemma 5.1** (chunk_0012 md:3, chunk_0013 md:29-33): ¬[α0,β1,…,βn,αn](z0,z1) ≡ ∨→∃∀ over Dedekind-complete chains **in the canonical expansion E[Σ]** (Def 4.1, chunk_0011). Technique (chunk_0016 md:5): construct per-case `Cond_i` (∨→∃∀ gate describing case i) and `Form_i` with `Cond_i → (Form_i ↔ ¬[…])`; output `∨_i (Cond_i ∧ Form_i)` — **the gates ride in the disjuncts**. Case 3 pins r0 = inf{¬β1} via the INF formula (5.3), itself bracket-shaped: `∀y∈(z0,z)β1 ∧ (¬β1(z) ∨ K+(¬β1)(z))`. | Fixed formula whose atoms are TL-definable predicates; model-dependence only in the correctness proof (Dedekind completeness → inf exists). | Model-dependent: `neg_2var_vec_ea` (EANegationClosure.lean:723, `∃ v' : VVecEA2, v'.holds` — refuted for syntactic use, confirmed by read). Fixed-formula forward-only: `neg_interval_formula_indep(_correct)`, `neg_2var_vec_ea_indep(_correct)` (**Boneyard/NegationIndep.lean** — forward direction green; backward direction documented unprovable *for that construction*, closing note :347-361). `HasAttainedINF` (PriorINF.lean:202) + `prior_hasAttainedINF` (:226, from `semantic_prior_UZ`) — green. | (1) Backward direction: Boneyard disjuncts lack the `Cond_i` gates (see Root Cause below). (2) `HasAttainedSUP` mirror **does not exist** (grep: 0 hits) — needed for Cor 5.4(2)/right-to-left walks; `HasDefinableSUP.last_occ` (PriorINF.lean:125) exists from `semantic_prior_SZ` (:168-176) but with the un-attained `Or` disjunct. (3) The De Morgan fold over disjunct lists needs `conjFull` (P1). | `structure HasAttainedSUP … : Prop where last_occ : ∀ (P : Formula) (z0 z1 : M.carrier), z0 < z1 → (∃ x, z0 < x ∧ x < z1 ∧ temporal_truth M atomMap x P) → ∃ r0, z0 < r0 ∧ r0 < z1 ∧ (∀ y, r0 < y → y < z1 → ¬temporal_truth M atomMap y P) ∧ temporal_truth M atomMap r0 P` + `theorem prior_hasAttainedSUP … (h_SZ : semantic_prior_SZ M atomMap) : HasAttainedSUP M atomMap` (mirror of PriorINF.lean:226-240); `def BracketFormula.negFix {n} (bf : BracketFormula n) : VBracketFormula` (gated Cases + On-recursion, below); `theorem BracketFormula.negFix_iff (M) (atomMap) (h_INF : HasAttainedINF M atomMap) (h_SUP : HasAttainedSUP M atomMap) (bf) (z0 z1) (h_lt : z0 < z1) : (negFix bf).holds M atomMap z0 z1 ↔ ¬bf.holds M atomMap z0 z1`; `def VVecEA2.negFix (v : VVecEA2) : VVecEA2` (per-disjunct endpoint/bracket split, conjFull De-Morgan fold) + `theorem VVecEA2.negFix_iff (h_INF) (h_SUP) (v) (z0 z1) (h_lt : z0 < z1) : (v.negFix).holds M atomMap z0 z1 ↔ ¬v.holds M atomMap z0 z1`. |
| **Lemma 5.3** (chunk_0014 md:3-41): ¬∃x1<…<xn∈(z0,z1) ∧ Pi(xi) ≡ ∨→∃∀ `On(P1,…,Pn,z0,z1)`. Technique: induction on n; step disjuncts = (1) P1 never occurs; (2) K+(P1)(z0) ∧ On(rest, z0, z1); (3) ∃r0 = attained inf of P1 (INF gate) ∧ On(rest, r0, z1). | Recursion consuming Dedekind completeness only through the inf; **in the attained setting (Prior structures) the K+ disjunct (2) is vacuous** (PriorINF.lean:195-199 doc: "the K+ case never arises"). | `exists_permutation_cons_head` (EANegationClosure.lean:757 — Lemma 5.3 permutation support, green). Model-dependent On-walk inside `neg_interval_formula` (EANegationClosure.lean). `VBracketFormula.prependAll` (Boneyard). | Fixed-formula On builder absent. | `def negChainOn : List TemporalPred → VBracketFormula` (list recursion: nil ↦ trivialTrue; P :: rest ↦ disj of [never-P 0-bracket ¬P] and prependAll-with-gate (¬P-segment, P-point) applied to `negChainOn rest`) + `theorem negChainOn_iff (h_INF) (Ps) (z0 z1) (h_lt) : (negChainOn Ps).holds M atomMap z0 z1 ↔ ¬∃ (increasing witnesses in (z0,z1) satisfying Ps pointwise)` — statement phrased against `BracketFormula.holds` of the all-top-segment bracket built from `Ps`. |
| **Corollary 5.4(1)/(2)** (chunk_0014 md:49, chunk_0015 md:3-43): ¬(∃z∈(z0,z1))[…](z0,z) (and mirror (z,z1)) ≡ ∨→∃∀. Technique: F0/Fi Until/Since-definable predicates + Lemma 5.3; direction ⇐ by induction with the Until-witness y2 ≤/> xn+1 case split. | (2) is the mirror image of (1) — mirror needs last-occurrence (attained SUP). | Forward-only model-dependent `neg_bounded_exists` (EANegationClosure.lean header :26). | Fixed iff form absent; mirror needs `HasAttainedSUP`. | `def negBoundedRightFix {n} (bf : BracketFormula n) : VBracketFormula` + `negBoundedRightFix_iff (h_INF) (h_SUP) … ↔ ¬∃ z, z0 < z ∧ z < z1 ∧ bf.holds M atomMap z0 z` (+ `Left` mirror). Fi predicates as `TemporalPred` via `temporal_truth`'s native `.untl`/`.snce` (Table.lean:191-194 — verified: genuine strict Until/Since over `M.carrier`). |
| **Def 4.1 canonical expansion E[Σ]** (chunk_0011 md:5,15-17): →∃∀ atoms may be TL-definable predicates. | Expansion device. | Already structurally present: `TemporalPred` = arbitrary `Formula` (ExistsForallNF.lean:49-56) evaluated by `temporal_truth`, which interprets `.untl`/`.snce` (Table.lean:182). **No new expansion machinery needed.** | none | (no new statement — record as an architectural note in module headers) |
| **Lemma 3.2(2)** ≤2-free-variable reduction + **Prop 3.5** ∃-witness → Until/Since folding (chunk_0010 md:11-15) | Splitting multi-anchor content into 2-variable pieces; folding navigated witnesses into modal formulas. | `VVecEA2.translateRight(_correct)` (NfToVecEA.lean:447/451 — iff, green), `VVecEA2.translateLeft` (VecEATranslation.lean:541), `nf_eval_depth1_fold_iff` (CarrierKv.lean:466 — **arity-generic depth-1 lossless re-fibering, iff, green**), `bracketEndChar_kv_correct_one_prior` (PriorInterface.lean:95 — k=1 interior per-qnf carrier, **full iff**, order-hypotheses pin x<w<t: CarrierKv.lean:396-405), `agg_diag_collapse_k1` (AggregateHookDischarge.lean:1907 — gated rename collapse, positions 1,2). | Exterior-w and point-w per-qnf carriers absent (P3 below); merge variants for positions (0,1)/(0,2) absent. | See P3 signatures below. |

### Root cause (single sentence per primitive)

1. **P1**: `conj_struct` was *designed* one-directional (its `(0,n2+1)` case never conjoins the
   other bracket's ambient segment into point types, and `(n1+1,n2+1)` discards bf2) — the paper's
   Lemma 3.2(1) iff requires merged point types to carry the other bracket's ambient segment type,
   which is precisely the reverse-projection ingredient.
2. **P2**: the archived fixed-formula negation (`Boneyard/NegationIndep.lean`) is backward-unprovable
   because its disjuncts omit the paper's `Cond_i` case gates (chunk_0016 md:5: the output is
   `∨_i (Cond_i ∧ Form_i)`, not `∨_i Form_i`): without the first-occurrence pin `¬p on (z0,r)` in
   the prepend disjunct, a disjunct realization does not force the case in which it is equivalent
   to the negation (the documented "B.1 interval mismatch", NegationIndep.lean:347-361).
3. **P3**: the depth-2 fold is refuted (F1, `bracketEndChar_kv_factors`, CarrierKv.lean:422) and a
   world-local base is refuted (`endCharN0_correct_world_local_obstruction`, Base.lean:1807), so
   k=1 population members must be carried **per-qnf whole**, split by the w-zone channel per
   Lemma 3.2(2) — only the interior channel has a landed carrier.

## Proposed solution path (per primitive)

### P1 — `VVecEA2.conjFull` (Lemma 3.2(1)/3.4 iff form) — **TRANSCRIBABLE**

Presentation deviation (flagged per literature-fidelity policy): instead of the paper's one-shot
enumeration of all interleavings-with-coincidences ("It is clear that…", chunk_0009 md:9-13), use
an equivalent **snoc-recursive** construction proving the same statement — Lean-friendlier, no
global arrangement combinatorics:

- `BracketFormula.snoc` + `snoc_holds_iff` (decomposition at the last witness; ⇒ direction
  restricts the witness vector, ⇐ direction re-appends; the file already has the one-directional
  cousin `existsBounded_right`, VecEAClosure.lean:265).
- Segment gluing lemma: `s on (a,x) → s(x) → s on (x,z1) → s on (a,z1)` (trichotomy on `y` vs `x`).
- `conjFull` recursion on `n1 + n2` (`termination_by`), last-witness trichotomy:
  - **(coincide)** merged point `(p1.conj p2)`, final segment `(s1.conj s2)`, recurse on both drops;
  - **(bf1-last greater)** merged point `(p1.conj s2last)` — the *other bracket's ambient segment
    type on the merged point*, the exact paper ingredient — final segment `(s1last.conj s2last)`,
    recurse `conjFull bf1' bf2` on `(z0, x)`;
  - **(bf2-last greater)** mirror.
  - Base cases `(0, n)` / `(n, 0)`: conjoin the 0-bracket's segment type into **all** point types
    and all segment types (this is where `conj_struct` diverges from the paper); iff via the
    interval trichotomy (every y ∈ (z0,z1) is a witness or interior to a segment).
- Lift to `VVecEA2.conjFull` by Cartesian product of disjunct lists (as `conj_struct` does) with
  endpoint conjunction via `TemporalPred.eval_at_conj` (already iff) and per-pair `conjFull`
  bracket lists flattened; `conjFull_iff` from `disj_holds` + per-pair `conjFull_iff`.

No model hypotheses needed (order-generic, matching the paper — Lemma 3.2 precedes any
completeness assumption). Estimated 400-700 lines. Disjunct-count growth (Delannoy-like) is
irrelevant: carriers are noncomputable proof objects, as with the landed k=0 aggregate.

### P2 — fixed-formula negation closure — **NEEDS-RESTATEMENT (strengthened), then transcribable**

**H4 restatement**: the blocker's "single-interior-witness fragment" is insufficient. For a
bit-false qnf, `¬∃w∈zone (A(w) ∧ ⋀_j ∃v Bj(w,v) ∧ ⋀_k ∀v Ck(w,v))` unfolds (through the
carrier's arrangement disjuncts) to negations of **multi-witness** brackets (the navigated w-slot
plus the interior fiber v-slots). Required strength: **general-n Lemma 5.1 in fixed-formula, iff
form over attained-INF/SUP structures**, i.e. the full `negChainOn` (Lemma 5.3) + `negBounded*Fix`
(Cor 5.4 both mirrors) + `negFix` (Lemma 5.1 Cases 1-3) stack from the mapping table, with the
attained simplification (K+ disjuncts vacuous; the INF gate is the plain first-occurrence pin
`[¬P-segment, P-point]`).

Worked n=1 instance demonstrating the gate-complete disjunct list and its cover (this is the
shape the general recursion produces; each disjunct *individually* implies the negation, and
attained INF/SUP drives the cover):

For `bf = [s0, p, s1]` (one interior witness) on `(z0, z1)`, `¬bf.holds` is equivalent to the
disjunction of:
- **A** `[¬p]` (0-bracket: p never occurs);
- **B1** `[¬p, (¬s0 ∧ ¬p), ⊤]` (a prefix violation before the first p-occurrence);
- **B2** `[⊤, (¬s1 ∧ ¬p), ¬p]` (mirror, last occurrence — consumes attained SUP);
- **B3** `[⊤, ¬s0, ⊤, ¬s1, ⊤]` (2 witnesses: an s0-violation strictly before an s1-violation);
- **B4** `[⊤, (¬s1 ∧ ¬p), ¬p, (¬s0 ∧ ¬p), ⊤]` (2 witnesses: s1-violation before s0-violation with
  a ¬p gap between, inclusive) and **B4′** `[⊤, (¬s0 ∧ ¬s1 ∧ ¬p), ⊤]` (coincidence variant).

Machine-checkable counterexample that the gate-free 4-list {A,B1,B2,B3} is incomplete (found
during this research; include as a test): carrier ℤ, `(z0,z1) = (0,10)`, `p` true exactly at
{2,8}, `¬s1` exactly at {3}, `¬s0` exactly at {7} — `¬bf.holds` yet A,B1,B2,B3 all false; B4
holds with (3,7). Cover proof sketch (⇒, attained setting): if p occurs and neither B1 (first-p
prefix clean of p before an s0-violation) nor B2 (mirror) nor B3, then with `y1* :=` last
¬s1-point and `y0* :=` first ¬s0-point one shows `y1* ≤ y0*` and `¬p` on `[y1*, y0*]` (any
p-point there would be a valid witness), yielding B4/B4′.

The general recursion follows the paper's Cases 1-3 verbatim with attained gates; Case 2 consumes
`negBoundedRightFix` (Cor 5.4(2) mirror → needs `HasAttainedSUP`); the `Cond_i ∧ Form_i`
combination and the VVecEA2-level De Morgan fold consume P1's `conjFull`. Endpoint negation and
the 3-way `¬el ∨ ¬er ∨ ¬bracket` split reuse the Boneyard skeleton (its **forward** correctness
and disjunct plumbing are salvageable; only the disjunct *contents* change by adding gates).
Estimated 1,200-1,800 lines; H8 split: (2a) `HasAttainedSUP` + `negChainOn` (~300-400), (2b)
`negBounded{Right,Left}Fix` (~300-500), (2c) `BracketFormula.negFix` Cases (~400-600), (2d)
`VecEA2/VVecEA2.negFix` De Morgan fold (~200-300).

### P3 — per-qnf k=1 zone carriers — **TRANSCRIBABLE (interior: instantiation-only; points: delivered technique; exteriors: new module)**

Per-qnf carrier `C(qnf) : VVecEA2` with
`(C qnf).holds M atomMap x t ↔ ∃ w, nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf`
(under ambient `x < t` for the past arm; mirror for future), split by qnf's w-zone channel
(order bits at pairs (0,1),(0,2) of `qnf.1` — the arity-3 analog of the delivered `agg2Mk`
classifier):

- **3-int (x<w<t)**: **EXISTS.** `bracketEndChar_kv_correct_one_prior` (PriorInterface.lean:95)
  instantiated with `charF 0 := nf_depth0_char_formula atomMap h_surj`, `h0 := rfl` — equivalently
  the k=1 arm of `endInterval_correct` (EndIntervalConsumerK.lean:220), which reduces to it by
  `rfl` (EndIntervalConsumerK.lean:197-200). Cite `endInterval_correct` as the task-349 DoD name.
- **3-pt (w=x / w=t)**: two rename-merge variants of the delivered diagonal collapse: merges of
  positions (0,1) and (0,2) (the delivered `aggMerge32` merges (1,2); `renameNF`
  (NfDepth0Generalized.lean:373) and the gate lemma `agg_rename_fixpoint_of_eval`
  (AggregateHookDischarge.lean:1853) are rename-generic — new instances, same technique,
  ~150-300 lines each). Result: `nf_eval_nf M 1 2 [x,t] (collapsed qnf)` at **fixed** anchors;
  characterize via `nf_eval_depth1_fold_iff` at n=2 (CarrierKv.lean:466) — fibers are
  zone-bounded **monadic** `(ZoneSpec 2 × NormalForm sig 0 1)` clauses, exactly the shape the
  delivered k=0 agg2 kit encodes (Since/Until lits at endpoints, plain chars at point zones,
  exclusion segment + arrangement slots for the single interior zone). Non-fixpoint qnf gate to
  the `bot` carrier exactly as `aggPosDiagK1` does.
- **3-ext (w<x / t<w)**: new construction ("inner-navigation carrier"). Apply
  `nf_eval_depth1_fold_iff` at n=3, env `[w,x,t]`: the depth-1 layer fibers into **monadic**
  clauses over the **7 order-consistent zones** of `w<x<t` (v<w, v=w, w<v<x, v=x, x<v<t, v=t,
  t<v). Partition fibers by w-dependence: w-dependent parts (atoms at w; zones v<w, v=w, w<v<x)
  fold into a single `endpointLeft : TemporalPred` at x via a Since-navigated kv_body-style
  package (Prop 3.5 device; bit-true inner fibers = arrangement slots inside the fold, bit-false
  = exclusion segments / negated Since-lits — all fixed formulas since `temporal_truth`
  interprets `.snce`); w-independent parts (v=x char → endpointLeft conjunct; x<v<t fibers →
  the (x,t) bracket's arrangement slots + exclusion segment; v=t, t<v, atoms at t →
  endpointRight) distribute out of the `∃w` cleanly. This avoids both refutations: no monadic
  re-fibering of the joint depth-1 content (F1) and no single predicate carrying t-reads
  (world-locality — t-reads are peeled to `endpointRight` before folding). Future side is the
  Since/Until mirror. Estimated 800-1,200 lines (past) + mirror.
- **3-bot** (order-channel inconsistent with ambient): `bot` carrier + falsity lemma (delivered
  consistency-lemma technique, `agg2_zone_consistent_*`).

### Aggregate assembly (consumes P1-P3; mirrors delivered Phase 3)

```
noncomputable def aggPop1 (atomMap) (h_surj) (sub_nf : NormalForm sig 2 2) : VVecEA2 :=
  ((Finset.univ : Finset (NormalForm sig 1 3)).toList.map fun qnf =>
      if sub_nf.2 qnf then C qnf else (C qnf).negFix).foldr VVecEA2.conjFull trivialTrue

theorem aggPop1_correct … (h_UZ) (h_SZ) (x t) (h_lt : x < t) :
    (aggPop1 atomMap h_surj sub_nf).holds M atomMap x t ↔
      ∀ qnf : NormalForm sig 1 3,
        ((∃ w, nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) ↔
          sub_nf.2 qnf = true)
```
(`Fintype (NormalForm sig 1 3)`: NormalForm.lean:167; fold induction over `conjFull_iff` +
per-qnf `C`-iff / `negFix_iff`; `h_INF := prior_hasAttainedINF … h_UZ`, `h_SUP :=
prior_hasAttainedSUP … h_SZ`.) Then `kampArm_past_k1 := (atom-layer endpoints ∧ aggPop1
sub_nf).translateRight` with `VVecEA2.translateRight_correct` (NfToVecEA.lean:451) supplying the
`∃ x, x < t ∧ …` navigation, exactly as Phase 3; future arm via `translateLeft`.

## Literature Proof Structure (Tier 1 step map)

| Step | Paper | Lean target | Depends on |
|---|---|---|---|
| 1 | Lemma 3.2(1) shuffle-with-merge | `BracketFormula.conjFull(_iff)` | — |
| 2 | Lemma 3.4 ∧-closure | `VVecEA2.conjFull(_iff)` | 1 |
| 3 | Dedekind inf/sup (attained surrogate) | `HasAttainedSUP` + `prior_hasAttainedSUP` | — |
| 4 | Lemma 5.3 On builder | `negChainOn(_iff)` | 2, 3 |
| 5 | Cor 5.4(1)/(2) | `negBounded{Right,Left}Fix(_iff)` | 4 |
| 6 | Lemma 5.1 Cases 1-3 (gated) | `BracketFormula.negFix(_iff)` | 2, 5 |
| 7 | Prop 4.2 | `VVecEA2.negFix(_iff)` | 2, 6 |
| 8 | Lemma 3.2(2) + Prop 3.5 per-qnf split | P3 carriers (3-pt merge variants; 3-ext navigated package) | 2 (3-ext bit-false may consume 7 locally) |
| 9 | population match = Cor 5.4 "all order patterns" clause | `aggPop1(_correct)` | 2, 7, 8 |
| 10 | arm assembly | `kampArm_{past,future}_k1(_correct)` | 9 + delivered Phase-3 glue |

## Adversarial Self-Verification

### Claim Verification Table

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| `conj_struct` one-directional; `(n1+1,n2+1)` discards bf2; `(0,n2+1)` omits point-conj | VecEAClosure.lean:109-122, 195-222 read directly | direct file read of definition | High |
| No `conjFull` exists repo-wide | — | `lean_local_search "conjFull"` = 0 hits | High |
| `neg_2var_vec_ea` model-dependent (`∃ v'`) | EANegationClosure.lean:723-731 | direct file read of statement | High |
| Boneyard fixed negation forward-green, backward-unprovable *as constructed*; failure = ungated prepend (B.1 interval mismatch) | Boneyard/NegationIndep.lean:56-140, 347-361 | direct file read incl. closing analysis note | High |
| Gates fix backward: gate-free 4-list incomplete; B4 required | ℤ counterexample (p@{2,8}, ¬s1@{3}, ¬s0@{7} on (0,10)) constructed and hand-checked this session | manual model check (recommend landing as a Lean `example`) | Medium-High |
| `temporal_truth` natively interprets `.untl`/`.snce` (canonical expansion free) | Table.lean:182-194 | direct file read of definition | High |
| `HasAttainedINF` + `prior_hasAttainedINF` (from h_UZ) exist; K+ case vacuous | PriorINF.lean:195-240 | direct file read | High |
| `HasAttainedSUP` missing; `HasDefinableSUP.last_occ` (h_SZ) exists un-attained | PriorINF.lean:125, 168-176; repo grep 0 hits for HasAttainedSUP | grep + file read | High |
| k=1 interior per-qnf carrier is a landed **iff** pinned to x<w<t | CarrierKv.lean:396-411 (six order-bit hypotheses read), PriorInterface.lean:95-103, EndIntervalConsumerK.lean:197-226 | direct file reads + `lean_local_search nf_eval_depth1_fold_iff` hit | High |
| `nf_eval_depth1_fold_iff` is arity-generic, lossless, iff | CarrierKv.lean:466-480 read | direct file read | High |
| `nf_eval_nf` k+1 = atoms ∧ per-sub population biconditional | NormalForm.lean:198-207 | direct file read | High |
| `Fintype (NormalForm sig k n)` | NormalForm.lean:162-182 | grep + file read | High |
| Diag collapse machinery rename-generic (merge variants feasible) | AggregateHookDischarge.lean:1805-1930, NfDepth0Generalized.lean:373 | direct file read (gate lemma takes rename maps as arguments) | High |
| 3-ext package avoids F1 and world-locality refutations | CarrierKv.lean:411-430, Base.lean:1770-1815 read; peeling argument in P3 | file reads + structural argument (not machine-checked) | Medium |
| P2 must be general-n, not single-interior-witness | structural: bit-false qnf carriers contain arrangement v-slots (kv_body shape, CarrierKv module header AggregateHookDischarge.lean:51-61) | file reads + derivation | Medium-High |

### Refuted-route check (blocker's four, per H4 (a))

- (i) `conj_struct`: `conjFull` is a different object (disjunction-valued, ambient-segment-conjoined
  points); the machine refutation targets `conj_struct`'s definition, not the existence of an iff
  — the paper proves the iff. NOT re-proposed.
- (ii) `neg_2var_vec_ea`: `negFix` is a fixed formula; model hypotheses appear only in the
  correctness proof (h_INF/h_SUP), as with every Prior-guarded lemma in the stack. NOT re-proposed.
- (iii) depth-2 fold re-fibering: not used anywhere — all P3 carriers keep qnf whole; `fold_iff`
  is used only at depth 1 where it is a lossless iff. NOT re-proposed.
- (iv) gated anchor-collapse at the off-diagonal seam: used only for the **w=x / w=t point
  channels** where the duplicated anchor genuinely exists (w duplicates x or t) — not for the
  x/t pair. This is a *new, sound* application site, not the refuted one.

### Contradiction Log

- `NegationIndep.lean:347-361` ("backward … unprovable") vs. this report's "P2 transcribable":
  RESOLVED — the note's own text scopes the verdict to "the current construction" (ungated
  disjuncts); the paper's construction (chunk_0016 md:5) includes `Cond_i` gates, and the n=1
  gate-complete list above shows each gated disjunct individually implies the negation. Precedence:
  primary source (paper proof) + direct construction over an archived analysis of a *different*
  construction. Residual risk logged in the claim table (Medium-High, recommend the ℤ
  counterexample and one gated-disjunct backward lemma as the first implementation probe).

### Recommendations modified after verification

- Strengthened P2 from "single-interior-witness fragment" to general-n Lemma 5.1 (see H4
  restatement) — this is the one deviation from the blocker's framing.
- Added the previously unlisted small gap `HasAttainedSUP`/`prior_hasAttainedSUP` (mirror,
  ~50 lines) as an explicit deliverable.

## Tactic Survey Results

Not applicable in the usual sense: the primitives are new definitions + structural inductions, not
tactic-closable goals. No `lean_multi_attempt` probes were run against existing positions (there
is no live sorry to probe; the blocker manifests as absent declarations). The verification burden
above was discharged by direct definition reads and `lean_local_search`. First implementation
probes recommended instead: (1) `BracketFormula.snoc_holds_iff` (self-contained, ~60 lines);
(2) the ℤ counterexample `example` for the gate-free 4-list; (3) `HasAttainedSUP` mirror.

## Recommended plan-revision shape (for /revise or /spawn)

Wave structure (H7-compatible; P1 and the P3 merge variants are file-disjoint and parallelizable):

1. **Phase A (P1)** — new file `Kamp/VecEAConjFull.lean`: snoc kit + `conjFull(_iff)` at
   BracketFormula/VBracketFormula/VVecEA2 levels. No model hypotheses. [~400-700 lines]
2. **Phase B (P2a-b)** — `HasAttainedSUP` + `prior_hasAttainedSUP` (PriorINF.lean append);
   `negChainOn(_iff)`, `negBounded{Right,Left}Fix(_iff)` in new `Kamp/EANegationFix.lean`.
   Depends on A. [~600-900 lines]
3. **Phase C (P2c-d)** — `BracketFormula.negFix(_iff)` (gated Cases 1-3), `VecEA2/VVecEA2.negFix(_iff)`.
   Depends on B. Salvage the Boneyard forward plumbing; land the ℤ B4-counterexample as a test.
   [~600-900 lines]
4. **Phase D (P3-pt)** — merge variants (0,1)/(0,2) + gated collapses + fixed-anchor depth-1
   arity-2 characterization via `fold_iff` n=2 + agg2-kit reuse. Independent of A-C
   (parallelizable). [~400-700 lines]
5. **Phase E (P3-ext)** — past-exterior navigated carrier (7-zone fiber split, Since-folded
   w-package); future mirror. May consume C for bit-false inner handling if the exclusion-segment
   device is insufficient at any fiber. [~800-1,200 lines + mirror]
6. **Phase F (assembly)** — zone classifier totality, `C(qnf)` dispatcher, `aggPop1(_correct)`
   conjFull-fold, `kampArm_past_k1/kampArm_future_k1(_correct)` + shape certificates via
   `translateRight/Left` (Phase-3 glue verbatim). Depends on all. [~300-500 lines]

## Memory candidates

1. (pattern, lean4) `VVecEA2.conj_struct` is one-directional **by construction** — Rabinovich
   Lemma 3.2(1)'s iff requires merged point types to carry the *other* bracket's ambient segment
   type; any conjunction combinator that tops-out or drops a bracket cannot be upgraded to an iff.
2. (pattern, lean4) Fixed-formula negation closure (Rabinovich Lemma 5.1) is backward-provable
   only when each disjunct embeds its case gate (`Cond_i ∧ Form_i`, first/last-occurrence pins as
   ¬P-segments); the Boneyard `NegationIndep.lean` backward failure was gate omission, not a
   mathematical obstruction.
3. (fact, lean4) In this codebase Dedekind completeness is replaced by `HasAttainedINF` (from
   `semantic_prior_UZ`) making the paper's K+ limit disjuncts vacuous; the SUP mirror
   (`HasAttainedSUP` from `semantic_prior_SZ`) was still missing as of task 350.
