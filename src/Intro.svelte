<script>
    // Controls the visibility of the introduction panel.
    export let showIntro = true;

</script>

{#if showIntro}
    <div class="intro-panel-content">
        <!-- <button class="close-button" on:click={closeIntro}>
            &times;
        </button> -->
        

        <section class="main-content">
            <h3>How does redistricting affect you in your community?</h3>
            <p>
                The Local Redistricting Database is a tool for understanding the local processes for the most recent redistricting efforts in Georgia – for Counties, School Boards and Cities. The Database can help people understand who decided on the redistricting lines, whether there was public input, how what your local maps were approved or not at the state level, and what maps you eventually ended up with in your county.
            </p>

            <!-- <hr> -->

            <h3>How to use the Database?</h3>
            <p>
                You can access the Database in multiple ways. Feel free to explore.
            </p>
            <ul>
                <li>Click on the tabs at the top of the Database to look at Counties, School Boards or City redistricting information. (Note: A 
                    few counties do not have districts, a number of school boards use the same districts as the county commission, and the Database 
                    only includes cities over 5,000 people.)</li>
                <li>Click on the map directly to view your information for a specific county, school board or city.</li>
                <li>Check a specific Redistricting Characteristic on the right and see the results on the full map. (You have to close the Instructions to see these selectors)</li>
                <li>Click on the list of counties that align with the Redistricting Characteristic you select.</li>
            </ul>

            <!-- <hr> -->

            <h3>Help us improve the Database!</h3>
            <p>
                Database information was collected through surveys, interviews and online searches, but we know we may have missed important points and will 
                need to keep updating our information. You can help us out by filling out an update <a href="https://forms.gle/8CPpSGet4AU6L7FD9" class="href" target="_blank">form</a>.
            </p>
        </section>
    </div>

{/if}

<style>
    /* The intro-panel-content is the main wrapper, replacing the old intro-container */
    .intro-panel-content {
        /* Padding matches the old container for internal spacing */
        padding: 0px 20px 20px 20px;
        /* Important: Uses position: relative for positioning the absolute 'close-button' */
        position: relative; 
        /* Ensures content takes up all available space in the flex parent (.right-panel) */
        flex-grow: 1; 
    }

    /* ---------------------------------- */
    /* CONTENT AND TEXT STYLES (Kept for continuity) */
    /* ---------------------------------- */

    h3 {
        color: var(--dkpurple);
        margin-top: 10px;
        margin-bottom: 10px;
    }

    p {
        line-height: 1.6;
        margin-bottom: 15px;
    }

    ul {
        margin-left: 20px;
        padding-left: 0;
    }

    li {
        margin-bottom: 8px;
    }

    /* hr {
        border: 0;
        height: 1px;
        background: #eee;
        margin: 25px 0;
    } */

</style>