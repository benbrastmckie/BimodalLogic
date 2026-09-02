# Territory C: Frames, Frame Properties & Correspondence — Findings

Reviewed read-only against `main` @ `257cad9b8`. 28 files, 9,516 lines, 427 declarations.
No `lake build` run; no MCP diagnostics called.

---

## 1. Architecture assessment

**The load-bearing architecture is right, and unusually well documented.** Three decisions in
particular are correct and should not be revisited:

1. **`TemporalOrder` as a reified object** (`FormalSystem/Semantics/TemporalOrder.lean`). Naming
   `{D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]` once, as a
   structure with instance-implicit fields plus a `CoeSort`, is exactly the right call. The
   regression `example`s at `TemporalOrder.lean:139-184` that pin numeral elaboration at
   `↑intOrder` and instance-projection defeq are a model of how to make a design premise
   machine-checked rather than folkloric.
2. **The frame fibration** `TaskFrame = Σ (D : TemporalOrder), FrameOver D`
   (`TaskFrame.lean:551,1608`), with the axioms declared *once* on the fibre and the total space
   delegating. The "why a component and not a type parameter" argument (`TaskFrame.lean:38-47`)
   is correct and is what makes `FrameProperty.lean`'s five predicates ordinary
   `TaskFrame → Prop`s.
3. **Bare-relation axiom predicates declared above the structure**
   (`TaskFrame.Serial`/`Interpolates`/`Compositional`/`Spherical`, `TaskFrame.lean:412-469`) so
   that fields cite them *definitionally*. The five `example` blocks that pin
   `F.spherical : Spherical F.TaskRel` (`TaskFrame.lean:1831,1867,1899`) turn that invariant into
   a compile-time acceptance test. This is genuinely good engineering.

**Where the architecture is not yet cashed out.** The territory has *three* well-designed
factoring mechanisms — the `TaskFrame` axiom-class helper kit (Helpers A/B/C plus
`limit_of_shift`/`spherical_of_finite`), `FrameOver.ofStep` for ℤ, and `ShiftSet.frame` for
`D`-actions — and they are under-used at exactly the points where they would pay most. Concretely:

- Every frame in the tree whose relation is *deterministic* re-proves *Spherical* by hand. Seven
  copies (C-01). There is no Helper D for the deterministic class even though `limit_of_shift`
  already serves that class on the *Limit* side.
- Helper B (permissive) covers `serial`/`interpolates`/`limit`/`spherical` but not
  `nullity_identity`/`converse`/forward-`comp`, so three permissive frames carry three verbatim
  copies of those three field bodies (C-03).
- Five `induction φ` truth-transport proofs (~400 lines) with the same six-case skeleton and no
  shared statement (C-02).

**The other systemic gap is `Truth.lean`'s missing Boolean API.** `BLTruth.lean` — the *base
language* mirror — carries a complete `@[simp]` set (`neg_iff`, `top_true`, `and_iff`, `or_iff`,
`diamond_iff`, `somePast_iff`, `someFuture_iff`, `always_iff`). `Truth.lean`, the primary
language, carries none of `and`/`or`/`top`/`always`. The consequence is four independent private
copies of `truth_and_iff` scattered across `Semantics/` and `Metalogic/` (C-04). The territory has
17 `@[simp]` lemmas across 427 declarations; the ones that would pay are the frame-constant truth
lemmas that are currently proved and then never tagged (C-05).

**Correspondence layer.** `Galois.lean` reimplements `Mathlib.Order.Concept`'s polarity API
verbatim (C-06) — the single highest ratio of deleted-lines to risk in the territory.
`FwdRecBridge.lean` reimplements `IntNormalForm.lean`'s ℤ step-path dictionary under different
names, in a module that does not import it, though it is upstream (C-07). The `Walk`/`MinCyc`
combinatorics, by contrast, are *not* in Mathlib and should stay (Q6, §4 C-14).

