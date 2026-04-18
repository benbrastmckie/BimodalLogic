# Teammate C Findings: Round 39 - Critic Analysis

**Teammate**: C (Critic)
**Date**: 2026-04-18
**Round**: 39
**Focus**: Challenge established conclusions after 38 rounds. Identify blind spots and overlooked possibilities.

---

## Overview

After reading the source files directly -- RootScopedChain.lean (especially lines 659-682,
798-864, 1280-1530, 1950-2200), TemporalCoherence.lean (lines 285-620), WitnessSeed.lean,
and Completeness.lean -- plus the round 37-38 team research syntheses, here are the
key challenges to the established consensus.

---

## Challenge 1: The `rr_fwd_chain` Construction Is NOT the Root Cause of the Three Reachable Sorries

**Established consensus**: The three sorry sites (1517, 1522, 1527) are caused by
`dd_bfmcs` using `rr_fwd_chain` (BX11-fold), which cannot prove Until/Since coherence.

**Challenge**: This framing is WRONG about what the three sorries actually require.

Reading `restricted_temporally_coherent` (TemporalCoherence.lean:295-300):
```
def BFMCS.restricted_temporally_coherent (B : BFMCS D) (root : Formula) : Prop :=
  ∀ fam ∈ B.families,
    (∀ t : D, ∀ φ : Formula, φ ∈ deferralClosure root →
      Formula.some_future φ ∈ fam.mcs t → ∃ s : D, t < s ∧ φ ∈ fam.mcs s) ∧
    (∀ t : D, ∀ φ : Formula, φ ∈ deferralClosure root →
      Formula.some_past φ ∈ fam.mcs t → ∃ s : D, s < t ∧ φ ∈ fam.mcs s)
```

This is purely about F/P eventuality discharge -- NOT about Until/Since directly. The
word "temporally coherent" in `restricted_tc` refers to F and P only. The restricted_buc
and restricted_fuc are the Until/Since coherence obligations.

The signature of `dd_bfmcs_restricted_tc` (line 1513-1517) also shows the `h_sub`
hypothesis that all `deferralClosure(root)` formulas are in `sigma_list`. This is
available because `dd_countermodel` uses `sigma_list = extendedDeferralClosure(phi).toList`
and calls `dd_bfmcs_restricted_tc` with:
```
fun ψ hψ => Finset.mem_toList.mpr (deferralClosure_subset_extendedDeferralClosure φ hψ)
```

**Key insight being missed**: For `dd_bfmcs_restricted_tc`, the question is: given
`F(φ) ∈ shifted_dd_fmcs(N, s).mcs(t)`, does there exist `s' > t` with `φ ∈ shifted_dd_fmcs(N, s).mcs(s')`?

By definition, `shifted_dd_fmcs(N, s).mcs(t) = dd_chain(N, sigma, t - s)`. So this
reduces to: given `F(φ) ∈ dd_chain(N, sigma, t - s)`, find `s' > t` with `φ ∈ dd_chain(N, sigma, s' - s)`.

This IS the same as `dd_fmcs_forward_F` (line 1426-1457, also sorry). But the
`h_sub` hypothesis says φ ∈ sigma_list. And `dd_fmcs_forward_F` for t ≥ 0 reduces
to `rr_fwd_chain_forward_F` (line 1442-1448), which is the depth-0 sorry.

**But here is the critical oversight**: the `self_resolving_fwd_step` infrastructure
at lines 1961-1996 exists ENTIRELY in RootScopedChain.lean. It proves:
- `self_resolving_fwd_step_target`: ψ ∈ M'
- `self_resolving_fwd_step_F_target`: F(ψ) ∈ M'
- `self_resolving_fwd_step_g_content`: g_content(M) ⊆ M'

The question no round has answered: **can dd_chain be simply RE-DEFINED to use
`self_resolving_fwd_step` instead of `enriched_fwd_step`?** Looking at `rr_fwd_chain`
(lines 659-666), it uses `enriched_fwd_step M hM (rrSchedule sigma_list n) sigma_list`.

