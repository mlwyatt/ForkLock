# GrubMatch Implementation Plan

> A group decision-making app for choosing where to eat. Swipe on restaurants, find consensus.

## Overview

**Architecture:** Rails 7+ monolith with Hotwire (Turbo + Stimulus)
**Frontend:** Server-rendered ERB views, Bulma CSS, Stimulus controllers
**Real-time:** Turbo Streams over ActionCable
**Core Flow:** Create session → Share code → Everyone swipes async → See ranked results

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Rails 7.1+ |
| Database | SQLite |
| Frontend JS | Stimulus, Turbo |
| CSS | Bulma |
| Real-time | ActionCable + Turbo Streams |
| Background Jobs | Solid Queue (Rails 8) |
| Testing | RSpec, Capybara |
| Phase 2 API | Google Places |

---

## Data Model

```
┌─────────────┐       ┌──────────────┐       ┌─────────┐
│   Session   │──────<│ Participant  │──────<│  Vote   │
└─────────────┘       └──────────────┘       └─────────┘
                                                  │
                                                  │
                                             ┌────┴────┐
                                             │Restaurant│
                                             └─────────┘
```

### Session
| Column | Type | Notes |
|--------|------|-------|
| id | integer | Primary key |
| code | string(4) | Unique, indexed, uppercase |
| status | enum | `lobby`, `active`, `closed` |
| expires_at | datetime | Auto-set to 24h from creation |
| created_at | datetime | |

### Participant
| Column | Type | Notes |
|--------|------|-------|
| id | integer | Primary key |
| session_id | integer | Foreign key |
| name | string | Required, max 20 chars |
| token | string | Secure random, indexed, for cookie auth |
| completed_at | datetime | Null until finished swiping |
| created_at | datetime | |

### Vote
| Column | Type | Notes |
|--------|------|-------|
| id | integer | Primary key |
| participant_id | integer | Foreign key |
| restaurant_id | integer | References Restaurant |
| liked | boolean | True = swipe right |
| created_at | datetime | |

*Unique index on (participant_id, restaurant_id)*

### Restaurant
| Column | Type | Notes |
|--------|------|-------|
| id | integer | Primary key (Phase 1), place_id string (Phase 2) |
| name | string | |
| cuisine | string | |
| rating | decimal | 1.0 - 5.0 |
| price_level | integer | 1-4 ($ to $$$$) |
| distance | string | Display string like "0.3 mi" |
| description | text | Short tagline |
| image_url | string | |
| address | string | Phase 2 |
| latitude | decimal | Phase 2 |
| longitude | decimal | Phase 2 |

---

## Phase 1: MVP

### Milestone 1.1: Project Setup
**Time estimate: 1-2 hours**

- [ ] Create Rails app (SQLite is default)
- [ ] Install and configure Bulma CSS
- [ ] Set up Stimulus
- [ ] Configure RSpec + Capybara
- [ ] Set up basic layout with navigation

```bash
rails new grubmatch --css=bulma
cd grubmatch
```

**Acceptance criteria:**
- App boots with styled welcome page
- Stimulus controller works (e.g., hello controller)

---

### Milestone 1.2: Models & Database
**Time estimate: 2-3 hours**

- [ ] Generate models with migrations
- [ ] Add validations and associations
- [ ] Create seed file with 15-20 restaurants
- [ ] Add model specs

**Models:**

```ruby
# app/models/session.rb
class Session < ApplicationRecord
  has_many :participants, dependent: :destroy
  has_many :votes, through: :participants

  enum :status, { lobby: 0, active: 1, closed: 2 }

  validates :code, presence: true, uniqueness: true, length: { is: 4 }

  before_validation :generate_code, on: :create
  before_create :set_expiration

  scope :active, -> { where("expires_at > ?", Time.current) }

  def expired?
    expires_at < Time.current
  end

  def everyone_finished?
    participants.any? && participants.all?(&:completed?)
  end

  private

  def generate_code
    chars = ('A'..'Z').to_a - ['I', 'O', 'L'] # Avoid ambiguous letters
    loop do
      self.code = Array.new(4) { chars.sample }.join
      break unless Session.exists?(code: code)
    end
  end

  def set_expiration
    self.expires_at = 24.hours.from_now
  end
end
```

