## Instructions

### Setup:

Ensure that Node >v18 is installed locally. Then run:

```
npm install
```

### Preview:

When writing a new piece of content, or when developing changes to the websites theme or styling, use the following command to run a local copy of the website which has live refresh when you change a file:

```
npm run-script docs:dev
```

Open `localhost:5173`

### Build and view:

This builds a fully static version of the website which is optimized for load speed and web hosting:

```
npm run-script docs:build
npm run-script docs:preview
```

Open `localhost:4173`

### Publish:

Copy the contents of `.vitepress/dist` to any static web hosting service.