#!/usr/bin/env python3
"""Lightweight structural/reference validator for the project's YAML docs.

Requires PyYAML. This checks syntax and internal references; it cannot prove
semantic correctness, user-intent coverage, or correctness of implementation.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path
from typing import Any

try:
    import yaml
except ImportError:
    print("ERROR: PyYAML is required. Install with: python -m pip install -r requirements-dev.txt")
    raise SystemExit(2)

ROOT = Path(__file__).resolve().parents[2]
ERRORS: list[str] = []
WARNINGS: list[str] = []


def error(path: Path, message: str) -> None:
    ERRORS.append(f"{path.relative_to(ROOT)}: {message}")


def warning(path: Path, message: str) -> None:
    WARNINGS.append(f"{path.relative_to(ROOT)}: {message}")


def load_yaml(path: Path) -> Any:
    try:
        with path.open("r", encoding="utf-8") as stream:
            return yaml.safe_load(stream)
    except Exception as exc:  # YAML parser exceptions may vary by PyYAML version.
        error(path, f"invalid YAML: {exc}")
        return None


def records(folder: Path, prefix: str) -> dict[str, tuple[Path, dict[str, Any]]]:
    result: dict[str, tuple[Path, dict[str, Any]]] = {}
    if not folder.exists():
        return result
    for path in sorted(folder.glob(f"{prefix}-*.yaml")):
        data = load_yaml(path)
        if not isinstance(data, dict):
            error(path, "record must be a YAML mapping")
            continue
        rid = data.get("id")
        if not isinstance(rid, str) or not rid:
            error(path, "missing non-empty id")
            continue
        if rid in result:
            error(path, f"duplicate id {rid} (also in {result[rid][0].relative_to(ROOT)})")
        result[rid] = (path, data)
    return result


def main() -> int:
    # Parse every YAML file, including templates and examples, to catch syntax errors.
    for path in sorted(ROOT.rglob("*.yaml")) + sorted(ROOT.rglob("*.yml")):
        if path.is_file():
            load_yaml(path)

    glossary_path = ROOT / "design/floor1/glossary.yaml"
    glossary = load_yaml(glossary_path) if glossary_path.exists() else None
    if not isinstance(glossary, dict):
        error(glossary_path, "glossary must be a YAML mapping")
        glossary = {}
    for section in ("roles", "entities", "actions"):
        if not isinstance(glossary.get(section), dict):
            error(glossary_path, f"section {section!r} must be a mapping")
            glossary[section] = {}

    roles = set(glossary["roles"])
    entities = set(glossary["entities"])
    actions = set(glossary["actions"])
    if "project" not in entities:
        error(glossary_path, "reserved root entity 'project' is required")

    stories = records(ROOT / "design/floor1/stories", "US")
    reqs = records(ROOT / "design/floor2/requirements", "REQ")
    constraints = records(ROOT / "design/floor2/constraints", "CON")
    comms = records(ROOT / "design/floor2/diagrams/comm", "COMM")
    strings = records(ROOT / "design/floor2/diagrams/string", "STR")

    # Check records stored in the working areas only; examples/templates are illustrative.
    for rid, (path, data) in stories.items():
        if not re.fullmatch(r"US-\d{3,}", rid):
            error(path, f"id {rid!r} must match US-NNN")
        for field, available in (("role", roles), ("object", entities), ("action", actions)):
            value = data.get(field)
            if not isinstance(value, str) or not value:
                error(path, f"field {field!r} must be a non-empty glossary key")
            elif value not in available:
                error(path, f"{field} key {value!r} is missing from glossary")
        if data.get("type", "atomic") == "scenario":
            children = data.get("composed_of", [])
            if not isinstance(children, list) or not children:
                error(path, "scenario must have a non-empty composed_of list")
            else:
                for child in children:
                    if child not in stories and child != rid:
                        # Referenced files may have been added in a later pass; report clearly.
                        error(path, f"composed_of references missing story {child!r}")
        if data.get("status") == "confirmed" and data.get("unresolved"):
            error(path, "confirmed story still has unresolved items")

    for rid, (path, data) in reqs.items():
        if not re.fullmatch(r"REQ-\d{3,}", rid):
            error(path, f"id {rid!r} must match REQ-NNN")
        covers = data.get("covers", [])
        if not isinstance(covers, list) or not covers:
            error(path, "REQ must have at least one covers entry or document an approved exception")
        for item in covers if isinstance(covers, list) else []:
            if not isinstance(item, dict):
                error(path, "each covers entry must be a mapping")
                continue
            story = item.get("story")
            if story not in stories:
                error(path, f"covers references missing story {story!r}")
            if item.get("part") not in {"precondition", "postcondition", "both"}:
                error(path, f"invalid covers.part value {item.get('part')!r}")
            if not item.get("argument"):
                error(path, "covers entry requires a non-empty argument")
        for field, available in (("entities", entities), ("actions", actions)):
            values = data.get(field, [])
            if not isinstance(values, list):
                error(path, f"{field} must be a list")
                continue
            for value in values:
                if value not in available:
                    error(path, f"{field} references missing glossary key {value!r}")
        dom = data.get("dom")
        if dom not in entities:
            error(path, f"dom {dom!r} is not a glossary entity")
        fs = data.get("formalization", {})
        if isinstance(fs, dict):
            constraint_refs = fs.get("constraints", [])
            # Read the old singular key for compatibility with early drafts.
            if fs.get("constraint") and not constraint_refs:
                constraint_refs = [fs["constraint"]]
                warning(path, "formalization.constraint is legacy; prefer formalization.constraints: []")
            if not isinstance(constraint_refs, list):
                error(path, "formalization.constraints must be a list of CON IDs")
            else:
                for constraint_ref in constraint_refs:
                    if constraint_ref not in constraints:
                        warning(path, f"formalization points to constraint {constraint_ref!r} not found in floor2 yet")

    for cid, (path, data) in constraints.items():
        if not re.fullmatch(r"CON-\d{3,}", cid):
            error(path, f"id {cid!r} must match CON-NNN")
        req = data.get("requirement")
        if req not in reqs:
            error(path, f"requirement reference {req!r} does not resolve")
        if data.get("dom") not in entities:
            error(path, f"dom {data.get('dom')!r} is not a glossary entity")
        if not isinstance(data.get("signature", {}), dict):
            error(path, "signature must be a mapping")
        decomposition = data.get("decomposition", {})
        if isinstance(decomposition, dict):
            for child in decomposition.get("children", []) or []:
                if child not in constraints:
                    warning(path, f"child constraint {child!r} not found in floor2 yet")
            parent = decomposition.get("parent")
            if parent and parent not in constraints:
                warning(path, f"parent constraint {parent!r} not found in floor2 yet")

    for group_name, group in (("COMM", comms), ("STR", strings)):
        for rid, (path, data) in group.items():
            if not re.fullmatch(group_name + r"-\d{3,}", rid):
                error(path, f"id {rid!r} must match {group_name}-NNN")
            refs = data.get("covers", [])
            for ref in refs if isinstance(refs, list) else []:
                if isinstance(ref, str) and (ref.startswith("US-") and ref not in stories):
                    error(path, f"covers references missing story {ref!r}")
                if isinstance(ref, str) and (ref.startswith("REQ-") and ref not in reqs):
                    error(path, f"covers references missing requirement {ref!r}")

    nav_path = ROOT / "design/trace/nav-log.yaml"
    nav = load_yaml(nav_path) if nav_path.exists() else None
    if not isinstance(nav, dict) or not isinstance(nav.get("entries", []), list):
        error(nav_path, "nav-log must contain entries: []")
    else:
        seen = set()
        for entry in nav["entries"]:
            if not isinstance(entry, dict):
                error(nav_path, "each trace entry must be a mapping")
                continue
            rid = entry.get("id")
            if not isinstance(rid, str) or not re.fullmatch(r"NAV-\d{3,}", rid):
                error(nav_path, f"invalid trace entry id {rid!r}; expected NAV-NNN")
            if rid in seen:
                error(nav_path, f"duplicate trace entry id {rid!r}")
            seen.add(rid)

    coverage_path = ROOT / "design/trace/coverage.yaml"
    coverage = load_yaml(coverage_path) if coverage_path.exists() else None
    if not isinstance(coverage, dict) or not isinstance(coverage.get("sources", []), list):
        error(coverage_path, "coverage file must contain sources: []")
    else:
        for item in coverage["sources"]:
            if not isinstance(item, dict):
                error(coverage_path, "each source coverage item must be a mapping")
                continue
            if item.get("disposition") == "covered":
                if not item.get("covered_by"):
                    error(coverage_path, f"{item.get('id')} marked covered but has empty covered_by")
                for ref in item.get("covered_by", []):
                    if ref.startswith("US-") and ref not in stories:
                        error(coverage_path, f"source coverage references missing story {ref!r}")
                    elif ref.startswith("REQ-") and ref not in reqs:
                        error(coverage_path, f"source coverage references missing requirement {ref!r}")
            elif item.get("disposition") not in {"open_question", "out_of_scope", "duplicate", "deferred", "context_only", "not_adopted", "covered"}:
                error(coverage_path, f"invalid disposition {item.get('disposition')!r}")

    for msg in WARNINGS:
        print("WARNING:", msg)
    for msg in ERRORS:
        print("ERROR:", msg)
    if ERRORS:
        print(f"\nValidation failed: {len(ERRORS)} error(s), {len(WARNINGS)} warning(s).")
        return 1
    print(f"Validation passed: YAML syntax and working-area references OK ({len(WARNINGS)} warning(s)).")
    print("Note: this tool does not prove semantic completeness, user approval, or runtime correctness.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
