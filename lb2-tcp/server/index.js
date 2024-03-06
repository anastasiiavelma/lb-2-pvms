const express = require("express");
const cors = require("cors");
const { Server } = require("socket.io");

const app = express();
const PORT = 3333;

app.use(express.json());
app.use(cors());

const server = app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});

const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
  },
});

io.on("connection", (socket) => {
  socket.on("find-max", (data) => {
    try {
      if (!data || !Array.isArray(data.numbers)) {
        throw new Error("Invalid data format. Please send an array.");
      }

      const maxElement = Math.max(...data.numbers);

      socket.emit("max-result", { max: maxElement });
    } catch (error) {
      console.error(error);

      socket.emit("error", { error: error.message });
    }
  });
});
