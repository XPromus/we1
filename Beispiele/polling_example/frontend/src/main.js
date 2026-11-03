import './style.css'

// '/api' is proxied to the Java backend (http://localhost:8888) by vite.config.js
const API = '/api'

const logEl = document.getElementById('log')
const updateForm = document.getElementById('update-form')
const updateInput = document.getElementById('update-input')

// ---------- short polling ----------

let shortTimer = null
let shortRequests = 0
let shortUnchanged = 0
let lastShortVersion = -1

const shortIntervalInput = document.getElementById('short-interval')
const shortStartBtn = document.getElementById('short-start')
const shortStopBtn = document.getElementById('short-stop')
const shortStats = document.getElementById('short-stats')

async function shortPoll() {
  try {
    const res = await fetch(`${API}/state`)
    const data = await res.json()
    shortRequests++
    const changed = data.version !== lastShortVersion
    if (!changed) shortUnchanged++
    lastShortVersion = data.version
    log('SHORT', `v${data.version} "${data.message}"${changed ? ' — changed' : ' — unchanged'}`)
    shortStats.textContent = `requests: ${shortRequests} · unchanged answers: ${shortUnchanged}`
  } catch (err) {
    log('SHORT', `error: ${err.message}`)
  }
}

function startShortPolling() {
  if (shortTimer) return
  const intervalSec = Math.max(1, Number(shortIntervalInput.value) || 2)
  shortPoll()
  shortTimer = setInterval(shortPoll, intervalSec * 1000)
  shortStartBtn.disabled = true
  shortStopBtn.disabled = false
  shortIntervalInput.disabled = true
}

function stopShortPolling() {
  clearInterval(shortTimer)
  shortTimer = null
  shortStartBtn.disabled = false
  shortStopBtn.disabled = true
  shortIntervalInput.disabled = false
}

// ---------- long polling ----------

let longPolling = false
let longRequests = 0
let lastLongVersion = 0

const longStartBtn = document.getElementById('long-start')
const longStopBtn = document.getElementById('long-stop')
const longStats = document.getElementById('long-stats')

async function longPollLoop() {
  while (longPolling) {
    const started = performance.now()
    try {
      // The server holds this request until the version changes or it times out
      const res = await fetch(`${API}/longpoll?since=${lastLongVersion}`)
      const data = await res.json()
      const waitedMs = Math.round(performance.now() - started)
      lastLongVersion = data.version
      longRequests++
      log('LONG', `v${data.version} "${data.message}" after ${waitedMs} ms${data.timeout ? ' — timeout' : ' — update'}`)
      longStats.textContent = `requests: ${longRequests}`
      // immediately re-issue the request: this is what makes it "long polling"
    } catch (err) {
      if (!longPolling) return
      log('LONG', `error: ${err.message} — retrying in 2 s`)
      await new Promise((resolve) => setTimeout(resolve, 2000))
    }
  }
}

function startLongPolling() {
  if (longPolling) return
  longPolling = true
  longStartBtn.disabled = true
  longStopBtn.disabled = false
  longPollLoop()
}

function stopLongPolling() {
  longPolling = false
  longStartBtn.disabled = false
  longStopBtn.disabled = true
}

// ---------- update + log ----------

updateForm.addEventListener('submit', async (event) => {
  event.preventDefault()
  const message = updateInput.value.trim()
  if (!message) return
  try {
    const res = await fetch(`${API}/update`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message }),
    })
    const data = await res.json()
    log('POST', `update sent -> v${data.version} "${data.message}"`)
    updateInput.value = ''
  } catch (err) {
    log('POST', `error: ${err.message}`)
  }
})

shortStartBtn.addEventListener('click', startShortPolling)
shortStopBtn.addEventListener('click', stopShortPolling)
longStartBtn.addEventListener('click', startLongPolling)
longStopBtn.addEventListener('click', stopLongPolling)

function log(tag, text) {
  const li = document.createElement('li')
  const time = new Date().toLocaleTimeString('en-GB', { hour12: false })
    + '.' + String(Date.now() % 1000).padStart(3, '0')
  const timeSpan = document.createElement('span')
  timeSpan.className = 'time'
  timeSpan.textContent = time
  const tagSpan = document.createElement('span')
  tagSpan.className = `tag tag-${tag.toLowerCase()}`
  tagSpan.textContent = tag
  li.append(timeSpan, tagSpan, document.createTextNode(' ' + text))
  logEl.prepend(li) // newest entry on top
}
