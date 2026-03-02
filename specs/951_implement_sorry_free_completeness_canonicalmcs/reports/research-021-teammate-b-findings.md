# Critical Gap Analysis: Task #951 Research Corpus

**Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
**Date**: 2026-03-01
**Mode**: Critical analysis (teammate-b)
**Scope**: 20 research reports, 4 implementation plans, 3 handoffs, source code
**Standards**: report-format.md

---

## Part A: Gaps and Blind Spots

### A.1 The transfer theorem has never been proven or even sketched at the Lean level

Every report from research-016 onward champions the "trivial task frame trick" as the
silver bullet: build a BFMCS over some Preorder D (sorry-free), then transfer the
falsification to a TaskFrame Int via `task_rel := fun _ _ _ => True`.

**The gap**: Not a single report writes down what this transfer proof actually looks
like in Lean 4. Research-016 Section 4.4 gives a "proof sketch" that hand-waves six
induction cases. Research-020 Section 11 says "truth transfer follows by structural
induction on phi." But no one has:

1. Verified that `bmcs_truth_at` (defined in BFMCSTruth.lean with `[Preorder D]`) and
   `truth_at` (defined in Truth.lean with `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`)
   have the SAME recursive structure. They do not: `truth_at` uses `WorldHistory` with
   domain predicates and dependent states functions, while `bmcs_truth_at` uses FMCS
   families directly.

2. Specified how the `Omega` (set of WorldHistories) in the TaskFrame model corresponds
   to `B.families` in the BFMCS. The box case requires an exact bijection between
   these sets, and with the trivial task frame, the Omega contains WorldHistories
   that are NOT derived from any BFMCS family (arbitrary functions on convex domains).
   The research handwaves this as "since Omega = {tau_fam | fam in B.families}, these
   match exactly" but never addresses that `valid` quantifies over ALL shift-closed
   Omega, not just canonical ones.

3. Addressed that `valid` requires `ShiftClosed Omega`. Research-017 Section 9.2 notes
   this issue and then claims "for the trivial frame, ALL sets are shift-closed."
   This claim is never verified. With trivial task_rel, `time_shift sigma Delta`
   creates a new history by shifting the domain. The shifted history must be in Omega.
   If Omega is exactly the canonical histories, this is not obviously satisfied (the
   canonical history for family `fam` at shift `Delta` produces a history with
   `states(t) = fam.mcs(t - Delta)`, which corresponds to a DIFFERENT family, not
   necessarily in B.families).

**Verdict**: The transfer theorem is the most critical piece of the whole construction,
and it has received the LEAST rigorous treatment. Every report assumes it is easy without
ever confronting the definitional mismatch between the two truth predicates.

### A.2 The "direction we need" for the bridge was confused for 4 reports

Research-016, research-017, and their supporting analyses repeatedly confuse which
direction of the bridge `temporal_valid phi <-> valid phi` is needed. Research-016
Section 5.3 initially writes the wrong direction, then corrects itself, then gets it
right. Research-017 Section 4.1 states both directions and then says "the first arrow
is the BFMCS construction... the second arrow is temporal_valid -> valid, which is the
EASY direction." This is correct but took 3 reports to arrive at.

The confusion reveals that the researchers were not working from a fixed formal statement.
A Blackburn/van Benthem expert would point out that the correct completeness chain should
have been stated precisely ONCE at the beginning as:

```
not derivable --> exists BFMCS countermodel --> exists TaskFrame countermodel --> not valid
```

Instead, the chain was reconstructed from scratch in every report.

### A.3 Nobody checked whether `valid` actually requires what we think it requires

The `valid` definition in Validity.lean quantifies over ALL D, ALL TaskFrames, ALL
TaskModels, ALL shift-closed Omega, ALL histories in Omega, ALL times. For completeness
(contrapositive: not derivable -> not valid), we need to EXHIBIT one specific D, one
specific TaskFrame, etc. that falsifies phi.

**The unchecked assumption**: Every report assumes that we can choose D = Int and use a
trivial TaskFrame. But `valid` quantifies over a UNIVERSE of types D. The Lean universe
level of D matters. Research-016 Section 6.3 mentions "Use `Type` (not `Type*`)" but
nobody verified this matches the actual definition. If `valid` uses `Type*` (universe
polymorphic) and our construction produces a model at a specific universe level, there
could be a universe-level mismatch.

More fundamentally: `valid phi` says phi is true in ALL models. To disprove it, we need
ONE countermodel. The countermodel construction is via `fully_saturated_bfmcs_exists_int`.
If we change strategy to use BidirectionalFragment as D, we need `BFMCS (BidirectionalFragment ...)`,
but the existing infrastructure (TruthLemma, Representation) is specialized to `BFMCS Int`.
Nobody has audited how much code would need to change.

