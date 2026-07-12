# Task 352 — Reindex/Transport Bridge Blocker Adjudication (Research Fork)

**Agent**: lean-research-hard-agent | **Date**: 2026-07-12 | **Mode**: hard (H2/H3/H4), lit
**Reference grounding tier**: **Tier 1** (literature-backed — Rabinovich 2014, Def 7.5 / Cor 5.4)
**Verdict**: **GO** — a shared, source-faithful, sorry-free, axiom-clean bridge is PROVEN.

---

## TL;DR

The documented blocker ("content channel evaluates the walked point at index 4; σ's fold binds
it at index 0; NO reindex/relabel bridge exists in the active tree, grep empty") rests on a
**false premise**. The bridge **already exists** in the active tree under a name the prior agents
did not grep for: `renameNF` + `renameNF_eval_iff` (`NfDepth0Generalized.lean:373`/`:440`) — a
fully-proven, general-`k`, arity-general, **bijective variable-permutation semantic transport**.

I stated the exact bridge both `_sound`/`_complete` need, instantiated it with an explicit cyclic
shift on `Fin 5`, and **verified it builds GREEN, sorry-free, axioms `[propext, Classical.choice,
Quot.sound]`** (lean_verify). I additionally built and verified the **shared content-channel
contract** (`kvE_fiberPosOnShift` + `_correct`) that the re-dispatch consumes.

Crucially, Rabinovich Def 7.5 / Lemma 5.3 / **Cor 5.4(2)** show the index-0↔index-4 "mismatch" is
**not a mismatch at all** — it is the literal encoding of the recursive rung step
`(∃r0)[z0<r0<z1] (INF(z0,r0,z1,P1) ∧ On(P2,…,Pn, r0, z1))`, in which the freshly-**quantified**
interior point `r0` (fold slot-0) **becomes the endpoint anchor** of the recursive sub-bracket
(existF index-last). The rename IS that re-anchoring. The bridge is faithful, not a workaround.

---

## Reference Grounding — Lemma-Level Mapping Table (H3 Tier 1)

| Source (Rabinovich 2014) | Prop / Location | Lean Identifier | Type Signature (verified) | Status |
|---|---|---|---|---|
| Bracket notation `[α0,β1,…,αn](z0,z1)`, endpoints z0(first)/z1(last), interior x1<…<xn quantified between | Notation 5.2 / Def 7.5 / formula (5.1); chunk_0013, chunk_0021 | `ExistProviders.existF` + `insertEnv env t` | `existF : (n)→NormalForm sig k (n+1)→Formula`; correct pins eval-point `t` at **index n (last)** = the sub-bracket **endpoint** | Confirmed (PriorInterface.lean:38-45) |
| `¬∃x1…∃xn (z0<x1<…<xn<z1) ∧ ⋀Pi(xi)` — interior points existentially bound, ordered between fixed endpoints | Lemma 5.3; chunk_0014 | `nf_eval_efold_k` fold conjunct | `∃ x, nf_eval_nf M k (n+1) (Fin.cons x env) sub ↔ qnf.2 sub` — fresh witness at **index 0** | Confirmed (NfEFold.lean:608-613) |
| Recursive rung: freshly-∃-quantified r0 **becomes endpoint** of sub-bracket `On(P2,…,Pn, r0, z1)` | **Cor 5.4(2)**; chunk_0014:35, chunk_0015 | **`renameNF` + `renameNF_eval_iff`** (the re-anchoring) | `nf_eval_nf M k b e (renameNF f r nf) ↔ nf_eval_nf M k a E nf` (bijective f,r; e=E∘f, E=e∘r) | **EXISTS, proven** (NfDepth0Generalized.lean:440) |
| Nested `(z0,z1,…,zk,∞)` bracket, consecutive endpoints bound each rung; z0 = present root | Def 7.13 / Lemma 7.14 / Lemma 7.10; chunk_0024, chunk_0023 | depth-`k` σ recursion (`NormalForm sig (k+1) 4`) | arity-4 anchors + arity-5 subs (1 fresh) per rung | Confirmed (structural) |
| One-free-var ∃-witness → Until/Since folding | Prop 3.5 (PDF p.5); chunk_0013 | `P.existF`/`P.correct` folding | — | Cited by PriorInterface.lean:29,55 |

---

## Deliverable 1 — Does an existing NormalForm reindex/transport lemma exist?

**YES. Definitively.** Prior agents grepped `reindex|relabel|permutation|skipIdx` (came up empty
except the Boneyard `∘ skipIdx` cross-*model* transport). The active-tree bridge is named
**`renameNF`**:

- **`renameNF`** (`NfDepth0Generalized.lean:373`): `{k a b} → (f : Fin b → Fin a) → (r : Fin a →
  Fin b) → NormalForm sig k a → NormalForm sig k b`. Precomposes a normal form with an index map;
  recurses through the quant layer via `liftIdx` (fixes fresh index 0, shifts the rest). Total
  along non-injective `f` (collides `.order` atoms to `false`).
- **`renameNF_eval_iff`** (`NfDepth0Generalized.lean:440`): the **semantic transport** —
  ```
  (f : Fin b → Fin a) (r : Fin a → Fin b) (E : Fin a → M.carrier) (e : Fin b → M.carrier)
  (hcomp : ∀ i, e i = E (f i)) (hcomp2 : ∀ i, E i = e (r i))
  (hsec : ∀ i, f (r i) = i) (hsec2 : ∀ i, r (f i) = i) (nf : NormalForm sig k a) :
      nf_eval_nf M k b e (renameNF f r nf) ↔ nf_eval_nf M k a E nf
  ```
  Fully proven, **general `k`**, **arity-general**, bijective. The succ case handles the quant
  layer via `cons_comp_liftIdx` — the fresh witness at `Fin.cons x ·` is preserved at every depth.
- Supporting: `renameNF_roundtrip` (:385), `liftIdx`/`liftIdx_zero`/`liftIdx_succ`/`liftIdx_comp`
  (:335-357), and a non-bijective diagonal variant `renameNF_eval_diag0` (:1646).

**Import availability** (verified): `ExteriorFiberK.lean` imports `NfEFold`, which imports
`NfDepth0Generalized` (NfEFold.lean:2). `renameNF`/`renameNF_eval_iff` are therefore already in
`ExteriorFiberK.lean`'s import graph — usable additively with **no new imports**.

Mathlib search was **not required** — the repo-local lemma is stronger and already tailored to
`NormalForm`/`nf_eval_nf`. (No "Mathlib likely has this" is asserted anywhere in this report.)

## Deliverable 2 — The exact bridge, stated and PROVEN

The bridge is a pure instantiation of `renameNF_eval_iff` with the cyclic shift that maps the
walked point between the fold slot (index 0) and the endpoint slot (index 4=last). **All of the
following was written to a scratch module, built GREEN (`lake build`, 1022 jobs, 0 errors), and
axiom-checked (lean_verify: `[propext, Classical.choice, Quot.sound]`), then removed** (research
fork leaves the tree clean; the re-dispatch adds these to `ExteriorFiberK.lean` proper):

```lean
-- Cyclic shift on Fin 5: index 0 (fold-fresh) ↔ index 4 (existF endpoint), rest shift.
def rot5Fwd : Fin 5 → Fin 5 := fun i => i + 1
def rot5Bwd : Fin 5 → Fin 5 := fun i => i - 1

theorem rot5_sec  : ∀ i, rot5Fwd (rot5Bwd i) = i := by decide
theorem rot5_sec2 : ∀ i, rot5Bwd (rot5Fwd i) = i := by decide

theorem rot5_comp {α : Type*} (env : Fin 4 → α) (p : α) :
    ∀ i, insertEnv env p i = (Fin.cons p env : Fin 5 → α) (rot5Fwd i) := by
  intro i; fin_cases i <;> rfl
theorem rot5_comp2 {α : Type*} (env : Fin 4 → α) (p : α) :
    ∀ i, (Fin.cons p env : Fin 5 → α) i = insertEnv env p (rot5Bwd i) := by
  intro i; fin_cases i <;> rfl

/-- THE BRIDGE. Content channel evaluating `renameNF rot5Fwd rot5Bwd s` at `insertEnv env p`
    (point `p` at LAST index 4 — `P.existF 4` endpoint convention) IFF the original `s` is
    realized at `Fin.cons p env` (point `p` at index 0 — σ's fold-slot convention). -/
theorem kvE_anchorBridge {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
    {k : Nat} (env : Fin 4 → M.carrier) (p : M.carrier) (s : NormalForm sig k 5) :
    nf_eval_nf M k 5 (insertEnv env p) (renameNF rot5Fwd rot5Bwd s) ↔
      nf_eval_nf M k 5 (Fin.cons p env) s :=
  renameNF_eval_iff M rot5Fwd rot5Bwd (Fin.cons p env) (insertEnv env p)
    (rot5_comp env p) (rot5_comp2 env p) rot5_sec rot5_sec2 s
```

**Shared content-channel contract** (also built GREEN + verified) — this is what `_sound`/`_complete`
actually reduce their content obligation to, and is **side-symmetric** (H7):

```lean
/-- Shared clause-content primitive: render each fiber sub under the anchor shift before existF. -/
noncomputable def kvE_fiberPosOnShift {sig} {atomMap} {k}
    (P : ExistProviders sig atomMap k) (l : List (NormalForm sig k 5)) : Formula :=
  kvE_fiberPosOn P (l.map (renameNF rot5Fwd rot5Bwd))

/-- Shared correctness contract: shifted channel holds at `p` IFF some listed fiber sub is
    realized with `p` as the FRESH (index-0) fold witness — EXACTLY σ's fold-layer shape. -/
theorem kvE_fiberPosOnShift_correct {sig} {atomMap} {k}
    (P : ExistProviders sig atomMap k) (l : List (NormalForm sig k 5))
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (p : M.carrier) :
    temporal_truth M atomMap p (kvE_fiberPosOnShift P l) ↔
      ∃ s ∈ l, ∃ env : Fin 4 → M.carrier, nf_eval_nf M k 5 (Fin.cons p env) s := by
  rw [kvE_fiberPosOnShift, kvE_fiberPosOn_correct P _ M h_UZ h_SZ p]
  constructor
  · rintro ⟨s', hs'mem, env, hev⟩
    obtain ⟨s, hsl, rfl⟩ := List.mem_map.mp hs'mem
    exact ⟨s, hsl, env, (kvE_anchorBridge M env p s).mp hev⟩
  · rintro ⟨s, hsl, env, hev⟩
    exact ⟨renameNF rot5Fwd rot5Bwd s, List.mem_map.mpr ⟨s, hsl, rfl⟩, env,
      (kvE_anchorBridge M env p s).mpr hev⟩
```

### How this discharges the exact recorded obligation

The Future handoff's concrete `lean_goal` obligation was:
`⊢ ∃ env, nf_eval_nf M k 5 (insertEnv env r) s` from
`hs : nf_eval_nf M k 5 (Fin.cons r [x1,w,x,t]) s` (i.e. `[r,x1,w,x,t]`, `r` at index 0).

With the clause content rendered through `kvE_fiberPosOnShift` (i.e. content `= P.existF 4
(renameNF rot5Fwd rot5Bwd s)`), the obligation becomes
`∃ env, nf_eval_nf M k 5 (insertEnv env r) (renameNF rot5Fwd rot5Bwd s)`, discharged by
`⟨[x1,w,x,t], (kvE_anchorBridge M [x1,w,x,t] r s).mpr hs⟩`. The `env` witness `[x1,w,x,t]` is
supplied by σ's own realizer. **This is the derivation both sides need**, verified sound-by-typing
against the real fold/insertEnv shapes.

**Derivation the re-dispatch performs** (side clause defs, which are re-dispatch-editable):
replace `kvE_futGapD/RayD` (and the Past mirror `kvE_pastGapD/RayD`) content from
`kvE_fiberPosOn P (kvE_fiberZoneList σ ·)` to `kvE_fiberPosOnShift P (kvE_fiberZoneList σ ·)`.
The already-green `kvE_futChainG/BuildG/DestructG` are consumed unchanged.

## Deliverable 3 — Is this an F2-style information-loss impossibility?

**No. Definitively not.** Three independent reasons:

1. **Bijective ⇒ lossless.** `renameNF f r` with `f,r` a `Fin 5` bijection is invertible
   (`renameNF_roundtrip`, :385); `renameNF_eval_iff` is an `↔`. A variable **permutation** carries
   zero information loss — every `.order`/`.pred` atom is relabeled bijectively, order relations
   preserved. There is no F2-style collapse (F2 was about *marginal/depth-0 content* forbidden at
   `k≥2`; the rename touches **no** marginal content — it is a whole-element syntactic permutation,
   G6-compliant, and `P.existF` still reads the full arity-5 element).

2. **The "mismatch" is Rabinovich's own recursion.** Cor 5.4(2) / Lemma 5.3 inductive step
   (chunk_0014:35, chunk_0015): `(∃r0)[z0<r0<z1](INF(z0,r0,z1,P1) ∧ On(P2,…,Pn, r0, z1))`. The
   freshly-quantified interior point `r0` (fold slot-0, role a) **becomes the left endpoint** of
   the recursive sub-bracket `On(…, r0, z1)` (endpoint anchor, existF index-last, role b). The
   index-0→index-4 shift **is** that re-anchoring. Sanctioned by Def 7.5 (chunk_0021) + formula
   (5.1) (Notation 5.2, chunk_0013).

3. **The existential `env` is faithful, not a weakness.** The prior Past handoff flagged that
   `P.existF`'s `env` is existentially free ("SOME 4 points, not the actual `[x1,w,x]`"). But in
   Rabinovich the sub-bracket `On(P2,…,Pn, r0, z1)` **existentially quantifies its own interior
   points** (Lemma 5.3: `∃x1…∃xn` between the endpoints). So `∃env, nf_eval (Fin.cons p env) s` =
   "sub `s` realizable with `p` as endpoint and SOME interior points" is **exactly** the source's
   existential interior quantification for the deeper rung. Pinning happens at the TOP rung (σ's
   fixed anchors); deeper rungs quantify. The content channel is faithful by construction.

Because it is not an impossibility, the **alternative "anchor-all-content-at-`t`" re-architecture
is unnecessary** (and would be a *less* faithful, harder redesign — it would collapse the per-rung
endpoint walk that Cor 5.4 requires). Do not pursue it.

## Deliverable 4 — Recommended path + GO/NO-GO

**GO** — add the shared bridge to `ExteriorFiberK.lean`, then re-dispatch both `_sound`/`_complete`.

- **What to add to `ExteriorFiberK.lean`** (the task's OWN module; additively editable — NOT one of
  the 7 frozen providers; **`PriorInterface.ExistProviders`/`P.correct` are UNCHANGED**; the 7
  frozen providers are UNCHANGED): `rot5Fwd`, `rot5Bwd`, `rot5_sec`, `rot5_sec2`, `rot5_comp`,
  `rot5_comp2`, `kvE_anchorBridge`, `kvE_fiberPosOnShift`, `kvE_fiberPosOnShift_correct`. Add
  `import Mathlib.Tactic.FinCases` to `ExteriorFiberK.lean` (needed for `fin_cases`; the two
  `rot5_comp*` proofs are the only consumers — sections use `decide`). No other imports.
- **Must the bridge be symmetric across Future/Past?** **YES (H7).** The bridge is intrinsically
  side-agnostic: the fold-slot (index 0, fresh) vs endpoint (index 4=last) convention is identical
  for Future and Past — temporal direction is carried by the zone/chain layer, not by the anchor
  index. Both `ExteriorNegationK` (Future) and `ExteriorNegationPastK` (Past) consume the **same**
  `kvE_fiberPosOnShift` / `kvE_fiberPosOnShift_correct`. Exact shared signatures are in
  Deliverable 2.
- **Re-dispatch delta** (side files, re-dispatch-owned): swap gap/ray content from
  `kvE_fiberPosOn` to `kvE_fiberPosOnShift`; then `_sound` discharges the content obligation via
  `(kvE_anchorBridge …).mpr` witnessing σ's anchors, and `_complete` reduces the content half via
  `kvE_fiberPosOnShift_correct` to the fold shape `∃env, nf_eval (Fin.cons p env) s` (which the
  9-zone reconstruction consumes; the existential `env` matches the source's interior
  quantification — Deliverable 3.3).

**Confidence**: `_sound` — **High** (bridge is necessary and sufficient; the `.mpr` discharge is
type-checked against the real `hs`/goal shapes). `_complete` — **High for the content bridge
itself** (verified); **Medium for whole-theorem closure** (the 9-zone reconstruction generalization
is the re-dispatch's proof work — the bridge removes the *only* documented blocker and the source
confirms the existential channel is the faithful target, but the reconstruction lemmas themselves
were not re-proven here).

---

## Adversarial Self-Verification (H4)

| Claim | Source / Counterexample probe | Verification Method | Confidence |
|---|---|---|---|
| `renameNF`/`renameNF_eval_iff` exist in the active (non-Boneyard) tree | grep of `Theories/` (50 hits in NfDepth0Generalized.lean); Boneyard has only `skipIdx` cross-model transport | `grep` + Read NfDepth0Generalized.lean:373-548 | High |
| They are in `ExteriorFiberK.lean`'s import graph | ExteriorFiberK→NfEFold→NfDepth0Generalized | `grep "import.*NfDepth0Generalized" NfEFold.lean` (line 2) | High |
| `renameNF_eval_iff` handles the quant layer at general `k` (not just depth-0) | succ case uses `cons_comp_liftIdx`, `ih` | Read NfDepth0Generalized.lean:486-548 | High |
| The bridge `kvE_anchorBridge` type-checks and proves | full statement + proof | **`lake build` GREEN, 1022 jobs, 0 errors** | High |
| Bridge is axiom-clean (no sorry, no extra axioms) | — | **lean_verify → `[propext, Classical.choice, Quot.sound]`** | High |
| Shared contract `kvE_fiberPosOnShift_correct` closes via bridge + `kvE_fiberPosOn_correct` | full proof | **`lake build` GREEN (same module)** | High |
| The bridge discharges the *exact* recorded `hs`→goal obligation | Future handoff lean_goal trace | `.mpr` typing: `(kvE_anchorBridge M [x1,w,x,t] r s).mpr hs : nf_eval (insertEnv [x1,w,x,t] r) (renameNF s)` — matches `∃env` witness | High |
| Index-0↔index-4 shift is faithful to Def 7.5 / Cor 5.4(2), not an artifact | Rabinovich chunk_0013/0014/0015/0021 | Read literature chunks; matched `∃r0 … On(…,r0,z1)` re-anchoring | High |
| Existential `env` is faithful (not information loss) | Lemma 5.3 `∃x1…∃xn` interior quantification | Read chunk_0014 (Lemma 5.3) | High |
| Frozen providers + PriorInterface + ExteriorFiberK untouched | — | `git diff --stat Theories/` EMPTY after scratch removal | High |

**Contradiction Log**: One contradiction found and **resolved**. Both prior handoffs assert "NO
reindex/relabel bridge exists in the active tree (grep empty)". This **conflicts** with the present
verified finding that `renameNF_eval_iff` exists and proves the bridge. Resolution (precedence:
executed lean tool result > prior agent assertion): the prior claim is a **false negative from an
incomplete grep** — they searched `reindex|relabel|permutation|skipIdx`; the decl is named
`renameNF`. The lean build + lean_verify results supersede. **No UNRESOLVED contradictions.**

**Forbidden-output check**: no "Mathlib likely has this" (repo-local lemma named + verified); no
sorry/axiom/placeholder recommended; no type-mismatch claim without a goal state; the bridge was
actually built, not asserted.

**Recommendations modified after verification**: initial hypothesis considered whether the
existential-`env` weakening might block `_complete` (a genuine second concern beyond the index
mismatch). Rabinovich Lemma 5.3 (existential interior quantification) resolved this in favor of the
bridge being faithful and sufficient as the content target — downgraded from "residual risk" to
"reconstruction proof-work only".

## Files / Anchors

- Bridge lemmas (verified, to be added by re-dispatch): `renameNF`/`renameNF_eval_iff` at
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfDepth0Generalized.lean:373,440`.
- Content channel (frozen-interface, additively extendable): `.../NfMultiAnchorBridge/ExteriorFiberK.lean:70-131`
  (`kvE_fiberPosOn`/`kvE_fiberPosOn_correct`), :237 (`kvE_fiberZoneList`).
- Fold slot: `.../Kamp/NfEFold.lean:608-613,627` (`nf_eval_efold_k`/`nf_eval_nfk_iff_efold`).
- Anchor def: `.../Kamp/NfDepth0Generalized.lean:42` (`insertEnv`).
- Interface (UNCHANGED — forbidden to edit): `.../NfMultiAnchorBridge/PriorInterface.lean:38-45`.
- Frozen k=2 template: `.../Kamp/ExteriorNegation.lean:1243` (`_sound`), `:1484` (`_complete`).
- Literature: `~/Projects/Literature/sources/rabinovich_2014/` chunk_0013 (Notation 5.2 / formula
  5.1), chunk_0014 (Lemma 5.3, Cor 5.4), chunk_0015 (Cor 5.4(2), Lemma 5.1), chunk_0021 (Def 7.5),
  chunk_0023/0024 (Def 7.13 / Lemma 7.10 / 7.14, `(z0,…,zk,∞)` nesting).
