
## TableauConformance

### Row 1 — line 411

```lean
/--
info: C1 p->p            CLOSED   target=CLOSED          propositional tautology
C2 p               OPEN     target=OPEN            atom is satisfiable and not valid
C3 Gp->p           OPEN     target=OPEN            G is strict: t is not in its own future
C5 K_G             CLOSED   target=CLOSED          K axiom for G
C4 Fp->FFp         OPEN     target=OPEN            no density over an arbitrary linear order
S1 F-top           CLOSED   target=CLOSED          serial_future; serialityRule creates the required successor
S2 not-G-bot       CLOSED   target=CLOSED          dual of S1
S3 Gp->Fp          CLOSED   target=CLOSED          seriality turns the universal into an existential
S4 Hp->Pp          CLOSED   target=CLOSED          past dual of S3
S5 P-top           CLOSED   target=CLOSED          serial_past
K0 Fq->F^0-top     CLOSED   target=CLOSED          F^0(top) is a theorem by iterated seriality
K1 Fq->F^1-top     CLOSED   target=CLOSED          F^1(top) is a theorem by iterated seriality
K2 Fq->F^2-top     CLOSED   target=CLOSED          F^2(top) is a theorem by iterated seriality
K3 Fq->F^3-top     CLOSED   target=CLOSED          F^3(top) is a theorem by iterated seriality
K4 Fq->F^4-top     CLOSED   target=CLOSED          F^4(top) is a theorem by iterated seriality
K5 Fq->F^5-top     CLOSED   target=CLOSED          F^5(top) is a theorem by iterated seriality
K6 Fq->F^6-top     CLOSED   target=CLOSED          F^6(top) is a theorem by iterated seriality
A Gp->GGp          CLOSED   target=CLOSED          was D1; closes now that futureOf is a transitive closure
B lin-perm         CLOSED   target=CLOSED          was D2; closes now that orderTrichotomy splits on the witness order
BX11 lin-fut       CLOSED   target=CLOSED          temp_linearity, exact axiom disjunct order
BX11' lin-past     CLOSED   target=CLOSED          temp_linearity_past, exact axiom disjunct order
BX10 U->F          CLOSED   target=CLOSED          until_F
BX10' S->P         CLOSED   target=CLOSED          since_P
BX7 lin-until      CLOSED   target=CLOSED          linear_until instance
BX7' lin-since     CLOSED   target=CLOSED          linear_since instance
-/
#eval IO.print (report .Base baseRows)
```

### Row 2 — line 441

```lean
/--
info: C1 p->p            CLOSED   target=CLOSED          propositional tautology
C2 p               OPEN     target=OPEN            atom is satisfiable and not valid
C3 Gp->p           OPEN     target=OPEN            G is strict: t is not in its own future
C5 K_G             CLOSED   target=CLOSED          K axiom for G
C4 Fp->FFp         OPEN     target=CLOSED  [DEFECT] density: a time strictly between t and the witness
S1 F-top           CLOSED   target=CLOSED          serial_future; serialityRule creates the required successor
S2 not-G-bot       CLOSED   target=CLOSED          dual of S1
S3 Gp->Fp          CLOSED   target=CLOSED          seriality turns the universal into an existential
S4 Hp->Pp          CLOSED   target=CLOSED          past dual of S3
S5 P-top           CLOSED   target=CLOSED          serial_past
K0 Fq->F^0-top     CLOSED   target=CLOSED          F^0(top) is a theorem by iterated seriality
K1 Fq->F^1-top     CLOSED   target=CLOSED          F^1(top) is a theorem by iterated seriality
K2 Fq->F^2-top     CLOSED   target=CLOSED          F^2(top) is a theorem by iterated seriality
K3 Fq->F^3-top     CLOSED   target=CLOSED          F^3(top) is a theorem by iterated seriality
K4 Fq->F^4-top     CLOSED   target=CLOSED          F^4(top) is a theorem by iterated seriality
K5 Fq->F^5-top     CLOSED   target=CLOSED          F^5(top) is a theorem by iterated seriality
K6 Fq->F^6-top     CLOSED   target=CLOSED          F^6(top) is a theorem by iterated seriality
A Gp->GGp          CLOSED   target=CLOSED          was D1; closes now that futureOf is a transitive closure
B lin-perm         CLOSED   target=CLOSED          was D2; closes now that orderTrichotomy splits on the witness order
BX11 lin-fut       CLOSED   target=CLOSED          temp_linearity, exact axiom disjunct order
BX11' lin-past     CLOSED   target=CLOSED          temp_linearity_past, exact axiom disjunct order
BX10 U->F          CLOSED   target=CLOSED          until_F
BX10' S->P         CLOSED   target=CLOSED          since_P
BX7 lin-until      CLOSED   target=CLOSED          linear_until instance
BX7' lin-since     CLOSED   target=CLOSED          linear_since instance
-/
#eval IO.print (report .Dense denseRows)
```

### Row 3 — line 473

