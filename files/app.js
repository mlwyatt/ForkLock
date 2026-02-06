// ============================================
// GrubMatch - Stimulus-style JavaScript App
// ============================================
// This is structured to easily port to Rails + Stimulus
// Each "controller" section maps to a Stimulus controller

// ============================================
// RESTAURANT DATA (Phase 1 - Predefined List)
// In Phase 2, replace with Google Places API
// ============================================
const RESTAURANTS = [
  {
    id: 1,
    name: "Golden Dragon",
    cuisine: "Chinese",
    rating: 4.5,
    priceRange: "$$",
    distance: "0.3 mi",
    description: "Authentic Szechuan cuisine with hand-pulled noodles and dim sum.",
    image: "https://images.unsplash.com/photo-1552566626-52f8b828add9?w=400&h=300&fit=crop"
  },
  {
    id: 2,
    name: "Pizzeria Napoli",
    cuisine: "Italian",
    rating: 4.7,
    priceRange: "$$",
    distance: "0.5 mi",
    description: "Wood-fired Neapolitan pizza with imported Italian ingredients.",
    image: "https://images.unsplash.com/photo-1604382355076-af4b0eb60143?w=400&h=300&fit=crop"
  },
  {
    id: 3,
    name: "Sakura Sushi",
    cuisine: "Japanese",
    rating: 4.8,
    priceRange: "$$$",
    distance: "0.7 mi",
    description: "Fresh omakase and creative rolls from award-winning chef.",
    image: "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=400&h=300&fit=crop"
  },
  {
    id: 4,
    name: "Taco Loco",
    cuisine: "Mexican",
    rating: 4.3,
    priceRange: "$",
    distance: "0.2 mi",
    description: "Street-style tacos, burritos, and fresh guacamole made to order.",
    image: "https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=400&h=300&fit=crop"
  },
  {
    id: 5,
    name: "Curry House",
    cuisine: "Indian",
    rating: 4.6,
    priceRange: "$$",
    distance: "0.8 mi",
    description: "Rich curries, fresh naan, and vegetarian specialties.",
    image: "https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400&h=300&fit=crop"
  },
  {
    id: 6,
    name: "Burger Joint",
    cuisine: "American",
    rating: 4.4,
    priceRange: "$$",
    distance: "0.4 mi",
    description: "Grass-fed beef burgers with craft beer selection.",
    image: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=300&fit=crop"
  },
  {
    id: 7,
    name: "Pho 99",
    cuisine: "Vietnamese",
    rating: 4.5,
    priceRange: "$",
    distance: "0.6 mi",
    description: "Steaming bowls of pho and banh mi sandwiches.",
    image: "https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=400&h=300&fit=crop"
  },
  {
    id: 8,
    name: "Mediterranean Grill",
    cuisine: "Mediterranean",
    rating: 4.6,
    priceRange: "$$",
    distance: "0.9 mi",
    description: "Fresh falafel, shawarma, and mezze platters.",
    image: "https://images.unsplash.com/photo-1544025162-d76694265947?w=400&h=300&fit=crop"
  },
  {
    id: 9,
    name: "Thai Orchid",
    cuisine: "Thai",
    rating: 4.4,
    priceRange: "$$",
    distance: "0.5 mi",
    description: "Pad thai, green curry, and mango sticky rice.",
    image: "https://images.unsplash.com/photo-1559314809-0d155014e29e?w=400&h=300&fit=crop"
  },
  {
    id: 10,
    name: "Seoul Kitchen",
    cuisine: "Korean",
    rating: 4.7,
    priceRange: "$$",
    distance: "1.0 mi",
    description: "Korean BBQ, bibimbap, and sizzling stone pot dishes.",
    image: "https://images.unsplash.com/photo-1590301157890-4810ed352733?w=400&h=300&fit=crop"
  }
];

// ============================================
// STATE MANAGEMENT
// In Rails, this would be in the database
// Using localStorage to simulate persistence
// ============================================
class SessionStore {
  constructor() {
    this.storageKey = 'grubmatch_sessions';
  }

  getAll() {
    const data = localStorage.getItem(this.storageKey);
    return data ? JSON.parse(data) : {};
  }

  get(code) {
    return this.getAll()[code];
  }

  save(session) {
    const sessions = this.getAll();
    sessions[session.code] = session;
    localStorage.setItem(this.storageKey, JSON.stringify(sessions));
  }

  generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
    let code = '';
    for (let i = 0; i < 4; i++) {
      code += chars[Math.floor(Math.random() * chars.length)];
    }
    return code;
  }
}

const store = new SessionStore();

// Current user state
let currentSession = null;
let currentUser = null;
let currentCardIndex = 0;

// ============================================
// SCREEN NAVIGATION
// In Stimulus: navigate between Turbo frames
// ============================================
function showScreen(screenId) {
  document.querySelectorAll('.screen').forEach(s => s.style.display = 'none');
  document.getElementById(screenId).style.display = '';
}

// ============================================
// HOME CONTROLLER
// ============================================
function initHomeController() {
  document.querySelector('[data-action="create-session"]').addEventListener('click', createSession);
  document.querySelector('[data-action="show-join"]').addEventListener('click', () => showScreen('join-screen'));
  document.querySelector('[data-action="go-home"]').addEventListener('click', () => showScreen('home-screen'));
}

function createSession() {
  const code = store.generateCode();
  const userName = 'Host';
  
  currentSession = {
    code: code,
    participants: [{ name: userName, odne: false }],
    votes: {},
    createdAt: new Date().toISOString()
  };
  
  currentUser = userName;
  store.save(currentSession);
  
  // Show lobby
  document.getElementById('session-code-display').textContent = code;
  updateParticipantsList();
  showScreen('lobby-screen');
}

// ============================================
// JOIN CONTROLLER
// ============================================
function initJoinController() {
  document.querySelector('[data-action="join-session"]').addEventListener('click', joinSession);
  
  // Auto-uppercase code input
  document.getElementById('join-code-input').addEventListener('input', (e) => {
    e.target.value = e.target.value.toUpperCase();
  });
}

function joinSession() {
  const code = document.getElementById('join-code-input').value.toUpperCase();
  const name = document.getElementById('join-name-input').value.trim() || 'Guest';
  
  const session = store.get(code);
  
  if (!session) {
    showToast('Session not found. Check the code!');
    return;
  }
  
  // Check if name already exists, make unique
  let uniqueName = name;
  let counter = 2;
  while (session.participants.some(p => p.name === uniqueName)) {
    uniqueName = `${name} ${counter}`;
    counter++;
  }
  
  session.participants.push({ name: uniqueName, done: false });
  store.save(session);
  
  currentSession = session;
  currentUser = uniqueName;
  
  document.getElementById('session-code-display').textContent = code;
  updateParticipantsList();
  showScreen('lobby-screen');
}

// ============================================
// LOBBY CONTROLLER
// ============================================
function initLobbyController() {
  document.querySelector('[data-action="start-swiping"]').addEventListener('click', startSwiping);
  document.querySelector('[data-action="copy-code"]').addEventListener('click', copyCode);
}

function updateParticipantsList() {
  const container = document.getElementById('participants-list');
  container.innerHTML = currentSession.participants.map(p => 
    `<span class="tag is-medium participant-tag ${p.name === currentUser ? 'is-primary' : 'is-light'}">
      <i class="fas fa-user mr-2"></i>${p.name}
      ${p.done ? '<i class="fas fa-check ml-2 has-text-success"></i>' : ''}
    </span>`
  ).join('');
}

function copyCode() {
  navigator.clipboard.writeText(currentSession.code);
  showToast('Code copied!');
}

function startSwiping() {
  currentCardIndex = 0;
  renderCards();
  updateProgress();
  showScreen('swipe-screen');
}

// ============================================
// SWIPE CONTROLLER
// ============================================
function initSwipeController() {
  document.querySelector('[data-action="swipe-left"]').addEventListener('click', () => swipe('left'));
  document.querySelector('[data-action="swipe-right"]').addEventListener('click', () => swipe('right'));
  document.querySelector('[data-action="show-results"]').addEventListener('click', showResults);
  document.querySelector('[data-action="back-to-swipe"]').addEventListener('click', backToSwipe);
}

