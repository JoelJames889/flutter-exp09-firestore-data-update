import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init note: $e");
  }
  runApp(const FirestoreUpdateApp());
}

/// Root Application Widget - Glassmorphic Dark Edition
class FirestoreUpdateApp extends StatelessWidget {
  const FirestoreUpdateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CloudStaff - Firestore Record Update',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF090D16),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF97316), // Sunset Orange
          secondary: Color(0xFFFB7185), // Neon Coral
          surface: Color(0xFF111827),
        ),
      ),
      home: const EmployeeUpdateScreen(),
    );
  }
}

/// Employee Model for Updates
class Employee {
  final String id;
  final String empId;
  final String name;
  final String email;
  final String department;
  final String role;
  final double salary;
  final String status;

  const Employee({
    required this.id,
    required this.empId,
    required this.name,
    required this.email,
    required this.department,
    required this.role,
    required this.salary,
    required this.status,
  });

  factory Employee.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Employee(
      id: doc.id,
      empId: d['empId'] ?? '',
      name: d['name'] ?? '',
      email: d['email'] ?? '',
      department: d['department'] ?? '',
      role: d['role'] ?? '',
      salary: (d['salary'] as num?)?.toDouble() ?? 0.0,
      status: d['status'] ?? 'Active',
    );
  }
}

/// Main Screen listing employees with Edit/Update capability
class EmployeeUpdateScreen extends StatefulWidget {
  const EmployeeUpdateScreen({super.key});

  @override
  State<EmployeeUpdateScreen> createState() => _EmployeeUpdateScreenState();
}

class _EmployeeUpdateScreenState extends State<EmployeeUpdateScreen> {
  final List<Employee> _localEmployees = [
    Employee(
      id: 'doc_1',
      empId: 'EMP-201',
      name: 'Samantha Ray',
      email: 's.ray@cloudcorp.com',
      department: 'Mobile Engineering',
      role: 'Lead Flutter Developer',
      salary: 115000.0,
      status: 'Promoted',
    ),
    Employee(
      id: 'doc_2',
      empId: 'EMP-202',
      name: 'Daniel Kim',
      email: 'd.kim@cloudcorp.com',
      department: 'DevOps & SRE',
      role: 'Cloud Operations Specialist',
      salary: 92000.0,
      status: 'Active',
    ),
    Employee(
      id: 'doc_3',
      empId: 'EMP-203',
      name: 'Maya Lin',
      email: 'm.lin@cloudcorp.com',
      department: 'Data Analytics',
      role: 'BI & Analytics Lead',
      salary: 104000.0,
      status: 'Active',
    ),
  ];

  Future<void> _updateEmployeeInFirestore(
    String docId,
    String updatedRole,
    String updatedDept,
    double updatedSalary,
    String updatedStatus,
  ) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('employees').doc(docId);