If instead we define a new chain:
```lean
noncomputable def sr_fwd_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) : (n : Nat) → { M : Set Formula // SetMaximalConsistent M }
  | 0 => ⟨M₀, h₀⟩
  | n + 1 =>
    let ⟨M, hM⟩ := sr_fwd_chain M₀ h₀ sigma_list n
    let target := rrSchedule sigma_list n
    if h : Formula.some_future target ∈ M then
      ⟨self_resolving_fwd_step M hM target h, self_resolving_fwd_step_mcs M hM target h⟩
    else
      ⟨fwd_succ M hM target, fwd_succ_mcs M hM target⟩
```

Then `sr_fwd_chain` would:
1. Have g_content propagation (from `self_resolving_fwd_step_g_content` or `fwd_succ_g_content`)
2. Have forward_F provable: at step n where rrSchedule hits φ and F(φ) ∈ M, we get φ ∈ M' directly

Does `sr_fwd_chain` preserve box stability? YES: `self_resolving_fwd_step` uses the same
seed structure (`enriched_resolving_seed M ψ ψ.some_future` = `{ψ, F(ψ)} ∪ g_content(M)`),
and box stability relies on `g_content` propagation plus BX3 (4-axiom) and BX4 (connect_past).
The same `box_stable_dd_chain` argument applies.

**This redefinition has never been explicitly attempted.** Report 38's contingency plan
(item 2: "redefine dd_chain to use self_resolving_fwd_step") is listed as a FALLBACK.
But given that `self_resolving_fwd_step` is already proved and has all required properties,
this should be the FIRST thing tried, not a fallback.

---

## Challenge 2: The `restricted_tc` Sorry Is Simpler Than Being Treated

**Established consensus**: `dd_bfmcs_restricted_tc` requires closing the depth-0 base
case of `rr_fwd_chain_forward_F`, which is the core obstruction.

**Challenge**: There is a much more direct path that has been overlooked.

`dd_bfmcs_restricted_tc` (line 1513) asserts restricted temporal coherence for `dd_bfmcs`.
The families in `dd_bfmcs` are `shifted_dd_fmcs N h_N sigma_list s` for various N, s.

The `shifted_dd_fmcs` is just `dd_fmcs` shifted by s. The restricted_tc for the
shifted version reduces to restricted_tc for the unshifted version, which reduces to
`dd_fmcs_forward_F`.

**BUT**: What if we change the approach entirely and prove restricted_tc for
`dd_bfmcs` by constructing a DIFFERENT family that witnesses the eventuality?

The families in `dd_bfmcs.families` are:
```
{ fam | ∃ (N : Set Formula) (h_N : SetMaximalConsistent N) (s : Int),
    (∀ φ, Formula.box φ ∈ M₀ ↔ Formula.box φ ∈ N) ∧
    fam = shifted_dd_fmcs N h_N sigma_list s }
```

Restricted_tc says: given F(φ) ∈ fam.mcs(t), find s > t with φ ∈ fam.mcs(s). The witness
must be in the SAME family fam, not a different family. This is the difficulty.