```ruby
# app/models/participant.rb
class Participant < ApplicationRecord
  belongs_to :session
  has_many :votes, dependent: :destroy

  validates :name, presence: true, length: { maximum: 20 }
  validates :token, presence: true, uniqueness: true

  before_validation :generate_token, on: :create

  scope :completed, -> { where.not(completed_at: nil) }
  scope :pending, -> { where(completed_at: nil) }

  def completed?
    completed_at.present?
  end

  def mark_complete!
    update!(completed_at: Time.current)
  end

  def vote_for(restaurant)
    votes.find_by(restaurant_id: restaurant.id)
  end

  def voted_on?(restaurant)
    votes.exists?(restaurant_id: restaurant.id)
  end

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64(32)
  end
end
```

```ruby
# app/models/vote.rb
class Vote < ApplicationRecord
  belongs_to :participant
  belongs_to :restaurant

  validates :restaurant_id, uniqueness: { scope: :participant_id }

  scope :liked, -> { where(liked: true) }
  scope :disliked, -> { where(liked: false) }
end
```

```ruby
# app/models/restaurant.rb
class Restaurant < ApplicationRecord
  has_many :votes, dependent: :destroy

  validates :name, presence: true
  validates :cuisine, presence: true

  def self.for_session
    # Phase 1: return all
    # Phase 2: filter by location
    all.order(:id)
  end

  def price_display
    "$" * (price_level || 2)
  end

  def rating_stars
    "★" * rating.floor + (rating % 1 >= 0.5 ? "½" : "")
  end
end
```

**Acceptance criteria:**
- All models have validations and pass specs
- `rails db:seed` creates test restaurants
- Associations work correctly

---

### Milestone 1.3: Session Management
**Time estimate: 3-4 hours**

- [ ] Sessions controller (create, show)
- [ ] Participants controller (create/join)
- [ ] Cookie-based authentication via participant token
- [ ] Home page with create/join buttons
- [ ] Join page with code input
- [ ] Lobby page showing participants

**Routes:**

```ruby
# config/routes.rb
Rails.application.routes.draw do
  root "home#index"

  # Session management
  resources :sessions, only: [:create, :show], param: :code do
    member do
      get :swipe
      get :results
    end
  end

  # Joining a session
  get "join", to: "participants#new"
  get "join/:code", to: "participants#new", as: :join_with_code
  post "join", to: "participants#create"

  # Voting (from swipe interface)
  resources :votes, only: [:create]
end
```

**Controllers:**

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  helper_method :current_participant, :current_session

  private

  def current_participant
    return @current_participant if defined?(@current_participant)
    token = cookies.signed[:participant_token]
    @current_participant = Participant.find_by(token: token) if token
  end

  def current_session
    current_participant&.session
  end

  def require_participant!
    redirect_to root_path, alert: "Please join a session first" unless current_participant
  end

  def require_session_participant!(session)
    unless current_participant&.session == session
      redirect_to root_path, alert: "You're not in this session"
    end
  end
end
```

```ruby
# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  def create
    session = Session.create!
    participant = session.participants.create!(name: params[:name].presence || "Host")

    cookies.signed[:participant_token] = {
      value: participant.token,
      expires: 24.hours.from_now,
      httponly: true
    }

    redirect_to session_path(session.code)
  end

  def show
    @session = Session.find_by!(code: params[:code].upcase)

    if @session.expired?
      redirect_to root_path, alert: "This session has expired"
      return
    end

    require_session_participant!(@session)
    @participants = @session.participants.order(:created_at)
  end

  def swipe
    @session = Session.find_by!(code: params[:code].upcase)
    require_session_participant!(@session)

    @restaurants = Restaurant.for_session
    @current_restaurant = next_restaurant_for(current_participant)
    @progress = {
      current: current_participant.votes.count + 1,
      total: @restaurants.count
    }
  end

  def results
    @session = Session.find_by!(code: params[:code].upcase)
    require_session_participant!(@session)

    @results = calculate_results(@session)
    @pending_participants = @session.participants.pending
  end

  private

  def next_restaurant_for(participant)
    voted_ids = participant.votes.pluck(:restaurant_id)
    Restaurant.for_session.where.not(id: voted_ids).first
  end

  def calculate_results(session)
    Restaurant.for_session.map do |restaurant|
      votes = Vote.joins(:participant)
                  .where(participants: { session_id: session.id })
                  .where(restaurant_id: restaurant.id)

      {
        restaurant: restaurant,
        yes_votes: votes.liked.count,
        total_votes: votes.count,
        voters: votes.includes(:participant).map do |v|
          { participant: v.participant, liked: v.liked }
        end
      }
    end.sort_by { |r| [-r[:yes_votes], -r[:total_votes]] }
  end
