# Teammate D (HORIZONS): Strategic Analysis
## Task 109 — Close chain construction sorries

**Date**: 2026-04-20
**Role**: Horizons and strategic direction
**Session**: sess_1776729500_24d339

---

## Key Findings

- **The current chain construction is architecturally sound**, but the termination argument
  has a critical definitional flaw: `active_defects` is defined as `{chi | F(chi) in M}`
  (line 470-472), not `{chi | F(chi) in M AND chi not_in M}`. This incorrect definition
  is why the active defect count does not decrease under the current code.

- **Under irreflexive semantics, the mathematically correct argument is:**
  1. Define true active defects as `{chi in sigma_list | F(chi) in M AND chi not_in M}`
  2. At each step with active defects, `defect_step_choice_early` resolves at least one:
     some `w` with `F(w) in M` becomes `w in M'`
  3. Under irreflexive semantics, `w in M'` does NOT force `F(w) in M'` (because
     `chi -> F(chi)` is not derivable without BX1/reflexivity)
  4. Therefore `w` exits the true active defect set
  5. New true active defects can only come from sigma_list (finite), but their entry
     requires `F(chi) in M'`, which requires `chi not_in M'` (else not active)
  6. The key question: can new true-active defects appear strictly faster than old ones are resolved?

- **The regeneration bound question** is the remaining gap. The team research correctly
  identified this. My analysis suggests the answer is NO for a well-chosen chain design:
  a defect chi that newly appears as active at step k requires `F(chi) in chain(k)`, which
  by `fwd_chain_F_obligation_monotone` means `F(chi) in chain(0) = M₀`. So only
  formulas with F-obligation AT THE INITIAL MCS can ever become active. This gives a
  uniform bound: total true-active defects over all time ≤ |sigma_list|.

- **The finite state space argument closes the termination gap**: Let S = `{chi in sigma_list |
  F(chi) in M₀}` (formulas with F-obligation at the initial MCS). By
  `fwd_chain_F_set_nonincreasing`, once F(chi) leaves the chain, it never returns. So S
  is non-increasing and each chi can be "active" at most once in any continuous active period.
  Total resolution events ≤ |S| ≤ |sigma_list|. After at most |S| steps, all active defects
  must have been resolved.

---

## Literature Survey

### Standard Completeness Proofs for Temporal Logics

#### Burgess 1984: "Basic Tense Logic" (Handbook of Philosophical Logic)

The original completeness proof for linear tense logic with Since/Until uses a different
architecture than what we have. Burgess does NOT build a single infinite chain with
round-robin scheduling. Instead, he uses a **saturated model** approach:

1. Define a set of all maximal consistent theories (the canonical frame)
2. Show the frame is a linear order (using the linearity axioms)
3. The chain IS the whole canonical frame, ordered by the bx_le relation
4. Eventuality resolution follows from the well-foundedness of bx_le

The key structural point: in Burgess's proof, the "chain" is not constructed step-by-step
with a preserving forward step. It is the entire canonical frame, and the eventuality
resolution proof is a MODEL-THEORETIC argument (by contradiction: if F(phi) is true at
w but phi is never true, derive a contradiction using the well-ordering of the canonical
frame under the tense axioms).

