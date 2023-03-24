## Instructions

### Structure:

- `.vitepress` - The theme and code that renders content from this repo into a website. Includes Vue 3 components for each piece of the page.
- `data` - Metadata about the content.
   - `data/filters.yml` - The list of filters that can be applied to content
   - `data/filter-groups.yml` - How those filters are grouped into categories
- `pattern` - Folder containers all the patterns published on the website
   - `pattern/<pattern-name>` - A folder containing all the data for a specific published pattern
     - `pattern/<pattern-name>/index.md` - Markdown text file with the content of the pattern page itself.
     - `pattern/<pattern-name>/files` - A folder to hold any other files associated with the pattern, such as code, images, etc
     - `pattern/<pattern-name>/cover.png` - A preview image for the pattern

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