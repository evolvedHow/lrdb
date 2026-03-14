# ============================================================
# Fix typos and text issues from issue tracker
# Add this to your R data processing script
# ============================================================

# 1. Atlanta (id 1304000) - City Council
#    Typo in summary: "being drawing" should be "begin drawing"
lrdb[lrdb$id == 1304000, "summary"] <- gsub(
  "resolution to being drawing",
  "resolution to begin drawing",
  lrdb[lrdb$id == 1304000, "summary"]
)

# 2. Cobb County School District (id 1301290)
#    a) Typo in nonbinding_guidelines: "he" should be "the map drawer"
#       Original: "secondary interests he considered when drawing the BOE map"
#       The reviewer said replace "he" with "should be" but that doesn't make
#       grammatical sense. The "he" refers to the map drawer (a lawfirm).
#       Suggest replacing with a neutral phrasing:
lrdb[lrdb$id == 1301290, "nonbinding_guidelines"] <- gsub(
  "secondary interests he considered when drawing the BOE map, such as",
  "secondary interests considered when drawing the BOE map, such as",
  lrdb[lrdb$id == 1301290, "nonbinding_guidelines"]
)

#    b) Typo in summary: "intervenes" should be "intervened"
lrdb[lrdb$id == 1301290, "summary"] <- gsub(
  "School Board voluntarily intervenes",
  "School Board voluntarily intervened",
  lrdb[lrdb$id == 1301290, "summary"]
)

# 3. Carroll County School District (id 1300840)
#    Run-on sentence caused by map_approval being too long.
#    The InfoPanel renders: "approved on 12/13/2021 by {map_approval} in a vote
#    that was described as unanimous approval"
#    Current map_approval: "the Board must pass a resolution asking local
#    legislators to bring the proposed changes to the Legislative session for
#    approval"
#    This creates a run-on. Shorten map_approval to just the approving body:
lrdb[lrdb$id == 1300840, "map_approval"] <- "the School Board"

# 4. Albany (id 1301052) - City Council
#    "GIS Office" is unclear - spell out what it means
lrdb[lrdb$id == 1301052, "draft1_drew"] <- "City of Albany GIS (Geographic Information Systems) Office"

# 5. Brookhaven (id 1310944) - City Council
#    map_approval contains a full sentence which creates a run-on when the
#    InfoPanel renders "approved on 5/4/2021 by {map_approval}"
#    Current: "the City Council passed a resolution to change the charter under
#    Home Rule to amend the district map"
#    Fix: shorten to just the approving body, move the method detail elsewhere
lrdb[lrdb$id == 1310944, "map_approval"] <- "the City Council by Home Rule charter amendment"