**Lesson for our proof**: Burgess avoids the "Lindenbaum step" problem entirely because
his chain already exists (it's the whole canonical frame). The eventuality argument is
purely semantic at the level of the model. We cannot directly copy this approach because
we need an INT-indexed FMCS/BFMCS for the parametric representation theorem.

#### BdRV 2001 (Blackburn, de Rijke, Venema): Modal Logic, Ch. 7

BdRV use a **filtration** approach for temporal logics. The key technique:

1. Build the standard canonical model (all MCS sets)
2. Apply a FILTRATION to reduce it to a finite model (using the finite subformula closure)
3. In the filtrated model, the Until/Since eventualities are discharged by the FILTRATION
   map, which sends each defective world to its nearest "true witness" in the original model

The BdRV approach does NOT use a round-robin chain at all. It uses the finite model
property argument. This is closest to what we already have in the Quasimodel infrastructure.

**Lesson**: The quasimodel/filtration approach (already implemented in our Quasimodel/
directory) is the standard literature approach. The question is how to wire it into the
INT-indexed BFMCS structure.

#### Goldblatt 1992: "Logics of Time and Computation"

Goldblatt's approach to completeness for temporal logics with Until uses a **step-by-step
model construction** (sometimes called a "canonical run"):

1. Start with an MCS M₀ containing ¬φ
2. At each step, if F(ψ) ∈ current MCS, choose an extension that satisfies ψ
3. **Critically**: Goldblatt uses an EXPLICIT ENUMERATION of all eventualities and handles
   them in FIXED ORDER — not round-robin, but priority-queue style

The Goldblatt construction is the closest to our current architecture. His termination
argument: at step n, handle the eventuality with the LOWEST INDEX in the enumeration
that is still active. Because each handled eventuality never re-enters (under his semantics,
which are also irreflexive), the total work is bounded by the size of the formula.

**KEY INSIGHT FROM GOLDBLATT**: Goldblatt's proof works because his semantics are
irreflexive AND because he uses a FIXED PRIORITY ORDER (by index), not round-robin. At
each step, the LOWEST-INDEX active eventuality is resolved. This corresponds exactly to
our `bx11_earlier` infrastructure — the BX11 ordering IS a priority ordering on eventualities.

#### GHR 1994 (Gabbay, Hodkinson, Reynolds): "Temporal Logic: Mathematical Foundations"

GHR gives the most detailed account. Their completeness proof uses **"eventuality
satisfaction sequences"** — a constructive approach where:

1. Enumerate all eventualities in the subformula closure as e₁, e₂, ..., eₖ
2. Build an infinite chain where each eᵢ is satisfied in turn (round-robin OR
   priority-first, depending on the version)
3. **The key termination lemma**: once eᵢ is satisfied (eᵢ holds at some point),
   it is "permanently discharged" and never needs to be scheduled again

The "permanent discharge" property is what we call `fwd_chain_F_obligation_monotone`:
once F(chi) leaves the chain (because chi has been satisfied), G(¬chi) enters and chi
can never become active again.

GHR also explicitly discusses the "regeneration" issue: can a newly satisfied eventuality
create new unsatisfied eventualities? Their answer: YES, but only from the subformula closure
(finite), and since each eventuality can only be scheduled finitely many times before
becoming permanently discharged, the total work is bounded.

---

## Unconventional Approaches

### Approach 1: True Active Defect Definition Fix (RECOMMENDED — Path A refinement)

The current `active_defects` definition at line 470-472 is:
```lean
sigma_list.filter (fun χ => decide (Formula.some_future χ ∈ M))
```

This is `{chi in sigma_list | F(chi) in M}` — it does NOT exclude `chi in M`. The
correct definition for a termination argument is:
```lean
sigma_list.filter (fun χ => decide (Formula.some_future χ ∈ M) && decide (χ ∉ M))
```

This is `{chi in sigma_list | F(chi) in M AND chi not_in M}`. Under this corrected
definition:
- When chi is resolved (chi in M'), it exits the true active defect set
- By `fwd_chain_F_obligation_monotone`, once F(chi) leaves, it never returns
- So each chi can be in the true active defect set for at most a finite "window"
- The argument: at each step, at least one chi exits (resolved), and new entries are
  bounded by |S| = |{chi in sigma_list | F(chi) in M₀}| which is finite

**However**, this approach requires careful case analysis on whether newly active defects
can appear. See the "Regeneration Bound" discussion below.

### Approach 2: Defect Index Decrease via fwd_chain_F_set_nonincreasing

A cleaner argument avoids redefining `active_defects` entirely. Instead, track the
SET `F_set(n) = {chi in sigma_list | F(chi) in chain(n)}`. By
`fwd_chain_F_set_nonincreasing`, this set is non-increasing. By `defect_step_choice_early`,
at each step with F_set(n) ≠ ∅, some chi in F_set(n) satisfies chi in chain(n+1). Since
`chi -> F(chi)` is not derivable under irreflexive semantics, chi in chain(n+1) does NOT
imply F(chi) in chain(n+1), so chi MAY exit F_set(n+1). This MAY not happen (Lindenbaum
could add F(chi) independently), which is the regeneration gap.

**Key question**: Is there a chain design where F(chi) does NOT re-enter for resolved chi?

### Approach 3: G(¬w) Seeding (Approach A from handoff)

Modify `preserving_fwd_step` to include `G(¬w)` in the seed for the resolved witness w.
This forces `F(w) not_in chain(k+1)` because `G(¬w) in chain(k+1)` and `F(w) ∧ G(¬w)`
is inconsistent.

**Consistency check**: The seed would be `{w, G(¬w)} ∪ g_content(M)`. Is this consistent?
- `w ∧ G(¬w)`: under irreflexive semantics, "w now AND G(¬w)" means w holds now and ¬w
  holds at all STRICTLY FUTURE times. This is semantically consistent (w can be true now
  but false later).
- `g_content(M)` contains all formulas `G(α)` for `G(α) ∈ M`. If `G(¬w) ∈ g_content(M)`,
  then `G(¬w) ∈ M`, which means `F(w) = ¬G(¬w) ∉ M`, contradicting `F(w) ∈ M`. So
  `G(¬w) ∉ g_content(M)`.
- Is `{w, G(¬w)} ∪ g_content(M)` consistent? We need: no finite derivation of ⊥ from
  this set. The concern is `G(α) ∈ g_content(M)` combined with `G(¬w)` implying
  inconsistency. But `G(¬w)` only constrains future w; it doesn't conflict with g_content
  formulas in general.
- **Risk**: If `G(¬w → ⊥) ∈ g_content(M)` (i.e., `G(w) ∈ M`), then `G(¬w) ∧ G(w)`
  implies `G(⊥)`, which contradicts consistency. But `F(w) ∈ M` and `G(w) ∈ M` would mean
  M contains `G(w)` and `F(w) = ¬G(¬w)`. Since `G(w) → w` is BX1 (REMOVED under
  irreflexive semantics), M could consistently contain both. Wait — if `G(w) ∈ M`, then
  `G(¬w) ∈ M` would be inconsistent with M itself, so we'd have `G(¬w) ∉ g_content(M)`.
  So `{w, G(¬w)} ∪ g_content(M)` is NOT necessarily consistent when `G(w) ∈ M`.

**Verdict**: G(¬w) seeding is conditionally consistent. Need to check `G(w) ∉ M` when
`F(w) ∈ M`. This should hold: if `G(w) ∈ M` and `F(w) = ¬G(¬w) ∈ M`, these are
consistent (under irreflexive semantics, G(w) and F(w) are both satisfiable simultaneously).
But then adding `G(¬w)` to the seed creates `{G(w), G(¬w)}`, deriving `G(⊥)`, which by
seriality gives `F(⊤) = ¬G(¬⊤)` and `G(⊤) → F(⊤)` by `serial_future`, but `G(⊥) → G(¬⊤)`
contradicts this. So `G(¬w) ∈ seed` when `G(w) ∈ M` gives inconsistency.

**Conclusion**: Approach 3 (G(¬w) seeding) FAILS when `G(w) ∈ M`. The handoff identifies
this as needing verification — the verification shows it fails in general.

### Approach 4: Amortized Finite State Space Argument

Rather than a step-by-step count decrease, use an AMORTIZED argument:

Define a "credit function" Φ(n) = number of chi in sigma_list such that:
- F(chi) was in chain(0) = M₀
- AND chi has NOT YET appeared in chain(k) for any k ≤ n

This credit is non-increasing: once chi appears in chain(k), it is permanently credited
(by `fwd_chain_F_obligation_monotone`, once chi appears, F(chi) may or may not persist,
but the argument is different).

Actually, the cleanest amortized argument is:

**Lemma**: For any chi in sigma_list with F(chi) in M₀, there exists m > 0 such that
chi in chain(m).

**Proof by contradiction**: If chi never appears in chain(m) for any m > 0, then:
1. For all m, chi ∉ chain(m)
2. For all m, F(chi) ∈ chain(m) (by `fwd_chain_defect_one_step`: if F(chi) ∈ chain(m)
   and chi ∉ chain(m+1), then F(chi) ∈ chain(m+1))
3. So the defect {chi} is always active
4. By `defect_step_choice_early`, at each step, some formula is resolved — but if chi
   is never resolved and F(chi) persists, what other defects are being resolved?
5. All other defects in sigma_list eventually resolve (by the same argument applied to
   each of them — but this is circular!)

The circular dependency is the crux of the problem. The standard resolution is an
INDUCTION on the size of the current defect set.

### Approach 5: Well-Founded Induction on Defect Set (KEY APPROACH)

The cleanest structural argument uses well-founded induction:

Let `P(S)` = "for any MCS M₀ with {chi | F(chi) in M₀ ∧ chi in sigma_list} = S,
the forward chain eventually resolves every element of S."

Base case: S = ∅ (trivially true — no defects to resolve).

Inductive step: Given |S| = k+1. At the first step, `defect_step_choice_early` resolves
some w ∈ S (w in chain(1)). Consider two cases:
- **Case A** (w exits S): F(w) ∉ chain(1). Then the defect set for chain(1) is S' ⊆ S \ {w},
  so |S'| ≤ k. By induction hypothesis, the chain starting from chain(1) resolves all
  elements of S'. Since S' contains all remaining elements of S (potentially minus more),
  we're done.
- **Case B** (w stays in S): F(w) ∈ chain(1) even though w ∈ chain(1). This is the
  problematic case. The defect set for chain(1) could be exactly S again. We cannot apply
  the induction hypothesis directly.

**Case B analysis**: Can Case B persist forever for a fixed w?
- In chain(1), w ∈ chain(1) AND F(w) ∈ chain(1). Under irreflexive semantics, this means:
  "w is true now AND there exists a strictly future time when w is true." This is consistent.
- At chain(2), we again apply `defect_step_choice_early`. The defect set includes w (since
  F(w) ∈ chain(1)). Some formula is again resolved.
- The question: over infinitely many steps, must w eventually be resolved in a step where
  it is NOT immediately re-added?

**The regeneration mechanism**: `F(w) in chain(n+1)` can happen if `G(¬w) ∉ chain(n+1)`.
The chain construction uses Lindenbaum extension with seed `{w} ∪ g_content(chain(n))`.
Whether `G(¬w)` ends up in the Lindenbaum extension depends on the opaque `.choose`.
This is the irreducible obstruction identified in the dead ends.

---

## Strategic Assessment

### Is the Current Architecture Fundamentally Sound?

**YES**, with a qualification. The mathematical argument is sound — under irreflexive
semantics, the chain SHOULD terminate because F(chi) obligations don't propagate reflexively.
The soundness is confirmed by the standard literature (Burgess, GHR, Goldblatt all produce
correct completeness proofs using similar arguments).

The issue is **formalization soundness**: the Lindenbaum `.choose` is non-constructive,
and the proof must work WITHOUT controlling what `.choose` produces. The current
infrastructure (`defect_step_choice_early`, `resolving_enriched_fwd_exists`) gives
EXISTENCE of a resolving step but not UNIQUENESS or CONTROL over what happens to F(w)
after w is resolved.

### The Correct Path Forward

After studying the literature and the codebase carefully, I conclude:

**Path A (active defect finite descent) IS the correct approach**, but requires a key
insight that has not yet been formalized:

**The `fwd_chain_F_set_nonincreasing` theorem is the key**. It says:
- F_set(n) = {chi in sigma_list | F(chi) in chain(n)} is NON-INCREASING
- This means once F(chi) leaves the chain, it NEVER RETURNS

Combined with `defect_step_choice_early` (at each step with active defects, SOME chi in
F_set gets resolved — i.e., chi in chain(n+1)), the argument is:

1. F_set(0) = {chi in sigma_list | F(chi) in M₀} is finite
2. At each step n with F_set(n) ≠ ∅, some chi in F_set(n) gets resolved (chi in chain(n+1))
3. After chi is resolved (chi in chain(n+1)):
   - Either F(chi) ∈ chain(n+1): then chi is STILL in F_set(n+1) but ALSO in chain(n+1)
   - Or F(chi) ∉ chain(n+1): then chi EXITS F_set, never to return
4. In case (a): chi is in chain(n+1) AND F(chi) in chain(n+1). At step n+1, `defect_step_choice_early`
   will again find some formula to resolve. What happens to chi at step n+2?
   - chi ∈ chain(n+1) means g_content propagation MAY carry G(chi) not chi. We don't get
     chi ∈ chain(n+2) for free.
   - BUT: `fwd_chain_defect_one_step` gives: chi ∈ chain(n+2) OR F(chi) ∈ chain(n+2)

**The key missing piece**: a proof that F_set strictly decreases EVENTUALLY. Specifically:

**Claim**: For any chi in F_set(0), there exists N such that F(chi) ∉ chain(N).

**Proof of claim** (by contradiction + compactness):
Suppose F(chi) ∈ chain(n) for ALL n. By `defect_step_choice_early`, at each step some
formula is resolved. Consider the sequence of RESOLVED formulas: w(0) ∈ chain(1),
w(1) ∈ chain(2), etc. Each w(k) is from F_set(k). F_set(k) ⊆ F_set(0) (by
`fwd_chain_F_set_nonincreasing`). F_set(0) is finite (say |F_set(0)| = m). By
pigeonhole, some formula v appears as w(k) for infinitely many k.

For each such k, v ∈ chain(k+1). But `fwd_chain_F_obligation_monotone`: once F(v) ∉
chain(j), F(v) ∉ chain(j+1), etc. So if v is resolved at step k (v ∈ chain(k+1)) and
F(v) ∉ chain(k+1), then F(v) never returns. v would then be permanently discharged and
cannot appear as the resolved formula at any step > k.

Therefore: v appears as w(k) (the resolved formula) infinitely often IMPLIES F(v) ∈ chain(k+1)
at every step k where v is resolved. But then: F(v) persists AND v is resolved infinitely
often. What keeps F(v) in the chain?

**Here is the subtlety**: After v is resolved at step k (v ∈ chain(k+1)), F(v) ∈ chain(k+1)
requires either: (a) the seed explicitly included something that forces F(v), or (b)
Lindenbaum `.choose` added F(v) "for free."

Under the CURRENT chain construction, (b) is possible: Lindenbaum extension is non-constructive.
So the pigeonhole argument identifies the bottleneck but doesn't close the gap without
controlling the Lindenbaum extension.

### Why Path B (Quasimodel Run Composition) Avoids This

The quasimodel approach AVOIDS the Lindenbaum opacity problem because:
- Each finite quasimodel run uses the SIGMA-SPECIFIC oracle (`hintikka_step_for_sigma_sig`)
- This oracle has a DETERMINISTIC defect count decrease (sorry in oracle, but the logic is clear)
- Run composition then trivially gives the infinite timeline

The gap in Path B is only the oracle defect-count sorry — a single lemma about how the
sigma-specific oracle step decreases the Until-defect count. This is a much more targeted
gap than Path A's Lindenbaum opacity.

### Which Approach Best Serves Strategic Goals?

| Goal | Path A | Path B |
|------|--------|--------|
| Sorry-free bx_completeness | Possible but requires Lindenbaum control | More likely — single targeted gap |
| Representation theorem | Directly compatible (works with existing BFMCS) | Requires run-composition bridge |
| Decidability (task 82) | Independent | Independent |
| Code complexity | Moderate (builds on existing chain) | High (new run-composition layer) |
| Risk | Medium-high (Lindenbaum opacity) | Medium (one sorry to close) |

**Verdict**: Path B is strategically superior for sorry-free completeness. The single oracle
defect-monotonicity sorry is a much cleaner target than the Lindenbaum opacity problem in
Path A. However, Path B requires a run-composition layer that doesn't yet exist.

---

## Recommended Direction

### Phase 1: Close the Oracle Defect-Count Sorry (Path B)

**Target**: `HintikkaStepOracle.lean` — the sorry in `hintikka_step_oracle_for_sigma_sig`
that asserts `defect_count` decreases.

**Approach**: Use the enriched oracle seed fix proposed by Teammate B:
- Enrich the oracle step seed with `{neg(phi U psi) | phi U psi in Sigma, phi U psi ∉ active_defects}`
- This prevents Lindenbaum from introducing NEW Until-defects not in the original MCS
- With this fix, the defect count strictly decreases at each oracle step
- The consistency of the enriched seed needs verification (should be sound: each
  `neg(phi U psi)` is in the current MCS since `phi U psi` is not an active defect)

**Why this works**: The oracle step produces a new Hintikka point in the sigma-closure.
If `phi U psi` is not currently a defect (not in the active defect list), then `neg(phi U psi)`
is true at the current point (MCS completeness), and including it in the seed FORCES
`phi U psi` to be absent from the new point, preventing new defect introduction.

### Phase 2: Build Run-Composition Layer

Once the oracle sorry is closed, build the infrastructure to:
1. Use `hintikka_chain_exists` to build a finite run resolving each defect
2. Concatenate runs into an INT-indexed chain
3. Show the concatenated chain satisfies BFMCS coherence properties

This avoids the backward Until step transfer problem (sorry #4) because the run structure
directly provides Until witnesses without needing to pull Until formulas backward.

### Phase 3: Wire Path A as Backup

If Path B stalls on run composition, pursue Path A's counting argument more carefully:
- Redefine `active_defects` to include `chi not_in M` condition
- Use `fwd_chain_F_set_nonincreasing` to give a finite state space
- Apply the pigeonhole argument on the RESOLVED formulas sequence
- The key lemma needed: "If v is resolved (v in chain(k+1)) and F(v) in chain(k+1),
  then at some step k' > k, F(v) ∉ chain(k')." This requires showing that the Lindenbaum
  extension EVENTUALLY does not add F(v) — which may require the G(¬v) seeding idea,
  conditionally applied.

---

## Confidence Level

- **Path B (oracle sorry → run composition)**: 70% confidence this closes sorry #1.
  The oracle sorry fix is mathematically sound (enriched seed consistency is straightforward).
  The run composition is novel infrastructure but follows standard literature patterns.

- **Path A (active defect counting)**: 45% confidence. The counting argument is mathematically
  correct in principle, but Lindenbaum opacity makes formalization uncertain. The G(¬w)
  seeding approach fails in general (when G(w) ∈ M), so a different mechanism for preventing
  F(w) re-entry is needed.

- **Sorry #4 (backward Until step transfer)**: 20% confidence using either path. This
  requires either the quasimodel run structure (Path B) or a "next" operator (changes the
  logic). Most likely requires Path B's run composition to avoid step transfer entirely.

---

## Open Questions

1. **Regeneration bound for Path A**: Can we prove that for any chi in F_set(0), there
   exists N with F(chi) ∉ chain(N)? The pigeonhole argument suggests yes but hits the
   Lindenbaum opacity wall.

2. **Oracle defect-count sorry**: What is the EXACT sorry statement in
   `hintikka_step_oracle_for_sigma_sig`? The team research summary references
   `OracleStep.lean:452` — this needs verification before the enriched seed fix can be
   applied.

3. **Run composition compatibility with BFMCS**: The `dd_bfmcs` structure requires
   families of INT-indexed chains. Can quasimodel runs (which are finite and over
   Hintikka points, not BXPoints) be lifted to INT-indexed BXPoint chains? The
   Realization.lean infrastructure may already provide this lift.

4. **Sorry #2 and #3 (backward temporal coherence)**: The backward chain for negative
   integers in `dd_chain` uses `bwd_pred` which has H-content propagation but no
   P-resolution analogue of `fwd_chain_forward_F`. A symmetric backward analysis is needed.

5. **BX11 transitivity question** (from handoff Approach C): Is there a weaker form of
   BX11 transitivity that holds? Specifically: is the relation `bx11_earlier_total` a
   partial order (reflexive, antisymmetric, transitive)? If even partial order holds, the
   minimum element argument could be applied more carefully.

---

## Summary for Team Synthesis

- **No axiom extension needed** — BX under irreflexive semantics is mathematically sufficient
- **No fundamental impossibility** — the obstacle is formalization opacity, not a proof-theoretic gap
- **Path B (quasimodel run composition)** is the strategically superior path with a single
  targeted sorry to close
- **The active defect counting argument (Path A)** is mathematically correct but requires
  controlling Lindenbaum extension in a way that may be extremely difficult to formalize
- **Sorry #4 (backward Until step transfer)** is the hardest; Path B avoids it via run
  structure, but requires the run composition layer to be built first
- **G(¬w) seeding fails** when G(w) ∈ M — this approach from the handoff should be abandoned
