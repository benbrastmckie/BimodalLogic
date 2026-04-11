# Task 98 Round 4 — Teammate C (Critic): Phase 4 Architectural Gap Interrogation

- **Task**: 98 — research_filtration_quasimodel_pivot
- **Round**: 4 (post-Phase 4 partial)
- **Artifact**: 08_teammate-c-findings.md
- **Role**: Critic
- **Session**: sess_1775873649_08b347
- **Date**: 2026-04-10
- **Scope**: read-only; building on prior round-3 critic angle (locus-control)

---

## TL;DR

The gap documented in `07_phase4-summary.md` is **real**, but its framing conceals
a second, more fundamental error. Teammate A's §3.3 reduction has **two**
unstated assumptions, not one:

1. **Assumption A (the one flagged)**: `G(¬ (bigconj L_h)) ∈ Sigma` for every
   finite `L_h ⊆ h_{i+1}.formulas`. This is what `EnrichedClosure` intends to
   fix, and does fix for `L_h ⊆ SubformulaClosure target` — but NOT for
   `L_h ⊆ enrichedClosure target` (see §2 below for the subtlety).

2. **Assumption B (NOT flagged anywhere)**: The final contradiction step
   "`L_h ⊆ h_{i+1}.formulas` and `¬(bigconj L_h) ∈ h_{i+1}.formulas` gives
   ⊥" requires `bigconj L_h ∈ h_{i+1}.formulas`. But **`HintikkaPoint` is NOT
   closed under conjunction introduction at the set level**. `locally_consistent`
   is pairwise (`f ∈ formulas → ¬f ∉ formulas`); it does not give us
   "a conjunction of members is a member". This is exactly the same shape of
   error that blocked the "Option 2" direction and it reappears here.

Because of Assumption B, **all three options documented in the summary fail
for the same structural reason** unless a separate `bigconj_mem_hintikka`
lemma is proved — and that lemma **does not hold** for arbitrary
`HintikkaPoint`s. It only holds for `sigma_signature` of an MCS, because
MCSs are derivation-closed.

Confidence: **Medium-High** that the current framing is broken; **High**
that the fix (thread the "h_{i+1} = sigma_signature v_{i+1}" equality back
to the MCS level) is the only sound path; **Low** on the effort estimate.

---

## 1. Verification of Prior Claims Against the Actual Code

I read the following files directly (not via intermediate summaries):

- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/HintikkaPoint.lean` (full, 167 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` (lines 40-110, 240-620 selectively)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/EnrichedClosure.lean` (lines 1-120)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` (lines 1-200, 360-492)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/LocusControl.lean` (full, 96 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` lines 79-115 (`g_content_closed_derivation`)
- `Theories/Bimodal/Syntax/BigConj.lean` (selective — confirmed `bigconj [] = ¬⊥`)
- Plan v3 (`03_quasimodel-pivot-plan.md`, full)
- `07_phase4-summary.md` and `03_teammate-a-findings.md` (full)

### 1.1 `HintikkaPoint` structure fields (confirmed)

```
structure HintikkaPoint (Sigma : Finset Formula) where
  formulas          : Finset Formula
  subset_sigma      : formulas ⊆ Sigma
  locally_consistent: ∀ f ∈ formulas, Formula.neg f ∉ formulas
  bot_free          : Formula.bot ∉ formulas
  locally_maximal   : ∀ f ∈ Sigma, f ∈ formulas ∨ Formula.neg f ∈ formulas
```

There is **no derivation-consistency field**, no closure under classical
reasoning, no closure under any conjunction/disjunction introduction rule,
and no membership-implication-closure (modus ponens at the set level). The
summary's claim that `locally_consistent` is pairwise is correct. What the
summary does NOT note is that the contradiction the reduction needs is
**not derivable from `locally_consistent` alone** even if you had `bigconj L_h`
and `¬(bigconj L_h)` both in `h_{i+1}.formulas`, **unless `bigconj L_h` itself
is in the HintikkaPoint**. That is where the second hidden premise lives.

### 1.2 `hintikka_step` clauses (confirmed, Construction.lean:45-52)

