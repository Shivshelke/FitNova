/**
 * Database Seed Script
 * Run: npm run seed
 * Seeds the database with predefined workouts and food items
 */

require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });
const mongoose = require('mongoose');
const Workout = require('../models/Workout');
const FoodItem = require('../models/FoodItem');

// ── Predefined Workouts ───────────────────────────────────────────────────────
const predefinedWorkouts = [
  {
    name: 'HIIT Fat Burner',
    description: 'High-intensity interval training to maximize fat burning',
    type: 'home',
    difficulty: 'intermediate',
    targetGoal: 'weight_loss',
    estimatedDuration: 30,
    estimatedCalories: 400,
    category: 'Cardio',
    isPredefined: true,
    exercises: [
      { name: 'Jumping Jacks', muscleGroup: 'cardio', defaultSets: 3, defaultReps: 30, duration: 30 },
      { name: 'Burpees', muscleGroup: 'full_body', defaultSets: 3, defaultReps: 15 },
      { name: 'High Knees', muscleGroup: 'cardio', defaultSets: 3, defaultReps: 40, duration: 30 },
      { name: 'Mountain Climbers', muscleGroup: 'core', defaultSets: 3, defaultReps: 20, duration: 30 },
      { name: 'Jump Squats', muscleGroup: 'legs', defaultSets: 3, defaultReps: 15 },
    ],
  },
  {
    name: 'Upper Body Strength',
    description: 'Build chest, shoulders, and arms with classic lifts',
    type: 'gym',
    difficulty: 'intermediate',
    targetGoal: 'muscle_building',
    estimatedDuration: 55,
    estimatedCalories: 320,
    category: 'Strength',
    isPredefined: true,
    exercises: [
      { name: 'Bench Press', muscleGroup: 'chest', defaultSets: 4, defaultReps: 8, defaultWeight: 60 },
      { name: 'Incline Dumbbell Press', muscleGroup: 'chest', defaultSets: 3, defaultReps: 10, defaultWeight: 22 },
      { name: 'Overhead Press', muscleGroup: 'shoulders', defaultSets: 4, defaultReps: 8, defaultWeight: 40 },
      { name: 'Lateral Raises', muscleGroup: 'shoulders', defaultSets: 3, defaultReps: 12, defaultWeight: 10 },
      { name: 'Tricep Dips', muscleGroup: 'arms', defaultSets: 3, defaultReps: 12 },
      { name: 'Barbell Curl', muscleGroup: 'arms', defaultSets: 3, defaultReps: 10, defaultWeight: 25 },
    ],
  },
  {
    name: 'Leg Day Power',
    description: 'Squat, press and lunge for maximum leg development',
    type: 'gym',
    difficulty: 'advanced',
    targetGoal: 'weight_gain',
    estimatedDuration: 60,
    estimatedCalories: 450,
    category: 'Strength',
    isPredefined: true,
    exercises: [
      { name: 'Barbell Squat', muscleGroup: 'legs', defaultSets: 5, defaultReps: 5, defaultWeight: 80 },
      { name: 'Romanian Deadlift', muscleGroup: 'legs', defaultSets: 4, defaultReps: 8, defaultWeight: 70 },
      { name: 'Leg Press', muscleGroup: 'legs', defaultSets: 4, defaultReps: 10, defaultWeight: 120 },
      { name: 'Leg Curl', muscleGroup: 'legs', defaultSets: 3, defaultReps: 12, defaultWeight: 40 },
      { name: 'Calf Raises', muscleGroup: 'legs', defaultSets: 4, defaultReps: 20, defaultWeight: 50 },
      { name: 'Walking Lunges', muscleGroup: 'legs', defaultSets: 3, defaultReps: 16 },
    ],
  },
  {
    name: 'Back & Bicep Blast',
    description: 'Pull movements for a wide, strong back and peaked biceps',
    type: 'gym',
    difficulty: 'intermediate',
    targetGoal: 'muscle_building',
    estimatedDuration: 50,
    estimatedCalories: 300,
    category: 'Strength',
    isPredefined: true,
    exercises: [
      { name: 'Pull-Ups', muscleGroup: 'back', defaultSets: 4, defaultReps: 8 },
      { name: 'Bent Over Row', muscleGroup: 'back', defaultSets: 4, defaultReps: 8, defaultWeight: 60 },
      { name: 'Lat Pulldown', muscleGroup: 'back', defaultSets: 3, defaultReps: 10, defaultWeight: 55 },
      { name: 'Seated Cable Row', muscleGroup: 'back', defaultSets: 3, defaultReps: 12, defaultWeight: 50 },
      { name: 'Hammer Curl', muscleGroup: 'arms', defaultSets: 3, defaultReps: 12, defaultWeight: 14 },
      { name: 'Preacher Curl', muscleGroup: 'arms', defaultSets: 3, defaultReps: 10, defaultWeight: 20 },
    ],
  },
  {
    name: 'Core & Abs Destroyer',
    description: 'Six-pack abs and strong core with targeted exercises',
    type: 'home',
    difficulty: 'beginner',
    targetGoal: 'all',
    estimatedDuration: 25,
    estimatedCalories: 180,
    category: 'Core',
    isPredefined: true,
    exercises: [
      { name: 'Plank', muscleGroup: 'core', defaultSets: 3, defaultReps: 1, duration: 60 },
      { name: 'Crunches', muscleGroup: 'core', defaultSets: 3, defaultReps: 20 },
      { name: 'Bicycle Crunches', muscleGroup: 'core', defaultSets: 3, defaultReps: 30 },
      { name: 'Leg Raises', muscleGroup: 'core', defaultSets: 3, defaultReps: 15 },
      { name: 'Russian Twists', muscleGroup: 'core', defaultSets: 3, defaultReps: 20 },
      { name: 'Dead Bug', muscleGroup: 'core', defaultSets: 3, defaultReps: 10 },
    ],
  },
  {
    name: 'Yoga & Flexibility',
    description: 'Improve flexibility, posture and mental clarity',
    type: 'home',
    difficulty: 'beginner',
    targetGoal: 'maintenance',
    estimatedDuration: 30,
    estimatedCalories: 120,
    category: 'Flexibility',
    isPredefined: true,
    exercises: [
      { name: 'Child\'s Pose', muscleGroup: 'full_body', defaultSets: 1, defaultReps: 1, duration: 60 },
      { name: 'Downward Dog', muscleGroup: 'full_body', defaultSets: 1, defaultReps: 1, duration: 45 },
      { name: 'Warrior I', muscleGroup: 'legs', defaultSets: 2, defaultReps: 1, duration: 30 },
      { name: 'Warrior II', muscleGroup: 'legs', defaultSets: 2, defaultReps: 1, duration: 30 },
      { name: 'Pigeon Pose', muscleGroup: 'legs', defaultSets: 2, defaultReps: 1, duration: 45 },
      { name: 'Cat-Cow Stretch', muscleGroup: 'back', defaultSets: 3, defaultReps: 10 },
    ],
  },
  {
    name: 'Beginner Full Body',
    description: 'Perfect for beginners — target all muscle groups with basic movements',
    type: 'home',
    difficulty: 'beginner',
    targetGoal: 'all',
    estimatedDuration: 35,
    estimatedCalories: 220,
    category: 'Full Body',
    isPredefined: true,
    exercises: [
      { name: 'Bodyweight Squat', muscleGroup: 'legs', defaultSets: 3, defaultReps: 15 },
      { name: 'Push-Ups', muscleGroup: 'chest', defaultSets: 3, defaultReps: 10 },
      { name: 'Glute Bridge', muscleGroup: 'legs', defaultSets: 3, defaultReps: 15 },
      { name: 'Plank Hold', muscleGroup: 'core', defaultSets: 3, defaultReps: 1, duration: 30 },
      { name: 'Superman Hold', muscleGroup: 'back', defaultSets: 3, defaultReps: 12 },
      { name: 'Tricep Dips (Chair)', muscleGroup: 'arms', defaultSets: 3, defaultReps: 10 },
    ],
  },
];