```lean
/--
info: C1 p->p            CLOSED   target=CLOSED          propositional tautology
C2 p               OPEN     target=OPEN            atom is satisfiable and not valid
C3 Gp->p           OPEN     target=OPEN            G is strict: t is not in its own future
C5 K_G             CLOSED   target=CLOSED          K axiom for G
C4 Fp->FFp         OPEN     target=OPEN            ZZ is not dense: no time strictly between t and t+1
S1 F-top           CLOSED   target=CLOSED          serial_future; serialityRule creates the required successor
S2 not-G-bot       CLOSED   target=CLOSED          dual of S1
S3 Gp->Fp          CLOSED   target=CLOSED          seriality turns the universal into an existential
S4 Hp->Pp          CLOSED   target=CLOSED          past dual of S3
S5 P-top           CLOSED   target=CLOSED          serial_past
K0 Fq->F^0-top     CLOSED   target=CLOSED          F^0(top) is a theorem by iterated seriality
K1 Fq->F^1-top     CLOSED   target=CLOSED          F^1(top) is a theorem by iterated seriality
K2 Fq->F^2-top     CLOSED   target=CLOSED          F^2(top) is a theorem by iterated seriality
K3 Fq->F^3-top     CLOSED   target=CLOSED          F^3(top) is a theorem by iterated seriality
K4 Fq->F^4-top     CLOSED   target=CLOSED          F^4(top) is a theorem by iterated seriality
K5 Fq->F^5-top     CLOSED   target=CLOSED          F^5(top) is a theorem by iterated seriality
K6 Fq->F^6-top     CLOSED   target=CLOSED          F^6(top) is a theorem by iterated seriality
A Gp->GGp          CLOSED   target=CLOSED          was D1; closes now that futureOf is a transitive closure
B lin-perm         CLOSED   target=CLOSED          was D2; closes now that orderTrichotomy splits on the witness order
BX11 lin-fut       CLOSED   target=CLOSED          temp_linearity, exact axiom disjunct order
BX11' lin-past     CLOSED   target=CLOSED          temp_linearity_past, exact axiom disjunct order
BX10 U->F          CLOSED   target=CLOSED          until_F
BX10' S->P         CLOSED   target=CLOSED          since_P
BX7 lin-until      CLOSED   target=CLOSED          linear_until instance
BX7' lin-since     CLOSED   target=CLOSED          linear_since instance
Z1 priorUZ         CLOSED   target=CLOSED          prior_UZ: least future witness exists on the integers
Z2 priorSZ         CLOSED   target=CLOSED          prior_SZ: greatest past witness exists on the integers
-/
#eval IO.print (report .Discrete discreteRows)
```

### Row 4 — line 506

```lean
/--
info: C1 p->p            CLOSED   target=CLOSED          propositional tautology
C2 p               OPEN     target=OPEN            atom is satisfiable and not valid
C3 Gp->p           OPEN     target=OPEN            G is strict: t is not in its own future
C5 K_G             CLOSED   target=CLOSED          K axiom for G
C4 Fp->FFp         OPEN     target=CLOSED  [DEFECT] ValidDedekindDense includes density
S1 F-top           CLOSED   target=CLOSED          serial_future; serialityRule creates the required successor
S2 not-G-bot       CLOSED   target=CLOSED          dual of S1
S3 Gp->Fp          CLOSED   target=CLOSED          seriality turns the universal into an existential
S4 Hp->Pp          CLOSED   target=CLOSED          past dual of S3
S5 P-top           CLOSED   target=CLOSED          serial_past
K0 Fq->F^0-top     CLOSED   target=CLOSED          F^0(top) is a theorem by iterated seriality
K1 Fq->F^1-top     CLOSED   target=CLOSED          F^1(top) is a theorem by iterated seriality
K2 Fq->F^2-top     CLOSED   target=CLOSED          F^2(top) is a theorem by iterated seriality
K3 Fq->F^3-top     CLOSED   target=CLOSED          F^3(top) is a theorem by iterated seriality
K4 Fq->F^4-top     CLOSED   target=CLOSED          F^4(top) is a theorem by iterated seriality
K5 Fq->F^5-top     CLOSED   target=CLOSED          F^5(top) is a theorem by iterated seriality
K6 Fq->F^6-top     CLOSED   target=CLOSED          F^6(top) is a theorem by iterated seriality
A Gp->GGp          CLOSED   target=CLOSED          was D1; closes now that futureOf is a transitive closure
B lin-perm         CLOSED   target=CLOSED          was D2; closes now that orderTrichotomy splits on the witness order
BX11 lin-fut       CLOSED   target=CLOSED          temp_linearity, exact axiom disjunct order
BX11' lin-past     CLOSED   target=CLOSED          temp_linearity_past, exact axiom disjunct order
BX10 U->F          CLOSED   target=CLOSED          until_F
BX10' S->P         CLOSED   target=CLOSED          since_P
BX7 lin-until      CLOSED   target=CLOSED          linear_until instance
BX7' lin-since     CLOSED   target=CLOSED          linear_since instance
R1 prior-U-gap     CLOSED   target=CLOSED          prior_U_gap; discharged by the priorUGap rule
R2 prior-S-gap     CLOSED   target=CLOSED          prior_S_gap; discharged by the priorSGap rule
R3 sep             CLOSED   target=CLOSED          sep; discharged by the sepRule rule
-/
#eval IO.print (report .Dedekind dedekindRows)
```

### Row 5 — line 528

```lean
/-- info: [1, 2] -/
#eval ordA.futureOf 0
```

### Row 6 — line 533

```lean
/-- info: [2] -/
#eval ordA.futureOf 1
```

### Row 7 — line 539

```lean
/-- info: [1, 0] -/
#eval ordA.pastOf 2
```

### Row 8 — line 545

```lean
/-- info: true -/
#eval ordA.futureOf 2 == ([] : List TimeIndex) && ordA.pastOf 0 == ([] : List TimeIndex)
```

### Row 9 — line 551

```lean
/-- info: true -/
#eval (({ constraints := [(0, 1), (1, 0)] } : TimeOrdering).futureOf 0).length == 2
```

### Row 10 — line 559

```lean
/-- info: "persistent -> times [1, 2]" -/
#eval
  let sf := SignedFormula.neg (F (nt p)) { world := 0, time := 0 }
  match (applyRule .someFutureNeg sf [] ordA).1 with
  | .persistent fs => s!"persistent -> times {fs.map (fun g : SignedFormula => g.label.time)}"
  | .linear fs => s!"linear -> times {fs.map (fun g : SignedFormula => g.label.time)}"
  | .branching _ => "branching"
  | .branchingOrdered _ => "branchingOrdered"
  | .notApplicable => "notApplicable"
```

