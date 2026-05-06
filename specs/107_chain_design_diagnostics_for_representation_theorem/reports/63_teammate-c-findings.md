# Teammate C: Critic — Gap Analysis of Proposed Solutions

## Summary

Seven critical questions were investigated. Four expose genuine blockers in the proposed
guard-in-B plan. One (Question 1) reveals a factual misread of Burgess 2.4 that partially
undermines the plan's premise. Two others (Questions 5–6) expose the deepest unresolved
obligations: guard propagation across elimination steps and limit-level transfer.

---

## Finding 1 (CRITICAL): Burgess 2.4 — β is in B, NOT γ

The guard-in-B handoff claims we want "guard ∈ B" and appeals to Burgess 2.4. But the
Burgess 2.4 statement (p.371) is:

> "Let A be an MCS and suppose U(γ, β) ∈ A. Then there exist B, C such that β ∈ B,
> γ ∈ C, and R(A, B, C) holds."

In Burgess notation, U(γ, β) has γ as the guard (holds at intermediate points) and β as
the event (holds at the far endpoint). The intervals contain β (the event), not γ (the
guard). Burgess puts β ∈ B and γ ∈ C.

Our convention SWAPS the arguments: `untl(guard=φ, event=ψ)` = Burgess U(event=ξ, guard=η).
So Burgess β = our guard (φ), and Burgess γ = our event (ψ). Therefore:

- Burgess β ∈ B means our **guard ∈ B** ← THIS IS what the handoff wants
- Burgess γ ∈ C means our **event ∈ C** ← This is what `lemma_2_4` already gives

**Conclusion**: The claimed "guard ∈ B" target IS actually what Burgess 2.4 guarantees —
but our current `lemma_2_4` implementation does NOT achieve it. The implementation seeds B
with `DC({top})` using `burgessR3Maximal_from_g_content_sub`, which uses ⊤ as the seed
formula, NOT the guard formula. So the bug is real: `lemma_2_4` fails to follow Burgess's
construction that seeds B with DC({β}) = DC({our guard}).

This is a factual gap between the code and Burgess. The proposed fix (modify lemma_2_4 to
use the guard as seed) is in the right direction, but Phase 2 of the plan must be executed.

---

## Finding 2 (CRITICAL): burgessR(A, guard, C) Cannot Be Established Cheaply

The plan says: "After constructing C from enriched seed, get `burgessR(A, guard, C)` from
`burgessRSince_implies_burgessR` (the converse of Lemma 2.3)."

This is **backwards**. Lemma 2.3 says: (a) ∀γ ∈ C, U(γ, β) ∈ A  ↔  (b) ∀α ∈ A, S(α, β) ∈ C.

In our convention, β is the guard (our first argument). So:
- (a) = `burgessR(A, guard, C)`: ∀δ ∈ C, untl(guard, δ) ∈ A
- (b) = `burgessRSince(C, guard, A)`: ∀α ∈ A, snce(guard, α) ∈ C

The equivalence holds, so if we seed C₀ with `{snce(guard, α) : α ∈ A}`, then
`burgessRSince(C, guard, A)` holds for any C extending C₀ (since the seed members are in
C₀ ⊆ C). And by Lemma 2.3, this gives `burgessR(A, guard, C)`.

**BUT WAIT**: Does every Lindenbaum extension C of C₀ preserve all seed members? Yes —
the Lindenbaum extension takes the seed as a subset: the `h_sup` hypothesis in the current
`lemma_2_4` proof is exactly `C₀ ⊆ C`. So `snce(guard, α) ∈ C₀ ⊆ C` for all α ∈ A.

