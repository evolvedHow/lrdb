<script>
  export let activePage;
  export let changePage;
  export let openInfo;

  function refreshPage() {
    location.reload();
  }
</script>

<header>
  <div class="header-inner">
    <div class="brand">
      <a href="https://www.fairdistrictsga.org/" target="_blank" class="logo-link">
        <img src="img/fdga_logo.png" alt="FDGA" class="logo">
      </a>
      <span class="title" on:click={refreshPage} on:keydown={refreshPage} role="button" tabindex="0">
        Local Redistricting Database
      </span>
      <button class="info-btn" on:click={openInfo} title="How to use this tool" aria-label="Help">
        <svg viewBox="0 0 24 24" fill="none" width="16" height="16">
          <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2"/>
          <path d="M12 16v-4M12 8h.01" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
        </svg>
      </button>
    </div>

    <nav class="nav-tabs">
      <button class="tab" class:active={activePage === 'county'}
        on:click={() => changePage(true, false, false)}>County</button>
      <button class="tab" class:active={activePage === 'school'}
        on:click={() => changePage(false, false, true)}>School Board</button>
      <button class="tab" class:active={activePage === 'city'}
        on:click={() => changePage(false, true, false)}>Municipal</button>
    </nav>
  </div>
</header>

<style>
header {
  position: absolute;
  top: 0;
  left: 0;
  width: 100vw;
  height: 48px;
  z-index: 3;
  background: white;
  border-bottom: 1px solid #e8eaed;
  box-shadow: 0 1px 3px rgba(0,0,0,0.08);
}

.header-inner {
  display: flex;
  align-items: stretch;
  height: 100%;
  padding: 0 12px;
  gap: 0;
}

.brand {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-shrink: 0;
  margin-right: 20px;
}

.logo-link {
  display: flex;
  align-items: center;
}

.logo {
  height: 30px;
  width: auto;
  margin: 0;
}

.title {
  font-size: 0.95rem;
  font-weight: 700;
  color: var(--purple);
  cursor: pointer;
  white-space: nowrap;
  user-select: none;
}

.title:hover {
  color: var(--dkpurple);
}

.info-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  background: none;
  border: none;
  color: #9aa0a6;
  cursor: pointer;
  padding: 4px;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  flex-shrink: 0;
}

.info-btn:hover {
  background: #f1f3f4;
  color: var(--purple);
}

.nav-tabs {
  display: flex;
  align-items: stretch;
  gap: 0;
}

.tab {
  display: inline-flex;
  align-items: center;
  padding: 0 16px;
  height: 100%;
  background: none;
  border: none;
  border-bottom: 3px solid transparent;
  font-size: 0.85rem;
  font-weight: 500;
  color: #5f6368;
  cursor: pointer;
  white-space: nowrap;
  width: auto;
  transition: color 0.15s, border-color 0.15s;
  margin-bottom: -1px; /* overlap the header border */
}

.tab:hover {
  color: var(--purple);
  background: #f8f5f8;
}

.tab.active {
  color: var(--purple);
  border-bottom-color: var(--purple);
  font-weight: 600;
}

/* Mobile */
@media (max-width: 767px) {
  header {
    height: 44px;
  }

  .brand {
    flex: 1;
    min-width: 0;
    margin-right: 0;
  }

  .title {
    font-size: 0.82rem;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .logo {
    height: 26px;
  }

  .nav-tabs {
    display: none;
  }
}
</style>
