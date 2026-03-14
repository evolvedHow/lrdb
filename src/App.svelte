<script>

	import LeafletMap from './Map.svelte'
	import LRDB from './LRDB.svelte';
	import Districts from './Districts.svelte';
	import {onMount} from 'svelte'
	import Header from './components/Header.svelte';	
	import PlaceList from './PlaceList.svelte';
	import CollapsibleSection from './CollapsibleSection.svelte'
	import InfoPanel from './InfoPanel.svelte';
	import Intro from './Intro.svelte';
	import HomeButton from './Home.svelte'
	import BinaryLegend from './BinaryLegend.svelte';
	import { count } from "./store.js";

	let poly_data;
	let all_poly_data;
	let dist_data;
	let all_dist_data;
	let active_poly;
	const polygon_url = "assets/lrdb_web_20260216.geojson";
	const districts_url = "assets/cc_sb_districts15q_nod.geojson";
	const broken_links_url = "assets/broken_links.csv";

	//countValue is map object stored in the store.js
    let map;
    count.subscribe(value => {map = value});

	let activePage = 'county';
	let showIntroModal = true;

	function closeIntroModal() {
		showIntroModal = false;
	}

	function redrawPoly() {
        // force a redraw of the polygons
		filters = filters;
		// force the infoPanel to close
		active_poly = null;
    }

	// create the binary checkboxes
	let checkboxes = [
		{ value: "redistricted_w", label: "Local redistricting was required for 2020 redistricting cycle.", checked: true, noRedistricting: true, hideNo: true },
        { value: "requirements_w", label: "Written requirements about how and when to redistrict.", checked: false, noRedistricting: true  },
        { value: "guidelines_w", label: "Written guideline or standards for map drawing.", checked: false, noRedistricting: true  },
		{ value: "lcro_w", label: "The locally approved map drawn by the LCRO", checked: false, noRedistricting: true  },
        { value: "gga_adjust_w", label: "Enacted map drawn by state legislature, not locally.", checked: false, noRedistricting: true  },
		{ value: "participation_w", label: "Local redistricting process included some form of public participation.", checked: false, noRedistricting: true  },
		{ value: "controvery_w", label: "Local redistricting had evidence of some controversy", checked: false, noRedistricting: true  },
		{ value: "atlarge_w", label: "Elections are at-large.", checked: false, noRedistricting: false },
    ];

	// Compute the active legend title and whether to show "No Redistricting" / hide "No"
    $: activeLegendTitle = checkboxes.find(cb => cb.checked)?.label || "";
    $: showNoRedistricting = checkboxes.some(cb => cb.checked && cb.noRedistricting);
    $: showNo = !checkboxes.some(cb => cb.checked && cb.hideNo);

	// define the filter to display county, city, or school district
	function changePage(showCounty, showCity, showSchool) {
		active_poly = null;

		if (showCounty) {
			activePage = 'county';
			filters.type_filters = ["County Commission"];
		} else if (showCity) {
			activePage = 'city';
			filters.type_filters = ["City Council"];
		} else if (showSchool) {
			activePage = 'school';
			filters.type_filters = ["School Board"];
		}
	}

	
	onMount(async () => {

		const res2 = await fetch( polygon_url );
		poly_data = await res2.json();

		// Load broken links CSV and merge into features
		const blRes = await fetch( broken_links_url );
		const blText = await blRes.text();
		const blLines = blText.trim().split('\n').slice(1); // skip header
		const brokenMap = {};
		for (const line of blLines) {
			const cols = line.split(',');
			const id = cols[0].trim();
			const field = cols[2].trim();
			if (!brokenMap[id]) brokenMap[id] = [];
			brokenMap[id].push(field);
		}
		for (const feat of poly_data.features) {
			const fid = String(Math.round(feat.properties.id));
			if (brokenMap[fid]) {
				feat.properties.broken_links = brokenMap[fid];
			}
		}

		all_poly_data = [ ...poly_data.features]

		const res3 = await fetch( districts_url );
		dist_data = await res3.json();

		all_dist_data = [ ...dist_data.features]

	});


	//Filter Function. Filter goes to GeoJSON.svelte
	//Declare Empty filter. All Filters are together
	let filters = {
		type_filters:["County Commission"],
		feature_filters:["redistricted_w"],
		prog_filters:[],
		text_filter:"",
		active:[],
		previous:[]
	};

	// Handle Site Feature Filters
	function clickHandleSiteFeatures(value) {
		const checked = filters.feature_filters.includes(value);
		if (!checked) {
			filters.feature_filters = [value];
		} else {
			filters.feature_filters = [];
		}

		// Reset the active_poly
		active_poly = null;

		// Uncheck all checkboxes
		checkboxes.forEach(checkbox => {
			checkbox.checked = false;
		});

		// Check the clicked checkbox if it was not previously checked
		if (!checked) {
			const clickedCheckbox = checkboxes.find(checkbox => checkbox.value === value);
			if (clickedCheckbox) {
				clickedCheckbox.checked = true;
			}
		}
	}


	function handlePlaceMessage(e){
		let active_id = String(e.detail.active[0].properties.id )
		 active_poly = all_poly_data.filter( function(f){
			return String(f.properties.id) === active_id;
		 })
	}

	function handleMessage(e){
		let active_id = String(e.detail.active[0].properties.id )
		 active_poly = all_poly_data.filter( function(f){
			return String(f.properties.id) === active_id;
		 })
	}

	function handleExtent(e){
		active_poly = null;
	}


	
