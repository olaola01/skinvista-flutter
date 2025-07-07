class StringHelper {
  static String formatCondition(String condition) {
    return condition
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}