Three clauses: G-propagation, H-backward, and Until-defect propagation.
Notably, **none of these three clauses mention conjunctions, disjunctions, or
implications**. A `hintikka_step` does NOT propagate classical reasoning —
it only propagates exactly the three kinds of formulas listed. So even if
we had `G(¬(bigconj L_h)) ∈ h_i.formulas`, we would only get
`¬(bigconj L_h) ∈ h_{i+1}.formulas`, nothing more. This is sound for
Teammate A's step, but reinforces that `h_{i+1}` is extremely weak — it is
an "unclosed" classical fragment of Sigma.

### 1.3 `g_content_closed_derivation` signature (Frame.lean:79)

```
theorem g_content_closed_derivation {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (L : List Formula) (h_sub : ∀ ψ ∈ L, ψ ∈ g_content S)
    (h_deriv : DerivationTree L φ) : Formula.all_future φ ∈ S
```

Note: this outputs `G(φ) ∈ S` (where S is the MCS). It **does not** output
anything about `S`'s Sigma-signature. So to land `G(¬(bigconj L_h))` in
`h_i = sigma_signature v_i`, we additionally need `G(¬(bigconj L_h)) ∈ Sigma`
(which is what `EnrichedClosure` provides). Confirmed.

### 1.4 `EnrichedClosure` coverage (EnrichedClosure.lean:101-109)

```
theorem enriched_g_neg_bigconj_mem {target : Formula}
    {T : Finset Formula} (hT : T ⊆ SubformulaClosure target) :
    Formula.all_future (neg_bigconj T.toList) ∈ enrichedClosure target
```

**Critical observation**: the hypothesis is `T ⊆ SubformulaClosure target`,
**not** `T ⊆ enrichedClosure target`. This is a significant restriction.
Whether it's the right one is addressed in §2.1.

### 1.5 `bigconj []` base case (Syntax/BigConj.lean:39)

`bigconj [] = Formula.bot.neg = ¬⊥` (i.e. ⊤). This produces an edge case
the summary does not discuss: if `L_h = []` (the empty subset of
`h_{i+1}.formulas`), then `bigconj L_h = ¬⊥`, `neg_bigconj L_h = ¬¬⊥ = ⊥`
(syntactically `Formula.neg (Formula.neg Formula.bot)`), and
`G(¬¬⊥) ∈ Sigma` is needed. This case cannot arise in a non-trivial
inconsistency (the empty list derives ⊥ only if ⊢ ⊥, which is impossible),
but the proof of `chain_step_seed_consistent` as sketched needs to
handle `L_h = []` cleanly to discharge the degenerate case. Minor, but
not zero cost.

---

## 2. Gaps & Blind Spots in Each Option

### 2.1 Option 1 — Strengthen `HintikkaPoint` with derivation-consistency

**Proposed**: add a field
`∀ L ⊆ formulas.toList, ¬(L ⊢ Formula.bot)` to `HintikkaPoint`.

**Fatal flaw already noted**: this cannot be imposed in general; `sigma_signature`
of an arbitrary BXPoint satisfies it, but the abstract `hintikka_step` chain
construction in Phase 3 produces `HintikkaPoint`s that are **not** backed by
any MCS. Phase 3's `hintikka_chain_exists` delivers Hintikka points built
by well-founded recursion on `defect_count`, not by projection from BXPoints.

**Unmentioned additional flaw**: even if we added this field, the chain-step
consistency proof's final step would still need `bigconj L_h ∈ h_{i+1}.formulas`.
A derivation-consistency field would NOT give us that — it would give us
`¬ (bigconj L_h :: L_h ⊢ Formula.bot)`, which is vacuously true (any list
containing both `P` and `¬P` derives ⊥ — but the question is whether such
`P` is in `formulas` at all). The problem re-appears: the witness `bigconj L_h`
is not a member, only "derivable from L_h".

**Option 1 is dead** and worse, the summary underestimates why — it's not
just cascade risk, it's that the strengthened field would still not close
the proof.

### 2.2 Option 2 — Prove derivation-consistency from existing fields via compactness

**Proposed**: `locally_consistent + locally_maximal + locally_saturated →
derivation-consistent`.

**This cannot work for abstract `HintikkaPoint`s.** Proof sketch of why:

