# Teammate A Findings: Axiom-Based Irreflexivity Proof

## Task Context

Prove `canonicalR_irreflexive : (M : Set Formula) -> SetMaximalConsistent M -> ¬CanonicalR M M`.

`CanonicalR M M` means `GContent M ⊆ M`, where `GContent M = { phi | all_future phi ∈ M }`.

## Forward Analysis

### What does CanonicalR(M, M) give us?

Starting from `GContent(M) ⊆ M`:

**Step 1: HContent reflexivity follows.**
By `GContent_subset_implies_HContent_reverse` (WitnessSeed.lean:324) with M' = M:
if `GContent(M) ⊆ M`, then `HContent(M) ⊆ M`. This uses temp_a: `phi → G(P(phi))`.

Proof sketch: If phi in HContent(M) but phi not in M, then neg(phi) in M (MCS).
By temp_a applied to neg(phi): `G(P(neg(phi))) ∈ M`. By GContent ⊆ M:
`P(neg(phi)) ∈ M`. By HContent ⊆ M on H(phi): phi ∈ M. Contradiction.

**Step 2: Every formula in M has its F-version in M.**
For any phi ∈ M:
- By past_temp_a (WitnessSeed.lean:312): `phi → H(F(phi))`, so `H(F(phi)) ∈ M`.
- By HContent(M) ⊆ M (from Step 1): `F(phi) ∈ M`.

**Step 3: Every formula in M has its P-version in M.**
For any phi ∈ M:
- By temp_a: `phi → G(P(phi))`, so `G(P(phi)) ∈ M`.
- By GContent(M) ⊆ M: `P(phi) ∈ M`.

**Step 4: Constraint on G-negation.**
For any phi ∈ M:
- F(phi) ∈ M (Step 2).
- F(phi) = ¬G(¬phi). So `G(¬phi) ∉ M`.

**Step 5: Constraint on H-negation.**
For any phi ∈ M:
- P(phi) ∈ M (Step 3).
- P(phi) = ¬H(¬phi). So `H(¬phi) ∉ M`.

### Summary of consequences

Under `CanonicalR(M, M)`:
- `GContent(M) ⊆ M` (given)
- `HContent(M) ⊆ M` (derived)
- For all phi ∈ M: `F(phi) ∈ M`, `P(phi) ∈ M`
- For all phi ∈ M: `G(¬phi) ∉ M`, `H(¬phi) ∉ M`
- For all phi: if `G(phi) ∈ M` then `phi ∈ M` (definition)
- For all phi: if `H(phi) ∈ M` then `phi ∈ M` (HContent reflexivity)

## Backward Analysis

### What do we need to derive a contradiction?

We need either:
1. **A formula phi ∈ M and neg(phi) ∈ M** -- direct inconsistency.
2. **A derivation of bot from formulas in M** -- contradicts SetConsistent.
3. **A formula phi such that G(phi) ∈ M but phi ∉ M** -- contradicts GContent ⊆ M.

Option 3 is what we'd use to show ¬(GContent(M) ⊆ M) directly.
Options 1 and 2 show the MCS itself is inconsistent under the reflexivity assumption.

### What axioms/rules could close the gap?

The key question: do the axioms of TM (with IRR) force every MCS to have some
G(phi) whose argument is NOT in the MCS?

Without IRR: the T-axiom `G(phi) → phi` would trivially make GContent ⊆ M for ALL MCS.
But we DON'T have the T-axiom (since G is strictly future). So without the T-axiom,
it is NOT the case that GContent ⊆ M for all MCS. But can it happen for SOME MCS?

With IRR: the IRR rule derives additional theorems, tightening the constraints on MCS.

## Proof Attempt 1: Direct from Axioms (No IRR)

### Strategy

Try to derive contradiction from axioms alone (density, seriality, temp_a, temp_4).

### Analysis

From the forward analysis, under CanonicalR(M, M), we get for all phi ∈ M:
- F(phi) ∈ M and P(phi) ∈ M.
- G(¬phi) ∉ M and H(¬phi) ∉ M.

But none of these lead to a direct contradiction. The constraints are
self-consistent: an MCS where G(phi) ∈ M implies phi ∈ M, and
phi ∈ M implies F(phi), P(phi), G(P(phi)), H(F(phi)) ∈ M.

**Key test**: Can G(G(⊥)) be derived from these constraints?
- G(⊥) ∉ M (from seriality: F(¬⊥) = ¬G(⊥) ∈ M).
- This means ⊥ is NOT in GContent(M), so GContent ⊆ M is not violated by ⊥.
- But we also need G(phi) ∈ M for SOME phi with phi ∉ M to get contradiction.

**Critical question**: Does every MCS M contain some `G(phi)` such that `phi ∉ M`?

Without IRR, the answer is NO for the axioms we have. The proof system without IRR
is complete for reflexive-or-irreflexive frames. A reflexive frame (like Z with ≤)
satisfies all the non-IRR axioms and has G(phi) → phi valid, so GContent(M) ⊆ M
for every MCS in the reflexive canonical model.

### Verdict: NOT possible without IRR

