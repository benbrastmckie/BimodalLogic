# Phase 3 handoff — the two missing `VVecEA2` combinators landed live

**Session**: `sess_1785150996_3c6f1f_378` | **Date**: 2026-07-27 | **Phase 3 status**: COMPLETED

## Immediate next action

Dispatch **Phase 4** — `negBoundedRightFixFaithful` / `negBoundedLeftFixFaithful`, landing in
`Kamp/EANegationFixFaithful/BoundedFixFaithful.lean`. **Phase 4 is the MIGRATION CANARY** and
carries the whole-migration GO/NO-GO; it must be dispatched with its own gate.

Phase 4's first task is to re-confirm the current line numbers of `negBoundedRightFix_iff`
(`BoundedFix.lean:455`), `negBoundedLeftFix_iff` (`BoundedFix.lean:774`) and the two splice sites
(`BoundedFix.lean:449`, `:767`) before editing, and to read PDF p.9 directly.

## How to read this phase's result — READ THIS BEFORE DRAWING ANY CONCLUSION

Per the plan's own framing: Phase 3 is a pure combinator addition at a type layer that already
exists, and **cannot fail informatively**. Both combinators compiled on the first `lake build`
with no proof-state iteration. That is **not** evidence that the `VBracketFormula` → `VVecEA2`
migration will succeed, and difficulty here would not have been evidence it will fail. No
migration-viability claim is made in this handoff. The canary is **Phase 4**.

## Measured results (actual, not asserted)

| Gate | After Phase 2 | After Phase 3 | Verdict |
|---|---|---|---|
| `lake build` exit | 0 | **0** | pass |
| Jobs | 1885 | **1886** | +1, as specified |
| Live modules from `FormalSystem.lean` | 271 | **272** | +1, as specified |
| Tactic-position sorries in `Kamp/` | 4 dead / 0 live | **4 dead / 0 live** | unchanged |
| Tactic-position sorries in the new module | — | **0** | pass |
| Real `axiom` declarations in `FormalSystem/` | 0 | **0** | unchanged |

Sorry census is tactic-position via `.claude/scripts/lean-sorry-census.sh`, never `grep -c`. The
four dead sorries are unchanged and all under `Kamp/Boneyard/`: `EndpointNegation.lean:164`,
`FOToVEA.lean:122`, `EANegationVBracketBackward.lean:452`, `:611`.

Liveness was decided by a transitive `import` walk from `FormalSystem.lean`, never by
`lake build <target>`. `lake build BoneyardArchive` was never run or cited.
`Kamp.VecEACombinators` is reachable via the new `NfMultiAnchorBridge.lean` import edge.

Note on the axiom-declaration count: a bare `grep -c '^axiom '` over `FormalSystem/` returns 2,
but both hits are **prose continuation lines inside comments** (`Boneyard/DiscreteXY/
Discreteness.lean:40` — "axiom (DF) via the temporal_duality inference rule"; and
`Boneyard/StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean:1233`). Neither is a declaration, both
are pre-existing, and both are in `Boneyard/`. Real axiom count is 0, unchanged.

### Axiom check — all eight new declarations

**No `sorryAx` anywhere.** Every axiom set is a subset of
`{propext, Classical.choice, Quot.sound}`:

- Exactly `[propext, Classical.choice, Quot.sound]`: `VecEA2.conjEverywhere_holds_iff`,
  `VVecEA2.conjEverywhere_holds_iff`, `VecEA2.concatPin_holds_iff`,
  `VVecEA2.concatPin_holds_iff`
- `[propext, Quot.sound]`: `VecEA2.concatPin`, `VVecEA2.concatPin`
- No axioms at all: `VecEA2.conjEverywhere`, `VVecEA2.conjEverywhere`

## Non-vacuity — the specific form this phase requires

### (a) This phase is CARRIER-NEUTRAL

