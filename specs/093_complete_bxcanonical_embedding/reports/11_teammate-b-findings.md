# Teammate B Findings: Quasimodel-to-BFMCS Pipeline

## Key Findings

### 1. The Four Sorry Sites in CanonicalModel.lean

All four active sorry targets are in `CanonicalModel.lean`:

- **Line 497**: `bx_fmcs_forward_F` — `F(ψ) ∈ chain(t) → ∃ s > t, ψ ∈ chain(s)`
- **Line 503**: `bx_fmcs_backward_P` — `P(ψ) ∈ chain(t) → ∃ s < t, ψ ∈ chain(s)`
- **Line 586**: `bx_bfmcs_buc` (`backward_until_since_coherent`) — given witness pattern, derive `φ U ψ ∈ fam.mcs t`
- **Line 591**: `bx_bfmcs_fuc` (`forward_until_since_coherent`) — given `φ U ψ ∈ fam.mcs t`, produce witness

The restricted variants at lines 621–627 are identical in structure to the unrestricted ones (same proof obligations, just with an extra subformula closure guard that is unused in the proof).

### 2. What the BFMCS and FMCS Expect

`FMCS Int` (defined in `FMCSDef.lean`) requires:
- `mcs : Int → Set Formula`
- `is_mcs : ∀ t, SetMaximalConsistent (mcs t)`
- `forward_G : ∀ t t', t ≤ t' → G(φ) ∈ mcs t → φ ∈ mcs t'`
- `backward_H : ∀ t t', t' ≤ t → H(φ) ∈ mcs t → φ ∈ mcs t'`

`BFMCS Int` (defined in `BFMCS.lean`) requires:
- `families : Set (FMCS Int)`
- `modal_forward` and `modal_backward` coherence (already proved at lines 511–563)

The sorry targets are **not** in the FMCS or BFMCS structure themselves, but in separate coherence theorems needed for the truth lemma.

### 3. The `int_chain` Already Exists and Is Correct

`CanonicalModel.lean` lines 197–225 already define:
- `fwd_chain M₀ h₀ n` — forward Nat-indexed chain using `fwd_succ`
- `bwd_chain M₀ h₀ n` — backward Nat-indexed chain using `bwd_pred`
- `int_chain M₀ h₀ t` — Int-indexed chain combining both
- `int_chain_mcs`, `int_chain_forward_G`, `int_chain_backward_H` — all proved (sorry-free)

The chain construction uses a round-robin schedule (`schedule n = Denumerable.ofNat Formula (Nat.unpair n).2`) that targets every formula infinitely often.

### 4. The `forward_F` Sorry Root Cause

`bx_fmcs_forward_F` (line 493–497) states: if `F(ψ) ∈ int_chain M₀ h₀ t`, then `∃ s > t, ψ ∈ int_chain M₀ h₀ s`.

The chain was designed to resolve this: `fwd_succ` (lines 74–105) has two cases:
- If `F(ψ) ∈ M`, build a successor containing `ψ` (using `forward_temporal_witness_seed`)
- Otherwise, build a non-resolving successor (carrying `f_carry(M) = {F(χ) | F(χ) ∈ M}`)

The **problem**: `fwd_succ` resolves `ψ` at step n when `schedule(n) = ψ` AND `F(ψ) ∈ chain(n)`. The schedule is surjective above any bound (`schedule_surjective_above`, line 45). So for any `F(ψ) ∈ chain(t)`, there exists a future step `n ≥ t.toNat` where `schedule(n) = ψ`.

The missing piece is: `F(ψ)` must persist from `chain(t)` to `chain(n)`. The non-resolving branch carries `f_carry(M) ⊆ fwd_succ M h_mcs ψ'` when `F(ψ') ∉ M` (line 107–113). So `F(ψ)` persists through non-resolving steps ONLY IF `F(ψ) ∈ f_carry(chain(k))` means `F(ψ)` gets carried. The `f_carry` definition is `{φ ∈ M | ∃ χ, φ = F(χ)}`, i.e., all F-formulas in M. So `f_carry(chain(k))` contains `F(ψ)` as long as `F(ψ) ∈ chain(k)`. The non-resolving step carries `f_carry(M)` forward. This means F-formulas persist through non-resolving steps.

