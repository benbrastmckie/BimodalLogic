# Round 35 — The ELIMINATION, attacked at `ConAttack.attR` before anything is built on it

Phase 23 of `plans/35_construction-over-certified-subset.md`. Decision 29 (cycle 5,
`2026-11-17T02:35:30Z`) re-pinned `ladderConstruct` over the fibres of a certified **SUBSET** of
`R`, because elimination is what the published converse directions use. **The restatement does
not make the subset exist.** This round decides, by compilation and at the one certified fixture
that forced the weakening, whether a fibre-dissolving certified subset exists there at all.

**Rulings this round is bound by**: Ruling 38 (no GREATEST certified subset is assumed), Ruling
39 (guardrail (b) stays UNMET and is not reported as met), Rulings 27/31 (attack before adopt).
Nothing is stated or landed under `ladderConstruct`, `ladderRealized` or
`cellAt_const_of_kappa_eq` in this round.

## 0. Dispatch routing — this round was reached through two RE-ENTRY NOTICES, and says so

Dispatch 88 was scoped by the orchestrator to **Phase 11.44**, whose `[PARTIAL]` marker parses as
open. Phase 11.44's RE-ENTRY NOTICE (Ruling 28) names its continuation **by rule**: *"a dispatch
that selects this heading executes THE FIRST OPEN PHASE AT OR AFTER 11.48 IN FILE ORDER —
evaluated against the live file — and says in its record that it did so."* That rule was
evaluated against the live plan file at this round's entry:

| Heading, in file order from 11.48 | Marker | Enterable? |
|---|---|---|
| 11.48, 11.49, 11.40, 12.1 | `[COMPLETED]` / `[COMPLETED WITH EXCLUSIONS]` | closed |
| **12.2** | `[BLOCKED]` | **NO** — decision 28 holds it blocked and the (Q-2) revision states "Phase 12.2 stays `[BLOCKED]` with its compiled record" |
| 13, 14, 15.1 | `[NOT STARTED]` | NO — `Depends on: 12.2` |
| 17 | `[NOT STARTED]` | NO — `Depends on: 21`, which is `[PARTIAL]` |
| 11.30, 11.31 | `[NOT STARTED]` | NO — Ruling 4 forbids entry on a premise the (G-1) refutation contradicts |
| 18 | `[NOT STARTED]` | NO — `Depends on` names 23–26 among many open phases |
| 20 | `[NOT STARTED]` | NO — `Depends on: 12.2, 13`; decision 27/28 defer the READ-OFF half explicitly |
| 21 | `[PARTIAL]` | NO — its own (Q-2) RE-ENTRY NOTICE redirects to "the first open phase at or after 23 in file order" |
| **23** | `[NOT STARTED]` | **YES — entered** |

So the redirect chain is **11.44 → (rule, at or after 11.48) → 21 → (rule, at or after 23) →
23**, and Phase 23 is what this round executed. This is recorded here because Phase 11.44's
notice requires the executing dispatch to say so in its record.

## 1. THE REMOVAL RULE, STATED BEFORE ANY LEAN WAS WRITTEN

This section was written and committed **before** any Lean declaration of this round existed, as
Phase 23's rule-before-operator check requires and as Phase 21 discharged for its carrier.

### 1.1 The rule

> **ELIMINATION BY COMPONENT AT A MULTI-MEMBER FIBRE.** Let `R` be `certAdmK`-certified and let
> `s` be a key whose fibre `{x ∈ R | (x.1, x.2.2) = s}` carries two or more members. Choose one
> member `m` of that fibre and **keep exactly the `relK`-connected component of `m` inside `R`** —
> that is, remove from `R` every member not joined to `m` by a finite chain of `relK` edges, taken
> in either direction, all of whose intermediate members lie in `R`. Write the result `R ↾ m`.

The rule is a *removal* rule in the sense decision 29 requires: its output is a subset of its
input, it is produced from `R` and a chosen member, and **nothing anywhere assumes that its
output is certified** — that is this round's question, decided per candidate by compilation.

### 1.2 What the rule is INTENDED to preserve

| Preserved | Why the rule is shaped to preserve it |
|---|---|
| **Nonemptiness** | `m ∈ R ↾ m` by the length-`0` chain. The output is never empty. |
| **Condition (1), `certLocK`** | `locCoh` is a predicate on a single member, so it is inherited by every subset of `R` with no argument at all. |
| **Condition (2), `certBiInfK`** | A `relK`-successor and a `relK`-predecessor of a member of the component are themselves in the component, by one more edge of the chain — **provided** the witness `certBiInfK` supplies for that member lay in `R`, which it did. |
| **Condition (3), `certFwdK`** | A `DischPathK` out of a member of the component runs along `relK` edges inside `R`, so every position of it is in the same component. The discharge path therefore survives the removal unchanged. |
| **Condition (4), `certBwdK`** | The same argument along the reversed relation. |

### 1.3 What the rule MAY DESTROY, stated as a hazard and not as a prediction