Consider a `HintikkaPoint Sigma` whose `formulas` is `{p, q, r}` where
`Sigma = {p, q, r, ¬p, ¬q, ¬r}` and the closure is otherwise empty. Suppose
classically `⊢ ¬(p ∧ q ∧ r)` (we can engineer such p, q, r as long as the
target formula forces it). Then `{p, q, r} ⊢ ⊥` at the derivation level,
but `locally_consistent` still holds (no `f, ¬f` pair is in `{p,q,r}`), and
`locally_maximal` still holds (each of p, q, r ∈ Sigma has one direction in
`formulas`). The `HintikkaPoint` constructor would accept this structure,
but it is derivation-inconsistent.

The only thing that would rule out such a structure is some form of
**classical closure** that lives outside the pairwise `locally_consistent`
axiom. Option 2 as stated does not provide this. It would need an
additional axiom like "for every `L ⊆ formulas` with `L ⊢ φ` and
`φ ∈ Sigma`, we have `φ ∈ formulas`" — which is essentially the
**derivation-closure** property that makes a point an MCS projection.
Adding this axiom is identical to Option 1 and has the same fatal flaw.

**Edge cases the summary does not consider**:
- Empty `L_h`: as noted, `bigconj [] = ¬⊥`, `neg_bigconj [] = ¬¬⊥`. The
  case splits asymmetrically.
- `L_h` containing non-atomic formulas (e.g., `p ∧ q`): Hintikka points
  are not required to contain component subformulas of compound members,
  so `p ∧ q ∈ formulas` does not imply `p ∈ formulas` or `q ∈ formulas`.
  The EnrichedClosure does not impose such "positive" closure.

**Option 2 is structurally unsound.**

### 2.3 Option 3 — Direct BXPoint chain bypassing Hintikka seeds

**Proposed**: build a `BXUntilChain` with BXPoint-level forward steps using
`bx_forward_witness`, then project to Hintikka chain via `sigma_signature`
at the end.

**This is the only option that can work**, but the summary's sketch has
its own gaps:

1. **The "guard" problem reappears at the BX level.** `bx_forward_witness`
   on `F(ψ) ∈ v_i` produces a `v_{i+1}` with `ψ ∈ v_{i+1}`, but NOT with
   `φ ∈ v_{i+1}` (which is what the guard condition in Frame.lean:653
   demands for `u` strictly between `w` and `v`). The summary says BX5's
   self-accumulation `(φ ∧ (φ U ψ)) U ψ` carries the guard forward, but
   this only works if we apply BX5 BEFORE extracting the witness — the
   sequence `{φ U ψ ∈ v_i} → {(φ ∧ (φ U ψ)) U ψ ∈ v_i}` (by BX5/BX6), then
   `bx_forward_witness` applied to `F(ψ) ∈ v_i` gives `v_{i+1}` with
   `ψ ∈ v_{i+1}`, and separately `φ ∈ v_{i+1}` via the intermediate MCS
   closure? **This does not follow.** `bx_forward_witness` only promises
   what's in the seed. To get `φ ∈ v_{i+1}` you must include `φ` in the
   Lindenbaum seed, which again requires proving the seed
   `{φ, ψ} ∪ g_content(v_i)` is consistent — exactly the same consistency
   obligation the Hintikka route faces, except now with `{φ, ψ}` instead
   of `h_{i+1}.formulas` (smaller, but not automatically consistent).

2. **The "intermediate point" locus-control gap.** Even if option 3 builds
   a chain `v_0 → ... → v_k` with `ψ ∈ v_k`, the Frame.lean:653 target
   requires `φ ∈ u` for **arbitrary** `u` with `bx_le w u ∧ bx_le u v ∧
   ¬bx_le v u`. A constructed BX chain `v_0, ..., v_k` does not give us
   control over arbitrary intermediates `u` — only the specific chain
   points. This is exactly the locus-control exhaustiveness gap identified
   in round-3 teammate C (§Q3, Q5). Option 3 does NOT solve this; it only
   relocates it. **In fact, option 3 is arguably worse for locus-control**
   than the Hintikka-chain approach, because the Hintikka chain is
   finite-and-exhaustive (any `HintikkaPoint` reachable within Sigma is
   in the chain if the chain is built right), whereas a BX chain built by
   `bx_forward_witness` is a specific path, not all paths.

