# Teammate C: Critic — Mathematical Correctness Validation (R07)

## Summary

This report validates the mathematical correctness of the four approaches proposed for
proving `bx_fmcs_forward_F`. The existing scheduling chain construction in
`CanonicalModel.lean` is the current implementation; approaches 1-4 are modifications
or alternatives. Approach 5 (quasimodel) is already partially implemented.

---

## Key Findings

**FLAW (Approach 1a): The deferral disjunction `chi ∨ F(chi)` need NOT be in M.**
The proposal assumes that when `F(chi) ∈ M`, the disjunction `chi ∨ F(chi)` is also
in M and can be used as a seed ingredient. This is trivially true (`chi ∨ F(chi)` is
derivable from `F(chi)` alone via prop_s: `⊢ F(chi) → (chi ∨ F(chi))`), but the
proposed "deferral disjunction seed" does not actually solve anything. Adding `chi ∨ F(chi)`
to a seed does not force the Lindenbaum extension to contain `chi`. Lindenbaum extension
maximizes consistency — `chi ∨ F(chi)` is in the seed, so it will be in the extension,
but the extension may also contain `neg(chi)`, forcing `F(chi)` to be chosen (as
`neg(chi) ∧ (chi ∨ F(chi)) → F(chi)` in any MCS). This does NOT resolve `chi`.

**FLAW (Approach 1b): The WFI argument breaks at resolving steps.**
The argument claims: "well-founded induction on F-nesting depth in deferralClosure(root)
prevents infinite deferral." But the induction is on formulas in deferralClosure, and
the chain has NO mechanism ensuring that F(phi) at step n IMPLIES phi at step n+1 or
F(phi) at step n+1. The `f_carry` mechanism guarantees `F(chi) ∈ fwd_succ(M, psi)`
when `F(psi) ∉ M` (non-resolving step), but `f_carry` is NOT included in resolving
seeds. So at the resolving step (when `F(psi) ∈ M`), the seed is:
`{psi} ∪ g_content(M)` — NOT including `f_carry(M)`. F-formulas other than F(psi)
can be LOST at this step. The WFI argument provides no recovery mechanism for this loss.

**FLAW (Approach 1c): Lost F-formulas cannot be recovered by WFI.**
Even if F(chi) appears infinitely often in the schedule (which `schedule_surjective_above`
guarantees), the chain at the step where F(chi) would be scheduled to resolve may not
CONTAIN F(chi) anymore, because it was lost at an earlier resolving step for some
unrelated formula. The schedule surjectivity argument ensures that every formula
eventually targets resolution, but it does NOT ensure the formula still holds at
the scheduled step.

**CONFIRMED (Approach 3): The DeterministicChain boneyard IS fundamentally broken for BX.**
The `sorry /- temp_4 removed in BX -/` annotations in DeterministicChain.lean are
ANACHRONISTIC. `temp_4` (G(phi) → G(G(phi))) IS in BX (Axiom.temp_4, line 112 of
Axioms.lean). However, `YX_round_trip` and `XY_round_trip` require `y_det`, `x_det`,
`y_k_dist`, and `x_k_dist` which ARE genuinely removed from BX (these are discrete-only
axioms for the Next/Yesterday operators). The deterministic chain requires x_content and
y_content to be MCS-preserving, which needs x_det/y_det. These cannot be derived in BX.

**CONFIRMED (g_content ⊆ M): g_content(M) ⊆ M IS derivable in BX.**
Via BX1 (temp_t_future: G(phi) → phi). This is proved in `g_content_subset_self`
at CanonicalModel.lean:230. Similarly for h_content via BX1'.

**CONFIRMED (g_content ⊆ x_content): NOT applicable.**
x_content is NOT defined in the current BX construction (no X/Y operators). The
scheduling chain uses g_content, not x_content. The question about x_content only
applies to the boneyard DeterministicChain, which is not a viable path.

