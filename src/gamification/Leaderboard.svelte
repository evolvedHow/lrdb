<script>
  import VolunteerBadges from './VolunteerBadges.svelte'; // IMPORT NEW COMPONENT

  export let geojsonData = { features: [] };

  $: leaderboard = calculateLeaderboard(geojsonData);

  function calculateLeaderboard(data) {
    if (!data || !data.features) return [];
    
    const counts = {};
    data.features.forEach(feature => {
      const source = feature.properties.source; 
      if (source && source !== 'null' && source !== 'System' && source.trim() !== '') {
         counts[source] = (counts[source] || 0) + 1;
      }
    });

    return Object.entries(counts)
      .map(([name, count]) => ({ name, count }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 5); 
  }
</script>

<div class="leaderboard-container">
  <h3>🏆 Top Contributors</h3>
  {#if leaderboard.length === 0}
    <p>Loading volunteer data...</p>
  {:else}
    <ul class="leaderboard-list">
      {#each leaderboard as user, index}
        <li class="leaderboard-item">
          <div class="user-header">
            <span class="rank">#{index + 1}</span>
            <span class="name">{user.name}</span>
            <span class="score-badge">{user.count} updates</span>
          </div>
          
          <div class="user-badges">
            <VolunteerBadges volunteerName={user.name} geojsonData={geojsonData} />
          </div>

        </li>
      {/each}
    </ul>
  {/if}
</div>

<style>
  .leaderboard-container {
    padding: 1rem;
    background: white;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  }
  .leaderboard-list {
    list-style: none;
    padding: 0;
    margin: 0;
  }
  .leaderboard-item {
    display: flex;
    flex-direction: column;
    padding: 1rem 0;
    border-bottom: 1px solid #eee;
  }
  .user-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 0.5rem;
  }
  .rank { font-weight: bold; color: #9ca3af; width: 30px; }
  .name { flex-grow: 1; font-weight: 700; font-size: 1.1rem; color: #1f2937; }
  .score-badge {
    background: #eff6ff;
    color: #1d4ed8;
    padding: 0.25rem 0.5rem;
    border-radius: 999px;
    font-size: 0.8rem;
    font-weight: bold;
  }
  .user-badges {
    padding-left: 30px; /* Aligns badges under the name, skipping the rank column */
  }
</style>