3. **Projection to Hintikka requires `sigma_signature_mem` to be an
   equality-level round-trip.** The summary asserts this but the Lean
   surface only provides an **iff** characterization
   (`sigma_signature_mem : f ∈ (sigma_signature w Sigma h_neg).formulas ↔
   f ∈ Sigma ∧ f ∈ w.formulas`). The chain construction needs
   `sigma_signature v_{i+1} Sigma = h_{i+1}` as an **equality of
   HintikkaPoints**, which by `HintikkaPoint.ext` reduces to equality of
   `.formulas`. That equality is NOT free — it requires that the
   Lindenbaum extension producing `v_{i+1}` does not pick up any
   Sigma-formulas beyond those in `h_{i+1}`. This is provable via
   `locally_maximal` on `h_{i+1}` only if we know `h_{i+1}` already
   decided every `f ∈ Sigma`. This holds for HintikkaPoints, but the
   argument requires a distinct lemma that is not in tree.

4. **The `hintikka_step` projection step is where Assumption B reappears.**
   When we project a BX chain `v_i → v_{i+1}` to
   `sigma_signature v_i → sigma_signature v_{i+1}`, we must prove
   `hintikka_step (sigma_signature v_i) (sigma_signature v_{i+1})`. The
   G-propagation clause holds iff `bx_le v_i v_{i+1}`; the H-backward
   clause holds iff backward `bx_le v_{i+1} → v_i` in the H-content sense;
   **the Until-defect clause requires: `φ U ψ ∈ v_i` and `ψ ∉ v_i`
   implies `φ ∈ v_i` AND `φ U ψ ∈ v_{i+1}`**. The first half (`φ ∈ v_i`)
   is immediate from BX9/`until_elim_mcs`. The second half (`φ U ψ ∈ v_{i+1}`)
   requires **Until-persistence at the BX level**, which is NOT a theorem
   of BX without `bx_le` being total — and it is the same persistence
   property that blocks `until_backward` in Realization.lean:432! **Option
   3 pushes the unsolved Until-persistence problem from Realization.lean
   into the projection step.**

**Option 3 is viable only if Until-persistence via an *enriched seed that
includes φ U ψ* is proved.** Specifically, when applying `bx_forward_witness`
one must seed with `{φ U ψ} ∪ g_content(v_i)`, whose consistency is NOT
guaranteed by any existing lemma. This is a new consistency obligation
of the same type as `chain_step_seed_consistent`.

### 2.4 An Unmentioned Fourth Option: "Tie Sigma to MCS derivation closure via a closure witness"

The summary implicitly dismisses the cleanest mathematical resolution: make
`HintikkaPoint` carry a proof that `∃ w : BXPoint, sigma_signature w Sigma = self`.
This "backing-by-MCS" witness field would:

- Make `chain_step_seed_consistent` trivial (just invoke the MCS's
  derivation-closedness directly).
- Force the Phase 3 `hintikka_chain_exists` proof to produce MCS-backed
  Hintikka points — which is harder, and may require Phase 5 to be merged
  into Phase 3.
- Eliminate the need for EnrichedClosure entirely.

This option is essentially "Phase 3 and Phase 5 must be fused: you cannot
build an abstract Hintikka chain and then realize it; you must build the
realized chain directly, using the Hintikka projection only as a
specification." This is the cleanest path and likely the one that will
actually close, but it means **Phase 3 as currently committed is
structurally the wrong decomposition**. The effort cost is higher than
the summary's options but bounded.

---

## 3. Is the "Gap" Correctly Framed?

**No.** The summary frames the gap as "`locally_consistent` is pairwise,
not derivation-level". This is true but misses the deeper issue:

The real gap is that **`chain_step_seed_consistent` as stated is a
mathematically sound claim only about MCS-backed HintikkaPoints**, not
about abstract HintikkaPoints. The entire Phase-3-then-Phase-5 decomposition
— "build an abstract chain, then realize" — is an attempt to prove the
consistency claim at a level of abstraction where the claim is not true.
The summary treats this as a local gap in a specific reduction, but it is
a **global architectural mismatch between the chain type and the
consistency property the chain must satisfy**.

Once you see it this way, the three "options" collapse:
- Option 1 (add consistency field) = restrict to MCS-backed
- Option 2 (derive consistency from existing fields) = impossible without MCS backing
- Option 3 (go BXPoint-level) = explicitly build MCS-backed chain

