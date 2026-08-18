# Source Transcription Record

Task: repair 6 substantive FIX directives in `typst/FormalFoundations.typ`, transcribed from
`/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (4351 lines as of this
read — line numbers have drifted further from the 4174-line count recorded in the plan and
research report; every anchor below was re-grepped by `\label{...}` against the current file
rather than trusted from either prior document).

## Re-anchored FIX-tag map (typ file, re-grepped)

| FIX tag | Current line | Anchor text |
|---|---|---|
| `:244` Extension | 260 | `FIX: this proof is inadequate...` |
| `:267` Task Topology | 282 | `FIX: this needs to be expanded to be easier to read...` |
| `:353` S5 | 375 | `FIX: indent the axioms and formalize all of them...` |
| `:362` BX | 384 | `FIX: this is unreadable and needs to be expanded...` |
| `:369` Proof systems remainder | 391 | `FIX: everything in the remainder of this section...` |
| `:393` intro | 417 | `FIX: some introduction would be good...` |

`grep -c "FIX:" typst/FormalFoundations.typ` = 6 (confirmed). No other FIX tags remain.

## Re-anchored tex `\label` map (re-grepped, current possible_worlds.tex)

| Key | tex line (current) | plan's cited line (stale) |
|---|---|---|
| `sub:Logic` | 1155 | 1148-1172 |
| `sub:Extension` | 1236 | 1244-1255 |
| `def:task-topology` | 2772 | 2633-2643 |
| `def:constraints` | 2895 | (2749-2867 range) |
| `lem:nesting` | 2899 | " |
| `lem:nonempty` | 2915 | " |
| `lem:constraint` | 2928 | " |
| `lem:admissible` | 2945 | " (lem:fibers already merged into this in current paper, per its own `% CHANGE` comment) |
| `lem:step` | 2959 | " |
| `cor:spherical-finite` | 2973 | " |
| `thm:extension` | 2985 | " |
| `def:derivability` | 3819 | 3602-3604 |
| `def:S5` | 4017 | 3799-3812 |
| `def:BX` | 4035 | 3817-3861 |
| `def:TMplus-f` | 4084 | 3866-3940 |
| `def:TMplus-d` | 4104 | " |
| `def:TMplus-c` | 4121 | " |
| `def:TMplus` | 4144 | " |

Note: `lem:fibers` as a standalone label no longer exists in the source paper — a `% CHANGE`
comment at the `lem:admissible` definition (tex:2942-2943) records that the paper authors already
merged the standalone fiber-membership lemma into `lem:admissible`'s proof, "since the
fiber-membership lemma was cited only by the lem:admissible proof." This is consistent with (and
independently confirms) the plan's own condensation decision folding `lem:fibers` into
Admissibility.

## Extension proof ladder (`:244`)

**`def:constraints`** (tex:2895-2896):
> For a partial history $\tau : X \to W$ over a frame $\F = \tuple{W, \D, \Rightarrow}$ and
> duration $z \in D \setminus X$, the *constraints on $z$* are the segments
> $[\tau(t), \tau(s)]_{z-t}^{s-z}$ for times $t,s \in X$ where $t < z < s$ when both $t,s \in X$,
> and the fibers $\fib{\tau(t), z - t}$ for $t \in X$ otherwise.

Typst: `#definition("Constraints")[For a partial history $tau : X arrow.r #worldstate$ over a
frame $#taskframe = (#worldstate, #Dur, arrow.r.double.long)$ and duration $z in D without X$,
the *constraints on $z$* are the segments $[tau(t), tau(s)]_(z-t)^(s-z)$ for times $t, s in X$
where $t < z < s$ when both $t, s in X$, and the fibers $"Fib"(tau(t), z-t)$ for $t in X$
otherwise.]`

**`lem:nesting`** (tex:2899-2900, proof tex:2903-2907) — folded into Directedness's proof:
> the fibers $\fib{\tau(t'), z - t'} \subseteq \fib{\tau(t), z - t}$ nest for all times
> $t \leq t' < z$ in $X$ and symmetrically for all times $z < t' \leq t$ in $X$, while the
> segments $[\tau(t'), \tau(s')]_{z - t'}^{s' - z} \subseteq [\tau(t), \tau(s)]_{z - t}^{s - z}$
> nest for all times $t \leq t' < z < s' \leq s$ in $X$.
Proof: nearer-to-$z$ fibers compose (via Compositionality) into farther ones on each side;
segments nest factorwise from the two fiber inclusions.

**`lem:nonempty`** (tex:2915-2916, proof tex:2919-2921) — folded into Directedness's proof:
> every constraint imposed on $z$ is nonempty.
Proof: a fiber is nonempty by Seriality; a segment is nonempty by Compositionality applied to
$\tau(t) \Rightarrow_{s-t} \tau(s)$ (since $\tau$ is a partial history), splitting the duration at
$z$.

**`lem:constraint`** (tex:2928-2929, proof tex:2932-2938) — this is "Directedness":
> the constraints imposed on $z$ form a directed family of nonempty sets.
Proof: nonempty by `lem:nonempty`; directed by splitting $X$ into $A := \{t \in X : t<z\}$ and
$C := \{s \in X : s>z\}$ and taking $t'' = \max(t,t')$, $s''=\min(s,s')$ (segments) or the
nearer-side fiber (fibers), both via `lem:nesting`.

**`lem:admissible`** (tex:2945-2946, proof tex:2949-2956) — this is "Admissibility" (fiber-lemma
already merged in by the paper itself):
> the function $\tau \cup \{\langle z,u\rangle\}$ is a partial history on $X \cup \{z\}$ just in
> case $u$ belongs to every member of the constraints imposed on $z$.
Proof: the instance at $z$ itself is the zero loop $u \Rightarrow_0 u$ (Nullity); reduces to $u$
lying in every fiber $\fib{\tau(t),z-t}$; when assignments lie on one side this *is* the
constraint set; when they flank $z$, constraints are segments = fiber intersections, so the
biconditional splits factorwise.

**`lem:step`** (tex:2959-2960, proof tex:2963-2967) — this is "Step":
> Every partial history $\tau : X \to W$ ... extends to a partial history on $X \cup \{z\}$ for
> any duration $z \in D$.
Proof: if $z \in X$ trivial; else constraints form a directed family of nonempty fibers/segments
(`lem:constraint`), *Spherical* gives $u$ in every member, and `lem:admissible` makes
$\tau \cup \{\langle z,u\rangle\}$ a partial history. Closing remark: when the family has a
$\subseteq$-least member — as nesting (`lem:nesting`) provides whenever $X$ has a nearest
assignment to $z$ on each occupied side — *Spherical* is not needed.

**`cor:spherical-finite`** (tex:2973-2974, proof tex:2977-2981):
> Every frame with finite $W$ satisfies *Spherical*, choice-free.
Already covered at footnote level in the live document (line 276 footnote); per plan instruction,
leave at footnote level, do not duplicate as a corollary block.

**`thm:extension`** proof (tex:2985-2986, proof tex:2999-3004) — four steps:
> The partial histories extending $\tau$ are partially ordered by extension, and every chain among
> them is bounded above by its union, which restricts on any pair of times to a single member of
> the chain and so is itself a partial history. By Zorn's lemma, there is a maximal partial
> history $\sigma : T \to W$ extending $\tau$. If $T \neq D$, then $\sigma$ extends to a partial
> history on $T \cup \{z\}$ for any $z \in D \setminus T$ by the Step Lemma, contradicting
> maximality. Thus $T = D$, whence $\sigma \in H_\F$ is a total world history extending $\tau$.

## Task Topology (`:267`)

`def:task-topology` (tex:2772-2780), six sub-items in the paper:
- **Basic Opens**: $B_\F := \{(w)_x : w \in W \text{ and } x \in D \text{ with } x>0\}$
- **Topology**: $\mathcal{T}_\F := \langle W, \mathcal{O}_\F \rangle$ where $\mathcal{O}_\F$ closes
  $B_\F$ under arbitrary union and finite intersection
- **Discrete**: a topology is discrete iff every subset of $W$ is open — **omitted per plan**
  (unconsumed; sole consumer `app:topology-nondiscrete` is commented out in the paper)
- **Closure**: $\overline{S} := \{w \in W : O \cap S \neq \emptyset \text{ for every open }
  O \in \mathcal{T}_\F \text{ where } w \in O\}$
- **T1**: $\overline{\{w\}} = \{w\}$ for all $w$
- **R0**: $w \in \overline{\{u\}}$ iff $u \in \overline{\{w\}}$ for all $w,u$

## S5 (`:353`)

`def:S5` (tex:4017-4030), 5 keys: MK (`$square.stroked(phi.alt arrow.r psi) arrow.r
(square.stroked phi.alt arrow.r square.stroked psi)$`), MT (`$square.stroked phi.alt arrow.r
phi.alt$`), M5 (`$diamond.stroked square.stroked phi.alt arrow.r square.stroked phi.alt$`), MP
(rule: $\varphi, \varphi\to\psi \vdash \psi$), MN (metarule: if $\vdash\varphi$ then
$\vdash\Box\varphi$).

## BX (`:362`)

`def:BX` (tex:4035-4079), 17 keys in the paper's four groups (2+3+8+4):

- Preamble: $\varphi_{\langle S|U\rangle}$ = result of swapping `#since`/`#until` in $\varphi$.
- **Rules** (2): TN (if $\vdash\varphi$ then $\vdash G\varphi$); TD (if $\vdash\varphi$ then
  $\vdash \varphi_{\langle S|U\rangle}$).
