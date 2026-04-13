# Teammate B Findings: Until/Since Coherence (buc/fuc)
## Report 05 — Alternative Approaches for bx_bfmcs_restricted_buc and bx_bfmcs_restricted_fuc

---

## Executive Summary

The two restricted Until/Since coherence sorries at lines 617-627 of
`CanonicalModel.lean` are HARD BLOCKERS. The backward Until coherence (buc)
requires a "step transfer" property that is **not directly derivable** from the
current BXCanonical chain structure. The forward Until coherence (fuc) depends
on `bx_fmcs_forward_F` (line 493-497), which is also a sorry.

Both sorries form a dependency chain:
- `bx_bfmcs_restricted_fuc` depends on `bx_fmcs_forward_F` (the F-eventuality resolver)
- `bx_bfmcs_restricted_buc` requires step transfer for backward Until, which is not
  available from bare g_content/h_content structure alone

---

## Key Findings

### Finding 1: The Step Transfer Problem for Backward Until (buc)

The parameterized lemma `backward_until_from_step` (UntilSinceCoherence.lean:111)
reduces backward Until to a single-step hypothesis:
```
h_step : ∀ r : Int, (φ U ψ) ∈ chain(r+1) → φ ∈ chain(r) → (φ U ψ) ∈ chain(r)
```

The module comment in UntilSinceCoherence.lean explicitly states this is **not
derivable** from bare FMCS structure (g_content/h_content).

**What we have in the chain:**
- `g_content(chain(r)) ⊆ chain(r+1)`: G(α) ∈ chain(r) → α ∈ chain(r+1)
- `h_content(chain(r+1)) ⊆ chain(r)`: H(α) ∈ chain(r+1) → α ∈ chain(r)

**The attempted route via BX4' (connect_past):**
- BX4': φ → H(F(φ)). Applied at chain(r+1): if (φ U ψ) ∈ chain(r+1), then
  H(F(φ U ψ)) ∈ chain(r+1).
- By h_content: F(φ U ψ) ∈ chain(r).
- This gives F(φ U ψ) ∈ chain(r), NOT (φ U ψ) ∈ chain(r).
- F(φ U ψ) ∈ chain(r) cannot be upgraded to (φ U ψ) ∈ chain(r) without a witness.

**Why or_until_in_mcs does not directly apply:**
`or_until_in_mcs` says: `ψ ∨ (φ ∧ (φ U ψ)) ∈ M → (φ U ψ) ∈ M`.
To use this at chain(r), we'd need `ψ ∨ (φ ∧ (φ U ψ)) ∈ chain(r)`.
We have φ ∈ chain(r) (the guard hypothesis), but not (φ U ψ) ∈ chain(r) — that's
what we're trying to prove.

**Why the deterministic chain works but BXCanonical doesn't:**
The boneyard `DeterministicFMCS.lean` (line 341-396) proves backward Until using
`x_mem_chain_general` which provides: `α ∈ chain(n+1) ↔ X(α) ∈ chain(n)` where
X = ⊥ U · is the "next" operator. This gives exact step transfer. The BXCanonical
construction dropped X-content, and the f_carry mechanism only carries F-formulas,
not X-formulas or Until-formulas.

**Conclusion for buc:** The step transfer cannot be proved for the current
`bx_bfmcs` construction without additional chain properties. There is no BX axiom
that directly gives `(φ U ψ) ∈ chain(r)` from `(φ U ψ) ∈ chain(r+1)` and
`φ ∈ chain(r)`.

### Finding 2: The Forward Until Coherence Depends on bx_fmcs_forward_F

The sorry at lines 623-627 (`bx_bfmcs_restricted_fuc`) unfolds to:
```lean
intro t φ ψ _h_sub h_mem
-- h_mem : (φ U ψ) ∈ (shifted_bx_fmcs N h_N s).mcs t
-- Goal: ∃ r ≥ t, ψ ∈ fam.mcs r ∧ ∀ q, t ≤ q < r → φ ∈ fam.mcs q
```