**Conditions (5) and (6) — `certStabK` and `certBoxK` — are NOT preserved by shrinking in
general, and the reason is structural rather than incidental.** Both are stated as an
**iff** whose right-hand side is a **universal quantifier over `R`**:

```
certStabK:  ψ ∈ x.2.1.val  ↔  ∀ y ∈ R, y.1 = x.1 → y.2.2 = x.2.2 → argOf ψ ∈ y.2.1.val
certBoxK:   ψ ∈ x.2.1.val  ↔  ∀ y ∈ R, argOf ψ ∈ y.2.1.val
```

Removing members from `R` makes each right-hand side **more often true**. The `→` direction of
each iff therefore survives, but the `←` direction can break: a member `x` that did not carry the
`⊡` (or `□`) letter may, after the removal, satisfy the universal vacuously or by accident, and
the iff then fails at `x`. **A removal rule that reports conditions (5) and (6) as automatically
inherited has made an error**, and this round does not make it.

At **this fixture** both conditions are discharged by `no_stab_closure` and `no_box_closure` —
the closure of `g U e` carries no `⊡` and no `□` letter at all. That is a **FACT about this
closure, never a licence to omit the clauses**: Phase 23's prohibited-workarounds list names
exactly this, and both conditions are carried and discharged explicitly on every candidate below
rather than dropped from the enumeration.

A second hazard, recorded for the general lemma that Phase 24 owes and that this round does not
attempt: **condition (2) is preserved only because the component is closed under the successor
and predecessor the certificate actually supplies.** A certified set whose components are not
individually bi-infinite — a finite in-tree hanging off a cycle, say — would lose condition (2)
at its leaves. The fixture's components are two-cycles, so the hazard is not exercised here and
is **not** thereby shown to be harmless.

### 1.4 What the rule produces at `ConAttack.attR`, derived from the landed fixture facts

`attR = {m0p, m1p, m0m, m2m}` over `Qa = Fin 3` with `stepA : 0 → 1, 0 → 2, 1 → 0, 2 → 0`. The
landed edges are `rel_m0p_m1p`, `rel_m1p_m0p`, `rel_m0m_m2m`, `rel_m2m_m0m` and the landed
non-edges are `not_rel_m0p_m0p`, `not_rel_m0p_m0m`, `not_rel_m0p_m2m`, `not_rel_m0m_m0p`,
`not_rel_m0m_m0m`, `not_rel_m0m_m1p`, `not_rel_m1p_m0m`. So `relK` on `attR` is **two disjoint
two-cycles**, `m0p ↔ m1p` and `m0m ↔ m2m`, and the rule applied at the two-member fibre over the
key of object state `0` produces exactly two candidates:

- `attR ↾ m0p = {m0p, m1p}`, written `attRp` below;
- `attR ↾ m0m = {m0m, m2m}`, written `attRm` below.

The enumeration this round compiles is therefore `attRp`, `attRm`, `attR` itself and `∅` — the
minimum Phase 23 names, plus nothing, since the rule produces no further subset here.

<!-- Sections 2 onward are written after the attack and the enumeration have compiled. -->

## 2. THE ATTACK, CARRIED OUT FIRST — AND ITS OUTCOME

**The attack's target, stated before it was run.** At `ConAttack.attR`, attempt to REFUTE:

> there exists a `certAdmK`-certified, NONEMPTY subset `R' ⊆ attR` on which `conStepStrong` is
> serial.

This is the existence claim decision 29's restatement silently needs, and `attR` is the one
certified set in the tree on which `conStepStrong` is known NOT to be serial
(`conStepStrong_not_serial` at `sK0`), so it is where a refutation would live if one existed.

**Outcome: THE ATTACK FAILS, and its failure is compiled.** The removal rule's output from the
letter-carrying member is a witness to the very existence the attack tried to deny:

```
exists_certified_serial_dissolving_subset_at_attR   (LadderRealize.lean, top level)
  ∃ R' ⊆ attR, R'.Nonempty ∧ certAdmK stepA pendA labA phiA 0 0 0 0 R'
    ∧ (∀ t s, ∃ s', conStepStrong … R' t s s')
    ∧ (∃ x ∈ R', x.1 = 0 ∧ ∀ y ∈ R', (y.1, y.2.2) = (x.1, x.2.2) → y = x)
```

witnessed by `attRp`. Axioms `[propext, Classical.choice, Quot.sound]`, pinned in
`KTypeSummaryAxiomTest.lean`.

**What the failure of the attack does and does not buy.** It settles the question **at this
fixture** and nowhere else. It does **not** show that every certified set admits such a subset —
that is Phase 24's lemma and is asserted nowhere here — and it does not show the truth lemma is
provable: `conStep_two_step_lift_refuted` is untouched, because the weak relation is not the one
`attRp` is serial for. The attack was run before any positive declaration was written, in keeping
with Rulings 27 and 31; this section was drafted before section 3's enumeration was compiled.

