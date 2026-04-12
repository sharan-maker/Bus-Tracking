const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');

dotenv.config();

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: '*' }
});

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
const authRoutes = require('./routes/auth');
const busRoutes = require('./routes/bus');
const locationRoutes = require('./routes/location');

app.use('/api/auth', authRoutes);
app.use('/api/bus', busRoutes);
app.use('/api/location', locationRoutes);

// Home route
app.get('/', (req, res) => {
  res.json({ message: 'College Bus Tracking API - Week 5' });
});

// Socket.io - Real time location
io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  // Driver sends location
  socket.on('driver:location', (data) => {
    console.log('Location received:', data);
    // Broadcast to all students watching this bus
    io.emit(`bus:${data.bus_id}:location`, data);
  });

  // Student joins bus room
  socket.on('student:watch', (bus_id) => {
    socket.join(`bus_${bus_id}`);
    console.log(`Student watching bus ${bus_id}`);
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

// Start Server
const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
  console.log(`✓ Server running on http://localhost:${PORT}`);
});