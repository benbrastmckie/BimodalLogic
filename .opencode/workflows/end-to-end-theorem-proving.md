# End-to-End Theorem Proving

## Overview
This workflow guides the entire process of proving a new theorem, from initial research to final documentation. It's designed for complex mathematical proofs that require careful planning and execution.

<task_context>
  <expert_role>Lean 4 Developer & Mathematician</expert_role>
  <mission_objective>To formally prove a mathematical theorem in Lean 4, ensuring the proof is correct, efficient, and well-documented.</mission_objective>
</task_context>

<operational_context>
  <tone_framework>Formal, precise, and clear.</tone_framework>
  <audience_level>Mathematicians and computer scientists with a background in formal methods.</audience_level>
</operational_context>

<pre_flight_check>
  <validation_requirements>
    - A clear statement of the theorem to be proven.
    - Access to relevant mathematical literature.
  </validation_requirements>
</pre_flight_check>

<process_flow>

### Step 1: Research
<step_framework>
  <context_dependencies>
    - .opencode/context/lean4/theorem-proving-guidelines.md
  </context_dependencies>
  
  <action>Review existing literature and formal proofs to understand the context and identify potential strategies.</action>
  
  <output>A summary of relevant research and a list of potential proof strategies.</output>
</step_framework>

### Step 2: Planning
<step_framework>
  <context_dependencies>
    - .opencode/context/lean4/theorem-proving-guidelines.md
  </context_dependencies>
  
  <action>Outline the structure of the proof, breaking it down into smaller lemmas and defining the overall architecture.</action>
  
  <output>A detailed proof plan and a list of required lemmas.</output>
</step_framework>

### Step 3: Revision
<step_framework>
  <context_dependencies>
    - .opencode/context/lean4/style-guide.md
  </context_dependencies>
  
  <action>Review the proof plan for logical soundness and clarity. Refine the structure and approach based on feedback.</action>
  
  <output>A revised and approved proof plan.</output>
</step_framework>

### Step 4: Implementation
<step_framework>
  <context_dependencies>
    - .opencode/context/lean4/style-guide.md
  </context_dependencies>
  
  <action>Write the Lean 4 code for the proof, following the established plan and style guidelines.</action>
  
  <output>A complete Lean 4 implementation of the proof.</output>
</step_framework>

### Step 5: Documentation
<step_framework>
  <context_dependencies>
    - .opencode/context/lean4/style-guide.md
  </context_dependencies>
  
  <action>Add detailed comments and explanations to the code, clarifying the purpose and logic of each step.</action>
  
  <output>A fully documented Lean 4 proof.</output>
</step_framework>

</process_flow>

<guidance_systems>
  <when_to_use>
    - When proving a new, non-trivial theorem.
    - When a formal, machine-checked proof is required.
  </when_to_use>
  
  <when_not_to_use>
    - For simple proofs or minor code changes.
  </when_not_to_use>
</guidance_systems>

<post_flight_check>
  <validation_requirements>
    - The Lean 4 compiler successfully verifies the proof.
    - The proof is clean, readable, and well-documented.
  </validation_requirements>
</post_flight_check>

## Context Dependencies Summary
- **Step 1-2**: .opencode/context/lean4/theorem-proving-guidelines.md
- **Step 3-5**: .opencode/context/lean4/style-guide.md

## Success Metrics
- The theorem is successfully proven without any errors.
- The final code adheres to all style and documentation standards.
