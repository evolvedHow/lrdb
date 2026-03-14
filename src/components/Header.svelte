<script>

  export let activePage;
  export let changePage;
  export let openInfo;

  function refreshPage() {
    location.reload();
  }


</script>
    
  <header>
    <div class="header-content">
      <div class="col large-col">
        <div id="logo-container">
          <a href="https://www.fairdistrictsga.org/" target="_blank"><img src="img/fdga_logo.png" alt="FDGA" id="logo"></a>
        </div>
        <div class="title" on:click={refreshPage} on:keydown={refreshPage}>
          <span title="Find out information about the local redistricting process in (nearly) every county, school district, city in Georgia.">Local Redistricting Database</span>
          <button class="info-btn" on:click|stopPropagation={openInfo} title="How to use this tool">
            <svg viewBox="0 0 24 24" fill="none" width="20" height="20">
              <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2"/>
              <path d="M12 16v-4M12 8h.01" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
            </svg>
          </button>
        </div>
      </div>
      <div class="hamburger-selector">
        <input type="checkbox" id="hamburger-checkbox">
        <label for="hamburger-checkbox">
          <span class="hamburger"></span>
        </label>
        <div class="hamburger-menu">
          <div class="col" class:active={activePage === 'county'}>
            <div class="column-content other-pages" on:click={() => changePage(true, false, false)} on:keydown={() => changePage(true, false, false)}>
              County
            </div>
          </div>
          <div class="col" class:active={activePage === 'school'}>
            <div class="column-content other-pages" on:click={() => changePage(false, false, true)} on:keydown={() => changePage(false, false, true)}>
              School Board
            </div>
          </div>
          <div class="col" class:active={activePage === 'city'}>
            <div class="column-content other-pages" on:click={() => changePage(false, true, false)} on:keydown={() => changePage(false, true, false)}>
              Municipal
            </div>
          </div>
        </div>
      </div>
    </div>
  </header>    

<style>

.header-content {
  display: flex;
  justify-content: space-between;
  flex-wrap: nowrap;
  height: 65px; 
  align-items: center; /* Vertically align items */
  border-bottom: 1.5px rgb(225, 225, 225);
}

#logo-container {
  display: flex;
  align-items: center;
  position: absolute; /* Position the logo container absolutely */
  left: 10px; /* Place it 10px from the left edge of the header */
  top: 2.5px;
}
#logo {
  max-height: 60px; /* Adjust as needed to fit within header */
}

@media (max-width: 767px) { 
  #logo {
    max-height: 40px; /* Adjust for smaller screens */
  }
}

  .col {
    flex-basis: 33.3%;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .large-col {
    flex-basis: 40%;
  }

  .title {
    color: var(--purple);
    font-size: 1.5rem;
    font-weight: 700;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 6px;
  }

  .info-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    background: none;
    border: none;
    color: #999;
    cursor: pointer;
    padding: 2px;
    width: auto;
    min-width: 28px;
    min-height: 28px;
  }

  .info-btn:hover {
    color: var(--purple);
  }
  @media (max-width: 1250px) {

    .title {
      font-size: 1.3rem;
    }
  }

  @media (max-width: 1050px) {

    .title {
      font-size: 1.1rem;
    }
  }

  @media (max-width: 1000px) {

    .title {
      font-size: 1rem;
    }
  }


  .column-content {
    text-align: center;
    color: #5D5D5D;
    font-size: 20px;
    font-weight: 400;
  }

  /* active styles for column-content */
  .active {
    background-color: var(--purple);
  }
  div.active .column-content {
    color: white;
    font-weight: 600!important;
  }
   /* hover styles for headers other than the title */
   .other-pages:hover {
    font-weight: 600;
  }

  .hamburger-selector {
    flex-basis: 60%;
  }

  .hamburger-selector input[type="checkbox"] {
    display: none;
  }
  .hamburger-menu {
    display: flex;
    justify-content: space-between;
    flex-wrap: nowrap;
    height: 65px;
  }

  .column-content {
    /* make hand when hover */  
    cursor: pointer;
  } 


  /* Media query for mobile devices */
  @media (max-width: 767px) {
    .header-content {
      height: 45px;
    }
    
    .large-col {
      flex-basis: 90%;
    }

    .title {
      font-size: 1rem;
      padding-left: 45px;
    }

    .hamburger-selector {
      flex-basis: 10%;
      display: flex;
      align-items: center;
      justify-content: center;
      min-width: 44px;
      min-height: 44px;
      border: solid 1.5px rgb(225, 225, 225);
    }

    .hamburger-selector .hamburger {
      display: block;
      width: 25px;
      height: 3px;
      background-color: #707070;
      transition: background-color 0.3s ease;
      cursor: pointer;
    }

    .hamburger-selector .hamburger::before,
    .hamburger-selector .hamburger::after {
      content: "";
      display: block;
      width: 100%;
      height: 3px;
      background-color: #707070;
      transition: background-color 0.3s ease;
    }

    .hamburger-selector .hamburger::before {
      margin-bottom: 5px;
    }

    .hamburger-selector .hamburger::after {
      margin-top: 5px;
    }

    .hamburger-selector input[type="checkbox"] {
      display: none;
    }

    .hamburger-menu {
      display: none;
      position: absolute;
      top: 100%;
      left: 0;
      width: 100%;
      background-color: #fff;
      padding: 10px;
      box-sizing: border-box;
      height: auto;
    }

    .hamburger-selector input[type="checkbox"]:checked ~ .hamburger-menu {
      display: block;
    }

    .hamburger-menu .col {
      flex-basis: calc(100% / 3);
      margin-bottom: 10px;
    }
  }
</style>