The axioms alone (density, seriality, temp_a, temp_4, temp_k_dist, etc.) are
consistent with reflexive frames. Therefore, an MCS satisfying GContent ⊆ M
exists in the IRR-free system. The IRR rule is ESSENTIAL.

## Proof Attempt 2: Via IRR Rule

### Strategy

Use the Gabbay IRR rule to derive a specific theorem `phi` that prevents
any MCS from satisfying `GContent(M) ⊆ M`.

### The IRR Rule

```
irr (p : String) (phi : Formula)
    (h_fresh : p ∉ phi.atoms)
    (d : [] ⊢ (Formula.and (Formula.atom p)
                (Formula.all_past (Formula.neg (Formula.atom p)))).imp phi)
    : [] ⊢ phi
```

From a derivation of `(p ∧ H(¬p)) → phi` where p does not occur in phi,
conclude `phi`.

### Key Derivation

**Claim**: Using IRR, we can derive `[] ⊢ G(G(q)) → G(q)` for any atom q
(where p is a fresh atom not equal to q).

Wait -- we already have `G(G(q)) → G(q)` from the density axiom (contrapositive
of `F(q) → F(F(q))`). So this isn't new.

**Better claim**: Using IRR, derive `[] ⊢ ¬(G(q) ∧ ¬q)` for atom q?

This says "it's not the case that q holds at all strict future times but not now."
With p ∉ {q}, we need: `[] ⊢ (p ∧ H(¬p)) → ¬(G(q) ∧ ¬q)`.

Under assumption `p ∧ H(¬p)` and toward contradiction assume `G(q) ∧ ¬q`:
- p at t, ¬p at all s < t.
- G(q) at t means q at all s > t. ¬q at t.
- By temp_a applied to p: G(P(p)) at t. So at all s > t, P(p) holds at s.
  P(p) at s means ∃ r < s with p at r. The witness is r = t (since t < s).
  But this is SEMANTIC reasoning, not syntactic. We need a syntactic derivation.

The syntactic derivation would be:
1. From `p` and temp_a: `G(P(p))`.
2. `G(P(p))` means at all future times, P(p) holds.
3. From `G(q)` and `G(P(p))`: by temp_k_dist, `G(q ∧ P(p))`.
4. Hmm, we need `G(q → (P(p) → (q ∧ P(p))))` first...

This gets complex. Let me try a different approach.

### Correct IRR Application for Irreflexivity

**The standard technique** (Gabbay 1981, Blackburn-de Rijke-Venema 2001) for
proving canonical model irreflexivity via IRR:

For ANY atom q, define:
```
phi_q = G(q) → q
```

We CANNOT derive this via IRR since phi_q mentions q (not p-free in general).

But consider: pick a SPECIFIC fresh p. The IRR rule with `phi = ⊥` says:
if `(p ∧ H(¬p)) → ⊥` is derivable, then `⊥` is a theorem. This would make the
system inconsistent, so it's not the right approach.

**The correct approach**: Use IRR to show that in any MCS, there is a formula
in GContent(M) that is NOT in M.

**Specific theorem via IRR**: For any atom q with q ≠ p:

```
[] ⊢ (p ∧ H(¬p)) → (G(q ∧ H(¬q)) → (q ∧ H(¬q)))
```

The conclusion `G(q ∧ H(¬q)) → (q ∧ H(¬q))` is p-free (p ∉ atoms of conclusion).
By IRR: `[] ⊢ G(q ∧ H(¬q)) → (q ∧ H(¬q))`.

**Derivation of the premise**:
Under assumption `p ∧ H(¬p)` and `G(q ∧ H(¬q))`:
- p at t, ¬p at all past.
- G(q ∧ H(¬q)) means at all strict future s > t: q at s and H(¬q) at s.
- H(¬q) at s means ¬q at all r < s.
- In particular, at t (which is < s): ¬q at t.

But wait, we need q ∧ H(¬q) at t (the conclusion). We have ¬q at t (from above).
So q ∧ H(¬q) at t requires both q and H(¬q) at t. We have ¬q at t, so we DON'T
have q at t. Contradiction with needing q at t.

Hmm, this doesn't work. The conclusion requires q at t, but we derived ¬q at t.

Let me reconsider. We want to use IRR to derive a theorem of the form
`G(alpha) → alpha` for some specific formula alpha.

If `alpha = q ∧ H(¬q)`:
- Under `p ∧ H(¬p)` and `G(q ∧ H(¬q))`:
  - At all s > t: q at s and ¬q at all r < s.
  - In particular at t: since t < s for some s > t: ¬q at t (from H(¬q) at s).
  - But we need q ∧ H(¬q) at t: q at t (needed but we have ¬q) -- FAILS.

If `alpha = ¬q ∧ H(q)`:
- Under `p ∧ H(¬p)` and `G(¬q ∧ H(q))`:
  - At all s > t: ¬q at s and q at all r < s.
  - At t: since t < s, we need to check... from H(q) at s: q at all r < s, including t. So q at t.
  - H(q) at t: q at all r < t. Not directly given...
  - Actually, we get ¬q at all s > t (from G(¬q ∧ ...) → G(¬q)) and q at t.
  - So ¬q ∧ H(q) at t requires ¬q at t -- but q at t. CONTRADICTION.

So this doesn't give `alpha` at t either.

