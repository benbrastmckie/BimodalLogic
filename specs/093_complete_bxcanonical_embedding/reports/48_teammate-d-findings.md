# Teammate D (Horizons) Findings — Round 48
# How the IRR Rule Closes the BXCanonical Sorry Sites

**Task**: 93 - Complete BXCanonical embedding
**Date**: 2026-04-19
**Focus**: Concrete proof strategy for how IRR closes each sorry site

---

## Key Findings

### 1. The Sorry Sites: Exact Inventory

Reading the live code confirms five sorry sites on the active completeness path
(`dd_countermodel` in `RootScopedChain.lean`):

| # | Site | File | Line | Goal State |
|---|------|------|------|-----------|
| 1 | `fwd_chain_forward_F` | `RootScopedChain.lean` | 1111 | `∃ m, n < m ∧ φ ∈ (fwd_chain_of_sigma M₀ h₀ sigma_list m).val` |
| 2 | `dd_bfmcs_restricted_tc` backward | `RootScopedChain.lean` | 1138 | `∃ u < t, φ ∈ fam.mcs u` (from `P(φ) ∈ fam.mcs t`, `t - s < 0`) |
| 3 | `dd_bfmcs_restricted_tc` backward-P | `RootScopedChain.lean` | 1145 | `∃ u < t, φ ∈ fam.mcs u` (from `P(φ) ∈ fam.mcs t`) |
| 4 | `dd_bfmcs_restricted_buc` | `RootScopedChain.lean` | 1153 | Full backward Until/Since coherence goal |
| 5 | `dd_bfmcs_restricted_fuc` | `RootScopedChain.lean` | 1160 | Full forward Until/Since coherence goal |

Additionally there are sorry sites in the quasimodel subsystem
(`OracleStep.lean`, lines 272, 341, 348, 367, 386, 393, 397, 452), but these
are NOT on the active `dd_countermodel` completeness path.

### 2. The IRR Rule Infrastructure: What Exists

**ExtFormula.lean**: `ExtAtom := String ⊕ Unit`. The fresh atom is
`freshAtom := Sum.inr ()`. It does not appear in any `embedFormula φ` for any
base `φ : Formula` (proved in `fresh_not_in_embedFormula_atoms`).

**ExtDerivation.lean**: `ExtDerivationTree` has constructors for all base rules
(axiom, assumption, modus_ponens, necessitation, temporal_necessitation,
temporal_duality, weakening) but **NO IRR constructor**. The file also contains
`embedDerivation` which lifts base derivations to extended derivations.

**Substitution.lean**: Defines `substFormula : ExtFormula → ExtFormula` replacing
`Sum.inr ()` with `⊥`. Proves axiom closure, idempotence, and q-free fixed points.

**Lifting.lean**: Defines `substFreshWith s : ExtFormula → ExtFormula` replacing
`Sum.inr ()` with `Sum.inl s`. Defines `liftFormula s = unembedFormula ∘ substFreshWith s`.
The main theorem `lift_derivation_qfree` proves: if `ExtDerivationTree (L.map embedFormula) (embedFormula φ)` then `Nonempty (DerivationTree L φ)`.

**Critical observation**: The `ExtDerivationTree` type has NO IRR constructor. The
infrastructure is entirely about lifting (conservative extension from F to F+). The
IRR rule mechanism in the literature (GHR 1994) is a meta-rule for *building* chains,
not a constructor in the proof system. The current infrastructure does NOT implement
IRR as a proof-theoretic rule; it implements lifting from extended to base derivations.

### 3. Category A (Sorry Site #1): fwd_chain_forward_F

**The goal**: Given `F(φ) ∈ fwd_chain_of_sigma M₀ h₀ sigma_list n`, find `m > n` with
`φ ∈ fwd_chain_of_sigma M₀ h₀ sigma_list m`.

**What the code has**: The `preserving_fwd_step` (defined at ~line 551) satisfies:
- When `active_defects M sigma_list ≠ []`, it calls `defect_step_choice_early`
  which uses `resolving_enriched_fwd_exists` (the BX11 fold). This resolves **at
  least one** defect and preserves ALL F-obligations for all other sigma_list formulas.
- `fwd_chain_F_persistent` (proved, no sorry) shows F-obligations persist.

**The gap**: The sorry comment says "Termination argument requires well-founded induction
on defect count or a pigeonhole argument." The code has all the pieces but no termination
proof.

