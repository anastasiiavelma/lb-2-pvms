import React, { useState, useEffect } from "react";
import io from "socket.io-client";
import "./App.css";

const BASE_SOCKET_URL = "http://localhost:3333";

function App() {
  const [socket, setSocket] = useState(null);
  const [inputArray, setInputArray] = useState("");
  const [result, setResult] = useState("");

  useEffect(() => {
    const newSocket = io(BASE_SOCKET_URL);
    setSocket(newSocket);

    return () => newSocket.disconnect();
  }, []);

  const onChange = async (e) => {
    const value = e.target.value.trim();
    setInputArray(value);

    if (value) {
      try {
        const numbers = value.split(",").map(Number);
        console.log(numbers);
        socket.emit("find-max", { numbers });
      } catch (error) {
        console.error(error);
        alert("Invalid input format. Please enter comma-separated numbers.");
      }
    }
  };

  useEffect(() => {
    if (socket) {
      socket.on("max-result", (data) => {
        setResult(data.max || "");
      });
    }
  }, [socket]);

  return (
    <div className="container">
      <h1 className="title">Find Maximum Number</h1>

      <div className="input-container">
        <label htmlFor="array">Enter comma-separated numbers:</label>
        <input
          id="array"
          value={inputArray}
          onChange={onChange}
          className="input-field"
          placeholder="1, 2, 3, 4"
        />
      </div>

      <div className="result-container">
        <h2 className="result-text">Result:</h2>
        <p className="result-value">{result}</p>
      </div>
    </div>
  );
}

export default App;