### Row 11 — line 594

```lean
/-- info: [0] -/
#eval ancestorTimes ordB 1
```

### Row 12 — line 600

```lean
/-- info: [] -/
#eval ancestorTimes ordB 0
```

### Row 13 — line 605

```lean
/-- info: false -/
#eval Branch.isSubsetBlocked b0 1 0
```

### Row 14 — line 611

```lean
/-- info: false -/
#eval isTemporallyBlocked b0 1 ordB EventualityTracker.empty
```

### Row 15 — line 618

```lean
/-- info: true -/
#eval isTemporallyBlocked b1 1 ordB EventualityTracker.empty
```

### Row 16 — line 627

```lean
/-- info: false -/
#eval
  let tr : EventualityTracker :=
    { pending := [{ formula := U p q, label := { world := 0, time := 1 }, isUntil := true }] }
  isTemporallyBlocked b1 1 ordB tr
```

### Row 17 — line 637

```lean
/-- info: true -/
#eval
  let tr : EventualityTracker :=
    { pending := [{ formula := U p q, label := { world := 0, time := 0 }, isUntil := true }] }
  isTemporallyBlocked b1 1 ordB tr
```

### Row 18 — line 646

```lean
/-- info: true -/
#eval
  let tr : EventualityTracker :=
    { pending :=
        [ { formula := U p q, label := { world := 0, time := 1 }, isUntil := true }
        , { formula := U p q, label := { world := 0, time := 0 }, isUntil := true } ] }
  isTemporallyBlocked b1 1 ordB tr
```

### Row 19 — line 718

```lean
/-- info: certified fc=Base saturated=true formulas=51 times=4 -/
#eval IO.print (certProbe diaP FrameClass.Base)
```

### Row 20 — line 725

```lean
/-- info: certified fc=Base saturated=true formulas=19 times=4 -/
#eval IO.print (certProbe (im (G p) p) FrameClass.Base)
```

### Row 21 — line 801

```lean
/-- info: total=true knownTimes=[9, 5, 3, 4, 8, 1, 6, 2, 0] constraints=[(6, 1), (9, 3), (9, 5), (8, 9), (1, 8), (6, 8), (2, 6), (3, 5), (4, 0), (0, 3), (0, 2), (0, 1)] incomparable=[] -/
#eval IO.print (orderProbe (nt (an (F (G p)) (F (nt p)))) FrameClass.Base linearityFuel)
```

### Row 22 — line 806

```lean
/-- info: total=true knownTimes=[4, 7, 9, 8, 1, 6, 2, 3, 0] constraints=[(8, 3), (9, 2), (9, 6), (9, 7), (8, 9), (1, 8), (6, 7), (2, 6), (3, 9), (4, 0), (0, 3), (0, 2), (0, 1)] incomparable=[] -/
#eval IO.print (orderProbe (nt (an (F p) (F q))) FrameClass.Base linearityFuel)
```

### Row 23 — line 811

```lean
/-- info: total=true knownTimes=[10, 3, 4, 7, 9, 8, 1, 0] constraints=[(7, 3), (7, 10), (9, 7), (8, 9), (1, 8), (3, 10), (4, 0), (0, 3), (0, 8), (0, 1)] incomparable=[] -/
#eval IO.print (orderProbe (nt (an (F (G p)) (F (G q)))) FrameClass.Base linearityFuel)
```

### Row 24 — line 816

```lean
/-- info: total=true knownTimes=[4, 7, 9, 8, 1, 6, 2, 3, 0] constraints=[(8, 3), (9, 2), (9, 6), (9, 7), (8, 9), (1, 8), (6, 7), (2, 6), (3, 9), (4, 0), (0, 3), (0, 2), (0, 1)] incomparable=[] -/
#eval IO.print (orderProbe (nt (an (F (nt p)) (F (G p)))) FrameClass.Base linearityFuel)
```

### Row 25 — line 824

```lean
/-- info: total=true knownTimes=[4, 5, 6, 8, 7, 1, 2, 3, 0] constraints=[(2, 4), (6, 4), (8, 3), (8, 5), (7, 8), (1, 7), (6, 2), (3, 5), (4, 0), (0, 3), (2, 0), (0, 1)] incomparable=[] -/
#eval IO.print (orderProbe (nt (an (F p) (P q))) FrameClass.Base)
```

### Row 26 — line 832

```lean
/-- info: total=true knownTimes=[3, 4, 5, 0, 2, 1] constraints=[(3, 0), (5, 3), (5, 0), (2, 4), (3, 1), (1, 2), (0, 1)] incomparable=[] -/
#eval IO.print (orderProbe (im (F p) (F (F p))) FrameClass.Base)
```

### Row 27 — line 838

```lean
/-- info: total=true knownTimes=[9, 7, 5, 3, 4, 8, 1, 6, 2, 0] constraints=[(6, 1), (6, 8), (6, 9), (7, 3), (7, 5), (9, 7), (8, 9), (1, 8), (6, 7), (2, 6), (3, 5), (4, 0), (0, 3), (0, 2), (0, 1)] incomparable=[] -/
#eval IO.print (orderProbe (nt (an (F (G p)) (F (nt p)))) FrameClass.Base 2000)
```

**TableauConformance: 27 rows**


## TemporalWitnessProbe

### Row 1 — line 393

```lean
/-- info: "OPEN |T|=6 gen=false check=true U[dich=false wit=true gw=true rdG=true nStr=true nCo=true rP=true rN=true] S[dich=false wit=true gw=true ruG=true nStr=true nCo=true rP=true rN=true]" -/
#eval probe (.imp (Formula.someFuture p) p)
```