**Conclusion**: The direction burgessRSince → burgessR IS valid here (Lemma 2.3 is an
equivalence), but only because the Lindenbaum extension is guaranteed to contain the seed.
The plan's labeling "burgessRSince_implies_burgessR (the converse direction)" is confused:
it IS the forward direction of 2.3 (the proof that (b) → (a) in Lemma 2.3). Burgess proves
(a) → (b); the reverse (b) → (a) is a separate proof in Section 2.3. The code needs this
reverse direction. Check whether `burgessRSince_implies_burgessR` exists in RRelation.lean
(it's named in the handoff but not confirmed present). If absent, it must be proved.

---

## Finding 3 (CRITICAL): Enriched Seed Consistency Requires Careful Argument

The enriched seed is `C₀ = {ψ} ∪ g_content(A) ∪ {snce(guard, α) : α ∈ A}` where
`untl(guard, ψ) ∈ A` (our convention: guard first, event second).

The handoff claims consistency by iterated BX13 enrichment. Let us verify.

BX13 (A3a in Burgess) is: `p ∧ U(q, r) → U(q ∧ S(p, r), r)`.

In our convention: `p ∧ untl(q, r) → untl(q ∧ snce(p, r), r)`.

The original `lemma_2_4` seeds with `{ψ} ∪ g_content(A)` and proves consistency by:
- `until_witness_seed_consistent` which gives `F(ψ) ∈ A`, hence consistency of `{ψ}`
  (actually via `forward_temporal_witness_seed_consistent`)

For the enriched seed, we also need finite subsets containing `snce(guard, α_i)` to be
consistent. Burgess's own proof at 2.4 (p.371) handles this:

> "... it suffices to show that any particular formula γ ∧ S(α, β) with α ∈ A is
> consistent. But when α ∈ A, since U(γ, β) ∈ A by hypothesis, A3a yields
> U(γ ∧ S(α, β), β) ∈ A, whence 2.2 yields the consistency of γ ∧ S(α, β)."

In our convention (guard first): U(γ, β) = untl(guard, ψ). Burgess β = our guard, Burgess γ = our event. So the formula "γ ∧ S(α, β)" in Burgess = "ψ ∧ snce(α, guard)" in our system (where α ∈ A is quantified and guard = Burgess β).

**Wait**: Burgess writes "γ ∧ S(α, β)" where β = guard (our) and γ = event (our). With our
convention mapping: S(α, β) in Burgess = snce(α, guard) in ours, and γ in Burgess = ψ (event)
in ours. So the consistency target is `ψ ∧ snce(α, guard)`, which Burgess gets from A3a
applied to U(γ, β) = untl(guard, ψ) ∈ A.

This is exactly BX13 applied once. The iterated case (multiple snce terms) follows by
repeated BX13 application combined with conjunction. The infrastructure `iterated_enrichment`
at PointInsertion.lean line ~1388 should handle this.

**Key gap**: The plan says this "mirrors forward_temporal_witness_seed_consistent but with
BX13 enrichment folded in." But forward_temporal_witness_seed_consistent proves consistency
of `{ψ} ∪ g_content(A)` via `F(ψ) ∈ A`. The new enriched seed includes `snce(guard, α_i)`.
The combined set `{ψ, snce(guard, α_1), ..., snce(guard, α_n)}` needs consistency via
`untl(guard ∧ snce(guard, α_1) ∧ ... ∧ snce(guard, α_n), ψ) ∈ A` (from Burgess's 2.4
argument), which requires iterated BX13. The g_content terms fold in via g_content ⊆ C
(inherited from the original seed). Overall, the enriched seed consistency IS provable but
requires a new lemma (call it `until_witness_enriched_seed_consistent`), not just a small
modification to the existing proof.

---

## Finding 4 (MAJOR): burgessR3Maximal_with_guard Preconditions Are Not Automatically Met

The theorem `burgessR3Maximal_with_guard` requires BOTH:
1. `burgessR(A, guard, C)`: ∀δ ∈ C, untl(guard, δ) ∈ A
2. `burgessRSince(C, guard, A)`: ∀α ∈ A, snce(guard, α) ∈ C

For the C constructed from enriched seed C₀, (2) is satisfied from seed membership.
For (1), we use Lemma 2.3 equivalence: since (2) holds, so does (1).

BUT: `burgessR3Maximal_with_guard` also requires `NoUnivBurgessR3`. The current callers of
`lemma_2_4` already thread through `h_nubr3 : NoUnivBurgessR3`, so this parameter is
available. No new parameter is needed.

**However**: The plan's Phase 2 says to add `gamma in B` to the output of `lemma_2_4`. The
correct implementation via `burgessR3Maximal_with_guard` returns `∃ B, guard ∈ B ∧ R(A,B,C)`.
But the current `lemma_2_4` returns `∃ B C, ... BurgessR3Maximal A B C`. Changing the
output type to include `guard ∈ B` is safe but requires:
- The seed formula for B becomes `DC({guard})` (via `burgessR3Maximal_with_guard`)
- The C is constructed from the enriched seed (new C₀ with snce terms)
- Both B and C are constructed in a coordinated manner

This is a non-trivial refactor of `lemma_2_4`. The plan's Phase 2 estimate of this work is
probably accurate (~3-4 hours), but the caller update in Phase 3 is also non-trivial since
5 elimination callsites must be updated.

---

## Finding 5 (CRITICAL BLOCKER): Guard Propagation Through Elimination Steps is Unproved

Even if guard ∈ B at the n=0 case (C5 forward, no intermediate points), the plan's
Option A (structural) for Phase 4 claims:

> "When y is inserted between t and s, Lemma 2.5 absorption gives B = B' ∩ D ∩ B'',
> so B ⊆ D, hence guard ∈ D = f(y)"

This uses Burgess Lemma 2.5. Let's verify: Lemma 2.5 says if R(A,B,C), r(A,B',D),
r(D,B'',C), and B ⊆ B' ∩ D ∩ B'', then B = B' ∩ D ∩ B''. This gives B ⊆ D.

