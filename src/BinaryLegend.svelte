<script>
     export let activeLegendTitle;
     export let showNoRedistricting;
     export let showNo = true;
</script>

<div class="legend">
    {#if activeLegendTitle}
        <div class="legend-title">{activeLegendTitle}</div>
    {/if}
    <div class="legend-row">
        <div class="legend-symbol">
            <div class="legend-square" style="background-color: #8d598a;"></div>
        </div>
        <div class="legend-label">Yes</div>
    </div>
    {#if showNo}
    <div class="legend-row">
        <div class="legend-symbol">
            <div class="legend-square" style="background-color: #e6b04d;"></div>
        </div>
        <div class="legend-label">No</div>
    </div>
    {/if}
    {#if showNoRedistricting}
        <div class="legend-row">
            <div class="legend-symbol">
                <div class="legend-square" style="background-color: #a3a0a3;"></div>
            </div>
            <div class="legend-label">No Redistricting</div>
        </div>
    {/if}
    <div class="legend-row">
        <div class="legend-symbol">
            <div class="legend-square" style="background-color: #ECEFF1;"></div>
        </div>
        <div class="legend-label">No Data</div>
    </div>
</div>

<style>
    .legend {
        position: absolute;
        bottom: 20px;
        left: 10px;
        z-index: 1000;
        background-color: #fff;
        padding: 10px;
        border-radius: 5px;
        border: solid 2px rgb(204, 204, 204);
        /* box-shadow: 0 1px 1px rgba(0, 0, 0, 0.65); */
        font-size: 1rem;
        line-height: 18px;
        max-width: 200px;
        max-height: calc(100vh - 115px);
        overflow-y: scroll;
        color: #707070;
    }
    /* Media query for mobile devices */
    @media (max-width: 767px) {
        .legend {
            position: fixed;
            bottom: 46vh;
            left: 5px;
            padding: 6px 8px;
            max-width: none;
            max-height: none;
            border-radius: 4px;
            font-size: 0.8rem;
            line-height: 14px;
            z-index: 1;
        }

        .legend-title {
            display: none;
        }

        .legend-symbol {
            width: 12px;
            height: 12px;
        }
    }

    /* Hide scrollbar for Chrome, Safari and Opera */
	.legend::-webkit-scrollbar {
		display: none;
	}

	/* Hide scrollbar for IE, Edge and Firefox */
	.legend {
		-ms-overflow-style: none;  /* IE and Edge */
		scrollbar-width: none;  /* Firefox */
	}

    .legend-title {
        color: #707070;
        margin: 0 0 5px 0;
        font-size: 18px;
        font-weight: 700;
        line-height: 1.25;
    }

    .legend-row {
        display: flex;
        align-items: center;
        margin-bottom: 2px;
    }

    .legend-symbol {
        width: 17px;
        height: 17px;
        margin-right: 5px;
    }

    .legend-square {
        width: 100%;
        height: 100%;
    }

    .legend-label {
        margin: 0;
    }
    
</style>