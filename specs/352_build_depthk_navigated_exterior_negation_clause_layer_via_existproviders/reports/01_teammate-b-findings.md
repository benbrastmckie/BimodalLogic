# Task 352 — Teammate B Findings (Frozen k=2 template + prior art + architectures)

**Angle**: the frozen k=2 clause layer as a *generalization template*, per-step break analysis,
reusable depth-k prior art already in the tree, and candidate construction architectures (no
commitment — that is synthesis's job). READ-ONLY; ExistProviders-channel deep-dive deferred to
Teammate A.

**Reference tier**: Tier 3 (implementation-backed) with Tier 1 backing (Rabinovich Cor 5.4 /
Lemma 5.3 / Def 7.5). All claims carry `file:line` evidence, read via `Read`/`Bash grep`.

---

## Key Findings

1. **The frozen k=2 clause layer splits cleanly into three strata by how each step touches
   `σ.2`.** Roughly half the proof volume — every zone/order/chain combinator — is
   **profile-type-agnostic** and generalizes to depth `k` *verbatim*. A second stratum (the
   `σ.2` zone-fact reads and the `nf_eval_depth1_fold_iff` unpacking) generalizes **mechanically
   via already-landed depth-k machinery**. Only a third stratum — the **TL formula-building
   layer** — is a genuine new construction, and it needs a depth-`k` characteristic-formula
   channel. So "ExteriorNegation-scale rebuild" (report 11 root-cause estimate: ~2000+ lines) is
   an over-count if the verbatim-generalizing and landed-core strata are reused rather than
   retyped.

2. **The single depth-hardwiring point is `σ.2 (nf0_assemble zs χ σ.1)` with `χ : NormalForm
   sig 0 1`** (the pattern in `kvE2_futGapBit`/`RayBit`/`SelfBit`, ExteriorNegation.lean:877/882/
   887; and in `kvE2_futAdmissible` :991, the `hbits` hypothesis :1499). `nf0_assemble` is a
   **lossless** coordinatization of depth-0 subs only (NfEFold.lean:283 `nf_eval_nf0_cons_factor`,
   :549-561 faithfulness note). At depth `k ≥ 1` the arity-1 `χ` cannot capture a depth-`k` sub's
   joint coupling — this is exactly the F2/task-327 collapse (`f2_sub_proj_eq`,
   RefutationF2.lean:471). Every break traces to this one boundary.

3. **The depth-k replacement for that read already exists and is green.**
   `kvE_subBit`/`kvE_subBit_iff` (ExteriorBracketK.lean:302/314) is the *fiber-existential
   full-arity* substitute for `σ.2 (nf0_assemble zs4 χ σ.1)`, reading subs at `NormalForm sig k 5`
   through the atom-layer channels `nfk_dropFresh`/`nfk_zoneSpec`/`nfk_projFresh` and consuming
   the Phase-1 bridge `nf_eval_nfk_iff_efold` (NfEFold.lean:627). Its docstring names the exact
   frozen read it replaces (:298-301). This is the prior-art pattern the rebuild should mirror, not
   reinvent.

4. **The formula channel the "needs-P" steps require is *also* already in the frozen tree:**
   `nf_succ_char_formula` + `nf_succ_char_formula_correct` (KampPrior.lean:67/81) build the
   characteristic TL formula of a depth-`(k+1)` arity-1 NF **given a depth-`k` arity-2
   existential-to-TL converter** — which is exactly `ExistProviders.existF` at arity 1
   (PriorInterface.lean `existF : (n) → NormalForm sig k (n+1) → Formula`, `correct` field
   mirroring `nf_succ_char_formula_correct`'s `h_exist_correct` hypothesis verbatim). KampPrior.lean
   is a byte-identical-frozen file, so this is a **read-only reusable input**. The depth-k analog of
   `nf_depth0_char_formula atomMap h_surj χ` is therefore `nf_succ_char_formula atomMap h_surj
   (P.existF 1) χ` — the formula-building layer is *parameterized reuse*, not a from-scratch build.

5. **The "thin adapter over the frozen layer" architecture is provably DEAD.** The blocker record
   (plan 07 Phase-2 BLOCKER (ii); report 11 root-cause 2) shows a truncation-shadow bracket over
   `nfk_truncD` shadows cannot satisfy `_sound` and `_complete` simultaneously (the F2 pair breaks
   both directions). Any candidate that tries to feed a shadow σ into the *unchanged*
   `kvE2_extNegFut` is refuted up front — the rebuild must read at full arity from the start.

---

## Per-step generalization table

Legend: **V** = generalizes verbatim (no `σ.2` read; profile-type-agnostic); **L** = generalizes
via landed depth-k core + Phase-1 bridge (mechanical substitution); **P** = needs the depth-`k`
formula/char-correctness channel (`nf_succ_char_formula` + `ExistProviders`).

| Frozen k=2 element (file:line) | Role | Verdict | What changes at depth k |
|---|---|:--:|---|
| `kvE2_futZoneClass` (:915), `kvE2_futPossibleZones` (:902), `kvE2_futBelowClass`/`futCharZone4` | zone-4 order classification | **V** | pure `ZoneSpec 4` order combinatorics; no `σ.2`; copy unchanged |
| `kvE2_futMinPick` (:1146) | minimal-witness pick over a list | **V** | generic over `α`; profile-agnostic |
| `kvE2_futChainBuild` (:1180), `kvE2_futChainDestruct` (:1435) | build/destruct `D`-guarded Until chain | **V** | takes char-formulas as *parameters*; only `M.carrier` order + formula truth; copy unchanged |
| `kvE2_futGapBit`/`RayBit`/`SelfBit` (:877/882/887) `= σ.2 (nf0_assemble … χ σ.1)` | σ's exterior-zone bits | **L** | replace with `kvE_subBit σ zs4 χ` (ExteriorBracketK:302); `χ : NF 0 1 → NF k 1` |
| `kvE2_futGapList`/`RayList` (:891/896) `filter` over `Finset.univ : NF 0 1` | profile lists | **L** | universe `NF 0 1 → NF k 1` (still `Fintype`); bit read via `kvE_subBit` |
| `kvE2_futAdmissible` §1 zone marking `nf0_zoneSpec σ.1` (:985) | atom-layer zone tag | **L** | atom-layer only; `nfk_zoneSpec`/`nf0_zoneSpec ∘ ·.1` (lossless on atom layer, D7-legal) |
| `kvE2_futAdmissible` §2 off-fiber bits over `NF 0 5` (:986-987) | off-fiber falsity | **L** | `NF 0 5 → NF k 5`; `nf0_dropFresh → nfk_dropFresh`; read `σ.2 τ` at full arity |
| `kvE2_futAdmissible` §3 order-impossible bits `σ.2 (nf0_assemble zs χ σ.1)` (:988-991) | impossible-zone falsity | **L** | fiber-existential `kvE_subBit`; determinacy `nf_eval_unique M k` |
| `kvE2_futAdmissible` §4 self-bit vs `nf0_projFresh σ.1` (:992-993) | fresh-profile carve-out | **L** | `kvE_projFreshD σ` (ExteriorBracketK:198); `= kvE_projFreshD_zero` at k=0 |
| `kvE2_futFreshProfile` (:996) `nf_eval_nf M 0 1 … nf0_projFresh σ.1` | realizer carries fresh profile | **L** | `nf_eval_nf M k 1 … kvE_projFreshD σ`; landed `nf_eval_projFreshD` (:203) |
| `kvE2_futRealizer_admissible` (:1010) unpacks via `nf_eval_depth1_fold_iff` | realizer ⇒ admissible | **L** | swap `nf_eval_depth1_fold_iff → nf_eval_nfk_iff_efold` (NfEFold:627); zone reads via `kvE_subBit_iff` |
| `kvE2_futGapD`/`RayD` (:1072/1079) `map (nf_depth0_char_formula …)` | gap/ray guard formulas | **P** | `nf_depth0_char_formula χ` (χ:NF 0 1) → `nf_succ_char_formula … (P.existF 1) χ` (χ:NF k 1) |
| `kvE2_futRayForm` (:1088), `kvE2_futEnd` (:1098), `kvE2_futChain` (:1108), `kvE2_futPos` (:1124) | positive local-existence form | **P** | same char-formula substitution threaded through; chain *shape* is V, its *char inputs* are P |
| `kvE2_extNegFut_sound` (:1243): `hD`/`hend`/`hocc` via `nf_depth0_char_correct'` + `hquantσ` | soundness | **L+P** | order/chain plumbing V; each `hquantσ`-read is L; each `nf_depth0_char_correct'` is P (`nf_succ_char_formula_correct`) |
| `kvE2_extNegFut_sound` final `kvE2_futChainBuild … if_pos` (:1313) | assemble realizer | **V** | order-structural once char inputs supplied |
| `kvE2_extNegFut_complete` (:1484) hyps `kvE2_futAnyBit`/`hbits`/`hbelow` | zone-fact pins | **L** | landed `kvE_futAnyBit`/`kvE_futAnyBit_correct` (ExteriorBracketK:218/230) are the exact depth-k pins |
| `..._complete` `hbase : nf0_dropFresh σ.1 = qnf.1` (:1495) | base-restriction match | **L** | `nfk_dropFresh` |
| `..._complete` admissibility unpack `hoff`/`himposs`/`hself` (:1515-1540) | reconstruct realizer's zone bits | **L** | fiber-existential reads; `nf_eval_unique M k` |
| `..._complete` `kvE2_futChainDestruct` (:1553) | destruct true chain | **V** | order-structural |
| `..._complete` realizer reconstruction from formula truth at each witness | rebuild depth-k realizer | **L+P** | `nf_characteristic M k` (available) + char-correctness (P) to match formula-truth ↔ profile-realization |

**Where it SPECIFICALLY breaks at the `nf0_assemble` depth-0 boundary (NfEFold:549-561):** every
**L** row above. The break is uniform — a single substitution `σ.2 (nf0_assemble zs χ σ.1)` (χ:NF
0 1) ⟶ `kvE_subBit σ zs χ` (χ:NF k 1) — and the substitute is already proved honest
(`kvE_subBit_iff`). The **P** rows are the only rows with no landed substitute *inside the leaf
module*; their substitute (`nf_succ_char_formula` + a `P : ExistProviders`) lives in a frozen file
and must be *threaded in as a parameter*, which is why the leaf-module Phase-2 attempt could not
close them (report 11 root-cause 3).

---

## Reusable prior art (file:line) — mirror, do not reinvent

- **Phase-1 depth-k fold bridge** — `nf_eval_nfk_iff_efold` (NfEFold.lean:627), with
  `nf_eval_efold_k` (:608), `nfk_dropFresh` (:578), `nfk_zoneSpec` (:586), `nf_eval_nf_atom_layer`
  (:593), and k=1 recovery `nf_eval_nfk_iff_efold_k1_recovers` (:678). This is the depth-general
  replacement for `nf_eval_depth1_fold_iff` (CarrierKv.lean:466) that every clause-layer proof
  step unpacks through. **Green, sorry-free, axiom-clean** (task 349 Phase-1, commit 6b6ef2196).
- **Landed depth-k determinacy core** — ExteriorBracketK.lean (task 349 Phase-2, commits
  34a173e88/af794abcb/c4c5c7eb1). Directly reusable inputs the clause layer consumes:
  - `kvE_subBit` (:302) / `kvE_subBit_iff` (:314) — **the fiber-existential replacement for the
    frozen `σ.2 (nf0_assemble …)` reads** (every **L** row).
  - `kvE_futAnyBit` (:218) / `kvE_futAnyBit_correct` (:230) — the depth-k `habove`/`hbelow` pin in
    the exact `NF k 1` / `nf_eval_nf M k 1` shape the `_complete` hypotheses need.
  - `kvE_projFreshD` (:198) / `nf_eval_projFreshD` (:203) — depth-k fresh shadow (replaces
    `nf0_projFresh σ.1` reads).
  - `nfk_truncD` (:62) / `nf_eval_truncD` (:80), `nf_eval_take` (:111) / `nf_eval_projFresh` (:163).
  - **k=0 recovery lemmas** `kvE_projFreshD_zero` (:376), `kvE_futAnyBit_zero` (:389), and the
    `kvE2_futAnyBit_correct` recovery `example` (:397) — the template for proving the rebuilt
    clause layer is *not weaker* than the frozen k=2 originals (mandatory sanity gate).
- **Depth-k characteristic-formula channel (frozen, read-only)** — `nf_succ_char_formula`
  (KampPrior.lean:67) / `nf_succ_char_formula_correct` (:81): builds the char TL formula of a
  depth-`(k+1)` arity-1 NF from a depth-`k` arity-2 existential converter; `correct` field is the
  `ExistProviders.correct` shape verbatim. `nf_depth0_char_formula_correct_arity1` (:168) is the
  k=0 base. **This is the substitute for every P row** and it already exists.
- **The provider bundle type** — `ExistProviders` (PriorInterface.lean, `existF`/`correct`) — the
  parameter that threads the P-channel into the leaf module. (Deep-dive = Teammate A.)
- **NfZoneDepthK.lean** — depth-k order/zone lemmas: `nf_eval_atom_layer` (:190, NOTE the
  Phase-1 name-collision that forced the `nf_eval_nf_atom_layer` rename — do not re-collide),
  `nf3_order_*` (:233-278), `nf_zone_exists_iff_char` (:318), `nf_zone_partition5` (:366),
  `nf_char3_eq_succ_iff` (:537). Depth-k analogs of the zone plumbing the **V** rows use.
- **FORBIDDEN**: `nf_char3_deeper_split` (Base.lean:603) — it *grows* anchors (arity), so it is
  never an arity-collapse tool here (Lemma32Reduction.lean:56 documents why). Stay clear.

**Reusability verdict:** of the four "unbuilt" bracket-lemma dependencies named in report 11,
**three are already landed or frozen-consumable** (fold bridge, determinacy core, char-formula
channel). The genuinely-new work is confined to (a) *retyping* the V-stratum combinators into the
new module and (b) *threading* `P` through the P-stratum formula builders — not re-deriving
determinacy or fold theory.

---

## Candidate architectures (enumerated, not ranked)

**A1 — Standalone `ExteriorNegationK.lean` parameterized by `P : ExistProviders sig atomMap k`.**
Mirror ExteriorNegation.lean structure decl-for-decl: V-rows copied, L-rows substituted with
`kvE_subBit`/`kvE_futAnyBit`/`nf_eval_nfk_iff_efold`, P-rows built with `nf_succ_char_formula
… (P.existF 1)`. Past mirror is `ExteriorNegationPastK.lean` (time-reversed, symmetric —
ExteriorNegationPast.lean is a clean mirror per its :45-46 note). *Feasibility: high but large.*
This is plan-07 resolution (a) and the task title's prescribed shape. Risk: line count, and the
`P.existF` correctness hypotheses (`h_UZ`/`h_SZ`) must thread cleanly to every char-correctness
site.

**A2 — Re-derive over `P.existF 0` point descriptions directly.** Frame gap/ray/self "profiles"
as `P.existF`-produced formulas from the start rather than as `nf_succ_char_formula` of `NF k 1`
profiles. Essentially A1 with the char-formula indirection removed. *Feasibility: contingent on
the `existF` arity/shape — this is Teammate A's channel; I flag it as the natural alternative to
A1's `nf_succ_char_formula` framing and defer the interface analysis.*

**A3 — Thin adapter over the frozen layer (feed `nfk_truncD` shadow σ into `kvE2_extNegFut`).**
**INFEASIBLE — provably dead** (plan-07 BLOCKER (ii); report 11 root-cause 2; report 10 C4): the
truncation-shadow bracket cannot satisfy `_sound` and `_complete` at once against an F2 pair.
Listed only to record that synthesis should not revisit it.

**A4 — Build the clause layer inside the recursion, mutual with `endIntervalStep`.** Plan-07
resolution (b): the rung-`(k+1)` clause consumes rung-`k` formulas that only exist inside the
recursion. Removes the `ExistProviders` parameter (formulas supplied by the recursive partner) at
the cost of coupling task 352 to task 349 Phase 3 and a `Nat.rec`/termination obligation. *Feasibility:
plausible but entangles the two tasks and loses the clean leaf-module boundary; likely worse
separation of concerns than A1.*

**A5 — Hybrid: extract the V-stratum into a shared depth-agnostic file, then A1 for L+P.**
Pull `kvE2_futZoneClass`/`PossibleZones`/`MinPick`/`ChainBuild`/`ChainDestruct` (all **V**) into a
profile-parametric shared module (they already take char-formulas as parameters), then the depth-k
clause layer only *instantiates* them with depth-k char inputs. Minimizes retyping and keeps the
k=2 and depth-k layers sharing one combinator core (guards the "frozen byte-identical" constraint
by *not* copying frozen proof bodies — reusing them). *Feasibility: high; best churn profile, but
requires care that the extraction leaves ExteriorNegation.lean byte-identical (extract by
*re-export/parameterization from a new file the frozen file does not import*, since the frozen file
cannot be edited).* **Note the tension**: true extraction would touch the frozen file; a
non-touching variant must *re-copy* the V-combinators into the new module (A1's cost) or prove them
afresh generically. Synthesis should weigh whether the byte-identical constraint permits any shared
factoring at all.

**Cross-cutting constraints all candidates inherit** (from the delegation): guards G1-G5;
FORBIDDEN `nf_char3_deeper_split`; the 7 frozen providers + KampPrior.lean byte-identical
(⇒ `nf_succ_char_formula` is consume-only); sorry-free; axioms exactly `[propext,
Classical.choice, Quot.sound]`; and the mandatory k=0-recovery sanity gate (mirror
`kvE_futAnyBit_zero` :389) proving each rebuilt clause-layer decl agrees with its frozen k=2
original at `k=0`.

---

## Confidence

- **High**: the three-stratum decomposition and the per-step V/L/P verdicts (grounded in direct
  reads of the frozen defs and the landed ExteriorBracketK core; the L-substitutes are green and
  their k=0 recovery is proved).
- **High**: A3 is dead; A1 is the prescribed shape; `nf_succ_char_formula`/`ExistProviders` is the
  P-channel substitute (KampPrior.lean:67/81 read directly, `correct` field matches).
- **Medium**: the *line-count / feasibility* ranking of A1 vs A4 vs A5 — I did not attempt a
  compile of any rebuilt decl (read-only research), and the A5 byte-identical-vs-factoring tension
  is unresolved (flagged as an open question, not a claim).
- **Medium**: exact `P.existF` arity threading (A2) — deliberately deferred to Teammate A to avoid
  duplicating the ExistProviders-channel analysis.

---

## Open questions (for synthesis / Teammate A)

1. **Does the byte-identical constraint permit ANY shared factoring of the V-stratum (A5), or must
   the ~half of the frozen proof that is profile-agnostic be re-copied into the new module?** The
   frozen file cannot be edited; a shared combinator file it does not import is additive, but the
   frozen file would then still carry its *own* copies — acceptable, but it means no de-duplication,
   only new-module reuse. This is the single biggest lever on total line count.
2. **At which `P.existF` arity does the clause layer consume the provider?** The point profiles are
   `NF k 1`; `nf_succ_char_formula` wants a `NF k 2 → Formula` converter (arity-2 existential).
   Confirm `ExistProviders.existF 1` supplies exactly that shape (Teammate A).
3. **Do `h_UZ`/`h_SZ` (Prior structure hypotheses of `nf_succ_char_formula_correct`) propagate to
   every char-correctness site in `_sound`/`_complete`, or does the clause layer need them only at
   the top?** Affects whether the rebuilt lemmas gain `semantic_prior_UZ/SZ` hypotheses vs stay
   model-generic like the frozen k=2 (`kvE2_extNegFut_sound` is model-generic, :1243).
4. **Is the `nf0_zoneSpec σ.1` atom-layer zone read (V/L boundary in `kvE2_futAdmissible`) truly
   lossless at depth k?** ExteriorBracketK uses `nf0_zoneSpec ∘ ·.1` / `nfk_zoneSpec` freely
   (:222, :306) and the D7 note (NfEFold:570) says depth-0 losslessness is used *only* on the atom
   layer — so yes, but confirm no clause-layer step reads the *quant* layer through `nf0_zoneSpec`.
5. **Past-side symmetry**: confirm `ExteriorNegationPast.lean`'s private mirrors
   (`kvE2_extNegPast_complete` time-reversal, :662) generalize under the same V/L/P split with no
   new break — expected from the clean-mirror note (:45-46) but not step-verified here.