end
```

```ruby
# app/controllers/participants_controller.rb
class ParticipantsController < ApplicationController
  def new
    @code = params[:code]&.upcase
  end

  def create
    code = params[:code].to_s.upcase.strip
    name = params[:name].to_s.strip.presence || "Guest"

    session = Session.find_by(code: code)

    if session.nil?
      flash.now[:alert] = "Session not found. Check the code!"
      @code = code
      render :new, status: :unprocessable_entity
      return
    end

    if session.expired?
      redirect_to root_path, alert: "This session has expired"
      return
    end

    # Create unique name if duplicate
    existing_names = session.participants.pluck(:name)
    unique_name = name
    counter = 2
    while existing_names.include?(unique_name)
      unique_name = "#{name} #{counter}"
      counter += 1
    end

    participant = session.participants.create!(name: unique_name)

    cookies.signed[:participant_token] = {
      value: participant.token,
      expires: 24.hours.from_now,
      httponly: true
    }

    redirect_to session_path(session.code)
  end
end
```

**Acceptance criteria:**
- Can create a new session and see lobby
- Can join existing session with code
- Participant persists via cookie
- Lobby shows all participants in session

---

### Milestone 1.4: Swipe Interface
**Time estimate: 4-5 hours**

- [ ] Swipe page with card stack
- [ ] Restaurant card partial
- [ ] Stimulus controller for drag gestures
- [ ] Swipe buttons (like/nope)
- [ ] Vote creation endpoint
- [ ] Progress indicator
- [ ] Completion state

**Views:**

```erb
<!-- app/views/sessions/swipe.html.erb -->
<%= turbo_frame_tag "swipe_interface" do %>
  <section class="swipe-screen">
    <nav class="navbar is-primary">
      <div class="navbar-brand">
        <span class="navbar-item">
          <i class="fas fa-utensils mr-2"></i> GrubMatch
        </span>
      </div>
      <div class="navbar-end">
        <div class="navbar-item">
          <span class="tag is-warning is-medium">
            <%= @progress[:current] %> / <%= @progress[:total] %>
          </span>
        </div>
        <div class="navbar-item">
          <%= link_to results_session_path(@session.code), class: "button is-small is-light" do %>
            <span class="icon"><i class="fas fa-chart-bar"></i></span>
            <span>Results</span>
          <% end %>
        </div>
      </div>
    </nav>

    <div class="swipe-container">
      <% if @current_restaurant %>
        <div class="card-stack"
             data-controller="swipe"
             data-swipe-session-code-value="<%= @session.code %>">
          <%= render "restaurants/card", restaurant: @current_restaurant %>
        </div>

        <div class="swipe-actions">
          <button class="button is-large is-danger is-rounded swipe-btn"
                  data-action="swipe#left">
            <span class="icon is-medium"><i class="fas fa-times fa-lg"></i></span>
          </button>
          <button class="button is-large is-success is-rounded swipe-btn"
                  data-action="swipe#right">
            <span class="icon is-medium"><i class="fas fa-heart fa-lg"></i></span>
          </button>
        </div>
      <% else %>
        <div class="has-text-centered">
          <div class="box">
            <span class="icon is-large has-text-success">
              <i class="fas fa-check-circle fa-3x"></i>
            </span>
            <h3 class="title is-4 mt-4">All Done!</h3>
            <p class="subtitle is-6">You've swiped through all restaurants.</p>
            <%= link_to results_session_path(@session.code),
                        class: "button is-primary is-medium mt-4" do %>
              <span class="icon"><i class="fas fa-trophy"></i></span>
              <span>See Group Results</span>
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
  </section>
