<script>
  import { onMount } from 'svelte';
  import Leaderboard from './gamification/Leaderboard.svelte';
  
  let currentView = 'classic';
  let geojsonData = { features: [] };

  // Function to toggle views and save to local storage
  function setView(view) {
    currentView = view;
    localStorage.setItem('lrdb_preferred_view', view);
    
    // Update URL without reloading for a cleaner experience
    const url = new URL(window.location);
    if (view === 'gamify') {
        url.searchParams.set('view', 'gamify');
    } else {
        url.searchParams.delete('view');
    }
    window.history.pushState({}, '', url);
  }

  onMount(async () => {
    // 1. Determine the correct path for GitHub Pages
    const isGHPages = window.location.hostname.includes('github.io');
    const pathSegments = window.location.pathname.split('/');
    // If on GH Pages, the base is /repository-name/, otherwise it's /
    const baseUrl = isGHPages ? `/${pathSegments[1]}/` : '/';

    try {
      // Fetch data using the dynamic base URL
      const response = await fetch(`${baseUrl}assets/lrdb_web_20260216.geojson`);
      if (!response.ok) throw new Error("GeoJSON not found");
      geojsonData = await response.json();
    } catch (e) {
      console.error("Data load error:", e);
    }

    // 2. Priority for View: URL Param > Local Storage > Default
    const params = new URLSearchParams(window.location.search);
    const savedView = localStorage.getItem('lrdb_preferred_view');
    
    if (params.get('view') === 'gamify' || savedView === 'gamify') {
      currentView = 'gamify';
    }
  });
</script>