- **Seriality/linearity/connectedness** (3): TB ($F\top$); TL ($(F\varphi \land F\psi) \to
  [F(\varphi\land\psi) \lor F(\varphi \land F\psi) \lor F(F\varphi \land \psi)]$); CN
  ($[(\varphi U \psi)\land(\chi U \theta)] \to [(\varphi\land\chi)U(\psi\land\theta) \lor
  (\varphi\land\chi)U(\psi\land\chi) \lor (\varphi\land\chi)U(\varphi\land\theta)]$).
- **Primary Since/Until** (8): TA ($\varphi \to GP\varphi$); UE ($(\varphi U \psi) \to F\psi$); UT
  ($F\varphi \to (\top U \varphi)$); UI ($\varphi U(\varphi\land(\varphi U\psi)) \to \varphi
  U\psi$); UC ($G(\varphi\to\psi) \to ((\chi U\varphi)\to(\chi U\psi))$); UF ($(\varphi U\psi) \to
  (\varphi\land(\varphi U\psi))U\psi$); UG ($G(\varphi\to\chi) \to ((\varphi U\psi)\to(\chi
  U\psi))$); SU ($\theta\land(\varphi U\psi) \to \varphi U(\psi\land(\varphi S\theta))$).
- **Uniformity** (4, vacuous unless discrete): NP ($\mathrm{Next}\top \to \mathrm{Prev}\top$); NF
  ($\mathrm{Next}\top \to F\,\mathrm{Next}\top$); NA ($\mathrm{Next}\top \to P\,\mathrm{Next}\top$);
  NB ($\mathrm{Next}\top \to \Box\,\mathrm{Next}\top$).