No carrier is landed, weakened, or strengthened. `HasDedekindINF`, `HasDedekindSUP`,
`HasDefinableINF`/`HasDefinableSUP` and `HasAttainedINF`/`HasAttainedSUP` appear in **no**
statement in `VecEACombinators.lean`. The only structural hypothesis in any declaration is
`OrderedMonadicStructure sig` itself. Nothing here can make a downstream carrier claim easier or
harder to discharge, and nothing here can be cited for or against a carrier. This is recorded as
prose in the module docstring, not only in this handoff.

### (b) Every `_holds` lemma is a genuine BICONDITIONAL — exact statements

```lean
theorem VecEA2.conjEverywhere_holds_iff … (vea : VecEA2 n) (s : TemporalPred) (z0 z1 : M.carrier) :
    (vea.conjEverywhere s).holds M atomMap z0 z1 ↔
    vea.holds M atomMap z0 z1 ∧
      ∀ y : M.carrier, z0 < y → y < z1 → s.EvalAt M atomMap y

theorem VVecEA2.conjEverywhere_holds_iff … (v : VVecEA2) (s : TemporalPred) (z0 z1 : M.carrier) :
    (v.conjEverywhere s).holds M atomMap z0 z1 ↔
    v.holds M atomMap z0 z1 ∧
      ∀ y : M.carrier, z0 < y → y < z1 → s.EvalAt M atomMap y

theorem VecEA2.concatPin_holds_iff … (veaL : VecEA2 nL) (pin : TemporalPred) (veaR : VecEA2 nR)
    (z0 z1 : M.carrier) :
    (veaL.concatPin pin veaR).holds M atomMap z0 z1 ↔
    ∃ r : M.carrier, z0 < r ∧ r < z1 ∧
      veaL.holds M atomMap z0 r ∧ pin.EvalAt M atomMap r ∧
      veaR.holds M atomMap r z1

theorem VVecEA2.concatPin_holds_iff … (VL : VVecEA2) (pin : TemporalPred) (VR : VVecEA2)
    (z0 z1 : M.carrier) :
    (VL.concatPin pin VR).holds M atomMap z0 z1 ↔
    ∃ r : M.carrier, z0 < r ∧ r < z1 ∧
      VL.holds M atomMap z0 r ∧ pin.EvalAt M atomMap r ∧
      VR.holds M atomMap r z1
```

Why the biconditional is the load-bearing property here, and not a formality: a one-directional
`(combinator).holds → (spec)` is satisfiable by a combinator whose output is **unsatisfiable**
(`False → anything`), and a one-directional `(spec) → (combinator).holds` is satisfiable by a
combinator whose output is **trivially true**. Only the `↔` pins the constructed form to its
intended meaning in both directions, which is what makes these usable as normal-form definitions
rather than one-way approximations.

Both directions of both `VVecEA2` lemmas were **exercised, not merely stated** — a compiled
snippet inhabits `(LHS → RHS) ∧ (RHS → LHS)` for each via `.mp`/`.mpr`.

### (c) The endpoint carrying is load-bearing, demonstrated

A third compiled example derives, from the **forward direction alone** of
`VecEA2.concatPin_holds_iff`:

```lean
∃ r, veaL.endpointRight.EvalAt M atomMap r ∧ veaR.endpointLeft.EvalAt M atomMap r
```

An endpoint-**discarding** `concatPin` could not produce those two facts. That is the concrete
sense in which a version that dropped the endpoints would be the wrong object even though it
would compile and be sorry-free: its `mpr` direction would be unprovable, because
`veaL.endpointRight(r)` and `veaR.endpointLeft(r)` would have nowhere to come from.

## What was genuinely absent, and is now landed