## 3. THE CANDIDATE ENUMERATION, DECIDED BY COMPILATION

Every cell below cites a landed declaration. No row is backed by prose.

| Candidate | `certAdmK`? | Evidence | `conStepStrong` serial? | Evidence |
|---|---|---|---|---|
| `attRp = {m0p, m1p}` | **YES**, all six | `attRp_certAdmK` (= `attRp_certLocK`, `_certBiInfK`, `_certFwdK`, `_certBwdK`, `_certStabK`, `_certBoxK`) | **YES** | `conStepStrong_serial_attRp`, via `strong_pK0_pK1`/`strong_pK1_pK0` and `conKey_attRp_cases` |
| `attRm = {m0m, m2m}` | **YES**, all six | `attRm_certAdmK` (six named conditions, same shape) | **YES** | `conStepStrong_serial_attRm`, via `strong_mK0_mK2`/`strong_mK2_mK0` and `conKey_attRm_cases` |
| `attR` itself | **YES** | `att_certAdmK` (landed by Phase 21) | **NO** | `conStepStrong_not_serial` at `sK0` — no key whatsoever serves both members over `sK0` |
| `∅` | **YES**, vacuously | `empty_certAdmK` | **YES, but vacuously and for the wrong reason** — the key carrier over `∅` is itself empty | `conStepStrong_serial_empty` |

**No condition FAILS on any candidate at this fixture**, so the "failing condition NAMED" column
that Phase 23's task list asks for is empty by outcome rather than by omission. That is itself the
finding: the obstruction `conStepStrong_serial_refuted` consumes is **not** a certificate condition
resisting restriction — it is the arity of one fibre.

**The empty candidate is in the table and is EXCLUDED.** `empty_not_nonempty` compiles the
exclusion. It is listed because a verdict that did not exclude it would be discharged by it
trivially, and the construction half's conclusion is stated over a NONEMPTY subset.

**Conditions (5) and (6) were CARRIED on each candidate, never inherited.** `attRp_certStabK`,
`attRp_certBoxK`, `attRm_certStabK` and `attRm_certBoxK` are separate declarations rather than
restrictions of `att_certStabK`/`att_certBoxK`, for the structural reason section 1.3 states: each
is an iff whose right-hand side is a universal over the set, so shrinking does not preserve it in
general. At this fixture each is discharged by `no_stab_closure`/`no_box_closure` — the closure of
`g U e` carries no `⊡` and no `□` letter. **That is a fact about this closure and not a licence to
omit the clauses**, which is why four declarations exist where two inherited ones would have
looked sufficient.

## 4. THE DISSOLUTION VERDICT, PER CANDIDATE

Decision 29's obligation: *"a restatement that does not visibly dissolve THAT fibre has not
discharged this"*, THAT fibre being the one over the key of object state `0`, whose two members
`m0p`/`m0m` have disjoint successor keys `(1, κ)` and `(2, κ)`.

| Candidate | members over the key of object state `0` | Evidence |
|---|---|---|
| `attRp` | **ONE** — `m0p` | `over_pK0` |
| `attRm` | **ONE** — `m0m` | `over_mK0` |
| `attR` | **TWO** — `m0p` and `m0m` | `over_key_zero` (landed by Phase 21) |
| `∅` | **ZERO** — and the key does not exist in the carrier | `conStepStrong_serial_empty`'s own proof: the carrier over `∅` is empty |

So the fibre is **visibly dissolved** on both of the removal rule's outputs, by compilation and
member by member, and the dissolution is carried as a conjunct of the headline theorem's own
statement rather than asserted beside it.

## 5. THE BRANCH THIS ROUND SELECTS, BY RULE

**OUTCOME (a) — SURVIVES.** Phase 23's own rule: *"some candidate is certified, nonempty and
fibre-dissolving: Phase 24 is enterable and Phase 26 is NOT entered."* Both `attRp` and `attRm`
qualify, so the branch is not marginal — the choice of which member of the two-member fibre to
keep does not decide it.

Consequences, stated as the phase's rule states them and not wider:

- **Phase 24 is ENTERABLE** — the elimination lemma at a GENERAL certified `R`. Nothing in this
  round establishes it; what this round removes is the possibility that the fixture already
  refutes it.
- **Phase 26 is NOT entered.** Fallback (A) — the third step relation as a greatest fixpoint — was
  decision 29's fallback for the case where route (C) does not close at the fixture. It did close
  here, so the fallback is not taken, and this round designs no third relation (Phase 23's
  prohibited-workarounds list forbids it outright).
- **Phases 24 and 25 do NOT close by exclusion.** That disposition was reserved for outcome (b).
- **`ladderConstruct` is NOT stated or landed here.** It is Phase 25's, at the `(Q-2)` pin.

**What Phase 24 now owes, named from this round's own shape rather than guessed.** The removal rule
is stated for a key with a multi-member fibre and its output is the `relK`-connected component of
a chosen member. Two of its preservation arguments are *local and general* — conditions (1), (3)
and (4) hold of any `relK`-closed subset — while **two are fixture-dependent and are the general
lemma's real content**:

1. **Condition (2) at the component's edges.** Here the components are two-cycles, so bi-infinity
   survives. A certified set with a finite in-tree hanging off a cycle would lose condition (2) at
   its leaves, and nothing in this round shows that cannot happen.
2. **Conditions (5) and (6) under shrinking.** Section 1.3's hazard is real and is only unexercised
   here because the closure of `g U e` has no `⊡` and no `□` letter. At a `⊡`-bearing closure the
   `←` direction of `certStabK` is exactly what a general elimination must argue, and this round
   contributes nothing to it. **A Phase 24 lemma reached on a `⊡`-free closure would not discharge
   its obligation**, by the same standard decision 24 applied to the (T-1) round.
3. **Dissolution is not yet shown to TERMINATE.** At this fixture one removal suffices because the
   components are singleton-fibred. In general, keeping a component need not reduce every fibre to
   one member, and whether iterating the rule reaches a uniformly singleton-fibred certified subset
   — or whether that is even the right target, as against seriality directly — is open. Ruling 38's
   prohibition on assuming a GREATEST certified subset is the standing reason not to shortcut this.

## 6. WHAT THIS STANDS IN FOR IN THE PUBLISHED ELIMINATION, AND WHAT IT DOES NOT

Read against record §16 of `round-34-readoff-construction-pair.md` and
`reports/31_gkwz-ptl-s5-quasimodels.md`:

- **What it stands in for.** GKWZ 2003 §5.2's converse direction forms its maximal satisfying set
  **by elimination** — repeatedly discarding quasistates whose required successors have themselves
  been discarded — and Lemma 5.24's converse then builds a model over what survives. The device
  this round compiles is the same *kind* of step: restrict the certified set, then read the
  relation off what survives. Report 31's account of every converse direction read — *quasistates
  exact, runs existential, and every converse CONSTRUCTS its model* — is the shape being followed.
- **What it does NOT stand in for.** GKWZ's elimination is an iteration to a fixpoint over a finite
  family, with a termination argument and a maximality claim. **This round has none of the three**:
  one removal, at one fixture, with no iteration, no termination argument, and no maximality claim
  (Ruling 38). Nor is the removal rule GKWZ's: theirs discards on a *failed requirement*, this one
  on *connectivity*, and the two coincide here only because the fixture's two components are each
  internally complete.
- **The transfer is by SHAPE, and no published theorem applies.** This is restated because the
  task description's own CONTINGENCY paragraph records the correction: HWZ 2000 Theorem 14 is a
  satisfiability iff for monodic first-order temporal logic with **no `□` and no `⊡` modality at
  all**, GKWZ §13.2 / Theorem 13.6 is written for `L = K` with the S5 case left to the reader in
  one sentence, and this setting is **not** PTL × S5 because `stab_state_only` makes the stability
  modal state-keyed across times. No theorem in either source applies to this semantics, and
  nothing in this round is justified by citation.

## 7. WHAT THIS ROUND DOES NOT ESTABLISH

- **Guardrail (b) — infinite width — stays UNMET** and is not addressed, narrowed or reported as
  met (Ruling 39). The constructed model's finite width is a property of the output forced by the
  pinned equation, and this round neither repairs nor relies on it.