### Row 2 — line 398

```lean
/-- info: "OPEN |T|=7 gen=false check=true U[dich=false wit=true gw=true rdG=true nStr=true nCo=true rP=true rN=true] S[dich=false wit=true gw=true ruG=true nStr=true nCo=true rP=true rN=true]" -/
#eval probe (.imp (Formula.somePast p) p)
```

### Row 3 — line 403

```lean
/-- info: "OPEN |T|=4 gen=false check=true U[dich=true wit=true gw=true rdG=true nStr=true nCo=true rP=true rN=true] S[dich=false wit=true gw=true ruG=true nStr=true nCo=true rP=true rN=true]" -/
#eval probe (.imp (.allFuture p) p)
```

### Row 4 — line 408

```lean
/-- info: "OPEN |T|=7 gen=false check=true U[dich=false wit=true gw=true rdG=true nStr=true nCo=true rP=true rN=true] S[dich=false wit=true gw=true ruG=true nStr=true nCo=true rP=true rN=true]" -/
#eval probe (.imp (andF (.box p) (dia q)) r)
```

### Row 5 — line 413

```lean
/-- info: "OPEN |T|=4 gen=false check=true U[dich=true wit=true gw=true rdG=true nStr=true nCo=true rP=true rN=true] S[dich=false wit=true gw=true ruG=true nStr=true nCo=true rP=true rN=true]" -/
#eval probe (.imp (andF (.box p) (.box (.imp p q))) r)
```

### Row 6 — line 418

```lean
/-- info: "OPEN |T|=6 gen=false check=true U[dich=false wit=true gw=true rdG=true nStr=true nCo=true rP=true rN=true] S[dich=false wit=true gw=true ruG=true nStr=true nCo=true rP=true rN=true]" -/
#eval probe (.imp (Formula.someFuture p) p) 200 .Dense
```

### Row 7 — line 432

```lean
/-- info: "OPEN |T|=6 gen=true check=false U[dich=false wit=true gw=false rdG=true nStr=true nCo=true rP=false rN=true] S[dich=false wit=true gw=true ruG=true nStr=true nCo=true rP=true rN=true]" -/
#eval probe (.imp (.untl p q) q)
```

### Row 8 — line 437

```lean
/-- info: "OPEN |T|=4 gen=true check=true U[dich=true wit=true gw=true rdG=true nStr=true nCo=true rP=true rN=true] S[dich=false wit=true gw=true ruG=true nStr=true nCo=true rP=true rN=true]" -/
#eval probe (.imp p (.untl p q))
```

### Row 9 — line 442

```lean
/-- info: "OPEN |T|=7 gen=true check=false U[dich=false wit=true gw=true rdG=true nStr=true nCo=true rP=true rN=true] S[dich=false wit=true gw=true ruG=true nStr=true nCo=true rP=false rN=true]" -/
#eval probe (.imp (.snce p q) q)
```

### Row 10 — line 447

```lean
/-- info: "OPEN |T|=4 gen=true check=true U[dich=false wit=true gw=true rdG=true nStr=true nCo=true rP=true rN=true] S[dich=true wit=true gw=true ruG=true nStr=true nCo=true rP=true rN=true]" -/
#eval probe (.imp p (.snce p q))
```

### Row 11 — line 454

```lean
/-- info: "STALLED" -/
#eval probe (.imp (.untl p q) (.untl q p))
```

### Row 12 — line 459

```lean
/-- info: "OPEN |T|=6 gen=true check=false U[dich=false wit=true gw=false rdG=true nStr=true nCo=true rP=false rN=true] S[dich=false wit=true gw=true ruG=true nStr=true nCo=true rP=true rN=true]" -/
#eval probe (.imp (.untl p q) q) 200 .Dense
```

### Row 13 — line 466

```lean
/-- info: "OPEN |T|=4 gen=true check=false U[dich=true wit=true gw=true rdG=false nStr=true nCo=true rP=false rN=false] S[dich=false wit=true gw=false ruG=false nStr=true nCo=true rP=false rN=true]" -/
#eval probe (.imp p (.untl p q)) 200 .Discrete
```

### Row 14 — line 508

```lean
/-- info: "A check=true uNAR=true sNAR=true" -/
#eval "A " ++ probe2 (.imp (Formula.someFuture p) p)
```

### Row 15 — line 512

```lean
/-- info: "B check=true uNAR=true sNAR=true" -/
#eval "B " ++ probe2 (.imp (Formula.somePast p) p)
```

### Row 16 — line 517

```lean
/-- info: "C check=true uNAR=false sNAR=true" -/
#eval "C " ++ probe2 (.imp (.allFuture p) p)
```

### Row 17 — line 521

```lean
/-- info: "D check=true uNAR=true sNAR=true" -/
#eval "D " ++ probe2 (.imp (andF (.box p) (dia q)) r)
```

### Row 18 — line 525

```lean
/-- info: "E check=true uNAR=true sNAR=true" -/
#eval "E " ++ probe2 (.imp (andF (.box p) (.box (.imp p q))) r)
```

### Row 19 — line 529

```lean
/-- info: "F check=true uNAR=true sNAR=true" -/
#eval "F " ++ probe2 (.imp (Formula.someFuture p) p) 200 .Dense
```

### Row 20 — line 533

```lean
/-- info: "H check=false uNAR=true sNAR=true" -/
#eval "H " ++ probe2 (.imp (.untl p q) q)
```

### Row 21 — line 539

```lean
/-- info: "I check=true uNAR=false sNAR=true" -/
#eval "I " ++ probe2 (.imp p (.untl p q))
```

### Row 22 — line 543