### A.4 The constant witness family problem is deeper than acknowledged

Research-014 Section 4.6 discovers that constant witness families (mapping all times to
the same MCS) are NOT temporally coherent. This is labeled a "known issue" and dismissed
by saying "use non-constant witness families." But the modal saturation construction
(`exists_fullySaturated_extension` in ModalSaturation.lean) uses Zorn's lemma and has
no control over the temporal structure of the families it produces.

**The deep question nobody answered**: When Zorn's lemma produces a maximal modally-
saturated extension, can we guarantee that EVERY witness family in the extension is
temporally coherent? Or is this an additional constraint that Zorn's extension must
preserve?

Research-020 Section 10 (Risk 3) mentions this: "Modal saturation via Zorn's lemma
creates witness families that may be constant." The proposed mitigation is "use
fragment-based witness families." But the fragment-based approach requires that for
EACH diamond obligation, we construct a SEPARATE BidirectionalFragment rooted at the
witness MCS and build a full FMCS on it. Nobody has verified that:

1. The resulting BFMCS Int has consistent indexing across different fragment-based families
2. The families share the same D = Int domain in a compatible way
3. The truth lemma still works when different families are indexed by different fragments

### A.5 The FMCS Int construction via "chain to fragment" has a fatal surjectivity gap

Research-014 Section 4.4 proposes building `FMCS Int` by composing a chain `Int -> BidirectionalFragment`
with `fragmentFMCS`. The critical requirement is that the chain must be SURJECTIVE onto the
fragment (at least up to preorder equivalence). Research-014 Section 4.4 acknowledges
this and then states "the enriched chain VISITS w (or a CanonicalR-equivalent element)
at some index s." This claim is UNPROVEN and likely unprovable because:

1. The BidirectionalFragment contains ALL MCSes reachable from M0 by finite forward/backward
   steps. The enriched chain from M0 visits specific Lindenbaum extensions at each step.
   Different consistent seeds produce different Lindenbaum extensions.

2. The fragment may contain elements that are NOT reachable by the specific chain because
   the chain's Lindenbaum choices at each step are fixed by Zorn's lemma, while the
   fragment's elements arise from DIFFERENT Lindenbaum choices.

