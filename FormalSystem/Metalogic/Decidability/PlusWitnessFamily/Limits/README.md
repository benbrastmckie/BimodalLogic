# FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/

The **limits** of the `PlusSharingWitnessFamily` certificate class. This directory states no
positive result. It fixes two ℤ-time non-validities of `PlusFormula` as specifications, proves
each is a genuine non-validity, and then exhibits, against each, a certificate that does not
exist: one bounding a *production strategy*, one bounding the *whole class*.

Nothing here redefines `PlusSharingWitnessFamily`, `PlusCertifies`, the six conditions, or
`plusRefutes_of_certifies`. Those are consumed as given, and the soundness direction is not at
issue in either refutation.

## The route

The shape is a **branch, not a chain**.

1. **Targets.** `Targets.lean` supplies both limit targets — `hopTarget p` and `pumpTarget p` —
   built from a single atom by abbreviations that unfold on the nose, each with its ℤ-time
   non-validity proof and its closure-membership chain. It states no limit itself.
2. **Two parallel refutations, over different targets and different hypothesis classes.**
   `HopFree.lean` refutes `hopTarget p` for families satisfying `TransId.lean`'s hop-freedom
   hypothesis `hid`; `NoCertificate.lean` refutes `pumpTarget p` under *no* hypothesis on the
   succession relation. Neither imports the other.

`NoCertificate.lean` **re-derives** rather than imports the three opening steps it shares with
`HopFree.lean`. That is forced, not redundant: `plusClosureOf` is indexed by its context, so
`hopClosure p` and `pumpClosure p` are distinct `Finset PlusFormula` values, and no membership
fact about one transports to the other without a monotonicity principle neither refutation needs.
The shared prefix is a shared *shape*, not a shared theorem. The two membership chains are for the
same reason stated twice, at thirteen and seventeen steps.

The ℤ-time non-validity proofs *are* factored, through `plusTruthAt_box_someNextTrue` and
`plusTruthAt_box_someNextFalse`: both targets carry the same two antecedents, and on the permissive
frame both hold at the constant history for the same reason.

## Modules

| Module | Contents |
|---|---|
| `Targets.lean` | The tense abbreviations `nextTrue`, `nextFalse`, `someFuture` and their stability-modal duals `someNextTrue`, `someNextFalse`; the two targets `hopTarget`, `pumpTarget`; the two closures `hopClosure`, `pumpClosure` with their thirteen- and seventeen-step membership chains; the two non-validities `not_plusValidZTime_hopTarget`, `not_plusValidZTime_pumpTarget`; the two shared antecedents `plusTruthAt_box_someNextTrue`, `plusTruthAt_box_someNextFalse`; the `untl`-membership characterizations `untl_mem_hopClosure`, `untl_mem_pumpClosure` with their guard corollaries |
| `HopFree.lean` | `not_plusCertifies_hopTarget_of_hopFree` and its existential form `not_exists_hopFree_plusCertifies_hopTarget`; the forced successors `hopFree_branchesTrue`, `hopFree_branchesFalse` and the state-level deviation `hopFree_deviates`, all three stated for an arbitrary family; the counting step, a pigeonhole placing `lassos.length + 1` pairwise-distinct tracking indices in a type of cardinality `lassos.length` |
| `NoCertificate.lean` | `not_plusCertifies_pumpTarget` and its existential form `not_exists_plusCertifies_pumpTarget`, under no hypothesis, at any time, for any lasso count and any segment lengths; the bundled counterexample `plusCompression_fails_at_pumpTarget`; the long-postponement recursion `seqPostpone`, stated over abstract successor functions so that no family appears in it |

## What is refuted, and what is not

**`HopFree.lean` bounds a strategy.**

- It does not say `TransId.lean` is wrong. `plusLocalCoherentShare_of_transId`,
  `transId_forces_const_thread`, `thread_eq_const_of_transId` and
  `plusThreadFulfilling_of_transId` remain true, remain proved, and remain in the tree. The
  hypothesis here is spelled exactly as that module's `hid`, so the two are demonstrably about the
  same class of families.
- It does not say the six-condition certificate class is incomplete. That is a strictly stronger
  claim, about families with no hypothesis on `trans` at all, and it is `NoCertificate.lean`'s
  business against a different target.
- It does not say `hopTarget p` is unrefutable. It is refutable —
  `not_plusValidZTime_hopTarget` is a theorem — just not by a hop-free certificate.

**`NoCertificate.lean` bounds the class, and the defect is not a missing bound.** No bound repairs
it. (C2') is a demand about *every* thread of the presented structure, and that structure is
finite and eventually periodic, so every cycle reachable in the periodic region is a thread. A
target whose countermodels must contain, inside the periodic region, a cycle with an exit under a
pending eventuality therefore has no certificate: the certificate's own finiteness manufactures a
thread that stays in the cycle forever, and (C2') reads that thread as carrying an unfulfilled
eventuality even though the countermodel fulfils it by leaving the cycle. `pumpTarget p` is the
minimal instance — its `□⟐Xp`/`□⟐X¬p` pair forces the branching that creates the exit, and the
inserted `Fp → Fp`, semantically inert, is what puts `Fp` and its guard `⊤` in the closure and so
supplies the pending eventuality. Raising the lasso count, the window length or either period
raises the postponement length with it, because that length is defined *from* the family's own
numbers.

Weakening (C2') to quantify over some restricted class of threads is **not** an available repair
while `plusRefutes_of_certifies` is to survive: the soundness direction reads (C2') at exactly the
threads the joint countermodel construction builds. The repair is structural, and belongs to a
certificate whose fulfilment obligation is time-indexed rather than thread-indexed — which is what
the sibling `../../PlusSlicedCertificate/` subtree is.

**What survives unchanged.** `plusTruth_iff_mem` and `plusRefutes_of_certifies` are untouched by
this directory and remain true. Soundness of the certificate class was never in question. What
fails is completeness, the converse direction, and it fails at a specific exhibited formula.

## Provenance

Both refutations are transcriptions of compiled certificate-limit probes, with the arguments
unchanged. What changed in the transcription is that the targets, their non-validities and their
closure chains became library declarations parametric in the atom rather than probe-local
definitions fixed to a concrete one. The probes are retained as the provenance record and are not
superseded.

## Dependencies

- **Imports**: `Targets.lean` by both refutations; `HopFree.lean` additionally `../TransId`;
  `NoCertificate.lean` additionally Mathlib's `Fintype.Pigeonhole`, `Tactic.Ring` and
  `Tactic.WLOG`. `Targets.lean` itself imports `../Examples` and
  `FormalSystem.PlusLanguage.PlusNonValidities`.
- **Imported by**: the re-export `PlusWitnessFamily.lean` beside the parent directory,
  `../Compression/Extract.lean`, and — for the withdrawal it records — `PlusSlicedCertificate.lean`
  and `PlusSlicedCertificate/Sound.lean`.

This subtree is sorry-free and axiom-free.

## Related Documentation

- [PlusWitnessFamily README](../README.md)
- [Decidability README](../../README.md)
- [WitnessFamily compression README](../../WitnessFamily/Compression/README.md)

---

*Last verified: 2026-10-02*