Re-confirmed by search before writing, as Phase 3's first task requires. A tree-wide `grep` for
`conjEverywhere` and `concatPin` returned hits only at the `BracketFormula.*` and
`VBracketFormula.*` layers — **zero** `VVecEA2.` hits. An enumeration of every `VVecEA2.` member
in the tree confirmed the layer already carried `disj`, `conjFull`, `trivialTrue`, `conjStruct`,
`disjList`, `singleton`, `enrichEndpoints`, `prependAllVec` (Phase 1), `negFix`, `holds`/
`holdsLeft`/`holdsRight`, `translateLeft`/`translateRight` and `toVVecEA_m` — and neither of the
two. Nothing existing was rebuilt; every one of those is reused as-is.

Eight declarations now close the gap: `VecEA2.conjEverywhere`,
`VecEA2.conjEverywhere_holds_iff`, `VVecEA2.conjEverywhere`, `VVecEA2.conjEverywhere_holds_iff`,
`VecEA2.concatPin`, `VecEA2.concatPin_holds_iff`, `VVecEA2.concatPin`,
`VVecEA2.concatPin_holds_iff`.

## The design point, recorded so it is not lost

`VecEA2.concatPin`'s pinned point type is

```lean
(veaL.endpointRight.conj pin).conj veaR.endpointLeft
```

`veaL`'s **right** endpoint and `veaR`'s **left** endpoint are two assertions about the *same*
carrier element `r` — the pin. They are conjoined into the pin rather than dropped. The surviving
endpoints of the result are `veaL.endpointLeft` (at `z₀`) and `veaR.endpointRight` (at `z₁`).
This is the entire reason a `VVecEA2`-level `concatPin` is needed rather than a reuse of the
`VBracketFormula` one, which operates on a form with no endpoint predicates at all.

## Source correspondence

Rabinovich cited by **PDF page only** throughout; the corrupt companion `.md` was never read.

- **PDF p.6**, Prop 4.2 / Prop 4.3 — closure of the `∨∃⃗∀` fragment under conjunction,
  disjunction and existential quantification. `conjEverywhere` is conjunction closure in the shape
  the negation recursion consumes it.
- **PDF p.9**, Cor 5.4 and Case 3 of the Lemma 5.1 proof — the negation of a bracket on `(z₀,z₁)`
  assembled from forms on `(z₀,r)` and `(r,z₁)` glued at a pinned `x ∈ (z₀,z₁)` with `¬β₁(x)`.
  `concatPin` is that gluing.

## Deviations

**None.** No listed task was skipped, narrowed, substituted, or deferred.

`VecEA2.conjEverywhere` and `VecEA2.concatPin` are not deviations. Both source modules are
two-layer — a `BracketFormula`-level operation plus its `V`-level lift (`VecEAConjFull.lean:234`
+ `NegFix.lean:78`; `ConcatPin.lean:66` + `:97`) — and reproducing that same two-layer shape one
level up is what mirroring them structurally means. The `VVecEA2`-level proofs are the same
disjunct-chase as `NegFix.lean:84` and `ConcatPin.lean:104`, with the `BracketFormula`-level
appeal replaced by the corresponding `VecEA2`-level one. No alternative decomposition was
substituted.

## Constraints observed

- Zero sorries added; zero axioms added.
- No file deleted; no declaration excised or weakened. Both combinators are pure additions.
- `EANegation.lean:1090`/`:1249` not touched (three-strikes prohibition). `EANegation.lean` was
  not edited at all.
- `EANegationFix/` untouched — the new module *imports* `EANegationFix/ConcatPin.lean` and edits
  nothing in it.
- Landed **live**: the import edge in `NfMultiAnchorBridge.lean` is what makes it reachable, and
  reachability was verified by transitive import walk from `FormalSystem.lean`, never by
  `lake build <target>`. `lake build BoneyardArchive` was never run or cited.
- No task-number reference in any file outside `specs/**` (verified by grep on both touched
  `.lean` files: 0 hits).

## Files

- `FormalSystem/Metalogic/WeakCanonical/Kamp/VecEACombinators.lean` — new, live (created)
- `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — import edge + NOTE