function renderCards() {
  const stack = document.getElementById('card-stack');
  const completeMsg = document.getElementById('swipe-complete');
  
  if (currentCardIndex >= RESTAURANTS.length) {
    stack.innerHTML = '';
    completeMsg.style.display = '';
    document.querySelector('.swipe-actions').style.display = 'none';
    markUserDone();
    return;
  }
  
  completeMsg.style.display = 'none';
  document.querySelector('.swipe-actions').style.display = '';
  
  // Render next 3 cards (for stack effect)
  const cardsToShow = RESTAURANTS.slice(currentCardIndex, currentCardIndex + 3);
  
  stack.innerHTML = cardsToShow.map((restaurant, idx) => `
    <div class="restaurant-card" data-id="${restaurant.id}" data-index="${currentCardIndex + idx}">
      <div class="swipe-indicator nope">NOPE</div>
      <div class="swipe-indicator like">LIKE</div>
      <div class="card-image-container">
        <img src="${restaurant.image}" alt="${restaurant.name}" loading="lazy">
        <div class="card-overlay">
          <span class="cuisine-tag">${restaurant.cuisine}</span>
        </div>
      </div>
      <div class="card-body">
        <h3 class="title is-4">${restaurant.name}</h3>
        <div class="card-meta">
          <span class="stars">
            ${'★'.repeat(Math.floor(restaurant.rating))}${restaurant.rating % 1 ? '½' : ''}
            <span class="has-text-grey-light">${restaurant.rating}</span>
          </span>
          <span><i class="fas fa-dollar-sign"></i> ${restaurant.priceRange}</span>
          <span><i class="fas fa-walking"></i> ${restaurant.distance}</span>
        </div>
        <p class="card-description">${restaurant.description}</p>
      </div>
    </div>
  `).join('');
  
  // Initialize drag on top card
  initCardDrag(stack.querySelector('.restaurant-card'));
}

function initCardDrag(card) {
  if (!card) return;
  
  let startX, startY, currentX, currentY;
  let isDragging = false;
  
  const onStart = (e) => {
    isDragging = true;
    card.classList.add('swiping');
    const point = e.touches ? e.touches[0] : e;
    startX = point.clientX;
    startY = point.clientY;
  };
  
  const onMove = (e) => {
    if (!isDragging) return;
    e.preventDefault();
    
    const point = e.touches ? e.touches[0] : e;
    currentX = point.clientX - startX;
    currentY = point.clientY - startY;
    
    const rotate = currentX * 0.1;
    card.style.transform = `translate(${currentX}px, ${currentY}px) rotate(${rotate}deg)`;
    
    // Show indicators
    const nope = card.querySelector('.swipe-indicator.nope');
    const like = card.querySelector('.swipe-indicator.like');
    
    if (currentX < -50) {
      nope.style.opacity = Math.min(1, Math.abs(currentX) / 100);
      like.style.opacity = 0;
    } else if (currentX > 50) {
      like.style.opacity = Math.min(1, currentX / 100);
      nope.style.opacity = 0;
    } else {
      nope.style.opacity = 0;
      like.style.opacity = 0;
    }
  };
  
  const onEnd = () => {
    if (!isDragging) return;
    isDragging = false;
    card.classList.remove('swiping');
    
    if (currentX < -100) {
      swipe('left');
    } else if (currentX > 100) {
      swipe('right');
    } else {
      card.style.transform = '';
      card.querySelector('.swipe-indicator.nope').style.opacity = 0;
      card.querySelector('.swipe-indicator.like').style.opacity = 0;
    }
  };
  
  card.addEventListener('mousedown', onStart);
  card.addEventListener('touchstart', onStart, { passive: true });
  document.addEventListener('mousemove', onMove);
  document.addEventListener('touchmove', onMove, { passive: false });
  document.addEventListener('mouseup', onEnd);
  document.addEventListener('touchend', onEnd);
}

function swipe(direction) {
  const card = document.querySelector('.restaurant-card');
  if (!card) return;
  
  const restaurantId = parseInt(card.dataset.id);
  
  // Record vote
  if (!currentSession.votes[currentUser]) {
    currentSession.votes[currentUser] = {};
  }
  currentSession.votes[currentUser][restaurantId] = direction === 'right';
  store.save(currentSession);
  
  // Animate card
  card.classList.add(direction === 'left' ? 'swipe-left' : 'swipe-right');
  
  setTimeout(() => {
    currentCardIndex++;
    updateProgress();
    renderCards();
  }, 300);
}

function updateProgress() {
  document.getElementById('swipe-progress').textContent = 
    `${Math.min(currentCardIndex + 1, RESTAURANTS.length)} / ${RESTAURANTS.length}`;
}