// ── Food Items Seed Data ──────────────────────────────────────────────────────
const foodItems = [
  // Dairy
  { name: 'Whole Milk', category: 'dairy', calories: 61, protein: 3.2, carbs: 4.8, fat: 3.3, servingSize: 100, servingUnit: 'ml' },
  { name: 'Greek Yogurt', category: 'dairy', calories: 59, protein: 10, carbs: 3.6, fat: 0.4, servingSize: 100, servingUnit: 'g' },
  { name: 'Cheddar Cheese', category: 'dairy', calories: 403, protein: 25, carbs: 1.3, fat: 33, servingSize: 100, servingUnit: 'g' },
  { name: 'Paneer (Cottage Cheese)', category: 'dairy', calories: 265, protein: 18, carbs: 1.2, fat: 20, servingSize: 100, servingUnit: 'g' },
  // Meat
  { name: 'Chicken Breast', category: 'meat', calories: 165, protein: 31, carbs: 0, fat: 3.6, servingSize: 100, servingUnit: 'g' },
  { name: 'Eggs', category: 'meat', calories: 155, protein: 13, carbs: 1.1, fat: 11, servingSize: 100, servingUnit: 'g' },
  { name: 'Salmon', category: 'meat', calories: 208, protein: 20, carbs: 0, fat: 13, servingSize: 100, servingUnit: 'g' },
  { name: 'Tuna (Canned)', category: 'meat', calories: 132, protein: 29, carbs: 0, fat: 1, servingSize: 100, servingUnit: 'g' },
  { name: 'Mutton (Lamb)', category: 'meat', calories: 294, protein: 25, carbs: 0, fat: 21, servingSize: 100, servingUnit: 'g' },
  { name: 'Egg White', category: 'meat', calories: 52, protein: 11, carbs: 0.7, fat: 0.2, servingSize: 100, servingUnit: 'g' },
  // Vegetables
  { name: 'Broccoli', category: 'vegetables', calories: 34, protein: 2.8, carbs: 7, fat: 0.4, servingSize: 100, servingUnit: 'g' },
  { name: 'Spinach', category: 'vegetables', calories: 23, protein: 2.9, carbs: 3.6, fat: 0.4, servingSize: 100, servingUnit: 'g' },
  { name: 'Sweet Potato', category: 'vegetables', calories: 86, protein: 1.6, carbs: 20, fat: 0.1, servingSize: 100, servingUnit: 'g' },
  { name: 'Carrot', category: 'vegetables', calories: 41, protein: 0.9, carbs: 10, fat: 0.2, servingSize: 100, servingUnit: 'g' },
  { name: 'Tomato', category: 'vegetables', calories: 18, protein: 0.9, carbs: 3.9, fat: 0.2, servingSize: 100, servingUnit: 'g' },
  // Fruits
  { name: 'Banana', category: 'fruits', calories: 89, protein: 1.1, carbs: 23, fat: 0.3, servingSize: 100, servingUnit: 'g' },
  { name: 'Apple', category: 'fruits', calories: 52, protein: 0.3, carbs: 14, fat: 0.2, servingSize: 100, servingUnit: 'g' },
  { name: 'Orange', category: 'fruits', calories: 47, protein: 0.9, carbs: 12, fat: 0.1, servingSize: 100, servingUnit: 'g' },
  { name: 'Strawberry', category: 'fruits', calories: 32, protein: 0.7, carbs: 7.7, fat: 0.3, servingSize: 100, servingUnit: 'g' },
  { name: 'Mango', category: 'fruits', calories: 60, protein: 0.8, carbs: 15, fat: 0.4, servingSize: 100, servingUnit: 'g' },
  // Grains
  { name: 'White Rice (Cooked)', category: 'grains', calories: 130, protein: 2.7, carbs: 28, fat: 0.3, servingSize: 100, servingUnit: 'g' },
  { name: 'Brown Rice (Cooked)', category: 'grains', calories: 123, protein: 2.7, carbs: 26, fat: 0.9, servingSize: 100, servingUnit: 'g' },
  { name: 'Oats', category: 'grains', calories: 389, protein: 17, carbs: 66, fat: 7, servingSize: 100, servingUnit: 'g' },
  { name: 'Whole Wheat Bread', category: 'grains', calories: 247, protein: 13, carbs: 41, fat: 3.4, servingSize: 100, servingUnit: 'g' },
  { name: 'Chapati/Roti', category: 'grains', calories: 297, protein: 9, carbs: 57, fat: 4, servingSize: 100, servingUnit: 'g' },
  { name: 'Quinoa (Cooked)', category: 'grains', calories: 120, protein: 4.4, carbs: 22, fat: 1.9, servingSize: 100, servingUnit: 'g' },
  // Snacks
  { name: 'Almonds', category: 'snacks', calories: 579, protein: 21, carbs: 22, fat: 50, servingSize: 100, servingUnit: 'g' },
  { name: 'Peanut Butter', category: 'snacks', calories: 588, protein: 25, carbs: 20, fat: 50, servingSize: 100, servingUnit: 'g' },
  { name: 'Dark Chocolate (85%)', category: 'snacks', calories: 598, protein: 8, carbs: 46, fat: 43, servingSize: 100, servingUnit: 'g' },
  { name: 'Protein Bar', category: 'snacks', calories: 350, protein: 20, carbs: 35, fat: 10, servingSize: 60, servingUnit: 'g' },
  // Beverages
  { name: 'Whey Protein Shake', category: 'supplements', calories: 120, protein: 24, carbs: 3, fat: 2, servingSize: 30, servingUnit: 'g' },
  { name: 'Orange Juice', category: 'beverages', calories: 45, protein: 0.7, carbs: 10, fat: 0.2, servingSize: 100, servingUnit: 'ml' },
  { name: 'Coconut Water', category: 'beverages', calories: 19, protein: 0.7, carbs: 3.7, fat: 0.2, servingSize: 100, servingUnit: 'ml' },
  { name: 'Green Tea', category: 'beverages', calories: 1, protein: 0, carbs: 0.2, fat: 0, servingSize: 100, servingUnit: 'ml' },
];

// ── Seed function ─────────────────────────────────────────────────────────────
const seedDatabase = async () => {
  try {
    console.log('🌱 Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected!');

    // Clear existing data
    await Workout.deleteMany({ isPredefined: true });
    await FoodItem.deleteMany({ isCustom: false });
    console.log('🗑️  Cleared existing seed data');

    // Insert new seed data
    await Workout.insertMany(predefinedWorkouts);
    console.log(`✅ Inserted ${predefinedWorkouts.length} predefined workouts`);

    await FoodItem.insertMany(foodItems);
    console.log(`✅ Inserted ${foodItems.length} food items`);

    console.log('\n🎉 Database seeded successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Seed error:', error);
    process.exit(1);
  }
};

seedDatabase();