**How IRR closes this**: Under **irreflexive semantics** (GHR 1994 approach):

1. Add fresh atom `p : ExtAtom` (i.e., `freshAtom = Sum.inr ()`).
2. The IRR rule (as a meta-rule, not a constructor): if `Γ, p ∧ H(¬p) ⊢ φ` and
   `p` fresh to `Γ` and `φ`, then `Γ ⊢ φ`. This is temporal induction: "if φ holds
   whenever something is happening for the first time, then φ holds absolutely."
3. For sorry site #1, the IRR argument is: mark the "first step" with `p`. At step
   `n` where `F(φ) ∈ chain(n)`, label it as the initial step by having `p ∈ chain(n)`
   and `H(¬p) ∈ chain(n)`. By IRR temporal induction, this yields a well-founded
   induction principle: the finite sigma_list has finitely many defects, and each step
   of the chain resolves at least one without reintroducing it (because under irreflexive
   semantics, `φ → F(φ)` is NOT valid, so resolved formulas do not re-enter as
   F-obligations). Therefore, φ must be resolved in at most `|sigma_list|` steps.

**Concrete proof sketch** (without IRR, using finite defect count):

Actually, under the **current** reflexive semantics, the termination is blocked by
`phi_in_mcs_imp_F_phi` — resolved defects can re-enter as F-obligations because
`φ → F(φ)` is derivable. This is the fundamental obstruction.

Under **irreflexive semantics** (BX1 removed, `G(φ) → φ` gone):
- `φ → F(φ)` is NOT derivable (no `G(¬φ) → ¬φ` to contrapose).
- So once `φ ∈ chain(n)`, we do NOT get `F(φ) ∈ chain(n)` automatically.
- The `active_defects` list at chain(n) genuinely DECREASES after step n resolves φ.
- Since `sigma_list` is finite, after at most `|sigma_list|` steps all F-defects are resolved.
- This is the standard pigeonhole argument: `|sigma_list|` steps suffice.

**IRR rule's role**: In the GHR 1994 proof, IRR is used to show that the canonical
model satisfies Until without building the chain via Lindenbaum. For sorry site #1, the
key insight is NOT IRR directly but rather the **absence of `φ → F(φ)`** under irreflexive
semantics, which makes defect counts strictly decrease. IRR enables the axiomatic proof
system to reason about "first occurrences," but the chain construction uses the
well-founded defect argument.

**Proof obligation for sorry #1** (under irreflexive semantics):
```lean
-- sigma_list has n elements. F(φ) ∈ chain(0). After ≤ n+1 steps:
-- At each step, |active_defects chain(k)| ≤ |active_defects chain(k-1)| - 1
-- (because at least one defect resolves and resolved defects don't re-enter)
-- By induction, eventually active_defects = [] or φ ∈ chain(k).
-- Strong induction on |sigma_list| - |active_defects chain(n)|.
```

The key lemma needed: under irreflexive semantics, if `φ ∈ M'` is in the successor
MCS, then `F(φ) ∉ M'` is not forced by `φ ∈ M'` alone. This requires the absence
of `temp_t_future` (BX1).

### 4. Category B (Sorry Sites #2-3): Backward Chain

**The goal**: Given `P(φ) ∈ fam.mcs t`, find `u < t` with `φ ∈ fam.mcs u`.

**What exists**: `bwd_chain_of_sigma` is defined (line ~598) using `bwd_pred` at each
step. `bwd_pred` uses `past_temporal_witness_seed_consistent` when `P(ψ) ∈ M`. The
chain structure is symmetric to `fwd_chain_of_sigma`.

**The gap**: There is NO `preserving_bwd_step` equivalent. The sorry comments at lines
1137-1138 and 1143-1145 say "a different argument" / "symmetric argument" / "symmetric
preserving_bwd_step is needed."

**How IRR closes this**: The IRR rule has a temporal direction — it uses `H(¬p)` (past
operator). Its symmetric version uses `G(¬p) ∧ p` for "last occurrence." Under
irreflexive semantics, the symmetric argument is:

1. Build `preserving_bwd_step` symmetric to `preserving_fwd_step`:
   - Compute `active_past_defects M sigma_list` = formulas `χ` in sigma_list with
     `P(χ) ∈ M`.
   - When non-empty, call an analog of `defect_step_choice_early` for the past direction.
   - The analog requires: if `P(χ) ∈ M`, build predecessor `M'` with `χ ∈ M'` and
     `h_content(M) ⊆ M'`, AND all P-obligations preserved for sigma_list formulas.