**The approach for fuc:**
1. By BX10 (`until_F`): (φ U ψ) → F(ψ). So F(ψ) ∈ chain(t-s).
2. By `bx_fmcs_forward_F` (sorry at line 493): ∃ s' > t-s with ψ ∈ chain(s').
3. This gives the ψ-witness. But the guard φ on [t, s') needs to be proved too.

**The guard problem:**
Even if fuc gets `bx_fmcs_forward_F`, proving the guard `∀ r, t ≤ r < s', φ ∈ fam.mcs r`
requires knowing φ holds at all intermediate times. With BX9 (`until_elim`):
(φ U ψ) → φ ∨ ψ, so at t: φ ∈ chain(t) or ψ ∈ chain(t). If ψ ∈ chain(t), s' = t
works (empty guard). If φ ∈ chain(t), we still need φ to hold at t+1, t+2, ..., s'-1.

**BX5 (self_accum_until):** (φ U ψ) → (φ ∧ (φ U ψ)) U ψ. This says if (φ U ψ) ∈ chain(t),
then (φ ∧ (φ U ψ)) U ψ ∈ chain(t). The augmented Until has a stronger guard condition:
the guard formula is now φ ∧ (φ U ψ), meaning both φ AND the Until obligation hold at
intermediate times. This is used in `DefectChain.lean` for BX-canonical point eventuality
resolution, but translating to Int-indexed chain membership is non-trivial.

**The BX5 route for fuc:** If (φ ∧ (φ U ψ)) U ψ ∈ chain(t), the witness s' must
satisfy ψ ∈ chain(s') AND (φ ∧ (φ U ψ)) ∈ chain(r) for all t ≤ r < s'. So we get
φ ∈ chain(r) for the guard. But this circular — we need (φ ∧ (φ U ψ)) U ψ to have
a witness, which again requires the forward coherence (fuc) applied to this new Until.

**Dependency structure:**
```
bx_bfmcs_restricted_fuc → bx_fmcs_forward_F (sorry)
                        → guard proof (φ holds at intermediate times)
bx_bfmcs_restricted_buc → step transfer (no axiom supports this directly)
```

### Finding 3: BX Axiom Inventory Relevant to Until/Since

The complete relevant BX axiom list:
- BX5 (`self_accum_until`): (φ U ψ) → (φ ∧ (φ U ψ)) U ψ — enriches the guard
- BX6 (`absorb_until`): φ U (φ ∧ (φ U ψ)) → (φ U ψ) — prevents double-nesting
- BX7 (`linear_until`): linearity of witness ordering
- BX8 (`refl_intro_until`): ψ → (φ U ψ) — reflexive base case (WORKS for buc t=s)
- BX9 (`until_elim`): (φ U ψ) → φ ∨ ψ — current-time guard extraction
- BX10 (`until_F`): (φ U ψ) → F(ψ) — eventuality extraction (used in fuc route)
- BX4 (`connect_future`): φ → G(P(φ)) — used in DefectChain for point-level resolution
- BX4' (`connect_past`): φ → H(F(φ)) — gives F(φ U ψ) at chain(r) from chain(r+1)

**No BX axiom provides:** a direct induction principle connecting
`(φ U ψ) ∈ chain(r+1)` to `(φ U ψ) ∈ chain(r)`.

### Finding 4: The f_carry Mechanism Does Not Help with Until Step Transfer

The f_carry mechanism in the current chain construction carries F-formulas:
```lean
f_carry M = {F(χ) | F(χ) ∈ M}
```
When `fwd_succ` doesn't resolve F(ψ), it seeds with `g_content(M) ∪ f_carry(M)`,
ensuring F-formulas persist across steps. This is what `bx_fmcs_forward_F` uses
(when proved).

There is no analogous "until_carry" mechanism that would carry `(φ U ψ)` formulas
across steps or backward.

### Finding 5: Alternative — Directly Prove Full bx_bfmcs_buc via Reflexive Base Only

There is one viable observation: the restricted buc requires backward coherence for
Until/Since in `subformulaClosure(root)`. The proof structure at line 621:
```lean
constructor <;> (intro t φ ψ _h_sub ⟨r, h_le, h_psi, h_guard⟩; sorry)
```

The witness r satisfies `t ≤ r` (not strict). In the BASE CASE `r = t`:
- `h_psi : ψ ∈ fam.mcs t`
- The guard is vacuous (no r with t ≤ r < t)
- `backward_until_reflexive` (BX8) closes this: ψ ∈ M → (φ U ψ) ∈ M.

But the non-trivial case `r > t` (where ψ ∈ chain(r) and φ on [t, r)) is precisely
where step transfer is needed. So only the base case is easy.

---

## Recommended Approach

### Short-term (most likely to succeed):

**Option A — Prove buc using a different chain enrichment:**
Add a "u_carry" mechanism analogous to f_carry that carries `(φ U ψ)` formulas forward
in the chain. If (φ U ψ) ∈ chain(n), include (φ U ψ) in the seed for chain(n+1)
(alongside g_content). Then backward Until step transfer could use:
- (φ U ψ) ∈ chain(r+1) and by BX4' → F(φ U ψ) ∈ chain(r)
- F(φ U ψ) ∈ chain(r) and by BX12 → ⊤ U (φ U ψ) ∈ chain(r)
- Combined with φ ∈ chain(r) and `or_until_in_mcs`: requires (φ U ψ) already in chain(r)

This is circular. u_carry does not bypass the fundamental issue.

**Option B — Modify the chain to use Until-indexed construction:**
Instead of scheduling all formulas (formula ψ resolved when F(ψ) ∈ current MCS),
maintain explicit Until obligations and ensure each (φ U ψ) obligation is discharged.
This is a major architectural change (closer to the Boneyard's DeterministicFMCS approach).

**Option C — Prove restricted buc by a semantic argument:**
Since the truth lemma only needs restricted coherence for `subformulaClosure(root)`,
and the BXCanonical model is sound (by `bx_countermodel`), perhaps prove restricted
buc via a semantic consistency argument: if ∃ witness but (φ U ψ) ∉ chain(t), then
that chain would be unsound under the truth lemma.

This is circular (truth lemma uses buc to be proved).

**Option D — Observe that buc/fuc are NOT CURRENTLY USED via the restricted path:**
Looking at `bx_countermodel` (line 635), it calls:
```lean
fully_restricted_parametric_representation_from_neg_membership
  (bx_bfmcs M h_mcs φ)
  (bx_bfmcs_restricted_tc M h_mcs φ)     -- proved (delegates to sorry forward_F/backward_P)
  (bx_bfmcs_restricted_buc M h_mcs φ)    -- sorry
  (bx_bfmcs_restricted_fuc M h_mcs φ)    -- sorry
```

The path to close these depends on what `fully_restricted_parametric_representation_from_neg_membership`
actually requires. It's possible the truth lemma for Until/Since in the restricted setting
uses a weaker property that is actually provable.

**Recommended investigation:** Examine
`Theories/Bimodal/Metalogic/Algebraic/RestrictedParametricTruthLemma.lean` to understand
exactly what the truth lemma proof uses for the Until/Since cases — specifically whether
it uses buc step-by-step or only applies buc at the top level where the witness is known
by the induction hypothesis.

### For fuc specifically:

Once `bx_fmcs_forward_F` is proved (see teammate A findings), fuc for the witness
existence part follows. The guard proof requires showing φ at intermediate chain points.
The best approach: use BX9 at each chain point to show φ ∨ ψ, and since ψ only holds
at the final witness s', φ holds everywhere before. This requires a "ψ does not hold
before s'" argument that may require the schedule's saturation property.

---

## Confidence Levels

| Claim | Confidence |
|-------|------------|
| Step transfer NOT derivable from current chain | HIGH (supported by module docstring, boneyard analysis) |
| fuc depends on bx_fmcs_forward_F | HIGH (direct dependency chain) |
| Guard proof for fuc is non-trivial even after forward_F | HIGH |
| u_carry approach does not resolve buc | HIGH (circularity argument) |
| BX5 route for fuc is viable | MEDIUM (needs detailed chain-level analysis) |
| Direct semantic argument for buc could work | LOW (circularity risk) |

---

## Evidence: Code Locations

- `CanonicalModel.lean:583-591`: `bx_bfmcs_buc` and `bx_bfmcs_fuc` (both sorry) — unrestricted versions
- `CanonicalModel.lean:617-627`: `bx_bfmcs_restricted_buc` and `bx_bfmcs_restricted_fuc` (both sorry) — what bx_countermodel actually uses
- `CanonicalModel.lean:493-503`: `bx_fmcs_forward_F` and `bx_fmcs_backward_P` (both sorry) — direct dependency for fuc
- `UntilSinceCoherence.lean:111-138`: `backward_until_from_step` — parameterized buc, requires step transfer
- `UntilSinceCoherence.lean:22-38`: Module docstring explicitly states step transfer is NOT derivable from bare FMCS
- `SuccRelation.lean:527-548`: `until_persists_through_succ` — sorry with analysis of why X-content is needed
- `DeterministicFMCS.lean:341-396`: Boneyard proof of backward Until using X-operator (not applicable)
- `Axioms.lean:154-170`: BX5, BX6 — the closest axioms for Until induction (insufficient for chain buc)
- `RestrictedParametricTruthLemma.lean:310-312`: The consuming function that requires buc/fuc

---

## Additional Observation: Two-Level Architecture

The code has two levels of sorry for Until/Since:
1. **Chain level** (lines 583-591): `bx_bfmcs_buc` / `bx_bfmcs_fuc` — full unrestricted coherence
2. **Restricted level** (lines 617-627): `bx_bfmcs_restricted_buc` / `bx_bfmcs_restricted_fuc` — what's actually used

The restricted versions require the same step transfer as the unrestricted. The restriction
to `subformulaClosure(root)` limits which formulas are checked, but doesn't change the
fundamental requirement for step transfer. If the unrestricted versions cannot be proved,
the restricted ones cannot either (by the same argument).

The only exemption: if the truth lemma for Until/Since in `RestrictedParametricTruthLemma.lean`
uses a weaker property than step transfer, a direct proof bypassing `backward_until_from_step`
might be possible.
