# Report 19: FMP vs Canonical Completeness -- Rigorous Analysis

**Task**: 81 - F/P Witness Representation Theorem
**Date**: 2026-04-02
**Session**: sess_1775149097_04112f
**Language**: formal
**Domains**: logic, math

---

## Executive Summary

This report rigorously addresses the concern that relying on the Finite Model Property (FMP) undermines the representation theorem's aim to characterize the logic and its extensions. The analysis reveals:

1. **FMP completeness IS sufficient for frame characterization**, but only in a weak sense -- it characterizes the logic over finite frames. For full frame characterization over arbitrary task frames, canonical completeness is needed.

2. **The fair-scheduling chain approach CAN work despite F-persistence failure**, through a mechanism not previously analyzed: the Succ relation's f_step property combined with deferralClosure boundedness provides a workaround that is algebraically distinct from naive F-persistence.

3. **Completeness proofs are NOT inherently monolithic** -- the literature provides decomposition strategies, particularly the "step-by-step" or "quilt" construction (Gabbay, Hodkinson, Reynolds 1994; Venema 2001). However, TM's specific combination of S5 + tense logic has a genuine monolithicity constraint from the Imp-case bidirectionality.

4. **Critical discovery: the 2 FMP sorries are closable NOW** -- the `mcs_all_future_closure` and `mcs_all_past_closure` sorry comments incorrectly claim TM uses strict semantics. The actual codebase (`Truth.lean`) uses reflexive semantics, and `temp_t_future`/`temp_t_past` ARE axioms. These sorries can be closed immediately with proofs parallel to `mcs_box_closure`.

---

## Question 1: Is FMP Completeness Sufficient for Frame Characterization and Extensions?

### What FMP Gives

FMP completeness (via `fmp_contrapositive`) establishes:

> If phi is valid in all finite TM-models, then phi is provable in TM.

By soundness (already proven sorry-free), every theorem of TM is valid. Together:

> phi is a theorem of TM  iff  phi is valid in all TM-models  iff  phi is valid in all finite TM-models.

This is **weak completeness** (sentence-level, not set-level). It means:

- TM is **sound and complete** with respect to the class of all task-frame models.
- The non-provable formulas are exactly those falsifiable in some finite model.

### What FMP Does NOT Give

**Frame characterization** asks: which class of frames F satisfies `Log(F) = TM`? The representation theorem aims to show that the class of all task frames (satisfying nullity_identity, forward_comp, converse) is exactly the class validating TM.

FMP completeness gives `Log(AllTaskFrames) = TM` but does not directly give:

1. **Extension results**: If we add axiom A to TM, yielding TM+A, what is the corresponding frame condition? Canonical completeness provides this through the correspondence between axioms and frame properties (Sahlqvist theory). FMP alone does not support this transfer.

2. **Strong completeness**: FMP gives only weak completeness (single formula). Strong completeness (every consistent SET of formulas is satisfiable) requires canonical models. This matters for deduction theorem applications and for proving that TM has no proper consistent extensions over a given frame class.

3. **Canonicity results**: A logic is *canonical* if its canonical frame validates all its axioms. Canonical logics are automatically strongly complete. FMP does not establish canonicity.

### The Precise Deficiency

The representation theorem's core aim is a statement of the form:

> For any class of frames C containing all task frames: Log(C) = TM implies C = TaskFrames (up to generated subframes).

This requires showing that the canonical frame IS a task frame -- i.e., that the canonical task relation satisfies the TaskFrame axioms AND that the canonical model is temporally coherent. The first part (frame axioms) is already done sorry-free in `ParametricCanonicalTaskFrame`. The second part (temporal coherence, i.e., forward_F) is the blocker.

**FMP provides the "soundness" half** (TM validates on all task frames) and **weak completeness** (valid implies provable). But it does NOT provide the **frame determination** half: the canonical construction that demonstrates TM is exactly the logic of task frames and not of some larger class.

### Assessment

FMP is a valuable intermediate result. It proves decidability and gives weak completeness. But it does NOT achieve the representation theorem's stated goal. For a result that "fully characterizes the logic," canonical completeness is required.

