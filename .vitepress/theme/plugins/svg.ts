import fs from 'fs'
import path from 'path'
import { optimize } from 'svgo';

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

      // Crunch the SVG down a bit and clean it up
      const result = optimize(svgContent, {
        plugins: [
          // Convert fill='#000000' into a CSS variable that can adjust to
          // dark mode.
          {
            name: 'apply-css-variables',
            fn: applyVariables,
          },
          'preset-default',
          'removeDimensions',
          // PowerPoint export does weird things with clipping
          // which break some embedded images when you do the conversion
          // to a viewbox.
          {
            name: "removeAttrs",
            params: {
              attrs: "g:clip-path"
            }
          },
          // Simply adds some margin above and below. Note that this
          // completely overrides the inline style attribute, so may need
          // to be adjusted later if there are other inline styles.
          {
            name: 'add-margin',
            fn: applyMargin
          }
        ]
      });
      const optimizedSvgString = result.data;

      // Put the optimized SVG content into the markdown
      token.content = optimizedSvgString;
    }

    return true;
  }

  // Adds this SVG plugin to the list of rules that
  // MarkdownIt will run during markdown parsing.
  md.core.ruler.before('inline', 'svg', parser)
}

// Find all nodes that are filled with solid black.
// We then transform those fills into a CSS variable
// so that black areas of the SVG can adapt to dark/light mode.
function applyVariables(svgNode) {
  if (svgNode.attributes && svgNode.attributes.fill == '#000000') {
    svgNode.attributes.fill = 'var(--bs-emphasis-color)'
  }

  if (svgNode.children) {
    for (const child of svgNode.children) {
      applyVariables(child);
    }
  }
}

function applyMargin(svgNode) {
  if (svgNode.type == 'element' && svgNode.name == 'svg') {
    svgNode.attributes.style = 'margin-top: 20px; margin-bottom: 20px;'
  }
  if (svgNode.children) {
    for (const child of svgNode.children) {
      applyMargin(child);
    }
  }
}