const supabase = require('../config/database');

// Driver updates location
exports.updateLocation = async (req, res) => {
  try {
    const { bus_id, latitude, longitude, speed } = req.body;
    const driver_id = req.user.userId;

    if (!bus_id || !latitude || !longitude) {
      return res.status(400).json({ error: 'bus_id, latitude, longitude required' });
    }

    // Check if location exists for this bus
    const { data: existing } = await supabase
      .from('bus_locations')
      .select('location_id')
      .eq('bus_id', bus_id)
      .single();

    let result;
    if (existing) {
      // Update existing location
      const { data, error } = await supabase
        .from('bus_locations')
        .update({ latitude, longitude, speed, updated_at: new Date() })
        .eq('bus_id', bus_id)
        .select()
        .single();
      if (error) throw new Error(error.message);
      result = data;
    } else {
      // Insert new location
      const { data, error } = await supabase
        .from('bus_locations')
        .insert([{ bus_id, driver_id, latitude, longitude, speed }])
        .select()
        .single();
      if (error) throw new Error(error.message);
      result = data;
    }

    res.json({ message: 'Location updated', location: result });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get bus location (for students)
exports.getBusLocation = async (req, res) => {
  try {
    const { bus_id } = req.params;

    const { data, error } = await supabase
      .from('bus_locations')
      .select('*')
      .eq('bus_id', bus_id)
      .single();

    if (error || !data) {
      return res.json({ message: 'Bus location not available' });
    }

    res.json({ location: data });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get all active bus locations
exports.getAllLocations = async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('bus_locations')
      .select('*, buses(bus_number, status)');

    if (error) throw new Error(error.message);

    res.json({ locations: data });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};                                                   