<% end %>
```

```erb
<!-- app/views/restaurants/_card.html.erb -->
<div class="restaurant-card"
     data-swipe-target="card"
     data-restaurant-id="<%= restaurant.id %>">
  <div class="swipe-indicator nope" data-swipe-target="nopeIndicator">NOPE</div>
  <div class="swipe-indicator like" data-swipe-target="likeIndicator">LIKE</div>

  <div class="card-image-container">
    <%= image_tag restaurant.image_url, alt: restaurant.name, loading: "lazy" %>
    <div class="card-overlay">
      <span class="cuisine-tag"><%= restaurant.cuisine %></span>
    </div>
  </div>

  <div class="card-body">
    <h3 class="title is-4"><%= restaurant.name %></h3>
    <div class="card-meta">
      <span class="stars">
        <%= restaurant.rating_stars %>
        <span class="has-text-grey-light"><%= restaurant.rating %></span>
      </span>
      <span><i class="fas fa-dollar-sign"></i> <%= restaurant.price_display %></span>
      <span><i class="fas fa-walking"></i> <%= restaurant.distance %></span>
    </div>
    <p class="card-description"><%= restaurant.description %></p>
  </div>
</div>
```

**Stimulus Controller:**

```javascript
// app/javascript/controllers/swipe_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "nopeIndicator", "likeIndicator"]
  static values = { sessionCode: String }

  connect() {
    this.startX = 0
    this.startY = 0
    this.currentX = 0
    this.isDragging = false
    this.threshold = 100

    this.bindEvents()
  }

  bindEvents() {
    const card = this.cardTarget

    // Mouse events
    card.addEventListener("mousedown", this.onStart.bind(this))
    document.addEventListener("mousemove", this.onMove.bind(this))
    document.addEventListener("mouseup", this.onEnd.bind(this))

    // Touch events
    card.addEventListener("touchstart", this.onStart.bind(this), { passive: true })
    document.addEventListener("touchmove", this.onMove.bind(this), { passive: false })
    document.addEventListener("touchend", this.onEnd.bind(this))
  }

  onStart(e) {
    this.isDragging = true
    this.cardTarget.classList.add("swiping")
    const point = e.touches ? e.touches[0] : e
    this.startX = point.clientX
    this.startY = point.clientY
  }

  onMove(e) {
    if (!this.isDragging) return
    e.preventDefault()

    const point = e.touches ? e.touches[0] : e
    this.currentX = point.clientX - this.startX
    const currentY = point.clientY - this.startY
    const rotate = this.currentX * 0.1

    this.cardTarget.style.transform =
      `translate(${this.currentX}px, ${currentY}px) rotate(${rotate}deg)`

    // Update indicators
    if (this.currentX < -50) {
      this.nopeIndicatorTarget.style.opacity = Math.min(1, Math.abs(this.currentX) / 100)
      this.likeIndicatorTarget.style.opacity = 0
    } else if (this.currentX > 50) {
      this.likeIndicatorTarget.style.opacity = Math.min(1, this.currentX / 100)
      this.nopeIndicatorTarget.style.opacity = 0
    } else {
      this.nopeIndicatorTarget.style.opacity = 0
      this.likeIndicatorTarget.style.opacity = 0
    }
  }

  onEnd() {
    if (!this.isDragging) return
    this.isDragging = false
    this.cardTarget.classList.remove("swiping")

    if (this.currentX < -this.threshold) {
      this.submitSwipe(false)
    } else if (this.currentX > this.threshold) {
      this.submitSwipe(true)
    } else {
      this.resetCard()
    }
  }

  left() {
    this.animateSwipe("left")
    this.submitSwipe(false)
  }

  right() {
    this.animateSwipe("right")
    this.submitSwipe(true)
  }

  animateSwipe(direction) {
    this.cardTarget.classList.add(`swipe-${direction}`)
  }

  resetCard() {
    this.cardTarget.style.transform = ""
    this.nopeIndicatorTarget.style.opacity = 0
    this.likeIndicatorTarget.style.opacity = 0
  }

  async submitSwipe(liked) {
    const restaurantId = this.cardTarget.dataset.restaurantId
    const csrfToken = document.querySelector("[name='csrf-token']").content

    try {
      const response = await fetch("/votes", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
          "Accept": "text/vnd.turbo-stream.html"
        },
        body: JSON.stringify({
          restaurant_id: restaurantId,
          liked: liked
        })
      })

      if (response.ok) {
        // Turbo Stream will handle the UI update
        const html = await response.text()
        Turbo.renderStreamMessage(html)
      }
    } catch (error) {
      console.error("Vote failed:", error)
      this.resetCard()
    }
  }
}
```

**Votes Controller:**

```ruby
# app/controllers/votes_controller.rb
class VotesController < ApplicationController
  before_action :require_participant!

  def create
    restaurant = Restaurant.find(params[:restaurant_id])

    vote = current_participant.votes.create!(
      restaurant: restaurant,
      liked: params[:liked]
    )

    # Check if participant is done
    total_restaurants = Restaurant.for_session.count
    if current_participant.votes.count >= total_restaurants
      current_participant.mark_complete!
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "swipe_interface",
          partial: "sessions/swipe_interface",
          locals: {
            session: current_session,
            current_restaurant: next_restaurant,
            progress: progress_data
          }
        )
      end
    end
  end

  private

  def next_restaurant
    voted_ids = current_participant.votes.pluck(:restaurant_id)
    Restaurant.for_session.where.not(id: voted_ids).first
  end

  def progress_data
    {
      current: current_participant.votes.count + 1,
      total: Restaurant.for_session.count
    }
  end