But in our code, when a density point z is inserted between x and y (where R(f(x), B, f(y))
held originally), the splitting lemma (Lemma 2.6) gives B', D, B'' with:
- R(f(x), B', f(z)), R(f(z), B'', f(y))
- B = B' ∩ f(z) ∩ B'' (by Lemma 2.5)

So B ⊆ f(z), hence guard ∈ f(z) when guard ∈ B. This works for density insertions!

For C4 insertions: When ¬U(γ,δ) ∈ f(x) and γ ∈ f(y), a z is inserted with ¬δ ∈ f(z).
Burgess 2.9 uses Lemma 2.6 splitting of B = g(x,y) at the PAIR (x,x') not (x,y). The
split gives D = f(z) (new point) and R(f(x), B', D), R(D, B'', f(x')). Does guard end up
in D = f(z)?

The C4 splitting (Lemma 2.6) only guarantees ¬δ ∈ D and that D is MCS. Guard ∈ B does NOT
directly imply guard ∈ D (since D = f(z) is chosen from a different seed).

**Critical failure**: Guard propagation through C4/C4' eliminations is NOT guaranteed by
Lemma 2.5 absorption. The C4 splitting inserts z between x and x' (immediate successor),
not between x and y. The new f(z) = D comes from Lemma 2.6 applied to g(x,x') — and
guard ∈ g(x,x') only if guard was in B AND g(x,x') = B (which requires (x,x') to be the
immediately adjacent pair created by the C5 witness). If there were intermediate domain
points between x and the C5 witness y at the time the C5 was established, guard ∈ g(x,x')
must be derived from B ⊆ g(x,x') (C3 direction), which requires a separate argument.

In fact, C3 says g(x,y) = g(x,x') ∩ f(x') ∩ g(x',y) for all x' between x and y. If
guard ∈ g(x,y) = B, then guard ∈ g(x,x') (since B ⊆ g(x,x') by the intersection). But
wait: C3 in the Burgess construction is a derived property of the CURRENT g function, and
it holds at each stage. So if guard ∈ g_n(x,y) at stage n, then by C3 at stage n, we have
guard ∈ g_n(x, x') for any x' ∈ dom_n between x and y.

Then when x' is used as the base for Lemma 2.6 splitting, guard is in g_n(x', ...) as well
(by C3 again). This chain of C3 applications propagates guard through the splitting tree.

**BUT**: Is C3 actually maintained as an invariant in the omega chain formalization? Reading
`omega_chain_c3` (if it exists) is essential. The `guard-expose-final.md` handoff explicitly
states: "C3 is NOT maintained as an invariant at finite stages (only C0 and C2' are tracked)."

This is the deepest gap: if C3 is not an invariant of the finite omega chain stages, then
guard propagation via Lemma 2.5 is not available. The plan's Phase 4 Option A assumes C3
is maintained, but the code does not track it.

---

## Finding 6 (CRITICAL BLOCKER): Limit-Level Transfer Requires C3 at Limit

The `limit_g` definition is:
```
limit_g(x,y) = {φ | ∀ w ∈ limit_dom, x < w < y → φ ∈ limit_f(w)}
```

`limit_c3` IS proved in ChronicleConstruction.lean (lines 862-879) — this is a trivial
consequence of the definition (it's definitionally true for the limit_g construction).

But the key question is: if guard ∈ g_n(x,y) at stage n (from the C5 elimination), does
guard ∈ limit_g(x,y)?

By the definition of limit_g, this requires: for ALL w ∈ limit_dom with x < w < y, guard ∈
limit_f(w). A point w ∈ limit_dom means w ∈ dom_m for some m. The question is whether
guard ∈ limit_f(w) = f_m(w) (by limit_f_eq for some m ≥ m₀).

For w that ALREADY existed in dom_n (when the C5 witness was established), guard ∈ f_n(w)
requires either (a) guard ∈ f_n(w) directly (from C3 at stage n) or (b) guard ∈ g_n(x,y)
plus C3 at stage n.

For w added AFTER stage n (new density/C4 insertions at stages > n), guard ∈ f_m(w) must
come from the fact that f(w) is determined by Lemma 2.6 splitting of g(x', x'') where
x' < w < x''. If guard ∈ g(x', x'') at the time of splitting, then guard ∈ f(w) = D
(by Lemma 2.5: B ⊆ D where B = g(x',x'')).

So the key chain is:
1. guard ∈ B = g_n(x, y) at stage n (the C5 witness stage)
2. For all future stages m > n where a point w ∈ (x,y) is added: guard ∈ g_m(x, w_nearest)
3. By Lemma 2.5: guard ∈ f_m(w) for newly inserted w

Steps 2 and 3 require that guard persists in ALL g-values g_m(x', y') for (x', y') that
are sub-intervals of (x, y) at each stage m. This is exactly the invariant that C3 would
give if maintained — but the formalization does NOT maintain C3 as a tracked invariant.

**Conclusion**: The limit-level transfer works IF AND ONLY IF C3 is maintained through all
elimination steps. Since it is not currently tracked, a new invariant must be added to the
omega chain, or the `limit_g` approach must be replaced by tracking the Burgess g-function
separately (as "Option D" from guard-expose-final.md suggests).

---

## Finding 7: Phase 6 (FUC/FSC) in the Implementation Plan is Stale and Understated

The current `plans/62_implementation-plan.md` Phase 6 (FUC/FSC) states:

> "Prove `limit_satisfies_c5_full` in ChronicleConstruction.lean — the strengthened C5 with
> guard at intermediate points. Uses c2' invariant (now proved) and C3 at the limit."

This understates the difficulty by assuming C3 at the limit is directly usable. The actual
dependency chain is:

1. Modify `lemma_2_4` to produce `guard ∈ B` (Phase 2 in guard-in-B plan)
2. Update all 5 c2' construction sites in `eliminate_potential_counterexample` to wire
   guard ∈ B → guard ∈ g(t,s) (Phase 3)
3. Prove a new invariant: ∀ n, ∀ x < y in dom_n, if guard was in the original B at the
   C5 witness step, then guard ∈ g_n(x', y') for all x < x' ≤ y' < y sub-intervals at
   stage n (this requires tracking the guard across all splitting steps — approximately
   200-400 new lines as estimated in guard-expose-final.md)
4. Prove guard ∈ limit_g(t,s) from the stage-n invariant (requires C3 at all finite stages)
5. Use `limit_c3_interval_subset_point` (already proved) to extract guard ∈ limit_f(r)

Steps 3 and 4 are essentially unplanned in the current Phase 6 description and are the
hardest part of the entire proof.

---

## Recommended Approach

The guard-in-B plan (handoff: guard-in-B.md) is on the right track but incomplete. The
correct implementation order is:

**Step 0 (Prerequisite)**: Verify whether `burgessRSince_implies_burgessR` exists in
RRelation.lean. If absent, add this direction of Lemma 2.3 (the (b)→(a) direction).

**Step 1**: Prove `until_witness_enriched_seed_consistent`: consistency of
`{ψ} ∪ g_content(A) ∪ {snce(guard, α) : α ∈ A}` given `untl(guard, ψ) ∈ A`. Uses iterated
BX13 following Burgess 2.4 proof exactly.

**Step 2**: Modify `lemma_2_4` to:
- Construct C from the enriched seed
- Derive `burgessRSince(C, guard, A)` from seed membership
- Derive `burgessR(A, guard, C)` via Lemma 2.3 equivalence
- Apply `burgessR3Maximal_with_guard` to get guard ∈ B
- Output type includes `guard ∈ B`

**Step 3**: Update the 5 callers in `eliminate_potential_counterexample`. For C5 forward
(both n=0 and Walk Case A), the new B has guard ∈ B. The key is to also expose guard ∈ B
through the c2' invariant.

**Step 4**: Add a new invariant to ChronicleConstruction.lean:
```
omega_chain_c5_guard_inv(n) :=
  ∀ (x y : Rat) (guard : Formula),
    x ∈ dom_n ∧ y ∈ dom_n ∧ x < y ∧ (x,y) is a C5 witness pair from stage ≤ n →
    guard was the guard formula for this witness →
    ∀ w ∈ dom_n, x < w < y → guard ∈ f_n(w)
```
Prove this invariant is maintained across elimination steps, using Lemma 2.5 (B ⊆ D) at
each splitting step — which requires C3 at finite stages, or at minimum, that guard is in
all g-values g_n(x', y') for sub-intervals.

**Step 5**: Close FUC/FSC using this invariant + limit_dom density to transfer to limit_f.

**Alternative (Option D from guard-expose-final.md)**: Track the Burgess g-function
separately via `omega_chain_g_agrees` lemmas, prove `limit_g_burgess ⊆ limit_g`, and use
this to establish guard membership. This avoids modifying the omega chain invariants but
requires new infrastructure (~200-400 lines).

---

## Evidence/Examples

**Burgess 2.4 text** (verbatim, p.371): "Let B be maximal with respect to the properties
that β ∈ B and r(A, B, C)." Here β = our guard (first argument of untl in our convention).
The paper has guard ∈ B explicitly.

**lemma_2_4 code** (PointInsertion.lean:158-180): Seeds B with `top` via
`burgessR3Maximal_from_g_content_sub`. No reference to the guard formula. This is the
implementation gap.

**limit_g definition** (ChronicleConstruction.lean:845-849): The definitional form
`{φ | ∀ y ∈ limit_dom, x < y → y < z → φ ∈ limit_f(y)}` means guard ∈ limit_g(x,y)
requires guard ∈ limit_f(w) for EVERY intermediate w — including all future insertions.

**guard-expose-final.md explicit statement**: "C3 is NOT maintained as an invariant at
finite stages (only C0 and C2' are tracked)." This directly confirms Finding 5.

---

## Confidence Level

- Finding 1 (Burgess 2.4 mapping): **high** — verified against the paper text
- Finding 2 (burgessR direction): **high** — straightforward logical analysis
- Finding 3 (enriched seed consistency): **high** — follows Burgess's proof exactly
- Finding 4 (Phase 2 refactor scope): **high** — clear from the code structure
- Finding 5 (C3 not invariant): **high** — explicitly confirmed by guard-expose-final.md
- Finding 6 (limit transfer): **high** — follows from Finding 5 + limit_g definition
- Finding 7 (Phase 6 understated): **high** — clear from comparing plan text to actual dependency chain
