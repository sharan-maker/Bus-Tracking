const supabase = require('../config/database');

// Add new bus (Admin only)
exports.addBus = async (req, res) => {
  try {
    const { bus_number, capacity } = req.body;

    if (!bus_number) {
      return res.status(400).json({ error: 'Bus number is required' });
    }

    const { data, error } = await supabase
      .from('buses')
      .insert([{ bus_number, capacity }])
      .select()
      .single();

    if (error) throw new Error(error.message);

    res.status(201).json({ message: 'Bus added successfully', bus: data });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get all buses
exports.getAllBuses = async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('buses')
      .select('*')
      .eq('status', 'active');

    if (error) throw new Error(error.message);

    res.json({ buses: data });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Add route (Admin only)
exports.addRoute = async (req, res) => {
  try {
    const { route_name, start_location, end_location, bus_id } = req.body;

    if (!route_name || !start_location || !end_location || !bus_id) {
      return res.status(400).json({ error: 'All fields required' });
    }

    const { data, error } = await supabase
      .from('routes')
      .insert([{ route_name, start_location, end_location, bus_id }])
      .select()
      .single();

    if (error) throw new Error(error.message);

    res.status(201).json({ message: 'Route added successfully', route: data });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Search buses by location
exports.searchBuses = async (req, res) => {
  try {
    const { location } = req.query;

    if (!location) {
      return res.status(400).json({ error: 'Location is required' });
    }

    const { data, error } = await supabase
      .from('routes')
      .select('*, buses(*)')
      .or(`start_location.ilike.%${location}%,end_location.ilike.%${location}%`)
      .eq('status', 'active');

    if (error) throw new Error(error.message);

    res.json({ routes: data, count: data.length });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};// Mark bus as unavailable (Admin only)
exports.markBusUnavailable = async (req, res) => {
  try {
    const { bus_id, reason } = req.body;

    const { error } = await supabase
      .from('buses')
      .update({ status: 'unavailable' })
      .eq('bus_id', bus_id);

    if (error) throw new Error(error.message);

    res.json({ message: `Bus ${bus_id} marked as unavailable`, reason });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Set alternate route (Admin only)
exports.setAlternateRoute = async (req, res) => {
  try {
    const { original_route_id, alternate_route_id, reason } = req.body;

    if (!original_route_id || !alternate_route_id) {
      return res.status(400).json({ error: 'Both route IDs required' });
    }

    const { data, error } = await supabase
      .from('alternate_routes')
      .insert([{ original_route_id, alternate_route_id, reason }])
      .select()
      .single();

    if (error) throw new Error(error.message);

    res.status(201).json({ message: 'Alternate route set', alternate: data });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get alternate route
exports.getAlternateRoute = async (req, res) => {
  try {
    const { route_id } = req.params;

    const { data, error } = await supabase
      .from('alternate_routes')
      .select('*, routes!alternate_routes_alternate_route_id_fkey(*)')
      .eq('original_route_id', route_id)
      .eq('status', 'active')
      .single();

    if (error || !data) {
      return res.json({ message: 'No alternate route available' });
    }

    res.json({ alternate_route: data });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Assign student to bus
exports.assignStudentToBus = async (req, res) => {
  try {
    const { student_id, bus_id, route_id } = req.body;

    const { data, error } = await supabase
      .from('student_bus')
      .insert([{ student_id, bus_id, route_id }])
      .select()
      .single();

    if (error) throw new Error(error.message);

    res.status(201).json({ message: 'Student assigned to bus', data });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};