Option 3 is the correct direction **because it acknowledges the mismatch**,
but the summary's sketch of option 3 does not go far enough: it still
treats the Hintikka chain as a separate, projectable artifact rather than
integrating realization into chain construction.

**The correct architectural move** is: either (a) eliminate the abstract
Hintikka chain entirely and work at the BXPoint level throughout, or (b)
carry a backing witness inside `QuasimodelChain` making every step
MCS-backed. Both move the work to Phase 3 / Phase 5 fusion.

### 3.1 Assumption B: `bigconj L_h ∈ h_{i+1}.formulas`

The final contradiction step in Teammate A's §3.3 reduction is:

> By `bigconj_intro` on `L_h ⊆ h_{i+1}.formulas`, `bigconj L_h ∈ h_{i+1}.formulas`.
> Contradiction with local consistency of `h_{i+1}`.

**This step is invalid.** `bigconj_intro` is a `DerivationTree`-level
combinator: `L ⊢ bigconj L`. It produces a derivation, NOT a membership
claim. `bigconj L_h` is a fresh formula not in `L_h`, so even if every
element of `L_h` is in `h_{i+1}.formulas`, there is no set-level rule that
puts `bigconj L_h` into `h_{i+1}.formulas`. Hintikka points are not closed
under conjunction introduction at the set level.

Moreover, `locally_consistent` requires the SAME formula f and ¬f to both
be in `formulas`. For the contradiction we would need `bigconj L_h ∈ formulas`
AND `neg_bigconj L_h = ¬(bigconj L_h) ∈ formulas`. The second is provided
by the hintikka_step G-clause (given Assumption A); the first is NOT
provided by anything.

**This second gap is independent of EnrichedClosure and will block Option 1,
Option 2, and any variant that relies on the contradiction at the Hintikka
level.** Only Option 3 (or the unmentioned MCS-backed variant) bypasses
it, because MCSs ARE closed under conjunction introduction.

Teammate A's §3.3 reduction is therefore sound only when `h_{i+1}` is
backed by an MCS. The plan v3 does not enforce this backing.

---

## 4. Risks to Phase 5/6 Independent of Phase 4 Resolution

### 4.1 Phase 5 (Realize Full Chain) — independently blocked

Even if Phase 4 were magically solved, Phase 5 has its own independent
blocker:

**`realize_chain_step` requires the seed `h_{i+1}.formulas ∪ g_content(v_i.formulas)`
to produce a `v_{i+1}` whose `sigma_signature` is EXACTLY `h_{i+1}`.**

The seed's Lindenbaum extension produces some MCS containing the seed, but
that MCS may contain Sigma-formulas not in `h_{i+1}`. To force
`sigma_signature v_{i+1} = h_{i+1}`, you must additionally seed with the
negations `{¬f | f ∈ Sigma, f ∉ h_{i+1}.formulas}`. This enriches the seed
and **creates a second consistency obligation** that is NOT what Phase 4's
`chain_step_seed_consistent` proves. The seed needed for Phase 5 is:

```
h_{i+1}.formulas ∪ g_content(v_i.formulas) ∪ {¬f | f ∈ Sigma \ h_{i+1}.formulas}
```

Proving this enriched seed consistent is strictly harder than Phase 4's
obligation. None of the three options in the summary address this.

### 4.2 Phase 6 (locus-control exhaustiveness) — independently blocked

Phase 6 requires proving that every BXPoint `u` in the interval
`[v_0, v_k]` has its Sigma-signature equal to some `h_i` in the constructed
chain. As I noted in round 3 (and as the summary acknowledges), this is
**equivalent to proving the chain is exhaustive in Sigma-signature space**.
The only way to achieve this is if the chain `h_0, ..., h_k` visits
**every** `HintikkaPoint` reachable from `h_0` by at most `k` `hintikka_step`s.
The Phase 3 `hintikka_chain_exists` provides a chain along a specific
target-defect-decreasing path — not an exhaustive spanning.

**Phase 6 as currently planned is unprovable without rewriting Phase 3**
to produce a spanning tree (or: a breadth-first defect-discharge structure)
rather than a path. The plan v3 includes a fallback: "if the proof exceeds
12h, declare `locus_control_exhaustive` an axiom." If Phase 6 uses an
axiom, task 98 cannot claim zero-debt, and this violates the Zero-Debt
Policy binding all Lean research agents.

