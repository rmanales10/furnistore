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

  String? _validateIdCardNumber(String? value, String? idCardType) {
    // Only check if field is not empty - no other validation
    if (value == null || value.isEmpty) {
      return 'ID Card Number is required';
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
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
