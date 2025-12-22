---
name: context
agent: orchestrator
description: "Initiates a sequential workflow to plan the refactoring of context files and update all references."
---

# Context Management Planning Workflow

**Context Loaded:**
@context/common/system/context-guide.md

<context>
  <system_context>
    You are the system orchestrator, managing the `.opencode` context for a software project. You must execute a sequential workflow to ensure dependencies are handled correctly.
  </system_context>
  <task_context>
    Execute a three-stage planning workflow. The output from each stage (artifact references and summaries) must be passed to the subsequent stage. Do not read the artifact content; only pass the references.
  </task_context>
</context>

<role>
  Workflow Orchestrator
</role>

<task>
  Execute the context management planning workflow by calling subagents in sequence and chaining their inputs and outputs.
</task>

<workflow_execution>
  <stage id="1" name="PlanContextRefactor">
    <action>Route to @subagents/context-refactor to create a detailed plan for refactoring the `.opencode/context/` directory.</action>
    <process>
      1. Call `@subagents/context-refactor` with the user's initial request: `$ARGUMENTS`.
      2. The subagent will create a refactoring plan.
      3. Capture the JSON result containing `artifact_path` and `summary`.
    </process>
    <output>
      `refactor_plan_result` (JSON object with path and summary)
    </output>
    <checkpoint>Context refactor plan created.</checkpoint>
  </stage>

  <stage id="2" name="PlanReferenceUpdates">
    <action>Route to @subagents/context-references, passing the refactor plan's path and its parent directory.</action>
    <process>
      1. Get the `artifact_path` from `refactor_plan_result`.
      2. Extract the parent directory from `artifact_path`.
      3. Call `@subagents/context-references`, passing the full path to the refactor plan and the parent directory as arguments. The subagent will create its plan in the provided directory.
      4. Capture the JSON result containing `artifact_path` and `summary`.
    </process>
    <input>
      {
        "refactor_plan_path": `refactor_plan_result.artifact_path`,
        "output_directory": `dirname(refactor_plan_result.artifact_path)`
      }
    </input>
    <output>
      `references_plan_result` (JSON object with path and summary)
    </output>
    <checkpoint>Context references update plan created.</checkpoint>
  </stage>

  <stage id="3" name="AddTasksToDo">
    <action>Route to @subagents/task-adder, passing both created plans as arguments.</action>
    <process>
      1. Construct a JSON object containing the results from the previous two stages.
      2. Call `@subagents/task-adder` with this JSON object as the argument.
      3. The subagent will add the tasks to `TODO.md`.
      4. Capture the final confirmation summary.
    </process>
    <input>
      {
        "refactor_plan": `refactor_plan_result`,
        "references_plan": `references_plan_result`
      }
    </input>
    <output>
      `final_summary`
    </output>
    <checkpoint>Tasks added to TODO.md.</checkpoint>
  </stage>

  <stage id="4" name="PresentResults">
    <action>Present the final summary and artifact paths to the user.</action>
    <process>
      1. Display the summary from the `task-adder`.
      2. Display the `artifact_path` for the refactor plan.
      3. Display the `artifact_path` for the references plan.
    </process>
    <checkpoint>Workflow complete.</checkpoint>
  </stage>
</workflow_execution>
