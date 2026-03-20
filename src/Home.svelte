<script>
    import { count } from "./store.js";
    import L from "leaflet";
    import { createEventDispatcher } from 'svelte';
    const dispatch = createEventDispatcher();

    let map;
    count.subscribe(value => {
        map = value;
    });

    let home = L.easyButton('<i class="fa fa-expand" aria-hidden="true"></i>', function(btn, map){
        map.flyTo([32.482618, -83.602092], 7);
    }, 'Reset map');

    home.button.onclick = function(){
        dispatch('homebutton', { text: 'Hello!' });
    }
    
    if (map) home.addTo(map);
</script>

<div class="home-container">
    <h1>Local Redistricting Database (LRDB)</h1>
    <footer class="gamify-footer">
        <p>© 2026 FairDistrictsGA</p>
        <a href="/?view=gamify" class="secret-portal">Volunteer Portal</a>
    </footer>
</div>

<style>
    .gamify-footer {
        margin-top: 3rem;
        padding: 1.5rem 0;
        border-top: 1px solid #e5e7eb;
        text-align: center;
        font-size: 0.75rem;
        color: #6b7280;
    }
    
    .secret-portal {
        color: transparent;
        text-decoration: none;
        cursor: default;
        display: block;
        margin-top: 0.5rem;
    }

    .secret-portal:hover {
        color: #9ca3af;
    }
</style>