# add_cc_shapefiles.R
# Reads City Council shapefiles and merges them into cc_sb_districts15q_nod.geojson,
# replacing placeholder "boundaries not available" / "city-wide" entries with actual
# district-level features.
#
# Run from project root:
#   Rscript scripts/add_cc_shapefiles.R

library(sf)
library(dplyr)

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
geojson_path <- "public/assets/cc_sb_districts15q_nod.geojson"
shp_dir      <- "public/assets/City Council shapefiles"
output_path  <- geojson_path  # overwrites in place; change if you want a copy

# ---------------------------------------------------------------------------
# Load existing GeoJSON
# ---------------------------------------------------------------------------
cat("Loading existing GeoJSON...\n")
existing <- st_read(geojson_path, quiet = TRUE)
cat("  Features:", nrow(existing), "\n")

# Build city-name → FIPS id lookup from existing City Council entries
cc_ids <- existing |>
  filter(type == "City Council") |>
  st_drop_geometry() |>
  distinct(name, .keep_all = TRUE) |>
  select(name, id)

get_id <- function(city_name) {
  idx <- match(city_name, cc_ids$name)
  if (is.na(idx)) {
    warning("No existing id found for city: ", city_name)
    return(NA_character_)
  }
  cc_ids$id[idx]
}

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

# Zero-pad a district value to 3 digits (e.g. 1 -> "001", "03" -> "003")
pad_district <- function(x) {
  formatC(as.integer(x), width = 3, flag = "0", format = "d")
}

# Read a shapefile, reproject to WGS84, extract + dissolve districts,
# and return a standardized sf with columns: id, name, district, members, type
#
# Args:
#   filepath          - path to .shp file
#   city_name         - city name matching the GeoJSON
#   district_col      - column name holding the district identifier
#                       (NULL for city-wide/boundary-only files)
#   district_transform - optional function(character vector) -> character vector
#                        to clean/format raw district values
#   members_col       - optional column name for member count (default 1)
#   dissolve          - TRUE to st_union rows sharing the same district value
#                       (needed for precincts-within-wards or multi-part shapefiles)
process_shapefile <- function(filepath, city_name, district_col,
                              district_transform = NULL,
                              members_col = NULL,
                              dissolve = TRUE) {
  cat("  Reading:", basename(filepath), "\n")
  shp <- st_read(filepath, quiet = TRUE)

  # Fix invalid geometries and reproject to WGS84
  shp <- st_make_valid(shp)
  shp <- st_transform(shp, 4326)

  # Extract district values
  if (is.null(district_col)) {
    shp$district_val <- "city-wide"
    shp$members_val  <- NA_integer_
  } else {
    shp$district_val <- as.character(shp[[district_col]])
    if (!is.null(district_transform)) {
      shp$district_val <- district_transform(shp$district_val)
    }
    # Members: use column if available and non-zero, else default to 1
    if (!is.null(members_col) && members_col %in% names(shp)) {
      shp$members_val <- as.integer(shp[[members_col]])
      shp$members_val[is.na(shp$members_val) | shp$members_val == 0] <- 1L
    } else {
      shp$members_val <- 1L
    }
  }

  # Drop rows with NA district (e.g. junk rows in some files)
  shp <- shp[!is.na(shp$district_val), ]

  # Dissolve geometries by district (handles precinct-level or multi-part files)
  if (dissolve) {
    shp <- shp |>
      group_by(district_val, members_val) |>
      summarize(geometry = st_union(geometry), .groups = "drop")
  } else {
    shp <- shp |>
      select(district_val, members_val, geometry)
  }

  city_id <- get_id(city_name)
  shp |>
    transmute(
      id       = city_id,
      name     = city_name,
      district = district_val,
      members  = members_val,
      type     = "City Council"
    )
}

# ---------------------------------------------------------------------------
# Process each city
# ---------------------------------------------------------------------------
all_new_features  <- list()
cities_processed  <- character(0)

