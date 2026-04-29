import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.android;
  runApp(const AppointmentApp());
}

class AppointmentApp extends StatelessWidget {
  const AppointmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D5AFE)),
      ),
      home: const LoginScreen(),
    );
  }
}

//////////////////// LOGIN ////////////////////
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("LOGIN", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3D5AFE))),
              const SizedBox(height: 20),
              const TextField(decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder())),
              const SizedBox(height: 12),
              const TextField(obscureText: true, decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder())),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3D5AFE), foregroundColor: Colors.white),
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen())),
                  child: const Text("Sign In"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//////////////////// MAIN NAVIGATION CONTROLLER ////////////////////
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;
  List<Map<String, String>> appointments = [];
  List<Map<String, String>> chatMessages = [];

  final Map<String, List<Map<String, String>>> doctorDatabase = {
    "Doctors": [
      {"name": "Dr. Albert Smith", "hospital": "St. Luke's"},
      {"name": "Dr. Sarah Jenkins", "hospital": "Makati Med"},
      {"name": "Dr. Kevin Vang", "hospital": "Medical City"},
      {"name": "Dr. Maria Cruz", "hospital": "PGH"},
    ],
    "Dentist": [
      {"name": "Dr. Helen Tan", "hospital": "Dental First"},
      {"name": "Dr. Robert Lim", "hospital": "Smile Clinic"},
      {"name": "Dr. Grace Sy", "hospital": "White Teeth Hub"},
      {"name": "Dr. Paolo Reyes", "hospital": "City Dental"},
    ],
    "Cardiologist": [
      {"name": "Dr. Sam Goku", "hospital": "Heart Center"},
      {"name": "Dr. Victor Doom", "hospital": "Medical City"},
      {"name": "Dr. Jane Foster", "hospital": "St. Luke's"},
      {"name": "Dr. Bruce Banner", "hospital": "Gamma Health"},
    ],
    "Orthopedic": [
      {"name": "Dr. Logan Howlett", "hospital": "X-Clinic"},
      {"name": "Dr. Stephen Strange", "hospital": "Metro North"},
      {"name": "Dr. Peter Parker", "hospital": "Queens Medical"},
      {"name": "Dr. Diana Prince", "hospital": "Themis Center"},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        doctorDatabase: doctorDatabase,
        onBook: (doc) {
          setState(() {
            appointments.add(doc);
            chatMessages.insert(0, {
              "id": DateTime.now().millisecondsSinceEpoch.toString(),
              "sender": doc['name']!,
              "text": "Hello! This is an automated confirmation for your booking at ${doc['hospital']}. See you soon!",
              "time": "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}"
            });
          });
        },
      ),
      MessagesScreen(
        messages: chatMessages,
        onArchive: (id) {
          setState(() => chatMessages.removeWhere((m) => m['id'] == id));
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Message archived")));
        },
        onDelete: (id) => setState(() => chatMessages.removeWhere((m) => m['id'] == id)),
      ),
      AppointmentsScreen(
        appointments: appointments,
        onCancel: (idx) => setState(() => appointments.removeAt(idx)),
      ),
      const AccountScreen()
    ];

    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: "Home"),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: "Messages"),
          NavigationDestination(icon: Icon(Icons.calendar_today_outlined), label: "My Bookings"),
          NavigationDestination(icon: Icon(Icons.person_outline), label: "Account"),
        ],
      ),
    );
  }
}

//////////////////// HOME SCREEN ////////////////////
class HomeScreen extends StatefulWidget {
  final Map<String, List<Map<String, String>>> doctorDatabase;
  final Function(Map<String, String>) onBook;

  const HomeScreen({super.key, required this.doctorDatabase, required this.onBook});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = "";