- **No general statement.** No declaration of this round quantifies over certified sets, and
  **none takes a certified subset as a binder**: `attRp` and `attRm` are produced from `attR` by
  the removal rule, never assumed (Ruling 38, and Phase 23's NO-HYPOTHESIS check).
- **The truth lemma is still open.** `conStep_two_step_lift_refuted` stands untouched.
- **Nothing is revived.** `ladderRealized` and `cellAt_const_of_kappa_eq` remain refuted,
  unclaimed and unlanded; the object-dependent clip remains the OPEN QUESTION Phase 22 recorded,
  neither closed nor narrowed here; and the row-link route stays STOPPED.
- **`ladderConstruct` is declared nowhere**, before or after this round.

## 8. Carried-figure check (the dispatch's own premise lines, verified against live state)

| Figure carried into this round | Live measurement | Verdict |
|---|---|---|
| `ConKey:2341`, `conStep:2367`, `conStepStrong:2575`, `conStep_of_strong:2590`, namespace `ConAttack` from `:2639` | all confirmed at those lines | **unchanged** |
| `attR:2707` | live `attR` is at **`:2708`** | **drift of 1 line**; the plan's figure is off by one, the object is the same |
| `att_certAdmK`, `not_rel_m0p_m2m:2755`, `not_rel_m0m_m1p:2767`, `sK0:2908`, `sK1:2911`, `sK2:2914` | confirmed (`att_certAdmK` at `:2904`) | **unchanged** |
| "No elimination operator exists: `conElim`, and any `_elim`-suffixed declaration over a certified set, return no hits" | re-grepped at entry: `conElim` zero hits; the `_elim` hits are all unrelated (`double_neg_elim`, `until_elim`, `omega_chain_*_eq_elim`) | **confirmed** |
| `LadderRealize.lean` is 3,067 lines against an in-source `longFile 3100` at `:196`, 33 lines of headroom, "this phase WILL cross it" | 3,067 confirmed; the phase crossed it; baseline raised **in place** to `3500` in the same commit; file now 3,491 | **confirmed, and acted on** |
| `KTypeSummaryAxiomTest.lean` is 3,990 against an in-source `longFile 4100`, 110 lines of headroom | 3,990 confirmed; now 4,070 after the pins, 30 lines of headroom, no baseline change needed | **confirmed** |
| Description line: "the construction half is UNWRITTEN in all four of its components" | **no longer accurate as written** — Phase 21 landed carrier, frame and valuation (`ConKey`, `conFrame`, `conModel`, `conKeyMap_covers`); only the TRUTH LEMMA is unwritten | **stale in the description**; `docs/theorem-index.md` already carries the corrected "landed in three of its four components" |
| Description line: "`Dmax` is not even known to be certified" | `dmax_certStabK`/`dmax_certBoxK` still have no hits; unchanged by this round | **confirmed** |
| Description line: "`ladderRealized` is declared nowhere" | re-grepped: `grep -rnE '(theorem\|lemma\|def\|abbrev) +(cellAt_const_of_kappa_eq\|ladderRealized)\b' FormalSystem/ Tests/` returns nothing | **confirmed** |

---

# Phase 24 — The ELIMINATION LEMMA at a GENERAL certified `R`

Entered on Phase 23's recorded outcome **(a) SURVIVES**, read from that phase's `#### Recorded
Outcome` table rather than assumed. Phase 26 is therefore not entered by Phase 23's branch rule;
whether it is entered by *this* phase's verdict is section 13.

## 9. THE LEMMA, STATED BEFORE ANY LEAN WAS WRITTEN

### 9.1 The statement

```lean
theorem exists_certified_serial_subset {Q : Type} [Fintype Q]
    (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (Tc Tn P B : ℕ)
    (R : Set (Q × ClType φ × CK Tc Tn P B))
    (hR : certAdmK step pend lab φ Tc Tn P B R) (hne : R.Nonempty) :
    ∃ R' : Set (Q × ClType φ × CK Tc Tn P B),
      R' ⊆ R ∧ R'.Nonempty ∧ certAdmK step pend lab φ Tc Tn P B R' ∧
        ∀ (t : ℤ) (s : ConKey φ Tc Tn P B R'),
          ∃ s', conStepStrong step pend lab φ Tc Tn P B R' t s s'
```

`R'` is bound EXISTENTIALLY in the conclusion and appears in no binder (Ruling 38). The fourth
conjunct is not part of the `(Q-2)` pin: it is the property the construction actually needs and
the one `conStepStrong_serial_refuted` denies at the un-eliminated `attR`.

### 9.2 The token-for-token diff against the `(Q-2)` sub-block's first three conjuncts

The governing text is the `(Q-2)` sub-block, never the retired `(Q-1)` one. Its conclusion opens

```
    exists R' : Set (Q × ClType phi × CK Tc Tn P B),
      R' ⊆ R ∧ R'.Nonempty ∧ certAdmK step pend lab phi Tc Tn P B R' ∧
```

| Token of the pin | In 9.1 | Verdict |
|---|---|---|
| `R' ⊆ R` | `R' ⊆ R` | identical |
| `R'.Nonempty` | `R'.Nonempty` | identical |
| `certAdmK step pend lab phi Tc Tn P B R'` | `certAdmK step pend lab φ Tc Tn P B R'` | identical modulo the pin's ASCII `phi` for `φ` |
| `R' : Set (Q × ClType phi × CK Tc Tn P B)` | same type, `φ` for `phi` | identical modulo the same transliteration |
| `(hR : certAdmK …) (hne : R.Nonempty)` | carried unchanged | identical |
| `[Fintype Q] [Nonempty Q]` | `[Fintype Q]` only | **DIVERGENCE, and it is a WEAKENING of the hypothesis set, not of the conclusion**: `hne : R.Nonempty` already inhabits `Q` through a member's object component, so `[Nonempty Q]` is redundant here. Taking fewer instances proves more. Reported, not accepted silently |

**No Statement Fidelity finding against the conclusion.** The three conjuncts are the pin's, token
for token. The one divergence is in the instance binders and is in the strengthening direction.

### 9.3 THE FINITENESS INSTANCE CHECK, run at entry and COMPILED rather than read off type
definitions

Phase 24's own task list required this be checked at entry rather than assumed, and recorded that
the plan "does not assert one exists". **It exists — all four, by instance search, with nothing to
land.** Compiled standalone against the module (`lean_run_code`, zero diagnostics):

| Instance | Resolved by | Needed for |
|---|---|---|
| `Fintype (ClType φ)` | Mathlib's `Finset` subtype instance — `ClType φ` is an `abbrev` for `{T : Finset PlusFormula // T ∈ (plusSubformulaClosure φ).powerset}`, so the subtype-of-a-`Finset`-membership instance applies through the reducible unfolding | the ambient finiteness a descending elimination's termination needs |
| `Fintype (CK Tc Tn P B)` | a product of five `Fin`s | the same |
| `Fintype (ClType φ × CK Tc Tn P B)` | the product instance | the same |
| `Fintype (Q × ClType φ × CK Tc Tn P B)` | the above plus `[Fintype Q]` | the same |
| `DecidableEq (ClType φ)` | `Finset`'s `DecidableEq` through the subtype | any decidable removal rule |
| `Finite (Q × ClType φ × CK Tc Tn P B)` | from `[Fintype Q]` alone | the well-founded descent |

**No `Finite`/`Fintype` instance is landed by this phase**, because none is needed: the plan's
hypothesis that "the types look finite from their own definitions" is CONFIRMED by compilation,
and the `grep` that found no instance found none because none had to be written. That is a
positive finding about the route, recorded as one.

## 10. THE REDUCTION, AND WHY IT IS THE PHASE'S REAL CONTENT

Phase 24's task list asked for the elimination as the ITERATE of Phase 23's removal rule, with a
fixpoint lemma. Working the general case turned that decomposition inside out, and the reason is
worth recording because it is a fact about the rule and not a preference about proofs.

**Phase 23's removal rule does not generalize as an iterate.** The rule keeps the
`relK`-connected component, inside `R`, of one chosen member of a multi-member fibre. At
`ConAttack.attR` that works because `relK` there is two DISJOINT two-cycles, so the component of
`m0p` excludes `m0m` and the fibre is cut. At a general certified `R` nothing forces that: if the
two members over one key are `relK`-connected inside `R`, the component of either one contains
both, the rule returns a set with the fibre intact, and the iterate has no descent to perform. So
the iterate's fixpoint is "`relK`-connected", which is NOT the property the construction needs.

**What the construction actually needs is a property of the SET, and it is nameable.** Call `R`
key-injective when every key carries at most one member. The landed `KeyFibreInj` says exactly
that, on the set alone — no relation, no chosen member, no iteration.

| Landed | What it says |
|---|---|
| `KeyFibreInj` | every key of `R` carries at most one member |
| `conStepStrong_serial_of_keyFibreInj` | **THE REDUCTION.** The uniform key-level relation IS serial on any key-injective certified set, from condition (2) alone. No `ParamsOk`, no finiteness instance, no width assumption |
| `exists_certified_serial_subset_of_keyFibreInj_subset` | Phase 24's target follows from a key-injective certified nonempty subset, with nothing left over. The subset is existential in the HYPOTHESIS, so no binder of the statement is a certified subset (Ruling 38) |
| `ConAttack.attRp_keyFibreInj`, `ConAttack.attRm_keyFibreInj` | Phase 23's two candidates are key-injective |
| `ConAttack.serial_attRp_via_general`, `ConAttack.serial_attRm_via_general` | **SUBSUMPTION.** Phase 23's two seriality results, which that phase proved by enumerating each candidate's keys, are INSTANCES of the general reduction — so the general statement is not vacuous where the question has been decided |

`conStepStrong_serial_of_keyFibreInj` is the exact complement of `conStepStrong_serial_refuted`:
the refutation denies the same seriality at `attR`, where one key carries TWO members with
disjoint successor keys. The two together say the obstruction is fibre ARITY and nothing else.

## 11. THE OBSTRUCTION, COMPILED — condition (5) is NOT monotone, at a `⊡`-BEARING closure

Section 1.3 of this record stated the non-inheritance of conditions (5) and (6) under shrinking as
a **hazard and explicitly not as a prediction**, and Phase 23 discharged both at its fixture by
`no_stab_closure`/`no_box_closure` — a fact about the closure of `g U e`. Phase 23's own §5 then
named "conditions (5)/(6) under shrinking at a `⊡`-BEARING closure (a verdict on a `⊡`-free
closure would not discharge it)" as one of three debts Phase 24 inherits. **That debt is now
PAID, in the negative direction.**

