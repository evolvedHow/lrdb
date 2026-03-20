<script>
  import { onMount } from 'svelte';
  // ... your existing imports (Map, InfoPanel, etc.)
  
  // Import your new gamification components
  import Leaderboard from './gamification/Leaderboard.svelte';
  import { getGamifiedMapPaintStyles } from './gamification/GamifiedLayerHelper.js';

  let currentView = 'classic';
  let geojsonData = { features: [] }; // This should come from your existing data fetch

  onMount(() => {
    // Check the URL for the gamify flag
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

<style>
  .gamify-overlay {
    position: absolute;
    top: 20px;
    right: 20px;
    z-index: 1000;
    max-width: 350px;
  }
  .exit-link {
    display: inline-block;
    margin-bottom: 10px;
    color: #2563eb;
    text-decoration: none;
    font-weight: bold;
    font-size: 0.9rem;
  }
  .dimmed {
    opacity: 0.9; /* Slight visual change when in gamify mode */
  }
</style>