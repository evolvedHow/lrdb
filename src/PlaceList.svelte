<script lang="typescript" >

    import L from "leaflet";
    import { count } from "./store.js";
    import { afterUpdate } from 'svelte';
    import { createEventDispatcher } from 'svelte';
    import { onMount } from "svelte";
    const dispatch = createEventDispatcher();
    export let filters;
    export let geojson;

    let plusInnerHTML = "x";
    let searchText = "";

    $: filtered_data = searchText.trim()
        ? map_data.filter(d => d.properties.name.toLowerCase().includes(searchText.toLowerCase()))
        : map_data;

    function expander() {
        let holder = document.getElementById('holder');
        holder.classList.toggle('hidden');
        plusInnerHTML = holder.classList.contains('hidden') ? "+" : "x";
    }

    //countValue is map object stored in the store.js
    let map;
    count.subscribe(value => {map = value});

    //Prepare data to be filtered by geojson object
    function dataFilter(feature) {
        let type_remain = null;

        // Define the feature style if there are no filters
        if (filters.feature_filters.length === 0) {
            console.log(filters.feature_filters);
            feature.properties.feature_remain = "yes";
        } else {
            const allFeatureFilters = filters.feature_filters.every(
                (feature_filter) => feature.properties[feature_filter] === "yes" || feature.properties[feature_filter] === "yes, and no redist"
            );
            const noFeatureFilters = filters.feature_filters.every(
                (feature_filter) => feature.properties[feature_filter] === "no" || feature.properties[feature_filter] === "no, and no redist"
            );
            // selects not required OR "no districts" for the feature filter
            const notRequiredFeatureFilters = filters.feature_filters.every(
                (feature_filter) => (feature.properties[feature_filter] === "not required" || 
                feature.properties.redist_complete === "not required") &&
                (feature.properties[feature_filter] != "yes, and no redist" ||
                feature.properties[feature_filter] != "no, and no redist")
            );
            if (allFeatureFilters) {
                feature.properties.feature_remain = "yes";
                type_remain = true;
            } else if (noFeatureFilters) {
                feature.properties.feature_remain = "no";
                type_remain = false;
            } else if (notRequiredFeatureFilters) {
                feature.properties.feature_remain = "not required";
                type_remain = false;
            } else {
                feature.properties.feature_remain = "na";
                type_remain = false;
            }
        }

        // select the county, city, or school district to display, based on active header
        if (feature.properties.type == filters.type_filters) {
            type_remain = true;
        } else {
            type_remain = false;
        }
        console.log("type_remain:", type_remain);
        return type_remain;
    }
    //Filter list based on filters
    let map_data = geojson.filter( dataFilter );
        map_data = map_data.filter( function(feature){
        /// displays the name of any park that meets all above criteria
        if (feature.properties.feature_remain === "yes" ){
            return true;
        } else {
            return false;
        }
        })
        // Sort the filtered data alphabetically by name
        .sort((a, b) => a.properties.name.localeCompare(b.properties.name)); 

    //When an item from the list is clicked.
    //1. Set view, 2. update and dispatch clicked polygon
    function clickHandle(e){
        let clicked_list = geojson.filter( function(d){
            return d.properties.id == e.target.id
        }) 
        // let clicked_list = geojson
        // .filter(d => d.properties.id == e.target.id)
        // .sort((a, b) => a.properties.name.localeCompare(b.properties.name));

        console.log("Sorted clicked_list:", clicked_list); // Check sorted order

        dispatch('message', {
                active: clicked_list
            });
        map.flyTo( L.geoJson(clicked_list).getBounds().getCenter() , 10, {
            animate: true,
            duration: 1
        }); // Zoom to point
    }

    // scroll to after loading.
    afterUpdate(() => {

        let this_cont;
        let prev_cont;

        let placelists = [...document.getElementsByClassName( 'place-list' )];
        placelists.forEach( function(place){
            if (place.id === filters.active){
                this_cont = place;
            }

            if (place.id === filters.previous){
                prev_cont = place;
            }
        })

		let place_cont = document.getElementById('holder');

		if (this_cont && place_cont ){ //If both already are created

            if(prev_cont){
                place_cont.scroll({
                top:prev_cont.offsetTop,
                behavior:'auto'
                    })
            }

			place_cont.scroll({
				top:this_cont.offsetTop,
				behavior:'smooth'
			})
        }
    });

</script>

<!-- svelte-ignore missing-declaration -->
<button on:click={expander}>
    <div class="site-button">
        {#if map_data.length > 0}
            <span class="t2 search">Results ({map_data.length})</span>
            <span id="collapse-nav-button">{plusInnerHTML}</span>
        {/if}
    </div>
</button>
<div id="holder">
    {#if map_data.length > 0}
        <div class="search-bar">
            <input class="search-input" type="text" placeholder="Search by name..." bind:value={searchText}>
        </div>
        <p class="help-text">Select a name below to view details</p>
        {#each filtered_data as d }
            <div class="place-list t3 {d.properties.id}" id={d.properties.id} on:click={e=>{clickHandle(e)}} on:keydown={e=>{clickHandle(e)}}>
                {d.properties.name}
            </div>
        {/each}
        {#if filtered_data.length === 0}
            <p class="no-results">No matches found</p>
        {/if}
    {/if}
</div>

<style>

    #collapse-nav-button:before {
        font-weight: bold;
    }

    .hidden {
        display: none;
    }

    .site-button {
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .search {
        margin-left: 9px;
    }

    .search-bar {
        padding: 5px 0;
        position: sticky;
        top: 0;
        background: white;
        z-index: 1;
    }

    .search-input {
        width: 100%;
        padding: 8px 10px;
        font-size: 1rem;
        font-family: "ff-tisa-sans-web-pro", sans-serif;
        border: 1.5px solid #ccc;
        border-radius: 4px;
        box-sizing: border-box;
        background-image: none;
        color: #333;
    }

    .search-input:focus {
        border-color: var(--purple);
        outline: none;
        background-color: white;
    }

    .help-text {
        color: #999;
        font-size: 0.85rem;
        margin: 2px 0 6px;
        font-style: italic;
    }

    .no-results {
        color: #999;
        font-style: italic;
        padding: 10px 0;
    }

</style>