end
```

**Acceptance criteria:**
- Cards display restaurant info
- Can swipe left/right via drag or buttons
- Vote is recorded and next card appears
- Progress updates correctly
- Shows completion message when done

---

### Milestone 1.5: Results Page
**Time estimate: 2-3 hours**

- [ ] Results page with ranked list
- [ ] Show vote counts and who voted
- [ ] Indicate pending participants
- [ ] Winner highlight
- [ ] "New session" button

```erb
<!-- app/views/sessions/results.html.erb -->
<section class="results-screen">
  <nav class="navbar is-primary">
    <div class="navbar-brand">
      <span class="navbar-item">
        <i class="fas fa-trophy mr-2"></i> Results
      </span>
    </div>
    <div class="navbar-end">
      <div class="navbar-item">
        <%= link_to swipe_session_path(@session.code), class: "button is-small is-light" do %>
          <span class="icon"><i class="fas fa-arrow-left"></i></span>
          <span>Back to Swiping</span>
        <% end %>
      </div>
    </div>
  </nav>

  <div class="section">
    <div class="container" style="max-width: 600px;">

      <% if @pending_participants.any? %>
        <div class="notification is-warning">
          <p>
            <i class="fas fa-hourglass-half mr-2"></i>
            Waiting for others to finish swiping...
          </p>
          <div class="mt-2">
            <% @pending_participants.each do |p| %>
              <span class="tag is-light mr-1"><%= p.name %></span>
            <% end %>
          </div>
        </div>
      <% end %>

      <div id="results-list">
        <% @results.each_with_index do |result, index| %>
          <% is_winner = index == 0 && result[:yes_votes] > 0 %>
          <div class="result-card <%= 'winner' if is_winner %>">
            <% if is_winner %>
              <div class="winner-badge">
                <i class="fas fa-crown"></i>
              </div>
            <% end %>

            <div class="result-rank"><%= index + 1 %></div>

            <%= image_tag result[:restaurant].image_url,
                          class: "result-image",
                          alt: result[:restaurant].name %>

            <div class="result-info">
              <h4><%= result[:restaurant].name %></h4>
              <p class="cuisine">
                <%= result[:restaurant].cuisine %> ·
                <%= result[:restaurant].price_display %> ·
                <%= result[:restaurant].distance %>
              </p>
              <div class="vote-avatars">
                <% result[:voters].select { |v| v[:liked] }.each do |vote| %>
                  <div class="vote-avatar" title="<%= vote[:participant].name %>">
                    <%= vote[:participant].name.first.upcase %>
                  </div>
                <% end %>
              </div>
            </div>

            <div class="result-votes">
              <div class="count"><%= result[:yes_votes] %></div>
              <div class="label">likes</div>
            </div>
          </div>
        <% end %>
      </div>

      <div class="has-text-centered mt-6">
        <%= link_to root_path, class: "button is-primary is-medium" do %>
          <span class="icon"><i class="fas fa-redo"></i></span>
          <span>Start New Session</span>
        <% end %>
      </div>

    </div>
  </div>