| Landed | What it says |
|---|---|
| `certStabK_iff_collapse_of_keyFibreInj` | on a key-injective set condition (5) is EQUIVALENT to the collapse of the `⊡` letter onto its argument at every member — `⊡ψ ∈ x` iff `ψ ∈ x`. The clause is carried in full; this is an equivalence to it, never a weakening of it |
| `StabShrink` (`phiS = ⊡p`, one object state, all-zero parameters) | the minimal shape in which the clause's `←` direction can fail |
| `StabShrink.exists_stab_in_closure` | **the non-vacuity guard**: the closure DOES bear a `⊡` letter |
| `StabShrink.bigR_certStabK` | condition (5) HOLDS on `bigR = {n0, n1}` |
| `StabShrink.subR_not_certStabK` | and FAILS on the nonempty subset `subR = {n1}` |
| `certStabK_not_monotone` | the headline existential, carrying the `⊡`-bearing conjunct inside the statement so the verdict cannot be read as one about a `⊡`-free closure |

**The mechanism, which is the clause's own shape.** Condition (5) is an iff whose right side is a
universal quantifier over the set's fibre. Deleting a member makes that side MORE often true, so
the `←` direction fails at a member that did not carry the letter. Concretely: `n0` carries
neither `⊡p` nor `p`, `n1` carries `p` and not `⊡p`. On `{n0, n1}` the right side at `n1` is
false, because `n0` has no `p`, and `⊡p ∉ n1` matches it. Delete `n0` and the right side becomes
`p ∈ n1`, which is TRUE, while `⊡p ∈ n1` is still false. The clause breaks.