### The Actual Working Approach

The standard approach in temporal logic is different. Here it is:

**Theorem**: Using IRR, derive that for any formula psi, the formula
`G(psi) ∧ H(¬psi)` is inconsistent (leads to ⊥).

Actually, the cleaner approach:

**Derive `[] ⊢ ¬(G(psi) ∧ ¬psi ∧ H(¬psi))` for all psi.**

But this is NOT p-free in general if psi mentions atoms.

**The cleanest approach**: Show the contradiction DIRECTLY from the MCS.

Assume `CanonicalR(M, M)`. Choose any atom p. By MCS: either `atom p ∈ M` or `¬(atom p) ∈ M`.

**Case 1**: `atom p ∈ M`.
By forward analysis Step 3: `P(atom p) ∈ M`, i.e., `¬H(¬(atom p)) ∈ M`.
So `H(¬(atom p)) ∉ M`.

Now consider the IRR rule applied with this specific p and `phi = ⊥`... no, that makes ⊥ a theorem.

**Case 2**: `¬(atom p) ∈ M`.
By forward analysis Step 3: `P(¬(atom p)) ∈ M`, i.e., `¬H(atom p) ∈ M`.

Hmm, neither case gives immediate contradiction.

### Strategy Revision: The MCS-Level IRR Argument

The key insight from Gabbay's paper: IRR doesn't derive a single formula that
prevents reflexivity. Instead, it works at the MCS CONSTRUCTION level:

When building the canonical model for a logic with IRR, the Lindenbaum extension
must respect IRR. An MCS Gamma in a logic with IRR must contain all IRR consequences.

Specifically: for every `(p ∧ H(¬p)) → phi` that is derivable (where p ∉ phi.atoms),
the MCS must contain phi.

The argument for irreflexivity proceeds:

Assume CanonicalR(Gamma, Gamma). Let p be ANY atom.

**Sub-claim**: `(atom p) ∧ H(¬(atom p))` is consistent with GContent(Gamma).

If GContent(Gamma) ⊆ Gamma, then for any G(psi) ∈ Gamma, psi ∈ Gamma.
The set {atom p, H(¬(atom p))} ∪ GContent(Gamma) should be examined for consistency.

Actually, let me try a completely different approach.

### Strategy B/C Hybrid: IRR-Derived Theorem + MCS Argument

**Theorem via IRR**: For any atom q (choosing p fresh from q):
```
[] ⊢ (p ∧ H(¬p)) → (H(¬q) → ¬G(q))
```

Under `p ∧ H(¬p)` and `H(¬q)` and toward contradiction `G(q)`:
- p at t, ¬p at all s < t.
- ¬q at all s < t (from H(¬q) at t).
- q at all s > t (from G(q) at t).
- By density: between any two points there's another. For s > t, there exists u with t < u < s.
  At u: u > t so q at u (from G(q)). And u < s so... we need more.
- Actually, do we need density here? Let's think about what seriality gives.
- F(¬⊥) at t: ∃ s > t. At s: q (from G(q)). And by temp_a on p: G(P(p)) at t.
  So P(p) at s, meaning ∃ r < s with p at r. The witness r = t works (t < s).
  But we're mixing semantic and syntactic reasoning.

**The formal syntactic argument is**: We need a DerivationTree, not a semantic argument.

Let me try to construct: `[p ∧ H(¬p), H(¬q), G(q)] ⊢ ⊥`.

1. From `G(q)` and temp_4: `G(G(q))`.
2. From `H(¬q)` and temp_a on ¬q: but temp_a says `¬q → G(P(¬q))`.
   We don't have ¬q in context directly; we have H(¬q).
3. Hmm. Let me think differently.

Actually, maybe I should try: from `H(¬q)` and `G(q)`, can we derive ⊥?

`H(¬q)` means ¬q at all past. `G(q)` means q at all future. These are compatible
(q changes from false to true at "now"). No contradiction.

But add `p ∧ H(¬p)`: p is true only at "now". We can use this to "name" the present.

From temp_a on p: `G(P(p))`. So at all future s > t: P(p) at s, meaning ∃ r < s
with p at r. By H(¬p) at t: ¬p at all r < t. So the only r with p is r = t.
So at each s > t: the P(p) witness must be exactly t.

This means: at all future s > t, there is some r < s with p at r, namely t.
And t < s, so H(¬q) at t gives ¬q at all r' < t.

What about q at t? From G(q): q at all s > t. Is q at t? Not given by G(q)
(irreflexive). We also have H(¬q): ¬q at all s < t. So q's status at t is
open -- it could be either.

No contradiction from `[p ∧ H(¬p), H(¬q), G(q)]`.

### Key Realization

**The IRR-based approach to CanonicalR irreflexivity is more nuanced than
expected.** The standard reference (Blackburn-de Rijke-Venema, Chapter 5) uses
IRR in a specific way for temporal logics:

The argument uses the fact that in a canonical model for a logic with IRR,
one can show that if CanonicalR(Gamma, Gamma), then for a fresh p,
both `atom p` and `¬(atom p)` lead to contradictions when combined with
the G/H-content inclusion.

**The actual proof** (reconstruction from BdRV):

