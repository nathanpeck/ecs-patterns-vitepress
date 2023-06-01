## Instructions

### Structure:

- `.vitepress` - The theme and code that renders content from this repo into a website. Includes Vue 3 components for each piece of the page.
- `data` - Metadata about the content.
   - `data/filters.yml` - The list of filters that can be applied to content
   - `data/filter-groups.yml` - How those filters are grouped into categories
   - `data/authors.yml` - A list of the metadata for the pattern authors
- `pattern` - Folder contains all the patterns published on the website
   - `pattern/<pattern-name>` - A folder containing all the data for a specific published pattern
     - `pattern/<pattern-name>/index.md` - Markdown text file with the content of the pattern page itself.
     - `pattern/<pattern-name>/files` - A folder to hold any other files associated with the pattern, such as code, images, etc
- `author` - Folder contains the detail pages for each pattern author
    - `author/<authorId>.md` - The custom bio content for each author profile page.

### Markdown:

Details on available Markdown extensions are available here: https://vitepress.dev/guide/markdown

Additionally, there are custom Vue components available inside of the markdown such as:

YouTube:
```
<youtube id="RTeB7Ho88bg" />
```

Code from a file can be imported and embedded as a code widget using the following syntax:
```
<<< @/pattern/ecs-delete-task-definition/files/delete-tasks.sh
```

Import a SVG and embed it in the page:
```
!!! @/pattern/ecs-task-events-capture-cloudwatch/task-history.svg
```

In order to generate an SVG diagram for the site the following process should be followed:
1. Create a PowerPoint presentation, and create your diagram using standard shapes. Images should be kept minimal and small as they will be embedded in the SVG as base64. Recommend using Arial font exclusively. Use solid black (`#000000`) for all text. For arrows use a gray color that works in both light and dark mode.
2. Select all elements on the page and right click on the selection. Save as image, and choose the SVG format.
3. Now import the exported SVG file into your Markdown as shown above. The SVG plugin will automatically convert solid black (`#000000`) into a CSS variable that adjusts to dark/light mode. All other elements should be designed in such a way to look good on both light and dark mode.
4. Save the source PowerPoint into the same folder inside the pattern. This is necessary in case we need to make edits and export the SVG again in the future.

For the code see .vitepress/theme/plugins/svg.ts


### Setup:

Ensure that Node >v18 is installed locally. Then run:

```
npm install
```

### Preview:

When writing a new piece of content, or when developing changes to the websites theme or styling, use the following command to run a local copy of the website which has live refresh when you change a file:

```
npm run-script dev
```

Open `localhost:5173`

### Build and view:

This builds a fully static version of the website which is optimized for load speed and web hosting:

```
npm run-script build
npm run-script preview
```

Open `localhost:4173`

### Publish:

Copy the contents of `.vitepress/dist` to any static web hosting service.