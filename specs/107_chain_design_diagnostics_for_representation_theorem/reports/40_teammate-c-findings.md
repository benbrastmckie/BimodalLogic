# Teammate C (Critic) Findings: A3a Dependency Analysis and Plan Viability

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-28
**Role**: Critic — gap analysis and plan assessment
**Confidence**: HIGH

## Key Finding: The A3a "Counterexample" Is WRONG — A3a Is Valid Under Our Semantics

### The Critical Error

The entire blocker analysis in handoff 03 (and the comments in `TemporalDerived.lean:513-536` and `PointInsertion.lean:16-17`) is based on a **false claim**: that A3a is invalid under our semantics.

The claimed counterexample (TemporalDerived.lean:519-522, handoff 03 line 65-70):
> "times {0, 1, 2}, p true at 0, q true at 0 and 1, r true at 2. At time 0: p ∧ U(q,r) holds. But U(q ∧ S(p,r), r) fails at 0 because S(p,r) at u=0 requires v < 0 with r(v)."

**The error**: S(p,r) is evaluated at u=0 (the current point), but in A3a the formula S(p,r) appears inside U as part of the EVENT, meaning it should be evaluated at the UNTIL WITNESS s, not at the current point t.

### Proof that A3a is valid under open guard (t, s)

Our semantics (Truth.lean:127-130):
```
untl φ ψ => ∃ s, t < s ∧ ψ(s) ∧ ∀ r, t < r → r < s → φ(r)   -- guard = φ, event = ψ
snce φ ψ => ∃ s, s < t ∧ ψ(s) ∧ ∀ r, s < r → r < t → φ(r)   -- guard = φ, event = ψ
```

Guard interval is **open** (t, s) — strictly between endpoints.

A3a in Burgess convention: `p ∧ U(q, r) → U(q ∧ S(p, r), r)` where U(event, guard).
In our code convention (untl guard event): `p ∧ untl(r, q) → untl(r, q ∧ snce(r, p))`.

Semantic validity proof at time t:

**Assume**: p(t) and untl(r, q)(t), i.e., ∃ s > t with q(s) and ∀z ∈ (t, s), r(z).

