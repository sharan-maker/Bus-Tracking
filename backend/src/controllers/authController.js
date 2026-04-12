const jwt = require('jsonwebtoken');
const User = require('../models/User');

// REGISTER - Create new user account
exports.register = async (req, res) => {
  try {
    const { email, password, firstName, lastName, role } = req.body;

    // Validation: Check all fields are provided
    if (!email || !password || !firstName || !lastName || !role) {
      return res.status(400).json({
        error: 'All fields required (email, password, firstName, lastName, role)'
      });
    }

    // Check if user already exists
    const existingUser = await User.findByEmail(email);
    if (existingUser) {
      return res.status(400).json({ error: 'Email already registered' });
    }

    // Validate role
    if (!['student', 'driver', 'admin'].includes(role)) {
      return res.status(400).json({
        error: 'Role must be: student, driver, or admin'
      });
    }

    // Create user
    const newUser = await User.create(email, password, firstName, lastName, role);

    res.status(201).json({
      message: 'User registered successfully',
      user: newUser
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// LOGIN - Authenticate user and return token
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validation
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password required' });
    }

    // Find user
    const user = await User.findByEmail(email);
    if (!user) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    // Verify password
    const isValidPassword = await User.verifyPassword(password, user.password_hash);
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    // Create JWT token (valid for 7 days)
    const token = jwt.sign(
      { userId: user.user_id, email: user.email, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      message: 'Login successful',
      token: token,
      user: {
        userId: user.user_id,
        email: user.email,
        role: user.role,
        firstName: user.first_name
      }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};