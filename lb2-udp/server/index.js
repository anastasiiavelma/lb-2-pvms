const dgram = require("node:dgram");

const server = dgram.createSocket("udp4");

const PORT = 4898;

server.on("error", (err) => {
  console.error(`Server error:\n${err.stack}`);
  server.close();
});

server.on("message", async (msg, rinfo) => {
  try {
    const data = JSON.parse(msg.toString());
    if (!data || !Array.isArray(data.numbers)) {
      throw new Error("Invalid data format. Please send an array.");
    }

    const maxElement = Math.max(...data.numbers);

    const response = JSON.stringify({ max: maxElement });

    // Use await to send response asynchronously
    await new Promise((resolve, reject) => {
      server.send(response, rinfo.port, rinfo.address, (err) => {
        if (err) {
          console.error("Error sending response:", err);
          reject(err);
        } else {
          resolve();
        }
      });
    });
  } catch (error) {
    console.error("Error processing message:", error);
  }
});

server.on("listening", () => {
  const address = server.address();
  console.log(`UDP server listening on ${address.address}:${address.port}`);
});

server.bind(PORT);
