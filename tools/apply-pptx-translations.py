#!/usr/bin/env python3
from __future__ import annotations

import csv
import re
import shutil
import zipfile
from collections import defaultdict
from copy import deepcopy
from pathlib import Path
from tempfile import TemporaryDirectory

from lxml import etree


ROOT = Path(__file__).resolve().parents[1]
SOURCES_DIR = ROOT / "site-assets" / "sources"
CSV_COLUMNS = [
    "day",
    "slide_number",
    "shape_id",
    "shape_name",
    "shape_type",
    "japanese",
    "english",
    "status",
    "notes",
]
NS = {
    "a": "http://schemas.openxmlformats.org/drawingml/2006/main",
    "p": "http://schemas.openxmlformats.org/presentationml/2006/main",
    "r": "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
    "ct": "http://schemas.openxmlformats.org/package/2006/content-types",
    "pr": "http://schemas.openxmlformats.org/package/2006/relationships",
}
SLIDE_CONTENT_TYPE = "application/vnd.openxmlformats-officedocument.presentationml.slide+xml"


def unescape_csv_text(text: str) -> str:
    return text.replace(r"\n", "\n")


def load_rows(csv_path: Path) -> dict[int, dict[str, str]]:
    with csv_path.open(encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f)
        if reader.fieldnames != CSV_COLUMNS:
            raise ValueError(f"{csv_path}: unexpected columns: {reader.fieldnames}")
        rows = list(reader)

    by_slide: dict[int, dict[str, str]] = defaultdict(dict)
    errors = []
    for row_number, row in enumerate(rows, start=2):
        if row["status"] != "approved":
            errors.append(f"row {row_number}: status is {row['status']!r}")
            continue
        if not row["english"]:
            errors.append(f"row {row_number}: approved row has empty english")
            continue
        by_slide[int(row["slide_number"])][row["shape_id"]] = unescape_csv_text(row["english"])

    if errors:
        details = "\n".join(f"- {e}" for e in errors[:20])
        raise ValueError(f"{csv_path}: cannot apply unapproved or incomplete rows\n{details}")
    return by_slide


def parse_xml(path: Path) -> etree._ElementTree:
    parser = etree.XMLParser(remove_blank_text=False)
    return etree.parse(str(path), parser)


def write_xml(tree: etree._ElementTree, path: Path) -> None:
    tree.write(str(path), xml_declaration=True, encoding="UTF-8", standalone=True)


def next_slide_part_names(work_dir: Path, count: int) -> list[str]:
    slide_dir = work_dir / "ppt" / "slides"
    used = set()
    for path in slide_dir.glob("slide*.xml"):
        match = re.fullmatch(r"slide(\d+)\.xml", path.name)
        if match:
            used.add(int(match.group(1)))
    names = []
    candidate = max(used, default=0) + 1
    while len(names) < count:
        if candidate not in used:
            names.append(f"slides/slide{candidate}.xml")
        candidate += 1
    return names


def relationship_target_to_part(target: str) -> str:
    return target if target.startswith("slides/") else target.removeprefix("ppt/")


def replace_shape_text(slide_tree: etree._ElementTree, shape_id: str, english: str) -> bool:
    base_id, table_cell = split_shape_id(shape_id)
    shape = find_shape_by_id(slide_tree.getroot(), base_id)
    if shape is None:
        return False

    if table_cell is not None:
        return replace_table_cell_text(shape, table_cell, english)
    return replace_text_container(shape, english)


def split_shape_id(shape_id: str) -> tuple[str, tuple[int, int] | None]:
    match = re.fullmatch(r"(\d+)\[(\d+),(\d+)\]", shape_id)
    if match:
        return match.group(1), (int(match.group(2)), int(match.group(3)))
    return shape_id, None


def find_shape_by_id(root: etree._Element, shape_id: str) -> etree._Element | None:
    for element in root.xpath(".//p:sp | .//p:graphicFrame | .//p:grpSp", namespaces=NS):
        c_nv_pr = element.xpath("./p:nvSpPr/p:cNvPr | ./p:nvGraphicFramePr/p:cNvPr | ./p:nvGrpSpPr/p:cNvPr", namespaces=NS)
        if c_nv_pr and c_nv_pr[0].get("id") == shape_id:
            return element
    return None


