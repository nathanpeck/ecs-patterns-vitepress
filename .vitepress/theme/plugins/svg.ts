import fs from 'fs'
import path from 'path'
import { parseSync, stringify } from 'svgson'
import { decode } from 'html-entities';

import type { RuleBlock } from 'markdown-it/lib/parser_block'

// This plugin loads and inlines an SVG into the content.
// It also supports several SVG transformations that make
// SVG's display better. Can easily be extended with more
// transforms as needed.
export const svgPlugin = (md: MarkdownIt, srcDir: string) => {
  const parser: RuleBlock = (state, startLine, endLine, silent) => {
    const tokens = state.tokens;

    for (let token of tokens) {
      if (token.type !== 'inline') {
        continue;
      }

      // Check the trigger sequence for this plugin.
      if (!token.content.startsWith('!!!')) {
        continue;
      }

      // Last token in the line is the filename to load
      const originalContent = token.content.split(' ');
      const svgPath = originalContent[originalContent.length - 1]
        .trim()
        .replace(/^@/, srcDir)
        .trim()

      // Now put the filename together
      const svgFilename = path.resolve(svgPath);
      const isAFile = fs.lstatSync(svgFilename).isFile()

      if (!isAFile) {
        token.content = `SVG not found: ${svgFilename}`
        continue;
      }

      let svgContent = fs.readFileSync(svgFilename, 'utf8')

      // Convert the SVG into an HAST tree for manipulation
      const parsedSvg = parseSync(svgContent);

      // Apply some rules that will make the SVG look better
      enforceViewbox(parsedSvg);
      applyVariables(parsedSvg);
      applyMargin(parsedSvg);
      fixEntities(parsedSvg);

      // Synthesize the HAST tree back into an SVG
      token.content = stringify(parsedSvg);
    }

    return true;
  }

  // Adds this SVG plugin to the list of rules that
  // MarkdownIt will run during markdown parsing.
  md.core.ruler.before('inline', 'svg', parser)
}

// Transform any static width and height into a viewbox.
// This makes the SVG scale with the page width nicely.
function enforceViewbox(svg) {
  const width = svg.attributes.width;
  const height = svg.attributes.height;

  if (width && height) {
    svg.attributes.viewBox = `0 0 ${width} ${height}`;
    delete svg.attributes.width;
    delete svg.attributes.height;
  }
}

// Find all nodes that are filled with solid black.
// We then transform those fills into a CSS variable
// so that black areas of the SVG can adapt to dark/light mode.
function applyVariables(svgNode) {
  if (svgNode.attributes.fill) {
    if (svgNode.attributes.fill == '#000000') {
      svgNode.attributes.fill = 'var(--bs-emphasis-color)'
    }
  }

  if (svgNode.children) {
    for (const child of svgNode.children) {
      applyVariables(child);
    }
  }
}

// Simply adds some margin above and below. Note that this
// completely overrides the inline style attribute, so may need
// to be adjusted later if there are other inline styles.
function applyMargin(svg) {
  svg.attributes.style = 'margin-top: 20px; margin-bottom: 20px;'
}

// Decodes all HTML entities in the text. This is used because
// the svgson library already handles entities in text by wrapping
// them in a CDATA block. (https://github.com/elrumordelaluz/svgson/issues/27)
function fixEntities(svgNode) {
  if (svgNode.type == 'text') {
    svgNode.value = decode(svgNode.value);
  }

  if (svgNode.children) {
    for (const child of svgNode.children) {
      fixEntities(child);
    }
  }
}