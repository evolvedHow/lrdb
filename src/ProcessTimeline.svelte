<script>
  export let active_poly;

  $: show = active_poly &&
    active_poly.redistricted_w !== 'not required' &&
    active_poly.redistricted_w != null;

  $: steps = active_poly ? buildSteps(active_poly) : [];

  function buildSteps(p) {
    return [
      {
        num: 1,
        label: 'Redistricting Required',
        detail: p.redistricted_w === 'yes' ? 'Yes — redistricting was required after the 2020 Census.' : 'Not required for this jurisdiction.',
        state: p.redistricted_w === 'yes' ? 'done' : 'na',
      },
      {
        num: 2,
        label: 'Map Drawn',
        detail: p.draft1_drew
          ? `Drawn by: ${p.draft1_drew}${p.redist_coord ? ` · Coordinated by: ${p.redist_coord}` : ''}`
          : 'No information available on who drew the map.',
        state: p.draft1_drew ? 'done' : 'na',
      },
      {
        num: 3,
        label: 'Public Participation',
        detail: p.participation_w === 'yes'
          ? `Yes${p.comm_part_redistricting ? ` — ${p.comm_part_redistricting}` : ' — community input was included.'}`
          : p.participation_w === 'no'
          ? 'No public participation was included.'
          : 'No data available.',
        state: p.participation_w === 'yes' ? 'done' : p.participation_w === 'no' ? 'skipped' : 'na',
      },
      {
        num: 4,
        label: 'Local Approval',
        detail: p.map_approval
          ? `Approved by: ${p.map_approval}${p.date_loc_approve ? ` on ${p.date_loc_approve}` : ''}${p.local_vote ? ` · Vote: ${p.local_vote}` : ''}`
          : p.local_approval
          ? `Reviewed by: ${p.local_approval}`
          : 'No local approval information available.',
        state: (p.map_approval || p.local_approval) ? 'done' : 'na',
      },
      {
        num: 5,
        label: 'State Legislature',
        detail: p.gga_adjust_w === 'yes'
          ? `The state legislature rejected the local map and passed its own${p.bill_num ? ` (${p.bill_num})` : ''}.`
          : p.bill_num
          ? `The state legislature passed the locally approved map${p.bill_num ? ` (${p.bill_num})` : ''}.`
          : 'No state legislation information available.',
        state: p.gga_adjust_w === 'yes' ? 'override' : p.bill_num ? 'done' : 'na',
      },
    ];
  }
</script>

{#if show && steps.length}
  <div class="timeline-wrap">
    <div class="section-label">Redistricting Process</div>
    <ol class="steps">
      {#each steps as step}
        <li class="step step--{step.state}">
          <div class="step-num">{step.num}</div>
          <div class="step-body">
            <div class="step-label">{step.label}</div>
            <div class="step-detail">{step.detail}</div>
          </div>
        </li>
      {/each}
    </ol>
  </div>
{/if}

<style>
  .timeline-wrap {
    padding: 10px 15px 8px;
    border-top: 1px solid #f0f0f0;
  }

  .section-label {
    font-size: 0.75rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    color: #999;
    margin-bottom: 10px;
  }

  .steps {
    list-style: none;
    padding: 0;
    margin: 0;
    position: relative;
  }

  /* vertical connector line */
  .steps::before {
    content: '';
    position: absolute;
    left: 13px;
    top: 14px;
    bottom: 14px;
    width: 2px;
    background: #e8eaed;
  }

  .step {
    display: flex;
    align-items: flex-start;
    gap: 12px;
    padding: 0 0 12px;
    position: relative;
  }

  .step:last-child {
    padding-bottom: 0;
  }

  .step-num {
    width: 28px;
    height: 28px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 0.75rem;
    font-weight: 700;
    flex-shrink: 0;
    position: relative;
    z-index: 1;
    background: #e8eaed;
    color: #999;
  }

  .step--done .step-num {
    background: var(--purple, #8d598a);
    color: white;
  }

  .step--skipped .step-num {
    background: #e6b04d;
    color: white;
  }

  .step--override .step-num {
    background: #c0392b;
    color: white;
  }

  .step-body {
    padding-top: 4px;
    flex: 1;
    min-width: 0;
  }

  .step-label {
    font-size: 0.85rem;
    font-weight: 600;
    color: #333;
    line-height: 1.2;
    margin-bottom: 2px;
  }

  .step--done .step-label {
    color: var(--purple, #8d598a);
  }

  .step--override .step-label {
    color: #c0392b;
  }

  .step--skipped .step-label {
    color: #b08030;
  }

  .step-detail {
    font-size: 0.78rem;
    color: #666;
    line-height: 1.4;
  }
</style>
