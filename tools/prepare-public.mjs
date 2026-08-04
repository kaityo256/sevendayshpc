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

async function copySection(section, locale) {
  const source = path.join(root, section);
  const destination = path.join(output, locale, section);
  await mkdir(destination, { recursive: true });

  for (const entry of await readdir(source, { withFileTypes: true })) {
    if (entry.name === "README.md" || entry.name === "index.html") continue;

    if (entry.name === "fig") {
      const figureDestination = path.join(destination, "fig");
      await mkdir(figureDestination, { recursive: true });
      for (const figure of await readdir(path.join(source, "fig"), {
        withFileTypes: true,
      })) {
        if (
          !figure.isFile() ||
          !/\.(png|jpg|jpeg|gif|svg)$/i.test(figure.name)
        ) {
          continue;
        }
        await cp(
          path.join(source, "fig", figure.name),
          path.join(figureDestination, figure.name),
        );
      }
      continue;
    }

    await cp(path.join(source, entry.name), path.join(destination, entry.name), {
      recursive: true,
    });
  }
}

await rm(output, { recursive: true, force: true });
await mkdir(output, { recursive: true });
await writeFile(path.join(output, ".nojekyll"), "");

for (const locale of ["ja", "en"]) {
  for (const section of sections) await copySection(section, locale);
}

const overrides = path.join(root, "site-assets", "images", "en");
if (await exists(overrides)) {
  for (const entry of await readdir(overrides, { withFileTypes: true })) {
    if (!entry.isDirectory()) continue;
    await cp(
      path.join(overrides, entry.name),
      path.join(output, "en", entry.name, "fig"),
      { recursive: true, force: true },
    );
  }
}

await cp(path.join(root, "LICENSE"), path.join(output, "LICENSE"));
await cp(path.join(root, "site-assets", "favicon.svg"), path.join(output, "favicon.svg"));