**What this does and does not say.** It says NO removal rule can be proved to preserve
certification by inheritance alone, and it says what a key-injective candidate owes: a certified
`R` gives only the `⟹` half of the collapse at a member whose own fibre is larger (take `y := x`
in its own clause), so the candidate owes the `⟸` half at every member it keeps, and `R`'s
certification does not pay it. It does **NOT** say that no certified key-injective subset exists
at any particular `R`. The general elimination lemma is **OPEN — neither landed nor refuted** —
and section 13 states the branch that follows.

## 12. THE SIX-CONDITION CHECK, ANSWERED HONESTLY

Phase 24's verification asks the record to name each of `certAdmK`'s six conditions and the
declaration discharging it **on the fixpoint**. There is no fixpoint: no key-injective certified
subset of a general `R` is produced here, so there is no object to discharge six conditions on.
The check is answered by stating that, not by listing six declarations about something else.

| Condition | Status on a general key-injective candidate |
|---|---|
| (1) `certLocK` | inherited by any subset — `locCoh` is a predicate on a single member |
| (2) `certBiInfK` | **the open one on the positive side**: a key-injective subset must still give every member a successor and a predecessor INSIDE ITSELF, and a candidate chosen for key-injectivity need not |
| (3) `certFwdK` | **open**: `DischPathK` is an existential path, and the path witnessing it in `R` can leave the candidate |
| (4) `certBwdK` | **open**, for the same reason along the reversed relation |
| (5) `certStabK` | **REFUTED as inherited** — `certStabK_not_monotone`; and characterized on a key-injective candidate by `certStabK_iff_collapse_of_keyFibreInj` |
| (6) `certBoxK` | not inherited either, by the same shape, and NOT measured here. Its right side is a universal over the WHOLE set rather than over the fibre, so key-injectivity does not collapse it and a separate witness is owed. **Recorded as unmeasured, not as discharged** |

## 13. THE BRANCH, AND WHAT THIS PHASE RETURNS

**Phase 24 returns `[PARTIAL]`**, which is the outcome its own `Timing` paragraph provides for:
"the stated lemma plus the instance check is its first deliverable and is complete and reportable
on its own; if the fixpoint's certification has not landed by the end of the first dispatch, the
phase records what did and returns `[PARTIAL]`."

**What landed**: the stated lemma diffed token-for-token against the `(Q-2)` pin (§9.2, one
divergence, in the strengthening direction); the finiteness instance check, compiled, with nothing
to land (§9.3); the reduction of the entire question to key-injectivity, with Phase 23's two
fixture results re-derived as its instances (§10); and the compiled obstruction that pays one of
the three debts Phase 23 named (§11).

**What did not land**: the general elimination lemma. It is OPEN, not refuted, and the step it is
open at is now exactly named rather than diffuse: produce a certified nonempty subset on which
every key carries one member, against conditions (2), (3), (4) which a key-injective selection
need not preserve and condition (5) which it provably need not inherit.

**This is NOT a `user_decision`.** Decision 29's recorded route already names the sanctioned
attack-first fallback for the case where (C) does not close — option (A), Phase 26's third step
relation as the greatest fixpoint of the largest composing subrelation of `conStep`, attacked for
seriality at `ConAttack.attR` BEFORE adoption. Nothing in this phase's outcome requires a
judgement the artifacts cannot supply, so the route continues on the recorded decision.

**One standing constraint, restated because it is easy to lose.** Guardrail (b) — infinite width —
is **UNMET**. Nothing in this phase addresses it, narrows it, or reports it met (Ruling 39). The
reduction is about seriality of a relation on a key-level carrier that is finite by construction;
making that relation serial does not make the carrier wide.

## 14. Carried-figure check (Phase 24's own premise lines, verified against live state)