**CONFIRMED (Approach 2): Backward Until port is NOT viable with the scheduling chain.**
The scheduling chain does NOT have the property `chain(n+1) = x_content(chain(n))`.
It uses Lindenbaum extension from `{psi} ∪ g_content(M)` or `g_content(M) ∪ f_carry(M)`.
The `x_mem_chain_general` property requires `phi ∈ chain(n+1) ↔ X(phi) ∈ chain(n)`,
which is definitionally false for the scheduling chain. The weaker substitute
`g_content(chain(n)) ⊆ chain(n+1)` does NOT suffice for until_intro, because
until_intro needs to go BACKWARD: from `psi ∨ (phi ∧ (phi U psi)) ∈ chain(n+1)`,
derive `X(psi ∨ (phi ∧ (phi U psi))) ∈ chain(n)`. Without X, this backward step
is impossible.

---

## Validation Results

### Approach 1: Deferral seeds + WFI

**Is `chi ∨ F(chi)` in M when `F(chi) ∈ M`?**
Yes. By prop_s: ⊢ F(chi) → (chi ∨ F(chi)). By MCS implication_property, `chi ∨ F(chi) ∈ M`.
So this ingredient IS validly derivable. However, this is not the bottleneck.

**Does adding deferral disjunctions to the resolving seed preserve consistency?**
Yes trivially: `{psi} ∪ g_content(M) ∪ {chi ∨ F(chi) | F(chi) ∈ M}` is a subset of M
(since g_content(M) ⊆ M via BX1, and `chi ∨ F(chi) ∈ M` as shown above), so consistent.

**FLAW: Does the resolving seed with deferral disjunctions force chi to appear?**
No. Having `chi ∨ F(chi)` in the seed does not force `chi` into the Lindenbaum extension.
The extension may still choose `neg(chi)` (making `F(chi)` hold via the disjunction), or
may choose `chi` (resolving). There is no proof obligation that `chi` lands in the extension
rather than `neg(chi)`.

**Does WFI terminate?**
The termination claim ("deferralClosure is finite, so infinite deferral is impossible")
confuses FINITE CLOSURE SIZE with GUARANTEE OF RESOLUTION. The deferralClosure being
finite means there are finitely many F-formulas to resolve. But the schedule is infinite
— the claim must be that the chain eventually resolves each F-formula. The WFI argument
provides no constructive bound on WHEN a formula is resolved, only that each formula
has finite nesting depth. This does not prevent a single F-formula from being lost at
one resolving step and never reappearing.

**CRITICAL STRUCTURAL FLAW:**
At step n, when resolving F(psi): seed = `{psi} ∪ g_content(chain(n))`. The `f_carry`
mechanism is ONLY activated for NON-resolving steps (see `fwd_succ_f_carry` at
CanonicalModel.lean:108-114, which has hypothesis `h_not_F : Formula.some_future ψ ∉ M`).
At the resolving step, f_carry is NOT included. Therefore, any `F(chi) ∈ chain(n)` for
`chi ≠ psi` may NOT be in `chain(n+1)`. The deferral disjunction `chi ∨ F(chi)` also
does not appear in the resolving seed. So `F(chi)` can simply vanish.

**Verdict: APPROACH 1 IS MATHEMATICALLY FLAWED.** The deferral disjunction is derivable
but does not help. The f_carry loss at resolving steps is a fundamental obstruction
that deferral disjunctions do not address.

### Approach 2: Port backward Until from deterministic chain

**Can `until_intro` work with the scheduling chain?**
No. The backward Until argument in DeterministicChain.lean uses:
  `phi ∈ chain(n+1) ↔ X(phi) ∈ chain(n)`
which holds because `chain(n+1) = x_content(chain(n))` by definition. The scheduling
chain does NOT satisfy this equivalence. There is no X operator and no
`chain(n+1) = something(chain(n))` that is invertible.

**Is `g_content(chain(n)) ⊆ chain(n+1)` sufficient for backward Until?**
No. The backward direction requires: `(psi ∨ (phi ∧ (phi U psi))) ∈ chain(n+1)` implies
something in `chain(n)`. The inclusion `g_content(chain(n)) ⊆ chain(n+1)` only goes
FORWARD. To go backward, we would need h_content propagation, which goes in the OPPOSITE
temporal direction of what we need here.

