# Closeout of the Opus 5.5 final review

**Status of this round:** no tools were used, no source was checked and no prototype was run. My recorded **82.5/100** stands as the historical pre-closeout review, and the original mutual grades are unchanged. No new grade is given.

## Required-fix status

| # | Requested change | Status |
|---|---|---|
| 1 | Language-parametric `Step` | **Implemented.** `Step (L, J, imp)` is a local adapter over the existing TM/Plus tree families. `transfer` is explicitly a closed formula. Plus `demandMono` is built from Plus necessitation plus the transferred K schema, following the `liftContext` pattern. The X route necessitates `P→Q` with G and then applies `untilMonoEvent` at guard ⊥, so it never asserts X(P→Q). The P0 substitution pin allows defeq or an explicit normalization lemma, which is acceptable. |
| 2 | Enumerated scope conversions | **Implemented.** The finite table covers □→{G,H,⊡}, □/G/H → □ᵏ/Gᵏ/Hᵏ, and exact X/Y. There is no adapter chaining, and mixed words are explicitly deferred. Projecting W(A↔B) through composed `demandMono` is now stated. |
| 3 | S2 scenario | **Implemented** in both §6.4 and §8: the success case with a semantic twin, and the refusal `[A, G(A→F B)] ⊢ F B` with the "no temporal T" prohibition. |
| 4 | P0 inventory | **Implemented.** The P0 gate verifies every transfer row. The inventory separates formula theorems from functions on derivations, records per-file layers, and has a direction column. The generic semantic module imports only the clause interfaces. |
| 5 | Completeness guard | **Implemented correctly.** `assert_not_exists` names the actual completeness declarations and explicitly does not use `Classical.choice`. |
| 6 | `lsimp` contract | **Implemented.** The measure is primitive constructor count after view preparation. Orientation is registered and decrease acts as a guard. Outcomes are separated: skip and no change means failure without mutation; budget or repeated state means rollback. |
| 7 | Obligation defaults | **Implemented.** One rule now covers both: the `lstep`/`luntil` family exposes obligations, `lrewrite` exposes only with `obligations := expose`, and an incompatible concrete tag is rejected. §3.4 and §5.2 agree. |
| 8 | Rank caveat | **Implemented**, with essentially the suggested wording. |

**Codex's semantic demand kernel** has the right shape:
- D□, D⊡ and DG/DH, with monotonicity and per-position oriented transfer, mirror the native kernel.
- U/S guard and event positions are both strictly future/past, so DG/DH are sound conservative demands.
- A point-specific Iff discharges only the identity demand.
- The P4 mixed-path prototype gate is appropriate.

## Source-audit corrections (reported by Codex, accepted as reported)

These replace guesses in my review:
- **`nextConsequence`/`prevConsequence` both exist**, so my suspicion that `prevConsequence` might not exist was wrong. They are contextual metalevel functions, so they are correctly excluded as `transfer` sources. The closed `nextK`/`prevK` and `untilMonoEvent`/`sinceMonoEvent` at ⊥ fill those rows.
- **`box_global`** is `FormalSystem.PlusLanguage.box_global`. Its table entry is corrected.
- **All audited transport rows are Iff under their hypotheses.** My concern about unrecorded one-way rows is therefore resolved: there are none. The fact-only refusal test correctly uses a supplied one-way provider.
- **`Theorems/ProofMode` is layer 2.** Classification is per file, with no blanket ban on individual semantic `PlusLanguage` imports. This supersedes my stricter suggestion.

Anything in the plan beyond these points, such as the exact names `temporalFutureDerived`, `box_stab` and `gTransitivity`, is still an inventory claim for P0 to confirm.

## Remaining issues

**There is no soundness or design blocker.** Three small specification points remain:

1. **(b) Iff projection field.** `Step` carries only `imp`. Projecting W(A↔B) needs the language's closed conjunction/iff projections. Name their source in P0: either an extra kernel parameter or per-language closed combinators. This is not a design change.
2. **(b) One-way test provider.** The supplied `R p q → At p A → At q B` provider should be a genuine proved theorem, not an axiom or `sorry`. Otherwise the refusal test certifies nothing. Choose a concrete true but non-invertible instance.
3. **(d) Redundant repeated-state check.** "Reject repeated states" is redundant under strict decrease. It is harmless as a defensive check, but it should not be documented as the termination argument.

## Readiness

- **Start P0 now.** Its gates are well specified: signed composition, a mixed Plus path with its substitution pin, Base conditional Next, Base Since fold, pointed soundness, and closed sources per row.
- **P1–P2** are implementation-ready once P0 passes and item 1 above is settled.
- **P3** depends on the contextual TM reflection theorem (induction on derivations, plus involution) and the Base Since fold.
- **P4** depends on the covering-time Next/Previous lemmas and the semantic mixed-path prototype.
- **P5** depends on the rank theorem and G-persistence.

These are ordinary proof obligations, labelled (c). The plan correctly describes none of them as proved, and none should be described that way until they are.