# FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/

The **completeness (compression) half** of the witness-family route: every ℤ-time countermodel of
`φ` compresses to a `WitnessFamily [] [φ]` whose three lasso segments are bounded by a computable
function of the closure size and which is a member of a computable candidate list. Composed with
the soundness half that already lives one directory up (`Agreement.lean`'s
`WitnessFamily.refutes_of_certifies`, `Decide.lean`'s `decidableCertifies`), this yields
`Decidable (ValidZTime φ)`.

Nothing here redefines `LabelledLasso`, `WitnessFamily`, `Certifies`, `WitnessFamily.std` or the
agreement theorem. Those are consumed as given.

## The route

1. **Types.** The type of a position of an arbitrary `FrameOver intOrder` model, filtered through
   `closureOf (Γ ++ Δ)`. Presentation-free, because the countermodel the compression starts from
   is an arbitrary model, not a presented one.
2. **Cycles.** Pigeonhole over the finite type space `TypeState C`, producing *good* cycles —
   cycles through a recurring type that realise the event of every eventuality that type carries.
3. **Fulfilment.** Two good cycles plus two-sided periodicity discharge every eventuality at every
   position, with the interval guard `FulfillingSeqLab` demands.
4. **Extraction.** The ℤ geometry: one history becomes one `LabelledLasso`, assembled from a
   backward good cycle, a two-leg mid walk carrying the point of interest, and a forward good
   cycle.
5. **Family.** The canonical, enumerable box guess plus one witness lasso per boxed closure member
   the guess sets false, giving `BoxFaithful` and hence `Certifies`.
6. **Enumerate.** The computable candidate list, sweeping the whole segment-length grid.
7. **Assembly.** `decidable_of_iff` on "no candidate is certified".

## Modules

| Module | Contents |
|---|---|
| `Types.lean` | `typeAtM`, `mem_typeAtM`, `typeAtM_subset`, `LocalCoherentSeqLab`, `FulfillingSeqLab`, `typeAtM_localCoherentSeqLab`, `typeAtM_fulfillingSeqLab` |
| `Cycle.lean` | `TypeState`, `SeqStepT`, `joinPathT`, the pigeonhole plumbing, `cycleBoundC`, `exists_good_cycle_of_typeSeq` |
| `Fulfil.lean` | `untl_propagates_to_endC`, `snce_propagates_to_startC`, `lab_add_mul_nfC`, `lab_sub_mul_nbC`, `fulfillingSeqLab_of_good_cycles` |
| `Extract.lean` | `midBoundC`, `compressionBound`, `localCoherentSeqLab_of_edges`, `periodic_rel_of_windowC`, the three readouts, `exists_labelledLasso_of_history_realized`, `exists_labelledLasso_of_history`, `localCoherentSeqLab_congr_bx` |
| `Family.lean` | `Formula.boxArg?`, `boxedPart`, `closureOf_nil_singleton`, `semanticConsequenceIn_nil_iff`, `exists_witnessFamily_of_not_validZTime` |
| `Enumerate.lean` | `ListEnumC.ofLen`/`upTo`, `closureSubsetsOf`, `boundedLassos`, `cands`, `mem_cands_of_bounded` |
| `Assembly.lean` | `validZTime_iff_noCertifiedCandidate`, `Compression.decidableValidZTime`, `decidableSemanticConsequenceNil` |

## Terminology map against [GKWZ] 2003

The structure of the argument is Thm 11.26 and Thm 11.45 (the compression criterion and the
`s₁·s₂·s₃^ω` lasso shape over `(ℕ,<)`). The book's only `(ℤ,<)` result (Thm 11.7 / 11.21) is the
non-constructive MSO/Rabin route and is **not** on this path; the two-sided adaptation's in-tree
template is `BiLasso/Extraction.lean`'s `exists_annot_of_truth`.

| [GKWZ] | here |
|---|---|
| type | `typeAtM`, and the datum space `TypeState C` |
| suitable pair | a step of `SeqStepT`, i.e. an edge realised by the model |
| root-saturated sequence | a *good cycle*, `exists_good_cycle_of_typeSeq` |
| run | `LabelledLasso.lab`, the decoded bi-infinite label function |
| state function | `WitnessFamily`, a box guess plus a list of labelled lassos |

## The bound is a grid, not a magnitude

Every bound in this directory reads "segment lengths **at most** `B`", never "at least `f(|C|)`",
and `Enumerate.lean` sweeps every triple in `[0, B]³`.

This is load-bearing rather than stylistic. A consuming model checker that folds `back`/`mid`/`fwd`
bounds by **exact modulus** searches, at bound `n`, exactly the periods dividing `n` — so its
searched space is *not monotone* in the bound, and a lower-bound-shaped statement transfers
nothing to it. Representability, not magnitude, is what the folding decides. Anyone porting
`compressionBound` to such a consumer must sweep the grid rather than pick a single triple.

## Deliberate duplication, and what retires it

`Cycle.lean` and `Fulfil.lean` transcribe `BiLasso/GoodCycle.lean`'s combinatorial core, and
`Extract.lean` transcribes `BiLasso/Extraction.lean`'s three-segment geometry, in both cases with
the presentation and the state component deleted. `Enumerate.lean` transcribes
`BiLasso/Enumerate.lean`'s `ListEnum` under the distinct namespace `ListEnumC`, and its
`closureSubsets` as `closureSubsetsOf`.

The alternative — instantiating the `BiLasso/` originals at a one-state dummy `IntPresentation` —
would thread a semantically empty presentation through every statement here and would restrict
the closure to `subformulaClosure φ` rather than `closureOf (Γ ++ Δ)`. It would also import the
presentation layer into a directory whose whole point is to have none.

The deletion is a genuine simplification, not a rename: the `PigeonState` product's state factor
is read by exactly one clause of `BiLasso.CoherentEdge` — the atom clause — and that clause does
not exist in `WitnessFamily.LocalCoherentLab`. `Fulfil.lean`'s two iterated-periodicity lemmas are
the sharpest case: they are *already* presentation-free upstream and transcribe with no change at
all.

**The trigger that retires the duplication** is the one `WitnessFamily/Basic.lean` and
`WitnessFamily/Decide.lean` already name: once a shared periodic-label presentation lands, the
`BiLasso/` originals and these transcriptions should be redefined as its two instances and the
duplicated plumbing deleted. That refactor belongs to whichever task owns the shared abstraction;
doing it here would put a large refactor under `BiLasso/`'s live `check`.

## Dependency on `BiLasso/`

`WitnessFamily/`'s stated invariant is that its only dependency on `../BiLasso/` is
`Periodic.lean`. This subdirectory adds a **second**: `BiLasso/Unfold.lean`, for
`truth_untl_succ`, `truth_snce_pred`, `Int.rightInduction` and `Int.leftInduction`.

That is recorded rather than hidden. `Unfold.lean` is, like `Periodic.lean`, directory-independent
content — it is about `TruthAt` over ℤ and about ℤ-distance induction, and mentions no bi-lasso
and no presentation — so the invariant's *intent* (no dependency on the presentation layer) is
intact while its letter is widened from one module to two. Nothing here imports
`BiLasso/Basic.lean`, `BiLasso/Annotation.lean`, `BiLasso/Decide.lean` or `IntPresentation.lean`.

## One sub-namespaced declaration

`Compression.decidableValidZTime` is the only declaration in this subdirectory that does not sit
directly in `FormalSystem.Metalogic.Decidability`. `BiLasso/Assembly.lean` already owns that
simple name for the **conditional** procedure — the one that takes a finite-model-property
witness `fmp` as a hypothesis, the hypothesis `Probe476.fmp_false` refutes. This one is
unconditional. Rather than rename either result or edit `BiLasso/` (held stable), the new one
takes the sub-namespace.

## What is out of scope

- **General finite-premise consequence.** `decidableSemanticConsequenceNil` covers the
  empty-premise case only; the general one needs a context-conjunction deduction theorem and the
  tree has none.
- **A usable executable.** `cands` is astronomically large. [GKWZ] §6.5 gives an EXPSPACE-hardness
  lower bound for `PTL × S5`, so the cost is the literature's own; see `Assembly.lean`'s docstring.
- **The stability modal `⊡`.** `ValidZTime` is stated for `FormalSystem.Syntax.Formula`, which has
  no `⊡`. The durable scope sentence lives at `BiLasso/Assembly.lean`'s docstring.
