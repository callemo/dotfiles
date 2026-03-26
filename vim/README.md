# Vim Keymap Spec And Plan

## Goals

- Keep the keymap mentally coherent: key names and prefixes should suggest what they do.
- Reduce duplication so changing one action does not require editing several unrelated mappings.
- Preserve dual-modality use:
  - mouse-first on desktop
  - keyboard-first in constrained environments such as Macs and iPads
- Treat mouse and keyboard as peer frontends over the same core actions where possible.

## Current Assessment

### Improved

- Window cycling is now semantically clearer.
  - `<C-j>` and `<C-k>` no longer pretend to be directional movement.
  - `FocusNext()` and `FocusPrev()` make the behavior explicit by decoupling window focus from list structures, and unify tmux edge handoff.
  - Normal and terminal mode now share the same navigation helpers instead of duplicating the tmux condition inline.
- Window zoom no longer overloads Vim's window-command prefix.
  - The custom zoom action now belongs on `<leader>z` instead of `<C-w>z`.
- The `yo` family is more consistent.
  - `yoi` now matches `ignorecase` better than the previous `yoc`.
- The custom `m` make prefix is gone.
  - This removes an avoidable overload of Vim's mark namespace.

### Remaining Fragility

- The main semantic actions are still duplicated across modalities and contexts.
  - Plumb current thing is defined separately for normal, visual, mouse, and dir buffers.
  - Run command from current thing or selection is defined separately for keyboard, mouse, and dir buffers.
- Modalities treat their input as distinct execution contexts rather than routing a string to a single execution function.
- Dir buffer actions still duplicate top-level action logic instead of delegating to a shared interface where data simply dictates the target for `Plumb()` or `Cmd()`.

## Desired Model

### Core Principle

Keep the real semantic center in the existing functions such as `Cmd()` and `Plumb()`. Apply the principle "Data dominates" by creating single text-yielding data extraction functions. Do not define parallel control flows or mode-specific wrappers to handle `Plumb()` or `Cmd()` inputs. Instead, feed extracted string text through one common execution path.

### Modality Rule

- Desktop mouse-first use is the ergonomics baseline.
- Constrained keyboard-first use is the completeness baseline.
- Mouse and keyboard should share semantics when the action is actually the same.
- Mouse-only actions should remain only for genuinely pointer-native gestures such as statusline click behaviors.
- Small local differences in how a mode chooses its input are acceptable and do not need a formal shared interface.

## Refactor Plan

### Phase 1: Keep The Existing Semantic Center

- Keep `Cmd()` as the command-execution center.
- Keep `Plumb()` as the open-or-plumb center.
- Keep `FocusNext()` and `FocusPrev()` as the model for justified extraction: they decouple from window/list terminology to remove duplicated control flow.
- Ensure modalities and input mechanisms act only as text-extractors that pipe into single stateless versions of `Cmd()` or `Plumb()`.

### Phase 2: Simplify Only Where Duplication Is Real

- Consolidate modes (normal, visual, mouse) into a single text-yielding data-extractor function. 
- Eliminate mode-specific wrapper logic mapping to `Cmd()` or `Plumb()` execution flows.
- Pass a normalized string out of the UI layer rather than treating modes like unique contexts.

### Phase 3: Keep Custom Prefixes Honest

- Prefer `<leader>` for custom actions that are not natural extensions of an existing Vim prefix.
- Avoid rebuilding a custom namespace on top of strong built-in prefixes such as `m`.
- Treat future exceptions as explicit policy choices, not casual convenience mappings.

### Phase 4: Preserve Cheap, Readable Repetition

- Keep short explicit map families such as `yo` toggles and `[]` navigation if they remain stable and easy to scan.
- Do not table-drive these families unless they become materially harder to maintain.

## Verification

### Desktop Workflow

- Right click opens or plumbs the clicked thing.
- Middle click runs the expected command target.
- Statusline double click and control click preserve window-close and window-zoom behavior.
- Dir buffer mouse actions match the corresponding keyboard actions.

### Constrained Workflow

- Every core action can be completed without mouse input.
- `<C-j>` and `<C-k>` behave consistently in normal and terminal mode.
- Leader bindings and visual bindings cover the same important actions as mouse bindings.

### Consistency Checks

- Changing the implementation of plumb or command execution should usually happen in `Plumb()` or `Cmd()`, not in a helper taxonomy built around modes.
- Dir buffer behavior may stay locally expressed if the only difference is the source text.
- The abstraction threshold is simple: remove repeated logic, keep repeated declarations.

## Recommended Next Step

Start with renaming `WinCycleNext()` and `WinCyclePrev()` to `FocusNext()` and `FocusPrev()`, focusing strictly on the user state-change instead of Vim lists. Then refactor input data to pipe strings into `Plumb()` and `Cmd()` rather than allowing each mode to handle its own execution path.