- Closing: BX is the smallest extension of CPL closed under all instances of the above; past/since
  direction of each axiom follows from future/until direction by TD (already a footnote in the live
  doc — reconcile so stated once).

Glyph mapping used throughout (normative, from research Findings 3 / plan): `\Box`→
`square.stroked`, `\Diamond`→`diamond.stroked`, `\Future`/`G` (universal future)→`#allfuture`,
`\future`/`F` (existential future)→`#somefuture`, `\Past`/`H` (universal past)→`#allpast`,
`\past`/`P` (existential past)→`#somepast`, `\until`→`#until`, `\since`→`#since`, `\Next`→`#Nxt`,
`\Previous`→`#Prev`, `\always`→`#always`, `\sometimes`→`#sometimes`.

## BL+ level: TM+, BX_f, BX_d, BX_c (`:369` part 1)

`def:TMplus` (tex:4144-4149): TM+ = smallest extension of S5 and BX including MF:
$\Box\varphi \to \Box G\varphi$. TM+_f/d/c extend TM+ with the axioms distinguishing BX_f/d/c.

`def:TMplus-f` (tex:4084-4096): BX_f (*Discrete Burgess–Xu Tense Logic*) = BX + UZ
($F\varphi \to (\neg\varphi U \varphi)$), Z1 ($G(G\varphi\to\varphi) \to (FG\varphi \to
G\varphi)$). Glosses: UZ = nearest future $\varphi$-witness with $\neg\varphi$ throughout the
intervening interval; Z1 = backward induction, characteristic of successor-Archimedean frames.

