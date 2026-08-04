import { access, readFile, readdir } from "node:fs/promises";
import path from "node:path";

const root = process.cwd();
const output = path.join(root, "docs");
const content = path.join(root, "src", "content", "docs");
const base = "/sevendayshpc";
const routes = [
  "",
  "preface",
  ...Array.from({ length: 7 }, (_, index) => `day${index + 1}`),
  "postface",
];
const failures = [];
const japaneseText = /[ぁ-んァ-ヶ一-龯々]/;

async function fileExists(file) {
  try {
    await access(file);
    return true;
  } catch {
    return false;
  }
}

async function walk(directory) {
  const files = [];
  for (const entry of await readdir(directory, { withFileTypes: true })) {
    const target = path.join(directory, entry.name);
    if (entry.isDirectory()) files.push(...(await walk(target)));
    else files.push(target);
  }
  return files;
}

for (const locale of ["ja", "en"]) {
  for (const route of routes) {
    const source = path.join(content, locale, route, "index.md");
    if (!(await fileExists(source))) failures.push(`Missing source: ${path.relative(root, source)}`);

    const page = path.join(output, locale, route, "index.html");
    if (!(await fileExists(page))) {
      failures.push(`Missing page: ${path.relative(root, page)}`);
      continue;
    }
    const html = await readFile(page, "utf8");
    if (!html.includes(`<html lang="${locale}"`)) {
      failures.push(`Incorrect language metadata: ${path.relative(root, page)}`);
    }
  }
}

for (const route of routes) {
  const jaFile = path.join(content, "ja", route, "index.md");
  const enFile = path.join(content, "en", route, "index.md");
  if (!(await fileExists(jaFile)) || !(await fileExists(enFile))) continue;
  const ja = await readFile(jaFile, "utf8");
  const en = await readFile(enFile, "utf8");

  for (const [label, expression] of [
    ["code fences", /^```/gm],
    ["display-math delimiters", /^\$\$$/gm],
    ["images", /!\[[^\]]*\]\([^)]+\)/g],
    ["section headings", /^##+\s/gm],
  ]) {
    const jaCount = ja.match(expression)?.length ?? 0;
    const enCount = en.match(expression)?.length ?? 0;
    if (jaCount !== enCount) {
      failures.push(`Mismatched ${label} for ${route || "index"}: ja=${jaCount}, en=${enCount}`);
    }
  }

  let inCode = false;
  en.split("\n").forEach((line, index) => {
    if (line.startsWith("```")) {
      inCode = !inCode;
      return;
    }
    if (!inCode && japaneseText.test(line)) {
      failures.push(`Japanese prose remains in ${path.relative(root, enFile)}:${index + 1}`);
    }
  });
}

for (const file of (await walk(output)).filter((file) => file.endsWith(".html"))) {
  const html = await readFile(file, "utf8");
  const routePath = "/" + path.relative(output, file).replace(/index\.html$/, "").replaceAll(path.sep, "/");
  for (const match of html.matchAll(/(?:href|src)="([^"]+)"/g)) {
    const reference = match[1];
    if (/^(?:https?:|mailto:|data:|javascript:)/.test(reference)) continue;
    const resolved = new URL(reference, `https://example.test${base}${routePath}`);
    if (!resolved.pathname.startsWith(`${base}/`)) continue;
    let local = decodeURIComponent(resolved.pathname.slice(base.length));
    let target = path.join(output, local);
    if (local.endsWith("/")) target = path.join(target, "index.html");
    if (!(await fileExists(target))) {
      failures.push(`Broken local reference in ${path.relative(root, file)}: ${reference}`);
    }
  }
}

if (failures.length > 0) {
  console.error([...new Set(failures)].join("\n"));
  process.exit(1);
}

console.log(`Validated ${routes.length * 2} localized pages and all local asset references.`);