**Therefore**: `forward_F` is provable by induction on the chain: find the first step n where `schedule(n) = ψ` and `n ≥ t.toNat`, then show `F(ψ) ∈ chain(n)` by F-carry persistence, then `fwd_succ_resolves` gives `ψ ∈ chain(n+1)`.

The same logic applies symmetrically for `backward_P` using `p_carry`.

### 5. The `backward_until_since_coherent` Sorry

`bx_bfmcs_buc` (line 583–586) has the proof skeleton:
```
intro t φ ψ ⟨r, h_le, h_psi, h_guard⟩; sorry
```

This needs: given `ψ ∈ fam.mcs r`, `r ≥ t`, and `φ ∈ fam.mcs k` for `t ≤ k < r`, prove `φ U ψ ∈ fam.mcs t`.

`UntilSinceCoherence.lean` provides `backward_until_from_step` (line 111) which reduces this to a **step transfer** hypothesis:
```
h_step : ∀ r, (φ U ψ) ∈ fam.mcs (r+1) → φ ∈ fam.mcs r → (φ U ψ) ∈ fam.mcs r
```

The key question is whether the `int_chain` satisfies this step property. This requires: if `(φ U ψ) ∈ chain(r+1)` and `φ ∈ chain(r)`, then `(φ U ψ) ∈ chain(r)`.

**Analysis**: For `r ≥ 0`, `chain(r+1) = fwd_succ(chain(r), h, schedule(r))`. The `fwd_succ` seed (resolving case) contains `ψ ∪ g_content(M)` — so `G(φ U ψ) ∈ chain(r)` would give `(φ U ψ) ∈ chain(r+1)`. But we need the *converse*: from `(φ U ψ) ∈ chain(r+1)`, conclude `(φ U ψ) ∈ chain(r)`.

This is the **backward Until step transfer** that has been identified as the core obstacle in previous research. It requires showing that the chain construction somehow encodes Until formulas "backward." The current chain only encodes forward persistence (g_content) and backward persistence (h_content), not Until-backward.

**The f_carry approach has the same obstacle**: `f_carry` only persists F-formulas (`F(χ)`), not Until formulas (`φ U ψ`). So the step transfer for Until is not directly available from the current chain structure.

### 6. The `forward_until_since_coherent` Sorry

`bx_bfmcs_fuc` (line 588–591) needs: given `(φ U ψ) ∈ fam.mcs t`, produce `s ≥ t` with `ψ ∈ fam.mcs s` and `φ` on the guard `[t, s)`.

This requires:
1. From `(φ U ψ) ∈ chain(t)`, derive `F(ψ) ∈ chain(t)` (via BX10: `(φ U ψ) → F(ψ)`)
2. Apply `bx_fmcs_forward_F` to get `s > t` with `ψ ∈ chain(s)`
3. Show `φ ∈ chain(r)` for all `t ≤ r < s`

Step 1–2 are fine once `forward_F` is proved. Step 3 is the hard part: we need `φ ∈ chain(r)` for intermediate points `r`.

From `(φ U ψ) ∈ chain(t)` and BX9 (`(φ U ψ) → φ ∨ ψ`), we get `φ ∈ chain(t)` (assuming `ψ ∉ chain(t)`). The chain propagates `G(φ)` via `forward_G`, but `φ` without `G(φ)` doesn't persist. So we'd need `G(φ) ∈ chain(t)`, which requires `G(φ U ψ) ∈ chain(t)` and left monotonicity... but this is circular.

### 7. The Quasimodel Infrastructure: What Is There

The quasimodel directory `BXCanonical/Quasimodel/` contains:
- `HintikkaPoint.lean` — Hintikka points over Sigma-closure (finite signature)
- `Construction.lean` — `hintikka_step`, `UntilDefect`, defect count, MCS-level lemmas
- `Realization.lean` — Enriched seed consistency, delegates eventuality resolution to `Frame.lean`
- `SubformulaClosure.lean` — `EnrichedClosure` (Sigma closure including until/since subformulas)
- `LocusControl.lean` — (not read in detail, but referenced for locus-control/Phase 6)

