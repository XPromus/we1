import './style.css'

const status = document.getElementById('status')
const messages = document.getElementById('messages')
const form = document.getElementById('send-form')
const input = document.getElementById('message-input')
const connectBtn = document.getElementById('connect-btn')
const disconnectBtn = document.getElementById('disconnect-btn')

let ws = null

function connect() {
  if (ws && (ws.readyState === WebSocket.OPEN || ws.readyState === WebSocket.CONNECTING)) {
    return
  }

  ws = new WebSocket('ws://localhost:8887')

  ws.onopen = () => {
    status.textContent = 'Connected'
    updateButtons()
  }

  ws.onclose = () => {
    status.textContent = 'Disconnected'
    updateButtons()
  }

  ws.onerror = () => {
    status.textContent = 'Connection error'
    updateButtons()
  }

  ws.onmessage = (event) => {
    addMessage(event.data)
  }

  status.textContent = 'Connecting...'
  updateButtons()
}

function disconnect() {
  if (ws) {
    ws.close()
  }
}

function updateButtons() {
  const connected = ws !== null && (ws.readyState === WebSocket.OPEN || ws.readyState === WebSocket.CONNECTING)
  connectBtn.disabled = connected
  disconnectBtn.disabled = !connected
}

connectBtn.addEventListener('click', connect)
disconnectBtn.addEventListener('click', disconnect)

form.addEventListener('submit', (event) => {
  event.preventDefault()
  const message = input.value.trim()
  if (message && ws && ws.readyState === WebSocket.OPEN) {
    ws.send(message)
    input.value = ''
  }
})

function addMessage(text) {
  const li = document.createElement('li')
  li.textContent = text
  messages.appendChild(li)
}