**This is a harder blocker than Phase 4.** Even if Phase 4 is solved, Phase
6 will fail, and the only acceptable closure is:
(a) axiom declaration (forbidden by Zero-Debt Policy), or
(b) restructuring Phase 3 to build an exhaustive chain (8-20h additional
    work, not budgeted in plan v3).

### 4.3 Phase 7 (Sorry closure in Realization.lean) — dependent on Phase 5+6

The 6 Realization.lean sorries include `until_backward` (lines 432) and
`since_backward` (line 490). These sorries have a distinct structural
difficulty: they need `¬bx_le v u` for a specific u produced by the
enriched seed, and this does NOT follow from `bx_le u v` without
anti-symmetry at the semantic level (which the preorder lacks).

The plan v3's Phase 7 delegates these to "composition of Phase 5 +
locus-control." **But composition does not give `¬bx_le v u`.** If
`u` has `bx_le u v` AND `bx_le v u` (both directions), then `u` and `v`
are in the same `bx_le`-equivalence class; the guard condition
`¬bx_le v u` is false and the guard is vacuously satisfied. If `¬bx_le v u`,
then we need locus-control to apply the guard and get `φ ∈ u`. So
Phase 7 for R3, R6 actually needs **case analysis on `bx_le v u`** plus
locus-control for the non-vacuous case. This is additional work not
captured in the plan v3.

---

## 5. Questions That Should Be Asked But Aren't

### Q1. Is the decomposition Phase 3 → Phase 5 even the right shape?

Plan v3 builds an abstract Hintikka chain first (Phase 3) and realizes it
second (Phase 5). But the consistency of the realized chain depends on
MCS-level derivation closure, which is not available at Phase 3. **Should
these two phases be fused into a single "Construct a realized chain"
phase?** The answer is almost certainly yes. Fusing them means Phase 3's
`hintikka_chain_exists` is replaced by a more powerful
`realized_chain_exists` that builds BXPoints and HintikkaPoints in
lockstep. This is structurally different from the current plan.

### Q2. Does the Sigma used in `EnrichedClosure` interact correctly with
`hintikka_step`?

Plan v3 Phase 2 assumes the migration to `EnrichedClosure` preserves the
`sigma_signature_maximal` property. But `EnrichedClosure` is NOT closed
under arbitrary subformula extraction — it is closed under
`neg_bigconj T.toList` for `T ⊆ SubformulaClosure`, which means for a
Hintikka point `h`, the formula `bigconj L` for arbitrary `L ⊆ h.formulas`
is NOT in `EnrichedClosure` (only its negation `neg_bigconj` applied under
G/H is). This means `locally_maximal` on `bigconj L_h` fails: the
HintikkaPoint cannot decide membership of `bigconj L_h` because that
formula is not in Sigma. **This is the structural barrier to Assumption B
at the Hintikka level.** EnrichedClosure fixes Assumption A but not
Assumption B.

### Q3. What is the actual defect-count termination guarantee under
EnrichedClosure?

`defect_count` counts Until-defects in `Sigma.filter ...`. When Sigma
grows to EnrichedClosure (which adds many non-Until formulas), does the
defect count still strictly decrease? The filter restricts to Until
formulas, so adding `G(¬(bigconj T))` does not change the defect count
directly. **But** EnrichedClosure's powerset-image construction produces
`O(2^|base|)` formulas, which can be large; this doesn't change `defect_count`
but does change kernel performance. Plan v3 Phase 1 has a profiling risk
("if slow, restrict to needed T via on-demand elaboration") — this
on-demand approach would break `enriched_g_neg_bigconj_mem` because the
subset T is fixed only at proof time, not at definition time.

### Q4. Is `bigconj L_h.toList` actually the right conjunction formula?