| Figure carried into this phase | Live measurement | Verdict |
|---|---|---|
| Phase 23's recorded outcome is **(a) SURVIVES**, which is Phase 24's entry gate | read from Phase 23's `#### Recorded Outcome` table in the plan, not assumed | **confirmed; gate open** |
| `LadderRealize.lean` was 3,067 lines against `longFile 3100`, and "Phase 23 will have moved both figures" | at entry: **3,491 lines against `longFile 3500`, 9 lines of headroom** — Phase 23 moved both, exactly as predicted; this phase crossed it and raised the baseline **in place** to `3900`; file now 3,825 | **confirmed, and acted on** |
| `KTypeSummaryAxiomTest.lean` 110 lines of headroom | at entry **4,070 against `longFile 4100`, 30 lines**; the ten pins crossed it; baseline raised in place to `4200`, file now 4,141 | **drift (the plan's 110 was pre-Phase-23); re-measured and acted on** |
| "no `Finite`/`Fintype` instance for `ClType φ × CK …` was located by `grep`, and this plan does not assert one exists" | the `grep` finding is **confirmed** — none is written anywhere — and the inference one might draw from it is **WRONG**: all of them are derivable by instance search (§9.3). None had to be written | **confirmed as a grep result; corrected as a route finding** |
| `dmax_certStabK`/`dmax_certBoxK` have no hits | re-grepped at entry and at close: `grep -rnE '(theorem\|lemma) +dmax_(certStabK\|certBoxK\|certAdmK)\b' FormalSystem/` returns nothing | **confirmed, both times** |
| `ladderRealized`, `cellAt_const_of_kappa_eq` and `ladderConstruct` declared nowhere | re-grepped at close: nothing in `FormalSystem/` or `Tests/` | **confirmed** |
| `Realize.lean` is 1,004 lines (the task description's sizing figure) | `wc -l` reports **1,004** | **confirmed** |
| Description line: "the construction half is UNWRITTEN in all four of its components" | **still stale**, as Phase 23's §8 already recorded: carrier, frame and valuation landed in Phase 21; only the truth lemma is unwritten | **stale in the description**; `docs/theorem-index.md` carries the corrected reading |
| Description line: `CONTINGENCY` — "never sorry, axiom, vacuous definition, a trace-level hypothesis, or any finite-fibre/finite-width assumption" | `sorry_count: 0`; zero new `^axiom ` (count 14, unchanged); vacuous-grep **1**, the pre-existing `FormalSystem/Examples/TemporalStructures.lean:495` baseline; no finite-fibre or finite-width hypothesis in any landed signature | **confirmed** |

## 15. Gate readings at this phase's close, including one that is PARTIAL and says so

| Gate | Reading |
|---|---|
| `lake build` (full library) | **exit 0**, zero `error:` occurrences, `Build completed successfully (2976 jobs)`; through `lake-build-guard.sh`, detached with the bounded PID-liveness waiter. Tier-3: the touched module's `.olean` is newer than its source. Re-run green after the C23 rename |
| `lake build BimodalTest` | **exit 0**, `Build completed successfully (3044 jobs)`; the ten `#guard_msgs` axiom pins are inside it, so they are checked by this build |
| `lean-sorry-census.sh` | **exit 0**, `sorry_count: 0` |
| vacuous-definition grep | **1** — the pre-existing `FormalSystem/Examples/TemporalStructures.lean:495` baseline, unchanged |
| `^axiom ` count | **14**, unchanged; zero `+axiom ` lines in this dispatch's diff |
| `check-module-invariants.sh` | **PASS** — zero FAIL groups. It took two passes: the first flagged `FAIL C23` on three `RS'_*` names and on an `Sp` shadowing `Conservativity/SpWitness.lean:82`, plus `FAIL INV` on three stale generated inventory blocks. The fixture was renamed (`bigR`/`subR`/`clEmpty`/`clP`), the inventories regenerated through `--emit-inventory`, and both builds re-run green. **The gate found this, not review** |
| `readme-lint.sh` | **PASS** |
| `check-evidence-probes.sh` | **PASS** — `all 67 wired probe(s) compile`, zero FAIL, one pre-existing SKIP (`bi-lasso-decision-layer/spike-untl-unfolding-and-fwd-obstruction`, deferred for frame-class uniformity work); guard exit 0. An earlier reading in this dispatch recorded 65-of-76 as PARTIAL because the run had not finished and the denominator was taken from a file count rather than the wired-probe count; the completed run supersedes it |
| `verify-deploy.sh` | **NOT RUN** in this dispatch, and recorded as not run rather than passed |

## 16. A CONCURRENT WRITER, OBSERVED AND REPORTED

A foreign commit landed in this repository while this phase was running: **`0ad12f9ae` "task 935:
create determinization-free progress-measure design (route R3)"**, interleaved between this
phase's `24.2` and `24` commits. It is reported here rather than dismissed, as the territory
contract requires of any foreign commit observed mid-dispatch.

**It did not interfere.** `git show --name-only` reports it touches `specs/TODO.md` and
`specs/state.json` and nothing else — zero overlap with this dispatch's owned files (the Lean
module, the axiom test, `docs/theorem-index.md`, the three READMEs, `typst/generated/status.typ`,
and this task's own plan/record/summary). This phase's commit sits cleanly on top of it, and no
action was taken against it.
