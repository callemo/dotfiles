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
  - `WinCycleNext()` and `WinCyclePrev()` make the behavior explicit and unify tmux edge handoff.
  - Normal and terminal mode now share the same navigation helpers instead of duplicating the tmux condition inline.
- The `yo` family is more consistent.
  - `yoi` now matches `ignorecase` better than the previous `yoc`.

### Still Good Enough For Now

- `m<CR>` and `m<Space>` still overload a strong built-in Vim prefix, but this is now a policy choice rather than an accidental inconsistency.
- `<C-w>z` still uses Vim's window prefix for a custom zoom action. That is acceptable if it is a deliberate house style.

### Remaining Fragility

- The main semantic actions are still duplicated across modalities and contexts.
  - Plumb current thing is defined separately for normal, visual, mouse, and dir buffers.
  - Run command from current thing or selection is defined separately for keyboard, mouse, and dir buffers.
- The mouse-first and keyboard-first paths still share behavior by convention rather than through common helpers.
- Dir buffer actions still duplicate top-level action logic instead of delegating to a shared interface with a dir-specific data source.

## Desired Model

### Core Principle

Keep the real semantic center in the existing functions such as `Cmd()` and `Plumb()`. Extract only where there is duplicated control flow or shell or tmux logic. Do not add wrappers whose only job is to rename a data source.

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
- Keep `WinCycleNext()` and `WinCyclePrev()` as the model for justified extraction: they remove real duplicated control flow.
- Avoid adding helper families whose only purpose is to wrap one-line argument selection.

### Phase 2: Simplify Only Where Duplication Is Real

- Keep explicit mappings when they are only selecting a different data source such as cursor word, visual selection, or dir entry.
- Extract code only when the duplicated part is actual logic rather than argument choice.
- Treat dir-buffer mappings as a local UI layer unless a repeated control-flow pattern emerges.

### Phase 3: Decide On Two Policy Exceptions

Keep or revisit these intentionally:

- `m` as a custom make prefix
- `<C-w>z` as a custom zoom action

These are no longer the first cleanup target. They should only move if they are actually causing friction.

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

Start with the smallest concrete cleanup that removes repeated logic without inventing new layers. The current example to follow is `WinCycleNext()` and `WinCyclePrev()`: extract only when there is real behavior to share, and leave simple map declarations explicit.