import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class FirestoreDataImporter {
  static final List<Map<String, dynamic>> allDeficiencies = [
    {
      "question": "Is your child showing delayed growth or development compared to peers?",
      "deficiency": "Calcium Deficiency",
      "recommendedIntake": {
        "0-6 months": "200 mg/day",
        "7-12 months": "260 mg/day",
        "1-3 years": "700 mg/day",
        "4-8 years": "1,000 mg/day",
        "9-10 years": "1,300 mg/day"
      },
      "recommendedFoods": [
        "Milk", "Cheese", "Yogurt", "Leafy green vegetables",
        "Fortified cereals", "Tofu", "Fortified orange juice",
        "Almonds", "Broccoli", "Fish (sardines, salmon)"
      ],
      "mealSuggestions": {
        "0-6 months": "Breastmilk or formula (provides required calcium)",
        "7-12 months": "Small amounts of yogurt, soft cheese with meals",
        "1-3 years": "Whole milk, soft cheese slices as snacks, tofu cubes",
        "4-8 years": "Milk with breakfast, yogurt parfaits, broccoli with cheese",
        "9-10 years": "Cheese sandwiches, fortified cereals with milk, salmon with vegetables"
      },
      "educationalTip": "Calcium is essential for building strong bones and teeth during growth.",
      "referenceLink": "https://ods.od.nih.gov/factsheets/Calcium-Consumer/"
    },
    {
      "question": "Does your child experience frequent fatigue or weakness?",
      "deficiency": "Iron Deficiency",
      "recommendedIntake": {
        "0-6 months": "0.27 mg/day",
        "7-12 months": "11 mg/day",
        "1-3 years": "7 mg/day",
        "4-8 years": "10 mg/day",
        "9-10 years": "8 mg/day"
      },
      "recommendedFoods": [
        "Red meat", "Chicken", "Fish", "Beans",
        "Iron-fortified cereals", "Spinach", "Lentils",
        "Tofu", "Eggs", "Pumpkin seeds"
      ],
      "mealSuggestions": {
        "0-6 months": "Breastmilk or iron-fortified formula",
        "7-12 months": "Pureed meats, iron-fortified baby cereals",
        "1-3 years": "Small pieces of chicken, beans, iron-rich cereals, scrambled eggs",
        "4-8 years": "Beef stir fry with vegetables, lentil soup",
        "9-10 years": "Lean meats, iron-fortified cereals with fruits, spinach salad"
      },
      "educationalTip": "Iron supports red blood cell production and prevents fatigue.",
      "referenceLink": "https://ods.od.nih.gov/factsheets/Iron-Consumer/"
    },
    {
      "question": "Does your child have difficulty seeing in dim light?",
      "deficiency": "Vitamin A Deficiency",
      "recommendedIntake": {
        "0-6 months": "400 mcg/day",
        "7-12 months": "500 mcg/day",
        "1-3 years": "300 mcg/day",
        "4-8 years": "400 mcg/day",
        "9-10 years": "600 mcg/day"
      },
      "recommendedFoods": [
        "Carrots", "Sweet potatoes", "Spinach", "Kale",
        "Fortified milk", "Cantaloupe", "Red bell peppers",
        "Mangoes", "Tomatoes"
      ],
      "mealSuggestions": {
        "0-6 months": "Breastmilk or formula",
        "7-12 months": "Pureed carrots, sweet potato",
        "1-3 years": "Steamed carrots, spinach omelet, mashed sweet potatoes",
        "4-8 years": "Carrot sticks, spinach smoothies, mango slices",
        "9-10 years": "Carrot soup, sweet potato fries, tomato-based pasta sauce"
      },
      "educationalTip": "Vitamin A supports vision and immune function.",
      "referenceLink": "https://ods.od.nih.gov/factsheets/VitaminA-Consumer/"
    },
    {
      "question": "Is your child experiencing frequent muscle cramps or weakness?",
      "deficiency": "Magnesium Deficiency",
      "recommendedIntake": {
        "0-6 months": "30 mg/day",
        "7-12 months": "75 mg/day",
        "1-3 years": "80 mg/day",
        "4-8 years": "130 mg/day",
        "9-10 years": "240 mg/day"
      },
      "recommendedFoods": [
        "Nuts", "Whole grains", "Leafy greens", "Legumes",
        "Bananas", "Pumpkin seeds", "Avocados", "Tofu", "Chia seeds"
      ],
      "mealSuggestions": {
        "0-6 months": "Breastmilk or formula",
        "7-12 months": "Pureed spinach, mashed bananas",
        "1-3 years": "Banana pancakes, oatmeal with chia seeds",
        "4-8 years": "Whole grain bread with nut butter, avocado toast",
        "9-10 years": "Granola with yogurt, spinach salad with avocado"
      },
      "educationalTip": "Magnesium helps maintain muscle function and heart health.",
      "referenceLink": "https://ods.od.nih.gov/factsheets/Magnesium-Consumer/"
    },
    {
      "question": "Does your child have brittle or weak nails?",
      "deficiency": "Zinc Deficiency",
      "recommendedIntake": {
        "0-6 months": "2 mg/day",
        "7-12 months": "2.5 mg/day",
        "1-3 years": "5 mg/day",
        "4-8 years": "5 mg/day",
        "9-10 years": "8 mg/day"
      },
      "recommendedFoods": [
        "Red meat", "Shellfish", "Legumes", "Seeds",
        "Nuts", "Whole grains", "Oysters", "Poultry", "Dairy products"
      ],
      "mealSuggestions": {
        "0-6 months": "Breastmilk or formula",
        "7-12 months": "Pureed meat, legumes",
        "1-3 years": "Chicken nuggets, beans",
        "4-8 years": "Beef stew, pumpkin seeds, sunflower seeds",
        "9-10 years": "Shrimp stir fry, nut butter sandwiches, grilled chicken"
      },
      "educationalTip": "Zinc is vital for skin, immune system, and growth.",
      "referenceLink": "https://ods.od.nih.gov/factsheets/Zinc-Consumer/"
    },
    {
      "question": "Does your child experience frequent colds or respiratory infections?",
      "deficiency": "Vitamin C Deficiency",
      "recommendedIntake": {
        "0-6 months": "40 mg/day",
        "7-12 months": "50 mg/day",
        "1-3 years": "15 mg/day",
        "4-8 years": "25 mg/day",
        "9-10 years": "45 mg/day"
      },
      "recommendedFoods": [
        "Citrus fruits", "Bell peppers", "Strawberries", "Tomatoes",
        "Broccoli", "Brussels sprouts", "Kiwi", "Pineapple", "Papaya"
      ],
      "mealSuggestions": {
        "0-6 months": "Breastmilk or formula",
        "7-12 months": "Pureed oranges, bell peppers",
        "1-3 years": "Citrus slices, strawberry smoothies",
        "4-8 years": "Tomato salad, fruit juices",
        "9-10 years": "Smoothie bowls, bell pepper snacks"
      },
      "educationalTip": "Vitamin C supports the immune system and skin health.",
      "referenceLink": "https://ods.od.nih.gov/factsheets/VitaminC-Consumer/"
    },
    {
      "question": "Is your child experiencing frequent mood swings or irritability?",
      "deficiency": "Vitamin D Deficiency",
      "recommendedIntake": {
        "0-6 months": "400 IU/day",
        "7-12 months": "400 IU/day",
        "1-3 years": "600 IU/day",
        "4-8 years": "600 IU/day",
        "9-10 years": "600 IU/day"
      },
      "recommendedFoods": [
        "Fortified milk", "Eggs", "Fatty fish", "Fortified cereals",
        "Mushrooms", "Cheese", "Salmon", "Tuna", "Cod liver oil"
      ],
      "mealSuggestions": {
        "0-6 months": "Breastmilk or formula",
        "7-12 months": "Fortified formula, egg yolk",
        "1-3 years": "Scrambled eggs, fortified milk",
        "4-8 years": "Fatty fish, milk with cereal",
        "9-10 years": "Fortified cereals with milk, salmon fillets"
      },
      "educationalTip": "Vitamin D is essential for mood regulation and calcium absorption.",
      "referenceLink": "https://ods.od.nih.gov/factsheets/VitaminD-Consumer/"
    },
    {
      "question": "Does your child have dry skin or hair loss?",
      "deficiency": "Omega-3 Fatty Acids Deficiency",
      "recommendedIntake": {
        "0-6 months": "0.5 g/day",
        "7-12 months": "0.7 g/day",
        "1-3 years": "0.9 g/day",
        "4-8 years": "1.0 g/day",
        "9-10 years": "1.1 g/day"
      },
      "recommendedFoods": [
        "Fatty fish (salmon, mackerel)", "Chia seeds", "Flaxseeds",
        "Walnuts", "Canola oil", "Hemp seeds", "Soybeans", "Eggs"
      ],
      "mealSuggestions": {
        "0-6 months": "Breastmilk or formula",
        "7-12 months": "Pureed salmon, chia seeds",
        "1-3 years": "Omega-3 enriched eggs, flaxseed pancakes",
        "4-8 years": "Salmon fillet, walnut salad",
        "9-10 years": "Chia pudding, walnut cookies"
      },
      "educationalTip": "Omega-3 fatty acids support brain health, skin, and hair.",
      "referenceLink": "https://ods.od.nih.gov/factsheets/Omega3FattyAcids-Consumer/"
    },
    {
      "question": "Is your child having trouble with bone pain or joint problems?",
      "deficiency": "Vitamin D Deficiency",
      "recommendedIntake": {
        "0-6 months": "400 IU/day",
        "7-12 months": "400 IU/day",
        "1-3 years": "600 IU/day",
        "4-8 years": "600 IU/day",
        "9-10 years": "600 IU/day"
      },
      "recommendedFoods": [
        "Fortified milk", "Eggs", "Fatty fish", "Fortified cereals",
        "Cheese", "Tuna", "Salmon", "Cod liver oil"
      ],
      "mealSuggestions": {
        "0-6 months": "Breastmilk or formula",
        "7-12 months": "Fortified formula, scrambled eggs",
        "1-3 years": "Fish tacos, scrambled eggs with cheese",
        "4-8 years": "Fish and chips, cheese omelet",
        "9-10 years": "Grilled salmon with vegetables, fortified cereals with milk"
      },
      "educationalTip": "Vitamin D helps in calcium absorption and supports bone health.",
      "referenceLink": "https://ods.od.nih.gov/factsheets/VitaminD-Consumer/"
    },
    {
      "question": "Is your child prone to frequent infections or have a weak immune system?",
      "deficiency": "Vitamin C Deficiency",
      "recommendedIntake": {
        "0-6 months": "40 mg/day",
        "7-12 months": "50 mg/day",
        "1-3 years": "15 mg/day",
        "4-8 years": "25 mg/day",
        "9-10 years": "45 mg/day"
      },
      "recommendedFoods": [
        "Citrus fruits", "Strawberries", "Tomatoes", "Bell peppers",
        "Kiwi", "Pineapple", "Broccoli", "Papaya"
      ],
      "mealSuggestions": {
        "0-6 months": "Breastmilk or formula",
        "7-12 months": "Pureed citrus fruits, mashed strawberries",
        "1-3 years": "Kiwi slices, orange juice",
        "4-8 years": "Bell pepper strips, fruit salad",
        "9-10 years": "Citrus smoothies, broccoli stir-fry"
      },
      "educationalTip": "Vitamin C boosts the immune system and helps in healing.",
      "referenceLink": "https://ods.od.nih.gov/factsheets/VitaminC-Consumer/"
    },
    {
      "question": "Does your child suffer from constipation or digestive issues?",
      "deficiency": "Fiber Deficiency",
      "recommendedIntake": {
        "0-6 months": "0 g/day (from breast milk or formula)",
        "7-12 months": "5 g/day",
        "1-3 years": "19 g/day",
        "4-8 years": "25 g/day",
        "9-10 years": "26 g/day"
      },
      "recommendedFoods": [
        "Whole grains", "Fruits", "Vegetables", "Legumes",
        "Oats", "Beans", "Lentils", "Berries"
      ],
      "mealSuggestions": {
        "0-6 months": "Breastmilk or formula",
        "7-12 months": "Pureed apples, carrots, and oats",
        "1-3 years": "Whole wheat bread, apple slices",
        "4-8 years": "Veggie stir fry, lentil soup",
        "9-10 years": "Oatmeal with berries, bean salad"
      },
      "educationalTip": "Fiber is essential for digestive health and regular bowel movements.",
      "referenceLink": "https://ods.od.nih.gov/factsheets/DietaryFiber-Consumer/"
    },
    {
      "question": "Is your child showing signs of poor appetite or difficulty gaining weight?",
      "deficiency": "Vitamin B12 Deficiency",
      "recommendedIntake": {
        "0-6 months": "0.4 mcg/day",
        "7-12 months": "0.5 mcg/day",
        "1-3 years": "0.9 mcg/day",
        "4-8 years": "1.2 mcg/day",
        "9-10 years": "1.8 mcg/day"
      },
      "recommendedFoods": [
        "Fish", "Meat", "Poultry", "Dairy products",
        "Eggs", "Fortified cereals", "Milk"
      ],
      "mealSuggestions": {
        "0-6 months": "Breastmilk or formula",
        "7-12 months": "Pureed chicken, scrambled eggs",
        "1-3 years": "Fish sticks, cheese sandwiches",
        "4-8 years": "Grilled chicken, milk with fortified cereal",
        "9-10 years": "Tuna salad, egg muffins"
      },
      "educationalTip": "Vitamin B12 is important for energy production and red blood cell formation.",
      "referenceLink": "https://ods.od.nih.gov/factsheets/VitaminB12-Consumer/"
    },
    {
      "question": "Is your child experiencing poor wound healing or frequent bruising?",
      "deficiency": "Vitamin K Deficiency",
      "recommendedIntake": {
        "0-6 months": "2.0 mcg/day",
        "7-12 months": "2.5 mcg/day",
        "1-3 years": "30 mcg/day",
        "4-8 years": "55 mcg/day",
        "9-10 years": "60 mcg/day"
      },
      "recommendedFoods": [
        "Leafy green vegetables", "Broccoli", "Cabbage", "Spinach",
        "Brussels sprouts", "Kale", "Fish", "Eggs"
      ],
      "mealSuggestions": {
        "0-6 months": "Breastmilk or formula",
        "7-12 months": "Pureed spinach, avocado",
        "1-3 years": "Broccoli stir fry, spinach omelet",
        "4-8 years": "Salad with spinach and kale, roasted broccoli",
        "9-10 years": "Kale chips, fish tacos with cabbage"
      },
      "educationalTip": "Vitamin K is vital for blood clotting and wound healing.",
      "referenceLink": "https://ods.od.nih.gov/factsheets/VitaminK-Consumer/"
    }
  ];

  static Future<void> importAllData(BuildContext context) async {
    try {
      await Firebase.initializeApp();
      final firestore = FirebaseFirestore.instance;

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Starting data import...')),
      );

      // Batch write for better performance
      final batch = firestore.batch();
      final deficienciesRef = firestore.collection('deficiencies');

      // Clear existing data first
      final snapshot = await deficienciesRef.get();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Import new data
      for (var deficiency in allDeficiencies) {
        await deficienciesRef.add(deficiency);
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All data imported successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during import: $e')),
      );
      rethrow;
    }
  }
}