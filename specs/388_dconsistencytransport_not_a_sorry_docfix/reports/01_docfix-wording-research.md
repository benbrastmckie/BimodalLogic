# Research Report: DConsistencyTransport "not a sorry" Docstring Fix (Task 388)

## Metadata
- Task: 388 dconsistencytransport_not_a_sorry_docfix
- Type: lean4 (comment-only fix)
- Session: sess_1784905408_b56b5c
- Agent: lean-research-hard-agent
- Reference grounding tier: Tier 3 (implementation-backed — sibling-file convention, no literature source)

## Summary

Both target docstrings in
`Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/DConsistencyTransport.lean`
falsely claim the interior case is "sorry'd". The file contains exactly three `sorry`
tokens, all three inside the two docstrings themselves (lines 54, 55, 149); the proof
bodies contain zero. Both interior cases are discharged by `exact h_interior_d ...`
(lines 142 and 234), where `h_interior_d` is an explicit hypothesis parameter (lines 80
and 173) supplied by the caller in `SplitPoint.lean` (lines 900-907). No other docstring
in the file makes a false sorry claim.

## Findings

### 1. Current wording and exact locations

**`d_consistency_left`** — docstring spans lines 42-55, declaration at line 56. Offending
sentence (lines 53-55):

> "Boundary cases (x'=d, d=y') are fully proved.
> Interior case uses the forward strategy's response directly (sorry-free
> for boundary cases; interior case sorry'd pending Claim 1). -/"

**`d_consistency_right`** — docstring spans lines 144-149, declaration at line 150.
Offending sentence (line 149):

> "Boundary cases proved; interior case sorry'd (same blocker as left). -/"

### 2. Zero-sorry verification (bodies)

`grep -n "sorry" DConsistencyTransport.lean` output (complete):

```
54:    Interior case uses the forward strategy's response directly (sorry-free
55:    for boundary cases; interior case sorry'd pending Claim 1). -/
149:    Boundary cases proved; interior case sorry'd (same blocker as left). -/
```

All three hits are inside the two docstrings. Both theorem bodies are sorry-free.

### 3. `h_interior_d` hypothesis parameter — confirmed

- `d_consistency_left`: parameter at line 80, preceded by an inline comment (lines 76-79)
  that already states the correct story: "GHR93 Claim 1 (interior case): ... constructed
  via rank_down(h_fwd_r1) + K⁻(¬D) at the call site."
- `d_consistency_right`: parameter at line 173, inline comment at lines 170-172 (same
  construction, position 0).
- Interior-case discharge sites: line 141-142 (`-- Interior case: x' < d < y'. Delegate
  to h_interior_d.` / `exact h_interior_d hx'd hdy' a_pad ha_pad hc_last`) and lines
  233-234 (right variant, `hc_first`).
- Call-site supplier: `SplitPoint.lean:900-907` passes `h_interior_d_left` /
  `h_interior_d_right` (derived at :814 from `h_interior_d_left_from_suffices` /
  `h_interior_d_right_from_suffices`; constructions at :2663 and :3726).

### 4. Sibling-file wording convention (hypothesis-gated cases)

Note: the literal phrase "hypothesis-gated" appears NOWHERE in `Theories/` (verified by
`grep -rn "hypothesis-gated\|NOT a sorry"` — zero hits). The task directive's phrase
"interior case is hypothesis-gated (h_interior_d parameter), NOT a sorry" is the wording
to introduce; the sibling files establish the underlying convention of naming the
hypothesis parameter and its discharger, which the new wording should follow. Sentences
to imitate:

**`Kamp/NfMultiAnchorBridge/Base.lean:217-220`**:
> "correctness takes the assembled Phase-2 converter iff as a hypothesis
> (`h_exist_correct`), exactly as `nf_succ_char_formula_correct` takes
> `h_exist_correct`. Phases 4-5 supply the hooks and discharge that hypothesis via
> `nf_char2_diag_exist_tl_correct`."

