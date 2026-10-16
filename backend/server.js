const express = require('express');
const cors = require('cors');

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

const resources = [
  {
    name: 'Seminar Hall A',
    location: 'Academic Block · Floor 2',
    type: 'Venue',
    icon: 'meeting_room_rounded',
    available: true,
  },
  {
    name: 'Projector P-12',
    location: 'Library · Help Desk',
    type: 'Equipment',
    icon: 'videocam_rounded',
    available: true,
  },
  {
    name: 'Study Room 03',
    location: 'Central Library · Floor 1',
    type: 'Study space',
    icon: 'menu_book_rounded',
    available: true,
  },
  {
    name: 'Innovation Lab',
    location: 'Tech Block · Floor 3',
    type: 'Lab',
    icon: 'memory_rounded',
    available: true,
  },
];

const bookings = [
  {
    name: 'Study Room 03',
    location: 'Central Library · Floor 1',
    type: 'Study space',
    icon: 'menu_book_rounded',
    available: true,
  },
];

app.get('/api/health', (_req, res) => {
  res.json({ status: 'ok', service: 'campushub-backend' });
});

app.get('/api/resources', (_req, res) => {
  res.json({ resources });
});

app.get('/api/bookings', (_req, res) => {
  res.json({ bookings });
});

app.post('/api/bookings', (req, res) => {
  const booking = req.body;

  if (!booking || !booking.name) {
    return res.status(400).json({ error: 'Booking name is required.' });
  }

  const exists = bookings.some((item) => item.name === booking.name);
  if (exists) {
    return res.status(200).json({ booking: bookings.find((item) => item.name === booking.name) });
  }

  bookings.push({
    ...booking,
    available: booking.available ?? true,
  });

  return res.status(201).json({ booking: bookings[bookings.length - 1] });
});

app.post('/api/resources/share', (req, res) => {
  const share = req.body;

  if (!share || !share.name) {
    return res.status(400).json({ error: 'Resource name is required.' });
  }

  return res.status(201).json({
    message: `Share request for ${share.name} saved successfully.`,
    item: share,
  });
});

app.listen(port, () => {
  console.log(`CampusHub backend running at http://localhost:${port}`);
});
