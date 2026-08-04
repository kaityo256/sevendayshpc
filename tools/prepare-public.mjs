import { access, cp, mkdir, readdir, rm, writeFile } from "node:fs/promises";
import path from "node:path";

const root = process.cwd();
const output = path.join(root, ".generated", "public");
const sections = [
  "preface",
  ...Array.from({ length: 7 }, (_, index) => `day${index + 1}`),
  "postface",
];

async function exists(target) {
  try {
    await access(target);
    return true;
  } catch {
    return false;
  }
}

async function copyExamples(section, locale) {
  const source = path.join(root, "examples", section);
  const destination = path.join(output, locale, section);
  await mkdir(destination, { recursive: true });

  if (!(await exists(source))) return;
  await cp(source, destination, {
    filter: (entry) => path.basename(entry) !== ".gitignore",
    force: true,
    recursive: true,
  });
}

async function copyImages(sourceLocale, destinationLocale, section) {
  const source = path.join(root, "site-assets", "images", sourceLocale, section);
  if (!(await exists(source))) return;

  const destination = path.join(output, destinationLocale, section, "fig");
  await mkdir(destination, { recursive: true });
  for (const entry of await readdir(source, { withFileTypes: true })) {
    if (!entry.isFile() || !/\.(png|jpg|jpeg|gif|svg)$/i.test(entry.name)) {
      continue;
    }
    await cp(path.join(source, entry.name), path.join(destination, entry.name), {
      force: true,
      recursive: true,
    });
  }
}

await rm(output, { recursive: true, force: true });
await mkdir(output, { recursive: true });
await writeFile(path.join(output, ".nojekyll"), "");

for (const locale of ["ja", "en"]) {
  for (const section of sections) await copyExamples(section, locale);
}

for (const section of sections) {
  await copyImages("ja", "ja", section);
  await copyImages("ja", "en", section);
  await copyImages("en", "en", section);
}

await cp(path.join(root, "LICENSE"), path.join(output, "LICENSE"));
await cp(path.join(root, "site-assets", "favicon.svg"), path.join(output, "favicon.svg"));
