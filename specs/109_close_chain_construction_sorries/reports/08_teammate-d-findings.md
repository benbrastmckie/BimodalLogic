# Teammate D (Horizons): Strategic Analysis Round 8

**Task**: Task 109 — Close 3 remaining sorry sites blocking sorry-free `bx_completeness`
**Role**: Horizons — challenge conventional wisdom, explore non-linear paths
**Date**: 2026-04-21
**Prior rounds analyzed**: 01–07 (7 rounds of team research)

---

## Key Findings

### Finding 1: The Backward Until Coherence Chain Has a Foundation Problem

Prior rounds correctly identified `bx_bfmcs_restricted_buc` (backward Until/Since coherence) as the hardest problem. What was NOT noticed: the foundational lemma `backward_until_reflexive` in `UntilSinceCoherence.lean` (line 81-84) depends on `psi_imp_until` from `TemporalDerived.lean`, which is itself **sorry'd** because BX8 was removed under irreflexive semantics.

The chain of dependencies:
```
bx_bfmcs_restricted_buc
  -> backward_until_from_step (UntilSinceCoherence.lean:111)
     -> backward_until_reflexive (UntilSinceCoherence.lean:81)
        -> psi_imp_until (TemporalDerived.lean:232) [SORRY - BX8 removed]
```

Similarly:
```
or_until_in_mcs (SuccRelation.lean:571)
  -> psi_imp_until [SORRY]  (for the ψ ∈ M case)
```

This means the "parameterized backward Until" approach in `UntilSinceCoherence.lean` does not actually solve the problem — it reduces it to a sorry'd base case. Any implementation plan that uses `backward_until_from_step` as the proof infrastructure for `bx_bfmcs_restricted_buc` will inherit this sorry.

**Critical implication**: Under irreflexive semantics, `ψ → (φ U ψ)` is NOT valid. This is not just an axiom that was removed — it is semantically FALSE. Consider ψ at time t but no strictly future time s > t with ψ(s) (seriality only guarantees there exists SOME future time, not one where ψ holds). So backward Until coherence cannot simply introduce Until from a reflexive witness.

### Finding 2: The 3 Sorry Sites in the New Architecture Have Correct Structure

The current `RootScopedChain.lean` (as of round 7) uses `bx_bfmcs` (built from `shifted_bx_fmcs`) which wraps the schedule-based `int_chain`. This is the correct construction — the `fwd_succ` / `bwd_pred` approach with `schedule_surjective_above` is the right architecture. The three sorry sites are:

1. **`bx_bfmcs_restricted_tc`**: F/P resolution. Given `F(φ) ∈ fam.mcs t`, find `s > t` with `φ ∈ fam.mcs s`. The schedule + monotonicity proof strategy (round 7 synthesis) should work for this: schedule surjectivity gives a resolving step, and `fwd_chain_F_not_return` (already proved in RootScopedChain.lean:113-143) gives the monotonicity contrapositive.

2. **`bx_bfmcs_restricted_buc`**: Backward Until/Since introduction. Given witnesses (ψ at s, φ on guard [t,s)), derive `(φ U ψ) ∈ fam.mcs t`. This is fundamentally hard because the reflexive base case is sorry'd.

3. **`bx_bfmcs_restricted_fuc`**: Forward Until/Since elimination. Given `(φ U ψ) ∈ fam.mcs t`, find witness s > t with ψ at s and φ on guard. Via BX10 (until_F), we get `F(ψ) ∈ fam.mcs t`, then restricted_tc gives the existential witness. The guard condition needs additional work via BX5 (self-accumulation).

### Finding 3: The `bx_bfmcs_restricted_tc` Sorry is Closest to Closed

The proof strategy for `bx_bfmcs_restricted_tc` using schedule + monotonicity is the most feasible path. The infrastructure already exists:
- `fwd_chain_F_not_return` (lines 113-143): monotonicity — once F(φ) leaves, it never returns
- `schedule_surjective_above`: every formula is scheduled infinitely often
- `fwd_succ_resolves`: when F(ψ) ∈ chain(n), the resolving step puts ψ in chain(n+1)

