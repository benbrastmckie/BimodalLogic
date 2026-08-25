# Implementation Plan: TM/TM+ Conservativity Bridge — Backward Direction

- **Task**: 413 - Formalize the TM+/TM conservativity bridge (backward direction only, plus a
  documented refutation record for the forward direction)
- **Status**: [IMPLEMENTING]
- **Effort**: 12 hours
- **Dependencies**: 439, 470 (recorded in state.json; neither gates this plan — see "Dependency
  note" in the Overview)
- **Research Inputs**: `specs/413_formalize_tm_conservativity_bridge/reports/01_tm-conservativity-bridge.md`
- **Artifacts**: plans/01_tm-conservativity-backward-bridge.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Build the base language BL (`BLFormula`, primitive `box`/`allPast`/`allFuture`) and TM's
Hilbert system as a self-contained `FormalSystem.BaseLanguage` cluster, then formalize the
translation `tr : BLFormula -> Formula` into the repository's existing until/since-primitive
BL+ syntax and prove the **backward** conservativity direction `TM |- phi ==> TM+ |- tr phi` by
structural recursion over BL derivations. The bridge is parameterized by the *existing*
`ProofSystem.FrameClass`, so the four paper rows (CEB/CEF/CED/CEC) fall out as four
instantiations of one theorem rather than four separate developments. Alongside the bridge, a
module docstring permanently records why the converse (forward) direction is refuted for the
Base and Discrete rows and open for the other two, citing this repository's own `Axiom.z1` and
`Axiom.discrete_box_necessity` as the evidence.

**Definition of done**: `lake build` green; no new `sorry`; no new `axiom`; `translate`,
`derivable_translate`, and the four row corollaries `ceb_backward`, `cef_backward`,
`ced_backward`, `cec_backward` all proved and clean under `#print axioms`; the refutation
docstring present and naming both axioms.

**Dependency note**: state.json records dependencies 439 and 470. Nothing in this plan consumes
their output — the bridge is purely proof-theoretic and touches no semantics. Tasks 421/422/425
build the non-Archimedean discrete carrier that a future *machine-checked* CEF-forward
refutation would consume; that refutation is out of scope here (Deliverable B is documentation,
not proof). No phase below blocks on any other task.

### Research Integration

Report §11 "Recommended Scope" is the approved scope and is transcribed directly into the phase
set below. Load-bearing findings carried into the plan:

- **§7 prototypes compile clean** against the live tree: `BLFormula`, `swapBL`, `tr`,
  `swapBL_involution`, `tr_swapBL`, `tr_ne_untl`, `tr_ne_snce` all returned
  `{"success": true, "diagnostics": []}` from `lean_run_code`. Phases 1 and 4 transcribe these
  rather than re-deriving them.
- **§5.2 Base-row discharge table** and **§5.3 extension-row table** route every TM item to a
  named existing asset. Phases 6 and 7 execute those tables item by item.
- **§6** identifies DF at `FrameClass.Discrete` as the one open sub-obligation and names the
  three Route-A pieces. Phase 5 is dedicated to it.
- **§8.2** fixes the design decision to reuse `ProofSystem.FrameClass` rather than clone it, and
  records the CEC fidelity caveat (`Dedekind` in this repo admits `Dense`, so the CEC row reads
  TM_dc -> TM+_dc, not TM_c -> TM+_c).
- **§9** predicts the tactic profile: term-mode `DerivationTree` construction, `decide` for every
  `minFrameClass <= fc` side condition, targeted `simp only` for commutation/unfolding.
  `aesop`/`omega`/`linarith` have no purchase. The `untr`-recognizer route is measured-failed and
  must not be attempted.
- **§4.2** supplies the Deliverable B evidence verbatim: `Axiom.z1` is built entirely from
  `allFuture`/`someFuture`/`imp`, hence already in the image of `tr`.

### Prior Plan Reference

No prior plan. This is plan version 1 for task 413.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context and no roadmap phases are included. The
work advances the proof-theory side of the TM/TM+ relationship; it neither consumes nor feeds the
decidability/tableau critical path.

## Goals & Non-Goals

**Goals**:

- A self-contained `FormalSystem/BaseLanguage/` cluster: `BLFormula`, TM's axiom set, TM's
  derivation trees, and the translation `tr`, none of which shadow the existing `Formula` /
  `Axiom` / `DerivationTree`.
- `translate : BaseLanguage.DerivationTree fc G phi -> ProofSystem.DerivationTree fc (G.map tr) (tr phi)`
  and its Prop-level corollary `derivable_translate`, both sorry-free.
- The four row corollaries `ceb_backward`, `cef_backward`, `ced_backward`, `cec_backward`.
- `|-[Discrete] (H phi AND phi AND F top) -> F(H phi)` derived syntactically (Route A).
- A module docstring in `Metalogic/Conservativity.lean` that stops a future dispatch from
  re-attempting the forward direction.
- `BaseLanguage/` imports nothing from `FormalSystem/Semantics/` — an explicit, checkable
  invariant (report §8.4) that keeps the bridge composable with whatever the totality-based
  validity definition becomes.

**Non-Goals** (no phase below may drift into these):

- The **forward** direction `TM+ |- tr phi ==> TM |- phi`. It must not be stated and must not be
  `sorry`-ed: it is provably false for the Base and Discrete rows, so a `sorry` on it would be an
  unsound placeholder rather than deferred debt, which the zero-debt gate forbids.
- Any BL-side semantics, truth definition, frame, or soundness theorem.
- The two-fibre and Z x_lex Z countermodels (a machine-checked refutation is separate task
  material and would consume currently-blocked non-Archimedean carrier work).
- Cloning `FrameClass`. Reuse the existing one.
- Reusing any *content* from `FormalSystem/Boneyard/ConservativeExtension/`. Its shape
  (parallel `Axiom` inductive, parallel `DerivationTree`, one recursive `embed`) is the template;
  its content is a fresh-atom extension and is `#exit`-guarded and never compiled.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| DF at `Discrete` (Phase 5) does not close by Route A | H | M | Phase 5 is isolated in Wave 1 so a stall is visible early and blocks only Phases 6-9's CEF row. Route B (`completeness_discrete`) exists but **requires explicit user approval before use** — see the Route B escalation contract in Phase 5. Do not substitute silently. |
| `H phi AND phi -> X(H phi)` past-dual step is harder than the report's one-line sketch | M | M | `DerivationTree.temporal_duality` is a primitive rule at *any* frame class, so the dual is free once the forward form is in hand; the forward form is `unfoldForward`/`unfoldTableForward` in `Theorems/DiscreteUnfolding.lean`. Budget the whole of Phase 5's 2h to this step if needed. |
| Namespace collision between `BaseLanguage.Formula`/`Axiom`/`DerivationTree` and the existing top-level ones | H | M | Everything lands under `FormalSystem.BaseLanguage`; the BL-side formula type is named `BLFormula`, not `Formula`. Phase 1 carries tier `full` precisely because aggregator wiring is where a collision surfaces. Use distinct notation (e.g. `|-BL[fc]`) and never `open` both namespaces unqualified in the same section. |
| TL disjunct order/association mismatch (paper vs. `Axiom.temp_linearity`) | L | H (certain) | Routine `orElim`/`orIntro` plumbing pulled from `Theorems/Propositional/` and `Theorems/Combinators.lean`; do not re-derive propositional lemmas. Budgeted inside Phase 6. |
| `tr_injective` leaves residual goals | L | M | Report §7 measured exactly 8 residual goals: 4 direct IH applications, 4 shape clashes closed by the range lemmas with orientation fixed (`(tr_ne_snce _ _ _ h.1.symm).elim`). Injectivity is **not** needed for the backward direction — if it resists, it may be dropped with a note rather than blocking Phase 8. |
| `untr`-recognizer approach re-attempted | L | L | Measured failure (overlapping match patterns block `simp [untr]`). Recorded here and in Phase 4 as forbidden. |
| CEC fidelity: repo `Dedekind` admits `Dense`, so the row is TM_dc -> TM+_dc | L | H (certain) | State it explicitly in the `cec_backward` docstring rather than letting a reader infer TM_c. Phase 8 task item. |
| Including `temporal_necessitation` as a BL-side primitive overstates TM | L | M | TM has no primitive temporal necessitation, but `|- phi ==> |- G phi` **is derivable** in TM from MN + MF + MT, so including it as a primitive changes no theorem of TM and keeps the 7-rule mirror the task asks for. Record this as a fidelity note in `Derivation.lean`'s module docstring (Phase 3). |
| Aggregator wiring breaks an unrelated part of the build | M | L | Phases 1 and 8 are the only phases that edit an aggregator; both are tiered accordingly (`full` / `interface`) and both end with `lake build`. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 5 | -- |
| 2 | 2, 4 | 1 |
| 3 | 3, 6 | 2 (and 4, 5 for Phase 6) |
| 4 | 7 | 6 |
| 5 | 8 | 3, 7 |
| 6 | 9 | 8 |

Phases within the same wave can execute in parallel. Phase 5 is deliberately placed in Wave 1
despite being logically "late": it is the single largest unknown and shares no file territory
with any other phase, so starting it first surfaces a stall while there is still schedule to
absorb it.

**Territory map** (no two phases in the same wave write the same file):

| Phase | Writes |
|-------|--------|
| 1 | `FormalSystem/BaseLanguage/Formula.lean`, `FormalSystem/BaseLanguage.lean`, `FormalSystem/FormalSystem.lean` (one import line) |
| 2 | `FormalSystem/BaseLanguage/Axioms.lean`, `FormalSystem/BaseLanguage.lean` (import line) |
| 3 | `FormalSystem/BaseLanguage/Derivation.lean`, `FormalSystem/BaseLanguage.lean` (import line) |
| 4 | `FormalSystem/BaseLanguage/Translation.lean`, `FormalSystem/BaseLanguage.lean` (import line) |
| 5 | `FormalSystem/Theorems/DiscreteUnfolding.lean` (append only) |
| 6 | `FormalSystem/BaseLanguage/AxiomDischarge.lean` (create), `FormalSystem/BaseLanguage.lean` (import line) |
| 7 | `FormalSystem/BaseLanguage/AxiomDischarge.lean` (append) |
| 8 | `FormalSystem/Metalogic/Conservativity.lean`, `FormalSystem/Metalogic.lean` (one import line) |
| 9 | `FormalSystem/Metalogic/Conservativity.lean` (docstring only) |

Waves 2 and 3 each have two phases touching `FormalSystem/BaseLanguage.lean`. If those phases are
dispatched in parallel, the aggregator's import list is the one contended file: have each phase
append exactly one `import` line, or pre-write the full import list in Phase 1 with the
not-yet-existing modules commented out and have each later phase uncomment its own line.

---

### Phase 1: BL syntax — `BLFormula`, `swapBL`, instances [COMPLETED]

**Goal**: The base language exists as a Lean type, with the swap operation TM's TD rule needs and
the instances downstream phases require, wired into the build without disturbing anything.

**Tasks**:
- [x] Create `FormalSystem/BaseLanguage/Formula.lean` under namespace `FormalSystem.BaseLanguage`.
- [x] Define `BLFormula : Type` with exactly six constructors: `atom : Atom -> BLFormula`, `bot`,
      `imp`, `box`, `allPast`, `allFuture`. Reuse the existing `FormalSystem.Syntax.Atom`; do not
      define a new atom type.
- [x] **Polarity check before writing anything**: the paper writes `\Past`/`\Future` for the
      UNIVERSAL H/G and `\past`/`\future` for the existential P/F. `allPast` = H (universal),
      `allFuture` = G (universal). Getting this backwards transcribes a different logic. Add a
      docstring line on each constructor stating which paper symbol it is.
- [x] Define derived operators from the primitives: `neg`, `top`, `and`, `or`, `iff`,
      `somePast` (P := `neg (allPast (neg phi))`), `someFuture` (F := `neg (allFuture (neg phi))`).
      Mirror the naming used in `FormalSystem/Syntax/Formula.lean` so the two sides read alike.
- [x] Define `swapBL : BLFormula -> BLFormula` interchanging `allPast` and `allFuture`
      structurally (report §7 gives the exact six-line definition).
- [x] `deriving Repr, DecidableEq`; add a `Countable BLFormula` instance (follow whatever pattern
      `Syntax/Formula.lean` uses for its own `Countable`; if it derives via an encoding, reuse it).
- [x] Prove `swapBL_involution (phi) : phi.swapBL.swapBL = phi` by
      `induction phi <;> simp_all [swapBL]` (verified compiling in report §7).
- [x] Add convenience `simp` lemmas for `swapBL` on the derived operators if the induction in
      Phase 4 will need them (`swapBL (neg phi) = neg (swapBL phi)` etc.). *(completed: neg/and/or/iff/diamond/somePast/someFuture/top all `rfl`; `swapBL_always` stated non-`simp` since the conjunct order reverses)*
- [x] Create `FormalSystem/BaseLanguage.lean` aggregator importing
      `FormalSystem.BaseLanguage.Formula`, with the remaining four imports present but commented
      out (see the territory note above).
- [x] Add `import FormalSystem.BaseLanguage` to `FormalSystem/FormalSystem.lean` and add a bullet
      for the new component to that file's `## Components` list.
- [x] Add a module docstring stating the invariant: **`BaseLanguage/` imports nothing from
      `FormalSystem/Semantics/`.**

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts six `BLFormula` constructors and seven derived
operators. Confirm at implementation time by reading `def:BL-language` as transcribed in report
§3.1 (`phi ::= p_i | bot | phi -> psi | box phi | H phi | G phi`) and by checking that the derived
operator list matches what Phases 2, 4, 6 and 7 actually consume; add derived operators only as a
consumer demands one.

**Files to modify**:
- `FormalSystem/BaseLanguage/Formula.lean` — create; `BLFormula`, derived ops, `swapBL`,
  instances, `swapBL_involution`.
- `FormalSystem/BaseLanguage.lean` — create; aggregator.
- `FormalSystem/FormalSystem.lean` — add one import and one `## Components` bullet.

**Verification**:
- `lake build` green (tier `full`: this phase edits the root aggregator, where a namespace or
  notation collision with the existing `Formula` would surface).
- `#print axioms FormalSystem.BaseLanguage.swapBL_involution` clean.
- `grep -rn 'FormalSystem.Semantics' FormalSystem/BaseLanguage/` returns nothing.

---

### Phase 2: TM axiom set — `BaseLanguage.Axiom` and `minFrameClass` [NOT STARTED]

**Goal**: TM's axiom schemata exist as a Lean inductive, each routed to the frame class it needs
via the *existing* `ProofSystem.FrameClass`.

**Tasks**:
- [ ] Create `FormalSystem/BaseLanguage/Axioms.lean`; import `FormalSystem.BaseLanguage.Formula`
      and `FormalSystem.ProofSystem.Axioms` (for `FrameClass` only).
- [ ] Define `inductive Axiom : BLFormula -> Prop` with, per report §3.2:
      - CPL: mirror the propositional schemata the BL+ side uses (`prop_k`, `prop_s`, `ex_falso`,
        `peirce` — match `ProofSystem/Axioms.lean`'s choice exactly so Phase 6's discharge is
        constructor-for-constructor).
      - MK `box (phi -> psi) -> (box phi -> box psi)`
      - MT `box phi -> phi`
      - M5 `dia (box phi) -> box phi`
      - MF `box phi -> box (allFuture phi)`
      - TK `allFuture (phi -> psi) -> (allFuture phi -> allFuture psi)`
      - T4 `allFuture phi -> allFuture (allFuture phi)`
      - TB `someFuture top`
      - TA `phi -> allFuture (somePast phi)`
      - TL `(someFuture phi AND someFuture psi) -> [F(F phi AND psi) OR F(phi AND psi) OR F(phi AND F psi)]`
        — transcribe the **paper's** disjunct order and association here; the reshuffle to the
        repo's `Axiom.temp_linearity` order happens in Phase 6, not here.
      - DF `(allPast phi AND phi AND someFuture top) -> someFuture (allPast phi)`
      - DN `allFuture (allFuture phi) -> allFuture phi`
      - CO `always (allPast phi -> someFuture (allPast phi)) -> (allPast phi -> allFuture phi)`
        (define `always phi := allPast phi AND phi AND allFuture phi` on the BL side, mirroring
        `Formula.always`).
      MP, MN and TD are **rules**, not axioms — they belong to Phase 3.
- [ ] Define `Axiom.minFrameClass : Axiom phi -> FrameClass` sending `DF |-> .Discrete`,
      `DN |-> .Dense`, `CO |-> .Dedekind`, and every other constructor `|-> .Base`. Follow the
      catch-all shape of `ProofSystem/Axioms.lean`'s own `minFrameClass`.
- [ ] Uncomment the `Axioms` import in `FormalSystem/BaseLanguage.lean`.
- [ ] Module docstring: name the paper source (`\S sub:Logic` for TM, `\S sub:Extension` for
      DF/DN/CO) and note that TM's TD/MP/MN are rules living in `Derivation.lean`.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts "TM's 12 schemata/rules plus DF/DN/CO", of which 10
(MK, MT, M5, MF, TK, T4, TB, TA, TL, plus the CPL group) are axioms here and 3 (MP, MN, TD) are
rules deferred to Phase 3. Confirm the count against report §3.2's table before writing, and
confirm the CPL group against `ProofSystem/Axioms.lean`'s actual propositional constructors —
if the BL+ side uses a different propositional basis than `prop_k`/`prop_s`/`ex_falso`/`peirce`,
match *it*, and record the deviation.

**Files to modify**:
- `FormalSystem/BaseLanguage/Axioms.lean` — create.
- `FormalSystem/BaseLanguage.lean` — uncomment one import.

**Verification**:
- `lake build FormalSystem.BaseLanguage.Axioms` green.
- Each `minFrameClass` branch confirmed by `#eval`/`example ... := by decide` on one instance per
  non-Base constructor.

---

### Phase 3: TM derivations — `BaseLanguage.DerivationTree`, `Derivable`, notation [NOT STARTED]

**Goal**: TM's proof system exists as a `Type`-valued inductive mirroring the BL+ side's 7-rule
shape, so the Phase 8 recursion is constructor-for-constructor.

**Tasks**:
- [ ] Create `FormalSystem/BaseLanguage/Derivation.lean`; `abbrev Context := List BLFormula`.
- [ ] Define `inductive DerivationTree (fc : FrameClass) : Context -> BLFormula -> Type` with the
      seven rules mirroring `FormalSystem/ProofSystem/Derivation.lean`: `axiom` (with the
      `h.minFrameClass <= fc` side condition), `assumption`, `modus_ponens`, `necessitation`,
      `temporal_necessitation`, `temporal_duality`, `weakening`.
- [ ] **`temporal_duality` uses `swapBL`, not `swapTemporal`.** Its shape mirrors the BL+ rule:
      empty context on both sides, `DerivationTree fc [] phi -> DerivationTree fc [] phi.swapBL`.
      Read `ProofSystem/Derivation.lean`'s `temporal_duality` constructor and match its
      context discipline exactly.
- [ ] Define `Derivable (fc) (G) (phi) : Prop := Nonempty (DerivationTree fc G phi)`, mirroring
      `ProofSystem/Derivable.lean`.
- [ ] Add notation distinct from the BL+ side's `|-[fc]` (e.g. `|-BL[fc]` / `G |-BL[fc] phi`).
      Verify no clash by building a file that opens both namespaces.
- [ ] Add the `lift` lemma (`fc1 <= fc2 -> DerivationTree fc1 G phi -> DerivationTree fc2 G phi`)
      mirroring `ProofSystem/Derivation.lean`'s `lift`, if Phase 8's row corollaries will need it.
- [ ] Module docstring **fidelity note**: TM as axiomatized in the paper has no primitive
      temporal necessitation rule; `|- phi ==> |- G phi` is derivable from MN + MF + MT. Including
      it as a primitive here therefore changes no TM theorem and preserves the 7-rule mirror.
      State this explicitly so a reader does not read the extra rule as a strengthening.
- [ ] Uncomment the `Derivation` import in `FormalSystem/BaseLanguage.lean`.

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts a 7-rule mirror. Confirm by enumerating the constructors
of `FormalSystem.ProofSystem.DerivationTree` at implementation time (`lean_file_outline` on
`ProofSystem/Derivation.lean`) rather than trusting this count; if the BL+ side has more or fewer
rules than seven, mirror what is actually there and record the deviation.

**Files to modify**:
- `FormalSystem/BaseLanguage/Derivation.lean` — create.
- `FormalSystem/BaseLanguage.lean` — uncomment one import.

**Verification**:
- `lake build FormalSystem.BaseLanguage.Derivation` green.
- A smoke `example : |-BL[FrameClass.Base] (BLFormula.bot.imp BLFormula.bot) := ...` elaborates.
- Notation does not shadow the BL+ notation: an `example` file opening both namespaces builds.

---

### Phase 4: The translation — `tr`, `tr_swapBL`, range and injectivity lemmas [NOT STARTED]

**Goal**: The map from BL into BL+ exists, together with the one commutation lemma without which
the TD case of the Phase 8 recursion does not typecheck.

**Tasks**:
- [ ] Create `FormalSystem/BaseLanguage/Translation.lean`; import `BaseLanguage.Formula` and
      `FormalSystem.Syntax.Formula`.
- [ ] Define `tr : BLFormula -> Formula` structurally (report §7 gives the exact six lines):
      `atom |-> Formula.atom`, `bot |-> Formula.bot`, `imp |-> Formula.imp`,
      `box |-> Formula.box`, `allPast |-> Formula.allPast`, `allFuture |-> Formula.allFuture`.
      Note `Formula.allPast`/`allFuture` on the BL+ side are the *derived* until/since
      abbreviations — that is exactly the point.
- [ ] Prove `tr_swapBL (phi) : (phi.swapBL).tr = (phi.tr).swapTemporal`. **This is the
      load-bearing lemma.** Report §7 gives the verified per-case proof; the `allPast`/`allFuture`
      cases need `Formula.swap_temporal_all_past` / `Formula.swap_temporal_all_future` supplied
      explicitly to `simp`.
- [ ] Prove the two range lemmas `tr_ne_untl` and `tr_ne_snce` (verified in §7): `tr` never
      produces a top-level `untl`/`snce`. Both need the unfoldings
      `Formula.allPast, allFuture, somePast, someFuture, neg, top` passed to `simp`.
- [ ] Prove push-through lemmas for the derived operators — `tr (neg phi) = Formula.neg (tr phi)`,
      and the same for `and`/`or`/`top`/`somePast`/`someFuture` — since Phases 6 and 7 will state
      every discharge goal in terms of BL+ derived operators.
- [ ] Prove `tr_injective : Function.Injective tr`. Report §7 measured `induction ... <;>
      simp_all` leaving exactly 8 goals: 4 direct IH applications, 4 shape clashes closed by the
      range lemmas with orientation fixed (`(tr_ne_snce _ _ _ h.1.symm).elim`).
- [ ] **Do not attempt the `untr : Formula -> Option BLFormula` recognizer route.** Measured
      failure: overlapping match patterns block `simp [untr]` from reducing.
- [ ] Define the context-level lift `trCtx (G : BaseLanguage.Context) : Context := G.map tr`
      (or use `List.map tr` inline — pick one and use it consistently from Phase 8 onward).
- [ ] Uncomment the `Translation` import in `FormalSystem/BaseLanguage.lean`.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts that `tr_injective` leaves exactly 8 residual goals after
`induction ... <;> simp_all`, split 4 IH / 4 shape-clash. Confirm by running the induction and
counting the actual goals before writing the closing script. If the count differs, close what is
there; **`tr_injective` is not required by the backward direction** — if it resists, drop it with
a note in the module docstring rather than blocking Phase 8.

**Files to modify**:
- `FormalSystem/BaseLanguage/Translation.lean` — create.
- `FormalSystem/BaseLanguage.lean` — uncomment one import.

**Verification**:
- `lake build FormalSystem.BaseLanguage.Translation` green.
- `#print axioms FormalSystem.BaseLanguage.tr_swapBL` clean.
- A spot-check `example : tr (BLFormula.allFuture (BLFormula.atom a)) = Formula.allFuture (Formula.atom a) := rfl`.

---

### Phase 5: The DF derivation at `FrameClass.Discrete` [NOT STARTED]

**Goal**: Derive `|-[FrameClass.Discrete] (H phi AND phi AND F top) -> F (H phi)` syntactically.
This is the single largest unknown in the task and shares no file territory with any other phase.

**Tasks**:
- [ ] Read `FormalSystem/Theorems/DiscreteUnfolding.lean` in full — in particular
      `succIndicator` (`|-[Discrete] Formula.next Formula.top`, line ~85), `unfoldForward`
      (line ~106) and `unfoldTableForward` (line ~245) — plus the module docstring's explanation
      of why the frame class is pinned to `Discrete` rather than left free.
- [ ] **Route A, step 1**: obtain `X top` from `Theorems.DiscreteUnfolding.succIndicator`.
- [ ] **Route A, step 2**: obtain `X psi -> F psi` at `Base` from `Axiom.until_F` instantiated
      with guard `bot` (`X psi := U(psi, bot)`); confirm the exact guard convention against
      `Formula.next`'s definition before instantiating.
- [ ] **Route A, step 3** (the real work): derive `H phi AND phi -> X (H phi)`. This is the
      **past-dual** of the one-step unfolding in `unfoldForward`/`unfoldTableForward`. Past duals
      are free: `DerivationTree.temporal_duality` is a primitive rule applying to any theorem at
      any frame class, so no past-mirrored axiom is needed. Derive the forward form first, then
      apply `temporal_duality` (note its empty-context restriction — stage the derivation as a
      closed theorem, then use the deduction theorem from `Theorems/Propositional/` if a context
      form is wanted).
- [ ] Compose steps 1-3 into `discreteFuture` (or `dfSchema`):
      `def dfSchema (phi : Formula) : |-[FrameClass.Discrete] ((phi.allPast.and phi).and Formula.top.someFuture).imp (phi.allPast.someFuture)`
      — match the exact BL+ operator spelling and association that Phase 7 will need, and state
      it so Phase 7 can use it without reassociating.
- [ ] Append to `FormalSystem/Theorems/DiscreteUnfolding.lean` (same namespace, same
      `noncomputable section`); update that file's module docstring bullet list to name the new
      declaration.
- [ ] Pull all propositional plumbing (`andIntro`, `andElim`, `impTrans`, `deductionTheorem`)
      from `Theorems/Propositional/` and `Theorems/Combinators.lean`. Do not re-derive.

**ROUTE B ESCALATION CONTRACT** (binding): Route B derives `tr(DF)` from
`completeness_discrete` (`Metalogic/BXCanonical/Completeness.lean:297`) via validity over
Z-time. It is sorry-free but makes a proof-theoretic bridge depend on the completeness machinery
it is meant to feed — a presentational regression the paper explicitly wanted to avoid.
**Route B requires explicit user approval before use.** If Route A stalls, the implementer must
stop, mark this phase `[BLOCKED]`, write the stall point into the handoff, and request approval.
Silently substituting Route B is a plan violation, not a judgment call.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts that Route A decomposes into exactly three steps and
that step 3 is the past-dual of an existing forward unfolding. Confirm by reading
`unfoldForward`/`unfoldTableForward` and checking that its statement, dualized, is literally
`H phi AND phi -> X (H phi)`. If the dual does not line up (e.g. the existing unfolding carries
a guard that does not dualize cleanly), that is the stall condition — report it rather than
inventing a fourth step, and re-estimate before continuing.

**Files to modify**:
- `FormalSystem/Theorems/DiscreteUnfolding.lean` — append `dfSchema` plus supporting lemmas;
  update the module docstring's declaration list.

**Verification**:
- `lake build FormalSystem.Theorems.DiscreteUnfolding` green.
- `#print axioms FormalSystem.Theorems.DiscreteUnfolding.dfSchema` clean (and in particular does
  **not** mention any completeness theorem, which would indicate an accidental Route B).
- No new `sorry` in the file: `grep -c sorry FormalSystem/Theorems/DiscreteUnfolding.lean`
  unchanged from its pre-phase value.

---

### Phase 6: Base-row axiom discharge [NOT STARTED]

**Goal**: For every Base-row TM axiom constructor, a BL+ derivation of its translation at
`FrameClass.Base` — the table that makes the Phase 8 `axiom` case a lookup rather than a proof.

**Tasks**:
- [ ] Create `FormalSystem/BaseLanguage/AxiomDischarge.lean`; import `BaseLanguage.Axioms`,
      `BaseLanguage.Translation`, `ProofSystem`, and the `Theorems.*` modules named below.
- [ ] Work report §5.2's table top to bottom, one lemma per row, each of shape
      `|-[FrameClass.Base] tr (<the BL axiom formula>)`:
      - CPL group -> `Axiom.prop_k`, `prop_s`, `ex_falso`, `peirce` (direct)
      - MK -> `Axiom.modal_k_dist` (direct)
      - MT -> `Axiom.modal_t` (direct)
      - M5 -> `Axiom.modal_5_collapse` (direct)
      - MF -> `Axiom.modal_future` (**exact syntactic match**)
      - TK -> `Theorems.TemporalDerived.gDistribution` (`TemporalDerived.lean:259`, sorry-free)
      - T4 -> `Theorems.TemporalDerived.gTransitivity` (`TemporalDerived.lean:274`, sorry-free)
      - TB -> `Axiom.serial_future` (`top -> F top`) + MP on `top`; cf.
        `ContextualProofs.serial_future_ctx:294`
      - TA -> `Axiom.connect_future` (**exact syntactic match**)
      - TL -> `Axiom.temp_linearity` (`Axioms.lean:253`) **plus a propositional reshuffle**: the
        paper's `F(F phi AND psi) OR F(phi AND psi) OR F(phi AND F psi)` vs. the repo's
        `F(phi AND psi) OR (F(phi AND F psi) OR F(F phi AND psi))` — same three disjuncts,
        different order and association. Discharge with `orElim`/`orIntro` from
        `Theorems/Propositional/`. This is the only Base-row friction; budget most of the phase
        here.
- [ ] MP, MN and TD are **rules** and are discharged in Phase 8's recursion, not here.
- [ ] Each lemma's statement must be phrased in the form the Phase 8 `axiom` case will consume —
      i.e. `tr` applied to the BL axiom formula, reduced via the Phase 4 push-through lemmas.
      Write one such lemma against the Phase 8 skeleton *first* to fix the shape, then fill in.
- [ ] Uncomment the `AxiomDischarge` import in `FormalSystem/BaseLanguage.lean`.

**Timing**: 2 hours

**Depends on**: 2, 4, 5

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts 13 Base-row items discharged by the named assets in
report §5.2, with TL as the only friction. Confirm each named asset resolves before relying on it
(`lean_local_search` / `lean_hover_info` on `Axiom.modal_future`, `Axiom.connect_future`,
`Theorems.TemporalDerived.gDistribution`, `gTransitivity`, `Axiom.serial_future`,
`Axiom.temp_linearity`); the two "exact syntactic match" claims (MF, TA) are hypotheses to check
by `rfl`-level comparison, not facts. Any asset that does not match is a re-estimate trigger, not
a licence to weaken the statement.

**Files to modify**:
- `FormalSystem/BaseLanguage/AxiomDischarge.lean` — create; Base-row lemmas.
- `FormalSystem/BaseLanguage.lean` — uncomment one import.

**Verification**:
- `lake build FormalSystem.BaseLanguage.AxiomDischarge` green.
- Every Base-row lemma present and sorry-free; `#print axioms` clean on each.
- MF and TA close by `exact DerivationTree.axiom _ _ (Axiom.modal_future _) (by decide)` shape
  (or the phase records why the "exact match" claim did not hold).

---

### Phase 7: Extension-row axiom discharge — DN, CO, DF [NOT STARTED]

**Goal**: The three extension axioms discharged at their respective frame classes, completing the
lookup table.

**Tasks**:
- [ ] DN at `Dense`: `Axiom.density phi` (`Axioms.lean:358`) is **literally the same formula**.
      Confirm by `rfl` and close in one line.
- [ ] CO at `Dedekind`: `Theorems.DedekindDerived.co_derived {fc} (h_fc : Dedekind <= fc) (phi) :
      |-[fc] Formula.co phi` (`DedekindDerived.lean:372`, already sorry-free). Confirm that
      `Formula.co` (`Formula.lean:506`) unfolds to the same formula as `tr (CO phi)` after the
      Phase 4 push-through lemmas; if the association differs, reshuffle as in Phase 6's TL step.
- [ ] DF at `Discrete`: use Phase 5's `dfSchema`. Confirm its statement matches
      `tr (DF phi)` exactly; any residual mismatch is reassociation work, done here.
- [ ] Each lemma carries the `minFrameClass <= fc` side condition in the same shape Phase 8 needs;
      discharge those conditions by `decide` (`FrameClass` is finite with `DecidableEq` and a
      `DecidableRel` instance, `Axioms.lean:531`).
- [ ] Append to `FormalSystem/BaseLanguage/AxiomDischarge.lean` (same file as Phase 6 — hence the
      sequential dependency rather than a parallel wave).

**Timing**: 1 hour

**Depends on**: 6

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts exactly three extension-row items (DN/CO/DF) and that
`Axiom.density` is a literal match for DN. Confirm the literal-match claim by `rfl` before
relying on it; confirm `co_derived`'s signature and its `Formula.co` unfolding by
`lean_hover_info` rather than from this plan's transcription.

**Files to modify**:
- `FormalSystem/BaseLanguage/AxiomDischarge.lean` — append DN/CO/DF lemmas.

**Verification**:
- `lake build FormalSystem.BaseLanguage.AxiomDischarge` green.
- `#print axioms` clean on all three; the DF lemma's axiom list must not mention any completeness
  theorem.

---

### Phase 8: The bridge — `translate`, `derivable_translate`, four row corollaries [NOT STARTED]

**Goal**: The backward direction itself: one structural recursion, its Prop-level corollary, and
the four paper rows as instantiations.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Conservativity.lean`; import `FormalSystem.BaseLanguage` and
      `FormalSystem.ProofSystem`. **Do not import any `FormalSystem.Semantics.*` module** — the
      bridge touches no semantics (report §8.4).
- [ ] State and prove the recursion:
      ```
      def translate {fc : FrameClass} {G : BaseLanguage.Context} {phi : BLFormula} :
          BaseLanguage.DerivationTree fc G phi ->
          ProofSystem.DerivationTree fc (G.map tr) (tr phi)
      ```
      Case by case:
      - `axiom` -> the Phase 6/7 lookup table plus the `minFrameClass <= fc` side condition
        by `decide`.
      - `assumption` -> `List.mem_map` to transport membership through `tr`.
      - `modus_ponens`, `weakening` -> structural.
      - `necessitation`, `temporal_necessitation` -> structural (both are empty-context rules on
        both sides; check the context discipline matches).
      - `temporal_duality` -> the load-bearing case:
        `(tr_swapBL phi) |> ProofSystem.DerivationTree.temporal_duality (tr phi) (translate d)`
        (report §8.3 gives the `▸`-rewrite shape).
- [ ] Prove the Prop-level corollary:
      ```
      theorem derivable_translate {fc} {G} {phi} :
          BaseLanguage.Derivable fc G phi -> ProofSystem.Derivable fc (G.map tr) (tr phi)
      ```
- [ ] State and prove the four row corollaries, each at empty context (the paper's rows are
      theoremhood claims):
      - `ceb_backward` at `FrameClass.Base` (TM -> TM+)
      - `cef_backward` at `FrameClass.Discrete` (TM_f -> TM+_f)
      - `ced_backward` at `FrameClass.Dense` (TM_d -> TM+_d)
      - `cec_backward` at `FrameClass.Dedekind` (TM_dc -> TM+_dc)
- [ ] **`cec_backward`'s docstring must record the fidelity caveat**: this repository's
      `Dedekind` class admits the `Dense` axioms (`Dense <= Dedekind`), so `|-[Dedekind]`
      corresponds to the paper's TM+_dc, not TM+_c. There is no repository class for "complete
      but not dense". Say so; do not let a reader infer TM_c.
- [ ] Add `import FormalSystem.Metalogic.Conservativity` to `FormalSystem/Metalogic.lean`.

**Timing**: 1.5 hours

**Depends on**: 3, 7

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts seven recursion cases (one per BL-side rule) and four row
corollaries. The rule count is inherited from Phase 3's actual constructor list — re-derive it
from the file, not from this plan. The four rows are fixed by the task's acceptance criteria and
are not negotiable.

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity.lean` — create; `translate`, `derivable_translate`, four
  row corollaries.
- `FormalSystem/Metalogic.lean` — add one import.

**Verification**:
- `lake build` of `FormalSystem.Metalogic.Conservativity` plus its direct dependent
  `FormalSystem.Metalogic` (tier `interface`: this phase adds to an aggregator).
- All four row corollaries elaborate; no `sorry`.
- `grep -rn 'FormalSystem.Semantics' FormalSystem/Metalogic/Conservativity.lean` returns nothing.

---

### Phase 9: Deliverable B — the refutation record, and the acceptance gate [NOT STARTED]

**Goal**: Permanently record why the forward direction is not attempted, and run the task's full
acceptance gate.

**Tasks**:
- [ ] Write the module docstring at the top of `FormalSystem/Metalogic/Conservativity.lean`
      recording that the **converse (forward) direction is REFUTED for the Base and Discrete rows
      and OPEN for the other two**, with this repository's own axioms as evidence:
      - **CEF / Discrete**: `Axiom.z1` (`ProofSystem/Axioms.lean:347`, `minFrameClass = .Discrete`)
        is built entirely from `allFuture`/`someFuture`/`imp`, so `z1 phi = tr (Z1 phi')` for the
        obvious BL formula `Z1`. Hence `|-[Discrete] tr(Z1)` holds by a **one-line axiom
        invocation**, while `TM_f |- Z1` is refuted by soundness over Z x_lex Z. The forward
        direction is false by construction of this repository's own axiom set, with **no appeal
        to completeness**.
      - **CEB / Base**: `Axiom.discrete_box_necessity` is the paper's TMP-NB (`X top -> box X top`)
        and `Axiom.modal_5_collapse` is M5; both fall to `.Base` via `minFrameClass`'s catch-all,
        so the paper's (Sp) derivation is available verbatim in `|-[FrameClass.Base]`.
      - **CED / CEC**: open in the source; no counterexample is known.
- [ ] State the **zero-debt consequence** in the docstring: writing
      `theorem forward : |-[fc] tr phi -> BaseLanguage.Derivable fc [] phi` and discharging it
      with `sorry` would place a `sorry` on a provably false statement — an unsound placeholder,
      not deferred debt. This paragraph exists to stop a future dispatch re-attempting it.
- [ ] Cite the **deleted-theorem provenance**, not a live `\label`:
      `\label{thm:ConservativeExtension}` was deleted from the paper on 2026-08-14 (commit
      `c0116d04`); cite the last revision carrying it, **`58c7c0c0^` (2026-08-12)**, and mark the
      citation explicitly as historical. Do not cite it as a live anchor.
- [ ] Note that a machine-checked (rather than documented) refutation would need BL-side
      semantics + soundness and the two-fibre / Z x_lex Z countermodels, all out of scope here.
- [ ] Run `bash scripts/check-paper-definitions.sh` and cite
      `specs/paper-definitions-of-record.md` for any semantic definition the docstring leans on,
      rather than the paper directly.
- [ ] **Acceptance gate**:
      - `lake build` green from a clean state.
      - No new `sorry` anywhere: compare the repo-wide live-`sorry` count against its pre-task
        baseline of one (`WeakCanonical.countermodel_discrete`, per `FormalSystem/Metalogic.lean:37`).
      - No new `axiom` declaration anywhere.
      - `#print axioms` clean on `ceb_backward`, `cef_backward`, `ced_backward`, `cec_backward`.
      - `grep -rn 'FormalSystem.Semantics' FormalSystem/BaseLanguage/ FormalSystem/Metalogic/Conservativity.lean`
        returns nothing (the composability invariant).
      - The docstring names `Axiom.z1` and `Axiom.discrete_box_necessity` verbatim.

**Timing**: 1 hour

**Depends on**: 8

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts a repo-wide pre-task baseline of exactly one live
`sorry` outside `Boneyard/`. Confirm that baseline at implementation time before comparing
against it — if the baseline has moved for unrelated reasons, compare the delta introduced by
this task, not the absolute count.

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity.lean` — module docstring only (the docstring is prose,
  but the phase's tier is `full` because it runs the whole acceptance gate).

**Verification**:
- The full acceptance-gate checklist above, every item.

---

## Testing & Validation

- [ ] `lake build` completes green with no errors and no new warnings.
- [ ] Repo-wide live `sorry` count outside `Boneyard/` is unchanged from its pre-task baseline.
- [ ] No new `axiom` declaration introduced (`grep -rn '^axiom ' FormalSystem/` delta is empty).
- [ ] `#print axioms FormalSystem.Metalogic.Conservativity.ceb_backward` — clean.
- [ ] `#print axioms FormalSystem.Metalogic.Conservativity.cef_backward` — clean, and in
      particular free of any `completeness_*` dependency (which would indicate Route B crept in
      without approval).
- [ ] `#print axioms FormalSystem.Metalogic.Conservativity.ced_backward` — clean.
- [ ] `#print axioms FormalSystem.Metalogic.Conservativity.cec_backward` — clean.
- [ ] `#print axioms FormalSystem.BaseLanguage.tr_swapBL` — clean.
- [ ] `#print axioms FormalSystem.Theorems.DiscreteUnfolding.dfSchema` — clean.
- [ ] `grep -rn 'FormalSystem.Semantics' FormalSystem/BaseLanguage/` returns nothing.
- [ ] No `theorem forward`, no forward-direction statement, and no `sorry` anywhere in
      `Conservativity.lean`.
- [ ] The `Conservativity.lean` module docstring contains the literal strings `Axiom.z1` and
      `Axiom.discrete_box_necessity`, and cites `58c7c0c0^` marked as historical.

## Artifacts & Outputs

- `FormalSystem/BaseLanguage/Formula.lean` — `BLFormula`, derived operators, `swapBL`,
  `DecidableEq`, `Countable`, `swapBL_involution`.
- `FormalSystem/BaseLanguage/Axioms.lean` — `BaseLanguage.Axiom`, `Axiom.minFrameClass`.
- `FormalSystem/BaseLanguage/Derivation.lean` — `BaseLanguage.DerivationTree` (7 rules,
  `temporal_duality` via `swapBL`), `Derivable`, notation.
- `FormalSystem/BaseLanguage/Translation.lean` — `tr`, `tr_swapBL`, range lemmas,
  push-through lemmas, `tr_injective`.
- `FormalSystem/BaseLanguage/AxiomDischarge.lean` — per-axiom BL+ discharge table (Base row +
  DN/CO/DF).
- `FormalSystem/BaseLanguage.lean` — aggregator.
- `FormalSystem/Metalogic/Conservativity.lean` — `translate`, `derivable_translate`,
  `ceb_backward`, `cef_backward`, `ced_backward`, `cec_backward`, and the Deliverable B
  refutation docstring.
- `FormalSystem/Theorems/DiscreteUnfolding.lean` — appended `dfSchema` (DF at `Discrete`).
- `FormalSystem/FormalSystem.lean`, `FormalSystem/Metalogic.lean` — one import line each.

## Rollback/Contingency

Every new file lives under `FormalSystem/BaseLanguage/` or is
`FormalSystem/Metalogic/Conservativity.lean`; the only edits to pre-existing files are three
append-only changes (`FormalSystem/FormalSystem.lean` import, `FormalSystem/Metalogic.lean`
import, `FormalSystem/Theorems/DiscreteUnfolding.lean` appended declarations). Rollback is
therefore: delete the new files, revert the two import lines, and `git revert` the
`DiscreteUnfolding.lean` commits. Because commit mode is `per-substep` throughout, each phase is
independently revertable at a green build.

**Partial-landing contingency**: if Phase 5 (DF at `Discrete`) stalls and Route B is not
approved, Phases 1-4, 6 (Base row), 8 and 9 can still land with `cef_backward` omitted — the
other three row corollaries do not depend on DF. In that case mark Phase 5 `[BLOCKED]`, mark
Phase 7 `[PARTIAL]`, and record the omission as a Reasoned Exclusion on Phase 8 rather than
stating `cef_backward` with a `sorry`.
