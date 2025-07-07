class ConditionHelper {
  static final Map<String, Map<String, List<String>>> _conditionData = {
    'acne': {
      'symptoms': [
        "Whiteheads and blackheads",
        "Pimples and pustules",
        "Oily skin",
        "Scarring in severe cases"
      ],
      'recommendations': [
        "Wash face twice daily with a gentle cleanser",
        "Use over-the-counter treatments (e.g., benzoyl peroxide, salicylic acid)",
        "Avoid picking or squeezing pimples",
        "Consult a dermatologist for persistent or severe cases"
      ],
    },
    'eczema': {
      'symptoms': [
        "Itchy, red, and inflamed patches",
        "Dry and scaly skin",
        "Oozing or crusting in some cases"
      ],
      'recommendations': [
        "Use mild, fragrance-free soaps and detergents",
        "Apply moisturizers regularly, especially after bathing",
        "Avoid triggers like certain fabrics or allergens",
        "Use prescribed topical steroids or medications as directed"
      ],
    },
    'keloids': {
      'symptoms': [
        "Raised, firm, and rubbery lesions",
        "Itching or pain",
        "Darker than surrounding skin"
      ],
      'recommendations': [
        "Avoid piercings or unnecessary skin trauma",
        "Use silicone gel sheets or pressure dressings",
        "Consider corticosteroid injections",
        "Consult a dermatologist for treatment options (e.g., laser therapy, surgical removal)"
      ],
    },
    'hyperpigmentation': {
      'symptoms': [
        "Patches of skin darker than surrounding area",
        "Can be caused by sun exposure, inflammation, or medications"
      ],
      'recommendations': [
        "Use broad-spectrum sunscreen daily",
        "Avoid excessive sun exposure",
        "Use topical treatments (e.g., hydroquinone, retinoids) under medical supervision",
        "Consider chemical peels or laser therapy for persistent cases"
      ],
    },
    'pseudofolliculitis_barbae': {
      'symptoms': [
        "Small, red, inflamed bumps",
        "Ingrown hairs",
        "Typically on neck and face in men who shave"
      ],
      'recommendations': [
        "Use proper shaving techniques (e.g., single-blade razors, shave in direction of hair growth)",
        "Consider alternative hair removal methods (e.g., depilatory creams)",
        "Use topical antibiotics or retinoids if prescribed"
      ],
    },
    'prurigo_nodularis': {
      'symptoms': [
        "Hard, itchy lumps on the skin",
        "Often on arms and legs",
        "Associated with other skin conditions or systemic diseases"
      ],
      'recommendations': [
        "Avoid scratching",
        "Use moisturizers and topical steroids",
        "Consider phototherapy or systemic medications under medical supervision",
        "Address any underlying conditions"
      ],
    },
    'vitiligo': {
      'symptoms': [
        "White patches on the skin",
        "Often symmetrical",
        "Can affect any part of the body"
      ],
      'recommendations': [
        "Use sunscreen to protect affected areas",
        "Consider topical corticosteroids or calcineurin inhibitors",
        "Explore phototherapy options",
        "Seek support for cosmetic concerns"
      ],
    },
    'contact_dermatitis': {
      'symptoms': [
        "Red, itchy rash",
        "Sometimes with blisters",
        "Occurs in areas of skin contact with irritant or allergen"
      ],
      'recommendations': [
        "Identify and avoid the trigger",
        "Use mild soaps and moisturizers",
        "Apply topical corticosteroids for inflammation",
        "Seek medical attention for severe reactions"
      ],
    },
    'fungal_infections': {
      'symptoms': [
        "Red, itchy, and sometimes scaly patches",
        "Often with a clear center (ringworm)",
        "White, curd-like discharge (yeast infections)"
      ],
      'recommendations': [
        "Keep the affected area clean and dry",
        "Use over-the-counter antifungal creams or powders",
        "Avoid sharing personal items",
        "Consult a doctor for persistent or widespread infections"
      ],
    },
    'seborrheic_dermatitis': {
      'symptoms': [
        "Red, scaly, and sometimes greasy patches",
        "Often on scalp, face, or chest"
      ],
      'recommendations': [
        "Use medicated shampoos (e.g., ketoconazole, selenium sulfide)",
        "Apply topical antifungals or corticosteroids as prescribed",
        "Maintain good skin hygiene"
      ],
    },
    'no_diagnosis': {
      'symptoms': [
        "No distinct or recognizable skin abnormalities detected",
        "Possible mild irritation or variation in skin texture",
        "Appearance may be normal or not match any known condition recognized by the app"
      ],
      'recommendations': [
        "Maintain good skin hygiene with gentle cleansing",
        "Monitor the area for any changes in color, texture, or discomfort",
        "Use a mild moisturizer to keep skin hydrated",
        "Consult a dermatologist if you notice persistent or worsening symptoms"
      ],
    },
  };

  // Get symptoms for a given condition
  static List<String> getSymptoms(String condition) {
    return _conditionData[condition.toLowerCase()]?['symptoms'] ??
        ["Dry, sensitive skin", "Mild redness and scaling", "Possible itching"];
  }

  // Get recommendations for a given condition
  static List<String> getRecommendations(String condition) {
    return _conditionData[condition.toLowerCase()]?['recommendations'] ??
        ["Keep the area moisturised", "Avoid scratching", "Monitor for changes"];
  }
}