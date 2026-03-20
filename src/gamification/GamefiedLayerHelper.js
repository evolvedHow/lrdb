/**
 * Use this to apply a paint configuration to your map engine 
 * to show districts by their "complete" status.
 */
export const getGamifiedMapPaintStyles = () => {
  return {
    'fill-color': [
      'match',
      ['get', 'status'], // Assuming 'status' is the property in your GeoJSON
      'Complete', '#10B981',     // Green for verified
      'In Progress', '#F59E0B',  // Yellow/Orange for partial
      'Needs Review', '#EF4444', // Red for missing data
      /* default */ '#e5e7eb'    // Grey for unknown
    ],
    'fill-opacity': 0.7,
    'fill-outline-color': '#ffffff'
  };
};