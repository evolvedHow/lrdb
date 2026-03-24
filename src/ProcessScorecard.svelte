<script>
  export let active_poly;
  export let stats = {};

  const dimensions = [
    {
      field: 'participation_w',
      label: 'Public Participation',
      tooltip: 'Did residents get a chance to weigh in before lines were drawn?',
    },
    {
      field: 'requirements_w',
      label: 'Written Requirements',
      tooltip: 'Does local law spell out when and how redistricting must happen?',
    },
    {
      field: 'guidelines_w',
      label: 'Written Guidelines',
      tooltip: 'Were there rules for how lines should be drawn (compactness, communities of interest, etc.)?',
    },
    {
      field: 'lcro_w',
      label: 'Locally Drawn Map',
      tooltip: 'Was the final map drawn and approved locally?',
    },
    {
      field: 'gga_adjust_w',
      label: 'State Override',
      tooltip: 'Did the state legislature substitute its own map instead of the locally approved one?',
      invertColor: true,
    },
    {
      field: 'atlarge_w',
      label: 'At-Large Elections',
      tooltip: 'At-large elections mean all voters choose all seats — districts are not used.',
      invertColor: true,
    },
  ];

  function pillClass(val, invertColor) {
    if (!val || val === 'null') return 'pill na';
    if (val === 'not required') return 'pill not-required';
    if (val === 'yes') return invertColor ? 'pill no' : 'pill yes';
    if (val === 'no')  return invertColor ? 'pill yes' : 'pill no';
    return 'pill na';
  }

  function pillLabel(val) {
    if (!val || val === 'null') return 'No Data';
    if (val === 'not required') return 'Not Required';
    if (val === 'yes') return 'Yes';
    if (val === 'no') return 'No';
    return val;
  }

  function statLine(field, type) {
    if (!stats || !type || !stats[type]) return '';
    const s = stats[type];
    return `statewide: ${s[field] ?? 0} of ${s.total}`;
  }
</script>

{#if active_poly}
  <div class="scorecard">
    {#each dimensions as dim}
      {@const val = active_poly[dim.field]}
      <div class="card">
        <div class="card-top">
          <span class="dim-label">{dim.label}</span>
          <button class="tip-icon" aria-label={dim.tooltip} type="button">
            ?
            <span class="tip-text">{dim.tooltip}</span>
          </button>
        </div>
        <div class="card-bottom">
          <span class={pillClass(val, dim.invertColor)}>{pillLabel(val)}</span>
          {#if active_poly.type}
            <span class="stat">{statLine(dim.field, active_poly.type)}</span>
          {/if}
        </div>
      </div>
    {/each}
  </div>
{/if}

<style>
  .scorecard {
    padding: 8px 12px 6px;
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 6px;
  }

  .card {
    background: #fafafa;
    border: 1px solid #eeeeee;
    border-radius: 6px;
    padding: 7px 9px;
    display: flex;
    flex-direction: column;
    gap: 5px;
  }

  .card-top {
    display: flex;
    align-items: flex-start;
    gap: 4px;
  }

  .dim-label {
    font-size: 0.75rem;
    color: #555;
    font-weight: 500;
    line-height: 1.3;
    flex: 1;
  }

  .tip-icon {
    position: relative;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 14px;
    height: 14px;
    border-radius: 50%;
    background: #e0e0e0;
    color: #666;
    font-size: 0.6rem;
    font-weight: 700;
    cursor: help;
    flex-shrink: 0;
    border: none;
    padding: 0;
    margin-top: 1px;
  }

  .tip-icon:hover .tip-text,
  .tip-icon:focus .tip-text,
  .tip-icon:focus-within .tip-text {
    display: block;
  }

  .tip-text {
    display: none;
    position: absolute;
    left: 18px;
    top: -4px;
    width: 200px;
    background: #333;
    color: white;
    font-size: 0.75rem;
    font-weight: 400;
    padding: 6px 10px;
    border-radius: 5px;
    line-height: 1.4;
    z-index: 200;
    pointer-events: none;
  }

  .card-bottom {
    display: flex;
    align-items: center;
    gap: 6px;
  }

  .pill {
    display: inline-block;
    padding: 2px 8px;
    border-radius: 999px;
    font-size: 0.72rem;
    font-weight: 700;
    min-width: 64px;
    text-align: center;
    flex-shrink: 0;
  }

  .pill.yes {
    background: var(--purple, #8d598a);
    color: white;
  }

  .pill.no {
    background: #e6b04d;
    color: white;
  }

  .pill.not-required {
    background: #a3a0a3;
    color: white;
  }

  .pill.na {
    background: #ECEFF1;
    color: #999;
  }

  .stat {
    font-size: 0.68rem;
    color: #aaa;
    white-space: nowrap;
  }

  @media (max-width: 900px) {
    .stat {
      display: none;
    }
  }
</style>
