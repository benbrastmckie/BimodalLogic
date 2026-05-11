# Teammate D (Horizons) Findings: Task 121

## Key Findings

### 1. The Icc_finite Sorry Cannot Be Bypassed Architecturally

After examining all plausible bypass routes, the `limitDomSubtype_Icc_finite` sorry must be proved directly. Every architectural alternative was evaluated against the project's constraints:

**Bypasses evaluated and rejected:**

| Alternative | Why It Fails |
|---|---|
| Build countermodel on LimitDomSubtype directly (skip ℤ-iso) | `valid` requires `AddCommGroup D`; LimitDomSubtype is not a group. MF/TF soundness proofs need time-shift invariance, which requires addition. Task 120 research (Approach A) confirms: INFEASIBLE (~100h refactor, high risk of breaking soundness). |
| Extend limit_f to all of ℚ (constant/nearest-predecessor) | Strict G-coherence breaks at gap points: `G(φ) ∈ limit_f(a)` does NOT give `φ ∈ limit_f(a)` since G is irreflexive. Task 120 research (Approach C) confirms: FAILS for strict semantics. |
| Prove IsSuccArchimedean without Icc_finite | The existing `limitDomSubtype_isSuccArchimedean` proof (lines 1074-1111) uses Icc_finite via pigeonhole — this is the cleanest approach. An alternative direct proof would essentially reprove that bounded intervals are finite anyway. |
| Use `Mathlib.Order.SuccPred.LinearLocallyFinite` | This provides `LocallyFiniteOrder` from `IsSuccArchimedean` + `SuccOrder` + `PredOrder`. But we need `Icc_finite` to PROVE `IsSuccArchimedean` — circular. |
| Task 120 semantic redesign | Task 120's research explicitly concludes (§1.3): "The `IsSuccArchimedean` sorry has nothing to do with `AddCommGroup`. It is a purely order-theoretic property." The redesign route doesn't touch this sorry. |
| Mosaic methods (Caleiro et al. 2013) | Their completeness theorem (Theorem 3.13) drops discreteness conditions (Udsc/Ddsc). They note (line 845) that discrete axiomatization is possible but in a different setting. Would require rebuilding the entire completeness architecture from scratch — estimated 200+ hours for uncertain payoff. |

### 2. Literature Gap: Reynolds 1994 Is Directly Relevant

The "Not Yet Obtained" paper **Reynolds 1994 "Axiomatising U and S over integer time" (ICTL 1994, LNCS 827)** is the most directly relevant unobtained paper for this task. It addresses exactly the discrete case that BX formalizes. Key reasons:

- Reynolds handles discrete (integer) time specifically
- Reynolds 1992 (which we HAVE) covers the reals; 1994 handles ℤ
- The paper likely contains either: (a) a proof strategy for transferring from a discrete canonical construction to ℤ, or (b) an axiom system where the transfer is trivial
- **Recommendation: Obtain this paper before investing heavily in Icc_finite proof attempts.** It may contain the exact insight needed for the finiteness argument, or an alternative discrete completeness strategy that avoids IsSuccArchimedean entirely.

Additionally, **Gabbay-Hodkinson-Reynolds 1994 monograph (Vol. 1)** likely contains detailed treatment of discrete completeness. It is the definitive reference and would be authoritative on whether the Icc_finite route is standard.

### 3. Venema's Axiom W = Prior-UZ

A key alignment: Venema 1993's axiom **W** is `Fp → U(p, ¬p)`, which is precisely the project's **Prior-UZ** axiom (added in task 119). Venema uses W to define well-orderings and proves `D ∧ W ∧ L ⟺ ω` (Lemma 3.3). This confirms that Prior-UZ is the correct axiom for discrete completeness, and the project's axiom system is aligned with the literature.

Venema's completeness strategy for (ω, <) is: prove BN-consistency → BW-consistency → linear model → definably well-ordered model → Doets transfer → ω-model. This uses expressive completeness (Kamp's theorem) as an essential tool, which is a fundamentally different approach from the chronicle construction.

### 4. Task 998 (FMP Redesign) Is Independent