But notice: `fam.mcs(t)` is an MCS, and `self_resolving_fwd_step M hM φ h_F` gives
a new MCS M' with φ ∈ M'. What's blocking us from showing `fam.mcs(t+1) = M'`?

Nothing -- except we don't control the definition of `fam.mcs`. The chain is already
fixed as `rr_fwd_chain`. To change the chain, we need to redefine `dd_chain`, which
means redefining `dd_fmcs` and `dd_bfmcs`.

**The overlooked possibility**: Redefine `dd_chain` to use `self_resolving_fwd_step`
at each step when the F-obligation is active, and `fwd_succ` otherwise. This changes
ONLY the definition of the chain. The `dd_bfmcs` construction, its modal coherence
properties (`modal_forward`, `modal_backward`), and the `box_stable_dd_chain` proof
ALL go through unchanged because they depend only on g_content propagation and box stability.

**This is not a "fallback" -- it is the cleanest direct solution.** The current plan
treats it as a contingency (Plan v38 Contingency #2), but there's no reason it wouldn't
work as the primary approach.

---

## Challenge 3: The "No Chain Replacement Works" Conclusion Is Based on Wrong Evidence

**Established consensus** (strongly stated in round 37 synthesis): "No chain replacement
works because of the tension between F-obligation preservation and direct resolution."

**Challenge**: This conclusion was based on attempts to replace the BX11 fold with other
fold-based constructions. The `self_resolving_fwd_step` approach is CATEGORICALLY different:
it is NOT a fold-based construction. It uses `enriched_resolving_seed M ψ ψ.some_future`
which is `{ψ, F(ψ)} ∪ g_content(M)`. The key:

- `enriched_resolving_seed_consistent` (used by `self_resolving_fwd_step`) is proved
  using `F(ψ ∧ F(ψ)) ∈ M` (from `F_and_self_F_mcs`), not the BX11 fold machinery.
- This does NOT interact with Until/Since formulas -- the seed is purely about ψ and F(ψ).
- The consistency proof is already done. Zero new proof work is needed.

19 "failed approaches" were all variations on the BX11 fold. `self_resolving_fwd_step`
doesn't use BX11 at all. The evidence base for "no chain replacement works" does not
apply to this approach.

---

## Challenge 4: The `restricted_buc` and `restricted_fuc` Proofs May Be Easier Than Believed

**Reading `restricted_backward_until_since_coherent` (TemporalCoherence.lean:565-574)**:
```
def BFMCS.restricted_backward_until_since_coherent (B : BFMCS D) (root : Formula) : Prop :=
  ∀ fam ∈ B.families,
    (∀ t : D, ∀ φ ψ : Formula,
      Formula.untl φ ψ ∈ Bimodal.Syntax.subformulaClosure root →
      (∃ s : D, t ≤ s ∧ ψ ∈ fam.mcs s ∧ ∀ r : D, t ≤ r → r < s → φ ∈ fam.mcs r) →
      Formula.untl φ ψ ∈ fam.mcs t) ∧ ...