```lean
/-- info: "J check=false uNAR=true sNAR=true" -/
#eval "J " ++ probe2 (.imp (.snce p q) q)
```

### Row 23 — line 547

```lean
/-- info: "K check=true uNAR=true sNAR=true" -/
#eval "K " ++ probe2 (.imp p (.snce p q))
```

### Row 24 — line 617

```lean
/-- info: "A gen=false check=true uRL=true uRLs=true sRU=true sRUs=true" -/
#eval "A " ++ probe3 (.imp (Formula.someFuture p) p)
```

### Row 25 — line 621

```lean
/-- info: "B gen=false check=true uRL=true uRLs=true sRU=true sRUs=true" -/
#eval "B " ++ probe3 (.imp (Formula.somePast p) p)
```

### Row 26 — line 625

```lean
/-- info: "C gen=false check=true uRL=true uRLs=true sRU=true sRUs=true" -/
#eval "C " ++ probe3 (.imp (.allFuture p) p)
```

### Row 27 — line 629

```lean
/-- info: "D gen=false check=true uRL=true uRLs=true sRU=true sRUs=true" -/
#eval "D " ++ probe3 (.imp (andF (.box p) (dia q)) r)
```

### Row 28 — line 633

```lean
/-- info: "E gen=false check=true uRL=true uRLs=true sRU=true sRUs=true" -/
#eval "E " ++ probe3 (.imp (andF (.box p) (.box (.imp p q))) r)
```

### Row 29 — line 637

```lean
/-- info: "F gen=false check=true uRL=true uRLs=true sRU=true sRUs=true" -/
#eval "F " ++ probe3 (.imp (Formula.someFuture p) p) 200 .Dense
```

### Row 30 — line 641

```lean
/-- info: "H gen=true check=false uRL=true uRLs=true sRU=true sRUs=true" -/
#eval "H " ++ probe3 (.imp (.untl p q) q)
```

### Row 31 — line 646

```lean
/-- info: "I gen=true check=true uRL=true uRLs=true sRU=true sRUs=true" -/
#eval "I " ++ probe3 (.imp p (.untl p q))
```

### Row 32 — line 650

```lean
/-- info: "J gen=true check=false uRL=true uRLs=true sRU=true sRUs=true" -/
#eval "J " ++ probe3 (.imp (.snce p q) q)
```

### Row 33 — line 654

```lean
/-- info: "K gen=true check=true uRL=true uRLs=true sRU=true sRUs=true" -/
#eval "K " ++ probe3 (.imp p (.snce p q))
```

### Row 34 — line 658

```lean
/-- info: "M gen=true check=false uRL=true uRLs=true sRU=true sRUs=true" -/
#eval "M " ++ probe3 (.imp (.untl p q) q) 200 .Dense
```

### Row 35 — line 666

```lean
/-- info: "N gen=true check=false uRL=false uRLs=false sRU=true sRUs=true" -/
#eval "N " ++ probe3 (.imp p (.untl p q)) 200 .Discrete
```

### Row 36 — line 763

```lean
/-- info: "A gen=false check=true uGW=true [gw=true wit=true] sGW=true [gw=true wit=true] uRD=true [rdG=true] sRU=true [ruG=true]" -/
#eval "A " ++ probe4 (.imp (Formula.someFuture p) p)
```

### Row 37 — line 767

```lean
/-- info: "B gen=false check=true uGW=true [gw=true wit=true] sGW=true [gw=true wit=true] uRD=true [rdG=true] sRU=true [ruG=true]" -/
#eval "B " ++ probe4 (.imp (Formula.somePast p) p)
```

### Row 38 — line 771

```lean
/-- info: "C gen=false check=true uGW=true [gw=true wit=true] sGW=true [gw=true wit=true] uRD=true [rdG=true] sRU=true [ruG=true]" -/
#eval "C " ++ probe4 (.imp (.allFuture p) p)
```

### Row 39 — line 775

```lean
/-- info: "D gen=false check=true uGW=true [gw=true wit=true] sGW=true [gw=true wit=true] uRD=true [rdG=true] sRU=true [ruG=true]" -/
#eval "D " ++ probe4 (.imp (andF (.box p) (dia q)) r)
```

### Row 40 — line 779

```lean
/-- info: "E gen=false check=true uGW=true [gw=true wit=true] sGW=true [gw=true wit=true] uRD=true [rdG=true] sRU=true [ruG=true]" -/
#eval "E " ++ probe4 (.imp (andF (.box p) (.box (.imp p q))) r)
```

### Row 41 — line 783

```lean
/-- info: "F gen=false check=true uGW=true [gw=true wit=true] sGW=true [gw=true wit=true] uRD=true [rdG=true] sRU=true [ruG=true]" -/
#eval "F " ++ probe4 (.imp (Formula.someFuture p) p) 200 .Dense
```

### Row 42 — line 787

```lean
/-- info: "H gen=true check=false uGW=false [gw=false wit=true] sGW=true [gw=true wit=true] uRD=true [rdG=true] sRU=true [ruG=true]" -/
#eval "H " ++ probe4 (.imp (.untl p q) q)
```

### Row 43 — line 793

```lean
/-- info: "I gen=true check=true uGW=true [gw=true wit=true] sGW=true [gw=true wit=true] uRD=true [rdG=true] sRU=true [ruG=true]" -/
#eval "I " ++ probe4 (.imp p (.untl p q))
```

### Row 44 — line 797

```lean
/-- info: "J gen=true check=false uGW=true [gw=true wit=true] sGW=true [gw=true wit=true] uRD=true [rdG=true] sRU=true [ruG=true]" -/
#eval "J " ++ probe4 (.imp (.snce p q) q)
```

### Row 45 — line 801

