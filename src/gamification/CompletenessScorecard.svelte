<script>
  // Pass in the selected feature's properties
  export let districtProperties = {}; 

  // Define which fields represent "valuable" data for a complete profile
  const requiredFields = [
    'website_link', 
    'terms', 
    'election_type', 
    'redist_complete', 
    'guidelines_w'
  ];
  
  // Reactively calculate how many fields are actually filled out
  $: filledFields = requiredFields.filter(field => 
      districtProperties[field] && 
      districtProperties[field] !== 'null' && 
      districtProperties[field] !== ''
  ).length;

  // Calculate percentage
  $: completenessScore = requiredFields.length ? Math.round((filledFields / requiredFields.length) * 100) : 0;

  // Determine color based on score (Red -> Yellow -> Green)
  $: barColor = completenessScore === 100 ? '#10B981' : 
                completenessScore > 50 ? '#F59E0B' : '#EF4444';
</script>

<div class="scorecard">
  <h4>District Completeness: {completenessScore}%</h4>
  <div class="progress-bar-bg">
    <div class="progress-bar-fill" style="width: {completenessScore}%; background-color: {barColor};"></div>
  </div>
  <p class="details">{filledFields} of {requiredFields.length} key fields verified.</p>
</div>

<style>
  .scorecard {
    padding: 1rem;
    background: #f9fafb;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    margin-top: 1rem;
  }
  .progress-bar-bg {
    width: 100%;
    height: 12px;
    background-color: #e5e7eb;
    border-radius: 6px;
    overflow: hidden;
    margin: 8px 0;
  }
  .progress-bar-fill {
    height: 100%;
    transition: width 0.4s ease, background-color 0.4s ease;
  }
  .details {
    font-size: 0.875rem;
    color: #6b7280;
    margin: 0;
  }
</style>