**`Kamp/NfMultiAnchorBridge/Base.lean:178-180`** (hook-hypothesis framing):
> "Under the three hook-correctness hypotheses (each zone endpoint characterizes the
> coupled arity-3 evaluation at its navigated witness), the assembled formula holds
> at `t` iff ..."

**`Kamp/NfMultiAnchorBridge/CarrierK1V.lean:121`** (named-hypothesis-in-context framing):
> "with only the atom-layer hypothesis `h_atom : nf_eval_nf M 0 3 [w,x,t] qnf.1` in
> context."

Convention elements: (a) name the hypothesis parameter in backticks, (b) state what it
gates/discharges, (c) state who supplies it and how. All three elements are already
present in the file's own inline comments at lines 76-79 / 170-172, which the new
docstring wording can echo.

### 5. Recommended replacement wording

**Left** (replace lines 53-55's sentence):
> "Boundary cases (x'=d, d=y') are fully proved. The interior case is hypothesis-gated
> (discharged via the `h_interior_d` parameter, supplied at the call site via
> rank_down(h_fwd_r1) + K⁻(¬D)), NOT a sorry — this proof contains no `sorry`."

**Right** (replace line 149's sentence):
> "Boundary cases proved; the interior case is hypothesis-gated (`h_interior_d`
> parameter, same call-site construction as left), NOT a sorry — this proof contains
> no `sorry`."

Implementer may adjust phrasing but MUST keep: "hypothesis-gated", the backticked
`h_interior_d` name, and "NOT a sorry" (per task directive), and MUST NOT add
task-number references to the .lean file.

### 6. Other false sorry claims in the file

None. Per the complete grep in Finding 2, the only sorry mentions are the two docstrings
under repair (line 54's "sorry-free for boundary cases" is part of the same sentence
being rewritten in the left docstring).

### 7. Targeted build command

```
lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.DConsistencyTransport
```

(Library root is `Bimodal` with `srcDir := "Theories"` per `lakefile.lean`; the module
path drops the `Theories/` prefix.) Comment-only change, but the module still recompiles;
a green targeted build satisfies the task's verification requirement.

## Adversarial Self-Verification

### Claim Verification Table

| Claim | Source/Counterexample | Verification Method | Confidence |
|-------|------------------------|----------------------|------------|
| Both proof bodies contain zero `sorry` tokens | `grep -n "sorry"` returns only lines 54, 55, 149 — all inside docstrings | Exhaustive file grep (output quoted in Finding 2) | High |
| `h_interior_d` parameter exists in both theorems | Lines 80 and 173, read directly | Bounded Read of both signatures | High |
| Interior cases discharged via `h_interior_d`, not sorry | `exact h_interior_d ...` at lines 142 and 234 | Bounded Read of both discharge sites | High |
| "hypothesis-gated" is NOT an existing literal convention | `grep -rn "hypothesis-gated" Theories/` = zero hits | Repo-wide grep | High |
| Sibling convention = name hypothesis param + discharger | Base.lean:178-180, 217-220; CarrierK1V.lean:121 quoted verbatim | Bounded Reads of quoted regions | High |
| Callers supply `h_interior_d` at call site | SplitPoint.lean:900-907 (only non-defining file referencing `d_consistency_*`) | grep -l across Theories + targeted grep of SplitPoint.lean | High |
| Targeted build command module path | lakefile.lean: `lean_lib Bimodal`, `srcDir := "Theories"` | Read of lakefile.lean | High |

### Contradiction Log

One contradiction found and resolved: the task directive presents "hypothesis-gated ...
NOT a sorry" as "the established convention used in sibling Kamp files", but the literal
phrase appears nowhere in the repo. Resolution (direct-evidence precedence): the sibling
files establish the structural convention (named hypothesis parameter + supplier), not
the literal phrase; the phrase itself is new wording mandated by the task description.
Recommended wording (Finding 5) satisfies both — no downstream risk.

No recommendations were modified after verification.

## Tactic Survey Results

Not applicable — comment-only task; no tactics tested, no Mathlib search required
(no missing-lemma question exists; H2 formal-proof-line bar vacuously satisfied).
