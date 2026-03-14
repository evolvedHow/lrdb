<script>
    import { count } from "./store.js";
    import L from "leaflet";

    import { createEventDispatcher } from 'svelte';
	const dispatch = createEventDispatcher();

    let map;
    count.subscribe(value => {
        map = value;
    });

    let home = L.easyButton( '<i class="fa fa-expand" aria-hidden="true"></i>' , function(btn, map){
        map.flyTo([32.482618, -83.602092], 7);
    },'Reset map');
    
    home.button.onclick = function(){
        dispatch('homebutton', {
			text: 'Hello!'
		});
    }
    
    home.addTo(map);

</script>