add_city <- function(label, features) {
  all_new_features[[label]] <<- features
  cities_processed           <<- c(cities_processed, label)
}

# --- Savannah (aldermanic districts; UNIT = ward number) ---
add_city("Savannah", process_shapefile(
  file.path(shp_dir, "Aldermanic_Districts_(Savannah)_.shp"),
  "Savannah", district_col = "UNIT",
  district_transform = pad_district
))

# --- Alpharetta (city-wide; shapefile is city boundary only) ---
{
  shp <- st_make_valid(st_read(file.path(shp_dir, "Alpharetta City Boundary.shp"), quiet = TRUE))
  shp <- st_transform(shp, 4326)
  add_city("Alpharetta", st_sf(
    id = get_id("Alpharetta"), name = "Alpharetta",
    district = "city-wide", members = NA_integer_, type = "City Council",
    geometry = st_union(shp$geometry)
  ))
}

# --- Atlanta ---
add_city("Atlanta", process_shapefile(
  file.path(shp_dir, "atlanta_council_2020.shp"),
  "Atlanta", district_col = "NAME",
  district_transform = pad_district
))

# --- Monroe (two files: regular districts 1-6 + at-large districts 7-8) ---
monroe_reg    <- process_shapefile(
  file.path(shp_dir, "Districts_Monroe_2022.shp"),
  "Monroe", district_col = "District", district_transform = pad_district
)
monroe_at     <- process_shapefile(
  file.path(shp_dir, "AtLarge_Districts_Monroe_2022.shp"),
  "Monroe", district_col = "District", district_transform = pad_district
)
add_city("Monroe", rbind(monroe_reg, monroe_at))

# --- Braselton (DISTRICT_N already zero-padded, e.g. "03") ---
add_city("Braselton", process_shapefile(
  file.path(shp_dir, "braselton_edistricts2023.shp"),
  "Braselton", district_col = "DISTRICT_N"
))

# --- Brookhaven ---
add_city("Brookhaven", process_shapefile(
  file.path(shp_dir, "Brookhaven_Council_Districts.shp"),
  "Brookhaven", district_col = "DISTRICTID",
  district_transform = pad_district
))

# --- Canton ---
add_city("Canton", process_shapefile(
  file.path(shp_dir, "Canton_Council_Wards.shp"),
  "Canton", district_col = "Ward",
  district_transform = pad_district
))

# --- Carrollton (WARD = "Ward 4", "Ward 1", etc.) ---
add_city("Carrollton", process_shapefile(
  file.path(shp_dir, "Carrollton_Wards_Jan_2025.shp"),
  "Carrollton", district_col = "WARD",
  district_transform = function(x) pad_district(gsub("[^0-9]", "", x))
))

# --- Cartersville (13 voting precinct rows for 6 wards; dissolve by Ward) ---
add_city("Cartersville", process_shapefile(
  file.path(shp_dir, "Cartersville Voting Wards.shp"),
  "Cartersville", district_col = "Ward",
  district_transform = pad_district, dissolve = TRUE
))

# --- Chamblee ---
add_city("Chamblee", process_shapefile(
  file.path(shp_dir, "Chamblee_Districts.shp"),
  "Chamblee", district_col = "DistrictID",
  district_transform = pad_district
))

# --- Chattahoochee Hills (5 separate single-district files) ---
chatt <- lapply(1:5, function(d) {
  process_shapefile(
    file.path(shp_dir, paste0("Chattahoochee Hills_D_", d, ".shp")),
    "Chattahoochee Hills", district_col = "District22",
    district_transform = pad_district, dissolve = TRUE
  )
})
add_city("Chattahoochee Hills", do.call(rbind, chatt))

# --- Conyers ---
add_city("Conyers", process_shapefile(
  file.path(shp_dir, "ConyersVoting2023.shp"),
  "Conyers", district_col = "DISTRICT",
  district_transform = pad_district, members_col = "MEMBERS"
))