2. For P-obligation preservation under irreflexive semantics: `χ → P(χ)` is NOT
   derivable (symmetric to `φ → F(φ)` under reflexive). So resolved past-defects
   do not re-enter.

3. Build `bwd_chain_of_sigma` using this `preserving_bwd_step`.

4. Prove `bwd_chain_backward_P` symmetric to `fwd_chain_forward_F`:
   if `P(φ) ∈ bwd_chain(n)`, then `∃ m > n, φ ∈ bwd_chain(m)`.

**The backward IRR rule** (meta-level): `G(¬p) ∧ p → φ` gives temporal coinduction
for past. Under irreflexive semantics, `G(¬p) ∧ p` means "p holds now but never in
the future" — a unique "last point" marker.

**Key infrastructure needed for sorry #2-3**:
- A `bx11_earlier_past` ordering (BX11' on P-defects via linearity)
- An analog of `enriched_resolving_bwd_exists` preserving all P-obligations
- `bwd_chain_backward_P` analogue of `fwd_chain_forward_F` (sorry #1)

This is engineering work, not a mathematical obstruction, once the axiom system is
adjusted for irreflexive semantics.

### 5. Category C (Sorry Sites #4-5): Until/Since Step Transfer

**The goal for sorry #4** (`dd_bfmcs_restricted_buc`): "Backward Until/Since coherence."
Under the BFMCS coherence definitions in `UntilSinceCoherence.lean`, this requires
showing that if `φ U ψ ∈ fam.mcs(r+1)` and `φ ∈ fam.mcs(r)`, then `φ U ψ ∈ fam.mcs(r)`.

**The goal for sorry #5** (`dd_bfmcs_restricted_fuc`): "Forward Until/Since coherence."
Depends on `restricted_tc` and Until propagation.

**How IRR closes this under strict Until**:

Under **strict Until** (report 47, B's finding), `(φ U ψ)` means "ψ holds at some
strictly future time s > t, and φ holds on the open interval (t, s)."

Step transfer (the key lemma for backward BUC):
- Given `(φ U ψ) ∈ fam.mcs(r+1)`: by semantics, ∃ s > r+1 with ψ at s, φ on (r+1, s).
- Given `φ ∈ fam.mcs(r)`: φ holds at r.
- Claim: `(φ U ψ) ∈ fam.mcs(r)`.
- The same s works: s > r+1 > r, and the interval (r, s) = {r} ∪ (r+1, s).
- φ holds on {r} (given) and φ holds on (r+1, s) (from the hypothesis).
- So φ holds on (r, s), and ψ holds at s. Hence `(φ U ψ) ∈ fam.mcs(r)` semantically.

Under **reflexive Until** (current semantics), s ≥ r+1, but we need s ≥ r for the
extended interval. When s = r+1, the interval (r, r+1) = {r} works trivially. BUT
the problem is at the proof-theoretic level: we need to derive `φ U ψ ∈ fam.mcs(r)`
from `φ U ψ ∈ fam.mcs(r+1)` and `φ ∈ fam.mcs(r)`. The missing axiom is
`φ ∧ G(φ U ψ) → φ U ψ` (Until induction). This axiom is VALID under strict Until
but NOT provable from the current BX axioms under reflexive Until.

Under **strict Until**, the step transfer becomes an axiom (or is derivable from
the Until unfolding axiom): `φ ∧ F(φ U ψ) → φ U ψ` (if ψ will happen and φ holds
now, then φ U ψ holds now). This is provable because under strict Until:
- `F(φ U ψ)` means ∃ s > t with `(φ U ψ) at s`, i.e., ∃ u > s > t with ψ at u, φ on (s, u).
- If φ holds at t: the interval (t, u) = {t, ..., s} ∪ (s, u). Need φ on (t, u).
- But φ holds at t and we only know φ U ψ ∈ fam(s), not φ on (t, s).

Actually, the correct formulation for strict Until step transfer is:
Given `φ U ψ ∈ fam(r+1)` and `φ ∈ fam(r)`:
- `φ U ψ ∈ fam(r+1)` means ∃ s > r+1, ψ(s), φ on (r+1, s).
- φ at r plus φ on (r+1, s) gives φ on (r, s) = {r} ∪ (r+1, s).
- s > r+1 > r, so s > r. Hence `φ U ψ ∈ fam(r)`.

This argument is purely semantic. The proof-theoretic version requires the axiom:
`φ ∧ (φ U ψ)_at_next → φ U ψ` where `(φ U ψ)_at_next` is captured by
`G(φ U ψ) → φ U ψ_step` or by the FMCS ordering. Under the BFMCS framework,
`restricted_buc` requires the MCS-level step transfer:

```lean
-- If φ U ψ ∈ fam.mcs(r+1) and φ ∈ fam.mcs(r), then φ U ψ ∈ fam.mcs(r).
```

Under strict Until, the relevant BX axiom would be something like:
`(φ ∧ F(φ U ψ)) → φ U ψ`

Because if `φ U ψ ∈ fam(r+1)`, then by F-propagation, `F(φ U ψ) ∈ fam(r)`.
Combined with `φ ∈ fam(r)`, the new strict-Until axiom gives `φ U ψ ∈ fam(r)`.

**Concrete axiom needed**: `φ ∧ F(φ U ψ) → φ U ψ` (strict Until induction, "step back").
This is NOT a current BX axiom. It would need to be added as part of the strict-Until
axiom system revision.

Alternatively, `G(φ U ψ) → φ U ψ` (the T-axiom for Until) is provable under
reflexive Until but FALSE under strict Until. Instead, the correct step transfer under
strict Until uses:
`φ U ψ ∈ fam(r+1) ∧ φ ∈ fam(r) → φ U ψ ∈ fam(r)` by SEMANTIC argument (not axiom),
which can be turned into an MCS-level proof if the BFMCS chain is the canonical model
with the correct semantic clauses.

### 6. The GHR 1994 Chain Construction Under Irreflexive Semantics

The GHR 1994 approach does not use independent Lindenbaum extensions (which is the
current `dd_chain` architecture). Instead, it uses:

1. **Fresh atom p**: `p : ExtAtom = freshAtom = Sum.inr ()`.
2. **IRR derivation**: If `Γ ∪ {p ∧ H(¬p)} ⊢ φ` and `p` fresh, then `Γ ⊢ φ`.
   This simulates "if φ holds at any starting point, then φ holds."
3. **Chain construction**: Build a model of `{¬φ}` as follows:
   - Extend `{¬φ}` to an MCS `M₀` with `¬φ ∈ M₀`.
   - For the Int-indexed chain, at each negative position t < 0, use `{p ∧ H(¬p)} ∪ M_t`
     to mark position t as the "beginning."
   - The IRR rule guarantees that any formula provable with the "beginning" assumption
     is provable absolutely, so the canonical model with these marked points is
     coherent (all formulas that hold "beginning" also hold at arbitrary positions).

4. **Relation to current dd_chain**: The `dd_chain` is built via iterated Lindenbaum
   extensions (`fwd_chain_of_sigma`, `bwd_chain_of_sigma`). The IRR approach is
   different: instead of building a chain by extending, one proves the chain is
   coherent using the IRR meta-rule. The key difference:
   - dd_chain: semantic — build the chain step by step, prove coherence per step.
   - GHR/IRR: proof-theoretic — use IRR to derive temporal induction in the logic,
     then apply it to prove the canonical model satisfies Until.

5. **Under irreflexive semantics without IRR**: The `dd_chain` approach still works
   structurally (Lindenbaum extensions, g_content propagation). What changes is:
   - `φ → F(φ)` is NOT derivable (no BX1), so defect counts strictly decrease.
   - Until step transfer is directly provable (strict Until semantics).
   - The `restricted_tc` backward case requires `preserving_bwd_step`.

### 7. Strategic Assessment: IRR vs. Structural Fix

Two distinct paths exist under irreflexive semantics:

**Path A (GHR/IRR meta-rule)**: Add IRR constructor to `ExtDerivationTree`, prove
IRR soundness under strict semantics, then use IRR to derive the sorry closures as
theorems in the extended proof system, then project back via `lift_derivation_qfree`.

- Sorry #1: Use IRR temporal induction to derive `∃ m, F(φ) ∈ chain(n) → φ ∈ chain(m)`.
  The IRR argument: "Suppose F(φ) holds everywhere. Introduce fresh p to mark the
  'first time' F(φ) is present. Then p ∧ H(¬p) → eventually φ (since the chain is
  non-repeating under irreflexive semantics). By IRR, this holds without the p."
- This is a proof-theoretic argument, not a semantic one.
- It requires the IRR constructor and soundness proof.
- It works but is INDIRECT (goes through F+ → F conservatism).

**Path B (Direct semantic fix)**: Under irreflexive semantics, prove the termination
argument directly without IRR:
- Sorry #1: Prove that `|active_defects chain(n)|` strictly decreases, using the
  absence of `φ → F(φ)` under irreflexive semantics.
- Sorries #2-3: Build `preserving_bwd_step` and prove the backward analog.
- Sorries #4-5: Use strict Until step transfer axiom.

Path B is more direct and does NOT require the IRR rule at all. It requires:
1. Remove `temp_t_future` and `temp_t_past` from `ExtAxiom`/`Axiom`.
2. Add strict Until/Since unfolding axioms.
3. Prove `∀ M MCS, φ ∈ M → φ.some_future ∉ M` (or at least not forced) — actually
   this is not provable as a universal statement; what's needed is:
   `∀ M MCS, (∀ n, φ ∈ chain(n) → F(φ) ∈ chain(n))` is blocked under irreflexive.

Actually, the key for Path B, sorry #1 is:
Under irreflexive semantics, `preserving_fwd_step` resolves at least one defect per
step. If we can show that resolved defects STAY resolved (don't re-enter), then the
defect count strictly decreases, giving termination in `|sigma_list|` steps.

Resolved defects stay resolved iff: `φ ∈ M' → φ ∉ active_defects M' sigma_list` is
maintained. The `active_defects` criterion is `F(φ) ∈ M'`, not `φ ∈ M'`. Under
reflexive semantics, `φ ∈ M' → F(φ) ∈ M'` (from `φ → F(φ)`). Under irreflexive
semantics, this implication fails — resolving `φ` doesn't force `F(φ)`.

**BUT**: There's a subtlety. When `φ ∈ M'` (defect resolved), we also have
`φ → P(φ)` is NOT derivable under irreflexive semantics either. But `φ ∈ M'`
says φ holds at the CURRENT step. Whether `F(φ) ∈ M'` depends on the future, which
is determined by subsequent Lindenbaum extensions. The new `M''` (successor of `M'`)
can INDEPENDENTLY have `F(φ) ∈ M''` (if some further successor contains φ), re-entering
φ as an active defect. This problem remains under irreflexive semantics.

**This is the real obstruction**: The defect count argument fails even under
irreflexive semantics because future Lindenbaum extensions are independent of past
ones — the chain is "non-deterministic" in the sense that the oracle at step k doesn't
know what the oracle at step k+2 will decide. `F(φ)` depends on future decisions.

**Conclusion**: IRR (as a meta-rule) is needed to make the argument go through,
because IRR provides a "global" well-foundedness guarantee: "any formula φ that holds
whenever a starting point is introduced, holds absolutely." This breaks the
non-deterministic oracle cycle.

### 8. The IRR Constructor: What's Missing

To use IRR proof-theoretically (Path A), we need to add to `ExtDerivationTree`:

```lean
| irr (φ : ExtFormula) (p : ExtAtom)
    (h_fresh_ctx : p ∉ (... atoms ...))
    (h_fresh_concl : p ∉ φ.atoms)
    (d : ExtDerivationTree [ExtFormula.atom p |>.and (ExtFormula.atom p |>.neg.all_past)] φ) :
    ExtDerivationTree [] φ
```

The IRR rule: from `{p ∧ H(¬p)} ⊢ φ` (with p fresh to φ), derive `⊢ φ`.

Under irreflexive semantics, `H(¬p) ∧ p` is satisfiable — it means "p holds now but
never in the strictly past." This makes IRR sound: any point can be treated as "the
first time p holds" in a model, and if φ holds at all such points, φ holds at all points.

The soundness proof would go in a new `IRRSoundness.lean`:
```
Theorem: If ExtDerivationTree [{p ∧ H_strict(¬p)}] φ (with p fresh)
         then ∀ strict models M, ∀ worlds w: M, w ⊨ φ.
Proof: For any world w in any model M, set p := {w} (the singleton).
       Then p ∧ H_strict(¬p) holds at w (p holds at w by definition,
       H_strict(¬p) holds since for all past times t < w, t ≠ w so p doesn't hold there).
       By d: φ holds at w. Since w was arbitrary, ⊢_strict φ.
```

### 9. Summary: Sorry Site Closure Map

| Sorry Site | Root Cause | Closure Method Under Irreflexive | Needs IRR? |
|------------|------------|----------------------------------|------------|
| #1 `fwd_chain_forward_F` | F-defects re-enter under reflexive semantics | IRR well-founded induction gives global termination | YES (for global argument) |
| #2 `restricted_tc` backward (t-s < 0) | No `preserving_bwd_step` | Build symmetric backward chain infrastructure | NO (engineering) |
| #3 `restricted_tc` backward-P | Same as #2 | Same as #2 | NO |
| #4 `restricted_buc` | Until step transfer axiom missing | Strict Until step transfer (semantic + new axiom) | NO |
| #5 `restricted_fuc` | Depends on restricted_tc + Until propagation | Follows from #1-4 once closed | NO |

**Only sorry #1 requires IRR** (in the strong sense). Sorries #2-3 are engineering.
Sorries #4-5 require the strict Until axiom system.

### 10. The Real Geometry: Why dd_chain Needs IRR

The `fwd_chain_of_sigma` is an infinite chain built by iterated Lindenbaum extensions.
The sorry #1 asks: if `F(φ) ∈ chain(n)`, does `φ ∈ chain(m)` for some `m > n`?

Under the CURRENT architecture: The chain at position k makes LOCAL decisions about
which defects to resolve. A formula φ might be scheduled for resolution at step k,
but after resolution, the next chain step might independently get `G(¬φ) ∉ chain(k+1)`
from Lindenbaum, giving `F(φ) ∈ chain(k+1)`, re-entering φ as a defect. This is the
"oracle opacity" problem.

Under irreflexive semantics + IRR:
- The IRR rule says: treat position k as "the beginning" (p ∧ H(¬p) holds at k).
- At this marked beginning, we can derive temporal induction: if φ must hold at ANY
  beginning, then φ holds everywhere (by IRR, projecting away the marking).
- The chain starting at k with φ as the defect is a "beginning-marked" chain.
- By the IRR-based temporal induction, φ MUST eventually appear in any chain that
  starts with F(φ), because "this is the first time F(φ) holds" and temporal
  induction ensures F-eventualities are resolved.

This is the GHR 1994 argument in essence: IRR provides the induction principle that
makes "eventually" into "within finite steps from any marked beginning."

---

## Recommended Approach

Based on this analysis, the recommended approach for each sorry site is:

### Sorry #1 (F-eventuality): Use Defect Count Under Irreflexive + Induction Bound

Rather than the full GHR IRR machinery, a simpler induction on the defect count works
UNDER IRREFLEXIVE SEMANTICS because:

1. At step n with `F(φ) ∈ chain(n)`, φ ∈ sigma_list is a defect.
2. `preserving_fwd_step` at step n resolves ≥1 defect (by `defect_step_early`).
3. Under irreflexive semantics, a resolved φ does NOT generate `F(φ)` in the
   successor (no `φ → F(φ)` derivable from axioms).
4. HOWEVER: `F(φ)` can still appear in the successor via independent Lindenbaum
   extension if some later position will have φ.

The correct argument requires showing that the sigma_list defects eventually all
resolve. With a FINITE sigma_list and a SCHEDULING scheme that targets each formula
infinitely often (the current round-robin `n % sigma_list.length`), after enough
steps every formula gets a chance to be resolved. But "resolve once" doesn't prevent
re-entry.

**The pivotal question**: Can `F(φ) ∈ chain(n)` with `φ ∈ chain(n+1)` give
`F(φ) ∈ chain(n+2)` under irreflexive semantics?

Under irreflexive semantics: `F_strict(φ)` means ∃ s > t with φ at s. If `φ ∈ chain(n+1)`,
then `F_strict(φ) ∈ chain(n)` by `F_from_witness`. But whether `F_strict(φ) ∈ chain(n+2)`
depends on whether there exists s > n+2 with φ at s. Once `φ ∈ chain(n+1)`, the
future Lindenbaum extensions might independently not have φ — meaning `F_strict(φ) ∉ chain(n+2)`.

Under reflexive semantics: `F_refl(φ)` includes s = t, so `φ ∈ chain(n+1)` directly
gives `F_refl(φ) ∈ chain(n+1)` via `φ → F(φ)`. The defect re-enters trivially.

**Conclusion for sorry #1**: Under irreflexive semantics, once φ is resolved, the
system does NOT automatically generate `F(φ)` in the next step. The defect count
argument becomes: there exists a step m where all defects are either resolved or have
NO future occurrence. This is provable by finite induction on sigma_list size + the
fact that the chain is "omega-saturating" (each formula in sigma_list is targeted
infinitely often by the round-robin schedule). This avoids the full IRR machinery.

### Sorry Sites #2-3: Build Symmetric Backward Infrastructure

Build `preserving_bwd_step` using:
- `active_past_defects M sigma_list` = `sigma_list.filter (P(χ) ∈ M)`
- `defect_step_choice_past` using BX11' (since-linearity) instead of BX11
- `bwd_chain_backward_P` using finite induction

### Sorry Sites #4-5: Add Strict Until Step-Transfer Axiom

Add new BX axiom (in Axioms.lean): `φ ∧ F(φ U ψ) → φ U ψ` ("step-back Until").
Under strict Until semantics, this is valid and closes sorry #4 directly.
Sorry #5 follows from #4 by the BFMCS coherence chain.

---

## Evidence/Examples

**Evidence for sorry #1 being F-reentry dependent**:
- `RootScopedChain.lean` line ~468: `phi_imp_F_phi_early` is USED inside `defect_step_early`
  to prove F-preservation (line 524-529). This shows the code knows `φ → F(φ)`.
- Under irreflexive semantics, lines 524-529 would be invalid (can't conclude `F(χ) ∈ M'`
  from `χ ∈ M'`). This is actually a BLOCKER for the CURRENT chain structure itself,
  not just for sorry #1.

**Evidence for sorry #4-5 being step-transfer dependent**:
- `RootScopedChain.lean` line 1151-1153: sorry comment explicitly says "step transfer
  property which is blocked for Lindenbaum-based chains under reflexive semantics."
- Under strict Until, the semantic argument (Section 5 above) shows it's directly provable.

**Evidence for IRR infrastructure incompleteness**:
- `ExtDerivationTree` (ExtDerivation.lean) has 7 constructors, none named `irr`.
- The `ConservativeExtension/README.md` does not mention IRR.
- The `Lifting.lean` implements lifting (F+ → F), not IRR introduction.

---

## Confidence Level

| Finding | Confidence |
|---------|-----------|
| Sorry site inventory (5 live, 8 quasimodel/dead) | HIGH (95%) |
| IRR constructor missing from ExtDerivationTree | HIGH (100%) |
| Sorry #1 requires F-reentry fix under irreflexive | HIGH (85%) |
| Sorries #2-3 are symmetric engineering | HIGH (90%) |
| Sorries #4-5 require strict Until step-transfer axiom | HIGH (85%) |
| IRR needed for global termination of sorry #1 | MEDIUM (60%) — alternative is finite sigma induction |
| defect_step_early uses φ → F(φ) (line 524-529), which fails under irreflexive | HIGH (95%) |
| Overall: irreflexive semantics + strict Until axiom closes sorries #4-5 directly | HIGH (80%) |
| Overall: sorry #1 closable under irreflexive with finite induction (no IRR needed) | MEDIUM (65%) |

---

## Critical Unexpected Finding

**`defect_step_early` internally uses `phi_in_mcs_imp_F_phi_early`** (which derives
from `φ → F(φ)`). This means under irreflexive semantics (where `φ → F(φ)` fails),
the ENTIRE `preserving_fwd_step` construction is INVALID — not just sorry #1, but the
fundamental chain construction breaks. Lines 524-529 of `RootScopedChain.lean`:

```lean
· exact phi_in_mcs_imp_F_phi_early h_mcs' χ h
```

This line says: "if χ ∈ M' (resolved directly), then F(χ) ∈ M' (still F-preserved)."
Under irreflexive semantics, this fails. The entire `defect_step_early` function needs
to be redesigned for irreflexive semantics — it can no longer conclude that directly-resolved
defects remain F-preserved.

**The redesign**: Under irreflexive semantics, the F-preservation is WEAKER:
- Resolved defects (χ ∈ M') do NOT get F(χ) ∈ M'.
- Unresolved defects (χ ∉ M') DO get F(χ) ∈ M' (if scheduled).
- The chain construction becomes: each step resolves some defects AND carries forward
  F-obligations only for the REMAINING unresolved defects.

This is actually a SIMPLIFICATION: the `defect_step_early` function no longer needs
to preserve F for already-resolved formulas. The active_defects list naturally shrinks.
