const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 3000 });
let waitingPlayer = null;

wss.on('connection', (ws) => {
  console.log('New player connected');

  ws.on('message', (message) => {
    const data = JSON.parse(message);

    if (data.type === 'join_queue') {
      if (waitingPlayer) {
        const opponent = waitingPlayer;
        waitingPlayer = null;

        // Notify both players they are matched
        ws.send(JSON.stringify({ type: 'match_found', opponent: 'player2' }));
        opponent.send(JSON.stringify({ type: 'match_found', opponent: 'player1' }));
      } else {
        waitingPlayer = ws;
      }
    }
  });

  ws.on('close', () => {
    console.log('Player disconnected');
    if (waitingPlayer === ws) {
      waitingPlayer = null;
    }
  });
});

console.log('WebSocket server running on ws://localhost:3000');
