<script>
  import L from "leaflet";
  import { setContext, onMount } from "svelte";
  import { count } from "./store.js";

  let mapContainer;
  let map = L.map(L.DomUtil.create("div"), {
    center: [32.482618, -83.602092],
    zoom: 7,
    // zoom: zoom,
    // maxBounds: bounds,
    // zoomDelta: 0.5,
  });

  count.set(map)

  setContext("leafletMapInstance", map);

  var tileURL = 'https://api.mapbox.com/styles/v1/mapbox/light-v10/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiZmRnYW1hcHMiLCJhIjoiY2tsYTRnZWdiMGR5ZjJ2dHBpeDAzczkxNCJ9.uv8NswGoOuPCNdpPHXG5PQ';


  L.tileLayer(tileURL, {
    maxZoom: 18,
    minZoom: 3,
    zoomControl:false,
    attribution:'Data and Design by <a href="https://spatialcollections.com/">Sara Hodges</a>',
  }).addTo(map);

  onMount(() => {
    mapContainer.appendChild(map.getContainer());
    map.getContainer().style.width = "100%";
    map.getContainer().style.height = "100%";
    map.invalidateSize();
  });

</script>

<svelte:head>
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.6.0/dist/leaflet.css" integrity="sha512-xwE/Az9zrjBIphAcBb3F6JVqxf46+CDLwfLMHloNu6KEQCAWi6HcDUbeOfBIptF7tcCzusKFjFw2yuvEpDL9wQ==" crossorigin=""/>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.12.1/css/all.min.css" rel="stylesheet"/>
</svelte:head>


<style>
  .map {
    height: 100%;
    width: 100%;
  }
</style>
<div class="map" bind:this="{mapContainer}">
  <slot></slot>
</div>