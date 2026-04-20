# Teammate B Findings: Alternative Approaches for Chain Construction Sorries

## Key Findings

### 1. Quasimodel/BFMCS Infrastructure Assessment

The existing quasimodel infrastructure (`Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/`) is **not viable** as an alternative path. Key issues:

- **`qm_oracle_seed_subset_mcs`** (OracleStep.lean:72-79) already has its own sorry because `g_content(w) ⊆ w.formulas` requires the T-axiom (BX1), which was removed. The quasimodel path has the *same* root cause as the canonical model path.
- **`F_of_mem`** (Realization.lean:54-67) is sorry'd for the same reason: deriving `F(psi)` from `psi in w` requires `G(neg psi) in w -> neg psi in w` via BX1.
- **`refl_intro_until_mcs`** (Construction.lean:158-161) is sorry'd because `psi in w -> phi U psi in w` requires reflexive Until semantics.
- **`sigma_le_refl`** and **`sigma_strict_irrefl`** (SigmaOrdering.lean:80-99) are both sorry'd for the same BX1 removal reason.

**Conclusion**: The quasimodel infrastructure was designed for reflexive semantics and is thoroughly broken under irreflexive semantics. Leveraging it would require fixing *more* sorries, not fewer.

### 2. Textbook Completeness Proofs for Irreflexive Temporal Logic

Standard references handle irreflexive temporal semantics differently from reflexive:

**Burgess 1984 ("Basic Tense Logic")**: The original chain construction uses `G(phi) -> phi` (T-axiom) as a fundamental building block. Without it, Burgess's construction does not directly apply. His defect-discharge for Until uses the fact that the guard formula holds at the current point (from reflexive Until semantics).

**Gabbay, Hodkinson, Reynolds 1994 ("Temporal Logic: Mathematical Foundations")**: For strict (irreflexive) temporal operators:
- The completeness proof uses a **step-by-step method** (also called "completeness by construction") where the chain is built one step at a time.
- The key difference from reflexive: `G(phi)` at time `t` means `phi` holds at all `t' > t` (strict), so `phi` does NOT hold at `t` itself. The chain construction must handle this by ensuring `g_content(M)` flows to *successors* but not back to `M`.
- For F-resolution: `F(phi)` means `phi` at some strict future point. The standard approach is to ensure each F-formula is eventually resolved via a **fair scheduling** mechanism.

**Verbrugge 2007 ("Completeness by Construction")**: Uses a step-by-step construction where:
- Each step extends the chain by one point using Lindenbaum's lemma.
- The seed for the new point is `g_content(M)` (NOT `g_content(M) union {phi}` where phi = content of M).
- F-resolution is handled by cycling through all F-formulas and resolving one per step.
- **Critical insight**: Under strict semantics, `g_content(M) ⊆ M` is NOT assumed. Instead, the chain only guarantees `g_content(chain(n)) ⊆ chain(n+1)`.

This is exactly what the current codebase already does for the forward chain step. The sorry sites arise not from the basic step structure but from the **termination argument** for F-resolution and the **base case** where `m = n = 0`.

### 3. Deterministic Chain Construction

A deterministic chain construction (enumerating formulas, building X/Y-content chains) could theoretically avoid `Classical.choice` opacity issues with the termination argument. However:

- The codebase uses `Classical.choice` in exactly two places for the chain: `set_lindenbaum` (Lindenbaum extension) and `defect_step_choice_early` (choosing a resolving MCS).
- A deterministic construction would require:
  1. A well-ordering of all formulas (available via `Denumerable`)
  2. Explicit construction of the MCS at each step by formula enumeration
  3. This is essentially reimplementing Lindenbaum's lemma constructively
- **Cost**: Massive rewrite of the entire chain construction with no clear benefit. The `Classical.choice` opacity is not the actual blocker -- the blocker is the well-founded termination argument for `fwd_chain_forward_F`.

**Conclusion**: Not recommended. The effort-to-benefit ratio is very poor.

### 4. Filtration-Based Completeness

The codebase already has a substantial filtration infrastructure for the **Finite Model Property** (FMP) in `Theories/Bimodal/Metalogic/Decidability/FMP/`. This includes:
- `MCSFiltrationEquiv` (Filtration.lean): equivalence relation on closure MCS
- `FilteredWorld` (Filtration.lean): quotient type
- `ClosureMCSBundle` (ClosureMCS.lean): restricted MCS over subformula closure
- `TruthPreservation` (TruthPreservation.lean): truth preservation under filtration

**Could FMP imply completeness?** In principle, yes:
- FMP + soundness of the proof system gives: if `phi` is valid in all finite models, then `phi` is derivable.
- But FMP itself requires completeness to be useful (the standard FMP proof starts from "if phi is satisfiable, it's satisfiable in a finite model").
- **The existing FMP proof appears to be a separate decidability result**, not a completeness proof. It constructs finite countermodels from non-derivable formulas, which is exactly what completeness does.

