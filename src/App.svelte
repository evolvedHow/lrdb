<script>
  import { onMount } from 'svelte';
  import Leaderboard from './gamification/Leaderboard.svelte';
  
  let currentView = 'classic';
  let geojsonData = { features: [] };

  onMount(async () => {
    // Detect if we are on GitHub Pages and get the base path
    const pathRoot = window.location.pathname.split('/')[1];
    const isGHPages = window.location.hostname.includes('github.io');
    const baseUrl = isGHPages ? `/${pathRoot}/` : '/';

    try {
      // Use the base URL to find your data
      const response = await fetch(`${baseUrl}assets/lrdb_web_20260216.geojson`);
      if (!response.ok) throw new Error("Data not found");
      geojsonData = await response.json();
    } catch (e) {
      console.error("Error loading GeoJSON:", e);
    }

    const params = new URLSearchParams(window.location.search);
    if (params.get('view') === 'gamify') {
      currentView = 'gamify';
    }
  });
</script>