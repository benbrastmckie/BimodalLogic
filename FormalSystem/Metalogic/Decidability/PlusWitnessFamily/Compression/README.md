# FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/

The L⁺-indexed twin of `../../WitnessFamily/Compression/`: the machinery that compresses an
arbitrary ℤ-time countermodel into a bounded, enumerable `PlusSharingWitnessFamily` object.

**The L⁺ compression theorem this directory was built toward does not exist, and cannot exist for
the landed certificate class.** `../Limits/NoCertificate.lean`'s
`not_exists_plusCertifies_pumpTarget` refutes it outright — at any time, for any lasso count, for
any segment lengths, and under no hypothesis on the succession relation. That is stated here, at
the top, rather than in a footnote, because it inverts the conclusion of the `Formula`-side
exemplar this directory otherwise mirrors: there, the compression half composed with the soundness
half to *yield* decidability. Here there is no such composition to make.

What remains is therefore not a dead end but a **layered record**: the type layer, the
combinatorial core, the fulfilment layer, the readout and bounds, and the semantics of the (C5)
demand are each correct, each elaborated, and each either consumed by the sibling
`../../PlusSlicedCertificate/` subtree or retained deliberately. Soundness is not at issue
anywhere in this directory: `plusTruth_iff_mem` and `plusRefutes_of_certifies` are untouched.

Nothing here redefines `PlusSharingWitnessFamily`, `PlusCertifies`, the six conditions, or the
model layer. The model layer in particular is shared verbatim with the `Formula` side —
`PlusValidInt` quantifies over the same `FrameOver intOrder`, the same `TaskModel` and the same
`WorldHistory`; only the truth predicate differs. What is re-indexed here is a filter predicate,
not a semantics.

## The route

A strict chain, each module importing exactly its predecessor:

`Types` → `Cycle` → `Fulfil` → `Extract` → `Saturate`

1. **Types.** The L⁺ type of a position of an arbitrary ℤ-frame model, filtered through
   `plusClosureOf (Γ ++ Del)`. Presentation-free, because the countermodel compression starts from
   is an arbitrary model, not a presented one.
2. **Cycle.** Pigeonhole over the finite datum space `PlusTypeState C`, producing *good* cycles —
   cycles through a recurring datum that realise the event of every eventuality that datum carries.
3. **Fulfil.** Two good cycles plus two-sided periodicity discharge every eventuality at every
   position of a bare label sequence, with the interval guard `PlusFulfillingSeqLab` demands.
4. **Extract.** The ℤ geometry and the arithmetic: the decoding lemma, the splice lemma, the two
   bounds, and one history compressed to one bounded labelled lasso.
5. **Saturate.** The semantics of the (C5) demand, stated on `plusTypeAtM` labels, independent of
   how the witnesses are organised into a list.

Two modules additionally import their `Formula`-side counterparts, for generic lemmas reused
rather than transcribed: `Cycle` imports `WitnessFamily/Compression/Cycle.lean` for the abstract
pigeonhole pair, and `Extract` imports `WitnessFamily/Compression/Extract.lean` for the eight
generic readout lemmas. Both imports are recorded in the respective module headers so that they
are decisions rather than accidents.

## Modules

| Module | Contents |
|---|---|
| `Types.lean` | `plusTypeAtM` with `mem_plusTypeAtM` and `plusTypeAtM_subset`; the two sequence-level predicates `PlusLocalCoherentSeqLab` and `PlusFulfillingSeqLab`, with `plusTypeAtM_localCoherentSeqLab` and `plusTypeAtM_fulfillingSeqLab`; and three L⁺ truth lemmas **transcribed because they have no L⁺ counterpart anywhere in the tree** — `plusBox_const`, `plusTruth_untl_succ`, `plusTruth_snce_pred` |
| `Cycle.lean` | `PlusTypeState`, `plusTypeOfT`, `PlusSeqStepT`, `plusJoinPathT` with its three interface lemmas, `natCard_plusTypeState`, `iter_plusSeqStepT`, `exists_recurring_plusTypeState`, and the derived cycle bound at `k = C.card`. **Reuses the abstract pigeonhole pair by import**; transcribes everything monomorphic in `Formula` through the `TypeState` subtype |
| `Fulfil.lean` | The interior-eventuality reduction `plusUntl_propagates_to_endC` and `plusSnce_propagates_to_startC`; the two iterated periodicities `plusLab_add_mul_nfC` and `plusLab_sub_mul_nbC`; and `plusFulfillingSeqLab_of_good_cycles`. Mentions `⊡` nowhere, deliberately |
| `Extract.lean` | `plusTypeOfT_unrollOf` (**transcribed** — the one readout lemma that is not generic, being stated at the `PlusTypeState` subtype); the bounds `plusMidBoundC` and `plusCompressionBound` with their two comparison lemmas; the presentation-free splice lemma; one history to one bounded labelled lasso. **Reuses eight generic readout lemmas by import.** Also holds the retained-and-unused alignment half — see below |
| `Saturate.lean` | The (C5) demand's semantics: `plusSameState` with its three equivalence lemmas; the `→` direction `plusTruthAt_stab_of_sameState`, `plusTypeAtM_mem_of_stab_of_state_eq`, `plusTypeAtM_stab_congr_state`, `plusTypeAtM_atom_congr_state`; the `←` direction `exists_history_state_eq_of_not_stab` and `plusTypeAtM_stab_demand`; and the two-directional `plusTypeAtM_stab_iff_forall_sameState` |

## The alignment half of `Extract.lean` is retained and unused

