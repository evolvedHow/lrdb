<script>
    // based on suggestions from:
    // Inclusive Components by Heydon Pickering https://inclusive-components.design/collapsible-sections/
    export let headerText;

    // create prop to track whether or not the section is visible
    export let isVisible = true;
    let expanded = isVisible;
</script>

<div class="collapsible">
    <h3>
        <button aria-expanded={expanded} on:click={() => expanded = !expanded}>
          {#if headerText}
            <span class="header-text {expanded ? 'expanded' : ''}">{headerText}</span>
          {/if}
          <svg class="chevron {expanded ? 'expanded' : ''}" viewBox="0 0 24 24" fill="none">
            <path d="M9 18l6-6-6-6" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </button>
    </h3>
    
    <div class='contents' hidden={!expanded}>
        <slot></slot>
    </div>
</div>

<style>
  .collapsible {
    border-bottom: 1px solid var(--gray-light, #eee);
  }
	
	h3 {
		margin: 0;
	}

.collapsible h3 .header-text.expanded {
  /* Styles for expanded state */
  color: var(--purple);
}
	
  button {
    background-color: var(--background, #fff);
    color: var(--gray-darkest, #999);
    display: flex;
		justify-content: space-between;
    width: 100%;
		border: none;
		margin: 0;
		padding: 0.5em 0.5em;
    font-family: "ff-tisa-sans-web-pro", sans-serif;
    font-size: 14pt;
    font-weight: 600;
    color: #666;
    padding-left: 15px;
  }

  /* Media query for mobile devices */
	@media (max-width: 767px) {
    button {
      min-height: 44px;
      padding-top: 0.5em;
      padding-bottom: 0.5em;
    }
  }


  button[aria-expanded="true"] {
    border-bottom: 1px solid var(--gray-light, #eee);
  }

    .chevron {
        height: 0.8em;
        width: 0.8em;
        transition: transform 0.25s ease;
        color: #999;
        flex-shrink: 0;
    }

    .chevron.expanded {
        transform: rotate(90deg);
        color: var(--purple);
    }

    button:focus .chevron {
        outline: 2px solid;
    }

    .contents {
      padding-top: 5px;
      padding-bottom: 5px;
    }
</style>