// server.js
const WebSocket = require('ws');
const { v4: uuidv4 } = require('uuid'); // for generating unique lobby IDs

const wss = new WebSocket.Server({ port: 8080 });
const lobbies = {}; // lobbyId: [ws, ws]
const sendMatchReady = (lobbyId, playerIndex, socket) => {
  socket.send(JSON.stringify({
    type: "match_ready",
    lobby_id: lobbyId,
    player_index: playerIndex,
  }));
};


wss.on('connection', (ws) => {
  ws.on('message', (message) => {
    const data = JSON.parse(message);

    if (data.type === 'create_lobby') {
      const lobbyId = uuidv4().slice(0, 6);
      lobbies[lobbyId] = [ws];
      ws.lobbyId = lobbyId;
      ws.send(JSON.stringify({ type: 'lobby_created', lobbyId }));
    }

    if (data.type === 'join_lobby') {
      const { lobbyId } = data;
      if (lobbies[lobbyId] && lobbies[lobbyId].length === 1) {
        lobbies[lobbyId].push(ws);
        ws.lobbyId = lobbyId;

        // Notify both players
        lobbies[lobbyId].forEach((client) => {
          client.send(JSON.stringify({ type: 'start_game', lobbyId }));
        });
      } else {
        ws.send(JSON.stringify({ type: 'error', message: 'Lobby full or not found' }));
      }
    }

    if (data.type === 'message') {
      const { lobbyId, content } = data;
      if (lobbies[lobbyId]) {
        lobbies[lobbyId].forEach((client) => {
          if (client !== ws && client.readyState === WebSocket.OPEN) {
            client.send(JSON.stringify({ type: 'message', content }));
          }
        });
      }
    }

    if (lobby.length === 2) {
      sendMatchReady(msg.lobby_id, 0, lobby[0]);
      sendMatchReady(msg.lobby_id, 1, lobby[1]);
    }    

    ws.on('close', () => {
      if (ws.lobbyId && lobbies[ws.lobbyId]) {
        lobbies[ws.lobbyId] = lobbies[ws.lobbyId].filter(client => client !== ws);
        if (lobbies[ws.lobbyId].length === 0) {
          delete lobbies[ws.lobbyId];
        }
      }
    });
  });
});

console.log("WebSocket server running on ws://localhost:8080");