Assume CanonicalR(M, M), i.e., GContent(M) ⊆ M.

Consider the set `Sigma = {atom p} ∪ {H(¬(atom p))} ∪ GContent(M)` where p
is fresh (p does not appear as an atom in any formula of GContent(M)).

**Step A**: Sigma is consistent.

If Sigma were inconsistent, then from some finite subset we derive ⊥. This means:
from `[atom p, H(¬(atom p)), G_1, ..., G_n]` (where G_i ∈ GContent(M)) we derive ⊥.
By iterated deduction theorem: `[] ⊢ G_1 → ... → G_n → ¬(atom p ∧ H(¬(atom p)))`.
By temporal necessitation and K distribution:
`[] ⊢ G(G_1) → ... → G(G_n) → G(¬(atom p ∧ H(¬(atom p))))`.
Since G(G_i) ∈ M (by temp_4 from G_i ∈ GContent(M)):
`G(¬(atom p ∧ H(¬(atom p)))) ∈ M`.
By GContent ⊆ M: `¬(atom p ∧ H(¬(atom p))) ∈ M`.

But ¬(atom p ∧ H(¬(atom p))) mentions p. And p is fresh for GContent(M).
By IRR, any theorem derived about fresh variables must hold "unconditionally".

This is where the argument gets tricky. Let me think more carefully.

Actually, the formula `¬(atom p ∧ H(¬(atom p)))` is NOT a theorem -- it's just
claimed to be in M. And M contains ALL formulas or their negations.

**The real issue**: If `¬(atom p ∧ H(¬(atom p))) ∈ M`, then M thinks the "naming
hypothesis" is false. This is consistent.

**Alternative approach**: Extend Sigma to an MCS, call it N. N contains:
- atom p (so p is "true at N")
- H(¬(atom p)) (so ¬p at all past times relative to N)
- GContent(M) (so N is a canonical-R successor of M)

Since CanonicalR(M, M), GContent(M) ⊆ M. And GContent(M) ⊆ N (by construction).
So CanonicalR(M, N).

Now: is N = M? If N = M, then atom p ∈ M. But also GContent(M) ⊆ M gives
(via HContent(M) ⊆ M from the forward analysis) that H(¬(atom p)) ∈ M implies
¬(atom p) ∈ M. But atom p ∈ M and ¬(atom p) ∈ M contradicts consistency.

**Wait, this only works if H(¬(atom p)) ∈ M.** We put H(¬(atom p)) in N, not M.

If N = M, then H(¬(atom p)) ∈ N = M. And atom p ∈ N = M. And HContent(M) ⊆ M
gives ¬(atom p) ∈ M. Contradiction with atom p ∈ M!

**If N ≠ M**: N is a different MCS with CanonicalR(M, N). This means GContent(M) ⊆ N
but N ≠ M. This is fine -- N is a future witness for M that is NOT M itself.

But we assumed CanonicalR(M, M). Having N with CanonicalR(M, N) and N ≠ M
does NOT contradict CanonicalR(M, M). Both can hold simultaneously.

So the N = M case gives contradiction, but the N ≠ M case doesn't.

**The gap**: We need to force N = M, or find contradiction in the N ≠ M case too.

**Crucial observation**: We DON'T need N = M. What we showed is:

If CanonicalR(M, M) and Sigma is consistent, then extending Sigma to N
with N = M gives contradiction. But if N ≠ M, that's fine -- we just
didn't get the specific contradiction.

**The proof works if Sigma is INCONSISTENT**:

If Sigma = {atom p, H(¬(atom p))} ∪ GContent(M) is inconsistent, then...
we showed this leads to `¬(atom p ∧ H(¬(atom p))) ∈ M` (by the deduction
argument above). But this is fine -- it just means M doesn't believe the
"naming hypothesis" for p.

**The resolution**: We need to find an atom p such that BOTH:
- `atom p ∈ M` AND `H(¬(atom p)) ∈ M`.

If such p exists, then by HContent ⊆ M: ¬(atom p) ∈ M, contradiction.

But does such p exist?

**Under CanonicalR(M, M)**: For any phi ∈ M, P(phi) ∈ M (Step 3 of forward analysis).
In particular, for phi = atom p (if atom p ∈ M): P(atom p) ∈ M, i.e.,
¬H(¬(atom p)) ∈ M. So H(¬(atom p)) ∉ M!

Conversely, if ¬(atom p) ∈ M: P(¬(atom p)) ∈ M, i.e., ¬H(atom p) ∈ M.
So H(atom p) ∉ M.

This means: under CanonicalR(M, M), for each atom p:
- If atom p ∈ M, then H(¬(atom p)) ∉ M.
- If ¬(atom p) ∈ M, then H(atom p) ∉ M.

So we CANNOT have both `atom p ∈ M` and `H(¬(atom p)) ∈ M` simultaneously
under CanonicalR(M, M). The naming hypothesis can't hold at a reflexive point!

But this is exactly what IRR uses: the naming hypothesis IS satisfiable at
non-reflexive points (in irreflexive frames, every point can be uniquely named).

### The Complete IRR Argument

Here is the complete proof:

**Step 1**: Choose p fresh (not appearing in any formula of interest).

