# ForkLock 🍕

A "Tinder for food" app where groups swipe on restaurants and find matches based on consensus.

## Demo

Open `index.html` in a browser to try the prototype. The app uses localStorage to simulate persistence, so you can:

1. Open in one tab → Create a session → Copy the code
2. Open in another tab → Join with the code
3. Both tabs can swipe independently (async)
4. Check results to see group consensus

## How It Works

1. **Create Session** - Generate a 4-letter code to share
2. **Join Session** - Friends enter the code to join
3. **Swipe** - Each person swipes through restaurants (drag or use buttons)
4. **Results** - See restaurants ranked by group votes

## Phase 1 Features (Current)

- ✅ Session creation with shareable codes
- ✅ Multiple participants per session
- ✅ Async swiping (everyone swipes at their own pace)
- ✅ Swipe gestures with animations
- ✅ Results ranked by consensus
- ✅ Predefined restaurant list

## Phase 2 Roadmap

- [ ] Google Places API integration
- [ ] Location-based restaurant discovery
- [ ] Real-time updates (ActionCable)
- [ ] User accounts
- [ ] Session history

---

## Rails Migration Guide

### 1. Create Rails App

```bash
rails new grubmatch --css=bulma --javascript=importmap
cd grubmatch
```

### 2. Add Stimulus

```bash
bin/importmap pin @hotwired/stimulus
```

### 3. Generate Models

```bash
rails g model Session code:string:index
rails g model Participant session:references name:string done:boolean
rails g model Vote participant:references restaurant_id:integer liked:boolean

rails db:migrate
```

**app/models/session.rb:**
```ruby
class Session < ApplicationRecord
  has_many :participants, dependent: :destroy
  has_many :votes, through: :participants

  before_create :generate_code

  private

  def generate_code
    chars = ('A'..'Z').to_a - ['I', 'O'] # Avoid confusing letters
    self.code = 4.times.map { chars.sample }.join
  end
end
```

**app/models/participant.rb:**
```ruby
class Participant < ApplicationRecord
  belongs_to :session
  has_many :votes, dependent: :destroy

  validates :name, presence: true
end
```

**app/models/vote.rb:**
```ruby
class Vote < ApplicationRecord
  belongs_to :participant

  validates :restaurant_id, presence: true
  validates :restaurant_id, uniqueness: { scope: :participant_id }
end
```

### 4. Routes

```ruby
# config/routes.rb
Rails.application.routes.draw do
  root "home#index"

  resources :sessions, only: [:create, :show], param: :code do
    resources :participants, only: [:create]
    member do
      get :results
    end
  end

  resources :votes, only: [:create]
end
```

### 5. Controllers

**app/controllers/sessions_controller.rb:**
```ruby
class SessionsController < ApplicationController
  def create
    @session = Session.create!
    participant = @session.participants.create!(name: "Host")
    session[:participant_id] = participant.id

    redirect_to session_path(@session.code)
  end

  def show
    @session = Session.find_by!(code: params[:code].upcase)
  end

  def results
    @session = Session.find_by!(code: params[:code].upcase)
    @rankings = calculate_rankings(@session)
  end

  private

  def calculate_rankings(session)
    Restaurant.all.map do |restaurant|
      votes = Vote.joins(:participant)
                  .where(participants: { session_id: session.id })
                  .where(restaurant_id: restaurant.id)

      {
        restaurant: restaurant,
        yes_votes: votes.where(liked: true).includes(:participant).map(&:participant),
        total_voters: votes.count
      }
    end.sort_by { |r| -r[:yes_votes].count }
  end
end
```

### 6. Stimulus Controllers

**app/javascript/controllers/swipe_controller.js:**
```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "stack"]
  static values = {
    restaurantId: Number,
    index: Number
  }

  connect() {
    this.initDrag()
  }

  swipeLeft() {
    this.submitVote(false)
  }

  swipeRight() {
    this.submitVote(true)
  }

  async submitVote(liked) {
    const card = this.cardTarget
    card.classList.add(liked ? 'swipe-right' : 'swipe-left')

    await fetch('/votes', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({
        restaurant_id: this.restaurantIdValue,
        liked: liked
      })
    })

    setTimeout(() => {
      Turbo.visit(window.location.href, { action: 'replace' })
    }, 300)
  }

  // ... drag implementation same as prototype
}
```

### 7. Restaurant Service (Phase 2)

**app/services/restaurant_service.rb:**
```ruby
class RestaurantService
  GOOGLE_API_KEY = ENV['GOOGLE_PLACES_API_KEY']

  def self.nearby(lat:, lng:, radius: 1500)
    # In Phase 1, return predefined list
    return Restaurant::PREDEFINED if GOOGLE_API_KEY.blank?

    # Phase 2: Google Places API
    response = HTTP.get(
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json",
      params: {
        location: "#{lat},#{lng}",
        radius: radius,
        type: "restaurant",
        key: GOOGLE_API_KEY
      }
    )

    JSON.parse(response.body)["results"].map do |place|
      Restaurant.new(
        id: place["place_id"],
        name: place["name"],
        rating: place["rating"],
        price_level: place["price_level"],
        # ... etc
      )
    end
  end
end
```

### 8. Views

Copy the HTML structure from `index.html` into ERB templates:

- `app/views/home/index.html.erb` - Landing page
- `app/views/sessions/show.html.erb` - Lobby + Swipe interface
- `app/views/sessions/results.html.erb` - Results page

### 9. Real-time Updates (Optional)

For live participant updates, add ActionCable:

```ruby
# app/channels/session_channel.rb
class SessionChannel < ApplicationCable::Channel
  def subscribed
    stream_from "session_#{params[:code]}"
  end
end
```

```javascript
// Broadcast when participant joins
SessionChannel.broadcast_to(
  @session,
  { type: 'participant_joined', name: participant.name }
)
```

---

## File Structure

```
grubmatch/
├── index.html      # Main HTML (port to ERB views)
├── styles.css      # Custom styles (add to app/assets)
├── app.js          # JS logic (port to Stimulus controllers)
└── README.md       # This file
```

## Tech Stack

- **Frontend:** Bulma CSS, Stimulus JS
- **Backend:** Rails 7.1+
- **Database:** SQLite (dev) / PostgreSQL (prod)
- **Real-time:** ActionCable (optional)

## License

MIT