**Verdict: APPROACH 2 IS NOT VIABLE for the scheduling chain.**

### Approach 3: Replace with deterministic chain

**Is `temp_4` available in BX?**
YES. `Axiom.temp_4 (φ : Formula)` at line 112 of Axioms.lean is present. The
`sorry /- temp_4 removed in BX -/` comments in the DeterministicChain boneyard are
ANACHRONISTIC — they predate the current BX axiom system. `SetMaximalConsistent.all_future_all_future`
uses `Axiom.temp_4` and is used freely in the current `CanonicalModel.lean`.

**Are `y_det`, `x_det`, `x_k_dist`, `y_k_dist` derivable in BX?**
NO. These are discrete-only axioms for Next (X = ⊥ U phi) and Yesterday (Y = ⊥ S phi):
- `x_det`: `¬X(phi) → X(¬phi)` (determinism of Next)
- `y_det`: `¬Y(phi) → Y(¬phi)` (determinism of Yesterday)
- `x_k_dist`: K-distribution for X
- `y_k_dist`: K-distribution for Y

None of these are in the BX axiom set (see Axioms.lean, 37 constructors listed, none
involve X/Y). They require discrete frame conditions. BX targets ALL linear orders, not
just discrete ones. These axioms are NOT derivable in BX — they fail on dense orders.

**CONFIRMED: DeterministicChain is FUNDAMENTALLY BROKEN for BX.**
The x_content MCS preservation theorem `x_content_mcs` (which says x_content of an MCS
is again an MCS) requires x_det/y_det. Without these, x_content of an MCS is merely
a consistent set, not necessarily maximal. The entire deterministic chain structure
collapses without MCS preservation.

**Verdict: APPROACH 3 IS FUNDAMENTALLY BROKEN. Cannot be repaired within BX.**

### Approach 4: Hybrid chain

Not yet specified in enough detail to validate formally. The hybrid approach would need to:
1. Use the scheduling chain's Lindenbaum extension (which works)
2. Somehow guarantee F-formula persistence across resolving steps (which is the hard part)

The critical question for any hybrid: how does it handle the f_carry loss at resolving
steps? If it adds f_carry to resolving seeds, consistency must be verified
(`{psi} ∪ g_content(M) ∪ f_carry(M)` — is this consistent?). Answer: YES, because
`{psi} ∪ g_content(M) ∪ f_carry(M) ⊆ {psi} ∪ M` and {psi} ∪ M is consistent when
F(psi) ∈ M (by the existing seed consistency proof). So this enrichment is consistent.

**This is the key positive finding: adding f_carry to the RESOLVING seed is consistent.**
Current code only adds f_carry to non-resolving seeds. If f_carry were added to BOTH
resolving and non-resolving seeds, F-formulas would persist across ALL steps.

### Approach 5: Quasimodel (GHR 1994)

Already partially implemented at `BXCanonical/Quasimodel/`. The quasimodel approach
avoids the forward_F problem by building witness sets directly rather than relying
on chain coherence. This is the cleanest approach mathematically and does not require
the forward_F sorry to be proved for the chain.

---

## Evidence / Examples

### Example: f_carry loss at resolving step

Let the chain have:
- `chain(0) = M₀` containing `F(phi)`, `F(chi)`, `G(alpha)`
- Step 0 resolves `F(phi)` (since `schedule(0)` = phi):
  - Resolving seed: `{phi} ∪ g_content(M₀)` = `{phi, alpha, ...}`
  - `F(chi)` is NOT in the seed (not in g_content, not in {phi})
  - Lindenbaum extension may contain `neg(F(chi))`
  - So `chain(1)` need not contain `F(chi)`
- `F(chi)` is permanently lost if `neg(F(chi))` enters chain(1)