`.toList` on a `Finset` produces a list in an unspecified order (via
classical choice in noncomputable context). Two calls to `L_h.toList` may
produce different formulas, so `bigconj L_h.toList` is not a stable
definition. The classical order is fine for **existence** claims but means
that `neg_bigconj L_h.toList ∈ h_{i+1}.formulas` (from `hintikka_step`)
and `bigconj L_h.toList ∈ h_{i+1}.formulas` (which we can't prove) are
about the SAME `toList` expansion — as long as you use the same
`.toList` call. In practice this requires the Lean proof to carefully
thread one `.toList` throughout, which is a formalization hazard.

### Q5. If Phase 6 falls back to an axiom, what does that do to Task 98
closure?

Zero-Debt Policy forbids introducing axioms as a completion path. If
`locus_control_exhaustive` is axiomatized, task 98 cannot be marked
COMPLETED — only PARTIAL or BLOCKED. The plan v3 Phase 6 fallback is
therefore **incompatible with the Zero-Debt Policy** governing this
agent. The plan should be revised to either (a) budget 20-40h for a
sound locus-control proof, or (b) mark task 98 as BLOCKED pending a
fresh research pivot.

### Q6. Could the Fisher-Ladner closure be replaced by a smaller, targeted
enrichment?

Plan v3 adds `G(¬(bigconj T))` for **every** `T ⊆ SubformulaClosure`.
This is exponential in |SubformulaClosure|. But the consistency proof
only needs `G(¬(bigconj L_h))` for the specific finite `L_h` that fails.
Can we enrich Sigma **on demand** during the consistency proof rather
than ahead of time? Classically: yes, but this means `Sigma` depends on
the proof, which breaks the structure-constant nature of `HintikkaPoint`.
Not worth pursuing, but not investigated.

---

## 6. Cost Honesty

### 6.1 Plan v3's option-3 estimate: 8-15h

**This is unrealistic** for three reasons:

1. The summary's option-3 sketch relies on `bx_forward_witness` producing
   a chain in "at most length 2 in the simple case" — but the Frame.lean
   target is about **arbitrary-length** guard propagation (`φ` at every
   intermediate `u`), not a single witness hop. The "simple case" comment
   is misleading — the hard case is what the proof must handle.
2. The `BXUntilChain` type would duplicate `QuasimodelChain` + well-founded
   recursion + defect measure. Phase 3 (QuasimodelChain) took multiple
   sessions — duplicating it at the BXPoint level is reasonably another
   8-15h on top of Phase 3's already-sunk cost.
3. The projection from `BXUntilChain` to `QuasimodelChain` to satisfy
   Phase 3's committed API would require `hintikka_step`-for-projection
   lemmas (§2.3 point 4 above), which are not in tree and would themselves
   need `chain_step_seed_consistent`-shaped reasoning.

Realistic estimate for option 3 done properly: **25-45h**, plus an equal
amount for Phase 6 locus-control exhaustiveness. Grand total Phases 4-6:
**50-90h**, not the 30-50h the plan suggests.

### 6.2 Failure modes pushing effort beyond estimate

1. **`.toList` ordering hazards**: Lean's `Finset.toList` is classical; the
   proof must thread a single `.toList` call throughout. If the first
   attempt splits the list at different points, the type-checker will
   reject because the `bigconj` expressions don't match definitionally.
   Add 2-4h debugging.
2. **Well-founded recursion on `defect_count`** for `BXUntilChain`: Phase
   3 already completed this for `QuasimodelChain`. Duplicating takes time
   but is mechanical. Add 4-6h.
3. **Projection `hintikka_step` for BXPoint pairs**: the Until-defect
   clause of `hintikka_step` requires Until-persistence. At BX level,
   Until-persistence holds only when the seed includes `φ U ψ`. But if
   `ψ ∈ v_{i+1}` by construction, then `φ U ψ` is no longer a defect at
   `v_{i+1}`, so the clause is vacuously satisfied. This subtlety would
   require careful case analysis. Add 3-6h.
4. **`guard_transfer` under EnrichedClosure**: `φ ∈ Sigma` might not hold
   if `φ` is not in the base closure (e.g., `φ = neg_bigconj L`). For
   the guard condition formulas to transfer, they must be in Sigma. The
   original SubformulaClosure target is `φ U ψ`, so `φ ∈ SubformulaClosure`
   holds, so `φ ∈ EnrichedClosure`. This is fine for the main guard but
   fails for auxiliary lemmas that need membership of conjunctions. Add 2-4h.
5. **Since dual divergence**: `h_content` closure at the dual side uses
   `Formula.all_past`, and `enrichedHNegBigconj` is indexed by `T ⊆ SubformulaClosure`
   not by `T ⊆ enrichedClosure`. Same structural issue; double work. Add 4-8h.

Total pessimistic pad: 15-28h on top of the baseline.

### 6.3 Recommendation on effort

If the team commits to Option 3 (or Option 4 / MCS-backed chain), budget:
- Phase 4 (chain-step consistency) realistic: **20-35h**
- Phase 5 (realization) with enriched seed: **15-30h**
- Phase 6 (locus-control exhaustive): **20-40h** (without the axiom fallback)
- Phase 7-8 (sorry closure + Since): **15-30h**

Total: **70-135h** remaining. Plan v3's 52-98h estimate is optimistic by
about 30%. If the Zero-Debt Policy is enforced (no locus-control axiom),
the lower bound rises to **~90h**.

---

## 7. Confidence Level

**High (90%)**:
- Assumption B (`bigconj L_h` not in `h_{i+1}.formulas`) is a real and
  under-documented gap. It invalidates options 1 and 2 and complicates
  option 3.
- Phase 6 (locus-control exhaustiveness) is an independent blocker of
  at least equal severity to Phase 4 and is not resolved by any of the
  three options.
- Plan v3's effort estimate is optimistic by 30-50%.

**Medium (70%)**:
- Option 3 (BXPoint chain) can be made to work if Until-persistence via
  enriched seed is proved and locus-control exhaustiveness is handled
  separately.
- An "Option 4" — MCS-backing witness on `HintikkaPoint` — is cleaner than
  the three documented options but requires fusing Phase 3 and Phase 5.
- The summary's framing of the gap as "locally_consistent is pairwise" is
  technically correct but obscures the deeper issue.

**Low (40%)**:
- Whether Phase 4 + Phase 5 fused (Option 4) could close in under 50h
  without unforeseen obstacles. The well-founded recursion over realized
  BXPoint chains is territory the task has not yet explored.
- Whether Frame.lean's guard condition itself could be weakened (round 3
  teammate C Q4) to bypass locus control. Would need reading TruthLemma.lean.

