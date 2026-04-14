# Teammate B Findings: Alternative Approaches

## Key Findings

1. **Forward_F and backward_P (sorries 1 and 2) are structurally blocked for the current scheduling chain.** The obstacle analysis in CanonicalModel.lean lines 493–510 is confirmed correct. At resolving steps, the forward witness seed is `{chi} ∪ g_content(M)` (from `forward_temporal_witness_seed` in WitnessSeed.lean:50), which excludes f_carry. F-formulas for other than the resolved chi can be lost. This is an inherent obstacle of the current chain, not a localized gap.

2. **The restricted_buc sorry (line 649) does NOT require forward_F.** It only needs a step transfer property: `(φ U ψ) ∈ fam.mcs (r+1) ∧ φ ∈ fam.mcs r → (φ U ψ) ∈ fam.mcs r`. The infrastructure in `UntilSinceCoherence.lean` (`backward_until_from_step`, line 111; `backward_since_from_step`, line 145) is already built for exactly this purpose.

3. **The restricted_fuc sorry (line 655) does require something analogous to forward_F.** Forward Until coherence says: `(φ U ψ) ∈ fam.mcs t → ∃ s ≥ t, ψ ∈ fam.mcs s ∧ guard`. The guard (φ in all intermediate positions) is what makes this hard — it requires either the quasimodel chain structure or an axiom-level argument connecting BX10 (`(φ U ψ) → F(ψ)`) with positional content.

4. **The step-transfer property needed for restricted_buc is potentially provable from the enriched seed.** The fwd_succ non-resolving case uses seed `g_content(M) ∪ f_carry(M)` (CanonicalModel.lean:79). If `(φ U ψ) ∈ M` and `ψ ∉ M`, then `φ U ψ ∈ f_carry(M)` is false (f_carry is only F-formulas by definition at line 52: `{φ ∈ M | ∃ χ, φ = Formula.some_future χ}`). So Until formulas are NOT in f_carry. This means the enriched seed does NOT carry Until formulas through non-resolving steps either.

5. **The restricted_buc step transfer requires a new seed enrichment** — adding Until formulas whose goals are absent (defective Until formulas) to the non-resolving successor seed. This parallels the f_carry idea but for Until formulas.

6. **Path 4 (compactness/ultrafilter) is likely nonconstructive overkill** but is a genuine mathematical option. The key difficulty is that `BFMCS Int` requires a specific Int-indexed chain, not just an abstract coherent family; the compactness approach would yield existence without the explicit Int indexing needed.

---

## Path Analysis

### Path 1: Restricted forward_F via deferralClosure scheduling

**Verdict: UNCERTAIN (weakly viable with significant restructuring)**

The idea: schedule only formulas in `deferralClosure(root)` (a finite set), cycling through them so each F(ψ) for ψ ∈ deferralClosure(root) is resolved infinitely often. The seed at resolving steps for chi could include all of `f_carry(M) ∩ {F(ψ) | ψ ∈ deferralClosure(root)}`.

**Why it might work**: The counterexample to unrestricted enrichment (`G(F(alpha) → ¬ψ) ∈ M, F(alpha) ∈ M, F(ψ) ∈ M`) requires an inconsistency between F(alpha) and F(ψ) mediated by a G-formula. Within deferralClosure(root), the F-formulas are bounded and their potential interactions are finitely many. If we can show the finite set `{chi} ∪ g_content(M) ∪ {F(ψ) | ψ ∈ deferralClosure(root), F(ψ) ∈ M}` is consistent, this works.

**Why it might not work**: The counterexample from the obstacle analysis does not require arbitrarily many F-formulas — it uses just two (`F(alpha)` and `F(ψ)`) connected by `G(F(alpha) → ¬ψ)`. These two could both be in deferralClosure(root) simultaneously. So restricted enrichment does NOT avoid the inconsistency counterexample in general.

**Assessment**: This path does not cleanly avoid the root obstacle. The enrichment remains potentially inconsistent even within deferralClosure(root). It would require an additional structural argument (e.g., that the BX axioms prevent `G(F(alpha) → ¬ψ)` and `F(alpha)` and `F(ψ)` from all being in the same deferralClosure-bounded MCS), which seems unlikely to hold in general.