3. Research-014 Section 4.5 admits this: "the chain and the fragment may produce DIFFERENT
   MCSes at each step (because Lindenbaum's lemma is non-constructive)." It then says
   "we do not need literal surjectivity" and proposes using the enriched chain's witness
   placement. But the witness placement only works for formulas decoded at specific steps;
   it does not guarantee arbitrary F-witnesses are on the chain.

**This is the same blocker that killed the DovetailingChain approach**, just wearing
a different hat. The fragment approach gives sorry-free F/P at the fragment level, but
transferring to Int reintroduces the same surjectivity problem.

---

## Part B: "Cheap, Lazy, or Trivial" Elements

### B.1 The trivial task_rel is an engineering dodge, not a mathematical solution

The canonicalFrame in Representation.lean (line 100) uses:

```lean
task_rel := fun _ _ _ => True
```

This has been in the codebase since the beginning. Research-018 (Section 2) correctly
identifies this as "semantically vacuous" and notes the user has banned it. Yet research-016
through research-020 then propose using EXACTLY this trivial task_rel again, just framed
as the "trivial task frame trick."

The reframing is clever but ultimately dishonest: the user explicitly banned trivial
task_rel, and the proposed architecture uses a trivial task_rel. The justification is
"the task_rel only constrains WorldHistories, not truth" (research-016 Section 4.2).
But this is precisely WHY the user banned it: a task_rel that constrains nothing is
semantically empty.

**The mathematical content**: In the JPL paper's task semantics, `task_rel w d u` encodes
a genuine physical constraint: state u is reachable from w by a task of duration d.
This is the RAISON D'ETRE of the task frame formalism. Making it trivial guts the
formalism of its meaning.

If the completeness proof genuinely cannot produce a non-trivial task_rel (which the
research has essentially proven -- see Part A.5 and the compositionality obstruction in
research-019 Section 7), then this is a significant mathematical finding that should be
stated clearly: **TM's axioms are too weak to determine a unique non-trivial task relation
in the canonical model.** This is not a proof failure; it is a theorem about the logic's
expressiveness.

### B.2 The "D = Int is justified" argument is circular

Research-019 Section 5 argues: "Using D = Int in the canonical model does not restrict
the logic. It is a choice of WITNESS, not a restriction on the logic's models."

This argument is mathematically correct but misses the user's concern. The user asked
for D to be CONSTRUCTED from syntax, not chosen a priori. The argument "any D works
for completeness, so Int is fine" is true but lazy -- it avoids the harder question of
what D the logic's proof theory naturally produces.

Research-010 and research-011 came closest to addressing this: the BidirectionalQuotient
IS the syntactic D, and it may or may not be isomorphic to Int depending on the logic's
axioms. But research-016+ abandoned this line of inquiry in favor of the "just use Int"
shortcut.

### B.3 The four implementation plans contradict each other

| Plan | Strategy | Status | Why abandoned |
|------|----------|--------|---------------|
| v1 | Antisymmetrization via Z-indexed dovetailing chain | Superseded | F-persistence problem |
| v2 | Bidirectional Fragment approach | Phases A-D done, E blocked | Can't convert fragment FMCS to FMCS Int |
| v3 | OrderIso via SuccOrder/PredOrder | BLOCKED | Coverness mathematically impossible |
| v4 | Grothendieck construction on quotient | BLOCKED | quotientSucc_pred_inverse impossible |

Each plan was created with confidence that it would work, and each hit a fundamental
mathematical blocker. The plans do not learn from each other's failures. Plan v4 repeats
the exact same mistake as plan v3 (requiring quotientSucc/quotientPred to be inverses),
just dressed up in Grothendieck language.

**The pattern**: Every plan tries to force the BidirectionalQuotient into an algebraic
structure it does not naturally have (AddCommGroup, SuccOrder, Z-torsor). Every plan
fails because the Lindenbaum extension is non-constructive and does not produce the
regularity needed for algebraic structure.

### B.4 Research-020's "parametric completeness" is overengineered

Research-020 proposes proving completeness parametrically in D (for any ordered abelian
group) via a "model transfer" using `zmultiplesHom`. This is elegant mathematics but
massive overengineering for the stated goal. The existing completeness proof works for
D = Int. Making it parametric adds significant complexity for no practical benefit in
the current project.

---

## Part C: Underthought Areas

### C.1 The two-layer architecture was identified early but never implemented

Research-015 (Section 1) clearly states: "The root cause is an architectural mismatch,
not a missing lemma." The BFMCS layer needs only Preorder D; the semantic layer needs
AddCommGroup D. This diagnosis is correct and was confirmed by three independent
teammates.

The natural response is to SEPARATE these layers in the code: prove completeness at
the BFMCS level with Preorder D, then bridge to the standard `valid` definition.
Research-016 proposed this as "Architecture A" and recommended it. Research-017
specified the minimal hierarchy precisely. Research-020 mentions it approvingly.

**Yet nobody implemented it.** Every implementation plan (v1 through v4) instead tries
to force D = Int or D = BidirectionalQuotient through the EXISTING architecture, which
requires AddCommGroup D at the semantic layer. This is like trying to push a square
peg through a round hole, repeatedly, while holding the round peg in your other hand.

The two-layer architecture would:
1. Eliminate the need for AddCommGroup on the canonical D entirely
2. Make the sorry-free fragment FMCS directly usable
3. Reduce the sorry count from 3 to 0 with relatively straightforward refactoring
4. Properly separate concerns (temporal structure vs algebraic structure)

The reason it was never implemented appears to be engineering risk aversion: "it
requires refactoring existing sorry-free code." But the alternative -- 20+ research
reports and 4 failed implementation plans -- has cost far more effort.

### C.2 Category-theoretic perspective: the forgetful functor

The two-layer architecture has a clean category-theoretic formulation that no report
articulates:

There is a forgetful functor U from the category of ordered abelian groups (with
order-preserving group homomorphisms) to the category of linear orders (with order-
preserving maps). The functor U forgets the group structure.

For completeness, we construct a canonical model M in the category of linear orders.
To show `not valid`, we need a model in the category of ordered abelian groups. We
need a LEFT ADJOINT to U: a functor F that freely adds group structure to a linear
order.

The free ordered abelian group on a linear order L is well-defined mathematically.
For a countable linear order without endpoints, it is isomorphic to the reals (as
an ordered abelian group, via Dedekind completion and group completion). For a discrete
linear order without endpoints, it is Z.

None of the reports consider this perspective. They all try to construct the group
structure on the specific linear order L (the quotient), rather than freely generating
a group from L and embedding L into it.

### C.3 The Omega/ShiftClosed problem is a genuine gap

The `valid` definition requires `ShiftClosed Omega`. This means: for every history
tau in Omega and every shift Delta : D, the shifted history `time_shift tau Delta` is
also in Omega.

For the canonical construction, Omega = {canonicalHistory B fam hfam | fam in B.families}.
Time-shifting a canonical history by Delta produces a history with
`states(t) = fam.mcs(t - Delta)`. This corresponds to the SAME family but evaluated
at shifted times. For this to be in Omega, we need the family to be the SAME object
regardless of the time offset -- which it is (FMCS families are functions on all of D).

BUT: `time_shift` creates a new WorldHistory with a shifted domain. If the original
domain is `Set.univ`, the shifted domain is also `Set.univ`. The shifted states are
`states(t) = original.states(t + Delta)`. Since `canonicalHistory` uses states(t) = fam.mcs(t),
the shifted states are `fam.mcs(t + Delta)`, which is NOT the same as `fam.mcs(t)`.

This is `canonicalHistory B fam hfam` evaluated at `t + Delta` rather than `t`. This
is NOT the same WorldHistory object. For it to be in Omega, we need a family `fam'`
with `fam'.mcs(t) = fam.mcs(t + Delta)` to be in `B.families`. This requires B.families
to be shift-closed: for every family fam and shift Delta, the shifted family is also
in B.families.

**Nobody has checked whether the BFMCS construction produces shift-closed families.**
The Zorn's-lemma-based modal saturation has no obvious reason to preserve shift-closure.
This is a potentially fatal gap in the transfer from BFMCS to `valid`.

However, research-016 Section 5.4 observes that the completeness direction uses the
CONTRAPOSITIVE: we need `not (valid phi)`, which means exhibiting ONE specific Omega
(not all Omega). So we can CHOOSE Omega to be shift-closed. But then Omega must contain
ALL shifts of all canonical histories, which inflates Omega beyond the canonical families.
The box case of the truth lemma requires quantifying over this larger Omega, which may
break the correspondence with B.families.

### C.4 The real question: what does TM's proof theory say about task durations?

Every report focuses on the mathematical MECHANISM (how to construct D, how to define
task_rel) without asking the deeper question: **what does the axiom system TM actually
SAY about task durations?**

Looking at the axioms:
- Temporal axioms (T, 4, A, L, linearity): constrain the ORDER on D
- Modal axioms (K, T, 4, B, 5 for Box): constrain the accessibility relation
- MF axiom (Box phi -> Box(F phi)): links modal and temporal
- TF axiom (Box phi -> F(Box phi)): links temporal and modal

None of these axioms mention durations explicitly. The duration parameter d in task_rel
is an ARTIFACT of the TaskFrame formulation. The axioms constrain time as an ordered
set, not as a group. The group structure is needed by the FORMALISM (TaskFrame definition),
not by the LOGIC (TM axioms).

A Blackburn or van Benthem would say: the canonical model for a tense logic is a Kripke
frame (W, R) where R is the temporal accessibility. There is no separate "duration" type.
The TaskFrame's D is an extra layer of structure that the logic does not constrain. Any
linearly ordered abelian group D with an appropriate R-preserving embedding of the
canonical frame works.

This is why the trivial task_rel is the natural one: the logic says NOTHING about task
durations, so the canonical task relation contains no information about durations.

### C.5 Standard completeness proof techniques that were NOT considered

1. **Filtration**: For finitary logics with the finite model property, filtration gives
   completeness with respect to finite frames. TM may or may not have the finite model
   property, but this was never investigated. If TM has FMP, the whole sorry-free
   completeness problem simplifies dramatically.

2. **Step-by-step method (Bull/Fine)**: For linear tense logics, the step-by-step method
   constructs the canonical frame iteratively, ensuring each step preserves all
   required properties. This is different from the Lindenbaum/Zorn approach and may
   avoid the non-constructivity issues.

3. **Mosaic method**: For temporal logics, the mosaic method decomposes satisfiability
   into local consistency conditions. This can simplify the global construction.

4. **Algebraic semantics**: Represent TM as equations in an ordered algebra, use
   algebraic completeness (every variety is HSP-definable). The canonical algebra
   is the Lindenbaum-Tarski algebra, which is always available.

None of these alternatives were explored. All 20 reports work within the same
Lindenbaum+Zorn framework, hitting the same walls repeatedly.

---

## Part D: Honest Risk Assessment

### D.1 The trivial task frame trick approach (research-016/017/019/020)

**Will it work?** Probably, with 15-25 hours of careful engineering.

**Hidden complexity dragon**: The transfer theorem between `bmcs_truth_at` and `truth_at`.
These are DIFFERENT recursive functions with different type signatures. The induction is
not "trivial" -- it requires carefully threading through the domain predicates, the
CanonicalWorldState subtyping, the Omega correspondence, and the ShiftClosed constraint.
Each case will take 1-3 hours of Lean proof work, and the box case will be particularly
delicate because of the Omega bijection.

**Likelihood of new blockers**: LOW for the temporal cases (G, H), MEDIUM for the box
case (Omega correspondence), MEDIUM for the shift-closure requirement.

### D.2 The two-layer architecture refactor (research-015/016/017)

**Will it work?** Almost certainly, and it is the RIGHT solution.

**Hidden complexity dragon**: Refactoring `TaskFrame`, `WorldHistory`, `Truth`, and
`Validity` touches the foundation of the entire project. Even if each change is small,
the cascade through dependent files (Soundness, Representation, Completeness) could be
extensive. The risk is not mathematical but engineering: breaking currently-working
sorry-free proofs.

**Likelihood of new blockers**: LOW (the mathematical content is understood), but HIGH
risk of REGRESSIONS in existing proofs.

### D.3 The Grothendieck/SuccOrder approaches (plans v3/v4)

**Will they work?** NO. Both are mathematically blocked by the same fundamental
obstruction: the Lindenbaum extension is non-constructive and does not produce the
regularity (coverness, inverse property) needed for these algebraic constructions.
Plan v3 proved this; plan v4 rediscovered it.

These approaches should be marked PERMANENTLY ABANDONED, not just BLOCKED.

### D.4 The chain-based FMCS Int construction (plans v1/v2)

**Will it work?** Not without solving the F-persistence problem, which 20 reports have
confirmed is fundamentally blocked for linear chains. The enriched chain approach
(CanonicalChain.lean) places witnesses at specific steps but cannot guarantee persistence
of F-obligations across steps.

The dovetailing approach could potentially work if the chain processes F-obligations
IMMEDIATELY when they appear (before Lindenbaum can introduce conflicting G-formulas).
But research-014 Section 4.4 analyzed this and found the surjectivity gap remains.

### D.5 Where the research is being overly optimistic

1. **Time estimates**: Every plan estimates 30-60 hours. After 20+ research reports and
   4 failed plans spanning months, the true estimate for a working implementation is
   closer to 80-120 hours, regardless of approach.

2. **"Already sorry-free" infrastructure**: The reports repeatedly celebrate that
   `fragmentFMCS`, `exists_fullySaturated_extension`, `bmcs_truth_lemma` etc. are sorry-
   free. This is true but misleading: these are sorry-free at the BFMCS/Preorder level.
   The entire challenge is bridging to the TaskFrame/AddCommGroup level. The sorry-free
   infrastructure is necessary but not sufficient.

3. **"Straightforward induction"**: The transfer theorem is described as "structural
   induction on phi." In Lean 4, "structural induction" on a recursive function with
   dependent types, universe polymorphism, and set membership predicates is rarely
   straightforward. The box case alone could take a week.

---

## Summary: The Three Real Options

After reading all 20 reports and 4 plans, the situation is clear:

### Option 1: Two-layer refactor (RECOMMENDED)

Separate `TemporalFrame` (LinearOrder D) from `TaskFrame` (AddCommGroup D). Prove
completeness at the temporal level. Bridge to standard `valid` via the trivial embedding.

- **Effort**: 20-30 hours of refactoring, 10-15 hours of new proofs
- **Risk**: Regressions in existing code
- **Reward**: Clean architecture, extensible to density/discreteness, sorry-free

### Option 2: Direct transfer theorem (QUICK FIX)

Keep existing architecture. Prove `fully_saturated_bfmcs_exists_int` by constructing
a BFMCS Int using the fragment-level infrastructure and a carefully chosen chain. Prove
the transfer theorem between `bmcs_truth_at` and `truth_at` directly.

- **Effort**: 30-50 hours
- **Risk**: ShiftClosed gap, box case complexity, potential new blockers
- **Reward**: Minimal code changes, sorry-free

### Option 3: Accept trivial task_rel explicitly

Acknowledge that TM's axioms do not constrain task durations, so the canonical model's
task_rel is necessarily trivial. Document this as a mathematical theorem. Keep `task_rel
:= fun _ _ _ => True` and focus on eliminating the 3 actual sorries.

- **Effort**: 15-25 hours
- **Risk**: User may reject this framing
- **Reward**: Fastest path to sorry-free completeness

The research corpus overwhelmingly supports Option 1 as the correct long-term solution
and Option 3 as the correct mathematical interpretation. The 20+ reports of trying to
avoid both of these options have produced deep understanding of the obstacles but no
viable alternative path.
