const express = require("express");
const bodyParser = require("body-parser");
const twilio = require("twilio");

const app = express();
app.use(bodyParser.json());

// Load from environment variables (best practice)
const accountSid = process.env.TWILIO_ACCOUNT_SID ;
const authToken = process.env.TWILIO_AUTH_TOKEN;
const serviceSid = process.env.TWILIO_VERIFY_SERVICE_SID;

const client = twilio(accountSid, authToken);

// Send OTP
app.post("/send-otp", async (req, res) => {
  try {
    const { phone } = req.body;
    const verification = await client.verify.v2.services(serviceSid)
      .verifications
      .create({ to: phone, channel: "sms" });
    res.json({ status: verification.status });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Verify OTP
app.post("/verify-otp", async (req, res) => {
  try {
    const { phone, code } = req.body;
    const verification_check = await client.verify.v2.services(serviceSid)
      .verificationChecks
      .create({ to: phone, code });
    res.json({ status: verification_check.status });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));