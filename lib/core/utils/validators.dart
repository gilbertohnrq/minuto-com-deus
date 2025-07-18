import 'package:intl/intl.dart';

class Validators {
  // Common Brazilian phone area codes
  static const List<String> _validAreaCodes = [
    '11', '12', '13', '14', '15', '16', '17', '18', '19', // SP
    '21', '22', '24', // RJ
    '27', '28', // ES
    '31', '32', '33', '34', '35', '37', '38', // MG
    '41', '42', '43', '44', '45', '46', // PR
    '47', '48', '49', // SC
    '51', '53', '54', '55', // RS
    '61', // DF
    '62', '64', // GO
    '63', // TO
    '65', '66', // MT
    '67', // MS
    '68', // AC
    '69', // RO
    '71', '73', '74', '75', '77', // BA
    '79', // SE
    '81', '87', // PE
    '82', // AL
    '83', // PB
    '84', // RN
    '85', '88', // CE
    '86', '89', // PI
    '91', '93', '94', // PA
    '92', '97', // AM
    '95', // RR
    '96', // AP
    '98', '99', // MA
  ];

  // Common weak passwords
  static const List<String> _commonPasswords = [
    '123456',
    '123456789',
    'password',
    'senha123',
    'qwerty',
    'abc123',
    '123abc',
    'senha',
    'password123',
    '12345678',
    'admin',
    'root',
    'user',
    'guest',
    'test',
    'demo'
  ];