</section>
```

**Acceptance criteria:**
- Results ranked by yes votes
- Winner has crown/highlight
- Shows who voted for each restaurant
- Shows pending participants
- Can start new session

---

### Milestone 1.6: Real-time Updates (Optional for MVP)
**Time estimate: 3-4 hours**

- [ ] ActionCable setup
- [ ] Session channel for participant updates
- [ ] Turbo Streams for live lobby updates
- [ ] Live results updates

```ruby
# app/channels/session_channel.rb
class SessionChannel < ApplicationCable::Channel
  def subscribed
    session = Session.find_by(code: params[:code])
    stream_for session if session
  end
end
```

```ruby
# Broadcast when participant joins (in ParticipantsController#create)
SessionChannel.broadcast_to(
  session,
  turbo_stream.append("participants-list", partial: "participants/participant", locals: { participant: participant })
)
```

---

### Milestone 1.7: Polish & Edge Cases
**Time estimate: 2-3 hours**

- [ ] Session not found page
- [ ] Session expired handling
- [ ] Participant already in different session
- [ ] Mobile responsive testing
- [ ] Loading states
- [ ] Error handling
- [ ] Flash messages styled
- [ ] Cleanup job for expired sessions

---

## Phase 2: Location & Real Restaurants

### Milestone 2.1: Location Support
**Time estimate: 2-3 hours**

- [ ] Browser geolocation prompt
- [ ] Store coordinates in session
- [ ] Fallback for denied permissions

### Milestone 2.2: Google Places Integration
**Time estimate: 4-5 hours**

- [ ] Google Places API service class
- [ ] Nearby search by coordinates
- [ ] Place details fetching
- [ ] Photo URL generation
- [ ] Caching strategy (Redis)
- [ ] Rate limiting

```ruby
# app/services/google_places_service.rb
class GooglePlacesService
  include HTTParty
  base_uri "https://maps.googleapis.com/maps/api/place"

  def initialize
    @api_key = Rails.application.credentials.google_places_api_key
  end

  def nearby_restaurants(lat:, lng:, radius: 1500)
    response = self.class.get("/nearbysearch/json", query: {
      location: "#{lat},#{lng}",
      radius: radius,
      type: "restaurant",
      key: @api_key
    })

    return [] unless response.success?

    response.parsed_response["results"].map do |place|
      build_restaurant(place)
    end
  end

  private

  def build_restaurant(place)
    Restaurant.new(
      external_id: place["place_id"],
      name: place["name"],
      rating: place["rating"] || 0,
      price_level: place["price_level"] || 2,
      address: place["vicinity"],
      latitude: place.dig("geometry", "location", "lat"),
      longitude: place.dig("geometry", "location", "lng"),
      image_url: photo_url(place["photos"]&.first),
      cuisine: extract_cuisine(place["types"])
    )
  end

  def photo_url(photo)
    return default_image unless photo

    "https://maps.googleapis.com/maps/api/place/photo?" +
      "maxwidth=400&photo_reference=#{photo['photo_reference']}&key=#{@api_key}"
  end

  def extract_cuisine(types)
    type_map = {
      "chinese_restaurant" => "Chinese",
      "italian_restaurant" => "Italian",
      "japanese_restaurant" => "Japanese",
      "mexican_restaurant" => "Mexican",
      "indian_restaurant" => "Indian",
      "thai_restaurant" => "Thai",
      "vietnamese_restaurant" => "Vietnamese",
      "korean_restaurant" => "Korean",
      "american_restaurant" => "American",
      "french_restaurant" => "French",
    }

    types&.find { |t| type_map[t] }.then { |t| type_map[t] } || "Restaurant"
  end

  def default_image
    "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400&h=300&fit=crop"
  end
