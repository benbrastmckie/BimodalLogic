# Phase 4 handoff — THE MIGRATION CANARY: verdict **GO**

**Session**: `sess_1785150996_3c6f1f_378` | **Date**: 2026-07-27 | **Phase 4 status**: COMPLETED

## VERDICT: GO

Recorded against the MIGRATION GO/NO-GO GATE (plan line 420), quoting its GO condition rather than
reinterpreting it: `negBoundedRightFixFaithful` and its `_iff` are **stated and proved sorry-free at
`VVecEA2`**, with `negChainOnFaithful`'s disjuncts spliced (`_ :: (negChainOnFaithful …).disjuncts`),
**under `HasDedekindINF`**, with **zero** hypotheses added — the head disjunct consumes no carrier at
all. The mirror `negBoundedLeftFixFaithful_iff` is landed on the same terms.

Neither NO-GO condition fired:
- **Condition 1** (splice needs a hypothesis absent from pp.9-11): did not fire. The splice needed
  strictly FEWER hypotheses than the attained version, not more.
- **Condition 2** (route requires the model-independent Prop 4.2 backward direction): did not fire.
  `EANegation.lean:1090` and `:1249` were not read, not referenced, not touched. `EANegation.lean`
  was not edited at all.

## Immediate next action

Dispatch **Phase 5** (the anchored mirrors, `BoundedFixAnchoredFaithful.lean`). Phase 5's first task
is to re-confirm the current line numbers of the two anchored splice sites
(`BoundedFixAnchored.lean:158`, `:385`) before editing, and to reuse — not re-derive — Phase 4's
`negBoundedRightFixFaithful_iff` / `negBoundedLeftFixFaithful_iff` where they apply directly.

Phase 5 should expect the **same** structural payoff as Phase 4: wherever the anchored attained
version reaches for `first_occ_tp`/`last_occ_tp` to encode an endpoint condition as an interval, the
`VVecEA2` endpoint slot removes the need. Check for that pattern before assuming an attained
witness is required.

## What the canary actually found — the migration's thesis, confirmed

The attained `negBoundedRightFix_iff` consumes `HasAttainedINF` in **two** places:

1. via `negChainOn_iff` — Lemma 5.3, legitimately;
2. via `h_INF.first_occ_tp` at `EANegationFix/BoundedFix.lean:521`, to construct
   `rightPinBracket`'s attained first `¬β₁`-point.

Consumption (2) is **not in Rabinovich**. PDF p.9 closes Cor 5.4(1) with
`¬F₀(z₀) ∨ Oₙ(F₁,…,Fₙ,z₀,z₁)` — two disjuncts, the first a **point** condition at `z₀`.
`VBracketFormula` carries no endpoint predicates (it is a disjunction of pure interval brackets), so
that point condition could not be written down in the landed type and was re-encoded as the interval
condition `rightPinBracket` (`EANegationFix/BoundedFix.lean:411`). Recovering the required point is
what drags attainment in a second time; the docstring at `BoundedFix.lean:406-410` says so outright.

`VecEA2.holds` (`VecEAFormula.lean:268`) is `endpointLeft(z₀) ∧ endpointRight(z₁) ∧ bracket(z₀,z₁)`.
At `VVecEA2`, `¬F₀(z₀)` is writable **as printed**, and consumption (2) simply disappears.

| | attained, `VBracketFormula` | faithful, `VVecEA2` (landed here) |
|---|---|---|
| Cor 5.4(1) head | `rightPinBracket` (attained first `¬β₁`) | `¬F₀(z₀)`, as printed |
| Cor 5.4(1) carrier | `HasAttainedINF` | `HasDedekindINF` |
| Cor 5.4(2) head | `leftPinBracket` (attained last `¬βₙ`) | `¬Ĝ(z₁)`, as printed |
| Cor 5.4(2) carrier | `HasAttainedINF` **and** `HasAttainedSUP` | `HasDedekindINF` alone |

The migration does not merely survive its canary; the canary is where the payoff is realized.

## Measured results (actual, not asserted)

| Gate | After Phase 3 | After Phase 4 | Verdict |
|---|---|---|---|
| `lake build` exit | 0 | **0** | pass |
| Jobs | 1886 | **1887** | +1, as specified |
| Live modules from `FormalSystem.lean` | 272 | **273** | +1, as specified |
| Tactic-position sorries in `Kamp/` | 4 dead / 0 live | **4 dead / 0 live** | unchanged |
| Tactic-position sorries in the new module | — | **0** | pass |
| Real `axiom` declarations in `FormalSystem/` | 0 | **0** | unchanged |
| `NfMultiAnchorBridge/AggregateOffDiagK1.lean` | builds | **builds (1098 jobs, EXIT 0)** | no regression |