def replace_table_cell_text(shape: etree._Element, cell_position: tuple[int, int], english: str) -> bool:
    row_index, column_index = cell_position
    rows = shape.xpath(".//a:tbl/a:tr", namespaces=NS)
    if row_index >= len(rows):
        return False
    cells = rows[row_index].xpath("./a:tc", namespaces=NS)
    if column_index >= len(cells):
        return False
    return replace_text_container(cells[column_index], english)


def replace_text_container(container: etree._Element, english: str) -> bool:
    tx_body = find_text_body(container)
    if tx_body is None:
        return False

    paragraphs = tx_body.findall("./a:p", namespaces=NS)
    if not paragraphs:
        return False

    template_paragraph = deepcopy(paragraphs[0])
    template_run = first_run(template_paragraph)
    lines = english.split("\n") or [""]

    for paragraph in paragraphs:
        tx_body.remove(paragraph)

    for line in lines:
        paragraph = deepcopy(template_paragraph)
        clear_paragraph_text(paragraph)
        run = first_run(paragraph)
        if run is None:
            run = deepcopy(template_run) if template_run is not None else make_run()
            insert_run(paragraph, run)
        text = run.find("./a:t", namespaces=NS)
        if text is None:
            text = etree.SubElement(run, f"{{{NS['a']}}}t")
        text.text = line
        tx_body.append(paragraph)
    return True


def find_text_body(container: etree._Element) -> etree._Element | None:
    bodies = container.xpath(".//p:txBody | .//a:txBody", namespaces=NS)
    return bodies[0] if bodies else None


def first_run(paragraph: etree._Element) -> etree._Element | None:
    run = paragraph.find("./a:r", namespaces=NS)
    if run is not None:
        return run
    return paragraph.find("./a:fld", namespaces=NS)


def clear_paragraph_text(paragraph: etree._Element) -> None:
    for child in list(paragraph):
        if child.tag in {f"{{{NS['a']}}}r", f"{{{NS['a']}}}fld", f"{{{NS['a']}}}br"}:
            paragraph.remove(child)


def insert_run(paragraph: etree._Element, run: etree._Element) -> None:
    paragraph_properties = paragraph.find("./a:pPr", namespaces=NS)
    if paragraph_properties is None:
        paragraph.insert(0, run)
        return
    paragraph.insert(paragraph.index(paragraph_properties) + 1, run)


def make_run() -> etree._Element:
    run = etree.Element(f"{{{NS['a']}}}r")
    etree.SubElement(run, f"{{{NS['a']}}}rPr", lang="en-US")
    etree.SubElement(run, f"{{{NS['a']}}}t")
    return run


def apply_to_slide(slide_path: Path, replacements: dict[str, str]) -> list[str]:
    tree = parse_xml(slide_path)
    missing = []
    for shape_id, english in replacements.items():
        if not replace_shape_text(tree, shape_id, english):
            missing.append(shape_id)
    write_xml(tree, slide_path)
    return missing


def max_relationship_id(rels_root: etree._Element) -> int:
    max_id = 0
    for rel in rels_root.findall("./pr:Relationship", namespaces=NS):
        rid = rel.get("Id", "")
        match = re.fullmatch(r"rId(\d+)", rid)
        if match:
            max_id = max(max_id, int(match.group(1)))
    return max_id


def add_content_type(content_types_path: Path, slide_part: str) -> None:
    tree = parse_xml(content_types_path)
    root = tree.getroot()
    part_name = f"/ppt/{slide_part}"
    exists = root.xpath(f"./ct:Override[@PartName='{part_name}']", namespaces=NS)
    if not exists:
        etree.SubElement(
            root,
            f"{{{NS['ct']}}}Override",
            PartName=part_name,
            ContentType=SLIDE_CONTENT_TYPE,
        )
    write_xml(tree, content_types_path)