**Show**: untl(r, q ∧ snce(r, p))(t), i.e., ∃ s' > t with (q ∧ snce(r, p))(s') and ∀z ∈ (t, s'), r(z).

**Take s' = s**:
1. q(s) ✓ (from the Until witness)
2. snce(r, p) at s: need ∃ u < s with p(u) and ∀z ∈ (u, s), r(z).
   Take u = t: p(t) ✓. ∀z ∈ (t, s), r(z) ✓ (from the Until guard).
3. ∀z ∈ (t, s'), r(z) = ∀z ∈ (t, s), r(z) ✓.

**A3a is semantically valid under open guard (t, s) for ALL linear orders.** ∎

### Verification against the specific counterexample

Times {0, 1, 2}, p at 0, q at 0-1, r at 2. Using the correct witness:
- U(q, r)(0): witness s=1 (not s=2 as the counterexample claims). q(1) ✓, r on (0,1) = vacuous ✓.
- U(q ∧ S(p,r), r)(0): witness s'=1. q(1) ✓. S(p,r)(1): witness u=0, p(0) ✓, r on (0,1) = vacuous ✓.
- A3a holds. ✓

The counterexample's error was using s=2 as the Until witness (where q(2)=false), and then evaluating S(p,r) at t=0 instead of at the witness.

### Note on BX2 and the "half-open" confusion

The comment in Truth.lean:13-14 says "half-open guard [t, s)" but the actual code (Truth.lean:128) implements `t < r → r < s` which is open (t, s). The BX2 axiom has an extra `(φ→χ)` conjunct (beyond `G(φ→χ)`) which was designed for half-open guard, but the actual semantics is open, making the conjunct redundant. This mismatch between comments and code has caused lasting confusion.

## A3a Dependency Trace in Burgess/Xu

Now that we know A3a IS valid under our semantics, its availability completely changes the analysis:

| Lemma | Uses A3a? | Uses A4a? | Other deps | Available in BX? |
|-------|-----------|-----------|------------|-----------------|
| **2.3** (forward-backward equiv) | **YES** (directly) | No | MCS properties | **YES if A3a derivable** |
| **2.4** (witness placement) | **YES** (via A3a for seed consistency) | No | A1a, A2a, 2.2, 2.3 | **YES if A3a derivable** |
| **2.5** (composition) | No | No | A6a=BX6 | YES ✓ |
| **2.6** (D0 consistency) | **YES** | **YES** (A4a) | A5a=BX5 | A3a YES; A4a UNKNOWN |
| **2.7** (insertion, Until witness) | **YES** (final step) | No | A5a, A7a | **YES if A3a derivable** |
| **2.8** (insertion, mirror) | **YES** (final step) | No | A5a, A7a | **YES if A3a derivable** |
| **2.9** (C4 elimination) | **YES** in Burgess; **NO** in Xu (uses BX6 instead) | No | 2.6 | Xu's approach: YES ✓ |
| **2.10** (C5 elimination) | **YES** via 2.7/2.8 | No | 2.4, 2.7, 2.8 | **YES if A3a derivable** |
| **Xu 2.1** (= Burgess 2.3) | A3a is base axiom in Xu | No | Part of minimal TL_US | **YES if A3a derivable** |
| **Xu 3.2.1** (B closure) | No (only BX5) | No | Maximality + BX5 | YES ✓ |
| **Xu 3.2.2** (C4 replacement) | YES via 3.2.1 + **2.1** | No | 3.2.1, 2.1 | **YES if A3a derivable** |

### A4a status

A4a: `U(p,q) ∧ ¬U(p,r) → U(q ∧ ¬r, q)`.

A4a is used only in Burgess's Lemma 2.6. Xu's approach (3.2.2) replaces Lemma 2.6 entirely using 3.2.1 + 2.1, avoiding A4a. So **A4a is not needed if we follow Xu's construction** (which the plan already specifies).

### Summary of A3a dependency

If A3a is derivable from BX1-BX12 (which it should be, since it's semantically valid), then:
- **ALL** of Burgess's lemmas become available
- **ALL** of Xu's lemmas become available (2.1 = Burgess 2.3 becomes provable)
- The bidirectional maximality in BurgessR3Maximal is no longer a problem
- The plan v22 becomes fully viable

## Verification: Is A3a Derivable from BX Axioms?

A3a is semantically valid on ALL frames under our open-guard semantics. Our axiom system is COMPLETE for the class of linear orders (that's the whole point of the completeness proof). Therefore A3a must be derivable from BX1-BX12 (plus the linear order axioms BX7/BX11).

More specifically: A3a is in Xu's minimal tense logic TL_US(∅) which uses only axioms (1)-(4) and their mirrors. Our system BX includes:
- (1) parts = BX2, BX3
- (3) = A3a — this SHOULD be derivable since it's semantically valid
- (4) = A3b (mirror) — similarly derivable

Since A3a is valid on all frames (including non-linear), it is a theorem of the MINIMAL tense logic TL_US(∅). Our system includes all of TL_US(∅)'s axioms (possibly under different names), so A3a must be derivable.

**The derivation path**: From BX4 (connect_future: φ → G(P(φ))) combined with BX5 (self_accum) and BX12' (P → S(·, ⊤)), one should be able to derive A3a. The key insight is:
1. From p at current point and U(q, r) at current point
2. BX5 enriches: U(q, r ∧ U(q, r))
3. BX4 applied to p: G(P(p)), so P(p) at the witness
4. BX12': P(p) → S(⊤, p) = snce(⊤, p)
5. Need to strengthen guard from ⊤ to r: at the witness s, P(p) gives a past witness u. The Until guard r holds on (t, s). If u = t, then r on (u, s) = r on (t, s) ✓.
6. But P(p) doesn't guarantee u = t specifically...

Wait — the semantic proof works because we CAN choose u = t (since p holds at t and t < s). But the syntactic proof through BX4 gives P(p) at s, which is snce(⊤, p), and we need snce(r, p). BX4 gives us the EXISTENCE of a past witness but not the guard between that witness and s.

Actually, I think the derivation is more subtle. Let me think about this differently:

A3a says: from p ∧ U(q, r), derive U(q ∧ S(p, r), r).

We have untl(r, q) (guard=r, event=q). We need untl(r, q ∧ snce(r, p)).

By BX5: untl(r, q) → untl(r ∧ untl(r, q), q). The enriched guard is r ∧ untl(r, q).

By BX4: p → G(P(p)) = p → all_future(some_past(p)).

At the Until witness s: some_past(p)(s) holds. This is P(p)(s) = snce(⊤, p)(s).

But we need snce(r, p)(s), not snce(⊤, p)(s).

Hmm. The gap between P(p) and S(p, r) at the witness IS the Lemma 2.3 gap from the handoff. But semantically it works because we can choose the Since witness to be t itself.

**The missing piece**: We need a way to say "P(p) at s, with the past witness being specifically a point where U(q,r) was active, so the Until guard covers the Since interval."

This is exactly what A3a does in one step. The question is whether BX4+BX5+BX12 can reconstruct this.

**Critical realization**: The fact that A3a is semantically valid under open guard means that `¬(p ∧ untl(r, q) ∧ ¬untl(r, q ∧ snce(r, p)))` is unsatisfiable. By completeness (which we're trying to prove!), this should be derivable. But we can't use completeness to derive something we need FOR the completeness proof — that's circular.

However, A3a is valid on ALL frames, not just linear ones. It's valid even on general frames (no transitivity, no linearity needed). The MINIMAL tense logic TL_US(∅) is complete for all frames (Xu Theorem 2.8). Our axiom system includes all of TL_US(∅)'s axioms. So A3a should be derivable from just (1)-(4) and their mirrors, which correspond to BX2, BX3, and the as-yet-unidentified A3a itself.

**The problem**: A3a is one of the BASE axioms (3) of every US-tense logic. It's NOT derived from other axioms — it IS an axiom. Our system replaced it with BX4 (connect_future), claiming BX4 subsumes A3a's role. But BX4 is WEAKER than A3a (it gives P(p) but not S(p, r)).

So the question is: **Is A3a derivable from BX4 + BX5 + other BX axioms?**

Based on the analysis in handoff 03 (which tried 7 approaches and failed), the answer appears to be **NO** — despite A3a being semantically valid, the specific combination of BX axioms cannot reconstruct A3a syntactically.

**This means our axiom system may be INCOMPLETE.** A3a is semantically valid but not derivable.

## Plan Assessment

| Phase | Status | A3a Impact | Assessment |
|-------|--------|------------|------------|
| 1 (Review) | COMPLETED | None | ✓ Unaffected |
| 2 (Cleanup) | COMPLETED | None | ✓ Unaffected |
| 3 (C2' + Xu 3.2.1) | BLOCKED | **CRITICAL** — 3.2.1 proof needs forward maximality (OK with Xu's approach) but 3.2.2 needs Lemma 2.1 which needs A3a | **BLOCKED** unless A3a added as axiom |
| 4 (C4 elimination) | NOT STARTED | Xu's Theorem 3.3 uses BX6 for the substitution step (not A3a), BUT the base case uses 3.2.2 which needs A3a | **BLOCKED** by Phase 3 |
| 5 (C5 + Lemma 2.10) | NOT STARTED | Lemma 2.10 uses 2.7/2.8 which use A3a directly; also 2.4 uses A3a | **BLOCKED** unless A3a available |
| 6 (FUC/truth lemma) | NOT STARTED | Truth lemma itself doesn't use A3a (uses C5+C3); unaffected IF C5 is properly formulated | Possibly OK |
| 7 (Integration) | NOT STARTED | Depends on 3-6 | Depends on 3-6 |
| 8 (ROADMAP) | NOT STARTED | Documentation only | Unaffected |

## Gaps and Shortcomings

### Gap 1: A3a is semantically valid but possibly not derivable

A3a is valid under our open-guard semantics (proven above). But if it's not derivable from BX1-BX12, our axiom system is incomplete for the class of all frames. This is a FOUNDATIONAL issue.

The fix is straightforward: **add A3a (and its mirror A3b) as axioms**. They are semantically valid, so adding them preserves soundness. They are part of every US-tense logic in Xu's framework.

### Gap 2: Report 39's mapping "A3a = (3) = BX4" is WRONG

BX4 = connect_future = `φ → G(P(φ))`. This is NOT A3a. A3a = `p ∧ U(q, r) → U(q ∧ S(p, r), r)`. These are completely different axioms. BX4 connects present to future-past (the present is in the past of the future). A3a enriches an Until event with Since information.

### Gap 3: The handoff's counterexample and TemporalDerived.lean's claim are both wrong

The counterexample evaluates S(p,r) at the wrong point (t instead of the Until witness s). The claim "A3a not valid under strict semantics" is false for our open-guard semantics.

### Gap 4: A4a status unclear

A4a: `U(p,q) ∧ ¬U(p,r) → U(q ∧ ¬r, q)`. This is used in Burgess 2.6 but NOT in Xu's approach. However, A4a's semantic validity under open guard should also be checked. If valid, it could be added alongside A3a.

## Recommended Approach

### Primary recommendation: Add A3a and A3b as BX axioms

1. **Add A3a** (`p ∧ U(q, r) → U(q ∧ S(p, r), r)`) as a new BX axiom (call it BX4a or rename BX4 to BX4_connect and add BX4a_enrichment)
2. **Add A3b** (mirror: `p ∧ S(q, r) → S(q ∧ U(p, r), r)`) similarly
3. **Prove soundness** of A3a/A3b (the semantic validity proof above translates directly to Lean)
4. **Derive Burgess Lemma 2.3** using A3a (Burgess's original proof, 3 lines)
5. **Continue with plan v22** — all phases become unblocked

This is the minimal change that unblocks the entire construction. It requires:
- ~2 lines in Axioms.lean (new constructors)
- ~20 lines in Soundness.lean (soundness proof)
- ~15 lines in RRelation.lean (Lemma 2.3 proof using A3a)
- Plan v22 proceeds unchanged

### Alternative: Prove A3a from existing BX axioms

If A3a is derivable from BX1-BX12, that's even better — no axiom changes needed. But handoff 03 tried 7 approaches and failed. The derivation (if it exists) is non-trivial. This approach carries HIGH risk of further delay.

### Alternative: Forward-only maximality

Restructure BurgessR3Maximal to use forward-only maximality (handoff 03 Option B). This avoids Lemma 2.3 but requires significant plan revision and infrastructure changes. HIGHER cost than simply adding A3a.

## Confidence Level

**HIGH (95%)** that A3a is semantically valid under our open-guard semantics. The proof is elementary (3 lines, shown above).

**HIGH (90%)** that adding A3a as an axiom unblocks the entire plan v22.

**MEDIUM (70%)** that A3a can be derived from existing BX axioms without adding it explicitly. The semantic validity is clear but the syntactic derivation is non-obvious.