### Path 2: Direct restricted_buc/restricted_fuc without forward_F

**Verdict: VIABLE for restricted_buc; BLOCKED for restricted_fuc**

**For restricted_buc (line 649):**

The sorry is:
```lean
constructor <;> (intro t φ ψ _h_sub ⟨r, h_le, h_psi, h_guard⟩; sorry)
```

This calls for: given `r ≥ t`, `ψ ∈ fam.mcs r`, and `φ ∈ fam.mcs` at all intermediates, show `(φ U ψ) ∈ fam.mcs t`.

The `backward_until_from_step` in UntilSinceCoherence.lean:111 reduces this to proving the step transfer:
```
∀ r : Int, (φ U ψ) ∈ fam.mcs (r + 1) → φ ∈ fam.mcs r → (φ U ψ) ∈ fam.mcs r
```

This step transfer is NOT trivially derivable from the current fwd_succ construction because:
- At a resolving step for chi ≠ φ U ψ: seed is `{chi} ∪ g_content(M)`, which includes only G-formulas and chi. Until formulas are not G-formulas, so `(φ U ψ)` is dropped.
- At a non-resolving step: seed is `g_content(M) ∪ f_carry(M)`. Since `(φ U ψ) ∉ f_carry(M)` (f_carry only contains F-formulas by CanonicalModel.lean:52), Until formulas are also dropped.

**Conclusion for restricted_buc**: The step transfer property CANNOT be derived from the current chain construction without modifying the seeds. A new "u_carry" (Until-carry, tracking defective Until formulas) would need to be added to both resolving and non-resolving seeds. This requires verifying consistency of the enriched seed, which has its own obstacles.

**For restricted_fuc (line 655):**

The sorry is:
```lean
constructor <;> (intro t φ ψ _h_sub h_mem; sorry)
```

Forward Until coherence says: `(φ U ψ) ∈ fam.mcs t → ∃ s ≥ t, ψ ∈ fam.mcs s ∧ φ ∈ all intermediates`.

By BX10 (`(φ U ψ) → F(ψ)`, proved at line 139 of Construction.lean), we get `F(ψ) ∈ fam.mcs t`. If forward_F were proved, we'd have `∃ s > t, ψ ∈ fam.mcs s`. But we also need the guard condition (φ at intermediates), which forward_F alone cannot provide. The guard requires additional chain content structure (BX5 self-accumulation plus chain propagation), which is what the quasimodel approach addresses.

**Conclusion for restricted_fuc**: Directly provable from forward_F + chain guard structure, but forward_F itself is blocked. No shortcut that bypasses forward_F is visible.

### Path 3: Modified BFMCS definition

**Verdict: VIABLE (substantial restructuring, may simplify the proof)**

The current `bx_bfmcs` (line 529–532) defines families as shifted versions of the int-indexed chain. The coherence proofs all reduce to `bx_fmcs_forward_F` for the temporal component and to the Until step-transfer for the Until component.

An alternative: define `bx_bfmcs` using quasimodel chains as the underlying FMCS structure. The quasimodel chain (from Quasimodel/Construction.lean) uses the `hintikka_step` relation which explicitly includes Until defect propagation (line 51–52). If the FMCS families were built from quasimodel-extended Int-chains, then:
- forward_F would follow from the schedule (every F(ψ) is eventually resolved)
- Until step transfer would follow from hintikka_step's Until defect propagation rule

**Obstacle**: The current quasimodel infrastructure (`HintikkaPoint`, `hintikka_step`) operates on finite Sigma-bounded formula sets (Quasimodel/HintikkaPoint.lean), not on full MCS. Lifting to the MCS level would require significant additional work. The `Realization.lean` file has already started this lifting but delegates to Frame.lean sorries.

**Assessment**: This is essentially the quasimodel approach that prior research rounds have converged on. It is the correct path but requires substantial implementation.

### Path 4: Compactness / nonconstructive existence

**Verdict: UNCERTAIN (mathematically valid, but architecturally problematic)**

Mathlib has `Filter.Ultrafilter` and Zorn's lemma (`zorn_le`). A compactness argument could potentially show: there exists an FMCS Int with temporal coherence and Until coherence, by constructing it as a limit of finite approximations or via an ultrafilter.

