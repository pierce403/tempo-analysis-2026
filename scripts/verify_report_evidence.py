#!/usr/bin/env python3
"""Enforce direct, tracked evidence for every claim unit in REPORT.md.

A claim unit is one report metadata line, prose paragraph, list item, or table
data row. Markdown headings, blank lines, table headers/separators, and fenced
code are intentionally excluded. Each claim unit must directly contain an
inline Markdown link whose target is a file below evidence/.
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from collections import Counter
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from urllib.parse import unquote


HEADING_RE = re.compile(r"^\s{0,3}#{1,6}(?:\s+|$)")
FENCE_RE = re.compile(r"^\s{0,3}(`{3,}|~{3,})")
LIST_RE = re.compile(r"^\s*(?:[-+*]|\d+[.)])\s+")
METADATA_RE = re.compile(r"^\s*\*\*[^*\n]+:\*\*")
TABLE_SEPARATOR_CELL_RE = re.compile(r"^:?-{3,}:?$")
INLINE_LINK_RE = re.compile(
    r"(?<!!)\[[^\]\n]+\]\(\s*"
    r"(?P<target><[^>\n]+>|[^)\s]+)"
    r"(?:\s+(?:\"[^\"\n]*\"|'[^'\n]*'|\([^\n)]*\)))?\s*\)"
)

EVIDENCE_CONTRACT = {
    "timestamp/provenance": re.compile(
        r"(?:\b20\d{2}-[01]\d-[0-3]\d(?:[T ][0-2]\d:[0-5]\d(?::[0-6]\d)?(?:Z|[+-][0-2]\d:?[0-5]\d)?)?\b|"
        r"\b(?:executed|observed|captured|refreshed|recorded|assessment|observation|source)[ _-]*(?:at|date|time|window|revision|commit|sha|provenance)\s*:)",
        re.IGNORECASE,
    ),
    "re-run command/procedure": re.compile(
        r"(?:\b(?:re-?run|reproduce|reproduction|command|commands|procedure|verification steps|steps to verify|method|invocation)\b\s*:|"
        r"^\s*(?:\$|git |gh |curl |dig |nmap |forge |cargo |npm |pnpm |yarn |python3? |bash |sh )\S?)",
        re.IGNORECASE | re.MULTILINE,
    ),
    "captured result": re.compile(
        r"(?:\b(?:result|results|output|observed|observation|captured output|assertions?|exit code|conclusion|finding)\b\s*:|"
        r"\b(?:PASS(?:ED)?|FAIL(?:ED)?|exit(?:ed)?\s+(?:0|1)|status\s+(?:0|1|2\d\d|3\d\d|4\d\d|5\d\d))\b)",
        re.IGNORECASE,
    ),
    "limitations/safety": re.compile(
        r"(?:\b(?:limit|limitation|limitations|safety|safety boundary|authorization boundary|scope boundary|unknowns?)\b\s*:|"
        r"\b(?:not|never)\s+(?:tested|attempted|demonstrated|shown|established|confirmed|validated|contacted|triggered|submitted)\b|"
        r"\bno\s+(?:live|production|credential|secret|payment|transaction|state-changing)\b|"
        r"\b(?:read-only|dummy-only|dummy values?|local-only|owner confirmation required)\b)",
        re.IGNORECASE,
    ),
}


@dataclass(frozen=True)
class ClaimUnit:
    kind: str
    start: int
    end: int
    text: str


@dataclass(frozen=True)
class EvidenceLink:
    line: int
    raw_target: str
    relative_path: str | None
    error: str | None


def is_table_row(line: str) -> bool:
    return line.lstrip().startswith("|")


def is_table_separator(line: str) -> bool:
    if not is_table_row(line):
        return False
    cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
    return bool(cells) and all(TABLE_SEPARATOR_CELL_RE.fullmatch(cell) for cell in cells)


def fenced_lines(lines: list[str]) -> set[int]:
    """Return zero-based indexes occupied by complete or unterminated fences."""
    occupied: set[int] = set()
    marker_char: str | None = None
    marker_length = 0
    for index, line in enumerate(lines):
        match = FENCE_RE.match(line)
        if marker_char is None:
            if match:
                marker = match.group(1)
                marker_char = marker[0]
                marker_length = len(marker)
                occupied.add(index)
        else:
            occupied.add(index)
            if match:
                marker = match.group(1)
                if marker[0] == marker_char and len(marker) >= marker_length:
                    marker_char = None
                    marker_length = 0
    return occupied


def table_header_lines(lines: list[str], fenced: set[int]) -> set[int]:
    headers: set[int] = set()
    for index in range(len(lines) - 1):
        if index in fenced or index + 1 in fenced:
            continue
        if is_table_row(lines[index]) and is_table_separator(lines[index + 1]):
            headers.add(index)
    return headers


def boundary_kind(
    lines: list[str], index: int, fenced: set[int], table_headers: set[int]
) -> str | None:
    line = lines[index]
    if index in fenced:
        return "exempt"
    if not line.strip() or HEADING_RE.match(line):
        return "exempt"
    if is_table_row(line):
        if index in table_headers or is_table_separator(line):
            return "exempt"
        return "table row"
    if METADATA_RE.match(line):
        return "metadata"
    if LIST_RE.match(line):
        return "list item"
    return None


def claim_units(lines: list[str]) -> tuple[list[ClaimUnit], set[int]]:
    fenced = fenced_lines(lines)
    table_headers = table_header_lines(lines, fenced)
    units: list[ClaimUnit] = []
    index = 0
    while index < len(lines):
        kind = boundary_kind(lines, index, fenced, table_headers)
        if kind == "exempt":
            index += 1
            continue
        if kind in {"metadata", "table row"}:
            units.append(ClaimUnit(kind, index + 1, index + 1, lines[index]))
            index += 1
            continue
        if kind == "list item":
            start = index
            index += 1
            while index < len(lines):
                next_kind = boundary_kind(lines, index, fenced, table_headers)
                if next_kind is not None:
                    break
                index += 1
            units.append(
                ClaimUnit("list item", start + 1, index, "\n".join(lines[start:index]))
            )
            continue

        # Everything else is a prose paragraph. Wrapped source lines remain one
        # claim unit until a blank line or another structural boundary.
        start = index
        index += 1
        while index < len(lines):
            next_kind = boundary_kind(lines, index, fenced, table_headers)
            if next_kind is not None:
                break
            index += 1
        units.append(
            ClaimUnit("prose paragraph", start + 1, index, "\n".join(lines[start:index]))
        )
    return units, fenced


def normalize_evidence_target(raw_target: str) -> tuple[str | None, str | None]:
    target = raw_target.strip()
    if target.startswith("<") and target.endswith(">"):
        target = target[1:-1]
    target = unquote(target.split("#", 1)[0].split("?", 1)[0])
    if not target.startswith("evidence/"):
        return None, None
    pure = PurePosixPath(target)
    if pure.is_absolute() or ".." in pure.parts or pure.parts[0] != "evidence":
        return None, "evidence target escapes or does not remain below evidence/"
    if len(pure.parts) < 2:
        return None, "evidence target must name a file below evidence/"
    return pure.as_posix(), None


def links_in_text(text: str, start_line: int) -> list[EvidenceLink]:
    links: list[EvidenceLink] = []
    for match in INLINE_LINK_RE.finditer(text):
        raw_target = match.group("target")
        relative_path, error = normalize_evidence_target(raw_target)
        line = start_line + text.count("\n", 0, match.start())
        if relative_path is not None or error is not None:
            links.append(EvidenceLink(line, raw_target, relative_path, error))
    return links


def tracked_paths(repo_root: Path) -> tuple[set[str], str | None]:
    completed = subprocess.run(
        ["git", "-C", str(repo_root), "ls-files", "-z"],
        check=False,
        capture_output=True,
    )
    if completed.returncode != 0:
        message = completed.stderr.decode("utf-8", errors="replace").strip()
        return set(), message or "git ls-files failed"
    return {
        item.decode("utf-8", errors="surrogateescape")
        for item in completed.stdout.split(b"\0")
        if item
    }, None


def display_location(report_name: str, start: int, end: int) -> str:
    if start == end:
        return f"{report_name}:{start}"
    return f"{report_name}:{start}-{end}"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--report",
        default="REPORT.md",
        help="report path relative to the repository root (default: REPORT.md)",
    )
    parser.add_argument(
        "--require-tracked",
        action="store_true",
        help="fail when an evidence target is not present in the Git index",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = Path(__file__).resolve().parent.parent
    report_path = (repo_root / args.report).resolve()
    try:
        report_path.relative_to(repo_root)
    except ValueError:
        print(f"ERROR: report path escapes repository: {args.report}", file=sys.stderr)
        return 2
    if not report_path.is_file():
        print(f"ERROR: report does not exist: {args.report}", file=sys.stderr)
        return 2

    try:
        lines = report_path.read_text(encoding="utf-8").splitlines()
    except UnicodeDecodeError as error:
        print(f"ERROR: {args.report} is not valid UTF-8: {error}", file=sys.stderr)
        return 2

    units, fenced = claim_units(lines)
    diagnostics: list[str] = []
    links: list[EvidenceLink] = []
    evidenced_units = 0

    for unit in units:
        unit_links = links_in_text(unit.text, unit.start)
        valid_shape = [link for link in unit_links if link.relative_path is not None]
        if valid_shape:
            evidenced_units += 1
        else:
            location = display_location(args.report, unit.start, unit.end)
            diagnostics.append(
                f"{location}: {unit.kind} is missing a direct inline evidence link; "
                "add [evidence](evidence/<file>) to this claim unit"
            )
        links.extend(unit_links)

    # Also validate visible evidence links that happen to occur in exempt
    # structures, without letting those links satisfy a different claim unit.
    seen_link_sites = {(link.line, link.raw_target) for link in links}
    for index, line in enumerate(lines):
        if index in fenced:
            continue
        for link in links_in_text(line, index + 1):
            site = (link.line, link.raw_target)
            if site not in seen_link_sites:
                links.append(link)
                seen_link_sites.add(site)

    tracked: set[str] = set()
    if args.require_tracked:
        tracked, git_error = tracked_paths(repo_root)
        if git_error:
            diagnostics.append(f".git:1: unable to enumerate tracked files: {git_error}")

    unique_targets: dict[str, int] = {}
    for link in links:
        if link.error:
            diagnostics.append(f"{args.report}:{link.line}: {link.error}: {link.raw_target}")
            continue
        if link.relative_path is None:
            continue
        unique_targets.setdefault(link.relative_path, link.line)

    artifact_contract_passes = 0
    checked_text_artifacts = 0
    for relative_path, report_line in sorted(unique_targets.items()):
        target_path = repo_root / relative_path
        evidence_root = (repo_root / "evidence").resolve()
        try:
            target_path.resolve().relative_to(evidence_root)
        except ValueError:
            diagnostics.append(
                f"{args.report}:{report_line}: evidence target resolves outside evidence/: "
                f"{relative_path}"
            )
            continue
        if not target_path.is_file():
            diagnostics.append(
                f"{args.report}:{report_line}: evidence target does not exist as a file: "
                f"{relative_path}"
            )
            continue
        if args.require_tracked and relative_path not in tracked:
            diagnostics.append(
                f"{args.report}:{report_line}: evidence target is not git-tracked: "
                f"{relative_path}; stage or commit the artifact before relying on it"
            )

        if target_path.suffix.lower() != ".txt":
            continue
        checked_text_artifacts += 1
        try:
            content = target_path.read_text(encoding="utf-8")
        except UnicodeDecodeError as error:
            diagnostics.append(f"{relative_path}:1: evidence file is not valid UTF-8: {error}")
            continue
        missing_fields = [
            label for label, pattern in EVIDENCE_CONTRACT.items() if not pattern.search(content)
        ]
        if missing_fields:
            for field in missing_fields:
                diagnostics.append(
                    f"{relative_path}:1: missing evidence contract field: {field}; "
                    "add an explicit labeled entry"
                )
        else:
            artifact_contract_passes += 1

    type_counts = Counter(unit.kind for unit in units)
    breakdown = ", ".join(
        f"{kind}={type_counts.get(kind, 0)}"
        for kind in ("metadata", "prose paragraph", "list item", "table row")
    )
    for diagnostic in diagnostics:
        print(diagnostic)

    status = "PASS" if not diagnostics else "FAIL"
    print(
        f"{status}: {len(units)} claim units checked ({breakdown}); "
        f"{evidenced_units}/{len(units)} contain direct evidence links; "
        f"{len(unique_targets)} unique evidence targets; "
        f"{artifact_contract_passes}/{checked_text_artifacts} linked .txt artifacts "
        f"satisfy the evidence contract; tracked check="
        f"{'on' if args.require_tracked else 'off'}"
    )
    return 0 if not diagnostics else 1


if __name__ == "__main__":
    raise SystemExit(main())