The proof has this structure for the forward case (F(φ) in fam.mcs t where t = n ≥ 0):
1. F(φ) ∈ fwd_chain(t.toNat) by hypothesis
2. By schedule_surjective_above(φ, t.toNat): exists m ≥ t.toNat with schedule(m) = φ
3. Case A: F(φ) ∈ fwd_chain(m) → fwd_succ_resolves gives φ ∈ fwd_chain(m+1). Done (s = m+1 > t).
4. Case B: F(φ) ∉ fwd_chain(m) → by fwd_chain_F_not_return (contrapositively), since F(φ) ∈ fwd_chain(t.toNat) and F(φ) ∉ fwd_chain(m), there exists some k with t.toNat ≤ k < m where F(φ) ∈ fwd_chain(k) but F(φ) ∉ fwd_chain(k+1). The proof of fwd_chain_F_not_return uses: G(¬φ) ∈ chain(k) → G(G(¬φ)) → G(¬φ) ∈ chain(k+1). The contrapositive says: if F(φ) disappears at step k→k+1, it was because G(¬φ) was NOT in chain(k) at the right moment... Actually this requires careful analysis.

Wait — `fwd_chain_F_not_return` proves that once F(φ) is absent, it stays absent. Its contrapositive is: if F(φ) was in chain(n) and is absent in chain(m), then... the contrapositive is not immediately useful. The useful property is: if F(φ) ∈ chain(n) and F(φ) ∉ chain(n+1), then... what? The construction `fwd_succ` at step n resolves `schedule(n)`. If `schedule(n) = φ` and `F(φ) ∈ chain(n)`, then `fwd_succ_resolves` gives φ ∈ chain(n+1). If schedule(n) ≠ φ, the non-resolving branch uses g_content alone. Then F(φ) may or may not survive. It survives if G(¬φ).neg = F(φ) ∈ chain(n+1) — but this is exactly what we cannot control.

The schedule + monotonicity approach works only if we can establish: IF F(φ) drops at some step k (F(φ) ∉ chain(k+1) even though F(φ) ∈ chain(k)), THEN φ ∈ chain(k+1). This would require: the only way F(φ) can drop is by Lindenbaum choosing ¬F(φ) = G(¬φ), but if G(¬φ) is in the extension, then by g_content propagation, G(¬φ) ∈ fwd_chain for all future steps, and by F_not_return, F(φ) never appears again. But this does NOT give φ in chain(k+1) — it just says G(¬φ) was chosen, which is consistent with having ¬φ throughout (but not necessarily φ at k+1).

**Correction to round 7 synthesis**: The "Case B" of the schedule + monotonicity approach does NOT work as stated. F(φ) dropping does NOT imply φ appeared. Lindenbaum can choose G(¬φ) without ever choosing φ. The round 7 synthesis was mistaken in claiming "if F(psi) drops, then psi MUST have appeared at the drop step."

### Finding 4: The Only Viable Path is the Resolving Step when Scheduled

The ONLY proved fact about φ appearing in the chain is `fwd_succ_resolves`: when F(φ) ∈ chain(n) AND schedule(n) = φ, then φ ∈ chain(n+1). This gives φ in chain(n+1) > n. This is the resolving-step guarantee.

The real question for `restricted_tc` is: does F(φ) persist until the scheduled resolving step? This is NOT guaranteed. By `fwd_chain_F_not_return`, once F(φ) disappears it never returns. But F(φ) CAN disappear before φ's scheduled turn if Lindenbaum adds G(¬φ) at a non-resolving step.