However, examining `FMP.lean:57` (`exists_mcs_with_negation`), the FMP construction does construct a model from a non-derivable formula. If this construction is sorry-free, it could potentially serve as an *independent* completeness proof. But checking the sorry status of the FMP path would be needed.

**Key issue**: The FMP filtration collapses the temporal ordering to a finite quotient, which may not preserve Until/Since coherence (the same problem the canonical model has). The FMP path likely has its own sorry sites.

**Conclusion**: Potentially viable as a long-term alternative, but would require auditing the entire FMP path for sorries and likely faces similar Until/Since coherence issues.

### 5. The HintikkaStepOracle Pattern

The `HintikkaStepOracle` (in Boneyard `OracleStep.lean`) is a pattern where:
- Given a Hintikka point `h` with an Until defect `phi U psi` (where `psi` is absent), produce a successor Hintikka point `h'` satisfying `hintikka_step h h'`.
- The oracle is constructed from the MCS-level `qm_oracle_step`: Lindenbaum-extend `g_content(w) union {Until-defects}`, then project to sigma-signature.

**Status**: The oracle is in the Boneyard (deprecated). It has sorry sites from BX1 removal (`qm_oracle_seed_subset_mcs`). The oracle pattern itself is sound for sigma-signature inputs but breaks for general Hintikka points.

**Could it be revived?** The oracle pattern could work if the seed consistency proof is fixed. Under irreflexive semantics, `g_content(w) ⊆ w.formulas` fails, so `qm_oracle_seed ⊆ w.formulas` fails. But the seed `g_content(w) union {Until-defects}` *is* still consistent -- it just can't be proved by the subset argument. A direct consistency proof (similar to `enriched_resolving_seed_consistent`) would be needed.

**Conclusion**: The oracle pattern is structurally sound but requires the same consistency fixes as the main path. Not an independent solution.

### 6. Mathlib Infrastructure

**Available and relevant:**
- `Mathlib.Order.Zorn`: `zorn_subset` provides Zorn's lemma for subset ordering -- this is what backs `set_lindenbaum` (Lindenbaum's lemma). Already used.
- `Mathlib.Data.Finset.Card`: `Finset.strongInductionOn` provides well-founded induction on finsets by strict subset (`t ⊂ s -> p t`). This is directly applicable to the defect-count termination argument.
- `Finset.strongDownwardInduction`: Induction where `t₁ ⊂ t₂ → p t₂` gives `p t₁`. Also applicable.
- `Finset.exists_ne_map_eq_of_card_lt_of_maps_to`: Pigeonhole principle for finsets. Could be used to prove that defects must eventually repeat/decrease.
- `FirstOrder.Language.Theory.IsMaximal`: Mathlib has its own definition of maximal theories, but it's for first-order logic and not directly compatible.

**Not available:**
- Mathlib does NOT have a general Lindenbaum's lemma for propositional modal logic. The codebase's `set_lindenbaum` is custom-built.
- Mathlib does NOT have infrastructure for MCS in propositional logic contexts.

**Key recommendation**: Use `Finset.strongInductionOn` for the defect-count termination argument in `fwd_chain_forward_F`. The pattern would be:
1. Define the set of active F-defects as a `Finset` (already done: `active_defects`)
2. Show that each step either resolves a defect or preserves all defects (already done: `preserving_fwd_step_defect_preserved`, `resolving_enriched_fwd_exists`)
3. Apply `Finset.strongInductionOn` or well-founded recursion on `Nat` bounded by `sigma_list.length` to prove termination

## Recommended Approach

