<script>
    import * as L from 'leaflet';
    import { count } from "./store.js";
    import { onMount, onDestroy } from 'svelte';

    let map;
    count.subscribe(value => {
        map = value;
    });

    export let active_poly;
    export let selected;

    let districtLayer; // Reference to the Districts layer
    let popupOpen = false; // Track popup state

    onMount(() => {
        // Add the initial layer when the component is mounted
        addDistrictsLayer();
    });

    onDestroy(() => {
        // Clean up by removing the layer when the component is destroyed
        removeDistrictsLayer();
    });

    if (active_poly) {
        active_poly = active_poly[0].properties.id;
    }

    function onEachFeature(feature, layer) {
        const debouncedOpenPopup = debounce(layer.openPopup.bind(layer), 200);
        const debouncedClosePopup = debounce(layer.closePopup.bind(layer), 200);

        var popupContent = `
        <span class="t2">
            ${feature.properties.name}
        </span><br>
        <span class="Retired-popup-text">
            District: ${feature.properties.district}
        </span>
        `;

        // layer.bindPopup(popupContent);

        layer.bindPopup(popupContent, {
            closeOnEscapeKey: false,
            closeOnClick: false,
            offset: [30, -30] // Adjust the offset as needed
        });
        
        layer.on({
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
            },
            autoPan: false,
            closeOnClick: false
        });
    }

    function debounce(func, wait) {
        let timeout;
        return function (...args) {
        clearTimeout(timeout);
        timeout = setTimeout(() => func.apply(this, args), wait);
        };
    }

    function addDistrictsLayer() {
        if (selected) {
            const filteredData2 = selected.filter(districtFilter);

            // Remove the existing layer if it already exists
            removeDistrictsLayer();

            // Add the new layer
            districtLayer = L.geoJSON(filteredData2, {
                style: style,
                onEachFeature: onEachFeature,
            }).addTo(map);
        }
    }

    function removeDistrictsLayer() {
        if (districtLayer) {
            map.removeLayer(districtLayer);
            districtLayer = null;
        }
    }

    function districtFilter(feature) {
        let remain = null;

        // Define the feature style if there are no filters
        if( active_poly){
            if (feature.properties.id == active_poly) {
                feature.properties.dist_remain = "yes";
                remain = true;
            } else {
                feature.properties.dist_remain = "no";
                remain = false;
            }
        }else{
            feature.properties.dist_remain = "no";
            remain = false
        }
        return(remain)

    }


    function style(feature) {
        return {
        color: "var(--dkpurple)",
        // color: getColorByDist(feature.properties.dist_remain),
        weight: 2,
        // fillOpacity: getOpacityByDist(feature.properties.dist_remain),
        opacity: 1,
        fillOpacity: 0.3,
        fillColor: '#ffffff'
        };
    }
</script>