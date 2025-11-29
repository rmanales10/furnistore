import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class IdentityVerificationFormScreen extends StatefulWidget {
  const IdentityVerificationFormScreen({super.key});

  @override
  State<IdentityVerificationFormScreen> createState() =>
      _IdentityVerificationFormScreenState();
}

class _IdentityVerificationFormScreenState
    extends State<IdentityVerificationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedIdCardType;
  final _idCardNumberController = TextEditingController();

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _idCardTypes = [
    'National ID',
    'Passport',
    "Driver's License",
    'SSS ID / UMID',
    'PhilHealth ID',
    'Postal ID',
    'Other'
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3E6BE0),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Regex patterns for different ID types
  String? _getRegexPattern(String? idCardType) {
    switch (idCardType) {
      case 'National ID':
        return r'^\d{4}-\d{4}-\d{4}-\d{4}$'; // 1234-3653-3236-3625
      case 'Passport':
        return r'^P\d{7}[A-Z]$'; // P1234567A
      case "Driver's License":
        return r'^N\d{2}-\d{2}-\d{6}$'; // N12-34-567890
      case 'SSS ID / UMID':
        return r'^SS-\d{10}$'; // SS-1029384756
      case 'PhilHealth ID':
        return r'^\d{2}-\d{9}-\d{1}$'; // 12-345678901-2
      case 'Postal ID':
        return r'^PI-\d{9}$'; // PI-987654321
      case 'Other':
        return null; // No validation for Other
      default:
        return null;
    }
  }

  String? _getFormatExample(String? idCardType) {
    switch (idCardType) {
      case 'National ID':
        return 'Example: 1234-3653-3236-3625';
      case 'Passport':
        return 'Example: P1234567A';
      case "Driver's License":
        return 'Example: N12-34-567890';
      case 'SSS ID / UMID':
        return 'Example: SS-1029384756';
      case 'PhilHealth ID':
        return 'Example: 12-345678901-2';
      case 'Postal ID':
        return 'Example: PI-987654321';
      default:
        return null;
    }
  }

  // Get max length for each ID type (including dashes/formatting)
  int? _getMaxLength(String? idCardType) {
    switch (idCardType) {
      case 'National ID':
        return 19; // 1234-3653-3236-3625 (16 digits + 3 dashes)
      case 'Passport':
        return 9; // P1234567A
      case "Driver's License":
        return 13; // N12-34-567890 (10 digits + 2 dashes + N)
      case 'SSS ID / UMID':
        return 13; // SS-1029384756 (10 digits + 2 dashes + SS)
      case 'PhilHealth ID':
        return 14; // 12-345678901-2 (12 digits + 2 dashes)
      case 'Postal ID':
        return 12; // PI-987654321 (9 digits + 2 dashes + PI)
      case 'Other':
        return null; // No limit
      default:
        return null;
    }
  }

  // Get input formatter for auto-formatting
  List<TextInputFormatter>? _getInputFormatters(String? idCardType) {
    switch (idCardType) {
      case 'National ID':
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[\d-]')),
          _NationalIdFormatter(),
        ];
      case 'Passport':
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[P\dA-Z]')),
          LengthLimitingTextInputFormatter(9),
          _UpperCaseTextFormatter(),
        ];
      case "Driver's License":
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[N\d-]')),
          LengthLimitingTextInputFormatter(13),
        ];
      case 'SSS ID / UMID':
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[S\d-]')),
          LengthLimitingTextInputFormatter(13),
          _UpperCaseTextFormatter(),
        ];
      case 'PhilHealth ID':
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[\d-]')),
          LengthLimitingTextInputFormatter(14),
        ];
      case 'Postal ID':
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[PI\d-]')),
          LengthLimitingTextInputFormatter(12),
          _UpperCaseTextFormatter(),
        ];
      default:
        return null;
    }
  }

  String? _validateIdCardNumber(String? value, String? idCardType) {
    if (value == null || value.isEmpty) {
      return 'ID Card Number is required';
    }

    // Remove spaces for validation
    final cleanedValue = value.replaceAll(' ', '');

    // Get regex pattern for the selected ID type
    final pattern = _getRegexPattern(idCardType);

    if (pattern == null) {
      // No validation for "Other" type
      return null;
    }

    // Validate against regex pattern
    final regex = RegExp(pattern);
    if (!regex.hasMatch(cleanedValue)) {
      final example = _getFormatExample(idCardType);
      return example != null
          ? 'Invalid format. $example'
          : 'Invalid ID card number format';
    }

    return null;
  }

  @override
  void dispose() {
    _idCardNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Identity Verification',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                // Date of Birth
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date of Birth',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedDate != null
                                  ? DateFormat('dd-MMM-yyyy')
                                      .format(_selectedDate!)
                                  : 'Select date',
                              style: TextStyle(
                                fontSize: 16,
                                color: _selectedDate != null
                                    ? Colors.black
                                    : Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.calendar_today,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Gender Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: InputBorder.none,
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    items: _genderOptions.map((String gender) {
                      return DropdownMenuItem<String>(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select gender';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // ID Card Type Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedIdCardType,
                    decoration: const InputDecoration(
                      labelText: 'ID Card Type',
                      border: InputBorder.none,
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    items: _idCardTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedIdCardType = newValue;
                        // Clear ID card number when type changes
                        _idCardNumberController.clear();
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select ID card type';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // ID Card Number
                TextFormField(
                  controller: _idCardNumberController,
                  maxLength: _getMaxLength(_selectedIdCardType),
                  inputFormatters: _getInputFormatters(_selectedIdCardType),
                  decoration: InputDecoration(
                    labelText: 'ID Card Number',
                    hintText: _getFormatExample(_selectedIdCardType),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    helperText: _selectedIdCardType != null &&
                            _selectedIdCardType != 'Other'
                        ? _getFormatExample(_selectedIdCardType)
                        : null,
                    helperMaxLines: 2,
                    counterText: '', // Hide character counter
                  ),
                  validator: (value) =>
                      _validateIdCardNumber(value, _selectedIdCardType),
                ),
                const SizedBox(height: 40),
                // Scan Document Button
                Container(
                  height: 45,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3E6BE0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() &&
                          _selectedDate != null) {
                        Navigator.pushNamed(
                          context,
                          '/identity-verification/document-camera',
                          arguments: {
                            'dateOfBirth': _selectedDate,
                            'gender': _selectedGender,
                            'idCardType': _selectedIdCardType,
                            'idCardNumber': _idCardNumberController.text,
                          },
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all fields'),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Scan the document',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom formatter for National ID (auto-add dashes)
class _NationalIdFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('-', '');

    if (text.length > 16) {
      return oldValue; // Limit to 16 digits
    }

    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += '-';
      }
      formatted += text[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Custom formatter to convert to uppercase
class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