**Priority 1: Fix the genuinely false theorems (#5, #6) by deletion.**

`g_content_subset_self` and `h_content_subset_self` are genuinely false under irreflexive semantics and should be **removed entirely**. Their only consumers are `fwd_chain_g_content_trans` and `bwd_chain_h_content_trans` at the `m = n` base case. The fix:
- Change the base case from `m = n` (which needs `g_content(M) ⊆ M`) to a proper inductive argument
- At `m = n`, the goal `g_content(chain(m)) ⊆ chain(n)` becomes `g_content(chain(n)) ⊆ chain(n)`, which is false in general
- Instead, strengthen the induction: prove `g_content(chain(m)) ⊆ chain(n)` only for `m < n`, and handle `m = n` by not calling it (the consumers should use `m ≤ n` with an immediate `m < n` proof or handle equality separately)

Actually, the transitive g_content propagation is used with `h : m ≤ n`. At `m = n`, the goal is trivially `g_content(chain(n)) ⊆ chain(n)` which is NOT true under irreflexive semantics. The real fix is: **the consumers need to be modified to only use strict inequality `m < n`**, or the chain needs to carry formulas at the current point explicitly.

**Priority 2: Close `fwd_chain_forward_F` (#7) via well-founded induction on defect count.**

The preserving chain already has the key properties:
- At each step with defects, `resolving_enriched_fwd_exists` guarantees at least one defect `w` with `w in M'` (directly resolved).
- All other F-obligations are preserved (`chi in M' or F(chi) in M'`).
- The defect count (formulas in `sigma_list` with `F(chi) in M` but `chi not in M`) is bounded by `sigma_list.length`.

The termination argument:
1. Track `active_defects_finset(chain(n), sigma_list)` -- the set of sigma_list formulas with F-obligations.
2. At each step, `resolving_enriched_fwd_exists` gives a witness `w` directly resolved (`w in chain(n+1)`).
3. If `F(w) not in chain(n+1)`, then `w` leaves the active defect set (resolved without re-entry). Defect count decreases.
4. If `F(w) in chain(n+1)`, then `w` is both directly present AND F-protected. This doesn't obviously decrease the count.
5. **The gap**: We need to show that `w` being directly resolved means it's no longer a defect. Since `w in chain(n+1)`, it's resolved. But `F(w)` could also be in `chain(n+1)`, making `w` still an active defect at `chain(n+1)`.

This is the fundamental difficulty. The resolution of `w` at step `n+1` doesn't remove `w` from the active defect set because `F(w)` may persist. The defect set doesn't monotonically decrease.

**Alternative termination strategy**: Instead of tracking defect count, use the **BX11 ordering** (already implemented as `bx11_earlier`). At each step, the "earliest" defect is resolved. Since the ordering is finite (bounded by sigma_list), eventually all defects are resolved. This requires proving that the earliest defect at step `n` is eventually resolved, which follows from `target_stays_direct_in_fold`.

**Priority 3: Close `enriched_seed_consistent` (#1) and `enriched_past_seed_consistent` (#3).**

The enriched seed `g_content(M) ∪ f_carry(M)` needs to be shown consistent. Key insight: `f_carry(M) ⊆ M` (trivially, by definition). And `g_content(M)` is consistent (via `g_content_set_consistent`). The issue is that `g_content(M) ∪ f_carry(M)` may be inconsistent even though both parts are individually consistent.

A potential proof: Suppose `g_content(M) ∪ f_carry(M)` derives `bot`. Then there exist `L_g ⊆ g_content(M)` and `L_f ⊆ f_carry(M)` with `L_g ++ L_f ⊢ bot`. By deduction theorem on the L_f elements (which are F-formulas), we get `L_g ⊢ neg(conj(L_f))`. By generalized temporal K, `G(L_g) ⊢ G(neg(conj(L_f)))`. Since `G(chi) in M` for chi in L_g, we get `G(neg(conj(L_f))) in M`. But `conj(L_f)` is a conjunction of F-formulas from M, and `F(conj of F-formulas)` should be in M by BX11 linearity. This contradicts `G(neg(conj(L_f))) in M`.

This approach is promising but needs careful formalization of the conjunction of F-formulas.

**Priority 4: Remove `fwd_succ_f_carry` (#2) and `bwd_pred_p_carry` (#4).**

These are genuinely unprovable as stated (the non-resolving branch only seeds with `g_content(M)`, not `g_content(M) ∪ f_carry(M)`). The fix is to change the non-resolving branch of `fwd_succ` to seed with `g_content(M) ∪ f_carry(M)` (requiring `enriched_seed_consistent` from Priority 3), or to eliminate their use entirely.

Since the preserving chain (`fwd_chain_of_sigma`) in RootScopedChain.lean does NOT use `fwd_succ` for steps with active defects (it uses `defect_step_choice_early` instead), and for steps without defects `f_carry` is empty, these theorems may be dead code on the active path.

**Priority 5: Close temporal coherence (#8-#11).**

These depend on `fwd_chain_forward_F` (#7) being closed. Once F-resolution works:
- `restricted_tc` forward case follows from `fwd_chain_forward_F`
- `restricted_tc` backward case needs a symmetric `bwd_chain_backward_P`
- `restricted_buc` and `restricted_fuc` follow from restricted_tc + Until/Since axiom properties (BX9, BX10, BX12)

## Evidence/Examples

The preserving chain already has the core machinery:
- `resolving_enriched_fwd_exists` (RootScopedChain.lean:368): Guarantees a resolved witness at each step
- `target_stays_direct_in_fold` (RootScopedChain.lean:934): When target is BX11-earliest, it stays direct
- `bx11_earlier_total` (RootScopedChain.lean:837): BX11 ordering is total on F-defects
- `Finset.strongInductionOn` (Mathlib): Well-founded induction on finsets

The gap is connecting these pieces into a complete termination proof.

## Confidence Level

- **Quasimodel path not viable**: HIGH confidence (thoroughly broken by BX1 removal)
- **Deterministic chain not worth it**: HIGH confidence (massive rewrite, same blockers)
- **Filtration-based completeness**: LOW confidence (would need full audit, likely has own sorry sites)
- **Well-founded defect induction for forward_F**: MEDIUM confidence (machinery exists, but defect-count-decrease gap is real)
- **BX11-ordered resolution for forward_F**: MEDIUM-HIGH confidence (mathematically sound, needs careful formalization with `target_stays_direct_in_fold`)
- **Enriched seed consistency via G/F contradiction**: MEDIUM confidence (proof sketch works but conjunction-of-F-formulas step needs verification)
- **g_content_subset_self removal**: HIGH confidence (genuinely false, must be removed)