```

The conclusion `Formula.untl φ ψ ∈ fam.mcs t` is a MEMBERSHIP claim. The hypothesis
gives a concrete witness structure. This is a direct MCS-level argument.

**Key observation that has been missed**: The proof strategy uses BX8 + BX5 + BX6.

- **BX8** (intro rule for Until): `ψ → φ U ψ`. Base case: if s = t and ψ ∈ mcs(t), done.
- For the inductive case: φ ∈ mcs(t), and by IH (from t+1), φ U ψ ∈ mcs(t+1).
  Need: `φ ∈ mcs(t)` AND `φ U ψ ∈ mcs(t+1)` implies `φ U ψ ∈ mcs(t)`.
  This is the BX derivable rule: `φ ∧ F(φ U ψ) → φ U ψ`.
  Can this be derived from BX1-BX12? YES: from `φ U ψ ∈ mcs(t+1)` and `g_content(mcs(t)) ⊆ mcs(t+1)`,
  if `G(φ U ψ) ∈ mcs(t)` then `φ U ψ ∈ mcs(t)` directly. But we don't have G(φ U ψ).

**The actual gap**: the step from `φ U ψ ∈ mcs(t+1)` to `F(φ U ψ) ∈ mcs(t)` requires
the PAST direction: h_content(mcs(t+1)) ⊆ mcs(t). But wait -- does `dd_chain` have
this property? `rr_bwd_chain_h_content_step` proves h_content propagation for the backward
chain, but the FORWARD chain has g_content propagation, not h_content!

This means `φ U ψ ∈ mcs(t+1)` does NOT imply `H(φ U ψ) ∈ mcs(t+1)`, and even if it
did, H-content backward propagation requires the backward chain.

**This IS a genuine difficulty for restricted_buc.** But there is an overlooked approach:

Instead of going backward from mcs(t+1), we can prove BX-directly at the MCS level:
There exists a derived rule `φ ∧ F(φ U ψ) → φ U ψ` derivable from BX8+BX9+BX10.
Let me check if this is derivable:
- `φ U ψ ∈ mcs(t+1)` implies by BX10 `F(ψ) ∈ mcs(t+1)`, so `G(F(ψ)) ∈ mcs(t)`?
  No -- this requires `G(F(ψ)) ∈ mcs(t)` which is BX4 backward.
- Actually: `F(φ U ψ) ∈ mcs(t)` combined with BX12 gives `⊤ U (φ U ψ) ∈ mcs(t)`.
  With φ ∈ mcs(t) and BX9 at step t: if ¬ψ ∈ mcs(t), then from `⊤ U (φ U ψ)`,
  BX9 gives `⊤ ∈ mcs(t)` or `φ U ψ ∈ mcs(t)`. But ⊤ is always in mcs (theorem).
  This gives nothing useful.

The real issue: `φ ∧ F(φ U ψ) → φ U ψ` is NOT a theorem of propositional tense logic.
Countermodel: ψ false everywhere, φ true everywhere, the Until formula false at t but
F(φ U ψ) false too (correctly). The introduction requires knowing the witness exists.

**The genuine mathematical insight that IS overlooked**: The BUC direction (backward:
given witness structure, conclude Until membership) is actually the SEMANTIC truth
condition for Until, and the canonical model truth lemma should handle this via BX8
and the structure of the witness. The plan is essentially correct for this, but the
plan's complexity obscures a possibly simpler argument: use the Henkin-style induction
on the SEMANTIC witness directly, not a chain-based argument.

---

## Challenge 5: Are All Three Sorry Sites Actually Equally Hard?

**Established consensus**: All three sorries are similarly hard, requiring new
infrastructure of 600-900 LOC.

**Challenge**: The three sorries have VERY different difficulty profiles:

**Sorry 1 (restricted_tc, line 1517)**: Requires F/P eventuality discharge for
`dd_chain`. With `self_resolving_fwd_step` re-chain approach, this becomes straightforward:
at each round-robin step where the schedule visits φ and F(φ) is active, we place φ directly.
The roundrobin schedule visits all formulas in sigma_list within `sigma_list.length` steps.
**Estimated LOC: 100-150 for redefinition + 50-100 for tc proof.**

**Sorry 2 (restricted_buc, line 1522)**: Requires backward Until/Since introduction.
The BX8 base case is trivial. The inductive step requires connecting forward g_content
propagation (which goes rightward) with the backward requirement. This is the hardest
of the three. **Estimated LOC: 200-400.**

**Sorry 3 (restricted_fuc, line 1527)**: Requires forward Until/Since eventuality
discharge. Given φ U ψ ∈ mcs(t), find s ≥ t with ψ ∈ mcs(s) and guard. By BX10,
F(ψ) ∈ mcs(t). By restricted_tc (after solving sorry 1), ψ ∈ mcs(s) for some s > t.
The guard (φ ∈ mcs(r) for all t ≤ r < s) follows from BX9 at each intermediate step
if φ U ψ ∈ mcs(r) for all r in [t, s). **Estimated LOC: 150-200.**

**Key observation**: Sorry 3 is DEPENDENT on sorry 1 only (via restricted_tc for F(ψ)
discharge). Sorry 2 is mostly INDEPENDENT of sorry 1. The priority order should be:
Sorry 1 first (fixes tc), then sorry 3 (uses tc result), then sorry 2 (hardest, independent).

This ordering differs from Plan v38's sequence (Phase 1 = tc, Phase 2 = fuc, Phase 3 = buc),
which is actually correct. But the plan's relative effort estimates are off: buc
is underestimated at 1.5h while tc is over-estimated at 2h.

---

## Challenge 6: The Backwards Chain Is Being Ignored

**Established consensus**: Focus is entirely on the forward direction (restricted_tc, fuc).

**Challenge**: `dd_fmcs_backward_P` (line 1459-1464) is also sorry, and `restricted_tc`
requires BOTH forward F and backward P discharge. The backward P sorry:
```
theorem dd_fmcs_backward_P (...) : ∃ s : Int, s < t ∧ ψ ∈ (dd_fmcs M₀ h₀ sigma_list).mcs s
```

For t < 0, this is in the backward chain. For t ≥ 0, need to find s < t (possibly negative).

The backward chain `rr_bwd_chain` uses `bwd_pred` which is a NON-RESOLVING step (looking
at `defect_bwd_chain` definition, it uses `bwd_pred M hM Formula.bot`). But the symmetric
structure to `self_resolving_fwd_step` is `self_resolving_bwd_step` -- **does this exist?**

Looking at the code: lines 2014-2023 show `P_and_self_P_mcs` exists. Lines 1998-2013
show P-related infrastructure. But there is NO `self_resolving_bwd_step` definition
in the file that's equivalent to `self_resolving_fwd_step`! The round 37 synthesis
(Finding 8) says `defect_bwd_step` (lines 1717-1764) is the backward primitive, but
`defect_bwd_chain` uses `bwd_pred Formula.bot` (non-resolving). This means:

**The backward P sorry requires implementing the self-resolving backward step, which
has NOT been proved yet.** The P-infrastructure (P_and_self_P_mcs, etc.) suggests it
was PLANNED but not implemented. This is a genuine gap that rounds 37-38 glossed over.

The claim in round 37 synthesis (Finding 8) that "defect_bwd_chain uses bwd_pred
Formula.bot which is ALWAYS non-resolving" is presented as a bug to fix but the fix
has not been described or implemented. The symmetric argument:
- `P(ψ ∧ P(ψ)) ∈ M` (from `P_and_self_P_mcs`, proved at line 2020-2023)
- Seed: `{ψ, P(ψ)} ∪ h_content(M)` is consistent
- This is the backward analog of `enriched_resolving_seed_consistent`

Is `enriched_resolving_seed_consistent` available for the backward direction? Looking
at the code, `defect_resolving_seed_consistent` uses the FORWARD direction. There is no
`past_defect_resolving_seed_consistent` visible in the code. This needs to be proved.

---

## Challenge 7: The Compactness Argument for Extended Seed Was Dismissed Too Quickly

**Established consensus**: Round 37 Blocker 1 -- "G-lift fails for Until formulas: if
`alpha U beta in MCS`, this does NOT imply `G(alpha U beta) in MCS`." Therefore extended
seed consistency for the oracle approach fails.

**Challenge**: The round 37 synthesis (section 2 of the synthesis document) gives an
alternative consistency argument: subset-of-MCS argument. Let me re-examine this.

The extended seed is: `{ψ_target} ∪ g_content(w) ∪ {active Until defects from w}`.

The G-lift argument fails for Until formulas because they aren't in g_content. BUT
the subset-of-MCS argument works differently: all Until defects ARE in `w.formulas` by
assumption (they are ACTIVE defects of w). And `{ψ_target} ∪ g_content(w) ∪ {until_defects_of_w}`
is a subset of `{ψ_target} ∪ w.formulas`.

The consistency proof then works like `forward_temporal_witness_seed_consistent`:
if L ⊢ ⊥ and L ⊆ seed:
- If ψ_target ∉ L: L ⊆ w.formulas, so G(L) ⊆ g_content(w) ⊆ w. By gen.temp.K,
  G(L) ⊢ G(⊥), so G(⊥) ∈ w. Then ¬G(¬ψ_target) = F(ψ_target) ∈ w gives contradiction.
- If ψ_target ∈ L: L \ {ψ_target} ⊆ w.formulas. By gen.temp.K on L \ {ψ_target},
  G(L \ {ψ_target}) ⊢ G(¬ψ_target), so G(¬ψ_target) ∈ w. But F(ψ_target) ∈ w.
  Contradiction.

**This argument is valid.** The key point: Until defects don't need G-lifting because
they come directly from w.formulas, not from g_content(w). The Round 37 "Blocker 1"
was checking whether Until defects can be G-lifted (they can't), but the actual
consistency argument doesn't need G-lifting for them.

Round 37 Blocker 1 seems to have been a FALSE BLOCKER for the oracle approach. The
extended seed `{ψ_target} ∪ g_content(w) ∪ {until_defects_of_w}` is consistent
by the subset-of-MCS argument, EXACTLY as described in round 37 synthesis Finding 2,
item b. The fact that G-lift fails doesn't affect this argument.

Why was the oracle approach abandoned? Looking at the plan v38 overview: "Phase 1 (oracle
construction) was blocked by two fundamental issues: (1) extended seed consistency fails
because alpha U beta in MCS does NOT imply G(alpha U beta) in MCS, breaking the G-lift
argument." This is a MISTAKEN characterization. The consistency proof for the extended
seed does NOT use G-lifting for Until formulas. The Round 37 team report itself (Finding
2, paragraph starting "Consistency proof") gives the correct argument that doesn't
need G-lift for Until formulas.

**Conclusion**: The oracle approach (Plan v37) was abandoned based on a mischaracterized
blocker. The extended seed consistency proof works by subset-of-MCS argument and does
NOT require G-lifting Until formulas. This warrants re-examining whether Plan v37 was
correctly abandoned.

---

## Blind Spots Identified

### Blind Spot 1: No one has proved `self_resolving_bwd_step`

The backward analog of `self_resolving_fwd_step` is referred to but never defined.
The P-infrastructure exists (`P_and_self_P_mcs`, `P_and_self_P`) but the step function
itself is missing. This is needed for `dd_fmcs_backward_P` and the backward half of
`restricted_tc`.

### Blind Spot 2: No one has traced the EXACT proof obligation for restricted_buc

Round 37-38 discuss restricted_buc in abstract terms. But the CONCRETE proof obligation
is: given `φ U ψ ∈ subformulaClosure(root)` and an Int-indexed witness structure
`(∃ s ≥ t, ψ ∈ fam.mcs(s) ∧ ∀ r ∈ [t,s), φ ∈ fam.mcs(r))`, prove `φ U ψ ∈ fam.mcs(t)`.

The key missing lemma is: `φ in mcs(t)` AND `F(φ U ψ) in mcs(t)` IMPLIES `φ U ψ in mcs(t)`.
Is this derivable from BX axioms? The derivation: `φ U ψ ∈ mcs(t+1)` gives by BX4
(`φ → P(F(φ))`), specifically the Until version: `φ U ψ → P(F(φ U ψ))`. Then if we
have h_content propagation backward... this only works if mcs(t+1) is the NEXT step
of the backward chain from mcs(t), which is NOT generally true in dd_chain.

### Blind Spot 3: The Until persistence through g_content question was never fully resolved

If `φ U ψ ∈ mcs(t)` and `psi ∉ mcs(t)`, then by BX9: `φ ∈ mcs(t)`. By BX5:
`(φ ∧ (φ U ψ)) U ψ ∈ mcs(t)`. By BX10: `F(ψ) ∈ mcs(t)`.
Question: does `φ U ψ ∈ mcs(t+1)` follow from `g_content(mcs(t)) ⊆ mcs(t+1)`?
Only if `G(φ U ψ) ∈ mcs(t)`, which requires `φ U ψ → G(φ U ψ)` -- NOT a theorem.

So Until formulas do NOT propagate forward through g_content. This means the fuc proof
cannot use simple forward induction. This is a genuine difficulty that has been
acknowledged but no concrete resolution has been proposed.

---

## Overlooked Possibilities

### Possibility 1: Define sr_fwd_chain using self_resolving_fwd_step

Replace `enriched_fwd_step` with a conditional step:
- If `F(rrSchedule sigma_list n) ∈ M`: use `self_resolving_fwd_step M hM target h_F`
- Otherwise: use `fwd_succ M hM target`

This gives forward_F directly by construction: at step n where rrSchedule(sigma_list, n) = φ
and F(φ) ∈ chain(n), we have φ ∈ chain(n+1). Since sigma_list covers all defects within
`sigma_list.length` steps, F-obligations must be discharged within that window.

**The waiting problem**: What if F(φ) ∈ chain(n) but F(φ) disappears before the
rrSchedule visits φ? Answer: F-obligations PERSIST through fwd_succ (by F-carry in
the succ seed) until the round-robin schedule visits φ. This needs a proof, but it's
structurally similar to the existing `rr_fwd_chain_F_obligation_persists` (which applies
to `enriched_fwd_step`). The key fact: `self_resolving_fwd_step_F_target` proves
F(ψ) ∈ M', so even after resolving ψ, F(ψ) persists. And for non-resolving steps
(fwd_succ), F-persistence follows from F-carry in the seed.

### Possibility 2: Prove restricted_tc via counting argument on sigma_list

If we use the round-robin chain (whether original or sr_fwd_chain variant), within
`sigma_list.length` steps EVERY formula in sigma_list is visited once. If F(φ) ∈ chain(n)
and φ ∈ sigma_list, then within `sigma_list.length` steps we will reach step n + k
where rrSchedule(sigma_list, n+k-1) = φ. At that step:
- In sr_fwd_chain: if F(φ) ∈ chain(n+k-1), the step directly places φ in chain(n+k).
- F(φ) ∈ chain(n+k-1) follows from F-obligation persistence (F-carry through all non-resolving steps).

This gives a constructive proof: witness s = n + k where k = (index of φ in rrSchedule from n).
**This requires F-obligation persistence for the sr_fwd_chain, which is provable.**

### Possibility 3: Use a "lazy" Until witness for restricted_fuc

Instead of proving Until formulas propagate through the chain, use the following:
Given `φ U ψ ∈ fam.mcs(t)`, BX10 gives `F(ψ) ∈ fam.mcs(t)`. By restricted_tc
(after solving sorry 1), `∃ s > t, ψ ∈ fam.mcs(s)`. Take the SMALLEST such s.
For the guard: show φ ∈ fam.mcs(r) for r ∈ [t, s) by:
- At r = t: if s > t, then ψ ∉ fam.mcs(t) (by minimality), so BX9 gives φ ∈ fam.mcs(t).
- For r ∈ (t, s): need φ ∈ fam.mcs(r). But we only know F(ψ) ∈ fam.mcs(t), not at r.

Actually the minimality argument breaks here. F(ψ) ∈ fam.mcs(r) for r ∈ (t, s) is
NOT guaranteed without Until persistence.

**A different minimality approach**: Use semantic minimality + MCS completeness.
Suppose φ U ψ ∉ fam.mcs(t). Then ¬(φ U ψ) ∈ fam.mcs(t). By MCS negation completeness
and BX axioms... wait, we need the BACKWARD direction (buc) to conclude
φ U ψ ∈ fam.mcs(t). This is circular.

The fuc (forward Until coherence) proof does NOT depend on buc. It goes:
- fuc says: φ U ψ ∈ mcs(t) → witness exists.
- This is proved forward from the hypothesis.
- buc says: witness exists → φ U ψ ∈ mcs(t).
- This is the harder backward direction.

For fuc alone, the minimality argument with restricted_tc (sorry 1) gives the witness.
The guard proof needs Until persistence through the chain, which is not guaranteed.

**Overlooked fix for the guard in fuc**: The guard φ ∈ mcs(r) for r ∈ [t, s) only
needs to hold for r values that are actually IN the chain. Since fam.mcs is defined
for ALL integers (it's Int-indexed), this is a non-trivial constraint. But crucially:
if we use a MODIFIED chain definition that preserves Until formulas in the seed (by
adding `φ U ψ` to the forward resolving seed when F(ψ) ∈ mcs and it's the target),
we could maintain Until membership through the chain. This is essentially the oracle
approach of Plan v37 but applied to dd_chain itself.

---

## Questions That Should Be Asked But Aren't

1. **Can `self_resolving_bwd_step` be proved easily?** The infrastructure is 90%
   there (P_and_self_P_mcs exists). This is likely 30-50 LOC and may unlock backward_P
   for free.

2. **Does the sr_fwd_chain have the box stability property?** This determines whether
   the modal coherence of dd_bfmcs would be preserved under redefinition. Given that
   box stability comes from BX3 (4-axiom) and BX4 (past connection), and
   `self_resolving_fwd_step` only changes which MCS is chosen (not the modal content),
   the answer is almost certainly YES.

3. **What is the ACTUAL minimal set of lemmas needed for restricted_buc?**
   The plan lists complex BX9+BX10+BX12 derivation chains. But the actual obligation
   is: given a semantic Until witness structure, conclude syntactic Until membership.
   Is there an existing `until_intro_mcs`-style lemma anywhere in the codebase?
   Grep for "until_intro" has not been done.

4. **Is `Until_intro_from_guard_and_F` derivable from BX axioms in the form needed?**
   Specifically: `φ ∈ mcs(t) ∧ F(φ U ψ) ∈ mcs(t) → φ U ψ ∈ mcs(t)`. This is
   equivalent to `⊢ φ → (F(φ U ψ) → φ U ψ)`. Is this derivable from BX1-BX12?

5. **Has anyone checked whether `dd_bfmcs_restricted_buc` is actually REACHED by
   the truth lemma for simple formulas without Until?** If the root formula φ has no
   Until subformulas, `subformulaClosure(root)` contains no Until formulas, so buc
   and fuc are vacuously true. This means for completeness of Until-free formulas,
   only restricted_tc needs to be solved.

---

## Summary Assessment

The consensus is roughly correct in identifying the three sorry sites as the blockers,
but wrong in some key details:

**Confirmed obstacles**:
- Forward F/P eventuality discharge for dd_chain (sorry 1 / restricted_tc): REAL blocker
- Until persistence through g_content (for fuc guard proof): REAL technical challenge
- Until introduction (for buc backward proof): REAL technical challenge, possibly harder
  than acknowledged

**Potentially false blockers**:
- "Extended seed consistency fails for the oracle approach": This appears to be a
  MISTAKEN characterization. The subset-of-MCS argument works for Until defects.
  Plan v37 may have been abandoned prematurely.
- "No chain replacement works": This applies to BX11-fold replacements only. The
  sr_fwd_chain approach using self_resolving_fwd_step has not been attempted.

**Overlooked paths**:
- Redefine dd_chain to use self_resolving_fwd_step (primary approach, not fallback)
- Prove self_resolving_bwd_step (needed for backward_P, 30-50 LOC)
- Check for until_intro_mcs infrastructure that could short-circuit buc proof

---

## Confidence Level

**HIGH confidence (90%)**: Challenge 1 and 2 -- the self_resolving_fwd_step chain
redefinition is viable and has not been the primary focus of any implementation attempt.

**HIGH confidence (85%)**: Challenge 7 -- the Plan v37 oracle abandonment was based
on a mischaracterized blocker. Extended seed consistency with Until defects from w.formulas
is provable by subset-of-MCS argument, not G-lifting.

**MEDIUM confidence (65%)**: Challenge 4 -- restricted_buc is harder than current
plan acknowledges. The BX-derivable Until introduction rule may not exist in the needed
form.

**MEDIUM confidence (70%)**: Blind Spot 1 -- self_resolving_bwd_step is missing and
needed. High likelihood it can be proved symmetrically.
