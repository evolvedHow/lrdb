# lrdb — Local Redistricting Database

Interactive map of local redistricting practices across Georgia.
Part of the [Fair Districts GA](https://fairdistrictsga.org) toolset.

---

## Purpose

lrdb documents how every county commission, city council, and school board in
Georgia conducts its redistricting process.  For each jurisdiction it records:

- Whether redistricting was **required** for the 2020 cycle
- Whether the jurisdiction has **written requirements or guidelines** for drawing
  maps
- Whether the process was locally controlled or **overridden by the state
  legislature**
- Whether there was meaningful **public participation**
- Whether there was documented **controversy**
- Whether elections are **at-large** (no districts to redraw)
- **Timeline** of key process dates
- **Scorecard** rating process quality

The data is manually researched and compiled by FDGA staff.

**Audience:** Advocates, organizers, local officials, journalists.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Svelte 3.59 |
| Build | Rollup 2 |
| Map | Leaflet 1.7.1 + Leaflet EasyButton 2.4 |
| Static server | sirv-cli |
| Data processing | R (shapefile merging + typo fixes) |
| Package manager | npm |

---

## Directory Layout

```
lrdb/
├── src/
│   ├── App.svelte              ← Root: loads GeoJSONs, manages active page
│   ├── LRDB.svelte             ← Main map view, filter checkboxes
│   ├── Map.svelte              ← Leaflet map wrapper
│   ├── Districts.svelte        ← District boundary overlay
│   ├── InfoPanel.svelte        ← Sidebar: redistricting process details
│   ├── ProcessScorecard.svelte ← Visual scorecard for each jurisdiction
│   ├── ProcessTimeline.svelte  ← Timeline of key process dates
│   ├── PlaceList.svelte        ← Searchable jurisdiction list
│   ├── CollapsibleSection.svelte
│   ├── BinaryLegend.svelte     ← Map legend
│   ├── Home.svelte             ← Home button
│   ├── Intro.svelte            ← Intro modal
│   ├── Title.svelte
│   ├── components/
│   │   └── Header.svelte
│   ├── gamification/           ← Placeholder for future engagement features
│   ├── main.js                 ← Entry point
│   └── store.js                ← Svelte store (Leaflet map instance)
├── public/
│   └── assets/
│       ├── lrdb_web_20260216.geojson       ← Core data (9.5 MB)
│       ├── cc_sb_districts15q_nod.geojson  ← Boundary polygons (14 MB)
│       └── update_helper/
│           ├── infopanel_fields.csv    ← Field name → sidebar label mapping
│           ├── link_fields.csv         ← External link URL templates
│           └── name_id_lookup.csv      ← Place name → feature ID (for search)
├── scripts/
│   ├── add_cc_shapefiles.R     ← Merge county/city/school district shapefiles
│   ├── fix_typos.R             ← Data quality corrections
│   └── sync_data.sh            ← Pull files from fdp data platform
├── rollup.config.js
└── package.json
```

---

## Setup

```bash
cd ~/codebox/lrdb
npm install
```

No `.env` file needed — lrdb is entirely static.

---

## Development

```bash
npm run dev    # Rollup in watch mode
npm start      # sirv static server → http://localhost:5000
```

In a separate terminal, or just run `npm run dev` which starts the file watcher.
Then serve `public/` with `npm start`.

---

## Building for Production

```bash
npm run build
# prebuild: syncs data from fdp platform (npm run sync)
# build:    rollup -c → public/build/bundle.js + bundle.css
```

Deploy by serving the `public/` directory from any static host.

---

## Data

### Core file: `public/assets/lrdb_web_20260216.geojson`

Each feature is a jurisdiction (county commission, city council, or school board)
with the following key properties:

| Property | Values | Meaning |
|---|---|---|
| `type` | `County Commission`, `School Board`, `City Council` | Jurisdiction type |
| `redistricted_w` | `yes` / `no` | Required redistricting for 2020 cycle |
| `requirements_w` | `yes` / `no` | Has written redistricting requirements |
| `guidelines_w` | `yes` / `no` | Has written redistricting guidelines/standards |
| `lcro_w` | `yes` / `no` | Map drawn locally (not state-imposed) |
| `gga_adjust_w` | `yes` / `no` | State legislature overrode local process |
| `participation_w` | `yes` / `no` | Public participation in process |
| `controvery_w` | `yes` / `no` | Documented controversy |
| `atlarge_w` | `yes` / `no` | At-large elections (no districts) |

### Boundary file: `public/assets/cc_sb_districts15q_nod.geojson`

Polygon boundaries for county commissions, city councils, and school board
districts.  Joined to the LRDB features by district ID.

### Update helper files

- **`infopanel_fields.csv`** — maps GeoJSON property names to human-readable
  sidebar labels (e.g. `requirements_w` → "Written Requirements")
- **`link_fields.csv`** — URL templates for external links (e.g. Georgia General
  Assembly bill lookup)
- **`name_id_lookup.csv`** — maps place names to feature IDs for the search/filter
  functionality

---

## Updating the Data

The LRDB data is maintained in a master GIS file and exported to GeoJSON.

### Adding new shapefiles (R workflow)

```bash
# Edit scripts/add_cc_shapefiles.R to point to new source shapefiles
Rscript scripts/add_cc_shapefiles.R

# Fix any typos found in the data
Rscript scripts/fix_typos.R
```

Then copy the output GeoJSON to `public/assets/` (naming it with today's date,
e.g. `lrdb_web_20260521.geojson`), update references in `App.svelte`, and run
a build.

### Syncing from fdp

```bash
npm run sync    # calls scripts/sync_data.sh → fdp sync-app lrdb
```

---

## Filter Logic

The filter checkboxes in `LRDB.svelte` are hardcoded to the binary (`_w`) fields
above.  Each checkbox toggles which features are highlighted on the map.
Adding a new filter requires:

1. Adding the property to the GeoJSON
2. Adding a checkbox entry in `LRDB.svelte`
3. Adding the field mapping to `update_helper/infopanel_fields.csv`

---

## Known Issues

- Checkbox state resets on page reload (localStorage persistence not yet
  implemented)
- `type` field uses the spelling `controvery_w` (one 's') — preserved as-is
  for data compatibility; fix in a future data refresh

---

## FDP Integration

```
fdp/config/apps/lrdb.yml           ← data file paths + filter field definitions
fdp/data/repos/main/lrdb/          ← canonical source for GeoJSON files
lrdb/scripts/sync_data.sh          ← copies from fdp into public/assets/
```

The fdga-chain API also reads the LRDB GeoJSON directly via `LRDB_DATA_PATH`
in its `.env`.  After migration, both will read from `fdp/data/repos/main/lrdb/`.

---

## Related Projects

| Project | Integration |
|---|---|
| **fdp** | Canonical source for GeoJSON data files |
| **fdga-chain** | Reads LRDB GeoJSON for jurisdiction lookup endpoint |
| **fdex** | Independent; no runtime integration |
| **map-compare** | Independent; no runtime integration |