</script>

<svelte:head>
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/leaflet-easybutton@2/src/easy-button.css">
	<script src="https://cdn.jsdelivr.net/npm/leaflet-easybutton@2/src/easy-button.js"></script>
</svelte:head>


<!-- Render the page -- header, map and the sidebar -->
{#if all_poly_data} 

	<Header {activePage} {changePage} openInfo={() => showIntroModal = true} />
	<BinaryLegend {activeLegendTitle} {showNoRedistricting} {showNo} /> 


	<!-- Initiate Map Here-->
	<div class="map-pane">
		<LeafletMap >
			<HomeButton on:homebutton={handleExtent}/>
			{#key filters}
				<LRDB geojson={all_poly_data}  {filters} {redrawPoly}
				on:message={handleMessage} 
			/>
			{/key}
			{#key active_poly}
				<Districts selected={all_dist_data}  {active_poly}  />
			{/key}
		</LeafletMap>
	</div>

	{#if showIntroModal}
		<div class="modal-overlay" on:click={closeIntroModal} on:keydown={closeIntroModal}>
			<div class="modal-content" on:click|stopPropagation on:keydown|stopPropagation>
				<button class="modal-close" on:click={closeIntroModal}>&times;</button>
				<Intro showIntro={true} />
				<div class="modal-footer">
					<button class="modal-dismiss" on:click={closeIntroModal}>Explore the Map</button>
				</div>
			</div>
		</div>
	{/if}

	<div class="left-panel panel">
			{#if active_poly}
				<div class="info-panel">
					{#key active_poly}
						<InfoPanel {active_poly} {redrawPoly} />
					{/key}
				</div>
			{:else}
				<div id="amenity">
					<CollapsibleSection isVisible={true} headerText={'Select by redistricting characteristic'}>
						<div class="feature-filters r">
							{#each checkboxes as checkbox, index}
								<input type="checkbox" on:click={() => clickHandleSiteFeatures(checkbox.value)} bind:checked={checkbox.checked} class:first={index === 0}>
								<label class="t3" for={checkbox.value}>{checkbox.label}</label><br>
								{#if index === 0}
									<span class="characteristics">Local Election and Redistricting Characteristics</span>
								{/if}
							{/each}
						</div>
					</CollapsibleSection>
				</div>
				{#key filters}
					<PlaceList on:message={handlePlaceMessage} geojson={all_poly_data} {filters}/>
				{/key}
			{/if}
	</div>

	{:else}
	<div>Loading...</div>
{/if}

<style>

	.map-pane {
		position: absolute;
		top: 65px;
		left: 0px;
		z-index: 0;
		width: 60vw;
		height: calc(100% - 75px);
		padding: 0px;
	}

	.panel {
		background: white;
		z-index: 1;
		right: 0px;
	}

	.left-panel {
		position: absolute;
		display: flex;
		flex-direction: column;
		border-left: solid 2px rgb(225, 225, 225);
		width: 40vw;
		box-sizing: border-box;
		height: calc(100vh - 65px);
		overflow-y: auto;
		top: 65px;
	}

	/* Hide scrollbar for Chrome, Safari and Opera */
	.left-panel::-webkit-scrollbar {
		display: none;
	}

	/* Hide scrollbar for IE, Edge and Firefox */
	.left-panel {
		-ms-overflow-style: none;  /* IE and Edge */
		scrollbar-width: none;  /* Firefox */
	}

	/* Media query for mobile devices */
	@media (max-width: 767px) {

		.map-pane {
			position: fixed;
			top: 45px;
			left: 0;
			width: 100vw;
			height: calc(100vh - 45px);
			z-index: 0;
		}

		.left-panel {
			position: fixed;
			bottom: 0;
			left: 0;
			top: auto;
			display: flex;
			flex-direction: column;
			border-left: none;
			border-top: none;
			border-radius: 16px 16px 0 0;
			box-shadow: 0 -2px 12px rgba(0, 0, 0, 0.15);
			width: 100%;
			max-height: 45vh;
			height: auto;
			z-index: 2;
			overflow-y: auto;
		}

		.left-panel::before {
			content: '';
			display: block;
			width: 40px;
			height: 4px;
			background: #ccc;
			border-radius: 2px;
			margin: 8px auto 4px;
			flex-shrink: 0;
		}

		.r {
			margin-top: 0px;
			margin-bottom: 0px;
			padding-bottom: 0px;
			padding-left: 13px;
		}

	}

	.modal-overlay {
		position: fixed;
		top: 0;
		left: 0;
		width: 100%;
		height: 100%;
		background-color: rgba(0, 0, 0, 0.5);
		z-index: 10000;
		display: flex;
		justify-content: center;
		align-items: center;
	}

	.modal-content {
		background: white;
		border-radius: 8px;
		padding: 30px;
		max-width: 650px;
		width: 90%;
		max-height: 80vh;
		overflow-y: auto;
		position: relative;
		box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
	}

	.modal-close {
		position: absolute;
		top: 10px;
		right: 15px;
		font-size: 28px;
		color: #999;
		background: none;
		border: none;
		cursor: pointer;
		width: auto;
		padding: 0;
		line-height: 1;
	}

	.modal-close:hover {
		color: #333;
	}

	.modal-footer {
		text-align: center;
		margin-top: 15px;
	}

	.modal-dismiss {
		background-color: var(--purple);
		color: white;
		border: none;
		padding: 12px 30px;
		min-height: 44px;
		font-size: 14pt;
		font-family: "ff-tisa-sans-web-pro", sans-serif;
		font-weight: 600;
		border-radius: 5px;
		cursor: pointer;
		width: auto;
	}

	.modal-dismiss:hover {
		background-color: var(--dkpurple);
	}

	.modal-close {
		min-width: 44px;
		min-height: 44px;
		display: flex;
		align-items: center;
		justify-content: center;
	}

	.first {
		margin-bottom: 10px;
	}

	.characteristics {
		display: block;
		color: var(--purple);
		font-weight: 700;
		margin-bottom: 5px;
	}

	@media (max-width: 767px) {
		.first {
			margin-bottom: 5px;
		}

		.characteristics {
			font-size: 0.85rem;
			margin-bottom: 3px;
		}
	}

</style>