Sorry census is tactic-position via `.claude/scripts/lean-sorry-census.sh`, never `grep -c`. The four
dead sorries are unchanged and all under `Kamp/Boneyard/`: `EndpointNegation.lean:164`,
`FOToVEA.lean:122`, `EANegationVBracketBackward.lean:452`, `:611`.

Liveness was decided by a transitive `import` walk from `FormalSystem.lean`, never by
`lake build <target>`. `lake build BoneyardArchive` was never run or cited. The new module is
reachable via the new `NfMultiAnchorBridge.lean` import edge; the walk confirms it, and confirms
`AggregateOffDiagK1` is still in the live set.

`AggregateOffDiagK1` was additionally built explicitly as its own target — the regression check that
matters most from here on — and passed at 1098 jobs, EXIT 0.

Axiom-declaration count note (carried forward from Phase 3, re-verified): bare
`grep -c '^axiom ' FormalSystem/` returns **2**, unchanged. Both hits are prose continuation lines
inside `Boneyard/` comments (`Boneyard/DiscreteXY/Discreteness.lean:40`;
`Boneyard/StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean:1233`). Neither is a declaration. Real
axiom count: 0.

### Axiom check — all six new declarations (via `lean_verify`)

**No `sorryAx` anywhere.**

- Exactly `[propext, Classical.choice, Quot.sound]`: `negBoundedRightFixFaithful_iff`,
  `negBoundedLeftFixFaithful_iff`, `endpointFailLeft_of_rightPinBracket`,
  `endpointFailRight_of_leftPinBracket`
- `[propext, Quot.sound]`: `endpointFailLeft_holds`, `endpointFailRight_holds`

## Non-vacuity — the specific form this phase requires

### (a) Neither arm re-introduces attainment

The only carrier hypothesis in `negBoundedRightFixFaithful_iff` is `HasDedekindINF`. The only carrier
hypothesis in `negBoundedLeftFixFaithful_iff` is `HasDedekindINF`. `HasAttainedINF`,
`HasAttainedSUP`, `HasDefinableINF`, `HasDefinableSUP` appear in **no** statement in the module
except the two deliberate `_of_attained` shims, whose whole content is "the attained hypothesis
still reaches this result through the landed shim". Checkable from the signatures.

### (b) The `K⁺` branch is genuinely taken — branch and discharging lemma named

The **head** disjunct of each formula takes no branch of any carrier, because it consumes no carrier:
`endpointFailLeft_holds` / `endpointFailRight_holds` carry no structural hypothesis beyond
`OrderedMonadicStructure`.

The carrier is spent entirely in the **chain arm**, through the `negChainOnFaithful_iff` call that
each `_iff` makes in **both** the `mp` and the `mpr` direction. Inside that lemma
(`Lemma53Faithful.lean:274`) the proof `rcases`es `h_INF.first_occ`, and its **left** disjunct —
`hk : kplus M atomMap P z0`, Rabinovich's *Subcase r₀ = z₀* (PDF p.8) — is the branch at
`Lemma53Faithful.lean:277-282`, discharged by **`orderedPointsExist_combine_kplus`**
(`Lemma53Faithful.lean:281`). Live branch on the invoked code path; not dead syntax, not routed
around.

**The `K⁻`/`kminus` branch is NOT taken in this phase**, because `HasDedekindSUP` is not consumed
here at all (see Deviation 2). Stated rather than papered over: claiming a `kminus` discharge here
would be false.

### (c) No case silently assumes an attained witness — closed structurally

The failure mode this check exists to catch — a proof that routes around the weak branch by quietly
reintroducing attainment — is closed by structure rather than by inspection. Each `_iff` has exactly
two proof obligations: the endpoint condition (carrier-free **by signature**) and
`negChainOnFaithful_iff` (carrier `HasDedekindINF` **by signature**). There is no third obligation
into which an attained witness could be smuggled. That is precisely the difference from
`negBoundedRightFix_iff`, whose third obligation (`BoundedFix.lean:521`) *is* such a witness.

### (d) Subsumption is machine-checked, not argued

`endpointFailLeft_of_rightPinBracket` and `endpointFailRight_of_leftPinBracket` prove that wherever
the attained pin disjunct fires, the faithful endpoint disjunct fires too — **with no carrier
hypothesis on either side**. The converse fails: an interval on which `F₀(z₀)` merely fails, with no
attained first `¬β₁`-point available, satisfies the endpoint disjunct and no pin. That asymmetry is
the carrier drop made concrete, and it is why replacing the pin loses nothing.

## Deviations