**Step 2**: Via IRR, derive the following theorem for any q ≠ p:
```
phi_q := (atom q ∧ G(atom q)) → (H(atom q) ∨ G(atom q ∧ H(atom q)))
```

Actually, this is getting too complicated. Let me try the simplest possible approach.

**Simplest IRR-based proof**:

For any atom q, choose p fresh (p ≠ q). We claim:
```
[] ⊢ (p ∧ H(¬p)) → (G(H(¬p)) → H(¬p))
```

The conclusion is `G(H(¬p)) → H(¬p)` which DOES mention p. So IRR doesn't apply directly.

**EVEN SIMPLER**: Use IRR with `phi = G(bot) → bot`:
- phi.atoms = ∅ (no atoms in bot). So any p is fresh.
- Need: `[] ⊢ (p ∧ H(¬p)) → (G(⊥) → ⊥)`.
- Under `p ∧ H(¬p)` and `G(⊥)`:
  - G(⊥) means ⊥ at all s > t. So G(⊥) → ⊥ iff all s > t...
  - Actually G(⊥) is false on irreflexive frames with seriality (there IS a future point,
    and ⊥ can't hold there). But syntactically, `G(⊥) → ⊥` is NOT derivable in
    general (G(⊥) could be vacuously true if there are no future points).
  - With seriality, `¬G(⊥)` is derivable (since `F(¬⊥)` is an axiom and
    `F(¬⊥) = ¬G(⊥)`). So `G(⊥) → ⊥` is derivable from `¬G(⊥)` by explosion
    (if ¬G(⊥) then G(⊥) → anything).

Wait! `¬G(⊥)` IS a theorem (from seriality). So `G(⊥) → ⊥` is derivable:
from `¬G(⊥) = G(⊥) → ⊥`, we literally have `G(⊥) → ⊥`.

Actually, `¬G(⊥) = (all_future bot).imp bot`. That IS `G(⊥) → ⊥`.

So `G(⊥) → ⊥` IS a theorem already (it's the seriality axiom in disguise:
`F(¬⊥) = ¬G(⊥) = G(⊥) → ⊥`... wait, `F(¬⊥) = ¬G(¬(¬⊥)) = ¬G(⊥ → ⊥)`.

Hmm, `F(¬⊥) = some_future(neg bot) = neg(all_future(neg(neg bot)))`.
And `neg(neg bot) = (bot → bot) → bot`. That's NOT the same as `neg(all_future bot)`.

So `F(¬⊥) ≠ ¬G(⊥)` due to the encoding of negation!

Let me recheck: `neg phi = phi.imp bot`. So `neg bot = bot.imp bot`.
And `some_future phi = neg(all_future(neg phi))`.
So `some_future(neg bot) = neg(all_future(neg(neg bot))) = neg(all_future((bot.imp bot).imp bot))`.

While `neg(all_future bot) = (all_future bot).imp bot`.

These are definitionally different formulas! `F(¬⊥) ≠ ¬G(⊥)`.

This is a critical encoding issue. In the codebase, `F` and `G` are related by
`F(phi) = ¬G(¬phi)`, but the double negation makes the formulas structurally different.

However, in MCS, double negation elimination holds (MCS are classical). So
`G(⊥) ∈ M ↔ G(¬¬⊥) ∈ M` (via the DNE theorem and temporal K distribution),
and `¬G(⊥) ∈ M ↔ ¬G(¬¬⊥) ∈ M`.

The seriality axiom `F(¬⊥) ∈ M` means `¬G(¬(¬⊥)) ∈ M` which means `G(¬(¬⊥)) ∉ M`.
Since `¬(¬⊥) = (⊥ → ⊥) → ⊥`... this is getting into encoding details.

**The SeparationLemma already handles this**: `not_G_implies_F_neg` in SeparationLemma.lean
converts between ¬G(phi) and F(¬phi) accounting for the double negation.

## Proof Attempt 3: The Correct IRR-Based Proof

After extensive analysis, here is the correct proof strategy:

### The Proof

Assume `CanonicalR(M, M)`, i.e., `GContent(M) ⊆ M`.

**Step 1**: As shown in forward analysis, this implies `HContent(M) ⊆ M`.

**Step 2**: Choose any atom p. Either `atom p ∈ M` or `neg(atom p) ∈ M`.

**Case: atom p ∈ M.**
- By Step 3 of forward analysis: `P(atom p) ∈ M`.
- `P(atom p) = ¬H(¬(atom p))`. So `H(¬(atom p)) ∉ M`.
- By MCS negation complete: `¬H(¬(atom p)) ∈ M`. (Already known: P(atom p) ∈ M.)

Now: `atom p ∈ M` and `H(¬(atom p)) ∉ M`. So `¬(atom p ∧ H(¬(atom p)))` holds at M
(in the sense that either ¬(atom p) ∈ M or ¬H(¬(atom p)) ∈ M; here ¬H(¬(atom p)) ∈ M).

**Case: neg(atom p) ∈ M.**
- By Step 3: `P(neg(atom p)) ∈ M`.
- This means `¬H(atom p) ∈ M`. So `H(atom p) ∉ M`.

In neither case do we get a direct contradiction yet. The issue is that under
CanonicalR(M, M), the "naming hypothesis" `p ∧ H(¬p)` is NOT satisfiable at M
(as we showed above).

**Step 3**: The IRR argument.

For any p-free formula phi, if `(p ∧ H(¬p)) → phi` is derivable, then phi is
a theorem, hence phi ∈ M.

Now consider the formula `phi_0`:
```
phi_0 = ¬ (∧_{G(psi)∈M} ¬psi)
```
This is an infinite conjunction and not a formula. So this approach doesn't work directly.

**Step 4**: The finite witnessing argument.

Instead of working with the full GContent, work with a SPECIFIC formula.

**Key theorem to derive via IRR**:
For any atom q, choose p ≠ q fresh.
```
phi = G(q → H(q)) → (q → H(q))
```
phi.atoms = {q}, and p ∉ {q} (since p ≠ q). Good.

Need: `[] ⊢ (p ∧ H(¬p)) → (G(q → H(q)) → (q → H(q)))`.

Under assumptions `p ∧ H(¬p)`, `G(q → H(q))`, `q`:
- p at t, ¬p at all s < t.
- At all s > t: q → H(q) (i.e., if q at s, then ¬q at no r < s).
- q at t.
- Want: H(q) at t, i.e., q at all s < t.

From `q at t` and `H(¬p)`: p was false before t. But what about q before t?
We don't know! The information `G(q → H(q))` tells us about future times,
not past. And `p ∧ H(¬p)` tells us about p, not q.

This doesn't close. The issue: `p ∧ H(¬p)` gives us information about the
present and past of p, but we need information about q's past.

### Revised Attempt: Use the IRR-Derived Schema Differently

**The literature approach** (from Gabbay's 1981 irreflexivity lemma):

The proof works by showing that in any canonical model for a logic with IRR,
no world can be its own R-successor. The argument uses the freshness of p
as a "paint marker" for the current world.

**Here is the rigorous argument adapted to our setting:**

Suppose for contradiction that `CanonicalR(M, M)`.

Step 1: GContent(M) ⊆ M and HContent(M) ⊆ M (as established).

Step 2: For ANY formula phi, define:
```
phi* := phi ∧ H(¬phi)
```
The formula phi* says "phi holds now and ¬phi at all past times."

For phi* to be in an MCS M, we need:
- phi ∈ M and H(¬phi) ∈ M.
Under CanonicalR(M, M) with HContent ⊆ M:
- H(¬phi) ∈ M implies ¬phi ∈ M (from HContent ⊆ M).
- But phi ∈ M and ¬phi ∈ M contradicts consistency!

**Therefore: for ALL formulas phi, the formula `phi ∧ H(¬phi)` is NOT in M.**

In other words: `¬(phi ∧ H(¬phi)) ∈ M` for all phi.

Step 3: But `phi ∧ H(¬phi)` is exactly the "naming hypothesis" for phi.

By IRR: if `(p ∧ H(¬p)) → psi` is derivable with p ∉ psi.atoms,
then psi is a theorem, hence psi ∈ M.

Step 4: But we need MORE from IRR. The theorems derived by IRR must be
consistent with M being an MCS.

The KEY POINT: The IRR rule means that EVERY p-free consequence of
`p ∧ H(¬p)` is in M. In particular, if from `p ∧ H(¬p)` we can derive
a contradiction with GContent(M) ⊆ M, we're done.

**The actual contradiction**:

Consider the IRR instance with `phi = ⊥` (no atoms):
We need `(p ∧ H(¬p)) → ⊥` to be derivable. But this is NOT derivable
(it would make ⊥ a theorem).

Consider the IRR instance with `phi = G(q) → q` for some atom q ≠ p.
We need `(p ∧ H(¬p)) → (G(q) → q)` to be derivable.

Under `p ∧ H(¬p)` and `G(q)`:
- At all s > t: q at s.
- We want q at t.
- From the `p ∧ H(¬p)` assumption, we know p at t and ¬p before t.
  But this gives no information about q at t.

So this ISN'T derivable either.

**But wait** -- the IRR rule is about what's PROVABLE, not what's semantically true.
And `G(q) → q` might not be provable from `p ∧ H(¬p)` in the proof system.

### Final Realization

**The contradiction IS in Step 2 above.**

Under CanonicalR(M, M):
- GContent(M) ⊆ M
- HContent(M) ⊆ M (derived)
- For ANY phi: `phi ∧ H(¬phi)` cannot be in M (because H(¬phi) ∈ M would give
  ¬phi ∈ M by HContent ⊆ M, contradicting phi ∈ M).

Now: by IRR, for any p and p-free phi, if `(p ∧ H(¬p)) → phi` is derivable,
then `phi` is a theorem, hence `phi ∈ M`.

**The question reduces to**: Is there ANY p-free formula phi such that
`(p ∧ H(¬p)) → phi` is derivable AND phi leads to contradiction with
CanonicalR(M, M)?

In principle, many useful formulas are derivable from `p ∧ H(¬p)`:
- `¬G(p)` is NOT p-free.
- `¬H(p)` IS derivable (from H(¬p) and consistency), but NOT p-free.
- `F(¬⊥)` is derivable even without IRR (seriality).

The challenge: all the "interesting" consequences of `p ∧ H(¬p)` seem to mention p.

**HOWEVER**: The contradiction I found in Step 2 doesn't actually need IRR at all!

## The Direct Proof (No IRR Needed!)

**Theorem**: `¬CanonicalR M M` for any MCS M.

**Proof**:
Assume `CanonicalR(M, M)`, i.e., `GContent(M) ⊆ M`.

1. By `GContent_subset_implies_HContent_reverse` (WitnessSeed.lean:324):
   `HContent(M) ⊆ M`.

2. Take the formula `neg bot` (which is `bot.imp bot`, i.e., ⊤).
   `neg bot ∈ M` (it's a theorem: `[] ⊢ bot.imp bot` by identity).

3. By temp_a: `neg bot → G(P(neg bot))`, so `G(P(neg bot)) ∈ M`.
   By GContent ⊆ M: `P(neg bot) ∈ M`.

   Actually this just says "there was a past time" = seriality past. Fine.

4. Consider the seriality PAST axiom: `P(neg bot) ∈ M`.
   `P(neg bot) = neg(all_past(neg(neg bot)))`.
   `neg(neg bot)` in MCS is equivalent to `bot` (double negation...).
   Wait: `neg(neg bot) = (bot.imp bot).imp bot = ⊤ → ⊥ = ¬⊤ = ⊥`.
   Actually `neg(neg bot) = (bot → bot) → bot`. And `bot → bot` is `⊤`.
   So `neg(neg bot) = ⊤ → ⊥ = ⊥`.
   So `P(neg bot) = neg(all_past ⊥) = all_past(⊥) → ⊥ = ¬H(⊥)`.
   And `H(⊥) = all_past bot`.

   `H(⊥)` in MCS: is `all_past bot` in M?
   If `all_past bot ∈ M`, then by HContent ⊆ M: `bot ∈ M`. Contradiction.
   So `all_past bot ∉ M`.
   So `¬(all_past bot) ∈ M`. That's `P(neg bot) ∈ M`. Fine.

5. **THE KEY**: Take the formula `atom "fresh_p"` for some specific atom.
   By MCS: either `atom "fresh_p" ∈ M` or `neg(atom "fresh_p") ∈ M`.

   **Subcase 5a**: `atom "fresh_p" ∈ M`.
   By past_temp_a: `atom "fresh_p" → H(F(atom "fresh_p"))`.
   So `H(F(atom "fresh_p")) ∈ M`.
   By HContent ⊆ M: `F(atom "fresh_p") ∈ M`.
   `F(atom "fresh_p") = neg(all_future(neg(atom "fresh_p")))`.

   **Subcase 5b**: `neg(atom "fresh_p") ∈ M`.
   Similarly: `H(F(neg(atom "fresh_p"))) ∈ M` and `F(neg(atom "fresh_p")) ∈ M`.

   In both cases, we get F-versions. No contradiction yet.

6. **THE ACTUAL KEY**: Use HContent ⊆ M directly.

   `H(neg(atom "fresh_p"))`: if this is in M, then by HContent ⊆ M,
   `neg(atom "fresh_p") ∈ M`.

   If `atom "fresh_p" ∈ M`: we need `H(neg(atom "fresh_p")) ∉ M` (otherwise
   `neg(atom "fresh_p") ∈ M`, contradicting consistency with `atom "fresh_p" ∈ M`).

   But `H(neg(atom "fresh_p")) ∉ M` is guaranteed by the forward analysis
   (Step 5 of forward analysis): if phi ∈ M, then H(¬phi) ∉ M.

   So no contradiction from a single atom.

**The fundamental issue**: Under CanonicalR(M, M), everything is self-consistent.
The only constraints are:
- phi ∈ M implies P(phi), F(phi) ∈ M.
- phi ∈ M implies G(¬phi), H(¬phi) ∉ M.

These constraints are all mutually consistent. No single formula choice gives ⊥.

**WAIT** -- I need to reconsider Step 2 more carefully.

Under CanonicalR(M, M) with HContent(M) ⊆ M:
`H(¬phi) ∈ M → ¬phi ∈ M`.

Combined with `phi ∈ M`:
If BOTH phi ∈ M and H(¬phi) ∈ M, then ¬phi ∈ M, contradiction.

But this isn't a contradiction with CanonicalR(M, M) itself -- it just constrains
which formulas can be together in M.

**The MCS M under CanonicalR(M, M) is the theory of a reflexive point.** It includes
all G(phi) → phi instances as derived rules (from GContent ⊆ M). This is exactly
the theory of a point that sees itself in the strict future.

**In temporal logic without IRR, such a point IS consistent!** A reflexive-future
point t where t < t satisfies all the axioms (density vacuously, seriality via
the reflexive loop, etc.).

**With IRR, such a point is inconsistent because the IRR rule adds theorems
that distinguish "now" from "future".**

BUT: as I showed, finding the specific phi derived from IRR that contradicts
GContent ⊆ M is non-trivial.

## Key Lemmas Found

### In the codebase:

1. `GContent_subset_implies_HContent_reverse` (WitnessSeed.lean:324)
   ```
   GContent M ⊆ M' → HContent M' ⊆ M
   ```
   (Specialized to M = M': GContent(M) ⊆ M → HContent(M) ⊆ M)

2. `set_mcs_implication_property` (MCSProperties.lean:150)
   ```
   (φ.imp ψ) ∈ S → φ ∈ S → ψ ∈ S
   ```

3. `set_mcs_negation_complete` (MCSProperties.lean:174)
   ```
   φ ∈ S ∨ (neg φ) ∈ S
   ```

4. `set_consistent_not_both` (MCSProperties.lean:331)
   ```
   phi ∈ S → phi.neg ∈ S → False
   ```

5. `theorem_in_mcs` (MaximalConsistent.lean:482)
   ```
   [] ⊢ φ → φ ∈ S
   ```

6. `temp_a` axiom: `φ → G(P(φ))`
7. `past_temp_a` (WitnessSeed.lean:312): `φ → H(F(φ))`
8. `density` axiom: `F(φ) → F(F(φ))`
9. `seriality_future` axiom: `F(¬⊥)`
10. `seriality_past` axiom: `P(¬⊥)`
11. `irr` rule: from `(p ∧ H(¬p)) → phi` (p-free phi) derive phi

## Recommended Approach

### Approach 1: Direct Contradiction (High Confidence, if it works)

The forward analysis showed: under CanonicalR(M, M):
- GContent(M) ⊆ M
- HContent(M) ⊆ M
- phi ∈ M implies H(¬phi) ∉ M

Attempt to find a specific formula phi where this chain leads to ⊥.

**Challenge**: As analyzed, the constraints are self-consistent without IRR.

### Approach 2: IRR-Based Theorem (Medium-High Confidence)

Use IRR to derive a p-free formula `phi` such that `phi ∈ M` contradicts
`GContent(M) ⊆ M`.

The MOST PROMISING candidate: derive via IRR that
```
G(psi) → psi
```
for some SPECIFIC p-free psi.

**Specifically**: set `psi = ⊥` and get `G(⊥) → ⊥`. Then `G(⊥) → ⊥ ∈ M`
means `G(⊥) ∉ M` (by MCS properties). This is already derivable from seriality
without IRR, so it doesn't help.

**Better**: set psi to a formula that WOULD be in GContent(M) but NOT in M.

This requires finding psi such that G(psi) ∈ M (from the MCS axiom closure)
but the IRR-derived `G(psi) → psi` combined with `G(psi) ∈ M` gives `psi ∈ M`,
which would need to contradict something...

Actually, if `G(psi) → psi` is a theorem, then it's in M. If G(psi) ∈ M,
then psi ∈ M (by MP). This is exactly what CanonicalR(M, M) already gives!
So no new information.

### Approach 3: Encoding-Level Argument (Speculative)

The density and discreteness axioms being BOTH present in the derivation tree
may already make the system inconsistent, in which case no MCS exists and
the theorem is vacuously true.

**Check**: Does having both `Fφ → FFφ` (density) and
`(F⊤ ∧ φ ∧ Hφ) → F(Hφ)` (discreteness) derive ⊥?

If so, the theorem is trivially provable:
```
theorem canonicalR_irreflexive (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ¬CanonicalR M M := by
  intro h_R
  -- Derive ⊥ from the inconsistent axiom system
  have h_bot : Formula.bot ∈ M := theorem_in_mcs h_mcs inconsistency_proof
  exact set_consistent_not_both h_mcs.1 ...
```

This needs investigation.

### Approach 4: Product Domain Bulldozing (Alternative)

As mentioned in RestrictedFragment.lean:443 and the Phase 6 handoff:
use a product domain T x Q construction that eliminates reflexive points by fiat.
This avoids the irreflexivity proof entirely but requires restructuring.

## Confidence Level

**Medium-Low** with justification:

1. The direct axiom approach (no IRR) CANNOT work -- the axioms without IRR
   are consistent with reflexive frames.

2. The IRR-based approach is theoretically sound (Gabbay 1981) but the specific
   derivation required is non-trivial. The main challenge is finding a p-free
   formula phi such that:
   (a) `(p ∧ H(¬p)) → phi` is derivable, and
   (b) `phi ∈ M` contradicts `GContent(M) ⊆ M`.

3. The system consistency question (density + discreteness coexistence) could
   provide a simpler path but needs investigation.

4. The encoding of negation (double negation in `F` and `some_future`) creates
   technical complications that require careful handling with DNE theorems.

## Open Questions

1. **Is the full axiom system (with both density and discreteness_forward) consistent?**
   If not, the irreflexivity theorem is vacuously true and trivially provable.

2. **Can the IRR rule derive `G(phi) → phi` for any specific phi (with p fresh)?**
   This would directly contradict GContent ⊆ M if G(phi) ∈ M but phi ∉ M.

3. **Is there a formula phi such that G(phi) is derivable but phi is not?**
   Such a formula, if it exists, would give the contradiction directly.

4. **Can the proof use the semantic soundness of IRR (irr_sound_dense_at_domain)
   in a meta-argument?** I.e., argue that IF CanonicalR(M,M) then the canonical
   model has a reflexive point, contradicting IRR soundness on irreflexive frames.
   This would be a proof-by-soundness argument rather than a direct syntactic argument.
