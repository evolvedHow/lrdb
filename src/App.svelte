<script>
  import { onMount } from 'svelte';
  import Leaderboard from './gamification/Leaderboard.svelte';
  
  let currentView = 'classic';
  let geojsonData = { features: [] }; // This needs data!

  onMount(async () => {
    // 1. Fetch your actual data
    const response = await fetch('./assets/lrdb_web_20260216.geojson');
    geojsonData = await response.json();

    // 2. Check for the gamify view
    const params = new URLSearchParams(window.location.search);
    if (params.get('view') === 'gamify') {
      currentView = 'gamify';
    }
  });
</script>

{#if currentView === 'gamify'}
  <div class="gamify-overlay">
    <a href="/" class="exit-link">⬅ Back to Classic Map</a>
    <Leaderboard {geojsonData} /> 
  </div>
{/if}

<main class={currentView === 'gamify' ? 'dimmed' : ''}>
  </main>