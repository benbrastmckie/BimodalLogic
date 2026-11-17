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
