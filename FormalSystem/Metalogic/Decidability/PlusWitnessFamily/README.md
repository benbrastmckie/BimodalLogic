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
| (C1') | `PlusLocalCoherentShare` — local coherence, temporal clauses taken across **succession**: the `untl` unfolding over `trans t i j`, the `snce` unfolding over `trans (t-1) k i`. An earlier version quantified both over `share`-classes, which collapsed the branching; see *What this certificate can and cannot refute* below | `Predicates.lean` | `decidablePlusLocalCoherentShare` (`Decide.lean`) |
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

**That limitation was re-examined under the succession redesign, not inherited by default.** It
survives, and the reason is now known: the window reduction's far-left and far-right cases
consume exactly the relation a thread's step supplies, so re-quantifying (C1') over `trans`
transferred the argument verbatim and needed no new hypothesis. The limitation is about the
position graph's backward region being a path rather than a cycle — a fact about the *graph* —
which is why changing the substrate datum did not touch it. Closing it would need that region to
carry a cycle edge alongside its existing one, with the fixpoint lemmas re-proved against the
strictly larger walk set.

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

## What this certificate can and cannot refute

The certificate is **sound**, and it is now known to be non-vacuous on the hardest targets it
has: a stability modal over a tense operator, in both temporal directions. That was not always
so, and the history is worth keeping, because the repair is only intelligible as an answer to a
specific defect.

### What went wrong, and is now fixed

(C1')'s `snce` clause used to quantify its predecessor over the `share`-class at the label's own
time. Reading that clause twice — once at `i` with the shared index `j`, once at `j` with itself
by reflexivity of `share` — forced any two indices naming the same world state at `t` to agree on
every `snce` formula of the closure. Past-tense truth in a presented model was therefore a
function of the world state, which is exactly what `⊡` quantifies over, so (C5) could never find
the class member it demands. No family certified any instance of `(g S e) → ⊡(g S e)`, in either
placement. The `untl` clause carried the same defect displaced by one step, and closed the other
direction too.

Five declarations recorded that, and all five are retired. `Incompleteness.lean`'s header says
what the module holds now.

The repair was at the substrate level, as the rule of thumb predicted: any condition quantifying
over the one-step *reach* of a position collapses whenever that reach is a whole `share`-class,
at either time and in either direction, so narrowing or re-timing a clause while leaving the
substrate alone relocates the problem rather than removing it.
[The Sharing README](../WitnessFamily/Sharing/README.md) records the fourth periodic datum that
separates succession from state-identity, and (C1')'s two clauses now quantify over it: the
`untl` unfolding over `trans t i j`, the `snce` unfolding over `trans (t-1) k i`.

### What the certificate refutes now

Two families in `Examples.lean`, one per temporal direction, each at **non-trivial** sharing:

| Family | Target | Certificate | Sharing |
|---|---|---|---|
| A | `Pp → ⊡Pp` | `plusCertifies_stabSnce_example` | indices `0` and `1` name one state from the origin on, and disagree on `Pp` there (`famA_separates_snce`) |
| B | `Fp → (¬p → ⊡Fp)` | `plusCertifies_stabUntl_example` | indices `0` and `1` name one state up to the origin, and disagree on the unfolding `p ∨ (⊤ ∧ Fp)` there (`famB_separates_untl`) |

Both get their non-trivial sharing from index-identity succession: the indices share states
without any thread crossing between them, which is precisely the separation the single relation
made inexpressible. `targetA_eq` and `targetB_eq` record that each family's target is the schema
instance `Incompleteness.lean` names, on the nose, and `not_plusValidZTime_stabSnce` /
`not_plusValidZTime_stabUntl` record that both are genuine ℤ-time non-validities — so these are
certificates for real countermodels, not for validities.

### Why this is not a redesign that reproduced the defect in new spelling

A redesign can break an old proof term while still entailing the old statement, so "the
congruence no longer elaborates" would settle nothing on its own.
`Incompleteness.lean`'s `not_snce_share_congr` and `not_untl_shift_share_congr` *refute* the two
retired statements, on Family A and Family B respectively. The redesigned (C1') is satisfied by
families on which those congruences are false, which is the strongest form the check can take.

**Soundness was never at issue.** `plusTruth_iff_mem` and `plusRefutes_of_certifies` are
byte-identical in statement across the whole redesign: a family meeting the six conditions always
presented a genuine countermodel. What failed, and is now repaired, was completeness of the
certificate *class* **on these two targets**.

Completeness in general is **refuted**, not repaired. `Limits/NoCertificate.lean`'s
`not_exists_plusCertifies_pumpTarget` exhibits a ℤ-time non-validity no family of the class
certifies, under no hypothesis at all; `Limits/HopFree.lean` refutes the hop-free strategy
separately. The repair recorded above is a repair at `Pp → ⊡Pp` and `Fp → (¬p → ⊡Fp)`, and the
fragment the class does cover is open.

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
- `Examples.lean` — the (C5) non-vacuity witness, the deterministic diagonal, and the two gate
  families with their certificates (`plusCertifies_stabSnce_example`,
  `plusCertifies_stabUntl_example`)
- `Incompleteness.lean` — the three stability targets, their ℤ-time non-validity, and the two
  refutations of the retired congruences
- `TransId.lean` — the hop-free collapse: a family whose succession relation never leaves the
  index it is read at collapses (C1') to its one-position form and (C2') to its per-lasso form
- `Compression/` — the compression layer: the L⁺ type, the combinatorial core, fulfilment at a
  bare label sequence, the readout and the segment bound, and the (C5) demand's semantics. The
  L⁺ compression theorem it was built toward does **not** exist for this certificate class
  (5 files)
- `Limits/` — the two refutations that withdraw it: `hopTarget` certified by no hop-free
  family, and `pumpTarget` certified by **no** family of the class at all (3 files)

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
- [The L⁺ compression layer](Compression/README.md)
- [The limits of the L⁺ certificate class](Limits/README.md)
- [The time-sliced L⁺ certificate](../PlusSlicedCertificate/README.md)
- [Decidability README](../README.md)

---

*Last verified: 2026-10-02*