# --- Covington (NAME = "Covington East Ward", "Covington West Ward") ---
add_city("Covington", process_shapefile(
  file.path(shp_dir, "CovWardDistricts.shp"),
  "Covington", district_col = "NAME"
))

# --- Dallas (multiple polygons per ward; dissolve) ---
add_city("Dallas", process_shapefile(
  file.path(shp_dir, "Dallas_CouncilWards_241029.shp"),
  "Dallas", district_col = "Ward",
  district_transform = pad_district, dissolve = TRUE
))

# --- Doraville ---
add_city("Doraville", process_shapefile(
  file.path(shp_dir, "Doraville_Election_Districts_2024.shp"),
  "Doraville", district_col = "DISTRICT",
  district_transform = pad_district, members_col = "MEMBERS"
))

# --- Griffin ---
add_city("Griffin", process_shapefile(
  file.path(shp_dir, "Griffin_Commissioner_Districts.shp"),
  "Griffin", district_col = "DISTRICT",
  district_transform = pad_district
))

# --- Holly Springs ---
add_city("Holly Springs", process_shapefile(
  file.path(shp_dir, "Holly_Springs_2024_Wards.shp"),
  "Holly Springs", district_col = "DISTRICT",
  district_transform = pad_district, members_col = "MEMBERS"
))

# --- Jefferson ---
add_city("Jefferson", process_shapefile(
  file.path(shp_dir, "Jefferson_election_districts.shp"),
  "Jefferson", district_col = "DISTRICT_N"
))

# --- Marietta (SUBWARD/WARD subparts; dissolve to council wards) ---
add_city("Marietta", process_shapefile(
  file.path(shp_dir, "Marietta_Ward_and_School_Board_Boundaries.shp"),
  "Marietta", district_col = "WARD",
  district_transform = pad_district, dissolve = TRUE
))

# --- Milledgeville (District = "D1", "D3" – strip letter prefix) ---
add_city("Milledgeville", process_shapefile(
  file.path(shp_dir, "Milledgeville_City_Council_Districts.shp"),
  "Milledgeville", district_col = "District",
  district_transform = function(x) pad_district(gsub("[^0-9]", "", x))
))

# --- Newnan (MEMBERS column present but all 0; default to 1) ---
add_city("Newnan", process_shapefile(
  file.path(shp_dir, "Newnan_Council_Districts.shp"),
  "Newnan", district_col = "DISTRICT",
  district_transform = pad_district
))

# --- Peachtree Corners ---
add_city("Peachtree Corners", process_shapefile(
  file.path(shp_dir, "Peachtree Corners_Council_Districts.shp"),
  "Peachtree Corners", district_col = "Post_Numbe",
  district_transform = pad_district
))

# --- Perry (District = "D3", "D2" – strip letter prefix) ---
add_city("Perry", process_shapefile(
  file.path(shp_dir, "Perry Council District.shp"),
  "Perry", district_col = "District",
  district_transform = function(x) pad_district(gsub("[^0-9]", "", x))
))

# --- Powder Springs ---
add_city("Powder Springs", process_shapefile(
  file.path(shp_dir, "Powder_Springs_Wards.shp"),
  "Powder Springs", district_col = "DISTRICT",
  district_transform = pad_district, members_col = "MEMBERS"
))

# --- Sandy Springs ---
add_city("Sandy Springs", process_shapefile(
  file.path(shp_dir, "Sandy_Springs_City_Council_Area.shp"),
  "Sandy Springs", district_col = "DISTRICT",
  district_transform = pad_district
))

# --- Smyrna (ward = numeric) ---
add_city("Smyrna", process_shapefile(
  file.path(shp_dir, "Smyrna_Wards.shp"),
  "Smyrna", district_col = "ward",
  district_transform = pad_district
))

# --- Statesboro ---
add_city("Statesboro", process_shapefile(
  file.path(shp_dir, "Statesboro Council Districts 20241104.shp"),
  "Statesboro", district_col = "DISTRICTID",
  district_transform = pad_district
))