function markUserDone() {
  // Refresh session from storage (in case others updated)
  currentSession = store.get(currentSession.code);
  
  const participant = currentSession.participants.find(p => p.name === currentUser);
  if (participant) {
    participant.done = true;
    store.save(currentSession);
  }
}

// ============================================
// RESULTS CONTROLLER
// ============================================
function initResultsController() {
  document.querySelector('[data-action="new-session"]').addEventListener('click', () => {
    currentSession = null;
    currentUser = null;
    currentCardIndex = 0;
    showScreen('home-screen');
  });
}

function showResults() {
  // Refresh session
  currentSession = store.get(currentSession.code);
  
  renderResults();
  showScreen('results-screen');
}

function backToSwipe() {
  if (currentCardIndex >= RESTAURANTS.length) {
    showScreen('swipe-screen');
  } else {
    showScreen('swipe-screen');
  }
}

function renderResults() {
  const waitingDiv = document.getElementById('waiting-message');
  const waitingParticipants = document.getElementById('waiting-participants');
  const resultsList = document.getElementById('results-list');
  
  // Check who's still swiping
  const notDone = currentSession.participants.filter(p => !p.done);
  
  if (notDone.length > 0) {
    waitingDiv.style.display = '';
    waitingParticipants.innerHTML = notDone.map(p => 
      `<span class="tag is-light mr-1">${p.name}</span>`
    ).join('');
  } else {
    waitingDiv.style.display = 'none';
  }
  
  // Tally votes
  const tallies = {};
  RESTAURANTS.forEach(r => {
    tallies[r.id] = { restaurant: r, yesVotes: [], totalVoters: 0 };
  });
  
  Object.entries(currentSession.votes).forEach(([userName, votes]) => {
    Object.entries(votes).forEach(([restaurantId, liked]) => {
      const id = parseInt(restaurantId);
      tallies[id].totalVoters++;
      if (liked) {
        tallies[id].yesVotes.push(userName);
      }
    });
  });
  
  // Sort by yes votes (descending)
  const sorted = Object.values(tallies)
    .filter(t => t.totalVoters > 0)
    .sort((a, b) => b.yesVotes.length - a.yesVotes.length);
  
  if (sorted.length === 0) {
    resultsList.innerHTML = `
      <div class="notification is-info">
        <p>No votes yet! Start swiping to see results.</p>
      </div>
    `;
    return;
  }
  
  const maxVotes = sorted[0].yesVotes.length;
  
  resultsList.innerHTML = sorted.map((item, idx) => {
    const r = item.restaurant;
    const isWinner = idx === 0 && item.yesVotes.length > 0;
    const isTie = idx > 0 && item.yesVotes.length === maxVotes;
    
    return `
      <div class="result-card ${isWinner || isTie ? 'winner' : ''}" style="position: relative;">
        ${isWinner ? '<div class="winner-badge"><i class="fas fa-crown"></i></div>' : ''}
        <div class="result-rank">${idx + 1}</div>
        <img class="result-image" src="${r.image}" alt="${r.name}">
        <div class="result-info">
          <h4>${r.name}</h4>
          <p class="cuisine">${r.cuisine} · ${r.priceRange} · ${r.distance}</p>
          <div class="vote-avatars">
            ${item.yesVotes.map(name => 
              `<div class="vote-avatar" title="${name}">${name.charAt(0).toUpperCase()}</div>`
            ).join('')}
          </div>
        </div>
        <div class="result-votes">
          <div class="count">${item.yesVotes.length}</div>
          <div class="label">likes</div>
        </div>
      </div>
    `;
  }).join('');
}

// ============================================
// TOAST NOTIFICATIONS
// ============================================
function showToast(message) {
  const existing = document.querySelector('.toast');
  if (existing) existing.remove();
  
  const toast = document.createElement('div');
  toast.className = 'toast';
  toast.textContent = message;
  document.body.appendChild(toast);
  
  setTimeout(() => toast.remove(), 2500);
}

// ============================================
// INITIALIZE APP
// ============================================
document.addEventListener('DOMContentLoaded', () => {
  initHomeController();
  initJoinController();
  initLobbyController();
  initSwipeController();
  initResultsController();
  
  // Check for existing session in URL (for sharing)
  const params = new URLSearchParams(window.location.search);
  const joinCode = params.get('join');
  if (joinCode) {
    document.getElementById('join-code-input').value = joinCode;
    showScreen('join-screen');
  }
});
