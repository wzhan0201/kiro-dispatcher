#!/usr/bin/env python3
"""Validate the tracked Firstmate parity handover package."""

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
PIN = "f9a89c3962a5ad0db3ef79756a477053998c2529"
PACKAGE = ROOT / "docs" / "firstmate-parity"
HANDOVER_FILES = [
    ROOT / "Q_IMPLEMENTATION_HANDOVER.md",
    ROOT / "THIRD_PARTY_NOTICES.md",
    PACKAGE / "README.md",
    PACKAGE / "MATRIX.md",
    PACKAGE / "ROADMAP.md",
    PACKAGE / "VERIFICATION.md",
]
ALLOWED_STATUSES = {
    "NOT_STARTED",
    "PARTIAL",
    "IN_PROGRESS",
    "BLOCKED",
    "UNVERIFIED_LIVE",
    "VERIFIED",
}

errors: list[str] = []

for path in HANDOVER_FILES:
    if not path.is_file():
        errors.append(f"missing handover file: {path.relative_to(ROOT)}")
        continue
    text = path.read_text(encoding="utf-8")
    if PIN not in text:
        errors.append(f"missing pinned SHA: {path.relative_to(ROOT)}")
    for target in re.findall(r"\[[^\]]+\]\(([^)]+)\)", text):
        if "://" in target or target.startswith("#"):
            continue
        relative_target = target.split("#", 1)[0]
        if relative_target and not (path.parent / relative_target).resolve().exists():
            errors.append(f"broken link in {path.relative_to(ROOT)}: {target}")

matrix_path = PACKAGE / "MATRIX.md"
if matrix_path.is_file():
    matrix = matrix_path.read_text(encoding="utf-8")
    table_rows = re.findall(r"^\| ([A-K]\d{2}) \|.*?\| ([A-Z_]+) \|", matrix, re.MULTILINE)
    ids = [row_id for row_id, _ in table_rows]
    statuses = [status for _, status in table_rows]
    if not ids:
        errors.append("parity matrix has no recognized rows")
    if len(ids) != len(set(ids)):
        duplicates = sorted({row_id for row_id in ids if ids.count(row_id) > 1})
        errors.append(f"duplicate matrix IDs: {', '.join(duplicates)}")
    invalid_statuses = sorted(set(statuses) - ALLOWED_STATUSES)
    if invalid_statuses:
        errors.append(f"invalid matrix statuses: {', '.join(invalid_statuses)}")

    roadmap_path = PACKAGE / "ROADMAP.md"
    if roadmap_path.is_file():
        roadmap = roadmap_path.read_text(encoding="utf-8")
        covered_ids: set[str] = set()
        for specification in re.findall(r"^\*\*Rows:\*\* (.+)$", roadmap, re.MULTILINE):
            for match in re.finditer(r"\b([A-K])(\d{2})(?:\s*[–-]\s*([A-K])(\d{2}))?\b", specification):
                start_group, start_number, end_group, end_number = match.groups()
                if end_number is None:
                    covered_ids.add(f"{start_group}{start_number}")
                    continue
                if start_group != end_group or int(end_number) < int(start_number):
                    errors.append(f"invalid roadmap matrix range: {match.group(0)}")
                    continue
                covered_ids.update(
                    f"{start_group}{number:02d}"
                    for number in range(int(start_number), int(end_number) + 1)
                )
        unknown_ids = sorted(covered_ids - set(ids))
        if unknown_ids:
            errors.append(f"roadmap references unknown matrix IDs: {', '.join(unknown_ids)}")
        uncovered_ids = sorted(set(ids) - covered_ids)
        if uncovered_ids:
            errors.append(f"matrix IDs missing from roadmap phases: {', '.join(uncovered_ids)}")

agent_path = ROOT / ".kiro" / "agents" / "dispatcher.json"
if agent_path.is_file():
    agent = agent_path.read_text(encoding="utf-8")
    for forbidden in ("Q_IMPLEMENTATION_HANDOVER", "firstmate-parity", "THIRD_PARTY_NOTICES"):
        if forbidden in agent:
            errors.append(f"runtime dispatcher unexpectedly loads handover resource: {forbidden}")

if errors:
    print("handover validation: FAIL", file=sys.stderr)
    for error in errors:
        print(f"- {error}", file=sys.stderr)
    raise SystemExit(1)

print(f"handover validation: PASS ({len(ids)} unique matrix rows, pin {PIN[:8]})")
