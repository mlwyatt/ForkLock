# frozen_string_literal: true

# Seed restaurants for ForkLock
# Run with: bin/rails db:seed

restaurants = [
  {
    name: 'Sakura Garden',
    cuisine: 'Japanese',
    rating: 4.5,
    price_level: 3,
    distance: '0.3 mi',
    description: 'Authentic Japanese cuisine with fresh sushi and ramen in a serene setting.',
    image_url: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=400&h=300&fit=crop'
  },
  {
    name: 'Taco Fiesta',
    cuisine: 'Mexican',
    rating: 4.2,
    price_level: 1,
    distance: '0.5 mi',
    description: 'Street-style tacos and burritos made with family recipes.',
    image_url: 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=400&h=300&fit=crop'
  },
  {
    name: 'Bella Italia',
    cuisine: 'Italian',
    rating: 4.7,
    price_level: 3,
    distance: '0.8 mi',
    description: 'Classic Italian pasta and wood-fired pizzas in a cozy trattoria.',
    image_url: 'https://images.unsplash.com/photo-1498579150354-977475b7ea0b?w=400&h=300&fit=crop'
  },
  {
    name: 'Golden Dragon',
    cuisine: 'Chinese',
    rating: 4.0,
    price_level: 2,
    distance: '0.4 mi',
    description: 'Traditional Cantonese dim sum and Szechuan specialties.',
    image_url: 'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=400&h=300&fit=crop'
  },
  {
    name: 'The Burger Joint',
    cuisine: 'American',
    rating: 4.3,
    price_level: 2,
    distance: '0.2 mi',
    description: 'Juicy smash burgers with house-made sauces and crispy fries.',
    image_url: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=300&fit=crop'
  },
  {
    name: 'Spice Route',
    cuisine: 'Indian',
    rating: 4.6,
    price_level: 2,
    distance: '1.0 mi',
    description: 'Flavorful curries and tandoori dishes with vegetarian options.',
    image_url: 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400&h=300&fit=crop'
  },
  {
    name: 'Saigon Noodles',
    cuisine: 'Vietnamese',
    rating: 4.4,
    price_level: 1,
    distance: '0.6 mi',
    description: 'Steaming bowls of pho and fresh banh mi sandwiches.',
    image_url: 'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=400&h=300&fit=crop'
  },
  {
    name: 'Seoul Kitchen',
    cuisine: 'Korean',
    rating: 4.5,
    price_level: 2,
    distance: '0.9 mi',
    description: 'Sizzling Korean BBQ and authentic bibimbap bowls.',
    image_url: 'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=400&h=300&fit=crop'
  },
  {
    name: 'Le Petit Bistro',
    cuisine: 'French',
    rating: 4.8,
    price_level: 4,
    distance: '1.2 mi',
    description: 'Elegant French dining with seasonal tasting menus.',
    image_url: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400&h=300&fit=crop'
  },
  {
    name: 'Bangkok Street',
    cuisine: 'Thai',
    rating: 4.3,
    price_level: 2,
    distance: '0.7 mi',
    description: 'Authentic pad thai and green curry with bold flavors.',
    image_url: 'https://images.unsplash.com/photo-1559314809-0d155014e29e?w=400&h=300&fit=crop'
  },
  {
    name: 'Mediterranean Grill',
    cuisine: 'Mediterranean',
    rating: 4.4,
    price_level: 2,
    distance: '0.5 mi',
    description: 'Fresh hummus, falafel, and grilled kebabs.',
    image_url: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=400&h=300&fit=crop'
  },
  {
    name: 'Sushi Master',
    cuisine: 'Japanese',
    rating: 4.9,
    price_level: 4,
    distance: '1.5 mi',
    description: 'Omakase experience with premium fish flown in daily.',
    image_url: 'https://images.unsplash.com/photo-1553621042-f6e147245754?w=400&h=300&fit=crop'
  },
  {
    name: 'Pizza Palace',
    cuisine: 'Italian',
    rating: 4.1,
    price_level: 1,
    distance: '0.3 mi',
    description: 'New York-style slices and classic Italian-American favorites.',
    image_url: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&h=300&fit=crop'
  },
  {
    name: 'Farm to Table',
    cuisine: 'American',
    rating: 4.6,
    price_level: 3,
    distance: '1.1 mi',
    description: 'Seasonal American cuisine sourced from local farms.',
    image_url: 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=400&h=300&fit=crop'
  },
  {
    name: 'Curry House',
    cuisine: 'Indian',
    rating: 4.2,
    price_level: 2,
    distance: '0.8 mi',
    description: 'Rich curries and fresh naan from our tandoor oven.',
    image_url: 'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=400&h=300&fit=crop'
  },
  {
    name: 'Wing Stop',
    cuisine: 'American',
    rating: 3.9,
    price_level: 1,
    distance: '0.4 mi',
    description: 'Crispy wings in 12 signature flavors with ranch and blue cheese.',
    image_url: 'https://images.unsplash.com/photo-1527477396000-e27163b481c2?w=400&h=300&fit=crop'
  },
  {
    name: 'Poke Paradise',
    cuisine: 'Hawaiian',
    rating: 4.3,
    price_level: 2,
    distance: '0.6 mi',
    description: 'Build-your-own poke bowls with fresh fish and tropical toppings.',
    image_url: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&h=300&fit=crop'
  },
  {
    name: 'El Patron',
    cuisine: 'Mexican',
    rating: 4.5,
    price_level: 2,
    distance: '0.9 mi',
    description: 'Upscale Mexican with house margaritas and carne asada.',
    image_url: 'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?w=400&h=300&fit=crop'
  }
]

puts("Seeding #{restaurants.count} restaurants...")

restaurants.each do |attrs|
  Restaurant.find_or_create_by!(name: attrs[:name]) do |r|
    r.cuisine = attrs[:cuisine]
    r.rating = attrs[:rating]
    r.price_level = attrs[:price_level]
    r.distance = attrs[:distance]
    r.description = attrs[:description]
    r.image_url = attrs[:image_url]
  end
end

puts("Done! #{Restaurant.count} restaurants in database.")
