# Hugo Site Redesign Plan

## New Features to Add

### 1. Modern Theme
- Switch to PaperMod theme (fast, feature-rich, good documentation)
- Dark/light mode toggle
- Responsive design
- Search functionality

### 2. Enhanced Pages
- **Home**: Hero section with animated service status
- **/services**: Live dashboard of all homelab services
- **/uses**: Complete hardware/software stack
- **/projects**: Showcase of self-hosted projects
- **/now**: Current activities and focus
- **/privacy**: Privacy guides and recommendations
- **/tutorials**: Homelab setup tutorials

### 3. Interactive Features
- Service status widget (from Uptime Kuma API)
- Server metrics display
- RSS/JSON feeds
- Webmentions support
- IndieWeb microformats

### 4. Content Structure
```
content/
├── _index.md          # Home page
├── posts/             # Blog posts
├── tutorials/         # How-to guides
├── projects/          # Project showcases
├── services/          # Service documentation
└── about/             # About pages
    ├── _index.md
    ├── uses.md
    └── now.md
```

### 5. Technical Improvements
- SEO optimization
- Open Graph meta tags
- Sitemap generation
- Fast loading (lazy loading images)
- PWA capabilities

## Implementation Steps

1. Install PaperMod theme
2. Update configuration
3. Create new page templates
4. Migrate existing content
5. Add interactive components
6. Deploy and test