Task 998 concerns `TruthPreservation.lean` sorries in the FMP filtration pipeline. These are about reflexive G/H closures (`mcs_all_future_closure`, `mcs_all_past_closure`) which are deprecated under strict semantics. Task 998 explicitly notes that `mcs_finite_model_property` does NOT use these sorry'd lemmas, so the FMP is already sorry-free. Task 998 is cleanup work, not on the critical path, and does not relate to the Icc_finite problem.

### 5. The Most Promising Proof Strategy Aligns With the Roadmap

The roadmap (line 339) describes the dependency chain: Tasks 107→117→119→121→122. Task 119 added Prior-UZ/SZ and built IsSuccArchimedean modulo finiteness. The proof strategy already chosen — pigeonhole via Icc_finite — is sound mathematics. The question is purely about formalizing the finiteness argument.

**Key structural fact**: Each `omega_chain_val(n).dom` is a `Finset Rat` (finite set). The limit domain `limit_dom = ⋃ n, omega_chain_val(n).dom` is countably infinite. For any `a, b ∈ limit_dom`, both enter at some finite stage N. The intersection `limit_dom ∩ [a.val, b.val]` is contained in `⋃_{n ≤ M} omega_chain_val(n).dom` for some M — this is the key insight that needs to be formalized.

### 6. Creative Alternative: Direct Induction Without Icc_finite

There's a potentially simpler approach that bypasses Icc_finite entirely: **prove IsSuccArchimedean directly by strong induction on the stage N where both a and b enter the omega chain.**

The argument: if `a, b ∈ omega_chain_val(N).dom` with `a < b`, then the set `omega_chain_val(N).dom ∩ (a, b]` is finite (it's a subset of a `Finset`). The succ function on LimitDomSubtype picks the C5 witness, which at stage N must be in `omega_chain_val(N+k).dom` for some k. By induction on `|omega_chain_val(N).dom ∩ (a, b]|`, each succ step either stays within this finite set or exits it — but it can't exit because of the SuccOrder property.

This sidesteps the need to reason about ALL of limit_dom ∩ [a,b] and instead works within a single finite chronicle stage. However, the complication is that `succ(x)` might not be in `omega_chain_val(N).dom` — it's a C5 witness that might first appear at a later stage. This needs careful handling.

## Recommended Approach

**Short term (task 121)**: Prove `limitDomSubtype_Icc_finite` directly. The omega chain structure provides the key tool: for a ≤ b with both in `omega_chain_val(N).dom`, the set `{x ∈ LimitDomSubtype | a ≤ x ∧ x ≤ b}` is bounded above by the finite set `omega_chain_val(M).dom` for sufficiently large M. The finiteness argument should go: every x in the interval [a,b] of LimitDomSubtype has x.val ∈ limit_dom, so x.val ∈ omega_chain_val(n_x).dom for some n_x. The injection into ℚ (subtype inclusion) maps [a,b] ∩ LimitDomSubtype into [a.val, b.val] ∩ ℚ. Since LimitDomSubtype has a discrete SuccOrder, consecutive points have gaps between them in ℚ, so only finitely many can fit in a bounded rational interval.

**Medium term**: Obtain Reynolds 1994 to validate the approach and potentially discover a cleaner proof strategy.

**Long term**: The project is 2 sorries from sorry-free `bx_completeness`. This is a pure engineering problem, not a mathematical impossibility. The architectural decisions (chronicle construction, Prior-UZ axioms, pigeonhole strategy) are all sound and aligned with the literature.

## Evidence/Examples

- Task 120 research report §3.6 (Approach F): "This is the right approach. The sorry can likely be filled by induction on |omega_chain_val(N).dom ∩ (a.val, b.val]|."
- Venema 1993 Lemma 3.3: Prior-UZ (= axiom W) characterizes discreteness
- Chronicle structure: `dom : Finset Rat` guarantees finite domains at each stage
- `omega_chain_dom_mono`: domain monotonicity ensures stage-based reasoning is valid

## Confidence Level

**High** — that Icc_finite must be proved directly (all architectural alternatives fail).
**Medium** — on the specific proof strategy (omega chain stage induction vs. direct rational embedding argument). Reynolds 1994 could clarify the best approach.
**High** — that this is a solvable engineering problem, not a mathematical impossibility.