def duplicate_and_translate_pptx(pptx_path: Path, output_path: Path, rows_by_slide: dict[int, dict[str, str]]) -> list[str]:
    missing: list[str] = []
    with TemporaryDirectory(prefix="pptx-apply-") as tmp:
        work_dir = Path(tmp)
        with zipfile.ZipFile(pptx_path) as archive:
            archive.extractall(work_dir)

        presentation_path = work_dir / "ppt" / "presentation.xml"
        presentation_rels_path = work_dir / "ppt" / "_rels" / "presentation.xml.rels"
        content_types_path = work_dir / "[Content_Types].xml"
        pres_tree = parse_xml(presentation_path)
        rels_tree = parse_xml(presentation_rels_path)
        pres_root = pres_tree.getroot()
        rels_root = rels_tree.getroot()
        sld_id_lst = pres_root.find("./p:sldIdLst", namespaces=NS)
        if sld_id_lst is None:
            raise ValueError(f"{pptx_path}: missing p:sldIdLst")

        rel_by_id = {rel.get("Id"): rel for rel in rels_root.findall("./pr:Relationship", namespaces=NS)}
        slide_ids = list(sld_id_lst.findall("./p:sldId", namespaces=NS))
        new_slide_parts = next_slide_part_names(work_dir, len(slide_ids))
        next_rel = max_relationship_id(rels_root) + 1
        next_slide_id = max(int(sld_id.get("id")) for sld_id in slide_ids) + 1

        new_order = []
        for index, sld_id in enumerate(slide_ids, start=1):
            new_order.append(sld_id)
            rel_id = sld_id.get(f"{{{NS['r']}}}id")
            rel = rel_by_id[rel_id]
            original_part = relationship_target_to_part(rel.get("Target"))
            new_part = new_slide_parts[index - 1]

            original_slide_path = work_dir / "ppt" / original_part
            new_slide_path = work_dir / "ppt" / new_part
            shutil.copy2(original_slide_path, new_slide_path)

            original_rels = original_slide_path.parent / "_rels" / f"{original_slide_path.name}.rels"
            new_rels = new_slide_path.parent / "_rels" / f"{new_slide_path.name}.rels"
            if original_rels.exists():
                new_rels.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(original_rels, new_rels)

            if index in rows_by_slide:
                missing.extend(f"slide {index} shape {shape_id}" for shape_id in apply_to_slide(new_slide_path, rows_by_slide[index]))

            new_rel_id = f"rId{next_rel}"
            next_rel += 1
            etree.SubElement(
                rels_root,
                f"{{{NS['pr']}}}Relationship",
                Id=new_rel_id,
                Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide",
                Target=new_part,
            )
            new_sld_id = etree.Element(f"{{{NS['p']}}}sldId")
            new_sld_id.set("id", str(next_slide_id))
            new_sld_id.set(f"{{{NS['r']}}}id", new_rel_id)
            next_slide_id += 1
            new_order.append(new_sld_id)
            add_content_type(content_types_path, new_part)

        for sld_id in list(sld_id_lst):
            sld_id_lst.remove(sld_id)
        for sld_id in new_order:
            sld_id_lst.append(sld_id)

        write_xml(pres_tree, presentation_path)
        write_xml(rels_tree, presentation_rels_path)

        with zipfile.ZipFile(output_path, "w", compression=zipfile.ZIP_DEFLATED) as archive:
            for path in sorted(work_dir.rglob("*")):
                if path.is_file():
                    archive.write(path, path.relative_to(work_dir).as_posix())
    return missing


def main() -> int:
    all_missing = []
    for pptx_path in sorted(SOURCES_DIR.glob("day*/fig.pptx")):
        day_dir = pptx_path.parent
        csv_path = day_dir / "translations.csv"
        output_path = day_dir / "fig-ja-en.pptx"
        rows_by_slide = load_rows(csv_path)
        missing = duplicate_and_translate_pptx(pptx_path, output_path, rows_by_slide)
        all_missing.extend(f"{day_dir.name}: {item}" for item in missing)
        print(f"Wrote {output_path.relative_to(ROOT)}")

    if all_missing:
        print("Missing replacement targets:")
        for item in all_missing:
            print(f"- {item}")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