  final List<Map<String, String>> hospitalData = [
    {"name": "St. Luke's", "logo": "https://upload.wikimedia.org/wikipedia/en/2/23/St._Luke%27s_Medical_Center_logo.png"},
    {"name": "Makati Med", "logo": "https://www.makatimed.net.ph/wp-content/uploads/2021/05/MMC-Logo.png"},
    {"name": "Medical City", "logo": "https://upload.wikimedia.org/wikipedia/commons/4/4b/The_Medical_City_Logo.png"},
    {"name": "PGH", "logo": "https://upload.wikimedia.org/wikipedia/en/thumb/f/f6/UP-PGH_Logo.png/220px-UP-PGH_Logo.png"},
    {"name": "Asian Hospital", "logo": "https://logo.clearbit.com/asianhospital.com"},
    {"name": "Cardinal Santos", "logo": "https://logo.clearbit.com/cardinalsantos.com.ph"},
    {"name": "Manila Doctors", "logo": "https://logo.clearbit.com/maniladoctors.com.ph"},
    {"name": "Chong Hua", "logo": "https://logo.clearbit.com/chonghua.com.ph"},
  ];

  Widget categoryIcon(BuildContext context, IconData icon, String label) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorListScreen(
              category: label,
              doctors: widget.doctorDatabase[label]!,
              onBook: widget.onBook,
            ),
          ),
        );
      },
      child: Column(
        children: [
          CircleAvatar(radius: 25, backgroundColor: Colors.blue[50], child: Icon(icon, color: const Color(0xFF3D5AFE))),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3D5AFE), fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredHospitals = hospitalData
        .where((h) => h['name']!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Appointment.com", style: TextStyle(color: Color(0xFF3D5AFE), fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column( 
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                onChanged: (value) => setState(() => searchQuery = value),
                decoration: InputDecoration(
                  hintText: "Search popular hospitals...",
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF3D5AFE)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  categoryIcon(context, Icons.person, "Doctors"),
                  categoryIcon(context, Icons.medical_services, "Dentist"),
                  categoryIcon(context, Icons.favorite, "Cardiologist"),
                  categoryIcon(context, Icons.healing, "Orthopedic"),
                ],
              ),
              const SizedBox(height: 30),
              const Text("Popular Hospitals", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3D5AFE))),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredHospitals.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, 
                  mainAxisSpacing: 10, 
                  crossAxisSpacing: 10
                ),
                itemBuilder: (context, i) => Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                  ),
                  child: Image.network(
                    filteredHospitals[i]['logo']!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.local_hospital, color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//////////////////// DOCTOR LIST SCREEN ////////////////////
class DoctorListScreen extends StatelessWidget {
  final String category;
  final List<Map<String, String>> doctors;
  final Function(Map<String, String>) onBook;

  const DoctorListScreen({super.key, required this.category, required this.doctors, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select $category")),
      body: ListView.builder(
        itemCount: doctors.length,
        itemBuilder: (context, i) => Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(doctors[i]['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(doctors[i]['hospital']!),
            trailing: ElevatedButton(
              onPressed: () {
                onBook(doctors[i]);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Booked ${doctors[i]['name']}")));
              },
              child: const Text("Book"),
            ),
          ),
        ),
      ),
    );
  }
}

//////////////////// BOOKINGS SCREEN ////////////////////
class AppointmentsScreen extends StatefulWidget {
  final List<Map<String, String>> appointments;
  final Function(int) onCancel;
  const AppointmentsScreen({super.key, required this.appointments, required this.onCancel});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    final filtered = widget.appointments.where((a) => 
      a['name']!.toLowerCase().contains(query.toLowerCase()) || 
      a['hospital']!.toLowerCase().contains(query.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (v) => setState(() => query = v),
              decoration: InputDecoration(
                hintText: "Search bookings...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: filtered.isEmpty
          ? const Center(child: Text("No bookings found."))
          : ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (ctx, i) => ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(filtered[i]['name']!),
                subtitle: Text("Confirmed at ${filtered[i]['hospital']}"),
                trailing: TextButton(
                  onPressed: () {
                    int originalIndex = widget.appointments.indexOf(filtered[i]);
                    widget.onCancel(originalIndex);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Appointment Cancelled")));
                  },
                  child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                ),
              ),
            ),
    );
  }
}