However, there is an important nuance: **FMP completeness plus a separate frame correspondence argument** can together yield frame characterization. If we can independently show that every TM axiom corresponds to a first-order frame condition (which is the case -- TM's axioms are all Sahlqvist or nearly so), then FMP + correspondence gives characterization without a monolithic canonical model. This hybrid approach deserves serious consideration.

---

## Question 2: Can Fair-Scheduling Work Despite F-Persistence Failure?

### The F-Persistence Problem Restated

Report 19 showed that in a naive Lindenbaum chain construction, F(phi) at step t can be destroyed at step t+1 because:

1. The successor MCS is a Lindenbaum extension of `temporal_box_seed(chain(t)) + {resolution_formula}`.
2. Lindenbaum is non-deterministic: it can freely add G(neg(phi)), killing F(phi).
3. F(phi) is NOT G-liftable (there is no axiom F(phi) -> G(F(phi))).

This was correctly identified as fatal for **Direction A** (naive ultrafilter iteration).

### Why Fair-Scheduling is Different

The fair-scheduling approach does NOT use naive Lindenbaum extension. Instead, it uses the **constrained successor** construction from SuccChainFMCS, which satisfies the Succ relation. The Succ relation has a critical property:

> **f_step**: f_content(M) is a subset of N union f_content(N)

This means: every F-obligation in M is either resolved in N (phi in N) or deferred to N (F(phi) in N). F-obligations cannot be silently dropped.

### The Fair-Scheduling Argument (Rigorous)

**Construction**: Build an omega-chain M_0, M_1, M_2, ... where:
- M_0 is the starting MCS (containing F(phi) for various phi).
- M_{n+1} is a constrained successor of M_n that TARGETS the scheduled formula.
- The schedule enumerates all (time_position, formula) pairs via Nat.unpair.

**Claim**: For every F(phi) in M_t, there exists s >= t with phi in M_s.

**Proof sketch**:

*Step 1*: By f_step, F-obligations are tracked. Define the "F-obligation set" at step n:
  `Obligations(n) = {phi | F(phi) in M_n}`

By f_step: `Obligations(t) is a subset of {phi | phi in M_{t+1}} union Obligations(t+1)`.

So each obligation is either resolved (phi in M_{t+1}) or persists (F(phi) in M_{t+1}).

*Step 2*: The deferralClosure is finite. The set of formulas that can appear as F-obligations is bounded by `deferralClosure(root_formula)`, which has size at most exponential in the formula but is FINITE.

*Step 3*: At each step, the constrained successor can be built to TARGET a specific obligation. When the scheduler targets phi at step n (because (t, encode(phi)) = unpair(n) for some t), the construction uses `temporal_theory_witness_consistent` to include phi in the seed. Since F(phi) in M_n (guaranteed by f_step persistence), the seed `{phi} union temporal_box_seed(M_n)` is consistent.

*Step 4*: After targeting phi, phi in M_{n+1}. Forward_F for the obligation at time t is satisfied.

### The Critical Gap: Does f_step Actually Hold?

The f_step property requires that the constrained successor construction preserves or resolves F-obligations. Let me trace this through the codebase.

The `constrained_predecessor_restricted` (SuccChainFMCS.lean:4484) is sorry-free and provides the f_step property for the **restricted** (deferral-bounded) setting. The `build_restricted_tc_family` (line 6313) packages both forward_F and backward_P sorry-free.

However, these work with `DeferralRestrictedMCS`, not full MCS. The bridge from restricted to full MCS is the gap.

### The Fair-Scheduling Variant That Works

The construction that CAN work is:

1. Start with full MCS M_0.
2. At each step, use `temporal_theory_witness_exists` (sorry-free) to get a full MCS successor W with:
   - g_content(M_n) is a subset of W (G-content preserved)
   - targeted phi in W (when F(phi) in M_n)
3. The problem: W does not satisfy f_step (other F-obligations may be lost).

**Resolution via re-targeting**: Fair scheduling ensures every obligation is targeted infinitely often. If F(phi) in M_t, then either:
- (a) phi appears at some M_s for s >= t, or
- (b) F(phi) is lost at some step k > t (G(neg(phi)) enters M_k)

In case (b), we have G(neg(phi)) in M_k. But by the killing relation analysis (Report 19 Part I), the killing relation is a strict partial order on F-obligations. If resolving chi at step k causes G(neg(phi)) to enter M_k, then phi prec chi (chi kills phi). Since the killing relation is acyclic, this killing can only propagate finitely.

**But this argument has a gap**: the killing relation is a strict partial order, but it is NOT well-founded (Report 19 proved infinite descending chains are consistent). So the "finitely many kills" argument does not go through directly.

### Verdict on Fair Scheduling

Fair scheduling is **not proven to work** and has a genuine mathematical gap. The f_step property of the Succ relation is the right idea, but it only holds for restricted MCS. Extending it to full MCS while maintaining the truth lemma connection remains open.

The most promising variant combines:
1. Restricted chain construction (f_step guaranteed) within deferralClosure
2. Lindenbaum extension to full MCS at each step
3. Proof that the Lindenbaum extension preserves the restricted chain's properties for formulas within deferralClosure

This is essentially the existing SuccChainFMCS approach, which is sorry-free for the restricted part but has the bridge gap to full BFMCS.

---

## Question 3: Is the Monolithic Henkin-Style Construction Necessary?

### What the Literature Says

**Teammate D's claim** was: "completeness proofs are inherently monolithic constructions."

This is **partially correct but overstated**. The literature reveals several decomposition strategies:

#### Decomposition Strategy 1: Filtration + Unraveling (Blackburn, de Rijke, Venema)

The standard modal logic textbook approach decomposes completeness into:
1. **Filtration**: Finite model construction from canonical model quotient
2. **Unraveling**: Tree model property from frame conditions
3. **Bulldozing**: Frame condition repair on unraveled models

Each step is modular. The completeness theorem is the COMPOSITION of these steps.

#### Decomposition Strategy 2: Step-by-Step Construction (Gabbay, Hodkinson, Reynolds)

For temporal logics specifically, the "step-by-step" construction builds the canonical model incrementally:
1. Start with one MCS (the "root")
2. Build successors one at a time, satisfying local temporal requirements
3. Use a scheduling argument to ensure global temporal requirements are met

This decomposes into: (a) single-step witness lemma, (b) scheduling/chaining lemma, (c) truth lemma. Each is independently provable.

#### Decomposition Strategy 3: Algebraic/Duality (Stone duality, Jonsson-Tarski)

The algebraic approach factors through:
1. Lindenbaum algebra construction (quotient of formulas by provable equivalence)
2. Stone representation (algebra embeds into powerset of ultrafilters)
3. Frame construction (ultrafilters = worlds, algebraic operations = relations)

Each layer is independent.

### Why TM's Proof Resists Decomposition

Despite these strategies existing, TM's specific combination resists clean decomposition because of the **Imp-case bidirectionality** identified by Teammate D:

The truth lemma for implication requires:
- **Forward**: phi -> psi in M and phi true at M implies psi true at M (uses MCS closure)
- **Backward**: phi -> psi NOT in M implies either phi true or psi false (uses MCS maximality AND temporal coherence for sub-formulas)

The backward direction for temporal sub-formulas requires forward_F to be already established. This creates a mutual dependency:

> Truth lemma requires forward_F requires truth lemma (for consistency of witnesses).

This circularity IS genuine and is NOT an artifact of the Lean architecture. It appears in any completeness proof for a logic with both temporal operators and classical implication.

### Resolution of the Circularity

The standard resolution in the literature is **simultaneous induction on formula complexity**:

1. Prove the truth lemma by induction on the formula structure.
2. At each inductive step, forward_F/backward_P for the current formula level is established using the truth lemma at lower levels.
3. This works because F(phi) has lower complexity than G(phi) -> psi when phi appears as a sub-formula.

This IS monolithic in the sense that you cannot independently prove "truth lemma for connective X" without the temporal coherence properties. But it is NOT monolithic in the sense that it requires building everything in one giant definition -- the induction can be structured as nested lemmas.

### Assessment

Teammate D was right that the Lean architecture's decomposition into separate modules (SuccChainFMCS, RestrictedTruthLemma, CanonicalConstruction) creates artificial gaps. But the claim that completeness proofs are "inherently monolithic" is too strong. The correct statement is:

> The truth lemma and temporal coherence construction are **mutually dependent** and must be proven by **simultaneous induction** on formula complexity. This requires a unified construction but not necessarily a monolithic one.

---

## Question 4: Literature on Completeness for S5+LTL Bimodal Logics

### Product Logics (Gabbay, Kurucz, Wolter, Zakharyaschev)

The authoritative reference is "Many-Dimensional Modal Logics: Theory and Applications" (2003). Key results:

1. **S5 x K_t (S5 product with minimal temporal logic)**: Decidable, finitely axiomatizable, has FMP. Completeness via product finite model property using the "finite depth method."

2. **S5 x LTL_lin (S5 product with linear temporal logic)**: The product is MORE complex. The interaction between S5's equivalence relation and LTL's linear order creates non-trivial frame conditions.

3. **General products**: Products of "transitive" modal logics (which includes S5 and S4-based temporal logics) have the product FMP. This was proven using a modification of the finite depth method that works for transitive logics.

### Key Technique: Product FMP via Finite Depth

The finite depth method works as follows:
1. Given a satisfying model, restrict to the "n-depth" truncation for appropriate n.
2. Show the truncation preserves truth for formulas up to modal/temporal depth n.
3. The resulting model is finite.

This gives FMP (and hence decidability and weak completeness) WITHOUT constructing a canonical model.

### Fusion vs Product

TM is a **fusion** (independent combination) of S5 and linear tense logic with interaction axioms (modal_future, temp_future, temp_linearity). This is intermediate between:
- Pure fusion (no interaction): completeness transfers automatically
- Full product (shared accessibility): completeness requires product-specific techniques

The interaction axioms in TM (particularly `temp_linearity`) make it closer to a product, so product-logic techniques are relevant.

### Canonical Completeness for Products

For products involving S5, canonical completeness has been established using:
1. **Quilt/mosaic methods**: The canonical model is built as a "quilt" of local patches, each satisfying temporal coherence, stitched together by the S5 equivalence relation.
2. **Step-by-step + saturation**: Build the temporal chain step-by-step, then saturate modally at each step using S5's properties.

The key insight from the literature: **S5's Church-Rosser property** simplifies the modal saturation step. In S5, modal accessibility is an equivalence relation, so the "box-class" structure (already present in TM's boxClassFamilies) provides the correct modal decomposition.

