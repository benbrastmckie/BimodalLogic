# PlusWitnessFamily — the L⁺ certificate, and the stability condition it exists to state

This directory is the L⁺-indexed twin of `../WitnessFamily/`. It exists for exactly one reason:
the stability condition **(C5) `StabFaithful`** is not stateable over `Formula`, and a condition
that cannot be stated cannot be checked.

## Why the re-index is forced, and is not a matter of taste

`FormalSystem.Syntax.Formula` has six constructors — `atom`, `bot`, `imp`, `box`, `untl`, `snce`
— and no stability modal. `⊡` is `FormalSystem.PlusLanguage.PlusFormula.stab`, a constructor of
a **separate inductive** that shares no supertype with `Formula`. The deterministic certificate
stack is monomorphic in `Formula` at every level (`Context = List Formula`,
`closureOf : Context → Finset Formula`, `WitnessFamily.bx : Formula → Bool`), so no
instantiation and no coercion states (C5) over it. `../WitnessFamily/Sharing/Predicates.lean`'s
header records the same fact from the other side.

The alternative that was considered and **explicitly rejected** was to run the existing
`Formula` certificate on an atomized target, which would have been roughly four times cheaper but
would have added a pairing field to the *shipping* certificate. The shipping deterministic export
contract is unchanged in name, meaning and shape; this subtree is a parallel addition.

## The six conditions

