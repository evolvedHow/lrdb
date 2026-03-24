<script>
    import { count } from "./store.js";
    import { createEventDispatcher } from 'svelte';
    import ProcessScorecard from './ProcessScorecard.svelte';
    import ProcessTimeline from './ProcessTimeline.svelte';

    const dispatch = createEventDispatcher();

    export let active_poly;
    export let redrawPoly;
    export let stats = {};
    let map;

    function transparencyBadge(p) {
        if (!p || p.redistricted_w === 'not required') return null;
        const score = [
            p.participation_w === 'yes',
            p.requirements_w === 'yes',
            p.guidelines_w === 'yes',
            p.lcro_w === 'yes',
            p.gga_adjust_w !== 'yes',  // not overridden = good
        ].filter(Boolean).length;
        if (score >= 5) return { label: 'Platinum', color: '#5b8dee', desc: 'Highly transparent process' };
        if (score >= 4) return { label: 'Gold',     color: '#e6a817', desc: 'Strong transparency' };
        if (score >= 3) return { label: 'Silver',   color: '#8a9aaa', desc: 'Moderate transparency' };
        if (score >= 1) return { label: 'Bronze',   color: '#b07040', desc: 'Limited transparency' };
        return { label: 'Incomplete', color: '#ccc', desc: 'Minimal process data available' };
    }

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
    {@const badge = transparencyBadge(active_poly)}
    <div class="county-header">
        <span class="close" on:click={() => redrawPoly()} on:keydown={() => redrawPoly()}>x</span>
        <div class="header-row">
            <div>
                <p class="county-name">{active_poly.name}</p>
                {#if active_poly.type}
                    <p class="county-type">{active_poly.type}</p>
                {/if}
            </div>
            {#if badge}
                <div class="badge" style="--badge-color: {badge.color}" title={badge.desc}>
                    <span class="badge-dot"></span>
                    <span class="badge-label">{badge.label}</span>
                </div>
            {/if}
        </div>
    </div>

    {#if active_poly.website_link}
        <div class="county-link">
            <a href="{active_poly.website_link}" class="href" target="_blank">{active_poly.type} website</a>
            {#if isBroken('website_link')}<span class="broken-link"> (link may be outdated)</span>{/if}
        </div>
    {/if}

    {#if active_poly.dist_type || active_poly.election_type}
        <div class="county-meta">
            {#if active_poly.dist_type}<span>{active_poly.dist_type}</span>{/if}
            {#if active_poly.dist_type && active_poly.election_type} · {/if}
            {#if active_poly.election_type}<span>{active_poly.election_type}</span>{/if}
        </div>
    {/if}

    {#if active_poly.no_districts}
        <div class="county-note">{active_poly.no_districts}</div>
    {/if}

    {#if active_poly.shared_with}
        <div class="county-note">
            Uses the same district map as the
            {#if active_poly.shared_with === 'CC'}County Commission{/if}{#if active_poly.shared_with === 'SB'}School Board{/if}.
        </div>
    {/if}

    <!-- Scorecard & Timeline -->
    {#if active_poly.complete_n !== 'not required'}
        <ProcessScorecard {active_poly} {stats} />
        <ProcessTimeline {active_poly} />
    {/if}

    <!-- Documents & Resources -->
    {#if active_poly.minutes_src || active_poly.supporting_docs_src || active_poly.add_docs || active_poly.municode || active_poly.map_draft1_src}
        <div class="resources">
            <div class="resources-label">Documents</div>
            <ul>
                {#if active_poly.minutes_src}
                    <li><a href="{active_poly.minutes_src}" class="href" target="_blank">Meeting minutes</a>{#if active_poly.min_date} — {active_poly.min_date}{/if}{#if isBroken('minutes_src')}<span class="broken-link"> (may be outdated)</span>{/if}</li>
                {/if}
                {#if active_poly.supporting_docs_src}
                    <li><a href="{active_poly.supporting_docs_src}" class="href" target="_blank">Redistricting resolutions or statutes</a>{#if isBroken('supporting_docs_src')}<span class="broken-link"> (may be outdated)</span>{/if}</li>
                {/if}
                {#if active_poly.add_docs}
                    <li><a href="{active_poly.add_docs}" class="href" target="_blank">Additional materials</a>{#if isBroken('add_docs')}<span class="broken-link"> (may be outdated)</span>{/if}</li>
                {/if}
                {#if active_poly.municode}
                    <li><a href="{active_poly.municode}" class="href" target="_blank">Code of Ordinances</a>{#if isBroken('municode')}<span class="broken-link"> (may be outdated)</span>{/if}</li>
                {/if}
                {#if active_poly.up_require}
                    <li><a href="{active_poly.up_require}" class="href" target="_blank">Redistricting requirements</a>{#if isBroken('up_require')}<span class="broken-link"> (may be outdated)</span>{/if}</li>
                {/if}
                {#if active_poly.guidelines_list_src}
                    <li><a href="{active_poly.guidelines_list_src}" class="href" target="_blank">Drawing guidelines</a>{#if isBroken('guidelines_list_src')}<span class="broken-link"> (may be outdated)</span>{/if}</li>
                {/if}
                {#if active_poly.bill_num_src}
                    <li><a href="{active_poly.bill_num_src}" class="href" target="_blank">State legislation ({active_poly.bill_num})</a>{#if isBroken('bill_num_src')}<span class="broken-link"> (may be outdated)</span>{/if}</li>
                {:else if active_poly.bill_num}
                    <li>State legislation: {active_poly.bill_num}</li>
                {/if}
            </ul>
        </div>
    {/if}

    <!-- Summary -->
    {#if active_poly.summary}
        <div class="summary">
            <div class="summary-label">Summary</div>
            <p>{active_poly.summary}</p>
            {#if active_poly.source_n}<p class="summary-source">— {active_poly.source_n}</p>{/if}
        </div>
    {/if}
{/if}

<style>
.county-header {
    color: var(--purple);
    padding: 12px 12px 8px;
    border-bottom: 1px solid #f0f0f0;
}

.header-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
}

.county-name {
    font-size: 16px;
    font-weight: 700;
    margin: 0 0 2px;
}

.county-type {
    font-size: 0.72rem;
    color: #999;
    margin: 0;
    text-transform: uppercase;
    letter-spacing: 0.04em;
}

.badge {
    display: flex;
    align-items: center;
    gap: 5px;
    padding: 4px 10px;
    border-radius: 999px;
    border: 1.5px solid var(--badge-color);
    flex-shrink: 0;
    cursor: default;
}

.badge-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: var(--badge-color);
    flex-shrink: 0;
}

.badge-label {
    font-size: 0.72rem;
    font-weight: 700;
    color: var(--badge-color);
    white-space: nowrap;
}

.close {
    float: right;
    font-size: 20px;
    font-weight: 700;
    cursor: pointer;
    color: #bbb;
    line-height: 1;
    min-width: 28px;
    min-height: 28px;
    text-align: center;
}

.close:hover {
    color: #666;
}

.county-link {
    padding: 6px 15px 0;
    font-size: 0.85rem;
}

.county-meta {
    padding: 4px 15px 0;
    font-size: 0.85rem;
    color: #666;
}

.county-note {
    padding: 6px 15px;
    font-size: 0.85rem;
    color: #888;
    font-style: italic;
}

.resources {
    padding: 10px 15px 4px;
    border-top: 1px solid #f0f0f0;
}

.resources-label, .summary-label {
    font-size: 0.75rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    color: #999;
    margin-bottom: 6px;
}

.resources ul {
    list-style: none;
    padding: 0;
    margin: 0;
}

.resources li {
    margin-bottom: 5px;
    font-size: 0.85rem;
}

.href {
    color: var(--dkblue, #1a56a0);
    text-decoration: underline;
    font-weight: 500;
}

.href:hover {
    color: var(--purple);
}

.broken-link {
    color: #c0392b;
    font-style: italic;
    font-size: 0.8em;
}

.summary {
    padding: 10px 15px 15px;
    border-top: 1px solid #f0f0f0;
}

.summary p {
    font-size: 0.88rem;
    line-height: 1.55;
    color: #444;
    margin: 0 0 6px;
}

.summary-source {
    font-size: 0.78rem;
    color: #999;
    font-style: italic;
}
</style>