`def:TMplus-d` (tex:4104-4111): BX_d (*Dense Burgess–Xu Tense Logic*) = BX + DN
($GG\varphi \to G\varphi$), NN ($\neg\mathrm{Next}\top$). DN coincides with TM's DN; NN specific
to BL+ level.

`def:TMplus-c` (tex:4121-4141): BX_c (*Complete Burgess–Xu Tense Logic*) = BX + Prior-U, Sep, with
abbreviations $K^+\varphi := \neg(\neg\varphi U \top)$ ("recurs arbitrarily soon in the future"),
$K^-\varphi := \neg(\neg\varphi S \top)$ ("recurred arbitrarily recently in the past") defined
first. Prior-U ($(\varphi U\top)\land F\neg\varphi \to \varphi U(\neg\varphi \lor K^+\neg\varphi)$,
future/until direction only, since direction follows by TD). Sep ($K^+\varphi \land
\neg K^+(\varphi\land(\neg\varphi U\varphi)) \to K^+(K^+\varphi \land K^-\varphi)$). CO
($\always(P\varphi \to F P\varphi) \to (P\varphi \to F\varphi)$) is stated as a **derived
theorem** of BX_c from Prior-U and the base BX axioms — not a further axiom. Confirms **Decision
3**: only Prior-U and Sep are postulated ("Reynolds triple" language in the current typ table
naming "Prior-S" is a transcription error — no such axiom exists; the table must name Prior-U and
Sep only).

## BL level: TM, TM_f/d/c/dc, Derivability (`:369` part 2)

`sub:Logic` (tex:1155-1172): TM = smallest extension of CPL closed under: rules MP
($\varphi,\varphi\to\psi \vdash \psi$), MN (if $\vdash\varphi$ then $\vdash\Box\varphi$); modal
axioms MK, MT, M5 (as in S5 above); interaction axiom MF ($\Box\varphi\to\Box F\varphi$); rule TD
(if $\vdash\varphi$ then $\vdash\varphi_{\langle P|F\rangle}$, swapping `#allpast`/`#allfuture`);
temporal axioms TK ($G(\varphi\to\psi)\to(G\varphi\to G\psi)$), T4 ($G\varphi\to GG\varphi$), TB
($F\top$), TA ($\varphi\to GP\varphi$), TL ($(F\varphi\land F\psi) \to [F(F\varphi\land\psi)
\lor F(\varphi\land\psi) \lor F(\varphi\land F\psi)]$ — **note**: TM's TL lists the same three
disjuncts as BX's TL but in a different order; this is the paper's own presentation, not a
discrepancy to normalize, per plan instruction).

Count: 3 rules (MP, MN, TD) + 9 axioms (MK, MT, M5, MF, TK, T4, TB, TA, TL).