end
```

### Milestone 2.3: Session Location Flow
**Time estimate: 2-3 hours**

- [ ] Location prompt on session create
- [ ] Store lat/lng in session
- [ ] Fetch restaurants based on location
- [ ] Cache restaurants for session duration

---

## Phase 3: Enhancements

### Potential Features
- [ ] User accounts (optional)
- [ ] Session history
- [ ] Cuisine/price filters
- [ ] "Super like" feature
- [ ] Share results via link
- [ ] Restaurant details modal
- [ ] Map view of results
- [ ] "Decide for me" random picker
- [ ] Rematch with same group

---

## File Structure

```
app/
├── channels/
│   └── session_channel.rb
├── controllers/
│   ├── application_controller.rb
│   ├── home_controller.rb
│   ├── sessions_controller.rb
│   ├── participants_controller.rb
│   └── votes_controller.rb
├── javascript/
│   └── controllers/
│       ├── swipe_controller.js
│       ├── clipboard_controller.js
│       └── poll_controller.js
├── models/
│   ├── session.rb
│   ├── participant.rb
│   ├── vote.rb
│   └── restaurant.rb
├── services/
│   └── google_places_service.rb      # Phase 2
├── views/
│   ├── layouts/
│   │   └── application.html.erb
│   ├── home/
│   │   └── index.html.erb
│   ├── sessions/
│   │   ├── show.html.erb             # Lobby
│   │   ├── swipe.html.erb
│   │   ├── results.html.erb
│   │   └── _swipe_interface.html.erb
│   ├── participants/
│   │   ├── new.html.erb              # Join page
│   │   └── _participant.html.erb
│   └── restaurants/
│       └── _card.html.erb
└── assets/
    └── stylesheets/
        └── application.scss          # Custom styles + Bulma
```

---

## Timeline Estimate

| Phase | Milestone | Estimate |
|-------|-----------|----------|
| 1.1 | Project Setup | 1-2 hours |
| 1.2 | Models & Database | 2-3 hours |
| 1.3 | Session Management | 3-4 hours |
| 1.4 | Swipe Interface | 4-5 hours |
| 1.5 | Results Page | 2-3 hours |
| 1.6 | Real-time (optional) | 3-4 hours |
| 1.7 | Polish | 2-3 hours |
| **Phase 1 Total** | | **17-24 hours** |
| 2.1 | Location Support | 2-3 hours |
| 2.2 | Google Places | 4-5 hours |
| 2.3 | Location Flow | 2-3 hours |
| **Phase 2 Total** | | **8-11 hours** |

---

## Getting Started

```bash
# Create the app (SQLite is the default)
rails new grubmatch --css=bulma

# Setup
cd grubmatch

# Generate models
bin/rails g model Session code:string status:integer expires_at:datetime
bin/rails g model Participant session:references name:string token:string completed_at:datetime
bin/rails g model Vote participant:references restaurant:references liked:boolean
bin/rails g model Restaurant name:string cuisine:string rating:decimal price_level:integer distance:string description:text image_url:string

# Run migrations
bin/rails db:migrate

# Seed restaurants
bin/rails db:seed

# Start server
bin/dev
```

### SQLite Notes

SQLite works great for development and small-to-medium production deployments. A few considerations:

- **Concurrent writes**: SQLite handles one write at a time. For most GrubMatch usage (small groups swiping), this is fine.
- **Production**: SQLite is production-ready for apps with moderate traffic. Rails 8 defaults to SQLite for new apps.
- **If scaling needed later**: Migration to PostgreSQL is straightforward - just update `database.yml` and run migrations.