---

## 8. Zero-Debt Compliance Statement

Per the research-agent Zero-Debt Policy, I flag the following plan v3
elements as non-compliant:

1. **Phase 6 fallback to axiomatize `locus_control_exhaustive`** (plan v3
   line 270): forbidden. The plan must be revised to either budget a
   sound proof or re-scope the task.
2. **Rollback/Contingency clause "mark task 98 as BLOCKED pending a fresh
   research round"** (plan v3 line 364): this is the correct Zero-Debt
   compliant fallback and should be the primary fallback, not the axiom
   declaration.

**Recommendation**: the next session should **not** attempt Phase 4 in
any of the three documented options. Instead, it should:

1. Fuse Phase 3 and Phase 5 into a single phase that builds a realized
   chain directly (BXPoints + `sigma_signature` equality witnesses).
2. Re-state `chain_step_seed_consistent` as a property of MCS-backed
   Hintikka points only.
3. Budget 70-135h for the remainder and split into task 99 if required.
4. Alternatively, mark task 98 as `[BLOCKED]` and spawn a fresh research
   task investigating whether the Frame.lean guard condition can be
   weakened (round 3 teammate C Q4) to eliminate the locus-control
   obligation entirely.

---

## 9. References

- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/HintikkaPoint.lean` lines 43-54 (structure fields)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` lines 45-52 (`hintikka_step`)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` lines 382-392 (`QuasimodelChain`)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/EnrichedClosure.lean` lines 101-109 (`enriched_g_neg_bigconj_mem`)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` lines 360-492 (remaining sorries)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/LocusControl.lean` (full — delegation only, no real proofs)
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` lines 79-115 (`g_content_closed_derivation`, `h_content_closed_derivation`)
- `Theories/Bimodal/Syntax/BigConj.lean` line 39 (`bigconj_nil : bigconj [] = ¬⊥`)
- `specs/098_.../summaries/07_phase4-summary.md` (document under critique)
- `specs/098_.../reports/03_teammate-a-findings.md` §3.3 (reduction with Assumption B)
- `specs/098_.../reports/03_teammate-c-findings.md` Q3, Q5 (prior locus-control critique; built upon here)
- `specs/098_.../plans/03_quasimodel-pivot-plan.md` Phases 4-8
