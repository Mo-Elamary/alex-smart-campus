import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.user,
    required this.dark,
    required this.onDarkChanged,
  });
  final User user;
  final bool dark;
  final ValueChanged<bool> onDarkChanged;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      Dashboard(user: widget.user),
      SchedulePage(uid: widget.user.uid),
      const AnnouncementsPage(),
      ProfilePage(
        user: widget.user,
        dark: widget.dark,
        onDarkChanged: widget.onDarkChanged,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          [
            'Alex Smart Campus',
            'My schedule',
            'Campus updates',
            'My profile',
          ][index],
        ),
        centerTitle: false,
      ),
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign),
            label: 'Updates',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class Weather {
  final double temperature, wind;
  Weather(this.temperature, this.wind);
  factory Weather.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    return Weather(
      (current['temperature_2m'] as num).toDouble(),
      (current['wind_speed_10m'] as num).toDouble(),
    );
  }
}

Future<Weather> fetchWeather() async {
  final response = await http
      .get(
        Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=31.2001&longitude=29.9187&current=temperature_2m,wind_speed_10m&timezone=Africa%2FCairo',
        ),
      )
      .timeout(const Duration(seconds: 12));
  if (response.statusCode != 200) throw Exception('Weather unavailable');
  return Weather.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key, required this.user});
  final User user;
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late Future<Weather> weather = fetchWeather();
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.waves_rounded, color: Colors.white, size: 34),
            const SizedBox(height: 20),
            Text(
              'YOUR CAMPUS COMPANION',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .85),
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hello, ${widget.user.email?.split('@').first ?? 'student'}',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Stay organized and connected at Alexandria University.',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      Text(
        'Alexandria today',
        style: Theme.of(context).textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 10),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: FutureBuilder<Weather>(
            future: weather,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weather is unavailable. Check your internet connection.',
                    ),
                    TextButton.icon(
                      onPressed: () => setState(() => weather = fetchWeather()),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Icon(
                    Icons.wb_sunny_outlined,
                    size: 42,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${snapshot.data!.temperature.toStringAsFixed(1)}°C',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Wind ${snapshot.data!.wind.toStringAsFixed(1)} km/h · Open-Meteo',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      const SizedBox(height: 20),
      const Card(
        child: ListTile(
          leading: Icon(Icons.offline_pin_outlined),
          title: Text('Your schedule stays with you'),
          subtitle: Text('Classes are saved on this device and work offline.'),
        ),
      ),
    ],
  );
}

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key, required this.uid});
  final String uid;
  static const days = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];
  Future<void> edit(
    BuildContext context,
    Box box, {
    String? key,
    Map? item,
  }) async {
    final course = TextEditingController(
          text: item?['course'] as String? ?? '',
        ),
        room = TextEditingController(text: item?['room'] as String? ?? '');
    String day = item?['day'] as String? ?? days.first;
    TimeOfDay? time;
    final oldTime = item?['time'] as String?;
    if (oldTime != null) {
      final parts = oldTime.split(':');
      time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    final form = GlobalKey<FormState>();
    final route = DialogRoute<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text(item == null ? 'Add a class' : 'Edit class'),
          content: SingleChildScrollView(
            child: Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: course,
                    decoration: const InputDecoration(labelText: 'Course name'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Enter a course name'
                        : null,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: day,
                    decoration: const InputDecoration(labelText: 'Day'),
                    items: days
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (v) => setDialog(() => day = v!),
                  ),
                  TextFormField(
                    controller: room,
                    decoration: const InputDecoration(labelText: 'Room'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Enter a room' : null,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await showTimePicker(
                        context: ctx,
                        initialTime: time ?? TimeOfDay.now(),
                      );
                      if (result != null) setDialog(() => time = result);
                    },
                    icon: const Icon(Icons.access_time),
                    label: Text(
                      time == null ? 'Choose time' : time!.format(ctx),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!form.currentState!.validate()) return;
                if (time == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please choose a time.')),
                  );
                  return;
                }
                final value = {
                  'uid': uid,
                  'course': course.text.trim(),
                  'room': room.text.trim(),
                  'day': day,
                  'time':
                      '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}',
                };
                await box.put(
                  key ?? '${uid}_${DateTime.now().microsecondsSinceEpoch}',
                  value,
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    await Navigator.of(context).push(route);
    await route.completed;
    course.dispose();
    room.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('schedules');
    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box b, _) {
        final keys = b.keys
            .where((k) => (b.get(k) as Map?)?['uid'] == uid)
            .toList();
        keys.sort((a, z) {
          final x = b.get(a) as Map, y = b.get(z) as Map;
          final d = days.indexOf(x['day']).compareTo(days.indexOf(y['day']));
          return d != 0
              ? d
              : (x['time'] as String).compareTo(y['time'] as String);
        });
        return Stack(
          children: [
            keys.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No classes yet. Add your first class to build your schedule.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                    itemCount: keys.length,
                    itemBuilder: (context, i) {
                      final key = keys[i];
                      final item = b.get(key) as Map;
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            child: Text(
                              (item['course'] as String)
                                  .substring(0, 1)
                                  .toUpperCase(),
                            ),
                          ),
                          title: Text(
                            item['course'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${item['day']} · ${item['time']}\nRoom ${item['room']}',
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (action) async {
                              if (action == 'edit') {
                                await edit(
                                  context,
                                  b,
                                  key: key as String,
                                  item: item,
                                );
                              } else {
                                await b.delete(key);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            Positioned(
              bottom: 18,
              right: 18,
              child: FloatingActionButton.extended(
                onPressed: () => edit(context, b),
                icon: const Icon(Icons.add),
                label: const Text('Add class'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class AnnouncementsPage extends StatelessWidget {
  const AnnouncementsPage({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<DatabaseEvent>(
    stream: FirebaseDatabase.instance.ref('announcements').onValue,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Center(
          child: Text('Could not load announcements. Check your connection.'),
        );
      }
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final raw = snapshot.data!.snapshot.value;
      if (raw is! Map || raw.isEmpty) {
        return const Center(child: Text('No announcements yet.'));
      }
      final items = raw.values.whereType<Map>().toList();
      items.sort(
        (a, b) => ((b['timestamp'] as num?) ?? 0).compareTo(
          (a['timestamp'] as num?) ?? 0,
        ),
      );
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final timestamp = item['timestamp'];
          final date = timestamp is num
              ? DateFormat('d MMM yyyy · h:mm a').format(
                  DateTime.fromMillisecondsSinceEpoch(timestamp.toInt())
                      .toLocal(),
                )
              : '';
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.campaign_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${item['title'] ?? 'Announcement'}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('${item['body'] ?? ''}'),
                  if (date.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(date, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.user,
    required this.dark,
    required this.onDarkChanged,
  });
  final User user;
  final bool dark;
  final ValueChanged<bool> onDarkChanged;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> edit(Map<String, dynamic> data) async {
    final name = TextEditingController(text: data['name'] as String? ?? '');
    final photo = TextEditingController(
      text: data['photoUrl'] as String? ?? '',
    );
    final form = GlobalKey<FormState>();
    final route = DialogRoute<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit profile'),
        content: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter your name' : null,
                ),
                TextFormField(
                  controller: photo,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Photo URL (optional)',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final uri = Uri.tryParse(v.trim());
                    return uri == null ||
                            !['http', 'https'].contains(uri.scheme) ||
                            uri.host.isEmpty
                        ? 'Enter a valid HTTP or HTTPS URL'
                        : null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!form.currentState!.validate()) return;
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.user.uid)
                    .set({
                      'name': name.text.trim(),
                      'photoUrl': photo.text.trim(),
                    }, SetOptions(merge: true));
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (_) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('Could not save your profile. Try again.'),
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    await Navigator.of(context).push(route);
    await route.completed;
    name.dispose();
    photo.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load your profile.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data() ?? {};
          final name = (data['name'] as String?)?.trim() ?? '';
          final url = (data['photoUrl'] as String?)?.trim() ?? '';
          final initials = name.isEmpty
              ? '?'
              : name
                    .split(RegExp(r'\s+'))
                    .take(2)
                    .map((s) => s[0].toUpperCase())
                    .join();
          Widget fallback() => CircleAvatar(
            radius: 42,
            child: Text(initials, style: const TextStyle(fontSize: 26)),
          );
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 16),
              Center(
                child: url.isEmpty
                    ? fallback()
                    : ClipOval(
                        child: Image.network(
                          url,
                          width: 84,
                          height: 84,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => fallback(),
                          loadingBuilder: (context, child, progress) =>
                              progress == null ? child : fallback(),
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                name.isEmpty ? 'Student' : name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(widget.user.email ?? '', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton.tonalIcon(
                onPressed: () => edit(data),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit profile'),
              ),
              const SizedBox(height: 16),
              Card(
                child: SwitchListTile(
                  value: widget.dark,
                  onChanged: widget.onDarkChanged,
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark mode'),
                  subtitle: const Text('Saved on this device'),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => FirebaseAuth.instance.signOut(),
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
              ),
            ],
          );
        },
      );
}