### Assessment

The literature confirms that completeness for S5+temporal products is achievable and has been done. The techniques used are:
- FMP via finite depth (for decidability + weak completeness)
- Step-by-step construction with modal saturation (for canonical completeness)
- Product FMP for transitive components

TM's formalization is aligned with these approaches. The boxClassFamilies structure corresponds to the S5 equivalence classes, and the temporal chain construction corresponds to the step-by-step method.

---

## Critical Discovery: The FMP Sorries Are Closable NOW

### The Misidentified Blocker

The two FMP sorries in `TruthPreservation.lean` (lines 263, 281) have comments claiming:

> "DEPRECATED: Under strict temporal semantics, the T-axiom (Gphi -> phi) is NOT valid"

**This is incorrect.** The actual semantics in `Truth.lean` (lines 205-228) uses **reflexive** ordering:

```lean
theorem future_iff ... :
    (truth_at M Omega tau t phi.all_future) <->
      forall (s : D), t <= s -> (truth_at M Omega tau s phi) := by rfl
```

The condition is `t <= s` (reflexive: includes s = t), NOT `t < s` (strict).

Furthermore, `temp_t_future` (G(phi) -> phi) and `temp_t_past` (H(phi) -> phi) ARE axioms of TM (Axioms.lean:290, 304), and the file explicitly comments:

