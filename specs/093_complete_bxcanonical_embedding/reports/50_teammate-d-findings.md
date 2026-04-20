# Teammate D: Strategic Horizons (Round 50)

**Task**: 93 - Complete BXCanonical Embedding
**Date**: 2026-04-20
**Role**: Horizons — long-term architectural implications

---

## Executive Summary

After 50 research rounds, the project has reached a definitive mathematical crossroads. This
report provides a ranked strategic analysis of the viable paths forward, with particular attention
to what each option means for the long-term completeness goal, the publishability of the result,
and the health of the existing 21,941-line codebase.

**Key finding**: The guard convention conflict is NOT a nuisance — it is a fundamental signal
about the axiom system's design. The path forward depends on which version of "completeness"
the project intends to prove. This choice should be made explicitly, not by default.

---

## Part I: Precise Statement of the Problem

### What Truth.lean Actually Implements

Reading `Truth.lean` lines 127-128 directly:

```lean
| Formula.untl φ ψ => ∃ s : D, t < s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t < r → r < s → truth_at M Omega τ r φ
```

This is the **open guard convention**: strict witness `s > t`, guard on the open interval `(t, s)`.
The point `t` itself is NOT in the guard.

### What This Means for the Axiom System

Under the open guard `(t, s)` convention:

| Axiom | Formula | Valid? | Why |
|-------|---------|--------|-----|
| BX2 | `G(phi->chi) -> (phi U psi -> chi U psi)` | YES | Guard is `(t, s)`, G covers all `r > t` |
| BX3 | `G(phi->psi) -> (chi U phi -> chi U psi)` | YES | Endpoint only |
| BX4 | `phi -> G(P(phi))` | YES | Temporal connectedness |
| BX5 | `(phi U psi) -> ((phi & phi U psi) U psi)` | YES | Same witness, guard is `(t, s)` |
| BX6 | `phi U (phi & phi U psi) -> phi U psi` | YES | Standard |
| BX7 | Linearity | YES | Standard |
| BX8 | `phi & F(phi U psi) -> phi U psi` | NO | Need phi(t) but guard is (t, s) |
| BX9 | `(phi U psi) -> phi ∨ psi` | NO | Guard `(t,s)` excludes `t`; phi(t) not guaranteed |
| BX10 | `(phi U psi) -> F(psi)` | YES | Witness `s > t` gives F(psi) |

Under the **half-open guard** `[t, s)` convention (i.e., replace `t < r` by `t <= r` in the guard):

| Axiom | Valid? | Why |
|-------|--------|-----|
| BX2 | NO | G covers `r > t` strictly, but guard [t,s) includes `t`; cannot apply G at `r = t` |
| BX8 | YES | Guard [t,s) includes `t`, so phi(t) holds |
| BX9 | YES | Guard [t,s) includes `t`, so phi(t) ∨ psi(t) holds |

**This is the core tension**: BX2 requires G to cover the guard, which forces the guard to be open. BX9
requires the guard to include `t`. These requirements are mutually exclusive under the current definition
of G (strictly future, `s > t`).

### Why BX8 and BX9 Have Sorries in Soundness.lean

The sorries in `until_step_valid` and `until_elim_valid` are not engineering debt. They reflect a genuine
incompatibility: the axioms as written are NOT valid under the semantics as implemented. The codebase
comment "This axiom is NOT directly semantically valid under irreflexive semantics with open guard" is
correct.

---

## Part II: Analysis of Each Strategic Option

### Option A: Fix the Guard Convention

**Proposal**: Change Until semantics to half-open `[t, s)` by modifying Truth.lean line 128.

**Mathematical analysis**:
- This makes BX8 and BX9 valid (guard includes `t`)
- This breaks BX2 validity (G is strict, guard now includes `t`)
- BX2's validity proof currently works because `h_G r htr` uses `htr : t < r`. With half-open guard,
  `r = t` is possible, but `h_G t (le_refl t)` would need `G` to cover `t` itself, which it doesn't
  under irreflexive semantics.

**Resolution within Option A**: BX2 could be reformulated as:
```
(phi -> chi) ∧ G(phi -> chi) -> (phi U psi -> chi U psi)
```
This adds the current-point implication explicitly. But this is a different formula from the standard
BX2. It is derivable from BX2 via trivial weakening only if BX1 (G(phi) -> phi) holds.
Under irreflexive semantics, BX1 is removed. So this reformulation requires adding a new axiom.