```lean
/-- info: "K gen=true check=true uGW=true [gw=true wit=true] sGW=true [gw=true wit=true] uRD=true [rdG=true] sRU=true [ruG=true]" -/
#eval "K " ++ probe4 (.imp p (.snce p q))
```

### Row 46 — line 805

```lean
/-- info: "M gen=true check=false uGW=false [gw=false wit=true] sGW=true [gw=true wit=true] uRD=true [rdG=true] sRU=true [ruG=true]" -/
#eval "M " ++ probe4 (.imp (.untl p q) q) 200 .Dense
```

### Row 47 — line 815

```lean
/-- info: "N gen=true check=false uGW=true [gw=true wit=true] sGW=false [gw=false wit=true] uRD=false [rdG=false] sRU=false [ruG=false]" -/
#eval "N " ++ probe4 (.imp p (.untl p q)) 200 .Discrete
```

### Row 48 — line 915

```lean
/-- info: "A gen=false check=true uNRU=true [k=true r=true uRL=true] sNRD=true [k=true r=true sRU=true]" -/
#eval "A " ++ probe5 (.imp (Formula.someFuture p) p)
```

### Row 49 — line 919

```lean
/-- info: "B gen=false check=true uNRU=true [k=true r=true uRL=true] sNRD=true [k=true r=true sRU=true]" -/
#eval "B " ++ probe5 (.imp (Formula.somePast p) p)
```

### Row 50 — line 923

```lean
/-- info: "C gen=false check=true uNRU=true [k=true r=true uRL=true] sNRD=true [k=true r=true sRU=true]" -/
#eval "C " ++ probe5 (.imp (.allFuture p) p)
```

### Row 51 — line 927

```lean
/-- info: "D gen=false check=true uNRU=true [k=true r=true uRL=true] sNRD=true [k=true r=true sRU=true]" -/
#eval "D " ++ probe5 (.imp (andF (.box p) (dia q)) r)
```

### Row 52 — line 931

```lean
/-- info: "E gen=false check=true uNRU=true [k=true r=true uRL=true] sNRD=true [k=true r=true sRU=true]" -/
#eval "E " ++ probe5 (.imp (andF (.box p) (.box (.imp p q))) r)
```

### Row 53 — line 935

```lean
/-- info: "F gen=false check=true uNRU=true [k=true r=true uRL=true] sNRD=true [k=true r=true sRU=true]" -/
#eval "F " ++ probe5 (.imp (Formula.someFuture p) p) 200 .Dense
```

### Row 54 — line 939

```lean
/-- info: "H gen=true check=false uNRU=true [k=true r=true uRL=true] sNRD=true [k=true r=true sRU=true]" -/
#eval "H " ++ probe5 (.imp (.untl p q) q)
```

### Row 55 — line 944

```lean
/-- info: "I gen=true check=true uNRU=true [k=true r=true uRL=true] sNRD=true [k=true r=true sRU=true]" -/
#eval "I " ++ probe5 (.imp p (.untl p q))
```

### Row 56 — line 948

```lean
/-- info: "J gen=true check=false uNRU=true [k=true r=true uRL=true] sNRD=true [k=true r=true sRU=true]" -/
#eval "J " ++ probe5 (.imp (.snce p q) q)
```

### Row 57 — line 952

```lean
/-- info: "K gen=true check=true uNRU=true [k=true r=true uRL=true] sNRD=true [k=true r=true sRU=true]" -/
#eval "K " ++ probe5 (.imp p (.snce p q))
```

### Row 58 — line 956

```lean
/-- info: "M gen=true check=false uNRU=true [k=true r=true uRL=true] sNRD=true [k=true r=true sRU=true]" -/
#eval "M " ++ probe5 (.imp (.untl p q) q) 200 .Dense
```

### Row 59 — line 964

```lean
/-- info: "N gen=true check=false uNRU=false [k=false r=false uRL=false] sNRD=true [k=true r=true sRU=true]" -/
#eval "N " ++ probe5 (.imp p (.untl p q)) 200 .Discrete
```

### Row 60 — line 1073

```lean
/-- info: "A gen=false check=true uPR=true [self=true uRD=true] sPR=true [self=true sRU=true]" -/
#eval "A " ++ probe6 (.imp (Formula.someFuture p) p)
```

### Row 61 — line 1077

```lean
/-- info: "B gen=false check=true uPR=true [self=true uRD=true] sPR=true [self=true sRU=true]" -/
#eval "B " ++ probe6 (.imp (Formula.somePast p) p)
```

### Row 62 — line 1081

```lean
/-- info: "C gen=false check=true uPR=true [self=true uRD=true] sPR=true [self=true sRU=true]" -/
#eval "C " ++ probe6 (.imp (.allFuture p) p)
```

### Row 63 — line 1085

```lean
/-- info: "D gen=false check=true uPR=true [self=true uRD=true] sPR=true [self=true sRU=true]" -/
#eval "D " ++ probe6 (.imp (andF (.box p) (dia q)) r)
```

### Row 64 — line 1089

```lean
/-- info: "E gen=false check=true uPR=true [self=true uRD=true] sPR=true [self=true sRU=true]" -/
#eval "E " ++ probe6 (.imp (andF (.box p) (.box (.imp p q))) r)
```

### Row 65 — line 1093

```lean
/-- info: "F gen=false check=true uPR=true [self=true uRD=true] sPR=true [self=true sRU=true]" -/
#eval "F " ++ probe6 (.imp (Formula.someFuture p) p) 200 .Dense
```

### Row 66 — line 1097

```lean
/-- info: "H gen=true check=false uPR=false [self=false uRD=true] sPR=true [self=false sRU=true]" -/
#eval "H " ++ probe6 (.imp (.untl p q) q)
```

### Row 67 — line 1103

