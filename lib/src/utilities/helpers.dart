bool isNullOrEmpty(String value) => value == null || value.isEmpty;

bool isAlphaNumeric(String value) => RegExp(r"^[a-zA-Z0-9]*$").hasMatch(value);