The quasimodel infrastructure provides **finite** Hintikka chains with defect discharge. There is no `Realization` output type that produces `BXPoint` chains — the realization function stubs (`until_eventuality_resolution`, `since_eventuality_resolution`) simply delegate to `Frame.lean`'s `bx_until_eventuality_resolution`.

The critical finding from `Realization.lean` lines 366–401: **G-persistence fails through hintikka_step**, making the strict-seed approach unprovable. The quasimodel chain exists at the Hintikka level but cannot currently be lifted to BXPoint chains due to G-formula persistence failure.

### 8. The Quasimodel-to-BFMCS Pipeline Assessment

The proposed approach (Approach 5 from report 10) would:
1. Build a quasimodel chain (finite BXPoint sequence) for each Until eventuality
2. Use this as the FMCS timeline

**Problems with this approach**:
- The quasimodel chain is finite; FMCS requires `Int`-indexed (infinite) timeline
- Extending to infinite by repeating the last point creates a constant tail, but then `forward_F` fails (there's no strictly future witness for F-formulas beyond the last point)
- More fundamentally, the quasimodel chain and the `int_chain` serve different purposes: quasimodel discharges a single Until defect; the `int_chain` must satisfy ALL Until formulas simultaneously

### 9. Promising Path: Fix `forward_F` Using f_carry Persistence

The most tractable approach focuses solely on `bx_fmcs_forward_F` (line 497). The proof outline:

1. Given `F(ψ) ∈ int_chain M₀ h₀ t`, WLOG `t ≥ 0`
2. By `schedule_surjective_above` (line 45), there exists `n ≥ t.toNat` with `schedule n = ψ`
3. Need: `F(ψ) ∈ fwd_chain M₀ h₀ n`
4. Prove by induction: for each step `k` from `t.toNat` to `n-1`, if `F(ψ) ∈ chain(k)` and `schedule(k) ≠ ψ`, then `F(ψ) ∈ chain(k+1)` via `fwd_succ_f_carry`
5. At step `n`, `fwd_succ_resolves` gives `ψ ∈ fwd_chain M₀ h₀ (n+1)`
6. Since `t < n+1` (or `n+1 > t.toNat`), this gives the required witness

The inductive step (4) needs to track that `F(ψ) ∈ chain(k)` when `schedule(k) ≠ ψ`. Since `fwd_succ_f_carry` says `f_carry(M) ⊆ fwd_succ M h ψ'` when `F(ψ') ∉ M`, we need `schedule(k) ≠ ψ` to imply `F(ψ) ∉ M` OR `schedule(k) = ψ` for some k... but what if `F(ψ) ∈ M` and `schedule(k) = ψ` for some step, but `ψ ∉ M` at that step (so the resolving branch fires but the g_content may not include F(ψ))?

Actually the issue is subtler: in the resolving branch (`F(ψ) ∈ M`), the seed is `{ψ} ∪ g_content(M)` which does NOT include `f_carry(M)`. So `F(ψ)` might NOT be in the resolving successor. This means F-formulas are potentially NOT preserved through resolving steps for other ψ'.

**Critical gap**: `F(ψ)` persists through non-resolving steps (steps where `F(ψ) ∉ M`, i.e., when `schedule(k) = ψ` but `F(ψ) ∉ M` — wait, in the resolving case, `F(ψ) ∈ M`). The `fwd_succ` definition:
- Resolving case (`F(ψ) ∈ M`): seed = `{ψ} ∪ g_content(M)` — `F(other)` may or may not be in the result
- Non-resolving case (`F(ψ) ∉ M`): seed = `g_content(M) ∪ f_carry(M)` — all F-formulas in M persist

So `F(ψ')` can be lost at resolving steps (steps targeting a different formula `ψ`). This means `forward_F` requires showing that F-formulas that get lost are resolved before they can be needed — or that they reappear.

Actually, wait: via BX T-axiom `G(φ) → φ`, `g_content(M) ⊆ M`. But `G(F(ψ')) ∈ M` would give `F(ψ') ∈ g_content(M)`, hence `F(ψ') ∈ fwd_succ(M, h, ψ)` for any ψ. And `G(F(ψ')) ∈ M` follows from `F(ψ') ∈ M` via perpetuity axiom `F(φ) → G(F(φ))` (if such an axiom exists in BX).

**Key question**: Does BX include `F(φ) → G(F(φ))` (perpetuity/BX10)?

Looking at `CanonicalChain.lean`: `until_F_mcs` at line 139 shows BX10 gives `(φ U ψ) → F(ψ)`. But BX10 is specifically about Until. The F-perpetuity `F(φ) → G(F(φ))` would correspond to a different axiom.

The file `CanonicalModel.lean` imports `Bimodal.Theorems.Perpetuity` (line 35). Let me check what perpetuity provides.

### 10. Connection to Perpetuity Theorems

Looking at `CanonicalModel.lean` line 451: `Axiom.temp_future` is used: `□φ → G(□φ)`. This is the box perpetuity axiom. There may be an analogous `F(φ) → G(F(φ))` for temporal operators.

If `F(φ) → G(F(φ))` is derivable in BX (or is an axiom), then `F(ψ') ∈ M` would give `G(F(ψ')) ∈ M`, hence `F(ψ') ∈ g_content(M)`, hence `F(ψ')` persists through ALL fwd_succ steps regardless of which formula is being resolved. This would make `forward_F` provable.

The axiom `G(F(φ)) → F(φ)` is BX1 (temp_t_future on `F(φ)`). The converse `F(φ) → G(F(φ))` would be a perpetuity axiom for F. This is NOT standard in BX unless BX includes it explicitly. In linear dense time this fails (F(φ) true at t doesn't mean F(φ) true at all future s).

**For discrete linear time**, `F(φ)` does NOT imply `G(F(φ))` — if `φ` holds at exactly the next step and nowhere else, then `F(φ)` holds now but `F(φ)` fails at the next step. So this perpetuity axiom is NOT available in BX.

This means F-formulas can be genuinely lost at resolving steps. The forward_F sorry is harder than it appears.

## Recommended Approach

The most tractable path to closing all four sorries is:

**Approach A: Add Until content to the enriched forward seed**

Modify `fwd_succ` to use a richer non-resolving seed:
```
g_content(M) ∪ f_carry(M) ∪ until_content(M)
```
where `until_content(M) = {φ U ψ | (φ U ψ) ∈ M ∧ ψ ∉ M} ∩ f_carry_reachable(M)`

But this quickly becomes circular — adding more to the seed requires proving the seed is consistent, which requires more axioms.

**Approach B: Prove forward_F by connecting to the schedule surjectivity**

Rather than tracking F-formulas through all chain steps, observe that `F(ψ) ∈ int_chain(t)` means specifically `F(ψ) ∈ chain(t)`. Now:
1. `G(F(ψ)) ∈ chain(t)`? Not provable in general.
2. `F(ψ) → F(F(ψ))` (transitivity/induction of F)?

In BX with `F = ¬G¬`, `F(F(ψ)) = ¬G¬(¬G¬ψ)`. Whether `F(ψ) → F(F(ψ))` is derivable depends on the axioms. In discrete linear time, yes (`F(ψ) → F(F(ψ))` holds: if ψ holds at some future time k, then at k-1 (which is in the future of now), F(ψ) holds). But this needs axiom BX3 or similar inductive formula.

**Approach C (recommended): Replace `fwd_succ` non-resolving branch to carry F-formulas via g_content**

The key insight: if we can show `F(ψ) ∈ M → G(F(ψ)) ∈ M` for MCS M in BX, then F-persistence follows trivially. This holds iff BX proves `F(ψ) → G(F(ψ))`. Looking at the axiom list needed:

`F(ψ) → G(F(ψ))` is equivalent to: if ψ holds sometime in the future, then for ALL future times s, ψ holds at SOME time after s. This IS true in any dense linear order or well-ordered time, but requires the density/seriality axiom in BX.

Checking `CanonicalModel.lean` imports: it imports `Bimodal.Theorems.Perpetuity` (line 35). The `box_to_past` theorem used at line 460 (which says `□(□φ) → H(□φ)`) uses perpetuity. There may already be an `F(φ) → G(F(φ))` theorem in `Theorems/Perpetuity.lean`.

**If BX proves `F(ψ) → G(F(ψ))`**, then `forward_F` is provable as follows:
- `F(ψ) ∈ chain(t)` → `G(F(ψ)) ∈ chain(t)` (by the perpetuity axiom)
- By `int_chain_forward_G`: for any `t' > t`, `F(ψ) ∈ chain(t')`
- Schedule surjectivity: ∃ `n > t.toNat` with `schedule(n) = ψ`
- At step `n`: `F(ψ) ∈ chain(n)`, so resolving branch fires, giving `ψ ∈ chain(n+1)`

This would prove `forward_F`, and `backward_P` symmetrically.

## Evidence

- `CanonicalModel.lean:493-497`: `bx_fmcs_forward_F` sorry
- `CanonicalModel.lean:499-503`: `bx_fmcs_backward_P` sorry
- `CanonicalModel.lean:583-591`: `bx_bfmcs_buc`, `bx_bfmcs_fuc` sorries
- `CanonicalModel.lean:40-47`: Schedule definition and surjectivity
- `CanonicalModel.lean:74-113`: `fwd_succ` with `f_carry` persistence
- `UntilSinceCoherence.lean:111-138`: `backward_until_from_step` — reduces backward Until to step transfer
- `TemporalCoherence.lean:265-268`: `BFMCS.temporally_coherent` definition
- `Realization.lean:366-401`: G-persistence obstacle in quasimodel chain
- `FMCSDef.lean:99-117`: `FMCS` structure (only needs `forward_G` and `backward_H` for coherence)

## Confidence Level

**medium-high** for the overall assessment of sorry locations and obstacles.

**medium** for the `F(ψ) → G(F(ψ))` perpetuity route for `forward_F` — this depends on whether BX has such an axiom. It needs verification in `Theorems/Perpetuity.lean`.

**low** for the `backward_until_since_coherent` step transfer — no clear strategy without modifying the chain construction.

## Open Questions

1. **Does BX prove `F(ψ) → G(F(ψ))`?** Check `Theorems/Perpetuity.lean` for temporal perpetuity axioms. If yes, `forward_F` and `backward_P` are provable by a schedule argument.

2. **What is the step transfer property for Until?** For `bx_bfmcs_buc`, we need: `(φ U ψ) ∈ chain(r+1) ∧ φ ∈ chain(r) → (φ U ψ) ∈ chain(r)`. Is there a BX axiom giving this? Candidates: axiom connecting `φ ∧ (φ U ψ)` at `r+1` with `(φ U ψ)` at `r` (some form of induction on Until).

3. **What is the forward Until witness strategy?** For `bx_bfmcs_fuc`, after finding `s > t` with `ψ ∈ chain(s)`, how do we show `φ ∈ chain(r)` for all `t ≤ r < s`? This seems to require that the chain "watches" the guard condition, which the current round-robin construction doesn't ensure.

4. **Is the quasimodel approach relevant for Until/Since coherence?** The quasimodel infrastructure (Burgess-Xu defect discharge) proves existence of BXPoint witnesses for Until/Since events, but this seems to be what `bx_until_eventuality_resolution` and `bx_since_eventuality_resolution` in `Frame.lean` already provide. The quasimodel approach does NOT appear to provide a route to `forward_until_since_coherent` directly — that requires a chain-level argument about the `int_chain` construction.

5. **Should `bx_bfmcs_fuc` use `bx_until_eventuality_resolution` from Frame.lean?** That function (via `Frame.lean`) already proves: `(φ U ψ) ∈ w → ∃ v ≥ w, ψ ∈ v ∧ φ ∈ w`. But the FMCS is indexed by `Int`, not BXPoints. There's a mismatch between the BXPoint-level existence proof and the chain-level Int-indexed coherence required.
