# Discrete chronicle over a non-Archimedean block carrier — research report

**Verdict: BLOCKED.** Deliverable (a)'s densification step is not merely unproven; it is
**refuted at the level of every chronicle property the existing machinery exports**, and the
refutation survives relaxing the carrier from `ℚ ×ₗ ℤ` to *any* linearly ordered abelian group.
Deliverable (b) is blocked downstream of it. A non-trivial, sorry-free subset of the scope is
achievable and is itemised in §7.

Repository state at time of research: `lake build` green (2462 jobs, clean), HEAD `1f192f3f8`.

---

## 1. What was re-verified (all hints in the task brief were stale-checked)

| Claim in brief | Live location | Status |
|---|---|---|
| `box_dense_gives_density` near :430 | `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean:430` | exact |
| `cantorIsoDense` near :231 | same file `:231` | exact |
| `cantor_bfmcs_dense_restricted_tc` near :624 | same file `:624` | exact |
| `cantor_bfmcs_dense_restricted_buc` near :675 | same file `:675` | exact |
| `cantor_bfmcs_dense_restricted_fuc` near :750 | same file `:750` | exact |
| `valid` near :94, no `IsSuccArchimedean` binder | `FormalSystem/Semantics/Validity.lean:94` | **re-confirmed post-refactor**: binders are exactly `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]`; `SemanticConsequence` (`:118`) matches. No Ω, no admissible-history parameter, totality carried by `τ.IsTotal` |
| `WeakCanonical.countermodel_discrete` decl near :1068, sorry near :1084 | `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1069`, sorry at `:1102` | decl exact-ish, **sorry line drifted +18** |

### The four-axiom / totality exposure note is a non-issue for this task

The refactored `TaskFrame` (`FormalSystem/Semantics/TaskFrame.lean:474`) carries `WorldState`,
`nonempty`, `TaskRel`, `nullity_identity`, `comp` (biconditional Compositionality), `converse`,
`serial`, `Limit`, `Spherical`. **None of them is this task's burden.** Every frame the chronicle
route builds is `Algebraic.bundleFlowFrame B` (`FormalSystem/Metalogic/Algebraic/FlowFrame.lean:455`),
which is generic in `D` over exactly the four Base binders and discharges all `TaskFrame` fields
internally; `bundleFlowModel`, `bundleFlowHistory`, `bundleFlowHistory_total` likewise.

