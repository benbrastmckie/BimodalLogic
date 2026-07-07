# Task 321 Blocker Research — Successor-k Reformulation, Encoding, and Gate Decomposition

- **Task**: 321 — implement corrected k=2 carrier and close the correctness gate (F4 resolution)
- **Date**: 2026-07-07
- **Session**: sess_1783424133_5a7ad0_321 (orchestrator blocker-escalation fork)
- **Blockers researched**: the three machine-confirmed Phase-2 findings (A: general-k `σ.2`
  unrealizable; B: `pointTypes`/`segmentTypes` encoding under-specified; C: no k≥2 gate precedent)
- **Machine checks**: 6 standalone probes run via `lean_run_code` against the green module
  (imports `Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge`); final consolidated run:
  **success, zero diagnostics**. All probe code scratch-only (never written to any project file).

---

## 1. Root cause per blocker

**A (σ.2 at general k).** `NormalForm` is a `def` by recursion on depth
(`NormalForm.lean:134-136`): `| 0, n => AtomKind sig n → Bool` and
`| k+1, n => (AtomKind sig n → Bool) × (NormalForm sig k (n+1) → Bool)`. A projection `.2`
elaborates only when the depth index is a *syntactic successor*, because only then does the type
reduce to a `Prod`. This is not a defect of the design — it is the same constraint the landed
codebase already navigates: `NormalForm.quant_assgn` (`NormalForm.lean:157-159`) takes
`nf : NormalForm sig (k+1) n` (successor in the type index), and `NormalForm.atom_assgn`
(`NormalForm.lean:151-154`) handles all depths only by pattern-matching `{k : Nat} → …` with
separate `0` and `_+1` arms. Task-320 §5(1) wrote the signature at bare `k` and is unrealizable
*as written*; the fix is a parameterization shift, not new machinery (§2/Q1).