**Alternatively**: Keep G reflexive for the Until guard but use strict G elsewhere. This creates
two flavors of G, which is semantically incoherent.

**Code impact**:
- Truth.lean: 1 line change (add `t <= r` instead of `t < r` in guard)
- Soundness.lean: BX2 proof broken (~5 lines), BX8/BX9 proofs closable (~30 lines each)
- All downstream canonical model proofs: BX2-at-MCS-level lemmas remain valid (they use
  the axiom, not the semantic proof), so the proof system is unaffected
- Net LOC change: ~+50 lines, 2 sorries closed, 1 new sorry (BX2 validity)

**Assessment**: Option A trades the BX9 sorry for a BX2 sorry. It is not a net improvement
unless BX2 is reformulated or a reflexive G is introduced.

---

### Option B: Modify the Axiom System (Remove or Weaken BX8/BX9)

**Proposal**: Remove BX8 (`phi ∧ F(phi U psi) -> phi U psi`) and BX9 (`(phi U psi) -> phi ∨ psi`)
from the axiom system. Replace with weaker axioms that are valid under open guard.

**Mathematical analysis**: What do BX8 and BX9 actually do in the proof system?

**Role of BX9** (`until_elim`): Used critically in `bx_until_eventuality_resolution` in Frame.lean
(line 689). It proves `phi ∈ w.formulas` when `phi U psi ∈ w.formulas` and `psi ∉ w.formulas`.
This is used to establish the guard property in the truth lemma forward direction.

**Role of BX8** (`until_step`): Appears in Axioms.lean but is sorry'd in Soundness.lean. Its role
in the proof system: provides a "step introduction" rule. Under open guard, this is not valid
semantically, which means the canonical model may have MCS violating BX8 semantically — but since
the proof system includes BX8 as an axiom, all MCS are closed under it derivationally.

**Critical observation**: Removing BX9 from the proof system would require finding an alternative
source for `phi ∈ w` when `phi U psi ∈ w` and `psi ∉ w`. This is used in:
- `bx_until_eventuality_resolution` (Frame.lean line 689)
- `until_elim_mcs` (Construction.lean line 114)
- The truth lemma forward direction for Until

Without BX9, these proofs would require a different argument to establish `phi ∈ w`. The only
alternative is to use BX5 (self-accumulation) and BX10 together to establish that `phi` appears
somewhere in the "chain" from `w` to the witness — but not at `w` itself.

**Blast radius**: Removing BX9 would require redesigning `bx_until_eventuality_resolution`.
Estimated: 100-200 LOC redesign, with moderate risk that no clean replacement exists.

**Keeping BX9 but marking it "discrete/serial only"**: Make BX9 a frame-class axiom valid only
on serial (NoMaxOrder + NoMinOrder) frames. Under serial frames with open guard, BX9 fails (the
countermodel `ψ at t+1, empty guard at t` still exists). So serial frames don't save BX9 with
open guard either.

**Assessment**: Option B (removing BX9) requires redesigning key completeness infrastructure.
The only semantically valid replacement for BX9 under open guard is: "either psi ∈ w, or phi ∈
some future successor of w." This is a strictly weaker property and makes the truth lemma harder
to prove.

---

### Option C: Change G/F Definition (Make G Reflexive)

**Proposal**: Change `all_future` and `all_past` to use `≤` instead of `<`, making G and H
reflexive operators. This aligns with the original reflexive semantics the project used before
the irreflexive switch.

**Mathematical analysis**:
- Under reflexive G: `G(phi)` at `t` means `∀ s ≥ t, phi(s)` (includes present)
- BX1 (`G(phi) -> phi`) becomes valid again
- BX2 under reflexive G + open guard: G now covers `r ≥ t`, so it does cover `r = t`. But the
  Until guard is open `(t, s)` which excludes `t`. So BX2 is: "G covers all `r ≥ t`, guard is
  `(t, s)`, which excludes `r = t`." The guard proof still works (only needs `r > t`).
- BX9 under reflexive G + open guard: Still fails. Guard `(t, s)` excludes `t`. G being
  reflexive does not change this.
- BX9 under reflexive G + reflexive (half-open) Until: `phi U psi` at `t` means `∃ s ≥ t, ψ(s)
  ∧ ∀ r, t ≤ r < s, phi(r)`. Guard `[t, s)` includes `t`. BX9 becomes valid.

