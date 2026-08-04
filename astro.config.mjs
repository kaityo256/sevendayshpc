import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";
import { unified } from "@astrojs/markdown-remark";
import remarkMath from "remark-math";
import rehypeKatex from "rehype-katex";

export default defineConfig({
  site: "https://kaityo256.github.io",
  base: "/sevendayshpc",
  outDir: "./docs",
  publicDir: "./.generated/public",
  markdown: {
    processor: unified({
      remarkPlugins: [remarkMath],
      rehypePlugins: [rehypeKatex],
    }),
  },
  integrations: [
    starlight({
      title: {
        ja: "一週間でなれる！スパコンプログラマ",
        en: "Become an HPC Programmer in Seven Days!",
      },
      description: "A seven-day introduction to supercomputer programming",
      defaultLocale: "ja",
      locales: {
        ja: { label: "日本語", lang: "ja" },
        en: { label: "English", lang: "en" },
      },
      social: [
        {
          icon: "github",
          label: "GitHub",
          href: "https://github.com/kaityo256/sevendayshpc",
        },
      ],
      sidebar: [
        "index",
        "preface",
        "day1",
        "day2",
        "day3",
        "day4",
        "day5",
        "day6",
        "day7",
        "postface",
      ],
      customCss: ["./src/styles/custom.css"],
      lastUpdated: true,
    }),
  ],
});