**B (encoding under-specified).** §5(1) named the intent ("σ's inner-witness structure as bracket
witnesses … from σ.2") but not the term. The codebase, however, already contains the *forced*
encoding pattern: the landed `bracketEndChar_k1v` (`NfMultiAnchorBridge.lean:1940`) is precisely
"read a successor-depth NF's quantifier layer as per-zone fold bits, route interior-zone positive
bits to bracket witness slots, exterior-zone bits to endpoint Since/Until literals, and negative
bits to segment exclusion conjuncts." The sub-bracket is this same pattern applied one level in
(arity 4 instead of 3), with the fold-bit read supplied by the engine already cited for exactly
this purpose at the k=2 instance: `nf_eval_depth1_fold_iff` (`NfMultiAnchorBridge.lean:5187`)
decomposes `σ.2` at `n = 4` into bits over `(ZoneSpec 4 × NormalForm sig 0 1)` via
`nf0_assemble` (`NfEFold.lean:180`). See §2/Q2 for the exact term shape (machine-checked).

**C (no k≥2 gate precedent).** Confirmed as stated; not a formulation problem but a proof-effort
problem. The realistic decomposition and scope recommendation are in §2/Q3.

---

## 2. Answers to the research questions

### Q1 — the correct k-matching formulation: successor-parameterize the whole kvE2 layer at `j+1`

**Recommendation (machine-checked GREEN): shift the provider-depth parameter from `k` to `j+1`.**
Define the entire corrected layer for providers at depth `j+1` (`j : Nat` free), so that:

- the carrier is `BracketEndCharCarrierV sig (j+1+1)` — i.e. carrier depth `j+2`, which serves
  **exactly the k ≥ 2 band** the enriched carrier was always documented to serve (depth-alignment
  note at `NfMultiAnchorBridge.lean:5144-5148`: "depth 0 stays `bracketEndChar_k0`, depth 1 stays
  the landed k1v instance … this definition serves k ≥ 2");
- `qnf : NormalForm sig (j+2) 3` is a literal successor, so `qnf.1`/`qnf.2` project exactly as in
  the landed `bracketEndChar_kvE'` (:5510-5517);
- every sub has type `σ : NormalForm sig (j+1) 4` — a literal successor — so `σ.2 :
  NormalForm sig j 5 → Bool` projects directly (or via the named destructor
  `NormalForm.quant_assgn σ`, identical value).

**Machine checks (all elaborate, zero diagnostics):**

```lean
-- (1) the σ.2 read at general successor parameterization
noncomputable def scratch_subFoldBits {sig} {j : Nat}
    (σ : NormalForm sig (j + 1) 4) : NormalForm sig j 5 → Bool := σ.2
-- (1b) same via the named landed destructor
  … := NormalForm.quant_assgn σ
-- (3) the successor-parameterized carrier header, body reading σ.2 of each sub
noncomputable def scratch_kvE2_header … {j : Nat}
    (P : ExistProviders sig atomMap (j + 1)) :
    BracketEndCharCarrierV sig (j + 1 + 1) := fun qnf => …  -- reads σ.2, builds VVecEA2
-- (4) at j = 0 this instantiates to the EXACT landed gate signature
--     (P : ExistProviders sig atomMap 1, qnf : NormalForm sig 2 3), closing by rfl —
--     the same shape as bracketEndChar_kvE'_two_eq (:5523)
```

**Rejected alternatives.** (i) Pattern-matching the body on `k` (`| 0 | k+1` à la
`NormalForm.atom_assgn`) works but introduces a dead depth-0 arm the enriched carrier never
serves — pointless complexity. (ii) Keeping the body at bare `k` and specializing only
`kvE_subBracket` to `(k+1)` fails: the body's subs are `NormalForm sig k 4` and cannot be handed
to a successor-only function without the same shift. The `j+1` shift is the minimal, landed-idiom
fix, and the depth-alignment note shows the k-band it serves was always `k ≥ 2`.

**Naming note for the v2 plan**: since new code is appended to `NfMultiAnchorBridge.lean` (same
module), it CAN reference the `private` helpers (`kvE'_body`, `kvE_pinDisjunct`,
`kvE_exclConj`, `bracketFromLists`) directly — `private` in Lean 4 is module-scoped. The "retain
non-joint 13.2 channels verbatim" requirement is therefore implementable by local reuse or
restatement inside the same file; no visibility obstacle.

### Q2 — the encoding forced by literature + landed machinery: the k1v pattern one level in

The sub-level fold bits are (machine-checked, probe 2):

```lean
let bits : ZoneSpec 4 → NormalForm sig 0 1 → Bool :=
  fun zs χ => σ.2 (nf0_assemble zs χ σ.1)      -- gate instance j = 0
```

This is the `nf_eval_depth1_fold_iff` (:5187) decomposition at `n = 4` — semantically:
`bits zs χ = true` iff σ demands an inner witness `v` in zone `zs` (relative to σ's own env
`[u, w, x, t]`) of depth-0 monadic type `χ`. (At general `j`, the same read is
`σ.2 ∘ (assemble at depth j)`; the depth-j fold engine generalization is v2-plan work, but the
gate instance j = 0 needs only the landed `nf0_assemble`.)

**Routing of the bits, exactly as `bracketEndChar_k1v` (:1940) routes its zone bits** (this is
the Def 3.1 discipline — every chosen point pinned in the decomposition with point type and BOTH
adjacent interval types, Rabinovich md:61-74 — realized through the Def 4.1 fold, and it is what
makes the encoding *forced* rather than invented):

| Inner-zone class (of `v` rel. to `[u,w,x,t]`) | Carrier placement |
|---|---|
| Interior zones (inside `(x, t)`: e.g. `(x,u)`, `(u,w)`, `(w,t)` for a zXW sub) | **Extra bracket witness slots** adjacent to u's slot, point type `⟨charBase χ⟩` (positive bits), spliced into the outer arrangement lists |
| Point-coincidence zones (`v = x`, `= u`, `= w`, `= t`) | Conjuncts on the corresponding existing point type (u's slot gets `charK (nfk_projFresh σ)` ∧ the `v = u` bits, mirroring the landed `ptW` zAtW pattern :5463-5466) |
| Exterior zones (`v < x`, `v > t`) | Since/Until literals conjoined into `epL`/`epR` — the landed exterior-zone pattern (:5438-5448) |
| Negative bits, per interior zone | Segment **exclusion conjuncts** `(charBase χ).neg` on the refined segments — the landed `segL`/`segR` pattern (:5455-5462) one level in |

**Machine-checked skeleton (probe 5, GREEN)** — the type plumbing for the interior-zone core,
returning `Σ m, BracketFormula (m + 1)` (the `+1` guaranteed by u's own slot, which is what makes
`fChainPred` available):

```lean
noncomputable def kvE_subBracket {sig} (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula) (σ : NormalForm sig 1 4) :
    Σ m, BracketFormula (m + 1) :=
  let bits := fun zs χ => σ.2 (nf0_assemble zs χ σ.1)
  let posInner : List TemporalPred :=
    (allTypes.filter (fun χ => bits zInner χ)).map (fun χ => ⟨charBase χ⟩)
  let segExcl : TemporalPred := ⟨formula_conjList
    (allTypes.map fun χ => if bits zInner χ then Formula.top else (charBase χ).neg)⟩
  ⟨posInner.length,
    { pointTypes  := fun i => (posInner ++ [⟨charK (nfk_projFresh σ)⟩])[i.val]'…
      segmentTypes := fun _ => segExcl }⟩
```

(The full v2 construction iterates `posInner`/`segExcl` over each interior zone in order with
per-zone segment types, and folds the arrangement permutations exactly as `kvE'_body` does at
:5487-5489 — same `bracketFromLists` (:1896) slot discipline. The skeleton above establishes the
*type-level* realizability that Finding B said was missing; the zone-by-zone enumeration is
mechanical k1v-mirroring, not new design.)

**F4-counterexample discrimination is visible at the encoding level** (why this cannot re-flatten
into the refuted shape): the honest `char[14,15,10,20]` and dishonest `σ'' = char[14,16,11,20]`
share `nfk_projFresh` (σ.1-level) but differ at `σ.2` — σ'' has `bits z(u,w) χ = true` for the
predicate-free type (its `(14,16)` contains 15) while the honest sub has the whole `(u,w)`
interior empty (`(14,15) = ∅`). Under the encoding above these two subs produce sub-brackets with
*different witness-slot lists* — the carrier formulas differ, which is exactly the
discrimination the flat `charK (nfk_projFresh σ)` slot (:5467) could not provide. And every
positional fact rides a bracket witness slot / nested-Until chain (probe P3/P4), never a
single-point relative-position assertion — the litmus is preserved by construction.

**Probe 6 (GREEN)**: `bracket_implies_fChainPred` (EANegation:660) instantiates directly at the
*constructed* `kvE_subBracket …` (not just at a generic `bf`), so the P4 recovery mechanism —
honest positions read back `e`-free by evaluation point — is available for the actual
construction. This upgrades the task-320 probe from "abstract recovery lemma on generic bf"
(Finding C's caveat) to "recovery lemma applies to the concrete sub-bracket."

### Q3 — gate decomposition: staged, forward-first; keep the gate in-task with an explicit fallback split

**Honest difficulty assessment.** The landed k=1 *simple* gate consumed the ~800-line k1v proof
kit (:2028-2825) with direction templates at :2325 (soundness) and :2966 (completeness). The k=2
*enriched* gate adds: per-sub sub-bracket obligations in both directions, and the sub-chain
read-back. F1/F4 each burned a full dispatch discovering their carrier was wrong; this
construction differs in that the crux obligation is *already demonstrated closed* (probe P4 +
probe 6 here), but the reverse direction (honest realization ⇒ sub-bracket holds) is genuinely
unprobed and requires constructing `IntervalPattern.holds` witnesses (monotone enumeration,
range, point, segment conditions) from `nf_eval_nf` inner witnesses — order-theoretic work in the
Lemma 5.3 (md:137-152) style. This is a **multi-phase, plausibly multi-dispatch** effort; a
single "Phase 7: prove gate" line would repeat the plan-v1 sizing error.

**Credible staged structure for the v2 plan:**

- **Stage A — construction** (2-3 phases): `kvE_subBracket` (full zone routing per Q2 table);
  `kvE_subChain σ := (kvE_subBracket …).2.fChainPred`; `kvE2_body` (= `kvE'_body` channels with
  the flat `ptSub`/`t`-anchored `pos.map exF` joint literal replaced by the sub-bracket slot
  splice); `bracketEndChar_kvE2` at the Q1 parameterization + `two_eq` bridge (`rfl`).
- **Stage B — adversarial discrimination check** (1 phase, BEFORE the gate): machine-verify on
  `M = ℤ` that the corrected carrier separates the F4 pair — the σ''-disjunct now demands an
  inner witness in `(14,15) = ∅` and fails. This is checkable without the full gate and is the
  mandatory adversarial test; it also front-loads the highest-information failure mode.
- **Stage C — soundness direction** (1-2 phases): carrier holds ⇒ ∃w realization. Reuses
  `k1v_bracket_extract` (:2150) + the :2325 template; the per-sub positive obligation — the F4
  crux — closes via `bracket_implies_fChainPred` at the constructed sub-bracket (probe 6).
- **Stage D — completeness direction** (2-3 phases, the novel work): honest realization ⇒
  carrier holds. Fold `nf_eval_depth1_fold_iff` at `n = 4` to extract inner witnesses, build the
  sub-bracket's `IntervalPattern.holds` data, then the arrangement disjunct as in the :2966
  template. Highest-risk stage; phase-per-lemma, commit-per-green.

**Scope recommendation.** Keep the gate inside task 321 (its GO verdict is the task's stated
deliverable and prerequisite for 309 Phase 13.4/14), but with the staged structure above and an
**explicit pre-authorized fallback**: if Stage D hits a genuine obstruction (not mere effort),
land Stages A-C + the Stage-B discrimination record as this task's deliverable and spawn the
completeness direction as its own task — that outcome is a *partial GO with recorded progress*,
not an F5 defect. Do not pre-spawn; the decision point is a Stage-D blocker, if any.

---

## 3. Amended design spec (drop-in for the v2 plan)

All names/signatures below elaborate against the green module (probes 1-6) except where marked
(v2-work = mechanical completion in the stated pattern, no open design question).

```lean
-- 1. Sub-level fold bits (gate instance; general-j lift is Stage-A v2 work)
--    bits σ zs χ = true ↔ σ demands inner witness in zone zs of type χ
--    [machine-checked: probe 2]
fun zs χ => σ.2 (nf0_assemble zs χ σ.1)        -- σ : NormalForm sig 1 4

-- 2. kvE_subBracket [skeleton machine-checked: probe 5; full zone routing per Q2 table]
noncomputable def kvE_subBracket {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4) : Σ m, BracketFormula (m + 1)

-- 3. kvE_subChain [fChainPred available by the (m+1) shape; probe 6]
noncomputable def kvE_subChain … (σ : NormalForm sig 1 4) : TemporalPred :=
  (kvE_subBracket charBase charK σ).2.fChainPred

-- 4. kvE2_body: kvE'_body (same-module private reuse is legal) with the joint
--    channel replaced by the sub-bracket slot splice; non-joint channels verbatim.
--    Successor parameterization per Q1:
private noncomputable def kvE2_body {sig : MonadicSignature} {j : Nat}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig (j+1) 1 → Formula)
    (r : NormalForm sig 0 3)
    (q : NormalForm sig (j+1) 4 → Bool) : VVecEA2

-- 5. Corrected carrier [header machine-checked: probes 3-4]
noncomputable def bracketEndChar_kvE2 {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {j : Nat} (P : ExistProviders sig atomMap (j + 1)) :
    BracketEndCharCarrierV sig (j + 1 + 1)

-- 6. Gate-instance bridge (j = 0 ⇒ P : ExistProviders sig atomMap 1,
--    qnf : NormalForm sig 2 3; rfl) [machine-checked: probe 4 analog]
theorem bracketEndChar_kvE2_two_eq …
```

Note the corrected carrier drops the `exF`/`P.existF 3` parameter from the joint path entirely
(design spec §5's replacement, now made literal): the sub's joint content rides the sub-bracket
slots, not any provider literal, so no `e`-rebinding site exists on the joint path. `P.existF 0`
(unary `charK` channel) is retained.

## 4. Constraint compliance

Q1/Q2 formulation stays inside all binding constraints: additive same-file appends only (no
landed-asset edit); anchor set stays `{x, t}` with all new content as bracket *witnesses* between
the fixed endpoints (G4/G6-as-amended); no provider-side pinning — the provider disappears from
the joint path rather than being pinned (Amendment F3); no `EANegation :1090/:1249` consumption
(probe 6 uses only the forward stack's `bracket_implies_fChainPred`); segments carry real
exclusion conjuncts, never top (G3); chain steps are the landed cited lemmas (G5). All probe code
in this research ran via `lean_run_code` snapshots only — zero project-file writes; the module
remains byte-identical.