### Deviation 1 (substantive — the one the verdict turns on). REPORTED, not annotated-and-passed.

The Phase 4 task line prescribes the head "via `VecEA2.fromBracket` at the head". The landed head is
`endpointFailLeft (rightFoldHead bf)` instead. Per `.claude/rules/plan-compliance.md` this is raised
rather than silently substituted:

- `VecEA2.fromBracket` (`VecEAFormula.lean:334`) sets `endpointLeft := ⊤` **and**
  `endpointRight := ⊤`. The prescribed mechanism therefore lifts `rightPinBracket` into `VecEA2`
  while discarding the one feature of `VecEA2` the migration exists to exploit — and what it lifts
  is the attained-witness encoding.
- Under `HasDedekindINF` that head is **not provable**. In the `K⁺(¬β₁)(z₀)` branch, `¬β₁` holds
  throughout some initial segment above `z₀`, so no `r` can satisfy `rightPinBracket`'s requirement
  that `β₁` hold on all of `(z₀,r)` unless `(z₀,r)` is empty — which needs discreteness, a
  hypothesis absent from pp.9-11. Following the task line literally would have manufactured NO-GO
  condition 1 by construction, on a mechanism the paper does not use.
- The gate's GO condition is about **hypotheses**, not about the head's construction mechanism. The
  landed head satisfies it with strictly fewer hypotheses and is Rabinovich's printed disjunct
  verbatim.

Raised rather than blocked because the plan's own gate — the higher-level contract this phase exists
to evaluate — forces the change, and the two plan statements conflict. **The tail is exactly as
prescribed**: `negChainOnFaithful`'s disjuncts spliced unchanged, and `VecEA2.fromBracket` remains
in use throughout the tail via `negChainOnFaithful`'s own construction.

### Deviation 2 (substantive). `HasDedekindSUP` is not consumed.

The task line asks for the mirror "under `HasDedekindSUP`, using Phase 2's
`HasDedekindSUP.last_occ_tp` and `orderedPointsExist_combine_kminus`". The mirror is landed and
proved — but under `HasDedekindINF` alone, consuming neither.

`HasDedekindSUP`'s attained ancestor entered `negBoundedLeftFix_iff` for exactly one purpose:
placing `leftPinBracket`'s attained LAST `¬βₙ`-point. The chain arm of Cor 5.4(2) is still an
**increasing** chain (`chainAllTrue (sinceChainPreds …)`), hence still `negChainOnFaithful` and still
`HasDedekindINF`. Once the head is the printed `¬Ĝ(z₁)`, the SUP carrier has nothing left to do.
Stating it anyway would be an unused hypothesis — a strengthening that buys nothing and hides what
the proof costs.

**Phase 2 is not wasted.** `HasDedekindSUP.last_occ_tp` and `orderedPointsExist_combine_kminus` are
Phase 6 inputs: `NegFixOne.lean:243` and `:276` call `h_SUP.last_occ_tp`, and that is where they are
now expected to be consumed. Phase 6 should verify this rather than assume it.

### Deviation 3 (minor, strict superset — nothing listed was dropped)

`endpointFailLeft_of_rightPinBracket`, `endpointFailRight_of_leftPinBracket`, and the two
`_of_attained` shims are additions beyond the task list, added to make non-vacuity (a) and (d)
machine-checked rather than prose.

## Constraints observed

- Zero sorries added; zero axioms added.
- **`BoundedFix.lean` not edited** — `git status` shows it unmodified. The new module imports it.
  `negBoundedRightFix(_iff)` and `negBoundedLeftFix(_iff)` stay live and stay consumed.
- No file deleted; no declaration excised or weakened. Everything is a pure addition.
- `EANegation.lean:1090`/`:1249` not touched (three-strikes prohibition); `EANegation.lean` not
  edited at all, and no route to the splice went near the model-independent Prop 4.2 backward
  direction.
- Rabinovich cited by **PDF page only** throughout (pp.9-11 read directly from the PDF). The corrupt
  companion `.md` was never opened.
- Landed **live** via the `NfMultiAnchorBridge.lean` import edge; reachability verified by transitive
  import walk from `FormalSystem.lean`, never by `lake build <target>`.
- No task-number reference in any file outside `specs/**` (grep on both touched `.lean` files: 0
  hits).

## Sizing

Phase 4 closed in **one agent run**. The three-strikes sizing guard did not fire, and no re-split
boundary was needed. Both new-module builds compiled on the first attempt with no proof-state
iteration — attributable to the head redesign removing the phase's only hard obligation, not to the
phase being trivial.

## Files

- `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFixFaithful/BoundedFixFaithful.lean` — new,
  live (created)
- `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — import edge + NOTE
