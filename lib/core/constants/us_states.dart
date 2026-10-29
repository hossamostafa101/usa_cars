/// US state names are displayed to users; USPS codes are sent to the API.
/// Includes Washington, D.C. as a standard postal address option.
class UsStates {
  UsStates._();

  static const Map<String, String> names = {
    'AL': 'Alabama',
    'AK': 'Alaska',
    'AZ': 'Arizona',
    'AR': 'Arkansas',
    'CA': 'California',
    'CO': 'Colorado',
    'CT': 'Connecticut',
    'DE': 'Delaware',
    'FL': 'Florida',
    'GA': 'Georgia',
    'HI': 'Hawaii',
    'ID': 'Idaho',
    'IL': 'Illinois',
    'IN': 'Indiana',
    'IA': 'Iowa',
    'KS': 'Kansas',
    'KY': 'Kentucky',
    'LA': 'Louisiana',
    'ME': 'Maine',
    'MD': 'Maryland',
    'MA': 'Massachusetts',
    'MI': 'Michigan',
    'MN': 'Minnesota',
    'MS': 'Mississippi',
    'MO': 'Missouri',
    'MT': 'Montana',
    'NE': 'Nebraska',
    'NV': 'Nevada',
    'NH': 'New Hampshire',
    'NJ': 'New Jersey',
    'NM': 'New Mexico',
    'NY': 'New York',
    'NC': 'North Carolina',
    'ND': 'North Dakota',
    'OH': 'Ohio',
    'OK': 'Oklahoma',
    'OR': 'Oregon',
    'PA': 'Pennsylvania',
    'RI': 'Rhode Island',
    'SC': 'South Carolina',
    'SD': 'South Dakota',
    'TN': 'Tennessee',
    'TX': 'Texas',
    'UT': 'Utah',
    'VT': 'Vermont',
    'VA': 'Virginia',
    'WA': 'Washington',
    'WV': 'West Virginia',
    'WI': 'Wisconsin',
    'WY': 'Wyoming',
    'DC': 'District of Columbia',
  };

  /// Accepts an existing two-letter USPS code or a full state name.
  /// Unknown saved values require the user to select a supported state.
  static String? toCode(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final needle = value.trim().toLowerCase();
    for (final entry in names.entries) {
      if (entry.key.toLowerCase() == needle ||
          entry.value.toLowerCase() == needle) {
        return entry.key;
      }
    }
    return null;
  }

  static String displayName(String? code) {
    if (code == null) return '';
    return names[toCode(code)] ?? code;
  }
}