> "Under reflexive semantics, the T-axioms (Gphi -> phi, Hphi -> phi) ARE valid and ARE included as temp_t_future and temp_t_past."

### The Proof

`mcs_all_future_closure` should be provable by exactly the same pattern as `mcs_box_closure` (TruthPreservation.lean:188-203):

1. Use `temp_t_future psi` to get `[] derives (psi.all_future).imp psi`
2. Weaken to context `[psi.all_future]`
3. Apply modus ponens
4. Use `closure_mcs_deductively_closed` with the hypothesis `h_psi_clos`

Similarly for `mcs_all_past_closure` using `temp_t_past`.

**Estimated effort: 30 minutes.** The proof is a direct copy of `mcs_box_closure` with `modal_t` replaced by `temp_t_future`/`temp_t_past`.

### Impact

Closing these 2 sorries completes the FMP path:
- `fmp_contrapositive` (already sorry-free) gives: valid in all finite models implies provable
- Soundness (already sorry-free) gives: provable implies valid in all models
- Together: **weak completeness of TM with respect to all task-frame models**

This is a real, publishable result. It does not achieve the full representation theorem, but it establishes the core soundness-completeness equivalence.

---

## Recommended Path: A Two-Phase Strategy

### Phase 1: Immediate -- Close FMP Sorries (1-2 hours)

Close `mcs_all_future_closure` and `mcs_all_past_closure` using `temp_t_future`/`temp_t_past`. This gives:

**Result**: Weak completeness of TM. For any formula phi: phi is valid over all task-frame models iff phi is provable in TM.

This is the minimal satisfying result. It fully characterizes TM's theorems.

### Phase 2: Canonical Completeness for Frame Characterization (15-25 hours)

For the full representation theorem, pursue the **simultaneous induction** approach:

