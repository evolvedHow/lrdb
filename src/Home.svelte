<script>
    import { count } from "./store.js"; //
    import L from "leaflet"; //
    import { createEventDispatcher } from 'svelte'; //
    
    const dispatch = createEventDispatcher(); //
    let map;
    count.subscribe(value => { map = value; }); //

    // Use a reactive block ($:) to add the button once the map is ready
    $: if (map) {
        let home = L.easyButton('<i class="fa fa-expand" aria-hidden="true"></i>', function(btn, map){
            map.flyTo([32.482618, -83.602092], 7);
        }, 'Reset map'); //

        home.button.onclick = function(){
            dispatch('homebutton', { text: 'Hello!' });
        }; //
        
        home.addTo(map); //
    }
</script>

<div class="home-container">
    <div id="map-header">
        <h1>Local Redistricting Database</h1>
    </div>

    <footer class="gamify-footer">
        <p>© 2026 FairDistrictsGA</p>
        <a href="?view=gamify" class="secret-portal">Volunteer Portal</a>
    </footer>
</div>

<style>
    /* Paste your styles here */
    .gamify-footer { text-align: center; margin-top: 20px; }
    .secret-portal { color: #ccc; text-decoration: none; font-size: 0.8rem; }
</style>