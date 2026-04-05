# Pokemon TCG2 Workspace Instructions

## First Reads
- THERE IS NO ASSUMING. Always read the relevant file before making recommendations or edits, even if you think you remember the rules or context. This includes CONTRIBUTING.md, relevant persistent memory files in `/memories/`, and the directly relevant asm, constant, macro, and data files for the task at hand.
- Read [CONTRIBUTING.md](../CONTRIBUTING.md) before making disassembly, naming, documentation, RAM-label, constant, macro, or refactor changes.
- Record memory of batch updating activities.
- Consult relevant persistent memory in `/memories/` near the start of each task, especially `/memories/workflow.md`, `/memories/z80_assembly_debugging.md`, and other task-relevant notes.
- If unsure of a function, routine, or data block's purpose, read its callers, callees, RAM usage, constants, and any related patterns before proposing names or comments.
- For reviews, read relevant persistent memory to treat known historical failure modes as active review checks.

## Persistent Memory Policy
- Treat `/memories/` as project context, not optional background material.
- Reuse prior verified lessons before proposing new theories, especially for parity-sensitive label scope, stack behavior, calling patterns, and reverse-engineering decisions.
- When you confirm a durable repository-wide fact that is likely to help future tasks, store it as a new JSON note under `/memories/repo/` with `subject`, `fact`, `citations`, `reason`, and `category`.
- Do not write speculative conclusions, temporary hypotheses, or one-off task chatter into persistent memory.
- Store unresolved names to persistent memory.

## Disassembly Conventions
- Follow `CONTRIBUTING.md` exactly for labels, local-label scope, documentation headers, RAM names, constants, number formatting, macros, and refactors.
- Prefer local labels over global labels unless cross-file use is verified.
- Never change a label from `:` to `::` unless export scope is confirmed by real usage or authoritative symbols.
- Leave uncertain routines and labels as `Func_xxxx` and `.asm_xxxx` until their purpose is defensible.
- When a `Func_xxxx` placeholder receives a confirmed function name, keep the old placeholder as an inline label comment in the form `NewFuncName: ; Func_xxxx`.
- For every unknown ram label, create a new `wUnknown_xxxx` or `hUnknown_xxxx` RAM name in the format `wNewRAMName ; (w)XXXX` and in the appropriate file with a comment for its observed behavior and usage context. Do not rename a RAM label until its purpose is defensible.
- If a RAM label's purpose is not obvious from the name alone, add a concise explanation comment directly above the label declaration describing observed behavior/context.
- Functions will be scattered throught 'src', so use search and context to find the right file for a rename instead of assuming.
- Use the inline old-name comment only for confirmed renamed functions. Do not add it to unnamed routines, local labels, or non-function labels.
- Functions and labels should be named for their observed behavior and purpose, not just to avoid placeholder names.
- Do not rename a function with unknown WRAM names or function names. Example: `SetWDD75AndWDD76Zero` if a function writes to `wUnknown_1234` and we have no context for what that RAM does, we should not rename the function until we have more information about its behavior and purpose.

## Workflow Constraints
- Preserve existing code paths whenever possible and prefer the smallest correct change.
- Run `make clean && make DEBUG=1`, THIS IS MANDATORY.
- If a task requires disassembly tooling, ensure any use of `tools/tcg2disasm.py` is based on an up-to-date symbol file.

## Local Rename Documentation
- Create `docs/unnamed_funcs.txt` when recording the first confirmed rename if the file does not already exist.
- Record each confirmed `Func_xxxx` rename in `docs/unnamed_funcs.txt`.
- Use this exact entry format:
	`Func_xxxx -> NewFuncName`
	`Concise function description`
- Leave one blank line after the description so the next entry starts after a blank line.
- Keep descriptions concise and aligned with `CONTRIBUTING.md`, focusing on purpose, context, and important input or output behavior.

## Local WRAM Rename Documentation
- Create `docs/unnamed_wram.txt` when recording the first confirmed WRAM rename if the file does not already exist.
- Record each confirmed `wxxxx`/`hxxxx` rename in `docs/unnamed_wram.txt`.
- Use this exact entry format:
	`wxxxx -> wNewRAMName`
	`Concise RAM behavior/context description`
- Leave one blank line after the description so the next entry starts after a blank line.
- Keep descriptions concise and aligned with `CONTRIBUTING.md`, focusing on observed behavior and usage context.

## Review And Documentation
- For reviews, prioritize parity risks, accidental export changes, speculative naming, and violations of `CONTRIBUTING.md`.
- If you learn something durable while working, prefer preserving it in repo memory and, when appropriate, in repository documentation alongside the code changes.