```lean
/-- info: "I gen=true check=true uPR=true [self=true uRD=true] sPR=true [self=true sRU=true]" -/
#eval "I " ++ probe6 (.imp p (.untl p q))
```

### Row 68 — line 1110

```lean
/-- info: "J gen=true check=false uPR=true [self=false uRD=true] sPR=false [self=false sRU=true]" -/
#eval "J " ++ probe6 (.imp (.snce p q) q)
```

### Row 69 — line 1114

```lean
/-- info: "K gen=true check=true uPR=true [self=true uRD=true] sPR=true [self=true sRU=true]" -/
#eval "K " ++ probe6 (.imp p (.snce p q))
```

### Row 70 — line 1118

```lean
/-- info: "M gen=true check=false uPR=false [self=false uRD=true] sPR=true [self=false sRU=true]" -/
#eval "M " ++ probe6 (.imp (.untl p q) q) 200 .Dense
```

### Row 71 — line 1125

```lean
/-- info: "N gen=true check=false uPR=false [self=false uRD=false] sPR=false [self=false sRU=false]" -/
#eval "N " ++ probe6 (.imp p (.untl p q)) 200 .Discrete
```

**TemporalWitnessProbe: 71 rows**


## BoxNegReachabilityProbe

### Row 1 — line 84

```lean
/-- info: true -/
#eval rulePos .negPos < rulePos .boxNeg
```

### Row 2 — line 92

```lean
/-- info: true -/
#eval rulePos .boxNeg < rulePos .impPos
```

### Row 3 — line 98

```lean
/-- info: true -/
#eval rulePos .boxNeg < rulePos .allFuturePos
```

### Row 4 — line 126

```lean
/-- info: true -/
#eval reached.all fun bo => bo.1.contains (SignedFormula.pos gp { world := 0, time := 0 })
```

### Row 5 — line 144

```lean
/-- info: true -/
#eval reached.any fun bo => bo.1.contains (SignedFormula.neg gp { world := 1, time := 0 })
```

### Row 6 — line 152

```lean
/-- info: true -/
#eval reached.any fun bo => clashAtFreshWorld bo.1
```

### Row 7 — line 157

```lean
/-- info: (1, 0) -/
#eval (reached.length, (reached.filter fun bo => !isClosed bo.1 .Base).length)
```

### Row 8 — line 165

```lean
/-- info: some (1, 1, 0) -/
#eval (reached.head?.bind fun bo => findClosure bo.1 .Base).map fun cr =>
        match cr with
        | .contradiction _ l => (1, l.world, l.time)
        | .botPos l => (2, l.world, l.time)
        | .axiomNeg _ _ l => (3, l.world, l.time)
```

### Row 9 — line 183

```lean
/-- info: (1, 1) -/
#eval match buildTableau (gp.imp gp.box) 1000 .Base with
      | none => (0, 0)
      | some (.allClosed bs) => (1, bs.length)
      | some (.hasOpen ob _ _ _) => (2, ob.length)
```

### Row 10 — line 195

```lean
/-- info: (false, false, false, true, false) -/
#eval let r := decide (gp.imp gp.box)
      (r.isValid, r.isInvalid, r.isFuelExhausted, r.isExtractionFailed, r.isUndecided)
```

### Row 11 — line 201

```lean
/-- info: false -/
#eval (decide (gp.imp gp.box)).getCountermodel?.isSome
```

### Row 12 — line 209

```lean
/-- info: false -/
#eval isValid (gp.imp gp.box)
```

**BoxNegReachabilityProbe: 12 rows**


## RegionGateProbe

### Row 1 — line 202

```lean
/-- info: "total=true gate=false check=false cands=[[2, 0, 0]]" -/
#eval s!"total={timeOrderTotal refuteBranch refuteTimes} " ++
  s!"gate={regionGate refuteBranch refuteTimes} " ++
  s!"check={regionLabelCheck refuteBranch refuteTimes} " ++
  s!"cands={candidateGrid refuteBranch refuteTimes}"
```

### Row 2 — line 216

```lean
/-- info: "OPEN |W|=2 |T|=7 total=true gate=true check=true cands=[[3, 3, 3, 3, 3, 3, 3, 3], [3, 3, 3, 3, 3, 3, 3, 3]]" -/
#eval probe (.imp (andF (.box p) (dia q)) r)
```

### Row 3 — line 222

```lean
/-- info: "OPEN |W|=2 |T|=7 total=true gate=true check=true cands=[[3, 3, 3, 3, 3, 3, 3, 3], [3, 3, 3, 3, 1, 1, 1, 1]]" -/
#eval probe (.imp (andF (.box p) (dia (.allFuture q))) r)
```

### Row 4 — line 227

```lean
/-- info: "OPEN |W|=2 |T|=10 total=true gate=true check=true cands=[[3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3], [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]]" -/
#eval probe (.imp (andF (.box p) (dia q)) r) 200 .Dense
```

### Row 5 — line 234

```lean
/-- info: "OPEN |W|=1 |T|=4 total=true gate=true check=true cands=[[3, 3, 3, 3, 3]]" -/
#eval probe (.imp (andF (.box p) (.box (.imp p q))) r)
```

### Row 6 — line 240

```lean
/-- info: "OPEN |W|=1 |T|=4 total=true gate=true check=true cands=[[3, 3, 2, 2, 2]]" -/
#eval probe (.imp (.allFuture p) p)
```

### Row 7 — line 245

```lean
/-- info: "OPEN |W|=1 |T|=4 total=true gate=true check=true cands=[[3, 3, 2, 2, 2]]" -/
#eval probe (.imp (.imp (Formula.someFuture p) p) .bot)
```

### Row 8 — line 250

```lean
/-- info: "OPEN |W|=1 |T|=5 total=true gate=true check=true cands=[[3, 3, 2, 2, 2, 2]]" -/
#eval probe (.imp (.allFuture p) p) 200 .Dense
```

