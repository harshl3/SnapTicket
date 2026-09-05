require('dotenv').config({ path: __dirname + '/../.env' });
const dns = require('dns');
dns.setServers(['8.8.8.8', '8.8.4.4']);
const mongoose = require('mongoose');
const User = require('../models/User');
const Event = require('../models/Event');
const Booking = require('../models/Booking');

const users = [
  {
    name: 'Alice Johnson',
    email: 'alice@example.com',
    interests: ['Technology', 'Music']
  },
  {
    name: 'Bob Smith',
    email: 'bob@example.com',
    interests: ['Sports', 'Entertainment']
  },
  {
    name: 'Charlie Brown',
    email: 'charlie@example.com',
    interests: ['Business', 'Technology']
  }
];

const events = [
  {
    name: 'AI & Future Technology Summit 2026',
    category: 'Technology',
    description: 'Explore the limits of artificial intelligence, neural networks, and future technologies. Join industry leaders for keynote presentations, panels, and live coding demos.',
    date: '2026-09-15',
    time: '10:00 AM',
    venue: 'Pune Convention Centre',
    totalSeats: 100,
    availableSeats: 80,
    price: 499,
    image: 'https://images.unsplash.com/photo-1591453089816-0fbb971b454c?auto=format&fit=crop&q=80&w=600'
  },
  {
    name: 'Live Rock Music Festival 2026',
    category: 'Music',
    description: 'An open-air music festival featuring top rock bands, acoustic acts, and amazing street food. Bring your friends for a night of incredible rhythms and vibes.',
    date: '2026-10-05',
    time: '05:30 PM',
    venue: 'Sunset Meadows Arena',
    totalSeats: 100,
    availableSeats: 20,
    price: 899,
    image: 'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?auto=format&fit=crop&q=80&w=600'
  },
  {
    name: 'National Cricket Championship Finals',
    category: 'Sports',
    description: 'Experience the ultimate rivalry live from the stadium! Two of the best teams go head-to-head for the historic championship trophy.',
    date: '2026-08-30',
    time: '02:00 PM',
    venue: 'Wankhede Cricket Stadium',
    totalSeats: 100,
    availableSeats: 5,
    price: 1200,
    image: 'https://images.unsplash.com/photo-1531415080290-bc9b8998063a?auto=format&fit=crop&q=80&w=600'
  },
  {
    name: 'Stand-up Comedy Night featuring Zakir',
    category: 'Entertainment',
    description: 'Get ready for a night of non-stop laughter and brilliant observational humor. Food and beverages are available at the venue.',
    date: '2026-09-02',
    time: '08:00 PM',
    venue: 'The Laugh Club',
    totalSeats: 50,
    availableSeats: 0,
    price: 350,
    image: 'https://images.unsplash.com/photo-1585699324551-f6c309eed262?auto=format&fit=crop&q=80&w=600'
  },
  {
    name: 'Startup Leadership and Networking Meetup',
    category: 'Business',
    description: 'Connect with local startup founders, angel investors, and experienced product leaders. Exchange ideas, pitching tips, and explore partnership opportunities.',
    date: '2026-09-22',
    time: '06:00 PM',
    venue: 'WeWork Hub, Bangalore',
    totalSeats: 150,
    availableSeats: 150,
    price: 199,
    image: 'https://images.unsplash.com/photo-1515187029135-18ee286d815b?auto=format&fit=crop&q=80&w=600'
  },
  {
    name: 'Innovation Expo & Startup Showroom',
    category: 'Technology',
    description: 'Interact with cutting edge gadgets, new software demos, and smart appliances. Meet innovators presenting their latest patented tech concepts.',
    date: '2026-11-12',
    time: '11:00 AM',
    venue: 'Pragati Maidan Exhibition Hall',
    totalSeats: 80,
    availableSeats: 40,
    price: 150,
    image: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&q=80&w=600'
  },
  {
    name: 'Classical Indian Music & Fusion Evening',
    category: 'Music',
    description: 'Immerse yourself in soul-stirring classical ragas on sitar and tabla, followed by a contemporary fusion set by international artists.',
    date: '2026-09-28',
    time: '06:30 PM',
    venue: 'Royal Opera House',
    totalSeats: 120,
    availableSeats: 10,
    price: 600,
    image: 'https://images.unsplash.com/photo-1511192336575-5a79af67a629?auto=format&fit=crop&q=80&w=600'
  },
  {
    name: 'Product Strategy & Scale Conference 2026',
    category: 'Business',
    description: 'A premium masterclass event discussing SaaS growth loops, user acquisition channels, metrics frameworks, and monetization scaling strategies.',
    date: '2026-10-18',
    time: '09:00 AM',
    venue: 'Taj Lands End',
    totalSeats: 200,
    availableSeats: 180,
    price: 1500,
    image: 'https://images.unsplash.com/photo-1475721027785-f74eccf877e2?auto=format&fit=crop&q=80&w=600'
  }
];

const seedDatabase = async () => {
  try {
    const mongoUri = process.env.MONGO_URI;
    if (!mongoUri) throw new Error('MONGO_URI is required to seed the database');
    console.log(`Connecting to MongoDB for seeding: ${mongoUri}`);
    await mongoose.connect(mongoUri);

    console.log('Connected to database. Cleaning collections...');
    await User.deleteMany({});
    await Event.deleteMany({});
    await Booking.deleteMany({});
    console.log('Database clean completed.');

    console.log('Seeding Mock Users...');
    const createdUsers = await User.insertMany(users);
    console.log(`Created ${createdUsers.length} users successfully.`);

    console.log('Seeding Mock Events...');
    const createdEvents = await Event.insertMany(events);
    console.log(`Created ${createdEvents.length} events successfully.`);

    // Create an initial demo booking for Alice Johnson (Index 0) on AI Tech Summit (Index 0)
    console.log('Creating initial demo booking for Alice Johnson...');
    const alice = createdUsers[0];
    const techSummit = createdEvents[0];
    
    const quantity = 2;
    const totalAmount = techSummit.price * quantity;
    const bookingRef = `BK-2026-${Math.floor(100000 + Math.random() * 900000)}`;

    const demoBooking = new Booking({
      bookingReference: bookingRef,
      userId: alice._id,
      eventId: techSummit._id,
      quantity,
      totalAmount,
      bookingStatus: 'CONFIRMED'
    });

    await demoBooking.save();
    
    // Decrement available seats for techSummit
    techSummit.availableSeats -= quantity;
    await techSummit.save();

    console.log(`Demo Booking Seeded! Ref: ${bookingRef}, Seats decremented from 80 to ${techSummit.availableSeats}.`);
    console.log('Database Seeding Successful!');
    
    await mongoose.connection.close();
    console.log('Database connection closed.');
    process.exit(0);
  } catch (error) {
    console.error('Seeding process failed:', error);
    process.exit(1);
  }
};

if (require.main === module) {
  seedDatabase();
}

module.exports = { seedDatabase, users, events };
