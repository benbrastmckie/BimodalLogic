# Handoff: the (C5) `StabFaithful` statement for the branching witness frame

**From**: task 684 (agreement lemma over all walks / stability-quantifier collapse)
**To**: task 690 (stability condition over the branching frame), and any later L-plus
re-indexing of the certificate format.

This note exists so the downstream stability-condition work can **cite** a settled statement
rather than re-derive it. Everything named below is landed, compiled and axiom-clean in
`FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Stability.lean` unless stated
otherwise.

## (a) The statement

```
StabFaithful S  :≡  ∀ (φ : PlusFormula) (i : Fin S.lassos.length) (u : ℤ),
                      stab φ ∈ L i u  ↔  ∀ j, share u i j → φ ∈ L j u
```

The `Formula`-indexed shape of its right-hand side is already in the build graph as

```
FormalSystem.Metalogic.Decidability.SharingWitnessFamily.StabQuant
```

(`Sharing/Stability.lean`) — `StabQuant S hat σ t ψ` is `PlusTruthAt`'s `stab` clause with
`PlusFormula` replaced by `Formula`. That substitution is legitimate because the clause never
inspects the formula, only the world state; it is the reason the quantifier shape could be
settled at `Formula` before the L-plus re-indexing exists.

## (b) Its soundness argument

```
FormalSystem.Metalogic.Decidability.SharingWitnessFamily.stabQuant_iff_share_class
  (Sharing/Stability.lean)
```

> At a thread's trace, `StabQuant S hat (S.hist θ s) t ψ` holds iff
> `∀ j : Fin S.lassos.length, S.share (s + t) (θ.idx (s + t)) j → ψ ∈ S.L j (s + t)`.

The history quantifier of the stability clause does **not** range over walks on this frame. It
collapses to a finite quantifier over the `share`-class of the present index, with the right-hand
side ranging over `Fin S.lassos.length`. The two directions consume exactly the lemmas the box
case already consumes:

- `→`: instantiate at the constant thread (`Thread.const`, `Thread.const_idx`), whose trace is a
  history through the same class by `cls_eq`; read truth back as membership by `truth_iff_mem`.
- `←`: decompose an arbitrary history by `total_eq_thread`, extract `share` (and the time
  equality) from the state equality by `share_of_cls_eq`, read membership forward as truth by
  `truth_iff_mem`.

Axiom audit: `{propext, Classical.choice, Quot.sound}`, no warnings.

## (c) The decidability route

(C5) is decidable **for free**, by the machinery `Sharing/Decide.lean` already carries for (C0)
`AtomCoherent`. The statement reads only `S.rep u` and `S.L · u` — the same per-time datum
`SharingWitnessFamily.AtomCoherentAt` reads (`Sharing/Decide.lean`, `AtomCoherentAt` /
`atomCoherentData` / `decidableAtomCoherentAt`). Therefore:

1. Define `StabFaithfulAt S u` by the same `atomCoherentData`-shaped pattern, with
   `Formula.atom p` replaced by `stab φ`.
2. `SharingWitnessFamily.atomCoherentAt_congr` (`Sharing/Decide.lean`) transfers verbatim: two
   times with equal `rep` and equal `L · ·` satisfy the condition together.
3. `SharingWitnessFamily.atomCoherent_iff_window` (`Sharing/Decide.lean`) then reduces the ℤ-wide
   quantifier to the one-time window `cohWindowLo ≤ t < cohWindowHi`, using `data_congr_back` /
   `data_congr_fwd`.

There is **no analogue here of the relative-decidability gap** that governs the other conditions.
(C5) does not quantify over histories, threads, or future times; it is a finite check on one
time's datum.

## (d) The deterministic cross-check

```
FormalSystem.Metalogic.Decidability.SharingWitnessFamily.stabQuant_iff_self_of_share_eq
  (Sharing/Stability.lean)
```

When `share u` is equality the class is a singleton, so the collapse reads `⊡ψ ↔ ψ` — matching
`PlusLanguage.stab_iff_of_deterministic` on the deterministic device. This pins the branching
device as the **minimal** extension at which `⊡` stops collapsing to its argument, and is the
regression test to keep if the `share` relation is ever generalized further.

Also landed in the same module, and relevant to (C5)'s "one time" character:

```
FormalSystem.Metalogic.Decidability.SharingWitnessFamily.frame_recurrenceFree
```

No world history of this frame visits a world state twice. That is what makes the collapse a
quantifier over one time — `share_of_cls_eq` forces two equal classes to sit at the same time, so
"every history through the present state" cannot drag in another time. Recurrence-freedom costs
no refuting power: `FormalSystem.Semantics.plusValidIn_iff_recurrenceFree`
(`FormalSystem/Semantics/Frames/TranslationProduct.lean`) says validity of the larger language
over a frame class equals validity over that class's recurrence-free members.

## (e) Deferred: the `Sharing/README.md` announcement

`FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md` is task 690's declared
territory, so task 684 did **not** add the new module to its submodule list. Whoever next edits
that file should add a `Stability` entry naming the four declarations above.

Similarly deferred for a different reason: the one added sorted `import` line in the root
aggregator `FormalSystem.lean`. That file was under a concurrent sibling's uncommitted
modification during task 684's implementation dispatch, so the territory check stopped rather than
regenerating over it. The module is nevertheless in the build graph — it is imported by
`FormalSystem/Metalogic/Decidability/WitnessFamily.lean`, which `FormalSystem.lean` already
imports — and a full `lake build` compiles it green today. Only gate C33's byte-for-byte
`mk_all` assertion is outstanding. See
`specs/684_agreement_lemma_over_all_walks/plans/01_stability-quantifier-collapse.md`, Phase 2's
`**BLOCKER**` record.

## The completeness-side failure mode does not transfer

The completeness line's hazard is a trace that postpones an inevitability forever, cured by
limit-closure schemata in the logic together with progress measures carried in the state. That
hazard is about **deriving** fulfilment. On the certificate side fulfilment is an assumed and
checked hypothesis — `ThreadFulfilling`, decided by `Sharing/Fulfil.lean`'s least fixpoint. The
certificate's counterpart to a limit-closure schema is that decided fixpoint, already landed. No
limit-closure schema was adopted here, and none is needed for (C5).

## Shared content, and what neither line should wait on

The only content genuinely shared between this line and the completeness line is the **histories
characterization** — `SharingWitnessFamily.total_eq_thread` (`Sharing/Histories.lean`), the
replacement for `ShiftSet.total_eq_orbit`. It is landed. Beyond it the two lines diverge: the
completeness line needs a proof system and limit-closure schemata; the certificate line needs a
decidable per-time condition and has one. **Neither line should wait on the other.**