The schedule will eventually target chi. At step n where `schedule(n) = chi`, the step
checks if `F(chi) ∈ chain(n)`. If `chain(n)` does not contain `F(chi)`, the step is
NON-resolving, takes the non-resolving seed `g_content(chain(n)) ∪ f_carry(chain(n))`,
and chi is not forced. `F(chi)` is satisfied only if the MODEL has a future witnessing chi,
but the CHAIN may not.

### Example: temp_4 IS available

```
-- Working proof in CanonicalModel.lean (not boneyard):
theorem fwd_chain_g_content_trans (M₀ h₀) {m n : Nat} (h : m ≤ n) :
    g_content (fwd_chain M₀ h₀ m).val ⊆ (fwd_chain M₀ h₀ n).val := by
  ...
  have h_GG := SetMaximalConsistent.all_future_all_future (fwd_chain M₀ h₀ m).property hφ
  -- ↑ Uses Axiom.temp_4, works in BX
```

### Positive finding: enriched resolving seed is consistent

If the forward seed is changed to `{psi} ∪ g_content(M) ∪ f_carry(M)`, consistency holds
because this set is ⊆ `{psi} ∪ M` and `{psi} ∪ M` is consistent (provable by the same
argument as `forward_temporal_witness_seed_consistent`). This would make F-formulas
persist across ALL steps, providing the missing persistence needed for `forward_F`.

**However**: even with full F-persistence, proving `forward_F` requires showing the chain
ACTUALLY RESOLVES each F-formula. Persistence is necessary but not sufficient. The
resolution guarantee needs the schedule surjectivity plus showing that F(chi) persists
until step n where `schedule(n) = chi`, at which point the resolving seed contains chi.
With full persistence this argument would close — if F(chi) is in chain(0) and persists
to every chain step (because f_carry is always included), then when step n schedules chi,
F(chi) ∈ chain(n) holds, the resolving seed contains chi, and chi ∈ chain(n+1).

**This suggests the correct fix: Include f_carry in the resolving seed.**

---

## Confidence Level

| Claim | Confidence |
|-------|-----------|
| Approach 1 deferral disjunction is derivable | HIGH |
| Approach 1 WFI argument is flawed (f_carry loss) | HIGH |
| Approach 2 not viable for scheduling chain | HIGH |
| Approach 3 temp_4 IS in BX (boneyard comments outdated) | HIGH |
| Approach 3 x_det/y_det not in BX (not derivable) | HIGH |
| Deterministic chain fundamentally broken for BX | HIGH |
| g_content(M) ⊆ M via BX1 | HIGH (proved in code) |
| Enriched resolving seed {psi} ∪ g_content ∪ f_carry is consistent | HIGH |
| f_carry inclusion in resolving seed would enable forward_F proof | MEDIUM |

---

## Recommended Action

The most mathematically sound path is:

**Fix the scheduling chain by including f_carry in the resolving seed.**

Change `fwd_succ` so that BOTH resolving and non-resolving seeds include `f_carry(M)`:
- Resolving: `{psi} ∪ g_content(M) ∪ f_carry(M)`  (currently: `{psi} ∪ g_content(M)`)
- Non-resolving: `g_content(M) ∪ f_carry(M)` (unchanged)

With this change:
- Consistency of the resolving seed is preserved (proved above)
- `psi` is still resolved when `F(psi) ∈ M` (psi is explicitly in the seed)
- F-formulas persist across ALL steps (including resolving ones)
- forward_F proof: if `F(chi) ∈ chain(t)`, by full persistence `F(chi) ∈ chain(n)` for
  all n ≥ t. Let n be the step where `schedule(n) = chi`. Then F(chi) ∈ chain(n), the
  seed contains chi, and by the resolving branch chi ∈ chain(n+1), with n+1 > t. QED.

The critical issue to verify is whether adding f_carry to the resolving seed breaks
any existing properties (e.g., the g_content step property, the MCS property). It does
not: MCS is by Lindenbaum; g_content step holds because g_content(M) is still in the seed.

**Do NOT pursue Approaches 2 or 3.** Approach 2 requires X-operator backward linkage
that the scheduling chain structurally cannot provide. Approach 3 requires removed axioms.