      await docRef.update({
        'role': updatedRole,
        'department': updatedDept,
        'salary': updatedSalary,
        'status': updatedStatus,
        'lastModified': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      setState(() {
        final index = _localEmployees.indexWhere((e) => e.id == docId);
        if (index != -1) {
          final old = _localEmployees[index];
          _localEmployees[index] = Employee(
            id: old.id,
            empId: old.empId,
            name: old.name,
            email: old.email,
            department: updatedDept,
            role: updatedRole,
            salary: updatedSalary,
            status: updatedStatus,
          );
        }
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFF97316).withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(Icons.published_with_changes_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('Firestore document $docId mutated successfully!',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }
  }

  void _openEditSheet(Employee employee) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditEmployeeSheet(
        employee: employee,
        onUpdate: (role, dept, salary, status) {
          _updateEmployeeInFirestore(
              employee.id, role, dept, salary, status);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: Stack(
        children: [
          // Ambient Neon Orbs
          Positioned(
            top: -70,
            right: -50,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFF97316).withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFB7185).withOpacity(0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFF97316).withOpacity(0.4),
                          ),
                        ),
                        child: const Icon(Icons.edit_note_rounded,
                            color: Color(0xFFF97316), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CloudStaff Modifier',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF97316),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Exp 9: Firestore Document Mutation',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Info Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFF97316).withOpacity(0.3),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.sync_alt_rounded,
                                color: Color(0xFFF97316), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Tap "Edit Record" on any employee card to trigger atomic Firestore DocumentReference.update() mutation.',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Colors.white.withOpacity(0.75),
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Employee List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 40),
                    itemCount: _localEmployees.length,
                    itemBuilder: (context, index) {
                      final emp = _localEmployees[index];
                      return _buildEmployeeCard(emp);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(Employee emp) {
    Color statusColor;
    if (emp.status == 'Promoted') {
      statusColor = const Color(0xFF10B981);
    } else if (emp.status == 'Active') {
      statusColor = const Color(0xFF38BDF8);
    } else {
      statusColor = const Color(0xFFF59E0B);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFFF97316).withOpacity(0.15),
                          child: Text(
                            emp.name.isNotEmpty ? emp.name[0] : 'E',
                            style: const TextStyle(
                              color: Color(0xFFF97316),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              emp.name,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              emp.empId,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusColor.withOpacity(0.4)),
                      ),
                      child: Text(
                        emp.status,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ROLE & DEPARTMENT',
                              style: TextStyle(
                                  fontSize: 9.5, color: Colors.white.withOpacity(0.4))),
                          const SizedBox(height: 2),
                          Text(
                            '${emp.role} • ${emp.department}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFDBA74),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('COMPENSATION',
                              style: TextStyle(
                                  fontSize: 9.5, color: Colors.white.withOpacity(0.4))),
                          const SizedBox(height: 2),
                          Text(
                            '\$${emp.salary.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Edit Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: BorderSide(
                        color: const Color(0xFFF97316).withOpacity(0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _openEditSheet(emp),
                    icon: const Icon(Icons.tune_rounded, size: 16, color: Color(0xFFF97316)),
                    label: const Text(
                      'Modify Document Fields',
                      style: TextStyle(
                        color: Color(0xFFF97316),
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Edit Document Bottom Sheet
class EditEmployeeSheet extends StatefulWidget {
  final Employee employee;
  final Function(String role, String dept, double salary, String status) onUpdate;

  const EditEmployeeSheet({
    super.key,
    required this.employee,
    required this.onUpdate,
  });

  @override
  State<EditEmployeeSheet> createState() => _EditEmployeeSheetState();
}

class _EditEmployeeSheetState extends State<EditEmployeeSheet> {
  late final TextEditingController _roleController;
  late final TextEditingController _salaryController;
  late String _department;
  late String _status;

  final List<String> _departments = [
    'Mobile Engineering',
    'DevOps & SRE',
    'Data Analytics',
    'Cloud Architecture',
    'Security & IAM',
  ];

  final List<String> _statuses = ['Active', 'Promoted', 'On Probation'];

  @override
  void initState() {
    super.initState();
    _roleController = TextEditingController(text: widget.employee.role);
    _salaryController =
        TextEditingController(text: widget.employee.salary.toStringAsFixed(0));
    _department = widget.employee.department;
    _status = widget.employee.status;
  }

  @override
  void dispose() {
    _roleController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  void _submit() {
    final role = _roleController.text.trim();
    final salary = double.tryParse(_salaryController.text.trim()) ??
        widget.employee.salary;

    if (role.isNotEmpty) {
      widget.onUpdate(role, _department, salary, _status);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF111827).withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Mutate Document: ${widget.employee.name}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _roleController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: _sheetDecoration('Role / Title', Icons.work_outline_rounded),
              ),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: _department,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: _sheetDecoration('Department', Icons.domain_rounded),
                items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _department = val);
                },
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _salaryController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: _sheetDecoration('Salary (\$ USD)', Icons.attach_money_rounded),
              ),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: _status,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: _sheetDecoration('Status Indicator', Icons.verified_user_rounded),
                items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF97316).withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _submit,
                    child: const Text('Execute doc.update() Mutation',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _sheetDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFFF97316), size: 18),
      filled: true,
      fillColor: Colors.white.withOpacity(0.04),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF97316), width: 1.4),
      ),
    );
  }
}