**Two premises in the review brief are wrong and worth correcting.** (a) There is no
`synthInstance.maxHeartbeats` override anywhere in the territory: the two occurrences at
`TemporalOrder.lean:178,181` *lower* the budget to 2000 (Mathlib's default is 20000) as
performance regression guards. (b) There is no `decide`/`native_decide` heaviness: the single
`decide` is the 7-case absurd branch of `FrameClass.Sat.anti`
(`FrameClassValidity.lean:117`), which is correct and cheap. Territory-wide: 0 `sorry`,
0 heartbeat overrides, 0 `native_decide`.

---

## 2. Frame-property representation map (Q1) and hypothesis-bundle census (Q2)

### Q1 — the map, and whether it drifts

Frame properties are expressed in **four** distinct registers, and the split is *principled*, not
accidental:

| Register | Where | Examples |
|---|---|---|
| `FrameOver` structure fields | `TaskFrame.lean:551-691` | `comp`, `converse`, `serial`, `limit`, `spherical`, `nullity_identity`, `worldNonempty` |
| Bare-relation `Prop` predicates | `TaskFrame.lean:412-469` | `Spherical`, `Serial`, `Interpolates`, `Compositional` (*Limit* deliberately unnamed) |
| `TaskFrame → Prop` predicates | `FrameProperty.lean` | `IsDense`, `IsDiscrete`, `IsSuccArchDiscrete`, `IsComplete`, `IsDedekind` |
| Mathlib typeclasses on the carrier | statement-level binders | `[DenselyOrdered ↑D]`, `[SuccOrder ↑D]`, `[Archimedean ↑D]`, `[NoMaxOrder ↑D]` |

Each of the five `FrameProperty` predicates is stated **exactly once**; the two "split pairs"
(`IsDiscrete`/`IsSuccArchDiscrete`, `IsComplete`/`IsDedekind`) are related by named projections
rather than by a duplicate definition, and both splits carry a paper citation forcing them
(`FrameProperty.lean:22-42`). This is correct.

**The `FrameClass → Sat → Valid*` chain does not drift.** Verified end to end:

```
FrameClass.Sat  (FrameClassValidity.lean:110)   .Base ↦ True | .Dense ↦ IsDense
                                                 .Discrete ↦ IsSuccArchDiscrete
                                                 .Dedekind ↦ IsDedekind
ValidOnFrames P (Validity.lean:326)            = ∀ F, P F → F.ValidOn φ
ValidIn fc      (Validity.lean:337)            = ValidOnFrames fc.Sat φ
ValidDense      (Validity.lean:534)            = ValidIn .Dense          -- Iff.rfl
ValidDiscrete   (Validity.lean:608)            = ValidIn .Discrete       -- Iff.rfl
ValidDedekindDense (Validity.lean:765)         = ValidIn .Dedekind       -- Iff.rfl
ValidDedekind   (Validity.lean:711)            = ValidOnFrames IsComplete   ← the outlier
```

The `Sat`-to-binder adapters (`ValidDense.of_forall`/`.apply`, etc.) exist precisely because
`Sat .Dense F` has head symbol `TaskFrame.IsDense`, invisible to instance search — this is the
right fix and is documented at `Validity.lean:539-546`.

**Recommendation on representation.** *Do not* introduce `class FrameClass.Sat` with instances:
`IsSuccArchDiscrete` is an existential over data-carrying `SuccOrder`/`PredOrder`
(`FrameProperty.lean:113`), so it cannot be a class, and the `haveI`-versus-`@` trap recorded at
`Validity.lean:612-616` shows why routing those witnesses through the instance cache is actively
wrong. The current design is the right one. The only representation changes worth making are the
narrow ones in C-08 (`ValidDedekind` misnaming) and C-09 (`ValidDedekind.of_not` missing).

### Q2 — hypothesis-bundle census

Normalized instance-binder multisets across `FormalSystem/**` (excluding `Boneyard/`):

| Bundle | Occurrences | Named? |
|---|---|---|
| `[AddCommGroup] [LinearOrder] [IsOrderedAddMonoid] [Nontrivial]` | 36 adjacent + 163 `AddCommGroup` mentions total | **Yes** — `TemporalOrder` (but see below) |
| `[SuccOrder] [PredOrder] [NoMaxOrder] [NoMinOrder] [IsSuccArchimedean] [IsPredArchimedean]` (the "discrete bundle", split across lines) | 58 + 48 + 26 + 27 fragment hits; `IsSuccArchimedean` appears in **38 non-Boneyard files** | **No** |
| `[SuccOrder] [NoMaxOrder]` (the "*Limit* is free" bundle) | 51 | **No** |
| `[Countable] [DenselyOrdered]` | 25 | **No** |

Two conclusions:

1. **The `TemporalOrder` migration is incomplete inside its own territory.** `TaskFrame.lean`
   re-declares the raw four-binder bundle **five times** — lines 224, 783, 1308, 1775, 1863 — plus
   inline at `staticFrame` (1379), `natFrame` (1449), `trivialFrame` (1316). `WorldHistory.lean`
   has 7 more (lines 172, 193, 215, 399, 416, 430, 436). These are the bare-relation and
   frame-constant layers, which genuinely cannot take `(D : TemporalOrder)` for the helper
   *statements* — but the frame *constants* (`staticFrame`, `natFrame`, `trivialFrame`,
   `WorldHistory.trivial`, `universalTrivialFrame`, `universalNatFrame`) all produce
   `FrameOver (TemporalOrder.of D)` and could take `(D : TemporalOrder)` directly, matching their
   already-migrated twins in `Examples/TemporalStructures.lean`
   (`genericTimeFrame`/`genericNatFrame` at lines 331/382). See C-03, which subsumes this.
2. **The discrete bundle has no name and should have one.** It is the single largest un-named
   bundle in the tree. A `TemporalOrder`-shaped structure is wrong here (these *are* genuine
   carrier side conditions, correctly kept as binders per `TaskFrame.lean:200-203`), but a
   `variable` block per module plus an `abbrev` for the *predicate* form would remove most of the
   noise. See C-10.

**No place passes an explicit hypothesis where an instance would be found automatically.** The
reverse (instance where explicit is needed) is also absent. `succOrder_of_isLeast_pos`
(`DurationFrames.lean:96`) and `noMaxOrder_of_duration` (`DurationFrames.lean:78`) are
deliberately plain lemmas rather than global instances, with the reason recorded at
`DurationFrames.lean:41-44` — correct, and it should stay that way.

---

## 3. Countermodel-frame inventory (Q3)

| Frame | Carrier `W` | Duration | Defined at | Relation class | Axiom discharge |
|---|---|---|---|---|---|
| `FrameOver.trivialFrame` | `Unit` | any `D` | `TaskFrame.lean:1316` | total | Helper A (4/4 via kit) |
| `FrameOver.staticFrame` | any `W` | any `D` | `TaskFrame.lean:1379` | equality | Helper C (4/4 via kit) |
| `FrameOver.natFrame` | `ℕ` | any `D` + `[SuccOrder][NoMaxOrder]` | `TaskFrame.lean:1449` | permissive | Helper B for 4; **`nullity_identity`, `converse`, fwd-`comp` inline (~28 lines)** |
| `intTimeFrame` | `Unit` | `intOrder` | `Examples/TemporalStructures.lean:78` | total | Helper A |
| `intNatFrame` | `ℕ` | `intOrder` | `Examples/TemporalStructures.lean:123` | permissive | **inline copy of `natFrame`** |
| `intBoolFrame` | `Bool` | `intOrder` | `Examples/TemporalStructures.lean:225` | permissive | inline |
| `genericTimeFrame` | `Unit` | `(D : TemporalOrder)` | `Examples/TemporalStructures.lean:331` | total | Helper A |
| `genericNatFrame` | `ℕ` | `(D : TemporalOrder)` | `Examples/TemporalStructures.lean:382` | permissive | **verbatim copy of `natFrame`** |
| `translationFrame D` | `↑D` | `(D : TemporalOrder)` | `Correspondence/DurationFrames.lean:122` | deterministic shift | `limit_of_shift`; **`spherical` inline (16 lines), `nullity`/`comp`/`converse` inline** |
| `permissiveFrame D so nm` | `Bool` | `(D : TemporalOrder)` | `Correspondence/DurationFrames.lean:210` | permissive | Helper B for 3; **`nullity`/fwd-`comp`/`converse` inline (~30 lines)** |
| `clockFrame` | `ℚ ⧸ ℤ` | `TemporalOrder.of ℚ` | `Independence/ClockFrame.lean:178` | deterministic shift | **`clockRel_limit` bespoke (33 lines), `clockRel_spherical` inline (12 lines)** |
| `ratStaticFrame` | `Bool` | `ℚ` | `Independence/RationalWitness.lean:105` | equality | **reuses `staticFrame`** ✓ |
| `lexIntStaticFrame` | `Bool` | `ℤ ×ₗ ℤ` | `Independence/LexIntWitness.lean:149` | equality | **reuses `staticFrame`** ✓ |
| `flipFrame` | `Bool` | `intOrder` | `IntNormalForm.lean:518` | arbitrary bi-serial | **reuses `FrameOver.ofStep`** ✓ (7/7 free) |
| `ShiftSet.frame S` | `S.Carrier` | any `D` | `ShiftSet.lean` (`fibre` ~150-200) | deterministic action | 6/7 free; **`spherical` inline (17 lines)** |
| `zTaskFrameV2` | (flow) | `intOrder` | `WeakCanonical/.../ReynoldsBridge.lean:453` | deterministic shift | **`spherical` inline + `zTaskFrameV2_spherical`** |
| `multiFamTaskFrame(Gen)` | (flow) | `intOrder` / any | `ReynoldsBridge.lean:767`, `Algebraic/FlowFrame.lean` | deterministic shift | `Algebraic.sInter_nonempty_of_directed_subsingleton` |
| `regionFrame` | (flow) | any | `Decidability/.../RegionFrame.lean:208` | deterministic shift | **`spherical` inline + `regionFrame_spherical`** |
| `zHistory`/`zModel` over `natFrame` | `ℕ` | `ℤ` | `Metalogic/DiscreteNonCompactness.lean:149` | — | **reuses `natFrame`** ✓ |
| `z1F = multiFamTaskFrameGen z1D Unit` | — | `ℚ ×ₗ ℤ` | `Metalogic/Z1Countermodel.lean:65` | — | **reuses the gen frame** ✓ |

**Verdict on Q3.** A smart-constructor kit *exists* and works (`ofStep`, `staticFrame`,
Helpers A–C, `limit_of_shift`, `spherical_of_finite`); five sites reuse it cleanly. But the kit
is **missing its two most-needed members** — a deterministic-class *Spherical* helper (7 sites
duplicate it, C-01) and the three remaining permissive-class field helpers (3 sites duplicate
them, C-03) — and the constants themselves live in **five different homes** with no index
(C-11). The proposed `Semantics/Frames/Standard.lean` is worth doing, but *after* C-01/C-03,
which are where the line savings are.

Auxiliary duplication in the same family: every countermodel repeats the same
history + model + atom-truth triple with `domain := fun _ => True`,
`nonempty_domain := ⟨0, trivial⟩`, `convex := fun _ ... => trivial` — at
`DurationFrames.lean:174` (`translationHist`), `:257` (`permissiveHist`),
`ClockFrame.lean:227` (`clockHistory`), `FwdRecBridge.lean:95` (`ofWalk`),
`IntNormalForm.lean:310` (`HFofStepPath`), `DiscreteNonCompactness.lean:149` (`zHistory`).
See C-12.

---

## 4. Findings

### C-01. Seven copies of the "deterministic frame ⟹ *Spherical*" argument, and two competing generic helpers

- **Severity**: High
- **Category**: duplication / abstraction
- **Anchors**:
  - `FormalSystem/Semantics/TaskFrame.lean:977` `TaskFrame.sInter_nonempty_of_directed_of_univ_or_singleton`
  - `FormalSystem/Metalogic/Algebraic/FlowFrame.lean:116` `Algebraic.sInter_nonempty_of_directed_subsingleton`
  - `FormalSystem/Metalogic/Independence/ClockFrame.lean:110` `clockRel_fib_subsingleton`, `:156` `clockRel_spherical`
  - `FormalSystem/Semantics/Correspondence/DurationFrames.lean:110` `translationRel_fib_subsingleton`, `:163-178` `translationFrame.spherical` (inline)
  - `FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionFrame.lean:208` (inline), `:253` `regionFrame_fib_subsingleton`, `:295` `regionFrame_spherical`
  - `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean:464` (inline), `:485` `zTaskFrameV2_fib_subsingleton`, `:522` `zTaskFrameV2_spherical`, `:784` (inline)
  - `FormalSystem/Semantics/ShiftSet.lean:186` (inline, hand-rolled, using *neither* helper)
- **Description**: Every deterministic frame in the tree discharges *Spherical* by the same
  three-step argument — fibres are subsingletons, segments are intersections of fibres hence
  subsingletons, a directed family of nonempty subsingletons has nonempty intersection. The
  argument appears seven times. `clockRel_spherical` (ClockFrame:156-167) and the `spherical`
  field of `translationFrame` (DurationFrames:163-178) are the *same ten-line tactic script*,
  differing only in which `*_fib_subsingleton` lemma they name — a fact the `translationFrame`
  docstring admits verbatim ("*Spherical* copies `ClockFrame.clockRel_spherical`'s argument",
  `DurationFrames.lean:116`). Worse, two generic helpers exist for the same job in different
  namespaces and different layers, and sites split between them arbitrarily; `ShiftSet.lean:186`
  uses neither and inlines a third variant.
- **Impact**: ~90 lines of duplicated proof. Any future flow-style frame pays the same tax. The
  two competing helpers mean a reader cannot tell which is canonical, and `Algebraic.*` living in
  `Metalogic/` makes it unreachable from `Semantics/`.
- **Recommendation**: Add **Helper D** to `TaskFrame.lean`, immediately after Helper C
  (`TaskFrame.lean:1237-1295`), mirroring the section structure already there:

  ```lean
  /-! ### Helper D — the deterministic class: every fibre is a subsingleton -/

  omit [IsOrderedAddMonoid D] in
  /-- A directed family of nonempty subsingletons has nonempty intersection. -/
  theorem sInter_nonempty_of_directed_subsingleton {W : Type} {S : Set (Set W)}
      (hdir : DirectedFamily S) (hne : ∀ s ∈ S, s.Nonempty)
      (hsub : ∀ s ∈ S, s.Subsingleton) : (⋂₀ S).Nonempty

  omit [IsOrderedAddMonoid D] in
  /-- *Spherical* for any relation whose fibres are subsingletons: segments are
      intersections of fibres, so every member of the family is a subsingleton. -/
  theorem spherical_of_fib_subsingleton {W : Type} {R : W → D → W → Prop}
      (h : ∀ w x, (Fib R w x).Subsingleton) : Spherical R

  /-- The determinism hypothesis in the shape a shift/flow relation supplies it. -/
  theorem fib_subsingleton_of_functional {W : Type} {f : W → D → W}
      {R : W → D → W → Prop} (hR : ∀ w x u, R w x u ↔ u = f w x) :
      ∀ w x, (Fib R w x).Subsingleton
  ```

  Then: `spherical := spherical_of_fib_subsingleton (fib_subsingleton_of_functional
  fun _ _ _ => Iff.rfl)` at all seven sites, and delete `Algebraic.sInter_nonempty_of_directed_subsingleton`
  (re-export from `TaskFrame` if the `Metalogic` name is load-bearing). Note this pairs exactly
  with the existing `limit_of_shift` (`TaskFrame.lean:846`), which already serves the same class
  on the *Limit* side — the kit's "fourth class, deterministic shift, is already served by
  `limit_of_shift`" remark (`TaskFrame.lean:1067`) is half-true; it is served on one axiom of four.
- **Effort**: M
- **Depends on**: -

### C-02. Five independent `induction φ` truth-transport proofs with no shared statement

- **Severity**: High
- **Category**: abstraction / proof-elegance
- **Anchors**:
  - `FormalSystem/Semantics/Truth.lean:450` `time_shift_preserves_truth` (~90 lines of proof)
  - `FormalSystem/Semantics/IntTransfer.lean:292` `truthAt_map` (~68 lines)
  - `FormalSystem/Semantics/Correspondence/FwdRecPeriodicity.lean:356` `truthAt_add_hist_period` (~70 lines)
  - `FormalSystem/Metalogic/Independence/LoopingDuration.lean:98` `truthAt_add_period` (~64 lines)
  - `FormalSystem/Metalogic/Independence/CoNotPriorU.lean:416` `truthAt_mirror` (~80 lines)
- **Description**: All five prove "truth is preserved by a semantic symmetry" by the *same*
  six-case induction on `Formula` (`atom`/`bot`/`imp`/`box`/`untl`/`snce`), with the *same*
  structural trick — generalize over the history inside the induction so the `box` case can apply
  the IH — a trick each of the five docstrings independently explains
  (`LoopingDuration.lean:93-96`, `IntTransfer.lean:284-286`, `CoNotPriorU.lean:411-414`,
  `Independence/README.md`). The `untl` and `snce` cases in each are mirror images of one another,
  doubling the arithmetic within each proof. Every one of the five is an instance of a single
  statement: truth transports along a pair (order-(anti)isomorphism `e` of `F.Duration`, bijection
  of total histories commuting with `e`) preserving the atom valuation.
- **Impact**: ~370 lines of proof body doing one argument five times. Any new symmetry
  (a sixth countermodel, a shift-recurrence generalisation of `FwdRec` — which
  `FwdRecBridge.lean:38-44` names as open work) pays the full cost again. Each copy is also an
  independent place for the `box` case to be got subtly wrong.
- **Recommendation**: Introduce one transport lemma in `Semantics/Truth.lean` and derive the five:

  ```lean
  /-- A semantic isomorphism between two models: an order-isomorphism of durations
      together with a bijection of total histories commuting with it and preserving atoms. -/
  structure TruthIso {F F' : TaskFrame} (M : TaskModel F) (M' : TaskModel F') where
    dur   : F.Duration ≃o F'.Duration
    hist  : F.HF ≃ F'.HF
    atom  : ∀ (τ : F.HF) (t : F.Duration) (p : Atom),
              M.valuation (τ.val.states t (τ.property t)) p ↔
              M'.valuation ((hist τ).val.states (dur t) ((hist τ).property (dur t))) p

  theorem truthAt_of_truthIso {F F'} {M : TaskModel F} {M' : TaskModel F'}
      (I : TruthIso M M') (φ : Formula) (τ : F.HF) (t : F.Duration) :
      TruthAt M τ.val t φ ↔ TruthAt M' (I.hist τ).val (I.dur t) φ
  ```

  with an order-*reversing* companion `truthAt_of_truthAntiIso` concluding
  `TruthAt M' _ _ φ.swapTemporal`, which is what `CoNotPriorU.truthAt_mirror` needs. Then
  `time_shift_preserves_truth`, `truthAt_add_period`, `truthAt_add_hist_period` are the instance
  at `dur := (· + Δ)`, `truthAt_map` the instance at a `≃+o`, and `truthAt_mirror` the
  anti-instance at `Neg.neg`. Expected: one ~90-line proof plus five ~10-line instantiations.
  Land it incrementally — start with the three period/shift cases, which share `dur := (· + π)`
  exactly, before attempting `truthAt_map`'s `Aligned`-relational shape.
- **Effort**: L
- **Depends on**: -

### C-03. Helper B (permissive class) is incomplete; three frames carry verbatim copies of the three missing field bodies

- **Severity**: High
- **Category**: duplication / abstraction
- **Anchors**:
  - Helper B as it stands: `FormalSystem/Semantics/TaskFrame.lean:1129-1235`
    (`Fib_permissive_zero`, `Fib_permissive_ne`, `serial_of_permissive`,
    `interpolates_of_permissive`, `limit_of_permissive`, `univ_or_singleton_of_permissive`,
    `spherical_of_permissive`)
  - `FormalSystem/Semantics/TaskFrame.lean:1453-1503` `natFrame` — `nullity_identity`, forward
    half of `comp`, `converse` inline (~28 lines)
  - `FormalSystem/Examples/TemporalStructures.lean:382-...` `genericNatFrame` — **verbatim copy**
    of the same three bodies, with `TemporalOrder.of D` replaced by `(D : TemporalOrder)`
  - `FormalSystem/Semantics/Correspondence/DurationFrames.lean:210-250` `permissiveFrame` —
    third copy on `W = Bool` (~30 lines)
  - `FormalSystem/Examples/TemporalStructures.lean:123` `intNatFrame`, `:225` `intBoolFrame` —
    two further specialisations
- **Description**: Helper B supplies four of the seven `FrameOver` fields for the permissive
  class `R w d u ↔ (d ≠ 0 ∨ w = u)`. The other three — `nullity_identity`, `converse`, and the
  forward-composition half of `comp` — have no helper, so every permissive frame inlines them.
  The forward-`comp` body in particular is a ~20-line sign argument
  (`0 ≤ x`, `0 ≤ y`, `x + y = 0` ⟹ `x = 0 ∧ y = 0`) reproduced three times character-for-character.
  `natFrame` and `genericNatFrame` differ only in their duration binder.
- **Impact**: ~85 lines of duplicated proof; three places where the sign argument can drift. It
  also blocks the `TemporalOrder` migration of `TaskFrame.lean`'s frame constants (§2, Q2), since
  the duplication is what makes `natFrame`/`genericNatFrame` two definitions instead of one.
- **Recommendation**: Complete Helper B, and then delete one of the two `natFrame`s:

  ```lean
  theorem nullity_identity_of_permissive {W : Type} {R : W → D → W → Prop}
      (hR : ∀ w d u, R w d u ↔ (d ≠ 0 ∨ w = u)) : ∀ w u, R w 0 u ↔ w = u
  theorem converse_of_permissive {W : Type} {R : W → D → W → Prop}
      (hR : ∀ w d u, R w d u ↔ (d ≠ 0 ∨ w = u)) : ∀ w d u, R w d u ↔ R u (-d) w
  theorem forward_comp_of_permissive {W : Type} {R : W → D → W → Prop}
      (hR : ∀ w d u, R w d u ↔ (d ≠ 0 ∨ w = u)) :
      ∀ w u v x y, 0 ≤ x → 0 ≤ y → R w x u → R u y v → R w (x + y) v
  theorem comp_of_permissive {W : Type} {R : W → D → W → Prop}
      (hR : ∀ w d u, R w d u ↔ (d ≠ 0 ∨ w = u)) : Compositional R :=
    comp_of (interpolates_of_permissive hR) (forward_comp_of_permissive hR)
  ```

  With those, every permissive frame becomes seven one-line field discharges. Then migrate
  `natFrame`, `staticFrame`, `trivialFrame` to `(D : TemporalOrder)` and delete
  `genericNatFrame`/`genericTimeFrame` from `Examples/TemporalStructures.lean` as redundant, or
  keep them as `abbrev`s pointing at the `TaskFrame.lean` constants.
- **Effort**: M
- **Depends on**: -

### C-04. `Truth.lean` has no Boolean-operator API, so `truth_and_iff` exists in four private copies

- **Severity**: High
- **Category**: duplication / api-ergonomics
- **Anchors**:
  - `FormalSystem/Semantics/Truth.lean:182-334` — the `@[simp]` set: `bot_false`, `imp_iff`,
    `atom_iff_of_domain`, `box_iff`, `some_future_iff`, `some_past_iff`, `future_iff`, `past_iff`,
    `strong_release_iff`, `strong_trigger_iff`. **No `and`, `or`, `top`, `neg`, `always`.**
  - `FormalSystem/Semantics/BLTruth.lean:144` `and_iff`, `:150` `or_iff`, `:141` `top_true`,
    `:138` `neg_iff`, `:191` `always_iff` — all `@[simp]`, the *complete* set, on the base
    language
  - Copy 1: `FormalSystem/Semantics/Correspondence/DurationFrames.lean:298` `truth_and_iff`,
    `:309` `truth_always_of_forall`, `:319` `truth_of_always`
  - Copy 2: `FormalSystem/Metalogic/DedekindNonCompactness.lean:158` `truth_and_iff'`
  - Copy 3: `FormalSystem/Metalogic/Independence/CoNotPriorU.lean:180` `truth_and_iff`, `:190`
    `truth_or_iff`, `:177` `truth_top`
  - Copy 4: `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean:1408` `truthAt_and`
- **Description**: The primary language's truth relation is missing exactly the derived-Boolean
  lemmas its base-language mirror already carries. Four modules independently rediscovered
  `truth_and_iff`. `DedekindNonCompactness.lean:154-157` even documents the situation and elects
  to keep the copy: "an identical `truth_and_iff` exists at
  `Semantics/Correspondence/DurationFrames.lean:299`; importing that module here would be legal
  but would widen this file's import closure for three lines, so the local copy is kept
  deliberately." That reasoning is correct *given the current placement* — and is precisely the
  signal that the lemma is in the wrong module. `Truth.lean` is already in every one of the four
  import closures.
- **Impact**: Four maintenance points for one three-line fact; and, because `Formula.and` is
  `¬(A → ¬B)`, every proof that touches a conjunction must first find or rebuild the
  double-negation step. `DurationFrames.lean`'s three (T1) theorems open with
  `rw [truth_and_iff, truth_and_iff]` (lines 432, 454) purely to get past this.
- **Recommendation**: Add to `Semantics/Truth.lean`, mirroring `BLTruth.lean:138-195` one for one:
  `@[simp] Truth.neg_iff`, `@[simp] Truth.top_true`, `@[simp] Truth.and_iff`,
  `@[simp] Truth.or_iff`, `@[simp] Truth.always_iff`. Delete all four copies plus
  `truth_always_of_forall`/`truth_of_always` (both become one-liners over `always_iff`). Deletes
  ~55 lines and removes the *only* place in the territory where a module docstring argues for
  keeping a known duplicate.
- **Effort**: S
- **Depends on**: -

### C-05. Frame-constant truth lemmas are proved but not `@[simp]`-tagged, forcing an 8-site `rw [show τ.val = … from rfl, …]` idiom

- **Severity**: Medium
- **Category**: tactic-automation
- **Anchors**:
  - Untagged: `Correspondence/DurationFrames.lean:194` `translationModel_atom`, `:283`
    `permissiveModel_atom`; `Independence/CoNotPriorU.lean:120` `clock_atom_truth`;
    `Metalogic/DiscreteNonCompactness.lean:171` `zTruth_atom`
  - Tagged (correctly): `DurationFrames.lean:170` `translationFrame_taskRel`, `:253`
    `permissiveFrame_taskRel`; `ClockFrame.lean:213` `clockFrame_taskRel`
  - The idiom, 8 occurrences: `DurationFrames.lean:409, 424, 437, 441, 452, 500, 505, 531`
    (`rw [show τ.val = translationHist D from rfl, translationModel_atom]` and its permissive twin)
- **Description**: The atom-truth characterisations of the countermodel frames — exactly the
  lemmas a proof reaches for on every step — carry no `@[simp]`, while the task-relation lemmas
  next to them do. The result is that each use costs an explicit `rw` plus a
  `show … from rfl` to bridge `τ.val` and the underlying history. The territory has 17 `@[simp]`
  tags across 427 declarations (4%).
- **Impact**: Eight noisy rewrite chains in the three (T1) proofs; every future use of these
  frames pays the same. It is also the main reason `validOn_co_iff_isComplete`
  (`DurationFrames.lean:485`, 78 lines) reads as long as it does.
- **Recommendation**: Tag the four atom-truth lemmas `@[simp]`, and add the `τ.val`-normalised
  forms so `simp` closes the bridge in one step:

  ```lean
  @[simp] theorem translationHist_val (D : TemporalOrder) :
      (⟨translationHist D, translationHist_isTotal D⟩ : (translationFrame D).toTaskFrame.HF).val
        = translationHist D := rfl
  ```

  Then `rw [show τ.val = translationHist D from rfl, translationModel_atom]` becomes `simp`.
  Do the same for `permissiveHist`, `clockHistory`, `zHistory`.
- **Effort**: S
- **Depends on**: -

### C-06. `Galois.lean` reimplements `Mathlib.Order.Concept`'s polarity API

- **Severity**: Medium
- **Category**: duplication / math-insight
- **Anchors**:
  - `FormalSystem/Semantics/Correspondence/Galois.lean:90` `Th`, `:99` `Mod`, `:106` `th_anti`,
    `:110` `mod_anti`, `:114` `subset_mod_th`, `:118` `subset_th_mod`, `:122` `mod_th_mod`,
    `:126` `th_mod_th`, `:134` `GaloisClosed`, `:137` `galoisClosed_mod`
  - Mathlib (`Mathlib.Order.Concept`, present in the pinned tree — verified by `loogle`):
    `upperPolar`, `lowerPolar`, `subset_lowerPolar_upperPolar`, `subset_upperPolar_lowerPolar`,
    `lowerPolar_upperPolar_lowerPolar`, `upperPolar_lowerPolar_upperPolar`,
    `gc_upperPolar_lowerPolar`, `Order.IsExtent`, `Order.isExtent_iff`,
    `Order.isExtent_lowerPolar`, `Order.IsExtent.iInter`, `Order.IsExtent.univ`,
    `upperPolar_empty`, `Concept` (a `CompleteLattice`)
- **Description**: With `r : TaskFrame → Formula → Prop := fun F φ => F.ValidOn φ`, the entire
  first half of `Galois.lean` is Mathlib's polarity API on the nose:

  | `Galois.lean` | Mathlib |
  |---|---|
  | `Th K` | `upperPolar r K` |
  | `Mod S` | `lowerPolar r S` |
  | `subset_mod_th` | `subset_lowerPolar_upperPolar` |
  | `subset_th_mod` | `subset_upperPolar_lowerPolar` |
  | `mod_th_mod` | `lowerPolar_upperPolar_lowerPolar` |
  | `th_mod_th` | `upperPolar_lowerPolar_upperPolar` |
  | `GaloisClosed K` | `Order.IsExtent r K` (`isExtent_iff` is the definition, verbatim) |
  | `galoisClosed_mod` | `Order.isExtent_lowerPolar` |
  | `th_anti` / `mod_anti` | `(gc_upperPolar_lowerPolar r).monotone_l` / `.monotone_u` |

  This is not a superficial resemblance: `Order.isExtent_iff : Order.IsExtent r s ↔
  lowerPolar r (upperPolar r s) = s` is character-for-character `GaloisClosed K = Mod (Th K) = K`.
- **Impact**: ~45 lines of theorem bodies that Mathlib maintains. More importantly, the repo
  forgoes results it would get free and does not currently have: `Order.IsExtent.iInter` (an
  intersection of Galois-closed frame classes is Galois-closed — directly useful for combining
  `galoisClosed_sat_dense` and `galoisClosed_isDiscrete`), `Order.IsExtent.univ`,
  `upperPolar_empty` (`Th ∅ = univ`), and the `Concept TaskFrame Formula r` complete lattice,
  which is the natural home for the "which frame classes are axiomatizable" question the module
  header poses.
- **Recommendation**: Keep `Th`/`Mod`/`GaloisClosed` as the domain-facing names — the module's
  vocabulary is right and downstream sites should keep reading `Mod (AxiomSet .Discrete)` — but
  define them as `abbrev`s over the Mathlib API so the lemmas come for free:

  ```lean
  /-- The frame-validity incidence relation the whole layer is the polarity of. -/
  def validOnRel (F : TaskFrame) (φ : Formula) : Prop := F.ValidOn φ

  abbrev Th (K : Set TaskFrame) : Set Formula := upperPolar validOnRel K
  abbrev Mod (S : Set Formula) : Set TaskFrame := lowerPolar validOnRel S
  abbrev GaloisClosed (K : Set TaskFrame) : Prop := Order.IsExtent validOnRel K
  ```

  Then `th_anti`/`mod_anti`/`subset_*`/`*_th_mod`/`galoisClosed_mod` become one-line
  re-exports (keep them as named theorems — the docstrings are worth preserving), and
  `galoisClosed_of_indicator` (`Galois.lean:158`) is unchanged. Verify the `abbrev`s elaborate
  before committing; if `Set TaskFrame`'s universe (`Type 1`) causes friction, fall back to
  keeping the `def`s and adding `theorem th_eq_upperPolar : Th = upperPolar validOnRel := rfl`
  plus the four free corollaries. Add `Order.IsExtent.iInter` as a named corollary either way.
- **Effort**: M
- **Depends on**: -

### C-07. `FwdRecBridge.lean` re-derives the ℤ step-path dictionary that `IntNormalForm.lean` already proves

- **Severity**: High
- **Category**: duplication
- **Anchors**:
  - `FormalSystem/Semantics/IntNormalForm.lean:177` `FrameOver.step`, `:265` `IsStepPath`,
    `:274` `TaskFrame.HF.path`, `:287` `iter_of_isStepPath`, `:300` `respects_of_isStepPath`,
    `:310` `HFofStepPath`, `:325` `TaskFrame.HF.isStepPath`, `:335` `mem_HF_iff_adjacent`
  - `FormalSystem/Semantics/Correspondence/FwdRecBridge.lean:61` `Bridge.step`, `:65`
    `taskRel_nat`, `:82` `taskRel_diff`, `:95` `ofWalk`, `:105` `ofWalk_isTotal`, `:109`
    `hist_isWalk`
- **Description**: The two modules define the same objects under different names:

  | `FwdRecBridge` | `IntNormalForm` |
  |---|---|
  | `Bridge.step F w u := F.TaskRel w 1 u` | `FrameOver.step F w u := F.TaskRel w 1 u` (identical) |
  | `Walk.IsWalk (step F) σ` | `IsStepPath F σ` (definitionally equal) |
  | `taskRel_nat` | `iter_of_isStepPath` |
  | `taskRel_diff` | `respects_of_isStepPath` |
  | `ofWalk` + `ofWalk_isTotal` | `HFofStepPath` |
  | `hist_isWalk` | `TaskFrame.HF.isStepPath` |
  | (absent) | `mem_HF_iff_adjacent` — the whole dictionary as one `Iff` |

  `IntNormalForm.lean` imports only `Semantics.WorldHistory`, so it sits *upstream* of
  `Correspondence/Galois.lean`'s import chain (`Validity → Truth → TaskModel → WorldHistory`).
  There is no layering obstacle; `FwdRecBridge.lean` simply does not import it.
- **Impact**: ~55 lines of exact duplication, and — more seriously — two names for `step` in the
  same namespace tree, which will confuse anyone navigating the ℤ layer. `mem_HF_iff_adjacent` is
  the sharper statement of the dictionary the `FwdRecBridge` header sets out to establish
  ("every bi-infinite walk in `step F` is a total history … and conversely") and is already proved.
- **Recommendation**: Add `import FormalSystem.Semantics.IntNormalForm` to `FwdRecBridge.lean`;
  delete `Bridge.step`, `taskRel_nat`, `taskRel_diff`, `ofWalk`, `ofWalk_isTotal`, `hist_isWalk`;
  restate `allRec_of_fwdRec`, `hist_periodic`, `hist_deterministic` against
  `FrameOver.step`/`HFofStepPath`/`TaskFrame.HF.isStepPath`. Add
  `theorem isWalk_iff_isStepPath (F : FrameOver intOrder) (f) : Walk.IsWalk F.step f ↔ IsStepPath F f := Iff.rfl`
  as the one-line bridge between the `Walk` vocabulary and the normal-form vocabulary, and keep
  `Walk` as the digraph-side name (it is deliberately frame-free — see C-14).
- **Effort**: S
- **Depends on**: -

### C-08. `ValidDedekind` names the class that `TaskFrame.IsDedekind` does *not* denote

- **Severity**: Medium
- **Category**: naming
- **Anchors**: `FormalSystem/Semantics/Validity.lean:711` `ValidDedekind := ValidOnFrames TaskFrame.IsComplete`;
  `:765` `ValidDedekindDense := ValidIn .Dedekind`; `FormalSystem/Semantics/FrameProperty.lean:180`
  `TaskFrame.IsDedekind := IsDense ∧ IsComplete`; `FrameClassValidity.lean:133` `.Dedekind ↦ IsDedekind`
- **Description**: `TaskFrame.IsDedekind` is dense-and-complete; `ValidDedekind` is validity over
  the *bare* `IsComplete` class, i.e. `ValidDedekind ≠ ValidOnFrames TaskFrame.IsDedekind`. The
  danger is real and known: `Validity.lean:697-698` opens with "**Read this first: `ValidDedekind`
  is NOT `ValidIn .Dedekind`**" and the mismatch is documented in *four* places
  (`Validity.lean:697`, `:768`, `FrameProperty.lean:150-157`, `FrameClassValidity.lean:47`), with
  a note that the wrong target yields a refutable `soundness_dedekind`. The documentation is
  excellent; the name is still the trap.
- **Impact**: A defence that rests on four docstrings a reader must find. The tree already
  demonstrates that this class of confusion is expensive — the same docstring records that before
  the abbreviation refactor "the wrong target differed from the right one by *one binder*".
- **Recommendation**: Rename `ValidDedekind → ValidComplete`, matching `TaskFrame.IsComplete`
  which it is defined from, and rename `ValidDedekindDense → ValidDedekind` to match
  `TaskFrame.IsDedekind` / `FrameClass.Dedekind`. Every `Is*` / `Valid*` / `FrameClass` triple
  then agrees:

  | class | frame predicate | validity |
  |---|---|---|
  | `.Dense` | `IsDense` | `ValidDense` |
  | `.Discrete` | `IsSuccArchDiscrete` | `ValidDiscrete` |
  | `.Dedekind` | `IsDedekind` | `ValidDedekind` |
  | (no tag) | `IsComplete` | `ValidComplete` |

  Mechanical: `ValidDedekind` and `ValidDedekindDense` are each used in a bounded number of
  `Metalogic/` sites. Do it in one commit with the four docstrings updated; the "Read this first"
  paragraph can then be deleted rather than maintained. If the rename is judged too invasive,
  the fallback is to at least add the missing `of_not` (C-09) so the two APIs are symmetric.
- **Effort**: M
- **Depends on**: -

### C-09. `ValidDedekind` is the only class-restricted predicate missing `.of_not`

- **Severity**: Low
- **Category**: api-ergonomics
- **Anchors**: present — `Validity.lean:405` `valid.of_not`, `:514` `ValidIn.of_not`, `:561`
  `ValidDense.of_not`, `:636` `ValidDiscrete.of_not`, `:787` `ValidDedekindDense.of_not`;
  absent — no `ValidDedekind.of_not` (only `.of_forall` at `:716` and `.apply` at `:725`)
- **Description**: Each class-restricted predicate carries an `of_forall` / `apply` / `of_not`
  triple, which is the countermodel-extraction interface (`of_not` hands back the ∀-shape that
  `push Not` can take apart — `Validity.lean:556-558`). `ValidDedekind` has only two of the three.
- **Impact**: A countermodel over the bare-Complete class has to open the definition by hand.
  Small, but it is an asymmetry a reader will notice and wonder about.
- **Recommendation**: Add the missing theorem, three lines, verbatim in the shape of
  `ValidDedekindDense.of_not` minus the density binder. While there: the six triples are ~120
  lines of near-identical boilerplate; if a fourth class is ever added, consider a
  `macro` generating the triple from the binder telescope. Not worth doing for five.
- **Effort**: S
- **Depends on**: C-08 (do the rename first, then add `of_not` under the final name)

### C-10. The discrete order bundle is the largest un-named hypothesis bundle in the tree

- **Severity**: Medium
- **Category**: abstraction / api-ergonomics
- **Anchors**: `[SuccOrder] [PredOrder] [NoMaxOrder] [NoMinOrder] [IsSuccArchimedean]
  [IsPredArchimedean]` — `IsSuccArchimedean` appears in **38 non-`Boneyard` files**; the biggest
  concentrations are `Metalogic/SoundnessLemmas/FrameClassVariants.lean` (5),
  `Metalogic/StrongCompleteness.lean` (7), `Semantics/DurationClassification.lean` (9),
  `Metalogic/WeakCanonical/IntegerModel/ReynoldsNoGaps.lean` (9),
  `Semantics/Validity.lean` (4), `Semantics/BLValidity.lean` (3). Fragment counts of adjacent
  pairs: `[SuccOrder][PredOrder][NoMaxOrder]` 58, `[NoMinOrder][IsSuccArchimedean]` 48,
  `[SuccOrder][NoMaxOrder]` 51.
- **Description**: `TemporalOrder` named the four-binder duration bundle and removed it from
  ~163 sites. The *discrete* bundle is comparably large and unnamed. It cannot be a structure
  (these are genuine carrier side-conditions, correctly binders per `TaskFrame.lean:200-203`) and
  it cannot be a `TaskFrame → Prop` class (`SuccOrder` is data — `FrameProperty.lean:118-122`).
  But it *can* be named twice over: once as a `variable` block per module, and once as the
  predicate `TaskFrame.IsSuccArchDiscrete`, which already exists and already means exactly this.
- **Impact**: Signature noise, and — since the bundle is written in "dozens of slightly different
  shapes" (`TemporalOrder.lean:35`, describing the problem it solved for the *other* bundle) —
  a real risk that two supposedly-matching binder lists differ. `TaskFrame.lean:838-842` already
  documents the subsumption relation informally ("the repo's standard discrete binder bundle …
  therefore subsumes both hypotheses"); nothing checks it.
- **Recommendation**: Two cheap steps, no refactor:
  1. In `Semantics/DurationClassification.lean` add the *audit* lemmas that pin the bundle's
     internal implications as machine-checked facts rather than docstring prose, e.g.
     `example (D : TemporalOrder) [SuccOrder ↑D] [NoMaxOrder ↑D] : Nonempty (SuccOrder ↑D) := …`
     and the recorded "`[AddCommGroup][LinearOrder][IsOrderedAddMonoid][Nontrivial]` already
     implies `NoMaxOrder` by instance search" claim from `TaskFrame.lean:836` — currently prose,
     provable as a one-line `example`. `noMaxOrder_of_duration` (`DurationFrames.lean:78`) is
     already the lemma form; promote an `example` next to it.
  2. Introduce `abbrev TaskFrame.SuccArchDiscrete` ... no — that exists as
     `IsSuccArchDiscrete`. Instead, add the missing bridge lemma
     `theorem isSuccArchDiscrete_of_instances (F : TaskFrame) [SuccOrder F.Duration]
     [PredOrder F.Duration] [IsSuccArchimedean F.Duration] [IsPredArchimedean F.Duration] :
     F.IsSuccArchDiscrete` and its converse-shaped eliminator, so a site holding the binder
     bundle can hand it to the `Sat`-indexed layer in one step rather than through
     `ValidDiscrete.of_forall`'s `@`-application dance.
- **Effort**: S
- **Depends on**: -

### C-11. Frame constants are scattered across five homes with no index

- **Severity**: Medium
- **Category**: organization
- **Anchors**: `Semantics/TaskFrame.lean:1316,1379,1449` (trivial/static/nat);
  `Examples/TemporalStructures.lean:78,123,225,331,382` (intTime/intNat/intBool/genericTime/genericNat);
  `Semantics/Correspondence/DurationFrames.lean:122,210` (translation/permissive);
  `Semantics/IntNormalForm.lean:518` (flip); `Metalogic/Independence/ClockFrame.lean:178` (clock);
  plus flow frames in `Metalogic/Algebraic/FlowFrame.lean`,
  `Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean:453,767`,
  `Metalogic/Decidability/Verified/Bridge/RegionFrame.lean`
- **Description**: Fourteen concrete frames in nine files, three of which (`Examples/`,
  `Metalogic/Algebraic/`, `Metalogic/Decidability/`) a reader of `Semantics/` would not think to
  search. `Semantics/README.md` does not list any of them. There is no answer to "which frame
  should I reach for as a countermodel?"
- **Impact**: New countermodels get built from scratch rather than reused — which is visibly what
  happened with `permissiveFrame` (a third copy of `natFrame`) and `translationFrame` (a second
  copy of `clockFrame`'s deterministic argument).
- **Recommendation**: After C-01 and C-03 land, create `Semantics/Frames/Standard.lean`
  importing `TaskFrame.lean`, holding: the four relation-class constants at
  `(D : TemporalOrder)` (`trivialFrame`, `staticFrame`, `permissiveFrame`, `translationFrame`),
  each with a `@[simp] *_taskRel` lemma and the total-history/model/atom triple (C-12); and a
  module docstring table naming which class each belongs to and which axioms come from which
  helper. Re-export from `Semantics.lean`. Then `Examples/TemporalStructures.lean` becomes
  `abbrev`s at `intOrder`, `DurationFrames.lean` keeps only the (T1) theorems and the
  order-theoretic glue, and `ClockFrame.lean` keeps only the `ℚ ⧸ ℤ`-specific content
  (`clockRel_limit` genuinely is bespoke — `ClockFrame.lean:117-120` explains why
  `limit_of_shift` cannot apply, and that reasoning is right).
- **Effort**: M
- **Depends on**: C-01, C-03

### C-12. Six copies of the "total history over the whole line" boilerplate

- **Severity**: Medium
- **Category**: duplication / api-ergonomics
- **Anchors**: `Correspondence/DurationFrames.lean:174` `translationHist`, `:257` `permissiveHist`;
  `Independence/ClockFrame.lean:227` `clockHistory`; `Correspondence/FwdRecBridge.lean:95`
  `ofWalk`; `IntNormalForm.lean:310` `HFofStepPath`; `Metalogic/DiscreteNonCompactness.lean:149`
  `zHistory`. Each repeats `domain := fun _ => True`, `nonempty_domain := ⟨0, trivial⟩`,
  `convex := fun _ _ _ _ _ _ _ => trivial`, plus a companion `*_isTotal := fun _ => trivial`.
- **Description**: Constructing a total world history from a plain function `f : F.Duration →
  F.WorldState` requires discharging four fields, three of which are always the same three terms.
  Only `respects_task` carries content.
- **Impact**: ~40 lines, and each site also needs its own `*_isTotal` lemma and its own
  `τ.val = …` bridge, which is what generates the `rw [show … from rfl]` idiom in C-05.
- **Recommendation**: One smart constructor in `Semantics/WorldHistory.lean`:

  ```lean
  /-- A total world history from a bare state function, given only the task-respect obligation. -/
  def WorldHistory.ofTotal (f : F.Duration → F.WorldState)
      (h : ∀ s t, F.TaskRel (f s) (t - s) (f t)) : WorldHistory F where
    domain := fun _ => True
    nonempty_domain := ⟨0, trivial⟩
    states := fun t _ => f t
    respects_task := fun s t _ _ => h s t
    convex := fun _ _ _ _ _ _ _ => trivial

  theorem WorldHistory.ofTotal_isTotal (f) (h) : (WorldHistory.ofTotal f h).IsTotal := fun _ => trivial

  /-- The bundled form, which is what `ValidOn` quantifies over. -/
  def TaskFrame.HF.ofTotal (f) (h) : F.HF := ⟨WorldHistory.ofTotal f h, WorldHistory.ofTotal_isTotal f h⟩

  @[simp] theorem TaskFrame.HF.ofTotal_states (f) (h) (t) :
      (TaskFrame.HF.ofTotal f h).val.states t trivial = f t := rfl
  ```

  All six sites become one line plus their genuine `respects_task` argument, and the
  `@[simp]` states lemma removes the `τ.val` bridge everywhere.
- **Effort**: S
- **Depends on**: -

### C-13. `WorldHistory.lean`'s "Order Reversal Lemmas" are dead Mathlib duplicates that shadow Mathlib names

- **Severity**: Medium
- **Category**: duplication
- **Anchors**: `FormalSystem/Semantics/WorldHistory.lean:382-444` — `neg_lt_neg_iff` (:399),
  `neg_le_neg_iff` (:416), `neg_neg_eq` (:430), `neg_injective` (:436)
- **Description**: All four are restatements of Mathlib lemmas (`neg_lt_neg_iff`, `neg_le_neg_iff`,
  `neg_neg`, `neg_inj`), proved by `simp` and `neg_lt_neg`. Two of them — `neg_lt_neg_iff` and
  `neg_le_neg_iff` — carry the *same name* as the Mathlib lemma, so inside
  `namespace FormalSystem.Semantics` the local one wins. Mathlib's is
  `neg_lt_neg_iff : -a < -b ↔ b < a`; the local one is `s < t ↔ -t < -s`. They are equivalent but
  differently oriented, so a `rw [neg_lt_neg_iff]` inside the namespace rewrites the wrong way
  round from what a Mathlib-fluent reader expects.
- **Impact**: A grep across all of `FormalSystem/` (excluding `Boneyard/`) finds **zero call
  sites** for any of the four outside their own declarations. 63 lines of dead code carrying a
  live shadowing hazard, sitting in the middle of the history module with a section header
  ("This is crucial for proving temporal duality soundness") that no longer describes anything.
- **Recommendation**: Delete `WorldHistory.lean:382-444` outright. If the duality-soundness
  narrative is worth keeping, move the one-sentence version into the module docstring pointing at
  Mathlib's `neg_lt_neg_iff`.
- **Effort**: S
- **Depends on**: -

### C-14. `Walk`/`MinCyc` is *not* a Mathlib reimplementation and should stay — but `per_period` is `Function.Periodic`

- **Severity**: Low
- **Category**: math-insight
- **Anchors**: `Semantics/Correspondence/FwdRecPeriodicity.lean:70` `IsWalk`, `:74` `AllRec`,
  `:89` `per`, `:105` `per_period`, `:113` `MinCyc`, `:231` `succ_unique`, `:326` `periodic`
- **Description**: Checked against the candidates in the brief. `SimpleGraph.Walk` and
  `Quiver.Path` are *finite* paths in a graph/quiver; `Relation.ReflTransGen` is finite
  reachability. This module's object is a **bi-infinite** walk `σ : ℤ → W` in an arbitrary
  digraph, which Mathlib does not have. `Function.IsPeriodicPt` / `Function.minimalPeriod` are
  about iterates of a *function*, and the whole point of `succ_unique` (`:231`, the module's
  hardest 60 lines) is to *derive* that the relation is functional along walks — so the
  function-orbit machinery is unavailable at the point it would be needed. The recommendation is
  therefore: **do not replace this**. It is genuine, non-trivial combinatorics and the
  `exists_minCyc → minCyc_mem → succ_unique → det → periodic` chain is well-structured.
- **Impact**: n/a — this is a negative finding, recorded so the question is not reopened.
- **Recommendation**: Two small Mathlib hookups are available and worth taking:
  (a) `per_period (σ) (m n) : per σ m (n + m) = per σ m n` (`:105`) *is*
  `Function.Periodic (per σ m) m`; stating it that way gives `Periodic.int_mul`,
  `Periodic.sub_eq` and friends free, and `MinCyc.walk_add_mul` (`:145`, a 13-line
  `Int.induction_on`) is then `Function.Periodic.int_mul` (or close to it — check the exact
  Mathlib name before committing).
  (b) `Walk.periodic`'s conclusion `∃ π, 0 < π ∧ ∀ n, σ (n + π) = σ n` is
  `∃ π > 0, Function.Periodic σ π`; stating it that way lets
  `density_of_hist_periodic` (`:424`) and `Bridge.hist_periodic`
  (`FwdRecBridge.lean:130`) speak the same vocabulary as `LoopingDuration.truthAt_add_period`.
  Also record in the module docstring that the Mathlib survey was done and came back negative —
  the module currently gives no signal either way, and a future reader will re-run it.
- **Effort**: S
- **Depends on**: -

### C-15. Four copies of "a least positive element yields immediate successors"

- **Severity**: Medium
- **Category**: duplication
- **Anchors**:
  - `Correspondence/DurationFrames.lean:96-111` `succOrder_of_isLeast_pos` (the `←` branch:
    `hmem : 0 < b - a`, `hle := hp.2 hmem`, `le_sub_iff_add_le.mp`, `add_comm`)
  - `Correspondence/DurationFrames.lean:404-412` `hcov`, inside `validOn_dn_iff_denselyOrdered` —
    the same four steps, inlined
  - `Independence/LexIntWitness.lean:97-105` `lexInt_isLeast_succ` — the same four steps
  - `Independence/LexIntWitness.lean:107-117` `lexInt_isGreatest_pred` — the dual, same four steps
- **Description**: In an ordered abelian group, `IsLeast {x | 0 < x} p` implies
  `∀ x, IsLeast {z | x < z} (x + p)` by translation. That two-line argument is written out four
  times in the territory, each time inline in a larger proof.
- **Impact**: ~35 lines, and — more importantly — `LexIntWitness.lean` does not use
  `succOrder_of_isLeast_pos` even though it holds `lexInt_isLeast_pos`
  (`LexIntWitness.lean:81`), which is exactly that lemma's input. The two modules are solving
  the same problem in ignorance of each other.
- **Recommendation**: Add to `Semantics/DurationClassification.lean` (which already owns
  `isLeast_pos_succ_zero` and `duration_dense_or_least_pos`, so this is the natural home):

  ```lean
  /-- A least strictly positive element makes every point's immediate successor `x + p`. -/
  theorem isLeast_succ_of_isLeast_pos {D : Type} [AddCommGroup D] [LinearOrder D]
      [IsOrderedAddMonoid D] {p : D} (hp : IsLeast {x : D | 0 < x} p) (x : D) :
      IsLeast {z : D | x < z} (x + p)

  /-- The predecessor mirror. -/
  theorem isGreatest_pred_of_isLeast_pos … (x : D) : IsGreatest {z : D | z < x} (x - p)
  ```

  Then `succOrder_of_isLeast_pos` is `SuccOrder.ofSuccLeIff (· + p)` over it,
  `hcov` is one application, and `lexInt_isLeast_succ`/`lexInt_isGreatest_pred` are one
  application each of it at `lexInt_isLeast_pos`. Note this also connects
  `LexIntWitness.lean` to `DurationFrames.lean`'s `succOrder_of_isLeast_pos`, which it should
  arguably be using to get its `SuccOrder (ℤ ×ₗ ℤ)` instance for free.
- **Effort**: S
- **Depends on**: -

### C-16. `LexCarrier.lean` (`ℚ ×ₗ ℤ`) and `LexIntWitness.lean` (`ℤ ×ₗ ℤ`) develop the same lexicographic apparatus twice

- **Severity**: Medium
- **Category**: duplication / abstraction
- **Anchors**:
  - `Semantics/LexCarrier.lean:59-64` (four ambient `example`s), `:71` `lexSucc`, `:73`
    `lexSucc_le_iff`, `:78` `instance SuccOrder (ℚ ×ₗ ℤ)`, `:85` `lexPred`, `:87`
    `le_lexPred_iff`, `:97` `instance PredOrder (ℚ ×ₗ ℤ)`, `:112`/`:132` the two
    non-Archimedean `example`s
  - `Metalogic/Independence/LexIntWitness.lean:72-78` (the *same* four ambient `example`s, plus
    the same `TemporalOrder.of` example), `:81` `lexInt_isLeast_pos`, `:97`
    `lexInt_isLeast_succ`, `:107` `lexInt_isGreatest_pred`, `:123` `lexInt_not_archimedean`
- **Description**: Both modules build, for `α ×ₗ ℤ`, the same three things: the four ambient
  instance `example`s (character-identical apart from `ℚ`/`ℤ`), the immediate-successor and
  immediate-predecessor structure, and the failure of Archimedes via "the iterates never move the
  first coordinate". The two differ only in the first factor, and neither is stated generically.
  `LexCarrier` reaches the `SuccOrder` through `SuccOrder.ofSuccLeIff`; `LexIntWitness` reaches
  the same fact through `IsLeast`, and thereby duplicates C-15's argument as well.
- **Impact**: ~140 lines across two modules for one construction. A third lexicographic carrier
  (the `ℤ` ⊕ `nℤ` over `ℤ ×ₗ ℤ` candidate that `FwdRecBridge.lean:41-44` names as future work)
  would be a third copy.
- **Recommendation**: Generalise `LexCarrier.lean` to `α ×ₗ ℤ` for
  `[AddCommGroup α] [LinearOrder α] [IsOrderedAddMonoid α]`:

  ```lean
  namespace LexInt
  variable {α : Type} [AddCommGroup α] [LinearOrder α] [IsOrderedAddMonoid α]
  def succ (p : α ×ₗ ℤ) : α ×ₗ ℤ := toLex ((ofLex p).1, (ofLex p).2 + 1)
  theorem succ_le_iff {a b : α ×ₗ ℤ} : succ a ≤ b ↔ a < b
  instance : SuccOrder (α ×ₗ ℤ) := SuccOrder.ofSuccLeIff succ succ_le_iff
  instance : PredOrder (α ×ₗ ℤ) := …
  theorem isLeast_pos : IsLeast {x : α ×ₗ ℤ | 0 < x} (toLex (0, 1))
  theorem not_archimedean [Nontrivial α] : ¬ Archimedean (α ×ₗ ℤ)   -- needs a positive `α`-element
  end LexInt
  ```

  `ℚ ×ₗ ℤ` and `ℤ ×ₗ ℤ` are then both instances; `LexIntWitness.lean` loses ~70 lines and gains
  the `SuccOrder`/`PredOrder` instances it currently does without. Check `not_archimedean`'s
  hypothesis carefully — `LexCarrier`'s version uses `(1 : ℚ)` and `LexIntWitness`'s uses
  `(1 : ℤ)`; the generic form needs a positive element of `α`, which
  `TaskFrame.exists_pos_of_nontrivial` supplies.
- **Effort**: M
- **Depends on**: C-15

### C-17. `validOn_iff_total` and the truth-level `and`/`always` helpers live in `Correspondence/`, not in their home modules

- **Severity**: Medium
- **Category**: organization
- **Anchors**: `Correspondence/FwdRec.lean:73` `validOn_iff_total`;
  `Correspondence/DurationFrames.lean:298` `truth_and_iff`, `:309` `truth_always_of_forall`,
  `:319` `truth_of_always`; the `DurationFrames.lean:294-296` section header admits it
  ("`Truth.lean` supplies unfolding lemmas for the four tense operators but none for
  `Formula.and` or `Formula.always`, both of which the three biconditionals below consume")
- **Description**: Four general-purpose lemmas about `TaskFrame.ValidOn` and `TruthAt` are
  declared inside the correspondence layer because that is where they were first needed.
  `validOn_iff_total` in particular is the frame-level companion of `Validity.lean`'s
  `ValidOnFrames.of_forall_total` / `.apply_total` (`:481`, `:488`), stated as one `Iff` instead
  of two theorems — strictly the better form, in the wrong module, and in the bare
  `FormalSystem.Semantics` namespace rather than `TaskFrame`.
- **Impact**: A consumer in `Metalogic/` cannot reach `validOn_iff_total` without importing the
  whole correspondence layer; `DedekindNonCompactness.lean:154-157` documents making exactly that
  trade-off for `truth_and_iff` and choosing to duplicate instead (see C-04).
- **Recommendation**: Move `validOn_iff_total` to `Semantics/Validity.lean`, immediately after
  `TaskFrame.ValidOn` (`:254`), renamed `TaskFrame.validOn_iff_total`; consider restating
  `ValidOnFrames.of_forall_total`/`.apply_total` over it. Move the three truth helpers into
  `Semantics/Truth.lean` as `@[simp]` lemmas per C-04.
- **Effort**: S
- **Depends on**: C-04

### C-18. The three (T1) biconditionals do not share the witness-frame pattern they all use

- **Severity**: Medium
- **Category**: proof-elegance
- **Anchors**: `Correspondence/DurationFrames.lean:354` `validOn_dn_iff_denselyOrdered` (65 lines),
  `:419` `validOn_df_iff_isDiscrete` (66 lines), `:485` `validOn_co_iff_isComplete` (78 lines)
- **Description**: Answering Q5 directly: the (T0) refutation *is* isolated cleanly (it is a
  documented header note at `DurationFrames.lean:47-59` plus the `StaticFrame.static_untl_iff_disc`
  machinery it cites, and it is *not* duplicated with `Indicator.lean` — `Indicator.lean` handles
  a disjoint pair of indicator formulas, `X⊤` and `¬X⊤`, against `IsDense`/`IsDiscrete`, whereas
  `DurationFrames.lean` handles DF/DN/CO. There is no overlap.) But the three (T1) proofs are
  **not** written to a common pattern. Each independently:
  1. picks a witness frame and builds `τ : F.toTaskFrame.HF` by hand with `set … with h`;
  2. threads `rw [show τ.val = … from rfl, …_atom]` at 3-4 places (C-05);
  3. runs a bespoke order argument.

  Two of the three (`df`, `co`) use the *same* witness frame with the *same* pattern — realise a
  set `A ⊆ ↑D` as the truth-set of an atom along `translationHist` — and that step is what the
  (⇒) direction is entirely about in both. It is never named.
- **Impact**: ~90 lines of the 209 in these three proofs are frame/model/history plumbing rather
  than mathematics. The mathematics — density interpolates; discreteness gives a least strict
  upper bound; completeness gives a supremum — is each 8-15 lines and is well explained in the
  docstrings. The plumbing obscures it.
- **Recommendation**: Name the realisation step once, in `DurationFrames.lean` beside
  `translationModel_atom`:

  ```lean
  /-- The translation frame realises an arbitrary `A ⊆ ↑D` as the truth-set of an atom
      along its reference history: `⊨` at `t` iff `t ∈ A`. -/
  theorem translation_realizes (D : TemporalOrder) (A : Set ↑D) :
      ∃ (M : TaskModel (translationFrame D).toTaskFrame) (τ : (translationFrame D).toTaskFrame.HF),
        ∀ t : ↑D, TruthAt M τ.val t (Formula.atom corrAtom) ↔ t ∈ A
  ```

  plus the `@[simp]` lemmas from C-05 and the `HF.ofTotal` constructor from C-12. Each (⇒)
  direction then opens with `obtain ⟨M, τ, hMτ⟩ := translation_realizes D {r | r ≤ x}` and the
  remaining body is the order argument alone. Estimated: 209 → ~110 lines, with the three
  arguments visibly parallel.
- **Effort**: M
- **Depends on**: C-05, C-12

### C-19. `Semantics.lean` does not aggregate two modules under `Semantics/`

- **Severity**: Medium
- **Category**: documentation / organization
- **Anchors**: `FormalSystem/Semantics.lean:7-38` (the import block) vs
  `FormalSystem/Semantics/BLSchemaValidity.lean` and `FormalSystem/Semantics/LexCarrier.lean`
- **Description**: Both files live under `Semantics/` and neither is imported by
  `FormalSystem/Semantics.lean`. They reach the build only through `Metalogic/SpWitness.lean`,
  `Metalogic/BaseLanguageSoundness.lean` and `Metalogic/Z1Countermodel.lean`. So
  `import FormalSystem.Semantics` does *not* give the `Semantics` namespace — a violated
  invariant an aggregator exists to hold.
- **Impact**: `LexCarrier`'s `SuccOrder (ℚ ×ₗ ℤ)` / `PredOrder (ℚ ×ₗ ℤ)` instances are visible
  only in files that transitively import `Z1Countermodel`. That is very likely why
  `LexIntWitness.lean` re-derives the same structure for `ℤ ×ₗ ℤ` (C-16) rather than
  generalising `LexCarrier`'s.
- **Recommendation**: Add both imports to `Semantics.lean` and both docstring entries to its
  `## Submodules` list. Check the build stays green (neither creates a cycle: `LexCarrier`
  imports only `TemporalOrder` + Mathlib; `BLSchemaValidity` imports `BLValidity`, already in the
  aggregator).
- **Effort**: S
- **Depends on**: -

### C-20. `Semantics/README.md` omits the three most architecturally central modules and cites stale names

- **Severity**: Medium
- **Category**: documentation
- **Anchors**: `FormalSystem/Semantics/README.md` — the Contents table lists 19 entries but
  **omits `TemporalOrder.lean`, `FrameProperty.lean`, `FrameClassValidity.lean`**; "Key
  Definitions" names `truth_at` and `valid` where the declarations are `TruthAt`
  (`Truth.lean:163`) and `valid` (`Validity.lean:377`); "Last verified: 2026-05-29" against
  `Correspondence/README.md`'s "2026-09-01"
- **Description**: The three missing files are exactly the ones `Semantics.lean`'s own docstring
  leads with (`Semantics.lean:44-70`) — the reified temporal order, the frame-property predicates,
  and the single `Semantics → ProofSystem` seam. A reader who starts from the README will not
  learn that `TemporalOrder` exists.
- **Impact**: The README is the first thing a new contributor or a doc-gen consumer reads, and it
  describes a version of the tree from before the fibration landed. `Correspondence/README.md`, by
  contrast, is excellent and current — the contrast makes the gap more conspicuous.
- **Recommendation**: Add the three rows; refresh "Key Definitions" to `TaskFrame`/`FrameOver`/
  `TemporalOrder`/`TruthAt`/`TaskFrame.ValidOn`/`ValidIn`; add a short "The frame fibration"
  section pointing at `TaskFrame.lean`'s header table, matching the "The ℤ-frame normal form"
  section already there; bump the verification date. Also update `Semantics.lean:216-230`'s
  "Usage" block, which still shows `#check TruthAt M τ t ht (Formula.box …)` with an `ht`
  argument that `TruthAt` no longer takes (`Truth.lean:163`).
- **Effort**: S
- **Depends on**: C-19

### C-21. `Metalogic/Independence.lean`'s docstring contradicts its own contents; two of its six modules are definability results

- **Severity**: Medium
- **Category**: documentation / organization
- **Anchors**: `FormalSystem/Metalogic/Independence.lean:17-19` ("The **one result** carried here
  is that the paper's `CO` principle does not derive Reynolds' `Axiom.prior_U_gap`") vs `:24-38`
  (a six-module contents list); `Independence/RationalWitness.lean:181`
  `sat_dedekind_ssubset_mod_axiomSet`; `Independence/LexIntWitness.lean:242`
  `sat_discrete_ssubset_mod_axiomSet`; `Independence/README.md` repeats the same "The result
  carried here is…" singular framing
- **Description**: Answering Q8: the six modules *are* consistently structured internally — each
  builds a frame, proves a truth-invariance lemma, discharges the axioms, and refutes the target,
  and the four-step method is named in both the aggregator and the README. Naming is consistent
  (`*Frame` for frames, `*_iff` for characterisations, `sat_*_ssubset_mod_axiomSet` for the two
  sandwiches). But two of the six results are not axiom-independence at all: `RationalWitness` and
  `LexIntWitness` prove that `Sat .Dedekind ⊊ Mod (AxiomSet .Dedekind)` and
  `Sat .Discrete ⊊ Mod (AxiomSet .Discrete)` — i.e. that those two frame classes are **not
  Galois-closed**. That is definability, the exact complement of `Indicator.lean`'s
  `galoisClosed_sat_dense` / `galoisClosed_isDiscrete`, and
  `Correspondence/README.md` already claims them as part of the correspondence story ("the two
  non-closure witnesses").
- **Impact**: The aggregator docstring is simply wrong about how many results the directory
  carries. And the two non-closure witnesses are one `import` away from the closure results they
  complete, in a different top-level directory, so nothing puts the four-part picture
  (dense closed / paper-discrete closed / `Sat .Discrete` not closed / `Sat .Dedekind` not
  closed) in one place.
- **Recommendation**: Two changes, the first mandatory and the second a judgement call:
  1. Fix `Independence.lean:17-19` and `Independence/README.md`'s opening paragraph to describe
     all three result families (the `CO`/`prior_U_gap` independence, the two Galois non-closure
     sandwiches, and the reusable `LoopingDuration`/`StaticFrame` infrastructure).
  2. Consider moving `RationalWitness.lean` and `LexIntWitness.lean` to
     `Semantics/Correspondence/NonClosure.lean` (or a `Correspondence/Witnesses/` pair), where
     they sit beside `Indicator.lean`. The blocker is that both import
     `Metalogic.Soundness` to get the axiom-validity half; check whether they actually need it
     or whether `Independence/StaticFrame.lean`'s constant-truth calculus (which is where the
     real work is, and which is `Semantics`-only) suffices. If soundness is genuinely needed, do
     not move them — instead add a "See also" block in `Correspondence/README.md`'s Key Results
     (it already has one) and a reciprocal pointer from `Indicator.lean`'s header, which already
     names `LexIntWitness` at `:38-40`. That pointer discipline is most of the value.
- **Effort**: S (docs) / M (relocation)
- **Depends on**: -

### C-22. `TaskFrame.lean` carries five overlapping regression-`example` sections

- **Severity**: Low
- **Category**: organization
- **Anchors**: `TaskFrame.lean:1773` `BridgeChecks`, `:1799` `TotalSpaceIdentity`, `:1829`
  `BundledDefinitionalContent`, `:1861` `DefinitionalContent`, `:1894` `FibreDefinitionalContent`
  — ~150 lines total. Overlaps: `:1865` and `:1898` are the same statement
  (`example (F : FrameOver _) : TaskFrame.Serial F.TaskRel := F.serial`) under two different
  section binders; likewise `:1867`/`:1899`, `:1869`/`:1900`, `:1871`/`:1901`, `:1873`/`:1903`;
  `:1779`/`:1804` and `:1780`/`:1803` are also duplicates
- **Description**: The regression-`example` discipline is *right* — it is what makes the
  "fields are definitionally the bare-relation predicates" invariant an acceptance test rather
  than a docstring claim, and `TaskFrame.lean:369-373` explains this well. But it accreted into
  five sections with substantial overlap and no stated division of labour: three of the five
  (`BundledDefinitionalContent`, `DefinitionalContent`, `FibreDefinitionalContent`) test the
  same six facts at the total space, at the fibre with an ambient-carrier `variable` block, and
  at the fibre with a `TemporalOrder` binder.
- **Impact**: ~50 redundant lines and no way for a reader to tell which section to add a new
  check to. Low severity: `example`s are cheap and harmless.
- **Recommendation**: Merge into two sections with explicit charters —
  `## Fibration identities` (the `rfl` round-trips: current `TotalSpaceIdentity` +
  the overlapping half of `BridgeChecks`) and `## Axiom-field definitional content` (the
  `F.serial : Serial F.TaskRel` family, stated once at the fibre and once at the total space,
  since the delegating accessors are what is being tested). Add a one-line header to each saying
  what a failure there means, following the model of `TemporalOrder.lean:141-146`, which does
  this well.
- **Effort**: S
- **Depends on**: -

### C-23. Naming inconsistency between the two history layers' shift APIs

- **Severity**: Low
- **Category**: naming
- **Anchors**: `WorldHistory.lean:295` `time_shift_domain_iff`, `:302` `time_shift_inverse_domain`,
  `:335` `time_shift_time_shift_states`, `:347` `time_shift_congr`, `:355`
  `time_shift_zero_domain_iff`, `:362` `time_shift_time_shift_neg_domain_iff`, `:374`
  `time_shift_time_shift_neg_states` (snake) vs `PartialHistoryOrder.lean:135` `timeShift_domain`,
  `:139` `timeShift_mono`, `:144` `timeShift_timeShift_neg_domain_iff`, `:151`
  `timeShift_timeShift_neg_states` (camel); the definitions are `WorldHistory.timeShift`
  (`:262`) and `PartialHistory.timeShift` (`PartialHistoryOrder.lean:121`), both camel
- **Description**: Two parallel APIs over the same operation, named to two different conventions.
  Mathlib's convention (and this repo's own, at `TaskFrame.HF.timeShift_val`,
  `WorldHistory.lean:524`) is that a lemma about `foo` is named `foo_*`, so `timeShift_domain` is
  right and `time_shift_domain_iff` is wrong. Also note `states_eq_of_time_eq` is declared twice,
  at `WorldHistory.lean:323` and `PartialHistoryOrder.lean:108`, for the two layers — that one is
  legitimate (different types) but reads as a duplicate at a glance.
- **Impact**: Autocomplete and search miss half the API. Minor but pervasive: 7 declarations.
- **Recommendation**: Rename the seven `WorldHistory.time_shift_*` to `timeShift_*`. Mechanical;
  check call sites in `Truth.lean` (which is the main consumer, e.g.
  `time_shift_preserves_truth` at `:450` — that one should become `timeShift_preserves_truth`
  too, or better `truthAt_timeShift` to match the `truthAt_*` family in C-02).
- **Effort**: S
- **Depends on**: -

### C-24. `galoisClosed_of_indicator` takes two arguments that both call sites derive from one `Iff`

- **Severity**: Low
- **Category**: api-ergonomics
- **Anchors**: `Correspondence/Galois.lean:158` `galoisClosed_of_indicator`;
  `Correspondence/Indicator.lean:126-129` `galoisClosed_sat_dense`, `:145-148`
  `galoisClosed_isDiscrete` — both of the form
  `galoisClosed_of_indicator φ (fun _ hF => (h _).mpr hF) (fun _ h => (h _).mp h)`
- **Description**: The indicator mechanism is correctly factored exactly once (this is the
  module's best design decision, and its header says so). But its signature splits what every
  caller has as a single biconditional `∀ F, F.ValidOn φ ↔ F ∈ K` into two arguments, so both
  call sites spell out the `.mp`/`.mpr` split.
- **Impact**: Trivial, but it is the difference between a two-line and a one-line corollary, and
  the iff-form is the shape a *third* indicator would naturally arrive in.
- **Recommendation**: Add the iff-form as the primary entry point, keeping the current one:

  ```lean
  theorem galoisClosed_of_indicator_iff {K : Set TaskFrame} (φ : Formula)
      (h : ∀ F : TaskFrame, F.ValidOn φ ↔ F ∈ K) : GaloisClosed K :=
    galoisClosed_of_indicator φ (fun F hF => (h F).mpr hF) (fun F hv => (h F).mp hv)
  ```

  Both corollaries then read `galoisClosed_of_indicator_iff _ validOn_neg_nextTop_iff` /
  `… validOn_nextTop_iff_isDiscrete`, which is also a nicer statement of what an indicator *is*.
- **Effort**: S
- **Depends on**: -

### C-25. `corrAtom` is declared `private` in one module and inlined as `Atom.mk "p" none` in another

- **Severity**: Low
- **Category**: duplication
- **Anchors**: `Correspondence/DurationFrames.lean:352` `private def corrAtom : Atom := ⟨"p", none⟩`;
  `Correspondence/FwdRec.lean:104,113` `Atom.mk "p" none` inlined twice inside
  `validOn_atomic_density_iff_fwdRec`
- **Description**: The same "any atom will do" placeholder, once named and once inlined, in two
  files of the same directory.
- **Impact**: Negligible in isolation; noted because it is the kind of thing that multiplies —
  `CoNotPriorU.lean` and `DiscreteNonCompactness.lean` each take an `(a : Atom)` parameter
  instead, which is the better choice where the atom is user-visible.
- **Recommendation**: Promote `corrAtom` to a non-`private` `Correspondence`-level definition
  (or, better, drop it: both uses could take the atom as a parameter, matching
  `validOn_atomic_density_iff_fwdRec`'s own `∀ p : Atom` binder). If kept, document that the
  choice of atom is immaterial and why.
- **Effort**: S
- **Depends on**: -

### C-26. Tactic-idiom split: `push Not` (544) vs `push_neg` (74)

- **Severity**: Low
- **Category**: naming
- **Anchors**: e.g. `TaskFrame.lean:915` `push Not at hne`; `BLTruth.lean:167,175,183`
  `push Not at hc`; against 74 `push_neg` sites elsewhere in `FormalSystem/`
- **Description**: The tree uses both spellings of the same tactic. `push Not` dominates 7:1, so
  `push_neg` is the outlier, but a reader grepping for negation-pushing will find only half the
  sites. No correctness issue.
- **Recommendation**: Pick one (the majority `push Not`, which is the current Mathlib direction)
  and normalise in a mechanical pass, or record the convention in `.claude/rules/lean4.md`'s
  "Common Tactics" section, which currently lists neither.
- **Effort**: S
- **Depends on**: -

---

## 5. Proposed core utilities

Ranked by (lines removed + future leverage) / risk.

### U1. `TaskFrame.spherical_of_fib_subsingleton` — Helper D, the deterministic class

```lean
-- home: FormalSystem/Semantics/TaskFrame.lean, after "### Helper C" (:1237-1295)
omit [IsOrderedAddMonoid D] in
theorem sInter_nonempty_of_directed_subsingleton {W : Type} {S : Set (Set W)}
    (hdir : DirectedFamily S) (hne : ∀ s ∈ S, s.Nonempty)
    (hsub : ∀ s ∈ S, s.Subsingleton) : (⋂₀ S).Nonempty

omit [IsOrderedAddMonoid D] in
theorem spherical_of_fib_subsingleton {W : Type} {R : W → D → W → Prop}
    (h : ∀ w x, (Fib R w x).Subsingleton) : Spherical R

omit [IsOrderedAddMonoid D] in
theorem fib_subsingleton_of_functional {W : Type} {f : W → D → W} {R : W → D → W → Prop}
    (hR : ∀ w x u, R w x u ↔ u = f w x) : ∀ w x, (Fib R w x).Subsingleton
```

Discharges **C-01**. Seven sites collapse to one line each; deletes the competing
`Algebraic.sInter_nonempty_of_directed_subsingleton`. Completes the kit's fourth relation class,
which `limit_of_shift` already half-serves.

### U2. `truthAt_of_truthIso` — the single truth-transport lemma

```lean
-- home: FormalSystem/Semantics/Truth.lean, after `time_shift_preserves_truth`
structure TruthIso {F F' : TaskFrame} (M : TaskModel F) (M' : TaskModel F') where
  dur  : F.Duration ≃o F'.Duration
  hist : F.HF ≃ F'.HF
  atom : ∀ (τ : F.HF) (t : F.Duration) (p : Atom),
           M.valuation (τ.val.states t (τ.property t)) p ↔
           M'.valuation ((hist τ).val.states (dur t) ((hist τ).property (dur t))) p

theorem truthAt_of_truthIso (I : TruthIso M M') (φ : Formula) (τ : F.HF) (t : F.Duration) :
    TruthAt M τ.val t φ ↔ TruthAt M' (I.hist τ).val (I.dur t) φ

theorem truthAt_of_truthAntiIso (I : TruthAntiIso M M') (φ : Formula) … :
    TruthAt M τ.val t φ ↔ TruthAt M' (I.hist τ).val (I.dur t) φ.swapTemporal
```

Discharges **C-02**. ~370 lines of five duplicated inductions become one ~90-line proof plus five
short instantiations. Highest total line saving in the territory; also the highest risk, so land
the three shift/period cases first.

### U3. `Truth.and_iff` / `or_iff` / `neg_iff` / `top_true` / `always_iff`

```lean
-- home: FormalSystem/Semantics/Truth.lean, mirroring BLTruth.lean:138-195 exactly
@[simp] theorem Truth.and_iff (φ ψ : Formula) :
    TruthAt M τ t (φ.and ψ) ↔ (TruthAt M τ t φ ∧ TruthAt M τ t ψ)
@[simp] theorem Truth.always_iff (φ : Formula) :
    TruthAt M τ t φ.always ↔ ∀ s, TruthAt M τ s φ    -- the collected form; see below
```

Discharges **C-04**, most of **C-17**. Deletes four private copies. Note `BLTruth.always_iff`
states the three-conjunct form; a `∀ s` collected form is more useful here since
`DurationFrames.truth_of_always` (`:319`) does exactly that trichotomy by hand — supply both.

### U4. `WorldHistory.ofTotal` / `TaskFrame.HF.ofTotal` — the total-history smart constructor

```lean
-- home: FormalSystem/Semantics/WorldHistory.lean, in the "Totality and H_F" section (:445)
def WorldHistory.ofTotal (f : F.Duration → F.WorldState)
    (h : ∀ s t, F.TaskRel (f s) (t - s) (f t)) : WorldHistory F
theorem WorldHistory.ofTotal_isTotal …
def TaskFrame.HF.ofTotal (f) (h) : F.HF
@[simp] theorem TaskFrame.HF.ofTotal_states (f) (h) (t) :
    (TaskFrame.HF.ofTotal f h).val.states t trivial = f t := rfl
```

Discharges **C-12**, enables **C-05** and **C-18**. Six sites collapse; the `@[simp]` states
lemma is what removes the `rw [show τ.val = … from rfl]` idiom everywhere.

### U5. Helper B completion: `nullity_identity_of_permissive`, `converse_of_permissive`, `forward_comp_of_permissive`, `comp_of_permissive`

```lean
-- home: FormalSystem/Semantics/TaskFrame.lean, "### Helper B" (:1129)
```

Discharges **C-03**; unblocks **C-11** and the `TemporalOrder` migration of the frame constants.
Three permissive frames go from ~30 inline lines each to seven one-line field discharges, and
`natFrame`/`genericNatFrame` merge.

### U6. `Th`/`Mod`/`GaloisClosed` over `Mathlib.Order.Concept`

```lean
-- home: FormalSystem/Semantics/Correspondence/Galois.lean
def validOnRel (F : TaskFrame) (φ : Formula) : Prop := F.ValidOn φ
abbrev Th (K : Set TaskFrame) : Set Formula := upperPolar validOnRel K
abbrev Mod (S : Set Formula) : Set TaskFrame := lowerPolar validOnRel S
abbrev GaloisClosed (K : Set TaskFrame) : Prop := Order.IsExtent validOnRel K
```

Discharges **C-06**. ~45 lines of theorem bodies become re-exports; gains
`Order.IsExtent.iInter`, `.univ`, `upperPolar_empty`, and the `Concept` complete lattice. Verify
universe behaviour at `Set TaskFrame : Type 1` before committing.

### U7. `isLeast_succ_of_isLeast_pos` / `isGreatest_pred_of_isLeast_pos`

```lean
-- home: FormalSystem/Semantics/DurationClassification.lean, beside isLeast_pos_succ_zero (:194)
theorem isLeast_succ_of_isLeast_pos {p : D} (hp : IsLeast {x : D | 0 < x} p) (x : D) :
    IsLeast {z : D | x < z} (x + p)
theorem isGreatest_pred_of_isLeast_pos {p : D} (hp : IsLeast {x : D | 0 < x} p) (x : D) :
    IsGreatest {z : D | z < x} (x - p)
```

Discharges **C-15**, unblocks **C-16**. Four inline copies collapse; connects
`LexIntWitness.lean` to `DurationFrames.succOrder_of_isLeast_pos`, which it currently duplicates.

### U8. `LexInt` namespace: `SuccOrder`/`PredOrder`/`isLeast_pos`/`not_archimedean` at `α ×ₗ ℤ`

```lean
-- home: FormalSystem/Semantics/LexCarrier.lean, generalised from ℚ ×ₗ ℤ
variable {α : Type} [AddCommGroup α] [LinearOrder α] [IsOrderedAddMonoid α]
instance : SuccOrder (α ×ₗ ℤ) ; instance : PredOrder (α ×ₗ ℤ)
theorem LexInt.isLeast_pos : IsLeast {x : α ×ₗ ℤ | 0 < x} (toLex (0, 1))
theorem LexInt.not_archimedean [Nontrivial α] : ¬ Archimedean (α ×ₗ ℤ)
```

Discharges **C-16**. ~70 lines out of `LexIntWitness.lean`; makes the third lexicographic carrier
(the `ℤ ⊕ nℤ` candidate `FwdRecBridge.lean:41` names as open work) free.

---

## 6. Metrics

| Measure | Value |
|---|---|
| Files reviewed | 28 (territory), plus targeted reads in 9 adjacent `Metalogic/` files |
| Lines in territory | 9,516 |
| Declarations (`theorem`/`lemma`/`def`/`instance`/`structure`/`abbrev`) | 427 |
| Docstrings (`/--`) | 392 (**92% coverage** — the highest-quality dimension of this territory) |
| `@[simp]` attributes | 17 (**4% of declarations**) |
| `sorry` / `admit` | **0** |
| `maxHeartbeats` / `maxRecDepth` / `native_decide` overrides | **0** (the two `synthInstance.maxHeartbeats 2000` at `TemporalOrder.lean:178,181` are budget *reductions* used as regression guards) |
| `decide` uses | 1 (`FrameClassValidity.lean:117`, the 7 absurd cases of `Sat.anti`) |
| Declarations with proof body > 60 lines | 7 |
| Findings | 26 (High 5, Medium 13, Low 8) |
| Duplicated-argument copies found | deterministic-*Spherical* ×7; `induction φ` truth transport ×5; `truth_and_iff` ×4; "least positive ⟹ successor" ×4; permissive-frame field bodies ×3; total-history boilerplate ×6; ℤ step-path dictionary ×2 |
| Estimated deletable lines from U1–U8 | ~700–800, against ~250 added |
| Mathlib reuse opportunities confirmed by search | `Mathlib.Order.Concept` (C-06); `neg_lt_neg_iff`/`neg_le_neg_iff`/`neg_neg`/`neg_inj` (C-13); `Function.Periodic` (C-14a) |
| Mathlib reuse opportunities checked and **rejected** | `SimpleGraph.Walk`, `Quiver.Path`, `Relation.ReflTransGen`, `Function.minimalPeriod`/`IsPeriodicPt` for `Walk`/`MinCyc` (C-14) |
| Existing Mathlib reuse verified correct | `LinearOrderedAddCommGroup.discrete_or_denselyOrdered`, `.discrete_iff_not_denselyOrdered`, `.int_orderAddMonoidIso_of_isLeast_pos` (`DurationClassification.lean:162,179,262`); `SuccOrder.ofSuccLeIff` (`LexCarrier.lean:78`, `DurationFrames.lean:100`); `exists_minimal_of_wellFoundedLT` (`TaskFrame.lean:1077`) |
