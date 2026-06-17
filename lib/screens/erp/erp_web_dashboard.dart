import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════
// COSARC ERP - COMPLETE WEB DASHBOARD
// Premium, Minimalistic, Apple-inspired UI
// Single file - just run it!
// ═══════════════════════════════════════════════════════════════

void main() {
  runApp(const CosarcERPApp());
}

class CosarcERPApp extends StatelessWidget {
  const CosarcERPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'COSARC ERP',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home: const ERPDashboard(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MAIN DASHBOARD LAYOUT
// ═══════════════════════════════════════════════════════════════

class ERPDashboard extends StatefulWidget {
  const ERPDashboard({super.key});

  @override
  State<ERPDashboard> createState() => _ERPDashboardState();
}

class _ERPDashboardState extends State<ERPDashboard> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(Icons.dashboard_outlined, 'Dashboard'),
    _NavItem(Icons.people_outline, 'Members'),
    _NavItem(Icons.access_time, 'Attendance'),
    _NavItem(Icons.payment, 'Payments'),
    _NavItem(Icons.calendar_today, 'Classes'),
    _NavItem(Icons.badge_outlined, 'Staff'),
    _NavItem(Icons.bar_chart, 'Reports'),
    _NavItem(Icons.settings_outlined, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // SIDEBAR
          _buildSidebar(),
          
          // MAIN CONTENT
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _getScreen()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F0F),
        border: Border(right: BorderSide(color: Color(0xFF1A1A1A))),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            height: 80,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.fitness_center, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                const Text(
                  'cosarc',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(color: Color(0xFF1A1A1A), height: 1),
          
          const SizedBox(height: 8),
          
          // Navigation
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = _selectedIndex == index;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => _selectedIndex = index),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF7C3AED).withOpacity(0.15) : null,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFF6B7280),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item.label,
                              style: TextStyle(
                                color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFF9CA3AF),
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // User Profile
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1A1A1A)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF7C3AED),
                  child: Text('RK', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Rajesh Kumar',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Owner',
                        style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.more_vert, size: 18, color: Colors.white.withOpacity(0.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F0F),
        border: Border(bottom: BorderSide(color: Color(0xFF1A1A1A))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(
            _navItems[_selectedIndex].label,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.5),
          ),
          const Spacer(),
          
          // Search
          Container(
            width: 320,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1A1A1A)),
            ),
            child: const TextField(
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search members, payments...',
                hintStyle: TextStyle(color: Color(0xFF6B7280)),
                prefixIcon: Icon(Icons.search, color: Color(0xFF6B7280), size: 18),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Notifications
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, size: 22),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _getScreen() {
    switch (_selectedIndex) {
      case 0: return const DashboardHome();
      case 1: return const MembersScreen();
      case 2: return const AttendanceScreen();
      case 3: return const PaymentsScreen();
      default: return Center(
        child: Text(
          '${_navItems[_selectedIndex].label} - Coming Soon',
          style: const TextStyle(fontSize: 18, color: Color(0xFF6B7280)),
        ),
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// DASHBOARD HOME
// ═══════════════════════════════════════════════════════════════

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          const Row(
            children: [
              Expanded(child: _StatCard(
                title: 'Active Members',
                value: '234',
                icon: Icons.people,
                color: Color(0xFF7C3AED),
                change: '+12 this month',
              )),
              SizedBox(width: 16),
              Expanded(child: _StatCard(
                title: 'Revenue Today',
                value: '₹45,600',
                icon: Icons.account_balance_wallet,
                color: Color(0xFF10B981),
                change: '+8 payments',
              )),
              SizedBox(width: 16),
              Expanded(child: _StatCard(
                title: 'Check-ins Today',
                value: '87',
                icon: Icons.login,
                color: Color(0xFF3B82F6),
                change: '65% capacity',
              )),
              SizedBox(width: 16),
              Expanded(child: _StatCard(
                title: 'Expiring Soon',
                value: '18',
                icon: Icons.warning_amber,
                color: Color(0xFFF59E0B),
                change: 'Next 7 days',
              )),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Live Status
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1A1A1A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('LIVE', style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEF4444),
                      letterSpacing: 1,
                    )),
                    const SizedBox(width: 16),
                    const Text('Members Inside Gym', style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    )),
                    const Spacer(),
                    const Text('23 / 80', style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7C3AED),
                      letterSpacing: -1,
                    )),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const LinearProgressIndicator(
                    value: 0.29,
                    minHeight: 12,
                    backgroundColor: Color(0xFF141414),
                    valueColor: AlwaysStoppedAnimation(Color(0xFF7C3AED)),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('29% capacity', style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                )),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recent Activity
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F0F),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1A1A1A)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recent Activity', style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      )),
                      SizedBox(height: 16),
                      _ActivityItem(
                        icon: Icons.login,
                        color: Color(0xFF10B981),
                        title: 'Rajesh Kumar checked in',
                        time: '2 mins ago',
                      ),
                      _ActivityItem(
                        icon: Icons.payment,
                        color: Color(0xFF3B82F6),
                        title: 'Priya Singh paid ₹2,500',
                        time: '5 mins ago',
                      ),
                      _ActivityItem(
                        icon: Icons.person_add,
                        color: Color(0xFF7C3AED),
                        title: 'New member: Amit Sharma',
                        time: '12 mins ago',
                      ),
                      _ActivityItem(
                        icon: Icons.logout,
                        color: Color(0xFF6B7280),
                        title: 'Neha Gupta checked out',
                        time: '15 mins ago',
                      ),
                      _ActivityItem(
                        icon: Icons.calendar_today,
                        color: Color(0xFFF59E0B),
                        title: 'Yoga class booked by 12 members',
                        time: '28 mins ago',
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Quick Actions
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F0F),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1A1A1A)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quick Actions', style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      )),
                      SizedBox(height: 16),
                      _QuickAction(Icons.person_add, 'New Member', Color(0xFF7C3AED)),
                      SizedBox(height: 12),
                      _QuickAction(Icons.qr_code_scanner, 'Mark Attendance', Color(0xFF10B981)),
                      SizedBox(height: 12),
                      _QuickAction(Icons.payment, 'Collect Payment', Color(0xFF3B82F6)),
                      SizedBox(height: 12),
                      _QuickAction(Icons.assessment, 'View Reports', Color(0xFFF59E0B)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MEMBERS SCREEN
// ═══════════════════════════════════════════════════════════════

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final members = [
      {'id': 'GYM001', 'name': 'Rajesh Kumar', 'phone': '+91 98765 43210', 'plan': 'Yearly', 'status': 'Active', 'expiry': '15 Feb 2026', 'visits': 45},
      {'id': 'GYM002', 'name': 'Priya Singh', 'phone': '+91 98765 43211', 'plan': 'Monthly', 'status': 'Active', 'expiry': '10 Apr 2025', 'visits': 18},
      {'id': 'GYM003', 'name': 'Amit Sharma', 'phone': '+91 98765 43212', 'plan': 'Quarterly', 'status': 'Expiring', 'expiry': '12 Mar 2025', 'visits': 32},
      {'id': 'GYM004', 'name': 'Neha Gupta', 'phone': '+91 98765 43213', 'plan': 'Monthly', 'status': 'Expired', 'expiry': '01 Mar 2025', 'visits': 8},
      {'id': 'GYM005', 'name': 'Vikram Malhotra', 'phone': '+91 98765 43214', 'plan': 'Yearly', 'status': 'Active', 'expiry': '20 Jan 2026', 'visits': 67},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Expanded(child: _SearchBar()),
              const SizedBox(width: 16),
              const _FilterChip('All', true),
              const _FilterChip('Active', false),
              const _FilterChip('Expiring', false),
              const _FilterChip('Expired', false),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Member', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Stats
          const Row(
            children: [
              Expanded(child: _MiniStat('234', 'Total', Color(0xFF7C3AED))),
              SizedBox(width: 12),
              Expanded(child: _MiniStat('198', 'Active', Color(0xFF10B981))),
              SizedBox(width: 12),
              Expanded(child: _MiniStat('18', 'Expiring', Color(0xFFF59E0B))),
              SizedBox(width: 12),
              Expanded(child: _MiniStat('18', 'Expired', Color(0xFFEF4444))),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Table
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1A1A1A)),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF1A1A1A))),
                  ),
                  child: const Row(
                    children: [
                      Expanded(flex: 2, child: _TableHeader('MEMBER')),
                      Expanded(flex: 2, child: _TableHeader('CONTACT')),
                      Expanded(child: _TableHeader('PLAN')),
                      Expanded(child: _TableHeader('STATUS')),
                      Expanded(child: _TableHeader('EXPIRY')),
                      Expanded(child: _TableHeader('VISITS')),
                      SizedBox(width: 100, child: _TableHeader('ACTIONS')),
                    ],
                  ),
                ),
                
                // Rows
                ...members.map((m) => _MemberRow(m)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ATTENDANCE SCREEN
// ═══════════════════════════════════════════════════════════════

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = [
      {'name': 'Rajesh Kumar', 'id': 'GYM001', 'time': '06:45 AM', 'duration': 'Active', 'status': 'in'},
      {'name': 'Priya Singh', 'id': 'GYM002', 'time': '07:12 AM', 'duration': 'Active', 'status': 'in'},
      {'name': 'Amit Sharma', 'id': 'GYM003', 'time': '05:30 AM', 'duration': '2h 15m', 'status': 'out'},
      {'name': 'Neha Gupta', 'id': 'GYM004', 'time': '06:00 AM', 'duration': '1h 45m', 'status': 'out'},
      {'name': 'Vikram Malhotra', 'id': 'GYM005', 'time': '07:30 AM', 'duration': 'Active', 'status': 'in'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Stats
          const Row(
            children: [
              Expanded(child: _StatCard(
                title: 'Inside Now',
                value: '23',
                icon: Icons.people,
                color: Color(0xFF7C3AED),
              )),
              SizedBox(width: 16),
              Expanded(child: _StatCard(
                title: 'Check-ins Today',
                value: '87',
                icon: Icons.login,
                color: Color(0xFF10B981),
              )),
              SizedBox(width: 16),
              Expanded(child: _StatCard(
                title: 'Check-outs Today',
                value: '64',
                icon: Icons.logout,
                color: Color(0xFF3B82F6),
              )),
              SizedBox(width: 16),
              Expanded(child: _StatCard(
                title: 'Avg Duration',
                value: '1.8h',
                icon: Icons.access_time,
                color: Color(0xFFF59E0B),
              )),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // QR Scanner Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.qr_code_scanner, size: 24),
              label: const Text('SCAN QR CODE TO CHECK-IN', style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              )),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Logs Table
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1A1A1A)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF1A1A1A))),
                  ),
                  child: const Row(
                    children: [
                      Expanded(flex: 2, child: _TableHeader('MEMBER')),
                      Expanded(child: _TableHeader('CHECK-IN')),
                      Expanded(child: _TableHeader('DURATION')),
                      Expanded(child: _TableHeader('STATUS')),
                    ],
                  ),
                ),
                ...logs.map((log) => _AttendanceRow(log)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PAYMENTS SCREEN
// ═══════════════════════════════════════════════════════════════

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final payments = [
      {'name': 'Priya Singh', 'id': 'GYM002', 'amount': '₹2,500', 'type': 'Monthly', 'method': 'UPI', 'date': 'Today, 10:30 AM', 'status': 'Completed'},
      {'name': 'Amit Sharma', 'id': 'GYM003', 'amount': '₹4,500', 'type': 'Quarterly', 'method': 'Card', 'date': 'Today, 09:15 AM', 'status': 'Completed'},
      {'name': 'Rajesh Kumar', 'id': 'GYM001', 'amount': '₹15,000', 'type': 'Yearly', 'method': 'Cash', 'date': 'Yesterday, 06:45 PM', 'status': 'Completed'},
      {'name': 'Neha Gupta', 'id': 'GYM004', 'amount': '₹2,500', 'type': 'Monthly', 'method': 'UPI', 'date': '2 days ago', 'status': 'Pending'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Stats
          const Row(
            children: [
              Expanded(child: _StatCard(
                title: 'Today\'s Revenue',
                value: '₹45,600',
                icon: Icons.account_balance_wallet,
                color: Color(0xFF10B981),
                change: '+8 payments',
              )),
              SizedBox(width: 16),
              Expanded(child: _StatCard(
                title: 'This Month',
                value: '₹3,45,000',
                icon: Icons.trending_up,
                color: Color(0xFF7C3AED),
                change: '+18% vs last month',
              )),
              SizedBox(width: 16),
              Expanded(child: _StatCard(
                title: 'Pending Dues',
                value: '₹28,500',
                icon: Icons.warning_amber,
                color: Color(0xFFF59E0B),
                change: '12 members',
              )),
              SizedBox(width: 16),
              Expanded(child: _StatCard(
                title: 'Renewals Due',
                value: '18',
                icon: Icons.refresh,
                color: Color(0xFF3B82F6),
                change: 'Next 7 days',
              )),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Table
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1A1A1A)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF1A1A1A))),
                  ),
                  child: const Row(
                    children: [
                      Expanded(flex: 2, child: _TableHeader('MEMBER')),
                      Expanded(child: _TableHeader('AMOUNT')),
                      Expanded(child: _TableHeader('TYPE')),
                      Expanded(child: _TableHeader('METHOD')),
                      Expanded(flex: 2, child: _TableHeader('DATE & TIME')),
                      Expanded(child: _TableHeader('STATUS')),
                      SizedBox(width: 80, child: _TableHeader('RECEIPT')),
                    ],
                  ),
                ),
                ...payments.map((p) => _PaymentRow(p)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// REUSABLE WIDGETS
// ═══════════════════════════════════════════════════════════════

class _NavItem {
  final IconData icon;
  final String label;
  _NavItem(this.icon, this.label);
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? change;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.change,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1A1A1A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 16),
          Text(value, style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: -1,
          )),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          )),
          if (change != null) ...[
            const SizedBox(height: 8),
            Text(change!, style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF4B5563),
            )),
          ],
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(time, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickAction(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1A1A1A)),
      ),
      child: const TextField(
        style: TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search by name, phone, or ID...',
          hintStyle: TextStyle(color: Color(0xFF6B7280)),
          prefixIcon: Icon(Icons.search, color: Color(0xFF6B7280), size: 18),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _FilterChip(this.label, this.selected);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF7C3AED).withOpacity(0.1) : const Color(0xFF141414),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: selected ? const Color(0xFF7C3AED) : const Color(0xFF1A1A1A)),
      ),
      child: Text(label, style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: selected ? const Color(0xFF7C3AED) : const Color(0xFF6B7280),
      )),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _MiniStat(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1A1A1A)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: Color(0xFF6B7280),
      letterSpacing: 0.5,
    ));
  }
}