Everything in `Extract.lean` from the offset definition `plusAlignOffset` through the aligned
extraction `exists_plusLabelledLasso_of_history_aligned` — the offset, its two arithmetic lemmas,
the shift operation and its readout lemmas, the two transport lemmas, and the aligned extraction
itself, roughly 620 lines — has **no consumer in this tree and is expected to have none**.

Absolute-time alignment is precisely the step a compression needs and a time-sliced certificate
does not: a slice's own time is the only time there is, so there is no absolute origin to align
rows to and no offset to compute.

It is kept rather than deleted for two reasons. It is correct, non-trivial and tested by
elaboration — the arithmetic bounding a shifted mid segment is cheaper to keep than to re-derive,
and any future device that does pin rows to an absolute origin will want it. And deleting it would
erase the record of what the withdrawn route actually required, which is part of what makes the
withdrawal intelligible.

The dead-declaration census is therefore **expected to report this block**. That census is
reporting-only and never affects an exit code, so this section documents an intended state rather
than waiving a gate. A reader who finds these declarations in a census report should read this
section rather than assume an oversight.

## Design decisions, and what they rest on

**The L⁺ re-index adds no clause to either sequence predicate.** `PlusLocalCoherentSeqLab` has the
same five clauses `LocalCoherentSeqLab` has, and `PlusFulfillingSeqLab` the same two. This is a
measured fact, not an omission: `⊡` is not an eventuality, has no one-step unfolding, and so
contributes no clause to local coherence and no delivery obligation to propagate. Its obligation is
(C5), which is a *family* condition — it quantifies across the `share`-class at one time — and so
cannot be stated at a bare `ℤ → Finset PlusFormula` at all. The absence of a sixth clause is also
exactly what makes the splice lemma sound: every clause reads only the label at a position and its
two immediate neighbours, so a sequence assembled by jumping between model times whose types agree
still satisfies every clause. A clause relating a label to labels at *other indices* at the same
time would not be a local read, and no amount of type agreement along one history would establish
it.

**The bound's shape is unchanged despite the larger closure.** The cycle bound is `(2k + 1) · 2^k`
at `k = C.card`, identical in form to the `Formula` side: each mark is reached by an out-and-back
excursion contributing two shortened segments, plus one base cycle. The L⁺ closure is strictly
larger than the `Formula` closure of a corresponding formula — it carries a `stab` tier — so
`C.card` grows, but `⊡` contributes no event and hence no excursion, so no accounting term is
added. `plusCompressionBound` takes the maximum of the two derived bounds unconditionally, so no
closure-cardinality side condition is needed.

**The duplication is forced, and its retirement trigger is named.** `Formula` and `PlusFormula` are
separate inductives sharing no supertype, so `Finset Formula` and `Finset PlusFormula` are
unrelated types and the `TypeState` subtype cannot be re-indexed. Only genuinely generic lemmas —
those quantifying over an abstract carrier or over bare integers — are reused by import; the rest
is transcribed. The trigger that retires the duplication is the one the `Formula`-side modules
already name: once a shared periodic-label presentation lands, both cores should be redefined as
its two instances and the duplicated plumbing deleted. The alternative considered and rejected was
instantiating the `Formula`-side originals at a dummy presentation, which would thread a
semantically empty presentation through every statement and import the presentation layer into a
directory whose whole point is to have none.

**The `snce` propagation lemma is stated separately rather than derived by duality**, for the same
reason its `Formula`-side counterpart is: the tree has no `PlusFormula` duality operation, and
inventing one for a single use costs more than the lines it saves.

**The sequence-level route is prescribed, not a fallback.** `../Decide.lean`'s collapses are
stated for a `PlusSharingWitnessFamily`; the assembly needs the fulfilment conclusion at bare
sequences, before any family exists to state it about.

## What is out of scope

- **An L⁺ compression theorem.** Refuted, as stated above. No weakened form is asserted here, and
  weakening (C2') is not available while `plusRefutes_of_certifies` is to survive, because the
  soundness direction reads (C2') at exactly the threads the joint countermodel construction
  builds. The structural repair is the time-indexed fulfilment obligation of
  `../../PlusSlicedCertificate/`.
- **The organisation of the (C5) witnesses into a list.** `Saturate.lean` lands the demand's
  semantics only, deliberately independent of how the saturation organises witnesses, because the
  demand is the same whichever organisation is chosen.
- **A usable executable.** No complexity claim and no slice-width or period bound is proved
  anywhere in this directory; the bounds here are segment-length bounds of the form "at most",
  stated as a grid to be swept rather than a magnitude to be hit.

## Dependencies

- **Imports**: the strict chain above; `Types` additionally `../Predicates` and
  `FormalSystem.PlusLanguage.PlusTruth`; `Cycle` additionally the `Formula`-side
  `WitnessFamily/Compression/Cycle.lean`, `FormalSystem.Semantics.Periodicity` and Mathlib's
  `Int.LeastGreatest`; `Extract` additionally the `Formula`-side
  `WitnessFamily/Compression/Extract.lean`.
- **Imported by**: the re-export `PlusWitnessFamily.lean` beside the parent directory, and
  `PlusSlicedCertificate.lean` with its `Position.lean` and `Sound.lean`.

This subtree is sorry-free and axiom-free.

## Related Documentation

- [The Formula-side compression README](../../WitnessFamily/Compression/README.md)
- [PlusWitnessFamily README](../README.md)
- [The limits of the L⁺ certificate class](../Limits/README.md)
- [Decidability README](../../README.md)

---

*Last verified: 2026-10-02*