**The genuine obstruction** (refinement of dead end #36): When schedule(n) ≠ φ, the seed is `{schedule(n)} ∪ g_content(chain(n))` (if F(schedule(n)) ∈ chain(n)) or just `g_content(chain(n))`. Neither seed includes a constraint forcing F(φ) to stay. Lindenbaum CAN add G(¬φ) if that is consistent with the seed. And it IS consistent in general: G(¬φ) ∪ g_content(chain(n)) can be consistent even when F(φ) ∈ chain(n).

### Finding 5: The Forward Until Coherence (Sorry 3) Has a Real Path via BX10+BX5

For `bx_bfmcs_restricted_fuc`, the strategy is:
1. Given (φ U ψ) ∈ fam.mcs t (where (φ U ψ) ∈ subformulaClosure(root))
2. By BX10 (until_F): F(ψ) ∈ fam.mcs t
3. ψ ∈ deferralClosure(root) (since φ U ψ ∈ subformulaClosure(root))
4. By restricted_tc (sorry 1): exists s > t with ψ ∈ fam.mcs s (but only if sorry 1 is closed)
5. For the guard: need φ ∈ fam.mcs r for all r ∈ [t, s)
   - By BX5 (self_accum): (φ U ψ) ∈ fam.mcs t → ((φ ∧ (φ U ψ)) U ψ) ∈ fam.mcs t
   - By G-propagation of (φ ∧ (φ U ψ) U ψ)... but this doesn't directly give φ at intermediate chain points

The guard condition remains non-trivial. The g_content propagation gives: if G((φ ∧ (φ U ψ)) U ψ) ∈ fam.mcs t, then (φ ∧ (φ U ψ)) U ψ ∈ fam.mcs s' for s' > t. But (φ U ψ) is NOT a G-formula, so g_content propagation does not apply.

**This sorry (restricted_fuc) depends on restricted_tc AND requires a non-trivial guard argument.** It cannot be closed until restricted_tc is closed first.

### Finding 6: Irreflexive BUC Requires Fundamentally New Approach

The backward Until coherence under irreflexive semantics requires introducing `(φ U ψ)` from:
- ψ ∈ fam.mcs s (for some strictly future s > t)
- φ ∈ fam.mcs r for all r ∈ [t, s)

Under reflexive semantics, when s = t, we'd use `ψ → (φ U ψ)` (BX8). Under irreflexive semantics with strict witnesses, the minimal non-trivial case is s = t+1 (on Int). At this point, we need φ U ψ at t given ψ at t+1 and φ at t.

**Key question**: Is `φ ∧ F(ψ) → (φ U ψ)` derivable in BX under irreflexive semantics?

From BX12 (F_until_equiv): `F(ψ) → (⊤ U ψ)`. So `⊤ U ψ ∈ fam.mcs t` when F(ψ) ∈ fam.mcs t.
From BX2 (left_mono_until): `(⊤ → φ) ∧ G(⊤ → φ) → ((⊤ U ψ) → (φ U ψ))`. Under irreflexive semantics, can we derive φ U ψ from ⊤ U ψ?

Left monotonicity (BX2): `(φ → χ) ∧ G(φ → χ) → ((φ U ψ) → (χ U ψ))`. Setting χ = ⊤: `(φ → ⊤) ∧ G(φ → ⊤) → ((φ U ψ) → (⊤ U ψ))`. Going the other direction (⊤ U ψ → φ U ψ) would need to strengthen the left side, which left_mono does not provide (it weakens, not strengthens).

**No BX axiom introduces (φ U ψ) from F(ψ) alone under irreflexive semantics.** This is a firm obstruction.

However: `∈ psi_imp_until` is sorry'd, but BX12 is NOT removed. Consider:
- `F(ψ) → (⊤ U ψ)` (BX12, sorry-free)
- `(⊤ U ψ) → (φ U ψ)` would need: for each guard r ∈ (t, s), ⊤ is in fam.mcs r (trivially true, since ⊤ is a tautology). So semantically, ⊤ U ψ at t means ∃ s > t, ψ(s) ∧ ∀ r ∈ (t,s), ⊤. The ⊤ condition is vacuous. But (φ U ψ) at t requires additionally that φ holds at t and all r ∈ (t, s).

So `⊤ U ψ → φ U ψ` is NOT derivable unless φ holds everywhere. But we DO have φ ∈ fam.mcs r for r ∈ [t, s) as a hypothesis. The question is whether MCS membership of these individual facts can be assembled into Until membership.

### Finding 7: The Backward_Until_From_Step Approach Cannot Be Completed

The `backward_until_from_step` theorem (UntilSinceCoherence.lean:111) requires a "step transfer" hypothesis:
```
h_step : ∀ r : Int, Formula.untl φ ψ ∈ fam.mcs (r + 1) → φ ∈ fam.mcs r → Formula.untl φ ψ ∈ fam.mcs r
```

For the `bx_bfmcs` / `int_chain` construction, proving this step transfer requires:
- `(φ U ψ) ∈ int_chain(r+1)` means `(φ U ψ) ∈ fwd_succ(chain(r), schedule(r))`
- We need `(φ U ψ) ∈ chain(r)` given `φ ∈ chain(r)`

The `fwd_succ` step either:
1. Includes `ψ` (resolving branch, target = schedule(r) = ψ): then seed = {ψ} ∪ g_content(chain(r)). If (φ U ψ) ∈ result, we could potentially use some argument, but we need (φ U ψ) at chain(r), not chain(r+1).
2. Non-resolving branch: seed = g_content(chain(r)). If (φ U ψ) ∈ Lindenbaum result, we have G(φ U ψ) ∈ chain(r) (since result ⊇ g_content(chain(r))). Wait: chain(r+1) ⊇ g_content(chain(r)). So if (φ U ψ) ∈ chain(r+1) and we know chain(r+1) ⊇ g_content(chain(r)), it MIGHT be that G(φ U ψ) ∈ chain(r), giving (φ U ψ) ∈ g_content(chain(r)) ⊆ chain(r+1). But we need (φ U ψ) ∈ chain(r), not in g_content.

Actually: g_content(M) = {χ | G(χ) ∈ M}. If G(φ U ψ) ∈ chain(r), then (φ U ψ) ∈ g_content(chain(r)) ⊆ chain(r+1). This IS a g_content fact. But to get (φ U ψ) ∈ chain(r) from G(φ U ψ) ∈ chain(r), we need G(φ U ψ) → (φ U ψ), which is exactly BX1 applied to G(φ U ψ) — and BX1 is removed!

So this approach fails at the same wall: g_content goes INTO chain(r+1) but not necessarily back into chain(r).

---

## Recommended Approach

### Tier 1: Close `bx_bfmcs_restricted_tc` via Direct Resolving Step

**Status**: Feasible but requires careful construction.

The correct argument for restricted_tc is NOT the schedule + monotonicity dichotomy (Case B is wrong). The correct argument is simpler and more direct:

For F(φ) ∈ shifted_bx_fmcs(N, h_N, s).mcs t:
- This means F(φ) ∈ int_chain N h_N (t - s)
- Case t - s ≥ 0: F(φ) ∈ fwd_chain N h_N (t - s).toNat
- Use `schedule_surjective_above φ (t - s).toNat` to find m ≥ (t - s).toNat with schedule(m) = φ

Now use `fwd_chain_F_not_return` (contrapositive): if F(φ) ∈ chain(t-s.toNat), it could disappear at some step k. The monotonicity theorem says once it disappears, it stays gone. So either:

**Approach A (direct)**: Add a new lemma: if F(φ) ∈ chain(n) for all n in [start, m), THEN when schedule(m) = φ, we have F(φ) ∈ chain(m) and hence φ ∈ chain(m+1) via fwd_succ_resolves.

But this requires F(φ) to persist to step m, which is exactly what we cannot guarantee.

**Approach B (correct)**: The step where F(φ) FIRST disappears from the chain must be a step where F(φ) ∈ chain(k) but F(φ) ∉ chain(k+1). From the construction: chain(k+1) = fwd_succ(chain(k), schedule(k)). Either:
- schedule(k) = φ and F(φ) ∈ chain(k): then φ ∈ chain(k+1) (fwd_succ_resolves). DONE.
- schedule(k) ≠ φ: seed is {schedule(k)} ∪ g_content(chain(k)) or g_content(chain(k)). Neither forces F(φ) ∉ chain(k+1). The Lindenbaum extension can include or exclude F(φ). If F(φ) ∉ chain(k+1), then G(¬φ) ∈ chain(k+1) (by MCS maximality). Then G(G(¬φ)) ∈ chain(k+1) by temp_4. By bwd_chain step: G(¬φ) ∈ chain(k+2) via g_content propagation. So F(φ) ∉ chain(k+2) either. But did φ appear? Not necessarily.

**Conclusion**: The resolving step ONLY guarantees φ ∈ chain(m+1) if F(φ) STILL persists to step m. Once F(φ) is gone (via G(¬φ) being added by Lindenbaum), φ cannot be forced. This is the same dead end #3 (omega_true_dovetailed_forward_F_resolution) and dead end #36 from the ROADMAP.

### Tier 2: The Unfixable Obstruction in New Terminology

All three sorry sites share the same root cause:

**The fundamental obstruction**: `int_chain` uses `fwd_succ` and `bwd_pred` which call `set_lindenbaum`. The Lindenbaum extension is unconstrained beyond the seed. At non-resolving steps, the seed is `g_content(chain(n))`, which does NOT constrain:
- Whether F(φ) persists (for restricted_tc)
- Whether (φ U ψ) persists (for forward_fuc)
- How Until formulas are introduced (for backward_buc)

The `Classical.choice` in `set_lindenbaum` selects an MCS extension non-deterministically. There is no BX axiom that would force these properties to hold at EVERY non-resolving step.

This obstruction is documented in the ROADMAP as dead ends #3, #24, #36.

### Tier 3: The Only Viable Long-Term Path

Based on 7 rounds of team research and 36 documented dead ends, the only viable path is one of:

**Option 1: Semantic Completeness (Goldblatt/GHR style)**

Instead of building a chain and proving properties about it, adopt the Goldblatt (1992) / Goldblatt-Hodkinson-Reynolds (1994) semantic approach:
- Define the canonical model with ALL MCS as time points
- Show the temporal order (g_content inclusion) is a linear preorder on the canonical frame
- Prove F-resolution semantically: F(φ) ∈ w → there exists an MCS v with φ ∈ v, and w ≤ v in the canonical order
- This is guaranteed by `bx_forward_witness` (already sorry-free in Frame.lean)

The canonical frame witnesses exist without any chain construction. The challenge is re-engineering the BFMCS structure to use ALL MCS rather than a single Int-indexed chain.

**Concrete proposal**: Instead of `shifted_bx_fmcs N h_N s` being a family, define families as the full canonical frame with `bx_le` order. The BFMCS would have families indexed by all BXPoints (not by box-equivalence classes). The parametric representation theorem would need adjustment, but the coherence properties (restricted_tc, buc, fuc) would hold by the canonical model's completeness infrastructure (bx_forward_witness, bx_until_eventuality_resolution).

**Option 2: Hybrid — Use the Quasimodel Infrastructure for Coherence**

The existing quasimodel infrastructure (9 files, ~2228 lines) already proves `bx_until_eventuality_resolution` for BXPoints. The challenge (dead end #25) was bridging BXPoint chains to Int-indexed chains. 

Under irreflexive semantics, the quasimodel construction has irreflexive-consequence sorries. However, the LOGICAL structure of the completeness proof does not depend on the sorried sorries in Realization.lean and Construction.lean — those are reflexive-semantics artifacts. The quasimodel infrastructure proved what it needed to prove for Frame.lean's Until/Since sorries (tasks 98 and 102). 

**New observation**: The quasimodel was used to prove `bx_until_eventuality_resolution` for Frame.lean. But the coherence properties needed now (`restricted_tc`, `restricted_buc`, `restricted_fuc`) are STRONGER — they need witnesses to be IN THE SAME FMCS FAMILY. The quasimodel provides BXPoint witnesses that are outside the chain. This is dead end #30.

**Option 3: Restrict the Problem Further — `restricted_tc` Only**

If we can close only `restricted_tc` (sorry 1), then `restricted_fuc` (sorry 3) becomes approachable (since BX10 reduces it to restricted_tc + guard argument via BX5). The guard argument via BX5 is non-trivial but the subformula structure helps.

For `restricted_buc` (sorry 2), there is NO path under irreflexive semantics using Lindenbaum-based chains. This may need to remain a sorry unless the semantic completeness approach is adopted.

**Pragmatic recommendation**: Close restricted_tc using the one case that DOES work — when the formula is scheduled and F-obligation persists. Leave a comment explaining the obstruction for the case where F drops before the scheduled step, and consider whether the completeness proof can be restructured to avoid needing restricted_tc for formulas outside the deferral closure window.

---

## Evidence/Examples

### Evidence for Finding 1 (Foundation Problem)

In `TemporalDerived.lean:232-236`:
```lean
def psi_imp_until (φ ψ : Formula) :
    ⊢ ψ.imp (Formula.untl φ ψ) := by
  -- Under irreflexive semantics, ψ → (φ U ψ) is NOT valid.
  -- Need strict future witness s > t with ψ(s); just having ψ(t) is insufficient.
  sorry
```

This flows into `backward_until_reflexive` (UntilSinceCoherence.lean:81-84):
```lean
theorem backward_until_reflexive {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (φ ψ : Formula) (h_psi : ψ ∈ M) : Formula.untl φ ψ ∈ M :=
  SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (Bimodal.Theorems.TemporalDerived.psi_imp_until φ ψ)) h_psi
```

And into `backward_until_from_step` base case (UntilSinceCoherence.lean:130):
```lean
exact backward_until_reflexive (fam.is_mcs t') φ ψ h_psi_s
```

### Evidence for Finding 6 (BUC Obstruction)

The ROADMAP dead end #36(b) states: "Backward Until coherence requires the step transfer `(phi U psi) in chain(r+1) AND phi in chain(r) implies (phi U psi) in chain(r)`. This requires pulling Until from a successor into the current step. The only known mechanism is the deterministic chain's bot-Until linking... which is NOT available for Lindenbaum-based chains."

The BX axiom that would enable this — `φ ∧ F(φ U ψ) → (φ U ψ)` — would require a "next" operator and is NOT in the BX axiom system.

### Evidence for Finding 4 (Resolving Step is the ONLY Proof)

From CanonicalModel.lean:71-76 (`fwd_succ_resolves`):
```lean
theorem fwd_succ_resolves (M : Set Formula) (h_mcs : SetMaximalConsistent M) (ψ : Formula)
    (h_F : Formula.some_future ψ ∈ M) : ψ ∈ fwd_succ M h_mcs ψ
```

This is the ONLY theorem giving a specific formula appearing in a specific chain step. Everything else is about g_content ⊆ chain(n+1), which gives G-propagation but not F-resolution.

---

## Impact Assessment

If all 3 sorries remain:
- `bx_completeness` has `sorryAx` in its axiom set
- The representation theorem does not hold without sorries
- Publication requires either closing these sorries or citing them as open problems

If only restricted_tc is closed:
- restricted_fuc becomes approachable (via BX10 + restricted_tc)
- restricted_buc remains hard (foundation problem + step transfer obstruction)
- bx_completeness still has sorryAx

For publication-readiness, the ROADMAP priority is correct: close all 5 critical-path sorries, then do the axiom audit. The current architecture has the RIGHT structure but the WRONG proof strategy for restricted_tc and no viable strategy for restricted_buc.

---

## Confidence Level

| Finding | Confidence | Evidence |
|---------|-----------|----------|
| Foundation problem in backward_until (Finding 1) | HIGH | Direct code inspection; psi_imp_until is sorry'd |
| Restricted_tc via schedule + monotonicity is the closest to proof (Finding 3) | MEDIUM | Proved infrastructure; case analysis needed |
| Resolving step is the only proved fact about φ appearing (Finding 4) | HIGH | Code inspection; only fwd_succ_resolves gives this |
| F(φ) can drop before scheduled turn (Finding 4) | HIGH | Lindenbaum is unconstrained at non-resolving steps |
| Restricted_buc needs new approach (Finding 6) | HIGH | BX8 removed, no axiom bridges F(ψ) to (φ U ψ) |
| Restricted_fuc depends on restricted_tc + guard (Finding 5) | HIGH | Via BX10 reduction argument |
| Semantic completeness (Option 1) is the principled path | MEDIUM | Literature support; requires significant re-engineering |

**Overall assessment**: The current architecture cannot close all 3 sorries without either (a) adding new axioms to BX (changes the logic) or (b) switching to a semantic completeness approach (Goldblatt/GHR style). The schedule-based chain correctly addresses some problems but the Lindenbaum opacity obstruction remains irreducible for restricted_buc. Restricted_tc has a narrow viable proof strategy using the resolving step, but only if F(φ) can be shown to persist until the scheduled step — which requires either a different chain construction or accepting that this case cannot be closed with the current construction.

**Recommended next step**: Investigate whether restricted_tc can be proved for the SPECIFIC formulas in deferralClosure(root) by exploiting the FINITE nature of deferralClosure. If deferralClosure is finite and scheduledsurjectivity guarantees infinitely many resolving opportunities, a pigeonhole on the FINITE deferralClosure might work — but the obstruction is that F(φ) may disappear before the scheduled turn, not that there aren't enough turns.

The mathematical fact that needs to be true for restricted_tc: "For every formula φ in deferralClosure(root), if F(φ) ever appears in the chain, then φ eventually appears in the chain." This is the eventuality resolution property. It is exactly what the ROADMAP calls `fwd_chain_forward_F` and documents as the fundamental obstruction. After 50+ research rounds, no syntactic proof has been found. The semantic proof (using all MCS, not a chain) is the most promising unexplored path.