//////////////////// MESSAGES SCREEN ////////////////////
class MessagesScreen extends StatefulWidget { 
  final List<Map<String, String>> messages;
  final Function(String) onArchive;
  final Function(String) onDelete;

  const MessagesScreen({super.key, required this.messages, required this.onArchive, required this.onDelete});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String query = "";

  void _showReplyDialog(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Reply to $name"),
        content: const TextField(decoration: InputDecoration(hintText: "Type your message...")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Send")),
        ],
      ),
    );
  }

  @override 
  Widget build(BuildContext context) {
    final filtered = widget.messages.where((m) => 
      m['sender']!.toLowerCase().contains(query.toLowerCase()) || 
      m['text']!.toLowerCase().contains(query.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (v) => setState(() => query = v),
              decoration: InputDecoration(
                hintText: "Search messages...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ), 
      body: filtered.isEmpty 
        ? const Center(child: Text("No Messages found"))
        : ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, i) {
              final msg = filtered[i];
              return Dismissible(
                key: Key(msg['id']!),
                background: Container(
                  color: Colors.orange,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.archive, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  if (direction == DismissDirection.startToEnd) {
                    widget.onArchive(msg['id']!);
                  } else {
                    widget.onDelete(msg['id']!);
                  }
                },
                child: ListTile(
                  leading: CircleAvatar(child: Text(msg['sender']![4])),
                  title: Text(msg['sender']!),
                  subtitle: Text(msg['text']!),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(msg['time']!, style: const TextStyle(fontSize: 10)),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _showReplyDialog(context, msg['sender']!),
                        child: const Icon(Icons.reply, size: 20, color: Color(0xFF3D5AFE)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}

//////////////////// ACCOUNT SCREEN ////////////////////
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String userName = "John Doe";
  String userEmail = "john.doe@example.com";
  bool notificationsEnabled = true;

  void _showEditProfile() {
    TextEditingController nameController = TextEditingController(text: userName);
    TextEditingController emailController = TextEditingController(text: userEmail);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Full Name")),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              setState(() {
                userName = nameController.text;
                userEmail = emailController.text;
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated")));
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showChangePassword() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Change Password"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(obscureText: true, decoration: InputDecoration(labelText: "Current Password")),
            TextField(obscureText: true, decoration: InputDecoration(labelText: "New Password")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password Changed Successfully")));
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _showSimpleInfo(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Account"), elevation: 0),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF3D5AFE),
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text(userEmail, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildSectionTitle("General Settings"),
          _buildAccountTile(Icons.person_outline, "Edit Profile", _showEditProfile),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_none, color: Colors.black87),
            title: const Text("Notifications"),
            value: notificationsEnabled,
            activeColor: const Color(0xFF3D5AFE),
            onChanged: (val) => setState(() => notificationsEnabled = val),
          ),
          _buildAccountTile(Icons.lock_outline, "Security & Password", _showChangePassword),
          _buildAccountTile(Icons.language, "Language", () => _showSimpleInfo("Language", "English (US) is currently selected.")),
          
          const Divider(height: 40),
          
          _buildSectionTitle("Support"),
          _buildAccountTile(Icons.help_outline, "Help Center", () => _showSimpleInfo("Help", "Contact support@appointment.com for assistance.")),
          _buildAccountTile(Icons.privacy_tip_outlined, "Privacy Policy", () => _showSimpleInfo("Privacy", "Your data is secured with end-to-end encryption.")),
          
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.all(16),
              ),
              onPressed: () => Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (_) => const LoginScreen())
              ),
              child: const Text("Log Out"),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF3D5AFE))),
    );
  }

  Widget _buildAccountTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