# --- Stockbridge (boundary only; city-wide council) ---
{
  shp <- st_make_valid(st_read(file.path(shp_dir, "Stockbridge_Boundary_2024_PublicWorks3.shp"), quiet = TRUE))
  shp <- st_transform(shp, 4326)
  add_city("Stockbridge", st_sf(
    id = get_id("Stockbridge"), name = "Stockbridge",
    district = "city-wide", members = NA_integer_, type = "City Council",
    geometry = st_union(shp$geometry)
  ))
}

# --- Stonecrest ---
add_city("Stonecrest", process_shapefile(
  file.path(shp_dir, "Stonecrest_Districts.shp"),
  "Stonecrest", district_col = "DISTRICTID",
  district_transform = pad_district
))

# --- Tifton (NAME = "1", "3" – numeric strings) ---
add_city("Tifton", process_shapefile(
  file.path(shp_dir, "TiftonCityCouncilDistricts.shp"),
  "Tifton", district_col = "NAME",
  district_transform = pad_district
))

# --- Tucker (Name = "District 1", "District 3" – extract number) ---
add_city("Tucker", process_shapefile(
  file.path(shp_dir, "TuckerCouncilDistrictBoundaries.shp"),
  "Tucker", district_col = "Name",
  district_transform = function(x) pad_district(gsub("[^0-9]", "", x))
))

# --- Villa Rica
# NOTE: The Ward column in this shapefile is all NA (appears to be a parcel/zoning
# file rather than true ward boundaries). Skipping – existing placeholder kept.
{
  shp <- st_read(file.path(shp_dir, "Villa Rica_Council_Wards.shp"), quiet = TRUE)
  valid <- shp[!is.na(shp$Ward), ]
  if (nrow(valid) > 0) {
    add_city("Villa Rica", process_shapefile(
      file.path(shp_dir, "Villa Rica_Council_Wards.shp"),
      "Villa Rica", district_col = "Ward",
      district_transform = pad_district, dissolve = TRUE
    ))
  } else {
    cat("WARNING: Villa Rica shapefile has no valid Ward values — skipping\n")
  }
}

# --- Winder (Ward = "Ward 4", "Ward 3" – extract number) ---
add_city("Winder", process_shapefile(
  file.path(shp_dir, "WinderWards.shp"),
  "Winder", district_col = "Ward",
  district_transform = function(x) pad_district(gsub("[^0-9]", "", x))
))

# --- Woodstock ---
add_city("Woodstock", process_shapefile(
  file.path(shp_dir, "Woodstock_District_Wards.shp"),
  "Woodstock", district_col = "Ward",
  district_transform = pad_district
))

# ---------------------------------------------------------------------------
# Merge and write
# ---------------------------------------------------------------------------
new_features_sf <- do.call(rbind, Filter(Negate(is.null), all_new_features))
cat("\nNew features created:", nrow(new_features_sf), "\n")
cat("Cities processed:", length(cities_processed), "->", paste(cities_processed, collapse = ", "), "\n")

# Remove old city council entries for cities we've replaced
removed <- existing$name %in% cities_processed & existing$type == "City Council"
cat("Removing", sum(removed), "old placeholder entries\n")
existing_trimmed <- existing[!removed, ]

# Combine
result <- rbind(existing_trimmed, new_features_sf)
cat("Final feature count:", nrow(result), "\n")

# Simplify all features — county/school board geometries dominate the file size
# dTolerance = 0.0001 degrees (~11m): invisible at any web zoom level
# Disable S2 to avoid validity issues with the existing GeoJSON geometries
cat("Simplifying all geometries (dTolerance = 0.0001)...\n")
sf_use_s2(FALSE)
result <- st_simplify(result, preserveTopology = TRUE, dTolerance = 0.0001)
sf_use_s2(TRUE)

cat("Writing to:", output_path, "\n")
st_write(result, output_path, driver = "GeoJSON", delete_dsn = TRUE, quiet = TRUE)
cat("Done!\n")
