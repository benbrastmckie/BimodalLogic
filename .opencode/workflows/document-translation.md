# Document Translation

## Overview
This workflow manages the translation of Lean 4 documentation from one language to another, ensuring accuracy and consistency.

<task_context>
  <expert_role>Lean 4 Developer & Translator</expert_role>
  <mission_objective>To translate a piece of documentation accurately and in accordance with project standards.</mission_objective>
</task_context>

<operational_context>
  <tone_framework>Clear, accurate, and natural-sounding.</tone_framework>
  <audience_level>Users of the Lean 4 project who speak the target language.</audience_level>
</operational_context>

<pre_flight_check>
  <validation_requirements>
    - The source documentation is finalized and approved.
    - A clear target language has been identified.
  </validation_requirements>
</pre_flight_check>

<process_flow>

### Step 1: Initial Translation
<step_framework>
  <context_dependencies>
    - .opencode/context/lean4/translation-conventions.md
  </context_dependencies>
  
  <action>Translate the source document to the target language, paying close attention to technical terms and conventions.</action>
  
  <output>A draft translation of the document.</output>
</step_framework>

### Step 2: Review
<step_framework>
  <context_dependencies>
    - .opencode/context/lean4/translation-conventions.md
  </context_dependencies>
  
  <action>Have a second translator or a native speaker review the draft for accuracy, clarity, and adherence to translation conventions.</action>
  
  <output>A list of suggested edits and improvements.</output>
</step_framework>

### Step 3: Finalization
<step_framework>
  <context_dependencies>
    - .opencode/context/lean4/translation-conventions.md
  </context_dependencies>
  
  <action>Incorporate the feedback from the review process and produce the final version of the translated document.</action>
  
  <output>The final, approved translation.</output>
</step_framework>

</process_flow>

<guidance_systems>
  <when_to_use>
    - When making the project accessible to a wider, multilingual audience.
    - For official project documentation, tutorials, and guides.
  </when_to_use>
  
  <when_not_to_use>
    - For informal communications or code comments (unless specifically required).
  </when_not_to_use>
</guidance_systems>

<post_flight_check>
  <validation_requirements>
    - The translation is accurate and faithful to the source document.
    - The translated document is easy to read and understand for native speakers of the target language.
  </validation_requirements>
</post_flight_check>

## Context Dependencies Summary
- **All Steps**: .opencode/context/lean4/translation-conventions.md

## Success Metrics
- Positive feedback from the community on the quality of the translation.
- The translated document is used and referenced by speakers of the target language.