`FormalSystem/Metalogic/BXCanonical/DiscreteCarrierProbe.lean` (predecessor task's output)
confirms this by compilation at `D := ℚ ×ₗ ℤ`, including the load-bearing
`bundleFlow_completeness_from_neg_membership`. Its `.olean` is present and current, and `lake
build` is green, so the probe's claims hold against the post-refactor signatures.

Independently re-checked in this session (fresh `lake env lean` snippet, see §6):
`AddCommGroup (ℚ ×ₗ ℤ)`, `LinearOrder`, `IsOrderedAddMonoid`, `Nontrivial` all resolve.

---

## 2. Deliverable (a) part 1 is already done and sorry-free

The task brief frames the analogue of `box_dense_gives_density` as work to be produced. **It
already exists**, at the tail of the same file:

- `box_discrete_gives_discreteness` — `ChronicleToCountermodelBasic.lean:1176`.
  `Formula.box nextTop ∈ N → ∀ x ∈ LimitDom fc N h_N, nextTop ∈ LimitF fc N h_N x`.
  `#print axioms`: `[propext, Classical.choice, Quot.sound]` — no `sorryAx`.

So does the entire ℤ-block infrastructure it feeds (`:876`–`:1170`), all sorry-free
(`#print axioms` verified on the instance defs and `succ_orbit_convex`):

`limit_dom_has_succ`, `limit_dom_has_pred`, `next_top_gives_since`, `limitDomSubtypeSucc`,
`limitDomSubtype_succ_le_iff`, `limitDomSubtypeSuccOrder`, `limitDomSubtypePred`,
`limitDomSubtype_le_pred_iff`, `limitDomSubtypePredOrder`, `order_succ_eq_limitDomSubtype_succ`,
`order_pred_eq_limitDomSubtype_pred`, `limitDomSubtype_succ_pred`, `limitDomSubtype_pred_succ`,
`limitDomSubtype_le_pred_of_lt`, `limitDomSubtype_pred_lt`, `succ_orbit_convex`.

`succ`/`pred` are mutually inverse, so they generate a **ℤ-action** on `LimitDomSubtype`, and
`succ_orbit_convex` is precisely the convexity of its orbits. **The "block decomposition into
ℤ-blocks" half of deliverable (a) is therefore essentially in place**; what is missing is only
the quotient packaging (§7, S2) — and the densification, which is where the task dies.

---

## 3. The failing obligation, named

Deliverable (a)'s remaining content is the discrete analogue of `cantorIsoDense`:

```lean
-- OBLIGATION O1 (CARRIER-ISO / BLOCK-DENSITY)
theorem limitDomSubtype_isoBlockCarrier (fc : FrameClass) (N : Set Formula)
    (h_N : SetMaximalConsistent (fc := fc) N)
    (h_discrete : ∀ x ∈ LimitDom fc N h_N, nextTop ∈ LimitF fc N h_N x) :
    Nonempty (LimitDomSubtype fc N h_N ≃o (ℚ ×ₗ ℤ))
```

A second obligation is latent in the bundle and is *not* named anywhere in the design document:

```
-- OBLIGATION O2 (CARRIER-UNIFORMITY)
one and the same carrier D must serve every N box-equivalent to A,
because `cantorBfmcsDense.families` ranges over all such N at a single D.
```

O2 is free if O1 delivers the fixed carrier `ℚ ×ₗ ℤ`. It becomes a real obligation under any
weakening of O1 to a chronicle-dependent carrier — which is the natural repair move, and which
§4 also closes off.

### Why the isomorphism, and not an embedding, is required

Checked against the live definitions in `FormalSystem/Metalogic/Bundle/TemporalCoherence.lean`
(`:308`, `:558`, `:589`):

- `RestrictedTemporallyCoherent` and `RestrictedForwardUntilSinceCoherent` demand witnesses
  **in `D`**, so the image of `D` in the chronicle order must be closed under F/P-resolution
  and C5/C5' witnesses.
- `RestrictedBackwardUntilSinceCoherent` runs the other way: its hypothesis is an existential
  over `D`, and it is discharged from C4/C4', whose counterexample witness `z` lives in the
  chronicle order. For the contradiction to land, `z` must be **in the image** — i.e. the image
  must be **convex**.
- A map `f : D → LimitDomSubtype` that is not strictly monotone collapses two times to one MCS,
  and `forward_G` then demands `Gφ ∈ M → φ ∈ M`, which is not an MCS property.

Strictly monotone + convex image + resolution-closed ⇒ the image is all of the chronicle order
(resolution witnesses are cofinal and coinitial), and a strictly monotone surjection between
linear orders is an order isomorphism. There is no slack here: **O1 is exactly what deliverable
(a) needs.**

---

## 4. O1 is refuted, twice

### 4.1 The interface that any proof of O1 may use

The restricted-coherence proofs consume only: countability, `NoMinOrder`, `NoMaxOrder`,
`SuccOrder`/`PredOrder` (from discreteness), `limit_c0`, `limit_f_zero`, `limit_forward_G`,
`limit_backward_H`, `limit_F_resolution`, `limit_P_resolution`, `limit_satisfies_c4`,
`limit_satisfies_c4'`, `limit_satisfies_c5_strong`, `limit_satisfies_c5'_strong`.

That list is exactly the archived abstraction `PriorModelData`
(`FormalSystem/Boneyard/BXPipelineDeadCode/ReynoldsModelSurgery.lean:61`), read in full this
session: linear order, no max, no min, `SuccOrder`, `PredOrder`, MCS at each point, Prior-UZ/SZ,
C5 forward for Until and Since, C4 backward for Until and Since.

### 4.2 A model of that interface with the wrong shape

Take the one-world-state Base frame over `D := ℤ`: `WorldState := Unit`, `TaskRel w x u := True`.
Truth is then constant in `t`, so at any point (semantics per `FormalSystem/Semantics/Truth.lean:165`,
guard-first `untl ψ φ = ∃ s > t, φ at s ∧ ψ strictly between`):

- `Fφ ↔ φ`, hence `Gφ ↔ φ`; dually `Pφ ↔ φ`, `Hφ ↔ φ`;
- `untl ψ φ ↔ φ` and `snce ψ φ ↔ φ` — take `s = t ± 1`, whose open interval is empty;
- consequently `nextTop = untl ⊥ ⊤` holds, and `□ nextTop` holds (one world state).

Let `M` be the MCS of that point — a genuine `FrameClass.Base` MCS containing `□ nextTop`.
Now assign `M` **constantly** to every point of the abstract order `ℤ + ℤ` (`Bool ×ₗ ℤ`), which
is countable, discrete, and has neither endpoint. Every interface condition holds: C5/C5' with
`s` the immediate successor/predecessor (empty guard interval), C4/C4' **vacuously** (their
hypothesis `¬untl ψ φ ∈ M` together with `φ ∈ M` is unsatisfiable, since `untl ψ φ ↔ φ` in `M`),
`forward_G`/`backward_H` from `Gφ ↔ φ`. This is the ℤ+ℤ witness the repository already documents
(`FormalSystem/Boneyard/BXPipelineGapAnalysis/README.md`: "two copies of ℤ with constant MCS at
every point — satisfies all `PriorModelData` hypotheses yet has a Dedekind gap"), re-derived here
against the live semantics rather than taken on trust.

**Refutation R1 (against the stated carrier).** The same construction over a *single* copy of ℤ
is equally a model of the interface. `ℤ ≇ ℚ ×ₗ ℤ` (in `ℤ` every open interval is finite). So no
proof of O1 can go through the interface.

**Refutation R2 (against *any* ordered-group carrier).** The `ℤ + ℤ` model has block order `2`.
`ℤ + ℤ` **is not order-isomorphic to any linearly ordered abelian group** — machine-checked
below. So the natural repair (drop the fixed `ℚ ×ₗ ℤ`, let the carrier depend on the chronicle,
and satisfy O2 some other way) is closed off too.

### 4.3 R2's core, machine-checked

Artifact: `specs/422_.../verification/block_order_refutation.lean`
(re-run with `lake env lean specs/422_.../verification/block_order_refutation.lean`;
it emits `'no_ordered_group_carrier' depends on axioms: [propext, Classical.choice, Quot.sound]`
— **no `sorryAx`**).

```lean
abbrev T := Bool ×ₗ ℤ

/-- Order-invariant: the strict upper set of `x` contains a strictly decreasing ℕ-sequence. -/
def P {α : Type} [Preorder α] (x : α) : Prop :=
  ∃ f : ℕ → α, (∀ n, x < f n) ∧ StrictAnti f

theorem P_iso   : ∀ (e : α ≃o β) x, P x → P (e x)          -- invariant under order isos
theorem P_bot   : P (toLex (false, 0) : T)                  -- witness n ↦ toLex (true, -n)
theorem not_P_top : ¬ P (toLex (true, 0) : T)               -- would give ℤ⁺ strictly decreasing

theorem group_homogeneous {G} [AddCommGroup G] [LinearOrder G] [IsOrderedAddMonoid G]
    (a b : G) : ∃ t : G ≃o G, t a = b :=
  ⟨OrderIso.addRight (b - a), by simp⟩

theorem no_ordered_group_carrier {G} [AddCommGroup G] [LinearOrder G] [IsOrderedAddMonoid G]
    (e : G ≃o T) : False
```

The argument in one line: a linearly ordered abelian group is order-**homogeneous** (translation
is an order automorphism), `ℤ + ℤ` is not, so no such `G` has that order type.

Note this is a *sharper* statement than "the block order might not be dense". It says the
chronicle order can fail to be groupable **at all**, so no amount of carrier engineering
downstream can absorb it. This is the concrete content of the design document's §5.7 risk
(`specs/archive/361_.../design/03_weak-terminus-status.md`), now settled in the negative at
interface level.

---

## 5. What would be required to unblock, and why it is a research programme

Since O1 is unprovable from the interface, any proof must reach **into the construction**
(`ChronicleConstruction.lean`'s ω-chain, 1613 lines; `PointInsertion.lean`, 3639 lines) and
establish a new invariant: *between any two ℤ-blocks there is a third*.

Two structural facts make this expensive:

1. **A gap cannot be filled by a point; it must be filled by a whole fresh ℤ-block.** Inserting a
   single `z` between adjacent blocks contradicts `nextTop ∈ LimitF z`: `z` would need an
   immediate predecessor, but the block below `z` has no maximum.
2. **The fresh block's MCSs must resolve their own F/U obligations** (else
   `limit_satisfies_c5_strong` fails at the new points and every restricted-coherence proof
   breaks), while being G/H-coherent with both sides of the gap.

That is precisely the construction attempted and abandoned in
`FormalSystem/Boneyard/BXPipelineGapAnalysis/HenkinDiscreteChain.lean`. Its documented obstacle
is specific and should be treated as the real blocker:

> **F-formula persistence through Lindenbaum extensions is not guaranteed.** Building
> `mcs(n+1)` as `Lindenbaum({witness} ∪ g_content(mcs n))`, the extension may arbitrarily
> include `G(¬ψ)`; once in, it propagates forever via `temp_4`, and `F(ψ)` is permanently lost
> from the chain. The augmented seed `{ψ} ∪ g_content(M) ∪ {F(χ)}` can be inconsistent.

Five further approaches are recorded there as failed (v1–v3), including "stage-based induction —
constant-MCS gap scenario is consistent", which is the same witness as §4.2. Two sorry-free
building blocks survive there (`g_content_consistent`, `h_content_consistent`) and the file lists
four viable-but-unproven paths (reflexive-semantics Henkin model plus conservative extension;
augmented-seed consistency; restricted-MCS truth lemma; construction-level gap analysis).

**Recommendation: do not attempt O1 inside this task.** It is a construction-level research
programme with a named, previously-defeated obstacle, not a transcription job. Attempting it
under the zero-debt gate would produce either a `sorry` or a vacuous placeholder, both of which
the brief explicitly forbids.

---

## 6. Tool survey and one tool defect worth propagating

| Probe | Tool | Result |
|---|---|---|
| Whole-repo build | `lake build` | green, 2462 jobs |
| `ℚ ×ₗ ℤ` discharges the four Base binders | `lake env lean` snippet | all four `inferInstance` |
| `OrderIso.addRight (b - a)` gives homogeneity | `lake env lean` | closes with `simp` |
| `Prod.Lex.toLex_lt_toLex`, `Prod.Lex.lt_iff` | `lake env lean` | both exist, used verbatim |
| `#print axioms` on 5 discrete-infrastructure decls | `lake env lean` | all `[propext, Classical.choice, Quot.sound]` |
| `not_P_top` induction | `omega` after `push_cast` | succeeds |
| Bool strict-order side goals | `decide` (`not_true_lt`) | succeeds; `simp` alone does **not** close `¬(true < b)` |

**Defect: `mcp__lean-lsp__lean_run_code` reports false success.** In this session it returned
`{"success": true, "diagnostics": []}` for the input `example : 1 = 2 := by rfl`, and likewise
for a snippet containing `sorry`. Everything in this report was therefore verified with
`lake env lean <file>` via Bash instead. Downstream agents on this repository should not use
`lean_run_code` to confirm anything. (`lean_diagnostic_messages` and `lean_file_outline` were
already blocked by contract and were not called.)

---

## 7. Salvageable, sorry-free scope (recommended re-dispatch content)

If this task is re-scoped rather than parked, these two items are achievable now, are
independent of O1, and materially de-risk it. Neither requires a `sorry`.

**S2 — block quotient packaging** (the "block decomposition" half of deliverable (a)).
Define the succ-orbit equivalence on `LimitDomSubtype` from the existing mutually-inverse
`limitDomSubtypeSucc`/`limitDomSubtypePred`, the induced linear order on the quotient, and prove
block convexity (`succ_orbit_convex` already gives the substance) and that each block is
order-isomorphic to `ℤ`. All sorry-free, all reusing declarations verified sorry-free in §2.
This is a genuine deliverable and it is the natural interface against which O1 would later be
stated.

**S1 — carrier-generic refactor of the dense machinery** (converts deliverable (b) from a
rewrite into a corollary). Nothing in `cantorBfmcsDense`, `rootedCantorFmcsDense`,
`shiftedCantorFmcsDense'`, or the three `cantor_bfmcs_dense_restricted_*` proofs uses density of
`ℚ`, or any field or ring structure. They use only: an order iso `LimitDomSubtype fc N h_N ≃o D`,
and additive shifting in `D`. Factor them through

```lean
variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
  (isoOf : ∀ N (h_N : SetMaximalConsistent (fc := fc) N), Hypothesis N → LimitDomSubtype fc N h_N ≃o D)
```

with `cantorIsoDense` instantiating `D := ℚ`. The one real porting cost is tactic choice: the
offset arithmetic currently uses `ring` and `linarith`, neither of which applies at `ℚ ×ₗ ℤ`
(not a ring, not a field). Replacements are `abel` for the `t + offset - offset = t`
rearrangements and `add_lt_add_right` / `sub_add_cancel` for the strict-inequality shifts —
every such site is a one-line, mechanical substitution. Once S1 lands, deliverable (b) is three
`exact` applications the day O1 arrives.

---

## 8. Bottom line for the orchestrator

- Deliverable (a1) — discreteness propagation: **already present and sorry-free**
  (`box_discrete_gives_discreteness`, `:1176`). No work needed.
- Deliverable (a2) — ℤ-block decomposition: **achievable, sorry-free** (item S2).
- Deliverable (a3) — block-order densification and the iso into `ℚ ×ₗ ℤ` (obligation O1):
  **REFUTED at interface level**, and refuted for *every* ordered-group carrier, not just this
  one (machine-checked, §4.3). Plus the previously unnamed obligation O2.
- Deliverable (b) — the three restricted-coherence analogues: **blocked on (a3)**; item S1
  makes them mechanical afterwards.
- `WeakCanonical.countermodel_discrete` (`Transfer.lean:1069`, sorry `:1102`) — untouched, as
  the brief specifies. It remains the sole `sorryAx` source reaching `BXCanonical.completeness`
  (`FormalSystem/Metalogic/BXCanonical/Completeness.lean:229`).
- `succ_cofinal` was **not** re-attempted, per the brief.

Escalating as `[BLOCKED]` with obligation O1 named, per the brief's explicit instruction.
