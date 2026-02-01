import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class CreateRequestPage extends StatefulWidget {
  const CreateRequestPage({super.key});

  @override
  State<CreateRequestPage> createState() => _CreateRequestPageState();
}

class _CreateRequestPageState extends State<CreateRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedCategory = 'Plumbing'; // Default category
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _imageFile;
  bool _isLoading = false;

  final List<String> _categories = [
    'Plumbing',
    'Electrical',
    'HVAC',
    'Appliance',
    'Pest Control',
    'Other',
  ];

  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserApartment();
  }

  Future<void> _loadUserApartment() async {
    final uid = _authService.getCurrentUserId();
    if (uid != null) {
      final userData = await _firestoreService.getUser(uid);
      if (userData != null) {
        setState(() {
          if (userData['apartment'] != null) {
            _apartmentController.text = userData['apartment'];
          }
          if (userData['phone'] != null) {
            _phoneController.text = userData['phone'];
          }
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00A8C6),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1D3E72),
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

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00A8C6),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1D3E72),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an available date and time'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);
      try {
        final uid = _authService.getCurrentUserId();
        if (uid != null) {
          String? imageUrl;
          if (_imageFile != null) {
            imageUrl = await _firestoreService.uploadRequestImage(_imageFile!);
          }

          await _firestoreService.createRequest(
            uid: uid,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _selectedCategory,
            availableDate: DateFormat('MMM dd, yyyy').format(_selectedDate!),
            availableTime: _selectedTime!.format(context),
            apartment: _apartmentController.text.trim(),
            phone: _phoneController.text.trim(),
            imageUrl: imageUrl,
          );
          if (mounted) {
            Navigator.pop(context); // Go back to Home Page
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Request created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _apartmentController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Submit Request",
          style: TextStyle(
            color: Color(0xFF1D3E72),
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8FAFC),
        foregroundColor: const Color(0xFF1D3E72),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Color(0xFF1D3E72),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "What needs fixing?",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1D3E72),
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Provide details about the issue and your availability.",
                      style: TextStyle(
                        color: const Color(0xFF1D3E72).withOpacity(0.6),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title Field
                    _buildFieldLabel("Request Subject"),
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D3E72),
                        fontSize: 16,
                      ),
                      decoration: _inputDecoration(
                        "e.g., Water Leak in Bathroom",
                        Icons.topic_rounded,
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Title required'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // Apartment Field
                    _buildFieldLabel("Apartment Number"),
                    TextFormField(
                      controller: _apartmentController,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D3E72),
                        fontSize: 16,
                      ),
                      decoration: _inputDecoration(
                        "e.g., A-101",
                        Icons.apartment_rounded,
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Apartment required'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // Phone Number Field
                    _buildFieldLabel("Phone Number"),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D3E72),
                        fontSize: 16,
                      ),
                      decoration: _inputDecoration(
                        "e.g., +1 234 567 890",
                        Icons.phone_rounded,
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Phone number required'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // Category & Availability Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel("Category"),
                              _buildCompactDropdown(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel("Your Availability"),
                              _buildAvailabilityButton(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Image Attachment
                    _buildFieldLabel("Attach Image (Optional)"),
                    _buildImagePicker(),
                    const SizedBox(height: 24),

                    // Description Field
                    _buildFieldLabel("Description"),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D3E72),
                        height: 1.5,
                      ),
                      decoration: _inputDecoration(
                        "Describe the problem...",
                        null,
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Description required'
                          : null,
                    ),
                    const SizedBox(height: 48),

                    // Modern Submit Button
                    _buildSubmitButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1D3E72),
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[300]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _imageFile != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(_imageFile!, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _imageFile = null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 40,
                    color: const Color(0xFF00A8C6).withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Add a photo of the issue",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCompactDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: const Icon(
            Icons.arrow_drop_down_circle_outlined,
            size: 20,
            color: Color(0xFF00A8C6),
          ),
          style: const TextStyle(
            color: Color(0xFF1D3E72),
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          items: _categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => setState(() => _selectedCategory = v!),
        ),
      ),
    );
  }

  Widget _buildAvailabilityButton() {
    final text = (_selectedDate != null && _selectedTime != null)
        ? "${DateFormat('MMM d').format(_selectedDate!)}, ${_selectedTime!.format(context)}"
        : "Set Date & Time";

    return InkWell(
      onTap: () async {
        await _selectDate(context);
        if (_selectedDate != null && mounted) await _selectTime(context);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: (_selectedDate != null)
                ? const Color(0xFF00A8C6).withOpacity(0.5)
                : Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: (_selectedDate != null)
                  ? const Color(0xFF00A8C6)
                  : Colors.grey,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: (_selectedDate != null)
                      ? const Color(0xFF1D3E72)
                      : Colors.grey.shade400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _submitRequest,
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: _isLoading
              ? const LinearGradient(colors: [Colors.grey, Colors.grey])
              : const LinearGradient(
                  colors: [Color(0xFF00A8C6), Color(0xFF0A5CFF)],
                ),
          boxShadow: [
            if (!_isLoading)
              BoxShadow(
                color: const Color(0xFF00A8C6).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  "Submit Request",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData? icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      prefixIcon: icon != null
          ? Icon(icon, color: const Color(0xFF00A8C6), size: 22)
          : null,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF00A8C6), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }
}
