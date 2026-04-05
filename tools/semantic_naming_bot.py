#!/usr/bin/env python3
"""Scope scanner for TCG2 semantics and naming completion.

This script reports unresolved naming/semantics workload with the same focus as the
TCG2 completion bot: local .asm labels, hex-style WRAM/HRAM placeholders,
structural WRAM TODOs, and unresolved markers.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
from collections import Counter
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Iterable, List


@dataclass
class FileCount:
    file: str
    count: int


@dataclass
class BotReport:
    unresolved_func_defs: int
    unresolved_func_locations: List[str]
    unresolved_local_asm_labels: int
    top_local_asm_files: List[FileCount]
    unresolved_ram_placeholders: int
    unresolved_ram_locations: List[str]
    structural_wram_todos: int
    structural_wram_todo_locations: List[str]
    unresolved_marker_count: int
    unknown_unused_marker_count: int


def run_rg(repo: Path, pattern: str, paths: Iterable[str]) -> str:
    cmd = ["rg", "-n", pattern, *paths]
    result = subprocess.run(cmd, cwd=repo, capture_output=True, text=True, check=False)
    if result.returncode not in (0, 1):
        raise RuntimeError(f"rg failed: {' '.join(cmd)}\n{result.stderr}")
    return result.stdout.strip()


def parse_lines(text: str) -> List[str]:
    if not text:
        return []
    return [line for line in text.splitlines() if line.strip()]


def to_file_counts(lines: List[str], top_n: int) -> List[FileCount]:
    counter: Counter[str] = Counter()
    for line in lines:
        file_path = line.split(":", 1)[0]
        counter[file_path] += 1
    return [FileCount(file=path, count=count) for path, count in counter.most_common(top_n)]


def build_report(repo: Path, top_n: int) -> BotReport:
    func_pat = r"^Func_[0-9a-fA-F]+:|^Func_[0-9a-fA-F]+::"
    local_pat = r"^\s*\.[Aa]sm_[0-9a-fA-F]+"
    # Declaration-oriented hex placeholder pattern.
    ram_pat = r"^\s*(w(?:[0-9a-f]{4}|c[0-9a-f]{3}|d[0-9a-f]{3}|3d[0-9a-f]{3})|h[0-9a-f]{4})::"
    wram_todo_pat = r"TODO: is this really union\?"
    unresolved_marker_pat = r"TODO:|unreferenced|unused|remnant"
    unknown_marker_pat = r"\bUNK\b|UNKNOWN|UNUSED_|UNUSED\b|NO_OP|NOOP"

    func_lines = parse_lines(run_rg(repo, func_pat, ["src"]))
    local_lines = parse_lines(run_rg(repo, local_pat, ["src"]))
    ram_lines = parse_lines(run_rg(repo, ram_pat, ["src/wram.asm", "src/hram.asm"]))
    wram_todo_lines = parse_lines(run_rg(repo, wram_todo_pat, ["src/wram.asm"]))
    unresolved_lines = parse_lines(run_rg(repo, unresolved_marker_pat, ["src", "docs"]))
    unknown_lines = parse_lines(run_rg(repo, unknown_marker_pat, ["src/constants", "src/engine", "src/home"]))

    return BotReport(
        unresolved_func_defs=len(func_lines),
        unresolved_func_locations=func_lines,
        unresolved_local_asm_labels=len(local_lines),
        top_local_asm_files=to_file_counts(local_lines, top_n),
        unresolved_ram_placeholders=len(ram_lines),
        unresolved_ram_locations=ram_lines,
        structural_wram_todos=len(wram_todo_lines),
        structural_wram_todo_locations=wram_todo_lines,
        unresolved_marker_count=len(unresolved_lines),
        unknown_unused_marker_count=len(unknown_lines),
    )


def to_markdown(report: BotReport) -> str:
    lines: List[str] = []
    lines.append("# TCG2 Semantics/Naming Completion Report")
    lines.append("")
    lines.append("## Snapshot")
    lines.append(f"- Unresolved `Func_xxxx` definitions: {report.unresolved_func_defs}")
    lines.append(f"- Generic local labels (`.asm_xxxx`): {report.unresolved_local_asm_labels}")
    lines.append(f"- Hex-style WRAM/HRAM placeholders: {report.unresolved_ram_placeholders}")
    lines.append(f"- Structural WRAM TODOs: {report.structural_wram_todos}")
    lines.append(f"- Unresolved markers (`unreferenced|unused|remnant|TODO`): {report.unresolved_marker_count}")
    lines.append(f"- Unknown/unused-style markers in constants/engine/home: {report.unknown_unused_marker_count}")
    lines.append("")

    lines.append("## Highest-Impact Files For Local Label Cleanup")
    for item in report.top_local_asm_files:
        lines.append(f"- {item.file}: {item.count}")
    lines.append("")

    lines.append("## Unresolved Function Definitions")
    if report.unresolved_func_locations:
        for entry in report.unresolved_func_locations:
            lines.append(f"- {entry}")
    else:
        lines.append("- none")
    lines.append("")

    lines.append("## Hex-Style WRAM/HRAM Placeholders")
    if report.unresolved_ram_locations:
        for entry in report.unresolved_ram_locations:
            lines.append(f"- {entry}")
    else:
        lines.append("- none")
    lines.append("")

    lines.append("## Structural WRAM TODOs")
    if report.structural_wram_todo_locations:
        for entry in report.structural_wram_todo_locations:
            lines.append(f"- {entry}")
    else:
        lines.append("- none")
    lines.append("")

    lines.append("## Bot Policy Reminders")
    lines.append("- Keep orphan/unreferenced stubs documented as dead code unless new evidence appears.")
    lines.append("- Prioritize behavior-backed renames and avoid speculative names.")
    lines.append("- Preserve control flow and label export scope.")

    return "\n".join(lines) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description="TCG2 semantics and naming completion scope bot")
    parser.add_argument("--repo", default=".", help="Repository root path")
    parser.add_argument("--top", type=int, default=20, help="Top N files for local label counts")
    parser.add_argument("--json", dest="json_path", help="Write JSON report to this path")
    parser.add_argument("--md", dest="md_path", help="Write Markdown report to this path")
    args = parser.parse_args()

    repo = Path(args.repo).resolve()
    report = build_report(repo, args.top)

    if args.json_path:
        json_path = Path(args.json_path)
        if not json_path.is_absolute():
            json_path = repo / json_path
        json_path.parent.mkdir(parents=True, exist_ok=True)
        json_path.write_text(json.dumps(asdict(report), indent=2) + "\n", encoding="utf-8")

    md = to_markdown(report)
    if args.md_path:
        md_path = Path(args.md_path)
        if not md_path.is_absolute():
            md_path = repo / md_path
        md_path.parent.mkdir(parents=True, exist_ok=True)
        md_path.write_text(md, encoding="utf-8")
    else:
        print(md, end="")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