| | Condition | Where | Decided by |
|---|---|---|---|
| (C0) | `PlusAtomCoherent` — indices naming the same state carry the same atoms | `Predicates.lean` | `decidablePlusAtomCoherent` (`Decide.lean`) |
| (C1') | `PlusLocalCoherentShare` — local coherence, temporal clauses taken across shared states. Its `snce` clause quantifies the predecessor over the `share`-class at the label's **own** time, which forces that class to agree on every past-tense label; see *What this certificate cannot refute* below for the price | `Predicates.lean` | `decidablePlusLocalCoherentShare` (`Decide.lean`) |
| (C2') | `PlusThreadFulfilling` — every **thread** discharges its eventualities | `Predicates.lean` | jointly with (C1'), `decidablePlusCoherentShareAndFulfilling` (`Fulfil.lean`) |
| (C3) | `PlusBoxFaithful` — the box guess is right at every position | `Predicates.lean` | `decidablePlusBoxFaithful` (`Decide.lean`) |
| (C4) | `PlusTarget` — a time where every premise is labelled and no conclusion is | `Predicates.lean` | `decidablePlusTarget` (`Decide.lean`) |
| (C5) | `StabFaithful` — **the stability condition** | `Predicates.lean` | `decidableStabFaithful` (`Decide.lean`) |

`PlusCertifies` (`Agreement.lean`) bundles all six. The count is load-bearing: a five-component
bundle would mean (C5) was a hypothesis of the theorem but not a *checked* condition, which is
the exact regression this work exists to prevent.

(C1') and (C2') are nested as a single conjunct because (C2')'s window reduction is stated
relative to (C1') — the far-left case of `plusThreadFulfilling_of_window` walks an obligation into
the window by (C1') propagation rather than folding it in — so no standalone
`Decidable PlusThreadFulfilling` instance exists. What exists is a `Decidable` *term* taking a
(C1') proof, plus the genuine instance on the conjunction.

## (C5), stated

```lean
def StabFaithful (S : PlusSharingWitnessFamily Γ Del) : Prop :=
  ∀ (i : Fin S.lassos.length) (u : ℤ) (φ : PlusFormula),
    PlusFormula.stab φ ∈ plusClosureOf (Γ ++ Del) →
      (PlusFormula.stab φ ∈ S.L i u ↔ ∀ j, S.share u i j → φ ∈ S.L j u)
```

`⊡φ` is labelled at `(i, u)` exactly when `φ` is labelled at every index naming the same world
state at `u`. Three properties of that statement are the whole design:

1. **Decidability is preserved by construction.** The quantifier ranges over
   `Fin S.lassos.length` at *one* time — never over the frame's infinitely many walks.
2. **It is not vacuous.** On a deterministic frame `share u i j ↔ i = j`, the class is a
   singleton and the condition degenerates to `⊡φ ↔ φ` — which is exactly
   `PlusLanguage/PlusDeterminism.lean`'s `stab_iff_of_deterministic`, and is why the
   deterministic device is blind to the modal. The branching frame's task relation is not
   functional, so the classes are not singletons. `Examples.lean`'s `stabFamily_separates`
   exhibits a family where the condition has content.
3. **It is load-bearing, not decorative.** `Agreement.lean`'s `plusTruth_iff_mem` has seven
   cases, and the `stab` case consumes `StabFaithful`. A per-binder drop-and-re-elaborate check
   reports all six explicit hypotheses load-bearing, with `hstab`'s break located in the `stab`
   case and nowhere else.

## What this certificate cannot refute

The certificate is **sound** and **incomplete**, and the incompleteness is not a matter of the
bound being too small: for one family of targets the certificate class is *empty*.
`Incompleteness.lean` proves it, in seven declarations, on both temporal sides.

`snce_share_congr` is the root cause, and it is a consequence of (C1') alone. Reading the `snce`
clause twice — once at `i` with the shared index `j`, once at `j` with itself by reflexivity of
`share` — forces any two indices naming the same world state at `t` to agree on every `snce`
formula of the closure. Past-tense truth in a presented model is therefore a function of the world
state.

`not_plusCertifies_stabSnce` is the consequence: **no** `PlusSharingWitnessFamily` certifies any
instance of the schema `(g S e) → ⊡(g S e)`, at any time and at any size.
`not_plusCertifies_stabSnce_premise` shows the same for the negated-premise placement, so moving
the target between the premise and conclusion lists is not an escape. Only (C1')'s
`imp`/`bot`/`snce` clauses, (C4) and (C5) are used — not (C0), not (C2'), not (C3), and no bound.
(C5) demands a `share`-class member missing `g S e` wherever `⊡(g S e)` is absent, and
`snce_share_congr` says the class has none.

`not_plusValidZTime_stabSnce` closes the gap: at `g := ⊤`, `e := p` the instance is `Pp → ⊡Pp`,
refuted on the permissive ℤ-frame of `PlusLanguage/PlusNonValidities.lean`. So the empty class is
not the vacuous fact that the schema is valid. The certificate misses a real ℤ-time non-validity,
and the L⁺ analogue of the deterministic route's `exists_witnessFamily_of_not_validZTime` is
**false** against these six conditions.

**Soundness versus completeness, explicitly.** `plusTruth_iff_mem` and `plusRefutes_of_certifies`
are untouched: a family that does meet the six conditions still presents a genuine countermodel,
and nothing here weakens that. What fails is completeness of the certificate *class*. Nor is this
a refutation of stability-modal decidability — it says only that this certificate cannot be the
route, because a procedure enumerating certified families would answer "valid" for `Pp → ⊡Pp`.

**The `untl` side fails too, and this is machine-checked rather than inspected.** An earlier
version of this section called the future-tense half defect-free by inspection, on the ground
that its clause quantifies over the class at `t+1` rather than at the label's own time. That
reading was wrong. `untl_shift_share_congr` reads the one clause at `t - 1`, where `share t i j`
*is* `share ((t-1)+1) i j`, and recovers the same forced class agreement on the one-step
unfolding at `t`. `not_plusCertifies_stabUntl` turns that into an empty certificate class for
`Fp → (¬p → ⊡Fp)`, and `not_plusValidZTime_stabUntl` makes that emptiness a completeness failure
rather than a vacuity. The extra `¬p` antecedent is exactly what the shifted congruence needs:
the congruence controls the unfolding `p ∨ (⊤ ∧ Fp)`, so the `p` disjunct has to be ruled out at
the witnessing index.

**Where the fix belongs.** Not in a re-wording of (C1'), and not in re-timing one clause's
quantifier to match the other's. The rule of thumb the proofs expose is general: any condition
quantifying over the one-step *reach* of a position collapses whenever that reach is a whole
`share`-class, at either time and in either temporal direction. Since both clauses' reaches are
`share`-classes, narrowing or re-timing either one while leaving the substrate alone relocates
the problem rather than removing it. The repair is at the substrate level, and
[the Sharing README](../WitnessFamily/Sharing/README.md) records what it requires.

## A parallel export, not a widened one

`PlusWitnessFamily.PlusRefutes` is a **new** existential over `PlusTruthAt`, declared beside
`WitnessFamily.Refutes` rather than replacing it. The two quantify over different truth
predicates because they are about different languages.

Nothing in this directory edits `../WitnessFamily/`, `Semantics/ShiftSet.lean`, or any part of the
deterministic bi-lasso device. The deterministic path is byte-identical and its JSON export
contract was not re-opened.

## What is inherited rather than rebuilt

The branching substrate is shared with the `Formula` side verbatim:

- `../WitnessFamily/Sharing/Skeleton.lean` — `SharingSkeleton`: `share`, the threads, the
  quotient frame, its four frame constraints, the world histories and `total_eq_thread`. Mentions
  no formula.
- `../WitnessFamily/Sharing/Window.lean` — `SharingWindow`: the combined window, the position
  graph, the two wrapped time-steps, the two edge relations, the folding relations and the walk
  layer. Also mentions no formula.
- `../WitnessFamily/Sharing/Fulfil.lean`'s `AUFix` — the `A[g U e]` operator, its iteration, the
  stabilization bound and `lfp_induction`, stated at an arbitrary vertex type and reused as-is.

What is new is everything that reads a label.

## Modules

- `Closure.lean` — `plusClosureOf` and the seven constructor projections
- `Basic.lean` — `PlusLabelledLasso`, `PlusWitnessFamily`, `PlusSharingWitnessFamily`, and the
  projections onto `SharingSkeleton`
- `Predicates.lean` — the six conditions
- `Decide.lean` — the combined window, the `window` projection onto `SharingWindow`, and the
  decision procedures for (C0), (C1'), (C5), (C3), (C4)
- `Fulfil.lean` — the two fixpoints at `PlusFormula` and the (C2') window reduction
- `Agreement.lean` — the presented model, `plusTruth_iff_mem`, `PlusCertifies`, `PlusRefutes`
  and `plusRefutes_of_certifies`
- `Examples.lean` — the two-lasso non-vacuity witness and the deterministic diagonal
- `Incompleteness.lean` — `snce_share_congr` and the three declarations showing the certificate
  class is empty for a `snce` under a `⊡`

## Dependencies

- **Imports from**: `FormalSystem.PlusLanguage.Formula`,
  `FormalSystem.PlusLanguage.Subformulas`, `FormalSystem.PlusLanguage.PlusTruth`,
  `FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Skeleton`,
  `...Sharing.Window`, `...Sharing.Decide`, `...Sharing.Fulfil` and (in
  `Incompleteness.lean` only) `FormalSystem.PlusLanguage.PlusNonValidities`
- **Imported by**: the re-export
  `FormalSystem.Metalogic.Decidability.PlusWitnessFamily` beside this directory, which
  `FormalSystem.Metalogic.Decidability` imports, and the generated library root
  `FormalSystem.lean`

## Related Documentation

- [WitnessFamily README](../WitnessFamily/README.md)
- [Decidability README](../README.md)

---

*Last verified: 2026-09-29*