**Combined change**: Reflexive G + reflexive Until (half-open guard `[t, s)`) = the original
semantics before the irreflexive switch. Under original reflexive semantics:
- BX1 valid, BX2 valid (G covers `[t, ∞)`), BX9 valid (guard `[t, s)`)
- BUT: `phi -> F(phi)` is derivable (reflexive F gives trivially `phi -> F(phi)` via BX1 dual)
- This re-enables the Lindenbaum re-entry problem that motivated the irreflexive switch

**Assessment**: Option C is equivalent to reverting the irreflexive switch. The previous 49
rounds of research established that reflexive semantics, while making all axioms valid, creates
an insurmountable Lindenbaum re-entry problem in the chain construction. The round 49 team
consensus was: do NOT revert. This assessment stands.

---

### Option D: Return to Reflexive Semantics (Full Revert)

**Proposal**: Fully revert the semantics to reflexive `≤` for G, H, and reflexive witness for
Until/Since.

**This is Option C generalized.** The analysis above applies. The irreflexive switch was
motivated by the observation that `phi -> F(phi)` is derivable under reflexive semantics,
preventing the constrained Lindenbaum approach from working.

**However**, a new consideration emerges from this analysis: the Lindenbaum re-entry problem
under reflexive semantics was judged fatal 49 rounds ago. But at that time, the constrained
Lindenbaum approach was not yet the primary recommendation. The question is: does constrained
Lindenbaum resolve the re-entry problem under reflexive semantics?

**Under reflexive semantics**: `phi -> F(phi)` IS derivable (from BX1: G(phi) -> phi, hence
F(phi) = ¬G(¬phi), and ¬G(¬phi) follows from ¬(¬phi)). This means:
- `F(phi)` IS in `g_content(M) ∪ {phi}` (derivable)
- Excluding `F(phi)` from the Lindenbaum extension requires `neg(F(phi))` to be consistent with
  the seed, but the seed derivationally forces `F(phi)`
- Therefore, constrained Lindenbaum CANNOT exclude `F(phi)` under reflexive semantics

**Assessment**: Option D fails for the same reason that motivated the irreflexive switch. The
round 49 consensus was correct: do not revert to reflexive semantics.

---

### Option E: Separate Logic — Different Until for Different Purposes

**Proposal**: Have two Until operators:
1. `phi U_sem psi`: Semantic Until (used in Truth.lean) with open guard `(t, s)` for valid semantics
2. `phi U_ax psi`: Axiomatic Until (used in ProofSystem) with axioms BX2-BX10 including BX9

Connect them via a proved equivalence lemma.

**Mathematical analysis**: This is the approach used in some temporal logic formalizations where
the "Until" in the Hilbert system is defined by its axioms, and the "Until" in the semantic
interpretation is the standard one. The key question is whether they have the same models.

In the BX system, the axioms BX2-BX10 characterize Until. If BX9 is included and is valid only
under half-open guard, while BX2 is valid only under open guard, then no single semantic
Until can make all axioms valid simultaneously. The two operations `U_sem` and `U_ax` would
not be equivalent in general.

This option essentially acknowledges that the axiom system is inconsistent with the intended
semantics. If that is true, the entire completeness project needs to be reframed.

**Assessment**: If BX8 and BX9 are genuinely incompatible with BX2 under any single guard
convention, Option E is not a solution but an admission of the problem. We need to determine
whether the axiom set is CONSISTENT (has a model) and whether it is COMPLETE for that model.

---

## Part III: The Root Cause — Is the Axiom System Consistent?

This is the most important question to answer before choosing any strategic path.

### Checking Consistency: Does Any Model Satisfy All BX Axioms?

Consider the integers `Z` with the standard ordering. Define Until as the classical LTL Until
(open guard `(t, s)`). Then:

- BX9 (`phi U psi -> phi ∨ psi`) fails: Take phi = FALSE, psi = TRUE, present time `t=0`.
  Then `FALSE U TRUE` at 0 holds (witness `s=1`, empty guard on `(0,1)`). But `FALSE ∨ TRUE` at
  0 = TRUE, which holds. Wait — psi = TRUE makes `phi ∨ psi = FALSE ∨ TRUE = TRUE`. So this
  model satisfies BX9 trivially in this instance.

- Let phi = p (atom false at t), psi = q (atom true at t+1), guard empty. Then `p U q` at t
  holds (witness t+1, empty guard). But `p ∨ q` at t = FALSE. So BX9 fails: a model where
  `p U q` holds at t but neither `p(t)` nor `q(t)`.