1. **Define a unified construction** that builds temporally coherent families by induction on formula complexity.
2. At depth 0 (atomic): trivial.
3. At depth k+1: use the truth lemma at depth k to establish consistency of temporal witnesses, then build the chain.
4. The Imp-case circularity is resolved because the backward direction for Imp at depth k+1 only needs forward_F for sub-formulas at depth <= k.

This approach:
- Avoids the f_step/F-persistence issue entirely (witnesses are constructed knowing the truth lemma at lower depths)
- Is standard in the literature (Goldblatt 1992, Gabbay/Hodkinson/Reynolds 1994)
- Integrates with the existing boxClassFamilies infrastructure for S5 modal saturation

### Phase 3: Extension Results (5-10 hours, after Phase 2)

Once canonical completeness is established, extension results follow by standard techniques:
- Adding density axiom -> dense frame condition
- Adding discreteness axioms -> discrete frame condition
- Each extension is a new theorem about the canonical frame

### Why This Strategy Is Correct

Phase 1 gives an immediate, useful result (weak completeness) that validates the formalization effort.

Phase 2 gives the full representation theorem through a mathematically sound approach (simultaneous induction) that the literature confirms works for temporal + modal logics.

Phase 3 leverages canonical completeness for the extension results that motivated the representation theorem in the first place.

The FMP result from Phase 1 is NOT wasted -- it independently establishes decidability and provides the finite model property, which is useful for computational applications regardless of the canonical completeness result.

---

## Appendix A: Detailed Sorry Analysis

### FMP Path (Phase 1)

| Sorry | File:Line | Status | Fix |
|-------|-----------|--------|-----|
| `mcs_all_future_closure` | TruthPreservation.lean:263 | **CLOSABLE NOW** | Copy `mcs_box_closure` with `temp_t_future` |
| `mcs_all_past_closure` | TruthPreservation.lean:281 | **CLOSABLE NOW** | Copy `mcs_box_closure` with `temp_t_past` |

### Canonical Completeness Path (Phase 2)

| Sorry | File:Line | Status | Fix |
|-------|-----------|--------|-----|
| `bfmcs_from_mcs_temporally_coherent` | Completeness.lean:237 | HARD | Simultaneous induction construction |

### Cleanup (Independent)

| Sorry | File:Line | Status | Fix |
|-------|-----------|--------|-----|
| fuel=0 branches (3) | SuccChainFMCS.lean:5833,5991,6187 | EASY | Prove fuel > 0 invariant |
| `constrained_successor_seed_restricted_consistent` | SuccChainFMCS.lean:2529 | **FALSE** | Remove (documented counterexample) |
| Dead code (2) | SuccChainFMCS.lean:2190,2212 | DEAD | Remove |

---

## Appendix B: Literature References

### Primary Sources

- Blackburn, P., de Rijke, M., Venema, Y. (2001). *Modal Logic*. Cambridge University Press.
  - Chapter 4: Completeness via canonical models
  - Chapter 2.3: Filtration and FMP

- Gabbay, D., Hodkinson, I., Reynolds, M. (1994). *Temporal Logic: Mathematical Foundations and Computational Aspects*. Oxford University Press.
  - Step-by-step construction for temporal logic completeness
  - Eventuality handling via fair scheduling

- Gabbay, D., Kurucz, A., Wolter, F., Zakharyaschev, M. (2003). *Many-Dimensional Modal Logics: Theory and Applications*. Elsevier.
  - Chapter on product logics: S5 x temporal
  - Product FMP via finite depth method

- Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI Publications.
  - Chapter 3: Canonical models and completeness for temporal logics

### Relevant Papers

- Gabbay, D., Shehtman, V. (1998). "Products of modal logics, Part 1." *Logic Journal of the IGPL*, 6(1), 73-146.

- Gabbay, D., Shehtman, V. (2002). "Products of Modal Logics, Part 3: Products of Modal and Temporal Logics." *Studia Logica*, 72, 157-183.

- Reynolds, M. (2001). "An axiomatization of full computation tree logic." *Journal of Symbolic Logic*, 66(3), 1011-1057.

- Venema, Y. (2001). "Temporal Logic." Chapter 10 in *Handbook of Philosophical Logic*, 2nd ed.

### Web Sources Consulted

- Stanford Encyclopedia of Philosophy, "Temporal Logic": https://plato.stanford.edu/entries/logic-temporal/
- Hodkinson, I. and Reynolds, M. (2007). "Temporal Logic." Chapter 11 in *Handbook of Modal Logic*: https://cgi.csc.liv.ac.uk/~frank/MLHandbook/11.pdf
