<script>
  // Props: Pass in the specific volunteer's identifier and the full dataset
  export let volunteerName = "";
  export let geojsonData = { features: [] };

  // 1. Filter the map data to only the features this volunteer contributed to
  $: userContributions = geojsonData.features.filter(
    feature => feature.properties.source === volunteerName
  );

  // 2. FLEXIBLE BADGE CONFIGURATION
  // You can easily add, remove, or modify badges here without touching the HTML.
  const badgeRegistry = [
    {
      id: "first_blood",
      name: "The Vanguard",
      icon: "🛡️", // Replace with <img src="/assets/vanguard.svg"> if desired
      description: "Contributed data to at least one district.",
      // Logic: Does the user have 1 or more contributions?
      earned: (features) => features.length >= 1
    },
    {
      id: "cartographer",
      name: "Master Cartographer",
      icon: "🗺️",
      description: "Sourced a shapefile or official PDF map.",
      // Logic: Did any of their districts include map sources?
      earned: (features) => features.some(f => 
        (f.properties.shapefile_src && f.properties.shapefile_src !== 'null') || 
        (f.properties.pdf_map_src && f.properties.pdf_map_src !== 'null')
      )
    },
    {
      id: "historian",
      name: "The Archivist",
      description: "Tracked down meeting minutes or election change descriptions.",
      icon: "📜",
      // Logic: Did they provide minutes or text descriptions of changes?
      earned: (features) => features.some(f => 
        (f.properties.minutes_src && f.properties.minutes_src !== 'null') ||
        (f.properties.election_change_descr && f.properties.election_change_descr !== 'null')
      )
    },
    {
      id: "watchdog",
      name: "The Watchdog",
      icon: "👁️‍🗨️",
      description: "Flagged a district for controversy or prison gerrymandering.",
      // Logic: Flagged 'Yes' or provided details on controversy fields
      earned: (features) => features.some(f => 
        f.properties.controversy || 
        f.properties.prison_gerrymnadering === 'Yes' // Note: matching your geojson spelling
      )
    },
    {
      id: "marathon",
      name: "Marathon Mapper",
      icon: "🔥",
      description: "Contributed verified data to 5 or more distinct districts.",
      // Logic: High volume contributor
      earned: (features) => features.length >= 5
    }
  ];

  // 3. Calculate which badges this specific user has earned
  $: earnedBadges = badgeRegistry.filter(badge => badge.earned(userContributions));

</script>

<div class="badge-showcase">
  {#if earnedBadges.length === 0}
    <p class="no-badges">No badges earned yet. Start contributing!</p>
  {:else}
    <div class="badge-grid">
      {#each earnedBadges as badge}
        <div class="badge" title="{badge.description}">
          <div class="badge-icon">{badge.icon}</div>
          <div class="badge-name">{badge.name}</div>
        </div>
      {/each}
    </div>
  {/if}
</div>

<style>
  .badge-showcase {
    margin-top: 0.5rem;
  }
  .badge-grid {
    display: flex;
    flex-wrap: wrap;
    gap: 0.75rem;
  }
  .badge {
    display: flex;
    flex-direction: column;
    align-items: center;
    background: #f3f4f6;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    padding: 0.5rem;
    width: 90px;
    text-align: center;
    cursor: help; /* Shows the title description on hover */
    transition: transform 0.2s;
  }
  .badge:hover {
    transform: translateY(-2px);
    background: #e5e7eb;
    border-color: #d1d5db;
  }
  .badge-icon {
    font-size: 2rem; /* Size of the emoji/icon */
    margin-bottom: 0.25rem;
  }
  .badge-name {
    font-size: 0.7rem;
    font-weight: 600;
    color: #374151;
    line-height: 1.1;
  }
  .no-badges {
    font-size: 0.85rem;
    color: #9ca3af;
    font-style: italic;
  }
</style>