`sub:Extension` (tex:1236-1255): frame constraints Discrete/Dense/Complete (already stated
elsewhere in the typ doc as `#definition("Frame Properties")`) correspond to axioms DF
($(P\varphi\land\varphi\land F\top) \to FP\varphi$), DN ($GG\varphi\to G\varphi$, same statement
as BX_d's DN), CO ($\always(P\varphi\to FP\varphi) \to (P\varphi\to F\varphi)$, same statement as
BX_c's derived CO). TM_f := TM+DF, TM_d := TM+DN, TM_c := TM+CO, TM_dc := minimal extension of
TM_d and TM_c. Paper's own point: no temporal order is both discrete and dense, so TM cannot
consistently include both DF and DN.

`def:derivability` (tex:3819-3821): "The derivation relation $\vdash$ for TM is the smallest
relation closed under the axioms and rules for TM as presented in §sub:Logic." — i.e. closed
under MP, MN, TD, MK, MT, M5, MF, TK, T4, TB, TA, TL.

## `:393` intro — no tex anchor (derived from typ document's own §"Completeness and Decidability")

Five topics the section covers (confirmed by end-to-end read, typ:415-570): (1) Soundness for TM
and its four frame-class extensions (typ:430-438); (2) the three correspondences DF↔Discrete,
DN↔Dense, CO↔Complete (typ:444-454); (3) the perpetuity collapse of mixed modal-tense prefixes
(typ:458-468); (4) the completeness picture with BL/BL+ asymmetry — nothing positive at BL,
three machine-checked weak results at BL+, base case outstanding (typ:470-529); (5) decidability
open, with the failed uniform-FMP premise and the `Log(all) = Log(Discrete) ∩ Log(Dense)`
reduction as a live strategy, not a result (typ:539-569).

## Macro inventory check

All macros needed for the renderings above already exist and were confirmed by grep:
`#allpast`, `#allfuture`, `#somepast`, `#somefuture`, `#since`, `#until`, `#Nxt`, `#Prev`,
`#always`, `#sometimes` (`typst/notation/bimodal-notation.typ`), `#BL`, `#BLplus`
(`typst/FormalFoundations.typ:81-82`), `#items` (`typst/template.typ:128`). No new construct is
needed for any key's rendering.

## Landmark line numbers (current typ file, as of this record)

`#definition("History")`:239, `#theorem("Extension")`:255, commented Extension proof block:259-266,
`#corollary("Occurrence")`:268, Step-Lemma prose paragraph:274-277, `#definition("Task
Topology")`:281, `#theorem("Separation")`:291, `#remark[` following it:300, `#definition("Validity
and Consequence")`:356, `== Proof Systems`:372, `#definition("S5")`:374, `#definition("BX")`:383,
frame-class extensions `#figure(table(...))`:396-406, Hölder paragraph:410-413, `= Completeness
and Decidability`:415.

## Pre-edit compile baseline

`typst compile typst/FormalFoundations.typ` — exit 0. Two warnings, both pre-existing and expected:
`unknown font family: new computer modern sans` at `thmbox.typ:148` and `thmbox.typ:169`. No
`.typ` edit made in this phase.

## Count invariants (confirmed against paper)

S5 = 5 keys (MK, MT, M5, MP, MN) — confirmed. BX = 17 keys, partition 2+3+8+4 (TN,TD |
TB,TL,CN | TA,UE,UT,UI,UC,UF,UG,SU | NP,NF,NA,NB) — confirmed. BX_f = 2 (UZ, Z1) — confirmed.
BX_d = 2 (DN, NN) — confirmed. BX_c = 2 postulated (Prior-U, Sep) + 1 derived (CO) — confirmed.
TM (BL level) = 3 rules (MP, MN, TD) + 9 axioms (MK, MT, M5, MF, TK, T4, TB, TA, TL) — confirmed.
Task Topology = 5 transcribed sub-items (Basic Opens, Topology, Closure, T1, R0; Discrete
omitted) — confirmed.
