<script>
    import * as L from 'leaflet';
    import { count } from "./store.js";
    import { createEventDispatcher, onMount, onDestroy  } from 'svelte';
   
    const dispatch = createEventDispatcher();

    export let geojson;
    export let filters;
    export let redrawPoly;

    //countValue is map object stored in the store.js
    let map;
    count.subscribe(value => {
        map = value;
    });

    let layerGroup; // Reference to the layer group containing LRDB layers
    let popupOpen = false; // Track popup state

    function debounce(func, wait) {
        let timeout;
        return function (...args) {
        clearTimeout(timeout);
        timeout = setTimeout(() => func.apply(this, args), wait);
        };
    }

    function onEachFeature(feature, layer) {
        const debouncedOpenPopup = debounce(layer.openPopup.bind(layer), 200);
        const debouncedClosePopup = debounce(layer.closePopup.bind(layer), 200);

        var popupContent = `
        <span class="t2">
            ${feature.properties.name}
        </span>`;

        layer.bindPopup(popupContent, {
            closeOnEscapeKey: false,
            closeOnClick: false,
            offset: [20, -20], // Adjust the offset as needed
            autoPan: false // Add autoPan here
        });

        layer.on({
            click: activePoly,
            mousemove: () => {
                if (!popupOpen) {
                    debouncedOpenPopup();
                    popupOpen = true;
                }
            },
            mouseout: () => {
                if (popupOpen) {
                    debouncedClosePopup();
                    popupOpen = false;
                }
            }
        });
    }

    onMount(() => {
        // Add the initial layer when the component is mounted
        addLRDBLayer();
    });

    onDestroy(() => {
        // Clean up by removing the layer group when the component is destroyed
        removeLRDBLayer();
    });

    function addLRDBLayer() {
        if (geojson) {
            const filteredData = geojson.filter(dataFilter);

            // Remove the existing layer group if it already exists
            removeLRDBLayer();

            // Create a new layer group
            layerGroup = L.layerGroup().addTo(map);

            // Add the new layers to the group
            filteredData.forEach(feature => {
                const layer = L.geoJSON(feature, {
                    onEachFeature: onEachFeature,
                    style: style,
                }).addTo(layerGroup);
            });
        }
    }

    function removeLRDBLayer() {
        if (layerGroup) {
            map.removeLayer(layerGroup);
            layerGroup = null;
        }
    }

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
                (feature.properties[feature_filter] != "yes, and no redist" &&
                feature.properties[feature_filter] != "no, and no redist")
            );
            console.log(notRequiredFeatureFilters);
            if (notRequiredFeatureFilters) {
                feature.properties.feature_remain = "not required";
                type_remain = false;
            } else if (allFeatureFilters) {
                feature.properties.feature_remain = "yes";
                type_remain = true;
            } else if (noFeatureFilters) {
                feature.properties.feature_remain = "no";
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

        return type_remain;
    }


    //Zoom to active point and write id to store.
    function activePoly(e){
        map.flyTo(e.latlng, 10)
        // redrawPoly();
        // e.target.setStyle({ weight: 3});  
        e.target.setStyle({ weight: 3, fillOpacity: 0, color: '#6e426b'});  
        // redrawPoly();
        let clicked_poly = geojson.filter( function(d){
            return d.properties.id == e.target.feature.properties.id
        }) 
        redrawPoly();
        dispatch('message', {
            active: clicked_poly
        }); 
    }

    // color based on filters
    function getColorByFilter(d) {
        return d == "yes" ? '#8d598a' :
                // d == "no" ? '#b2a7b5' :
                d == "no" ? '#e6b04d' :
                d == "not required" ? '#a3a0a3' :
                d == "na" ? '#ECEFF1' :
                        '#ECEFF1'
    }


    function style(feature) {
        return {
        fillColor: getColorByFilter(feature.properties.feature_remain),
        color:"#e2e2e2",
        opacity: 1,
        weight: .9,
        fillOpacity: 1
        }
    }

 </script>