class _MemberRow extends StatelessWidget {
  final Map<String, dynamic> member;
  const _MemberRow(this.member);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF1A1A1A))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF7C3AED),
                  child: Text(member['name'][0], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(member['id'], style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  ],
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(member['phone'], style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)))),
          Expanded(child: _Badge(member['plan'], const Color(0xFF3B82F6))),
          Expanded(child: _StatusDot(member['status'])),
          Expanded(child: Text(member['expiry'], style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)))),
          Expanded(child: Text('${member['visits']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.visibility_outlined, size: 16, color: Color(0xFF6B7280)), onPressed: () {}),
                IconButton(icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF6B7280)), onPressed: () {}),
                IconButton(icon: const Icon(Icons.more_vert, size: 16, color: Color(0xFF6B7280)), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  final Map<String, dynamic> log;
  const _AttendanceRow(this.log);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF1A1A1A))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF7C3AED),
                  child: Text(log['name'][0], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(log['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(log['id'], style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: Text(log['time'], style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)))),
          Expanded(child: Text(log['duration'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          Expanded(child: log['status'] == 'in' 
            ? const _Badge('Inside', Color(0xFF10B981))
            : const _Badge('Checked Out', Color(0xFF6B7280))
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final Map<String, dynamic> payment;
  const _PaymentRow(this.payment);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF1A1A1A))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF7C3AED),
                  child: Text(payment['name'][0], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(payment['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(payment['id'], style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: Text(payment['amount'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF10B981)))),
          Expanded(child: _Badge(payment['type'], const Color(0xFF3B82F6))),
          Expanded(child: _Badge(payment['method'], const Color(0xFF7C3AED))),
          Expanded(flex: 2, child: Text(payment['date'], style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)))),
          Expanded(child: payment['status'] == 'Completed' 
            ? const _Badge('Completed', Color(0xFF10B981))
            : const _Badge('Pending', Color(0xFFF59E0B))
          ),
          SizedBox(
            width: 80,
            child: TextButton(
              onPressed: () {},
              child: const Text('Download', style: TextStyle(fontSize: 12, color: Color(0xFF7C3AED))),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final String status;
  const _StatusDot(this.status);

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Active': color = const Color(0xFF10B981); break;
      case 'Expiring': color = const Color(0xFFF59E0B); break;
      case 'Expired': color = const Color(0xFFEF4444); break;
      default: color = const Color(0xFF6B7280);
    }
    
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}