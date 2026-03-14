<script>
    import { count } from "./store.js";
    import L from "leaflet";
    import { createEventDispatcher } from 'svelte';
	const dispatch = createEventDispatcher();
    
    export let active_poly;
    export let redrawPoly;
    let map;

    function isBroken(field) {
        return active_poly?.broken_links?.includes(field);
    }
    count.subscribe(value => {
        map = value;
    });

    if (active_poly) {
        active_poly = active_poly[0].properties;
    }

</script>

{#if active_poly}
    <div class="county-header">
        <span class="close" on:click={() => redrawPoly()} on:keydown={() => redrawPoly()}>x</span>
        <p class="county-name">{active_poly.name}</p>
    </div>
    <div class="county-details">
        {#if active_poly.website_link}
            <p>The <a href="{active_poly.website_link}" class="href" target="_blank">{active_poly.type}</a>{#if isBroken('website_link')}<span class="broken-link"> (sorry, this link is no longer maintained on {active_poly.name}'s website)</span>{/if} in {active_poly.name} has <span class="notice">{active_poly.dist_type}</span> where <span class="notice">{active_poly.election_type}</span>.</p>
        {/if}
        {#if active_poly.no_districts}
            <p>{active_poly.no_districts}</p> 
        {/if}
        {#if active_poly.shared_with}
            <p>The {#if active_poly.shared_with == "CC"}<span>County Commission</span>{/if}{#if active_poly.shared_with == "SB"}<span>School Board</span>{/if} uses the same district map. {#if active_poly.shared_with == "CC"}<span>See the County page for additional details on the redistricting process.</span>{/if}</p> 
        {/if}
        {#if active_poly.complete_n != "not required"}
                {#if !active_poly.no_districts}
                    <p>{#if active_poly.redist_coord}The redistricting process was managed by the <span class="notice">{active_poly.redist_coord}</span>. {/if} {#if active_poly.draft1_drew}The locally proposed district map was drawn by <span class="notice">{active_poly.draft1_drew}</span>.{/if} 
                        {#if active_poly.local_approval} It was reviewed by <span class="notice">{active_poly.local_approval}</span>
                            {#if active_poly.map_approval}, and approved 
                                {#if active_poly.date_loc_approve}
                                    on <span class="notice">{active_poly.date_loc_approve}</span>
                                {/if}
                                by <span class="notice">{active_poly.map_approval}</span> {#if active_poly.local_vote}in a vote that 
                                was described as <span class="notice">{active_poly.local_vote}</span>{/if}
                            {/if}.
                        {/if}
                    </p>
                    {#if active_poly.minutes_src}
                        <ul>
                            <li><span class="notice"><a href="{active_poly.minutes_src}" class="href" target="_blank">View meeting minutes about the redistricting process.</a>{#if isBroken('minutes_src')}<span class="broken-link"> (sorry, this link is no longer maintained on {active_poly.name}'s website)</span>{/if}{#if active_poly.min_date}{active_poly.min_date}{/if}</span></li>
                        </ul>
                    {/if}
                    {#if active_poly.no_info}
                        <p>The local redistricting process:</p> 
                    {/if}
                    <ul>
                        {#if active_poly.participation_w == "yes"}
                            <li>Allowed for community participation {#if active_poly.comm_part_redistricting}<span class="notice"> ({active_poly.comm_part_redistricting})</span>{/if}.</li>
                        {/if}
                        {#if active_poly.participation_w == "no"}
                            <li><span class="notice">Did not allow</span> for community participation.</li>
                        {/if}
                        {#if active_poly.requirements_n}
                            <li><span class="notice">{active_poly.requirements_n}</span> written requirements for how and when to redistrict beyond those in the US and Georgia Constitutions.</li>
                        {/if}
                        {#if active_poly.up_require}
                            <ul>
                                <li><a href="{active_poly.up_require}" class="href" target="_blank">View description of requirements </a>{#if isBroken('up_require')}<span class="broken-link"> (sorry, this link is no longer maintained on {active_poly.name}'s website)</span>{/if}</li>
                            </ul>
                        {/if}
                        {#if active_poly.guide_n}
                            <li><span class="notice">{active_poly.guide_n}</span> written guidelines or standards for map drawing.
                                {#if active_poly.nonbinding_guidelines}
                                    They describe their redistricting criteria they used as: <span class="notice">{active_poly.nonbinding_guidelines}</span>; but these are not legally binding.
                                {/if}
                            </li>
                        {/if}
                        {#if active_poly.guidelines_w == "yes" && active_poly.guidelines_list}
                            <ul>
                                <li><span class="notice"> ({active_poly.guidelines_list})</span></li>
                                {#if active_poly.guidelines_list_src}
                                        <li><a href="{active_poly.guidelines_list_src}" class="href" target="_blank">View guidelines </a>{#if isBroken('guidelines_list_src')}<span class="broken-link"> (sorry, this link is no longer maintained on {active_poly.name}'s website)</span>{/if}</li>
                                {/if}
                            </ul>
                        {/if}
                    </ul>
                    {#if active_poly.gga_adjust_w == "yes"}
                        <p>The state legislature <span class="notice">rejected the locally approved map and passed a new map
                            {#if active_poly.bill_num_src}
                                <a href="{active_poly.bill_num_src}" class="href" target="_blank">({active_poly.bill_num})</a>{#if isBroken('bill_num_src')}<span class="broken-link"> (sorry, this link is no longer maintained on {active_poly.name}'s website)</span>{/if}
                            {/if}
                            {#if active_poly.bill_num && !active_poly.bill_num_src}<span class="notice"> ({active_poly.bill_num})</span>{/if}.
                        </p>
                    {/if}
                    {#if active_poly.gga_adjust_w != "yes"}
                        <p>The state legislature passed the locally approved map
                            {#if active_poly.bill_num_src}
                                    <a href="{active_poly.bill_num_src}" class="href" target="_blank">({active_poly.bill_num})</a>{#if isBroken('bill_num_src')}<span class="broken-link"> (sorry, this link is no longer maintained on {active_poly.name}'s website)</span>{/if}
                                {/if}
                            {#if active_poly.bill_num && !active_poly.bill_num_src}<span class="notice"> ({active_poly.bill_num})</span>{/if}.
                        </p>
                    {/if}
                    {#if active_poly.map_draft1_src || active_poly.add_docs || active_poly.supporting_docs_src}
                        <p>Additional resources:</p>
                    {/if}
                    {#if active_poly.supporting_docs_src}
                        <ul>
                            <li><span class="notice"><a href="{active_poly.supporting_docs_src}" class="href" target="_blank">View redistricting resolutions or statutes</a>{#if isBroken('supporting_docs_src')}<span class="broken-link"> (sorry, this link is no longer maintained on {active_poly.name}'s website)</span>{/if}</span></li>
                        </ul>
                    {/if}
                    {#if active_poly.add_docs}
                        <ul>
                            <li><span class="notice"><a href="{active_poly.add_docs}" class="href" target="_blank">View additional materials</a>{#if isBroken('add_docs')}<span class="broken-link"> (sorry, this link is no longer maintained on {active_poly.name}'s website)</span>{/if}</span></li>
                        </ul>
                    {/if}
                    {#if active_poly.municode}
                        <ul>
                            <li><span class="notice"><a href="{active_poly.municode}" class="href" target="_blank">View Code of Ordinances</a>{#if isBroken('municode')}<span class="broken-link"> (sorry, this link is no longer maintained on {active_poly.name}'s website)</span>{/if}</span></li>
                        </ul>
                    {/if}
                {/if}
            {/if}
            {#if active_poly.summary}
                <p>Read a summary of the local redistricting process based on the 2020 US Census, written by <span class="notice">{active_poly.source_n}</span>:</p>
                    <ul>
                        <li><span >{active_poly.summary}</span></li>
                    </ul>
            {/if}
    </div>
{/if}

<style>
.county-header {
    color: var(--purple);
    padding-top: 20px;
    padding-bottom: 20px;
    text-align: center;
    font-size: 22px;
}

.county-details {
    padding-left: 15px;
    padding-right: 15px;
    font-size: 18px;
}

.county-name {
    font-size: 20px;
    font-weight: 600;
    margin-bottom: 0px;
}

.close {
    float: right;
    font-size: 20px;
    font-weight: 700;
    margin-right: 10px;
    margin-top: -10px;
    margin-bottom: 0px;
    cursor: pointer;
    color: gray;
}

.notice {
    color: var(--purple);
    font-weight: 600;
    font-style: italic;
}

.county-details a {
    color: var(--dkblue);
    text-decoration: underline;
    font-style: normal;
    font-weight: 600;
}

.county-details a:hover {
    color: var(--purple);
}

.broken-link {
    color: #c0392b;
    font-style: italic;
    font-weight: normal;
    font-size: 0.9em;
}

</style>