  // Suspicious content patterns for security
  static const List<String> _suspiciousPatterns = [
    '<script',
    'javascript:',
    'onclick=',
    'onload=',
    'onerror=',
    'eval(',
    'setTimeout(',
    'setInterval(',
    'Function(',
    'SELECT',
    'INSERT',
    'UPDATE',
    'DELETE',
    'DROP',
    'ALTER',
    'UNION',
    'EXEC',
    'EXECUTE',
    '--',
    '/*',
    '*/',
    'xp_',
    'sp_',
    '<iframe',
    '<object',
    '<embed',
    '<link',
    '<meta',
    '<base',
    'data:',
    'vbscript:',
    'file:',
    'ftp:',
    'ldap:',
    'gopher:'
  ];

  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }

    final trimmed = value.trim();

    if (trimmed.length > 254) {
      return 'Email muito longo';
    }

    final parts = trimmed.split('@');
    if (parts.length != 2) {
      return 'Digite um email válido';
    }

    final localPart = parts[0];
    final domain = parts[1];

    if (localPart.isEmpty || domain.isEmpty) {
      return 'Digite um email válido';
    }

    if (localPart.length > 64) {
      return 'Parte local do email muito longa';
    }

    if (localPart.contains('..')) {
      return 'Email não pode conter pontos consecutivos';
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!emailRegex.hasMatch(trimmed)) {
      return 'Digite um email válido';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }

    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }

    if (value.length > 128) {
      return 'A senha deve ter no máximo 128 caracteres';
    }

    if (_commonPasswords.contains(value.toLowerCase())) {
      return 'Senha muito comum. Escolha uma senha mais segura';
    }

    return null;
  }

  // Strong password validation
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }

    if (value.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres';
    }

    if (value.length > 128) {
      return 'A senha deve ter no máximo 128 caracteres';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'A senha deve conter pelo menos uma letra maiúscula';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'A senha deve conter pelo menos uma letra minúscula';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'A senha deve conter pelo menos um número';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'A senha deve conter pelo menos um caractere especial';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome é obrigatório';
    }

    final trimmed = value.trim();

    if (trimmed.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }

    if (trimmed.length > 100) {
      return 'Nome deve ter no máximo 100 caracteres';
    }

    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    final hasInvalidChars = trimmed.runes.any((rune) {
      final char = String.fromCharCode(rune);
      return !RegExp(r'[a-zA-ZÀ-ÿ\s\-]').hasMatch(char) && char != "'";
    });

    if (hasInvalidChars) {
      return 'Nome deve conter apenas letras, espaços, hífens e apostrofes';
    }

    if (RegExp(r'\s{2,}').hasMatch(trimmed)) {
      return 'Nome não pode conter espaços consecutivos';
    }

    if (!RegExp(r'[a-zA-ZÀ-ÿ]').hasMatch(trimmed)) {
      return 'Nome deve conter pelo menos uma letra';
    }

    return null;
  }

  // Password confirmation validation
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }

    if (value != password) {
      return 'As senhas não coincidem';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName é obrigatório';
    }
    return null;
  }

  // Phone validation (Brazilian format)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefone é obrigatório';
    }

    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.length < 10 || cleaned.length > 11) {
      return 'Digite um telefone válido';
    }

    if (cleaned.length == 11) {
      final areaCode = cleaned.substring(0, 2);
      if (!_validAreaCodes.contains(areaCode)) {
        return 'Código de área inválido';
      }
    }

    return null;
  }

  // Length validation
  static String? validateMinLength(
      String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }

    if (value.length < minLength) {
      return '$fieldName deve ter pelo menos $minLength caracteres';
    }

    return null;
  }

  static String? validateMaxLength(
      String? value, int maxLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length > maxLength) {
      return '$fieldName deve ter no máximo $maxLength caracteres';
    }

    return null;
  }

  static String? validateLengthRange(
      String? value, int minLength, int maxLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }

    if (value.length < minLength) {
      return '$fieldName deve ter pelo menos $minLength caracteres';
    }

    if (value.length > maxLength) {
      return '$fieldName deve ter no máximo $maxLength caracteres';
    }

    return null;
  }

  // Numeric validation
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }

    if (double.tryParse(value) == null) {
      return '$fieldName deve ser um número válido';
    }

    return null;
  }

  static String? validateInteger(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }

    if (int.tryParse(value) == null) {
      return '$fieldName deve ser um número inteiro válido';
    }

    return null;
  }

  // URL validation
  static String? validateUrl(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }

    final urlRegex = RegExp(
      r'^(https?|ftp)://[^\s/$.?#].[^\s]*$',
      caseSensitive: false,
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Digite uma URL válida';
    }

    return null;
  }

  // Date validation (Brazilian format DD/MM/YYYY)
  static String? validateDate(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }

    final dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!dateRegex.hasMatch(value)) {
      return 'Digite uma data válida (DD/MM/AAAA)';
    }

    final parts = value.split('/');
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return 'Digite uma data válida (DD/MM/AAAA)';
    }

    if (day < 1 || day > 31) {
      return 'Dia deve estar entre 1 e 31';
    }

    if (month < 1 || month > 12) {
      return 'Mês deve estar entre 1 e 12';
    }

    // Check days in month
    final daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    // Check for leap year
    if (month == 2 && _isLeapYear(year)) {
      if (day > 29) {
        return 'Fevereiro tem no máximo 29 dias';
      }
    } else if (month == 2 && day > 28) {
      return 'Fevereiro tem no máximo 28 dias';
    } else if (day > daysInMonth[month - 1]) {
      return 'Este mês tem apenas ${daysInMonth[month - 1]} dias';
    }

    return null;
  }

  // CPF validation
  static String? validateCPF(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF é obrigatório';
    }

    final cpf = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cpf.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }

    // Check if all digits are the same
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) {
      return 'CPF inválido';
    }

    // Validate CPF check digits
    if (!_isValidCPF(cpf)) {
      return 'CPF inválido';
    }

    return null;
  }

  // Security validation
  static bool containsSuspiciousContent(String value) {
    final lowerValue = value.toLowerCase();
    return _suspiciousPatterns
        .any((pattern) => lowerValue.contains(pattern.toLowerCase()));
  }

  static String? validateSecurity(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (containsSuspiciousContent(value)) {
      return '$fieldName contém conteúdo não permitido';
    }

    return null;
  }

  // Sanitization methods
  static String sanitizeInput(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp(r'["\x27]'), '') // Remove quotes
        .replaceAll(RegExp(r'\s+'), ' '); // Normalize spaces
  }

  static String sanitizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  static String sanitizeName(String name) {
    return name.trim().split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  static String sanitizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }

  static String sanitizeForDatabase(String input) {
    return input
        .replaceAll(RegExp(r'[;\x27\x22\\]'), '') // Remove SQL injection chars
        .replaceAll(
            RegExp(r'(SELECT|INSERT|UPDATE|DELETE|DROP|ALTER|UNION|EXEC)',
                caseSensitive: false),
            '');
  }

  static String sanitizeHtml(String input) {
    return input
        .replaceAll(
            RegExp(r'<script[^>]*>.*?</script>',
                caseSensitive: false, dotAll: true),
            '')
        .replaceAll(
            RegExp(r'<iframe[^>]*>.*?</iframe>',
                caseSensitive: false, dotAll: true),
            '')
        .replaceAll(RegExp(r'on\w+="[^"]*"', caseSensitive: false), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '');
  }

  // Formatting methods
  static String formatPhone(String phone) {
    final cleaned = sanitizePhone(phone);
    if (cleaned.length == 11) {
      return '(${cleaned.substring(0, 2)}) ${cleaned.substring(2, 7)}-${cleaned.substring(7)}';
    } else if (cleaned.length == 10) {
      return '(${cleaned.substring(0, 2)}) ${cleaned.substring(2, 6)}-${cleaned.substring(6)}';
    }
    return phone;
  }

  static String formatCPF(String cpf) {
    final cleaned = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length == 11) {
      return '${cleaned.substring(0, 3)}.${cleaned.substring(3, 6)}.${cleaned.substring(6, 9)}-${cleaned.substring(9)}';
    }
    return cpf;
  }

  static String formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatter.format(value);
  }

  // Utility validators
  static String? Function(String?) combineValidators(
      List<String? Function(String?)> validators) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }

  static String? Function(String?) conditionalValidator(
    bool Function() condition,
    String? Function(String?) validator,
  ) {
    return (value) {
      if (condition()) {
        return validator(value);
      }
      return null;
    };
  }

  static String? Function(String?) optionalValidator(
    String? Function(String?) validator,
  ) {
    return (value) {
      if (value == null || value.isEmpty) {
        return null;
      }
      return validator(value);
    };
  }

  static String? validatePattern(
      String? value, RegExp pattern, String errorMessage) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (!pattern.hasMatch(value)) {
      return errorMessage;
    }

    return null;
  }

  static String? validateRange(
      String? value, num min, num max, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }

    final numValue = num.tryParse(value);
    if (numValue == null) {
      return '$fieldName deve ser um número válido';
    }

    if (numValue < min || numValue > max) {
      return '$fieldName deve estar entre $min e $max';
    }

    return null;
  }

  static String? validateOptions(
      String? value, List<String> options, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }

    if (!options.contains(value)) {
      return '$fieldName deve ser uma das opções válidas';
    }

    return null;
  }

  // Private helper methods
  static bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  static bool _isValidCPF(String cpf) {
    // Calculate first check digit
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }
    int remainder = sum % 11;
    int firstDigit = remainder < 2 ? 0 : 11 - remainder;

    if (int.parse(cpf[9]) != firstDigit) {
      return false;
    }

    // Calculate second check digit
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }
    remainder = sum % 11;
    int secondDigit = remainder < 2 ? 0 : 11 - remainder;

    return int.parse(cpf[10]) == secondDigit;
  }
}
