# Phase 7 — ACTIVE-arm repair, sepRule, and the two open measurements

Twentieth Phase 7 dispatch. Four green commits. **Ledger 31 → 32 of 34.**

## What moved the ledger, and what did not

The increment is `ruleSound_sepRule` **alone**. The authorized ACTIVE-arm repair moved it
**not at all** — `RuleSound` is per rule over *both* arms, and the PASSIVE arms of
`untlNeg`/`snceNeg` remain refuted. Both commit messages say so explicitly.

## 1. Probe rows D1/D2 — landed pre-repair, committed first

New section D of `Tests/BimodalTest/UntlSnceCopyProbe.lean` converts the ℚ refutation from a
hand argument into a measured fact, pinned at pre-repair values *before* the edit.

## 2. The authorized ACTIVE-arm repair — both mirrors

Deleted the self-propagated `F(U(event,guard))@freshLabel` from branch 2 of the `.untlNeg`
ACTIVE arm and the `.snceNeg` mirror. This was the **third** defect in these two rules,
independent of the copy block and of the PASSIVE arms, and refuted over a **dense** carrier
where the copy needed a **discrete** one.

| Gate | Before | After |
|---|---|---|
| TableauConformance, 29 rows | GREEN 58.5 s | GREEN 64.2 s, **zero rows changed** |
| TemporalWitnessProbe | GREEN | GREEN, **zero rows moved**; H–N still `nStr=true nCo=true` |
| UntlSnceCopyProbe A/B/C | GREEN | GREEN, unchanged |
| UntlSnceCopyProbe D | pinned | exactly 4 rows moved, all intended, all re-pinned |
| `Verified.Decidable` | — | GREEN at 1353 jobs (full downstream) |

`D1a`/`D1b`/`D1e` and mirrors are unchanged, which is what makes the `false` on `D1c`/`D2c`
non-vacuous: the arm still fires, still branches in two, still mints time `3`.

No `guardWitnessed` variant was implemented. No PASSIVE-arm logic was touched.

## 3. `ruleSound_sepRule` — proved; the `.Dedekind` family is complete

The blocker was real but mis-priced as unreachable. `exists_countable_order_dense` already
exists in `SoundnessLemmas/Separability.lean`, which imports **only** Mathlib and mentions
neither formulas nor truth — so the import edge is acyclic by inspection and strictly weaker
than the `FrameClassVariants` edge already present. Not `Metalogic/Soundness.lean` (still
refused), not `WeakCanonical`. Mathlib was searched first and does not carry the lemma usably.
`truthAt_sep` transcribes Reynolds §7 lemma 10's remaining ~45 lines. Axiom-clean.

## 4. The two open measurements — both resolved, both against the capped design

**R3's magnitude**: the cap is a **switch, not a net**. `timeCount ≥ 4` (the existing ACTIVE
guard's threshold) is crossed after **5** first-arm steps; `timeCount ≥ 8` after **21**, against
a fuel of 200.

**The G-propagation channel**: it **fires**. From a branch whose only `U(e,g)` is positive and
buried under a `G`, distinct times carrying a *negative* `U(e,g)` run `[0,1,1,3,5,9]`, at five
distinct labels by step 32. The supply of `(source, label)` pairs is not fixed in advance.

These are inputs to the rank-2-vs-rank-3 passive-arm choice, which is the orchestrator's. It was
not taken here.

## 5. Item B10 — comment-only, both copies

`Saturation.lean`'s `.splitOrdered` arm claimed unreachability "because every ordered split
lengthens the constraint list". False: `timeLinearity`, the only rule returning
`.branchingOrdered`, returns the *unchanged* `timeOrd` outwardly, so the guard lets it through.
The arm is dead for a different reason — `.timeLinearity` is excluded from `allRulesForFC`. The
same false claim was mirrored in `CancellableExpansion.lean` and is fixed there too; both now
record the trap.

## Verification

Full `lake build` GREEN at **1983 jobs**, matching the baseline exactly. Sorry census over the
Decidability tree: **0**. Zero new axioms. Zero vacuous definitions.

## Still open

`untlNeg`/`snceNeg` remain blocked on their **PASSIVE arms alone** — two of three obstructions
are now closed. Phase 7.3 was not attempted.