### Row 9 — line 255

```lean
/-- info: "OPEN |W|=2 |T|=10 total=true gate=true check=true cands=[[3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3], [3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1]]" -/
#eval probe (.imp (andF (.box p) (dia (.allFuture q))) r) 200 .Dense
```

### Row 10 — line 260

```lean
/-- info: "OPEN |W|=1 |T|=4 total=true gate=true check=true cands=[[3, 3, 2, 2, 2]]" -/
#eval probe (.imp (.imp (Formula.someFuture p) p) .bot) 200 .Dense
```

**RegionGateProbe: 10 rows**


## RayRegionProbe

### Row 1 — line 123

```lean
/-- info: "OPEN |W|=1 |T|=6 check=true rayUp=true rayDn=true rays=[(3, 3)]" -/
#eval probe (.imp (Formula.someFuture p) p)
```

### Row 2 — line 128

```lean
/-- info: "OPEN |W|=1 |T|=7 check=true rayUp=true rayDn=true rays=[(3, 3)]" -/
#eval probe (.imp (Formula.somePast p) p)
```

### Row 3 — line 133

```lean
/-- info: "OPEN |W|=1 |T|=4 check=true rayUp=true rayDn=true rays=[(2, 3)]" -/
#eval probe (.imp (.allFuture p) p)
```

### Row 4 — line 139

```lean
/-- info: "OPEN |W|=2 |T|=7 check=true rayUp=true rayDn=true rays=[(2, 2), (5, 5)]" -/
#eval probe (.imp (andF (.box p) (dia q)) r)
```

### Row 5 — line 144

```lean
/-- info: "OPEN |W|=1 |T|=4 check=true rayUp=true rayDn=true rays=[(2, 2)]" -/
#eval probe (.imp (andF (.box p) (.box (.imp p q))) r)
```

### Row 6 — line 149

```lean
/-- info: "OPEN |W|=1 |T|=6 check=true rayUp=true rayDn=true rays=[(3, 3)]" -/
#eval probe (.imp (Formula.someFuture p) p) 200 .Dense
```

### Row 7 — line 171

```lean
/-- info: "check=true rayUp=false rayDn=true rays=[(0, 0)]" -/
#eval s!"check={regionLabelCheck rayRefuteBranch rayTimes} " ++
  s!"rayUp={rayUpOk rayRefuteBranch rayTimes} rayDn={rayDnOk rayRefuteBranch rayTimes} " ++
  s!"rays={rayLabels rayRefuteBranch rayTimes}"
```

**RayRegionProbe: 7 rows**


## CrossWorldPropagationProbe

### Row 1 — line 66

```lean
/-- info: false -/
#eval isValid ((Formula.someFuture p).neg.imp ((Formula.someFuture p).neg.box))
```

### Row 2 — line 73

```lean
/-- info: false -/
#eval isValid ((Formula.allFuture p).imp ((Formula.allFuture p).box))
```

### Row 3 — line 80

```lean
/-- info: false -/
#eval isValid ((Formula.somePast p).neg.imp ((Formula.somePast p).neg.box))
```

### Row 4 — line 88

```lean
/-- info: true -/
#eval isValid (p.imp p)
```

### Row 5 — line 93

```lean
/-- info: false -/
#eval isValid (p.imp q)
```

**CrossWorldPropagationProbe: 5 rows**


## BoxSpreadProbe

### Row 1 — line 75

```lean
/-- info: "OPEN spread=false anchor=true grid=true |W|=2 |T|=7" -/
#eval probe (.imp (andF (.box p) (dia q)) r)
```

### Row 2 — line 80

```lean
/-- info: "OPEN spread=false anchor=true grid=true |W|=2 |T|=7" -/
#eval probe (.imp (andF (.box p) (dia (.allFuture q))) r)
```

### Row 3 — line 85

```lean
/-- info: "OPEN spread=false anchor=true grid=true |W|=2 |T|=10" -/
#eval probe (.imp (andF (.box p) (dia q)) r) 200 .Dense
```

### Row 4 — line 121

```lean
/-- info: "OPEN boxP=true boxPQ=true boxQ=false Gq=false Hq=false" -/
#eval gapProbe (.imp (andF (.box p) (.box (.imp p q))) r)
```

### Row 5 — line 129

```lean
/-- info: "STALLED" -/
#eval gapProbe (.imp (andF (.box p) (.box (.imp p q))) r) 400 .Dense
```

**BoxSpreadProbe: 5 rows**


## BoxNegPreservationProbe

### Row 1 — line 103

```lean
/-- info: 2 -/
#eval emitted.length
```

### Row 2 — line 108

```lean
/-- info: true -/
#eval emitted.all fun sf => sf.label == { world := 1, time := 0 }
```

### Row 3 — line 116

```lean
/-- info: true -/
#eval emitted.any fun a => emitted.any fun c =>
  a.formula == c.formula && a.label == c.label && a.sign == Sign.pos && c.sign == Sign.neg
```

### Row 4 — line 122

```lean
/-- info: true -/
#eval emitted.any fun a => a.sign == Sign.pos && a.formula == Formula.allFuture p
```

### Row 5 — line 131

```lean
/-- info: false -/
#eval isValid ((Formula.allFuture p).imp ((Formula.allFuture p).box))
```

**BoxNegPreservationProbe: 5 rows**


## Totals

- TableauConformance: 27
- TemporalWitnessProbe: 71
- BoxNegReachabilityProbe: 12
- RegionGateProbe: 10
- RayRegionProbe: 7
- CrossWorldPropagationProbe: 5
- BoxSpreadProbe: 5
- BoxNegPreservationProbe: 5

**TOTAL: 142**