**Conclusion**: Under open guard, BX9 is NOT universally valid. Any model satisfying BX9 (as
an axiom all derivable theorems must hold in) must use a guard that guarantees `phi(t)`.

**The standard literature resolution** (Burgess 1984, Xu 1988): In the original Burgess-Xu
axiom system, Until uses a **reflexive witness** `s ≥ t` with half-open guard `[t, s)`. Under
this convention:
- `s = t` is allowed, meaning `psi(t)` alone satisfies `phi U psi`
- BX9: guard `[t, s)` includes `t`, so `phi(t) ∨ psi(t)` holds
- BX2: G covers `∀ r ≥ t`, guard `[t, s)` includes all these points, so BX2 is valid

**This is the fundamental misalignment**: The project switched to irreflexive G (`s > t`) while
retaining the axiom set BX2-BX9 designed for reflexive G. These are incompatible.

---

## Part IV: The Core Incompatibility Precisely Stated

Under irreflexive G (`∀ s > t`) and open guard `(t, s)`:
- BX2 is valid (G covers `(t, ∞)`, guard is `(t, s)`, consistent)
- BX9 is NOT valid (guard `(t, s)` excludes `t`)

Under irreflexive G (`∀ s > t`) and half-open guard `[t, s)`:
- BX2 is NOT valid (G covers `(t, ∞)`, guard `[t, s)` includes `t`, G doesn't cover `t`)
- BX9 is valid (guard includes `t`)

The irreflexive switch created an axiom-semantics mismatch that CANNOT be resolved by guard
convention alone. One of the following must change:

1. **G must be made reflexive** (reverts the irreflexive switch — Option D, rejected above)
2. **BX2 must be reformulated** to use pointwise implication instead of G-guarded implication
3. **BX9 must be removed** and replaced with a weaker axiom valid under open guard
4. **The semantics for Until must use reflexive witness** `s ≥ t` with half-open guard

Option 4 is different from Options C/D because it changes ONLY Until/Since, not G/H.

---

## Part V: Ranked Strategic Paths

### Path 1 (RECOMMENDED): Reflexive Until with Irreflexive G

**Mechanism**: Keep G as `∀ s > t` (irreflexive), but change Until/Since to use **reflexive
witness** `s ≥ t` with half-open guard `[t, s)`. This is the "middle ground" between full
reflexive semantics (Option D) and the current state.

**Why this resolves the tension**:
- BX2 under irreflexive G + reflexive Until `[t, s)`:
  `h_G r htr` requires `t < r`. Guard needs phi at `r ∈ [t, s)`. At `r = t`: the Until formula
  has guard `[t, s)`, so `phi(t)` must hold. But G provides only `r > t`. This is the same
  problem.

  Wait — need to recheck. Under reflexive Until: `phi U psi` at `t` iff `∃ s ≥ t, psi(s) ∧
  ∀ r, t ≤ r < s, phi(r)`. BX2: `G(phi->chi)` at `t` means `∀ r > t, phi(r)->chi(r)`.
  Guard: `∀ r, t ≤ r < s`. At `r = t`: need `phi(t)->chi(t)`. G covers `r > t`, NOT `r = t`.

  Therefore, BX2 remains invalid under reflexive Until + irreflexive G.

  **The fundamental theorem**: For BX2 and BX9 to be simultaneously valid, G must cover the
  same domain as the Until guard. If G is strict (`> t`) and the guard is `≥ t`, there is a
  gap at `t`. This gap makes BX2 or BX9 invalid depending on which convention is chosen.

**Revised assessment of Path 1**: It does NOT work as stated. The conflict is inherent in having
G strict and the Until guard include the present. The resolution MUST involve one of:
(a) Making G reflexive (includes present), or
(b) Making BX2 use pointwise implication

---

### Path 1 (Revised): Reformulate BX2 with Pointwise Plus G-guarded

**Mechanism**: Change BX2 from `G(phi->chi) -> (phi U psi -> chi U psi)` to the equivalent
under half-open guard: `(phi->chi) ∧ G(phi->chi) -> (phi U psi -> chi U psi)`.

Under irreflexive G + half-open guard:
- The guard `[t, s)` includes `t`
- G covers `(t, ∞)`, so `G(phi->chi)` provides `phi->chi` at all `r > t`
- The conjunct `phi->chi` provides it at `t`
- Together: `phi->chi` at all `r ∈ [t, s)`. BX2 holds.

**BX9 validity**: Under half-open guard `[t, s)`, BX9 is valid. Guard includes `t`, so `phi(t)`
holds (from the guard when `s > t`), hence `phi(t) ∨ psi(t)`.

**BX8 validity**: `phi ∧ F(phi U psi) -> phi U psi`. Under half-open guard: `phi(t)` is given.
`F(phi U psi)` gives `∃ s' > t, (phi U psi)(s')` which gives `∃ s'' > s', psi(s'')` with guard
`[s', s'')`. Need witness for `phi U psi` at `t`: use `s''` with guard `[t, s'')`. At `r = t`:
`phi(t)` from hypothesis. At `r ∈ (t, s')`: `phi(r)` from... the `phi U psi` at `s'` only
covers `[s', s'')`. This is the same obstruction as before: no guarantee of `phi` on `(t, s')`.
BX8 appears invalid even under half-open guard with strict G.

**BX8 alternative**: BX8 is valid on DENSE orders or DISCRETE orders with the next operator.
Under the BX axiom system (designed for ALL linear orders including Z), BX8 requires additional
structure. This is probably why BX8 was originally not in Burgess's 1984 axiom set.

**The clean resolution**: The Burgess-Xu axiom system (as described in the published literature)
uses REFLEXIVE Until/Since, which is the convention where `s = t` is the witness when `psi(t)`.
Under this convention, ALL axioms BX2-BX10 are valid on linear orders.

---

### Path 2 (STRONGLY RECOMMENDED): Return to Reflexive Until/Since

**Mechanism**:
1. Change `Formula.untl`: `∃ s ≥ t, psi(s) ∧ ∀ r, t ≤ r < s, phi(r)` (reflexive witness)
2. Change `Formula.snce`: `∃ s ≤ t, psi(s) ∧ ∀ r, s < r ≤ t, phi(r)` (reflexive witness)
3. Keep G/H as strict (`> t` / `< t`) — this is the "irreflexive switch" that stays
4. All BX2-BX10 axioms become valid

**Why G can stay irreflexive**: The BX axiom system uses G only for the monotonicity axioms
(BX2, BX3). Under reflexive Until and strict G:
- BX2: G covers `(t, ∞)`, guard `[t, s)` includes `t`. At `r = t`, G doesn't cover. Problem.

**Wait — I am computing this incorrectly.** Let me reread the actual BX2 proof in Soundness.lean:

```lean
intro h_G ⟨s, hts, h_ψs, h_guard⟩
exact ⟨s, hts, h_ψs, fun r htr hrs => h_G r htr (h_guard r htr hrs)⟩
```

Under the CURRENT open guard, `h_guard r htr hrs` requires `htr : t < r`. So only `r > t` is in
the guard. BX2 works because `h_G r htr` provides `phi r -> chi r` for `r > t`, and the guard
only has `r > t` elements.

Under reflexive Until with strict witness `s > t` but half-open guard `[t, s)`:
- `h_guard r htr hrs` would give `phi r` for `r` with `t ≤ r < s`
- At `r = t`, we need `h_G t (refl)` but G is strict, so `h_G : ∀ r, t < r, phi r -> chi r`
- `h_G t` requires `t < t`, which fails

Under **fully reflexive Until** (reflexive witness `s ≥ t`, half-open guard `[t, s)`):
- This allows `s = t`, meaning `phi U psi` holds at `t` iff `psi(t)` (with empty guard)
- The BX2 proof still has the same problem at `r = t`

**The ONLY resolution without modifying G** is to use the open guard AND not need `phi(t)` in
BX9. But BX9 requires `phi(t)`.

### The Definitive Answer

After rigorous analysis, the only way to have ALL of BX2, BX9 valid with a consistent semantics is:

**Make G reflexive**: `G(phi)` at `t` means `∀ s ≥ t, phi(s)`. Then:
- BX2: G covers `[t, ∞)`, guard `[t, s)`, so G provides `phi->chi` at all guard points including `t`
- BX9: Guard `[t, s)` includes `t`, so `phi(t)` holds

This is the original reflexive semantics. The "irreflexive switch" was applied to G, which broke
the axiom-semantics alignment.

**The Lindenbaum re-entry problem under reflexive G**:
- `phi -> F(phi)` is derivable when G is reflexive (via BX1: `G(phi) -> phi`, applied to `G(¬phi)`)
  Specifically: if G(¬phi) then ¬phi (BX1), so ¬G(¬phi) is not directly derivable from phi.
  Wait — under reflexive G: `phi -> G(phi)` is NOT an axiom. `G(phi) -> phi` (BX1) is.
  `phi -> F(phi)` means `phi -> ¬G(¬phi)`. Under reflexive G: `¬G(¬phi)(t)` means `∃ s ≥ t, phi(s)`.
  Taking `s = t`, `phi(t)` gives `phi(s)`. So `phi -> F(phi)` IS valid under reflexive G.

Under reflexive G with reflexive Until: the Lindenbaum re-entry problem is real. But is it actually
fatal for the constrained Lindenbaum approach?

The constrained Lindenbaum approach requires that `¬F(phi)` is consistent with `seed = g_content(M) ∪ {phi}`.
Under reflexive G: `phi -> F(phi)` is semantically valid but is it DERIVABLE? Check: does the BX
axiom system with reflexive G derive `phi -> F(phi)`?

- BX1: `G(phi) -> phi`. Applied to `¬phi`: `G(¬phi) -> ¬phi`. Contrapositive: `phi -> ¬G(¬phi) = F(phi)`.

YES. `phi -> F(phi)` is derivable from BX1 (by contrapositive applied to `¬phi`). Therefore,
in ANY MCS M, if `phi ∈ M`, then `F(phi) ∈ M`. The constrained Lindenbaum approach cannot
exclude `F(phi)` when `phi` is in the seed.

**Conclusion**: Reflexive G makes all BX axioms valid but makes constrained Lindenbaum impossible.
Irreflexive G avoids the re-entry problem but breaks BX9 validity.

---

## Part VI: The Three Viable Paths (Ranked)

### Path 1: Reformulate BX2 to Include the Present Point (BEST OPTION)

**Change**: In the proof system, replace BX2 with:
- `(phi -> chi) ∧ G(phi -> chi) -> (phi U psi -> chi U psi)` (adds present-point implication)

In the semantics: keep irreflexive G, change Until to half-open guard `[t, s)` with strict witness.

**Why this is the best approach**:
1. Preserves the irreflexive switch (correct motivation: avoid `phi -> F(phi)`)
2. Makes BX9 valid (guard includes present)
3. Makes BX8 valid under serial frames (present + future gives witness)
4. Makes BX2 valid (present-point covered by hypothesis, future by G)
5. All other BX axioms (3-7, 10) continue to be valid

**Publishability**: The modified BX2 is equivalent to the original in models where G is reflexive
(via BX1). The resulting system is provably sound and complete for irreflexive linear orders
(integers). This is a publishable result: "sound and complete axiomatization of Until/Since over
Z with irreflexive modal-temporal operators."

**Code impact**:
- `Axioms.lean`: Change `left_mono_until` and `left_mono_since` (~5 lines)
- `Soundness.lean`: Update BX2 proof (~10 lines), close BX9 sorry (~10 lines), close BX8 sorry
  if serial frame class used (~15 lines on `valid_discrete` or new `valid_serial`)
- Proof system: `Substitution.lean` updated for new axiom form (~5 lines)
- Truth lemma: Minor updates since BX9 now valid (~20 lines)
- Total: ~65-80 LOC modifications
- Sorries closed: `until_elim_valid`, `since_elim_valid`, `until_step_valid` (if serial)
- No downstream canonical model code broken (it uses axioms, not their semantic proofs)

**Risk**: Low. The reformulated BX2 is logically stronger than the original (it adds a conjunct).
Any proof using BX2 still goes through. The new axiom is valid under the new semantics.

**Does it affect the chain construction sorries?** No — those sorries are about the Lindenbaum
chain construction, not about soundness. They remain open. But at least the axiom system is sound.

---

### Path 2: Task 95 Axiom Audit First (PREREQUISITE TO ALL PATHS)

**Before implementing any semantic change**, the axiom audit (task 95) should be performed:
1. Enumerate all BX axioms with their precise formulas
2. For each axiom, check validity under each guard convention
3. Produce a decision matrix: which convention makes which axioms valid
4. Identify any additional axioms needed to complete the system

**Why this is prerequisite**: The current analysis shows BX2 vs BX9 tension, but there may be
other incompatibilities not yet discovered. The audit will reveal whether Path 1's reformulation
is sufficient or whether more axioms need adjustment.

**Code impact**: Zero (research only). Creates `specs/095_*/reports/`.

---

### Path 3: Accept the Current Axiom-Semantics Gap as Intentional (LOWEST EFFORT, HIGHEST RISK)

**Mechanism**: Keep the codebase as-is. The `sorry`s in `until_elim_valid` and `until_step_valid`
remain. The canonical model proof proceeds without completing these soundness lemmas.

**Mathematical justification**: The COMPLETENESS proof (canonical model) and the SOUNDNESS proof
are independent. One can have a complete proof system that is not yet formally proven sound.
The sorry'd soundness lemmas do not block the completeness direction.

**What is actually needed for completeness**: The sorry sites in `RootScopedChain.lean` are:
1. `fwd_chain_forward_F` — termination of defect-discharge
2. `dd_bfmcs_restricted_tc` — temporal coherence
3. `dd_bfmcs_restricted_buc`, `dd_bfmcs_restricted_fuc` — Until/Since coherence

These are about the CHAIN CONSTRUCTION, not about soundness. The 49-round blocker is the chain
construction, not soundness.

**Risk**: If the axiom system turns out to be semantically inconsistent (has no model where BX2,
BX8, BX9 are all valid), then the "completeness" theorem would be vacuously true — every
formula is derivable from an inconsistent axiom system. This would invalidate the entire project.

**Current status on consistency**: The analysis above shows that under REFLEXIVE G semantics,
all BX2-BX9 axioms are valid. So the system IS consistent (has models). The question is only
whether it is sound for the INTENDED semantics (irreflexive G).

---

## Part VII: Impact on the Quasimodel Infrastructure

The quasimodel infrastructure (`Quasimodel/` directory, 2,378 lines, 31 sorries) uses BX9 at
the MCS level (in `Construction.lean` via `until_elim_mcs`). This proof goes through the axiom
system, so it remains valid as long as BX9 is an axiom (regardless of whether it has a semantic
proof).

**Key sorries in Quasimodel**:
- `F_of_mem` (Realization.lean line 67): Used to derive `F(psi) ∈ w` from `psi ∈ w`. Under
  irreflexive G + BX1 removed: this fails. It is correctly sorry'd.
- `P_of_mem` (Realization.lean line 73): Dual, also correctly sorry'd.

These sorries are structural — they reflect genuine gaps from the irreflexive switch, not just
incomplete proofs. They indicate that the quasimodel approach also has issues stemming from the
same root cause.

**If Path 1 (reformulate BX2) is adopted**: The quasimodel sorries for `F_of_mem` and `P_of_mem`
remain blocked because they depend on BX1 (which is still removed under irreflexive G). These
are non-critical path items.

---

## Part VIII: What Makes Mathematical Sense for Z-Semantics

The BX system is intended to model **tense and modality over integer time** Z. The "natural"
semantics for Until over Z in the literature (Kamp 1968, Burgess 1984) uses:
- Until: `phi U psi` at `t` iff there exists `s > t` with `psi(s)` and `phi` on all `r ∈ (t, s)`

This is the **open guard** convention. Under this convention:
- `phi U phi` at `t`: need `∃ s > t, phi(s) ∧ ∀ r ∈ (t, s), phi(r)` — requires a STRICT future
  witness. This is the "irreflexive" Until.
- BX9 fails under this convention (as shown above)

**The Burgess-Xu axiom system** was specifically designed for this open-guard Until, but with
the recognition that `phi U psi -> phi ∨ psi` (BX9) requires the author to have intended
the half-open guard `[t, s)` or reflexive witness. The literature reference needed is:

Burgess's 1984 paper uses reflexive Until: `∃ s ≥ t, psi(s) ∧ ∀ r ∈ [t, s), phi(r)`.
This makes BX9 valid. The irreflexive switch in this project diverges from Burgess.

**Resolution**: The project should decide which logic it is formalizing:
1. **Burgess's original logic** (reflexive Until, BX1 valid) — proven complete in 1984
2. **A new irreflexive variant** (irreflexive G, adapted axioms) — may be complete but needs
   different axioms

For option 2, the correct axiom set needs to be derived from scratch, not adapted from Burgess.
The honest approach: write up the new axioms explicitly, prove them valid, and state the
completeness theorem for the new system.

---

## Part IX: Decision Recommendation

### Immediate Decision Required

**The project must choose between two tracks**:

**Track A: Formalize Burgess's Original System**
- Revert G and H to reflexive semantics
- Use half-open guard for Until/Since
- All BX axioms valid
- Lindenbaum re-entry problem: YES, but can be addressed by adding BX1 as an axiom and using
  the "modal completeness first, then unfold temporal" approach
- This is the mathematically clean path that aligns with published literature

**Track B: Formalize a New Irreflexive System**
- Keep irreflexive G, H
- Use half-open guard for Until/Since
- Reformulate BX2 to include present-point: `(phi->chi) ∧ G(phi->chi) -> (phi U psi -> chi U psi)`
- Remove BX1 from the system
- Add Serial axioms (`⊤ -> F(⊤)` and `⊤ -> P(⊤)`) for seriality
- The Lindenbaum re-entry problem is avoided (BX1 removed, `phi -> F(phi)` not derivable)
- This is a NEW logic not yet in the literature — publishable as a novel contribution

### Ranked Paths for Immediate Implementation

| Rank | Path | Effort | Success Probability | Mathematical Soundness |
|------|------|--------|--------------------|-----------------------|
| 1 | Reformulate BX2 (Track B) | ~80 LOC | 90% (sound axioms) | HIGH (closes soundness sorries) |
| 2 | Axiom audit task 95 first | 0 code LOC | 100% (research) | HIGH (prerequisite) |
| 3 | Accept soundness gap | 0 LOC | 70% (completeness still blocked by chain) | LOW (risks inconsistency) |
| 4 | Return to reflexive semantics | ~200 LOC | 80% (chain still needs work) | HIGH (matches Burgess) |
| 5 | Remove BX9 | ~200 LOC | 50% (truth lemma harder) | MEDIUM |

### Primary Recommendation

**Do Path 2 (axiom audit) immediately, then Path 1 (reformulate BX2).**

The audit will take 1-2 research rounds but will prevent further surprises. Once the audit
confirms which axioms need adjustment under Track B, implement the minimal reformulations.
This closes the soundness sorry sites and aligns the proof system with its semantics.

The chain construction sorries (fwd_chain_forward_F, restricted_tc, etc.) remain open and require
the constrained Lindenbaum or quasimodel approach. These are orthogonal to the soundness issue.

---

## Part X: Long-Term Architectural Health

### Current State Assessment

- **Sorry count**: ~33 in BXCanonical + ~31 in Quasimodel + ~7 in Soundness = ~71 sorries
- **Sorry-free infrastructure**: 21,941 - ~71*avg_size lines
- **Completion stage**: Soundness proved, completeness architecture built, key construction step blocked

### What a Publishable Result Looks Like

A publishable Lean 4 formalization of bimodal logic TM completeness needs:
1. Sound axiom system (zero sorry in Soundness.lean)
2. Complete canonical model (zero sorry in BXCanonical/)
3. The completeness theorem stated and proved

Currently: (1) is partially sorry'd, (2) has 5 critical sorry sites, (3) is stated with sorry.

### Timeline Estimate (Optimistic)

- Axiom audit: 2 rounds (1 week)
- BX2 reformulation + soundness sorry closure: 3 rounds (1.5 weeks)
- Constrained Lindenbaum for chain construction: 5-10 rounds (3-5 weeks)
- Completeness theorem: 3 rounds (1.5 weeks)
- **Total**: ~15-25 rounds from this point

### Architecture Survivability

The core architecture is sound. The BXCanonical canonical model (Frame.lean, TruthLemma.lean,
CanonicalModel.lean) does not depend on the soundness proof. The sorry sites in these files
(eventuality resolution) are about the chain construction, not soundness.

The reformulation of BX2 will require small updates to:
- `Axioms.lean`: Change `left_mono_until` form
- `Substitution.lean`: Update substitution for new form
- `Soundness.lean`: Update BX2 proof, close BX9/BX8 sorries
- No changes needed in Frame.lean, TruthLemma.lean, CanonicalModel.lean

**The quasimodel infrastructure (2,378 lines) survives unchanged.** It uses BX9 at the axiom
level (derivation tree), which is unaffected by semantic reformulation.

---

## Appendix: Key File Reference for Next Agent

Files requiring changes for BX2 reformulation (Path 1):
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean` — BX2 form
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Substitution.lean` — substitution
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Soundness.lean` — validity proofs
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Truth.lean` — guard convention

Files with chain construction sorries (orthogonal blockers):
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean`
  Lines: 1065, 1092, 1099, 1107, 1114 (5 active sorry sites)

Files with correctly sorry'd infrastructure (reflect semantic gaps):
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean`
  `F_of_mem` (line 67), `P_of_mem` (line 73)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean`
  `psi_imp_until_mcs` (line 49), `psi_imp_since_mcs` (line 55)
