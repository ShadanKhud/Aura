const express = require("express");
const Stripe = require("stripe");
require("dotenv").config();
const cors = require("cors");

const app = express();
const stripe = Stripe(process.env.STRIPE_SECRET_KEY);

app.use(express.json());
app.use(cors());

app.post('/add-card', (req, res) => {
  console.log("Received card data:", req.body);
  res.json({ message: "Card added successfully" });
});

// Listen on 0.0.0.0 to allow connections from other devices
app.listen(5000, '0.0.0.0', () => {
  console.log("Server is running on port 5000");
});
// 🔹 Create Payment Intent
app.post("/create-payment-intent", async (req, res) => {
    try {
        const { amount, currency } = req.body;
        
        const paymentIntent = await stripe.paymentIntents.create({
            amount: amount, // Amount in cents (e.g., $1.00 = 100)
            currency: currency,
            payment_method_types: ["card"],
        });

        res.json({ clientSecret: paymentIntent.client_secret });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// Start Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