**Why it is architecturally problematic**:
1. The FMCS is indexed by `Int`, and the truth lemma requires knowing that specific formulas belong to specific time-indexed MCS positions. A compactness argument gives existence but may not give the explicit Int-indexed structure needed.
2. The `bx_bfmcs` definition (line 529) hard-codes the shifted scheduling chain structure for modal coherence purposes (families are parametrized by modal equivalence classes). A compactness-based FMCS would need to separately satisfy modal_forward and modal_backward properties.
3. The connection to the specific `root` formula (for restricted coherence) would need to be established separately.

**What compactness could give**: Given an MCS M₀ and formula root, construct by ultrafilter a coherent model that satisfies root. This is the standard "canonical model via ultrafilter" approach used in modal logic completeness. However, for temporal logic with F/G operators, the ultrafilter construction needs to be on a product space indexed by Int, and verifying forward_F/backward_P for the resulting MCS sequence is non-trivial.

**Assessment**: This is a genuine theoretical alternative but requires more infrastructure than the quasimodel approach and does not obviously simplify the Lean 4 proof.

---

## Recommended Fallback

If the quasimodel approach (Plan v11) is blocked, the most promising alternative is:

**Path 3 with focused scope: Prove restricted_buc directly by enriching the non-resolving seed with a "u_carry" of defective Until formulas, independently of forward_F.**

Specifically:

1. Define `u_carry(M) = {φ U ψ ∈ M | ψ ∉ M}` (defective Until formulas in M).

2. Define `p_carry_until(M) = {φ S ψ ∈ M | ψ ∉ M}` (defective Since formulas in M).

3. Enrich the non-resolving fwd_succ seed from `g_content(M) ∪ f_carry(M)` to `g_content(M) ∪ f_carry(M) ∪ u_carry(M)`.

4. Verify the enriched seed is consistent. The key check: can `g_content(M) ∪ f_carry(M) ∪ u_carry(M)` be inconsistent? This requires showing there is no M where `G(¬φ) ∈ M` for some φ ∈ u_carry(M). Since `φ U ψ ∈ M` implies `F(ψ) ∈ M` (BX10) and `G(¬(φ U ψ))` implies `¬(φ U ψ) ∈ M`, but `φ U ψ ∈ M` is already in the seed, consistency follows from M's own consistency.

5. Prove the step transfer: if `(φ U ψ) ∈ chain(n+1)` and `φ ∈ chain(n)`, and chain(n+1) was built with a non-resolving step for chi ≠ φ U ψ, then by fwd_succ's u_carry enrichment, `(φ U ψ) ∈ u_carry(chain(n))` implies `(φ U ψ) ∈ chain(n+1)`.

**Note**: This approach closes restricted_buc independently of forward_F. It does NOT close restricted_fuc or the forward_F/backward_P sorries. Those still require the quasimodel approach.

The four sorry sites thus decompose into:
- restricted_buc (line 649): potentially closable via u_carry enrichment (independent of forward_F)
- restricted_fuc (line 655): requires forward_F or quasimodel
- bx_fmcs_forward_F (line 518): requires quasimodel chain replacement
- bx_fmcs_backward_P (line 525): requires quasimodel chain replacement (symmetric)

---

## Confidence Level

**Medium** — with the following caveats:

- The finding that restricted_buc is independent of forward_F is **high confidence** (structural observation from the code: `backward_until_from_step` in UntilSinceCoherence.lean:111 shows the exact reduction).

- The finding that u_carry enrichment avoids the known inconsistency counterexample is **medium confidence** (the counterexample targets F-carry, not Until-carry; the consistency argument in step 4 above seems sound but needs formal verification).

- The finding that restricted_fuc and forward_F/backward_P require quasimodel or equivalent is **high confidence** (the forward coherence problem requires knowing WHERE ψ is realized, not just that F(ψ) holds; this requires chain-structural arguments that the current scheduling chain cannot provide).

- Assessment of Path 4 (compactness) is **low confidence** — the approach is theoretically sound but the Lean 4 implementation difficulty is hard to estimate without attempting it.
