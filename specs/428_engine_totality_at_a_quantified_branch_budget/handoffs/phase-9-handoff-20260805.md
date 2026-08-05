# Phase 9 handoff (plan 02)

- **Landed** in `Fuel.lean`, in a new section 4.3d(iii) after `end SplitFuelProbes`:
  `expand_split_fold_isSome`, `expand_splitOrdered_fold_isSome`.
- Both are stated over ABSTRACT per-arm hypotheses. Grep-checkable: neither statement mentions
  `worldFuel'`, `soundFuel'`, or `NoSplit`.
- **FINDING (the plan's third task, resolved in the "that is a finding" direction)**:
  `resolveOpenArm = none` IS genuinely reachable. By the landed `resolveOpenArm_eq_none_imp`
  the only surviving route is its final "still not saturated" arm — `saturateBlocked` returned
  an open branch that `findClosure` does not close and that `findUnexpandedUnblocked` still
  reports unsaturated. That is exactly the configuration the refuted unconditional
  `buildTableau_isSome` died on. It is therefore carried as the named per-arm hypothesis `hres`
  on BOTH fold lemmas, and reported here, rather than assumed away.
- The `.splitOrdered` twin differs only in that each arm carries its own `TimeOrdering`
  (`pair.1.2`). It is a fold statement and is untouched by the Phase-4 refutation.
- **Verification**: scoped `lake build` green; `sorry` count 0; purely additive.
- **Next action**: Phase 10 — the carried `hT` bound and the split-aware fuel figure.
- **Risk note carried into Phase 11**: the landed unsplit induction's measure is
  `U.card < b.toFinset.card + fuel`, and a `.split` arm recurses at `min alloc fuel` where
  `allocateFuelProportionally` gives each arm only a PROPORTIONAL share. The landed
  `allocateFuelProportionally_ge` supplies a lower bound of `1`, which is not by itself enough
  to re-establish the measure at an arm. This is F6's "fuel decays multiplicatively down the
  split tree while the universe bound does not shrink" and it is the substance of Phase 11.
