import 'dart:async';
import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClockWidget extends StatefulWidget {
  final bool isDesktop;
  const ClockWidget({super.key, this.isDesktop = true});

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  late Timer _timer;
  late DateTime _currentTime;
  String _location = "DHAKA - BANGLADESH"; // Default fallback location

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
    _loadCachedLocation();
    _fetchLocation();
  }

  void _loadCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_location');
      if (cached != null && mounted) {
        setState(() {
          _location = cached;
        });
      }
    } catch (_) {}
  }

  void _updateLocation(String newLocation) async {
    if (mounted) {
      setState(() {
        _location = newLocation;
      });
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_location', newLocation);
    } catch (_) {}
  }

  Future<void> _fetchLocation() async {
    // Immediately show visual loading feedback if we don't have a cached location yet
    if (_location == "DHAKA - BANGLADESH" && mounted) {
      setState(() {
        _location = "DETECTING LOCATION...";
      });
    }

    // 1. Try to get physical GPS / Browser / OS location (Supported on Mobile, Web, and Windows!)
    try {
      await _fetchGPSLocation().timeout(kIsWeb ? const Duration(seconds: 15) : const Duration(seconds: 8));
    } catch (e) {
      debugPrint("GPS location timed out or failed: $e");
    }

    if (_location != "DHAKA - BANGLADESH" && _location != "DETECTING LOCATION...") {
      return; // GPS / Browser successfully got the actual local city!
    }

    // 2. Fallback to free geocoding HTTPS IP APIs (Very reliable on Desktop / Windows)
    final List<String> apis = [
      'https://freeipapi.com/api/json',
      'https://ipwho.is/',
      'https://ipapi.co/json/'
    ];

    for (String url in apis) {
      try {
        final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 3));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          String? city;
          String? country;

          if (url.contains('freeipapi.com')) {
            city = data['cityName'];
            country = data['countryName'];
          } else if (url.contains('ipwho.is')) {
            if (data['success'] == true) {
              city = data['city'];
              country = data['country'];
            }
          } else if (url.contains('ipapi.co')) {
            city = data['city'];
            country = data['country_name'];
          }

          if (city != null && city.toString().isNotEmpty && 
              country != null && country.toString().isNotEmpty) {
            _updateLocation("${city.toString().toUpperCase()} - ${country.toString().toUpperCase()}");
            return; // Successfully got location, exit
          }
        }
      } catch (e) {
        debugPrint("Location API fetch failed for $url: $e");
      }
    }

    // 3. Fallback: Use timezone database if all network APIs fail
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      final String tz = tzInfo.identifier; // e.g. "Asia/Dhaka" or "Europe/London"
      final parts = tz.split('/');
      if (parts.length > 1 && mounted) {
        final String city = parts[1].replaceAll('_', ' ').toUpperCase();
        String countrySuffix = "BANGLADESH"; // default fallback
        
        if (tz.toLowerCase().contains("dhaka")) {
          countrySuffix = "BANGLADESH";
        } else if (parts[0].toLowerCase() == "europe") {
          countrySuffix = "EUROPE";
        } else if (parts[0].toLowerCase() == "america") {
          countrySuffix = "USA";
        } else {
          countrySuffix = parts[0].toUpperCase();
        }

        _updateLocation("$city - $countrySuffix");
      }
    } catch (_) {}

    // Fallback if all methods fail and it's still stuck on "DETECTING LOCATION..."
    if (_location == "DETECTING LOCATION..." && mounted) {
      setState(() {
        _location = "DHAKA - BANGLADESH";
      });
    }
  }

  Future<void> _fetchGPSLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      if (permission == LocationPermission.deniedForever) return;

      Position? position;
      if (!kIsWeb) {
        try {
          position = await Geolocator.getLastKnownPosition();
        } catch (_) {}
      }
      position ??= await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: kIsWeb ? const Duration(seconds: 10) : const Duration(seconds: 5),
      );

      final String url = 'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=${position.latitude}&longitude=${position.longitude}&localityLanguage=en';
      
      try {
        final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 3));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          String? city = data['city'] ?? data['locality'] ?? data['principalSubdivision'];
          String? country = data['countryName'];
          if (city != null && city.toString().isNotEmpty && 
              country != null && country.toString().isNotEmpty) {
            _updateLocation("${city.toString().toUpperCase()} - ${country.toString().toUpperCase()}");
            return;
          }
        }
      } catch (e) {
        debugPrint("BigDataCloud Geocoding failed: $e");
      }

      final String fallbackUrl = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=10&addressdetails=1';
      final response = await http.get(
        Uri.parse(fallbackUrl),
        headers: kIsWeb ? {} : {
          'User-Agent': 'MessManagerApp/1.0 (contact@messmanager.com)',
        },
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'];
        if (address != null) {
          String? city = address['city'] ?? address['town'] ?? address['village'] ?? address['suburb'] ?? address['county'] ?? address['state'];
          String? country = address['country'];
          if (city != null && country != null) {
            _updateLocation("${city.toString().toUpperCase()} - ${country.toString().toUpperCase()}");
          }
        }
      }
    } catch (e) {
      debugPrint("GPS Geolocation query failed: $e");
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Widget _buildDesktopClock(bool isDark) {
    final timeStr = DateFormat('hh:mm:ss a').format(_currentTime);
    final dateStr = DateFormat('dd MMM yyyy').format(_currentTime);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.12)
            : const Color(0xFF0F172A).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.2)
              : const Color(0xFF0F172A).withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            timeStr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateStr,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileWidget(bool isDark) {
    // Glassy main card (matching Language card in Settings)
    final Color highlightColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
    final Color headerTextColor = isDark ? Colors.white : const Color(0xFF111111);
    
    // Grey inner card background (matching the image)
    final Color innerCardBg = isDark ? const Color(0xFFB5B7B4) : const Color(0xFFC0C2BE);
    final Color contentTextColor = const Color(0xFF1A1A1A); // Dark charcoal text inside the grey cards

    final String monthStr = DateFormat('MMMM').format(_currentTime).toUpperCase();
    final String yearStr = DateFormat('yyyy').format(_currentTime);
    final String hourMinStr = DateFormat('hh:mm').format(_currentTime);
    final String amPmStr = DateFormat('a').format(_currentTime);
    final String secStr = DateFormat('ss').format(_currentTime);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10), // Middle-ground bezel padding
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [Colors.white.withValues(alpha: 0.15), Colors.white.withValues(alpha: 0.05)]
                      : [Colors.white, const Color(0xFFF1F5F9)],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.08),
                  width: 1.5,
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Card (Time / Weather Style)
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: innerCardBg,
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Middle-ground padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hourMinStr,
                            style: TextStyle(
                              color: contentTextColor,
                              fontSize: 35, // Balanced font size
                              height: 1.0,
                              fontWeight: FontWeight.w300,
                              letterSpacing: -1.0,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              "°",
                              style: TextStyle(
                                color: contentTextColor,
                                fontSize: 18, // Balanced font size
                                height: 1.0,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "$amPmStr • Sec: $secStr",
                        style: TextStyle(
                          color: contentTextColor.withValues(alpha: 0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(width: 10), // Balanced spacing between columns
            
            // Right Column (Header Text + Calendar Card)
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Month and Year row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Three colored pills "III"
                            Transform.rotate(
                              angle: 0.15,
                              child: Container(width: 3, height: 10, decoration: BoxDecoration(color: const Color(0xFFF93299), borderRadius: BorderRadius.circular(3))),
                            ),
                            const SizedBox(width: 2),
                            Transform.rotate(
                              angle: 0.15,
                              child: Container(width: 3, height: 10, decoration: BoxDecoration(color: const Color(0xFF8B5CF6), borderRadius: BorderRadius.circular(3))),
                            ),
                            const SizedBox(width: 2),
                            Transform.rotate(
                              angle: 0.15,
                              child: Container(width: 3, height: 10, decoration: BoxDecoration(color: const Color(0xFF06B6D4), borderRadius: BorderRadius.circular(3))),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              monthStr,
                              style: TextStyle(
                                color: headerTextColor,
                                fontSize: 13, // Balanced font size
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          yearStr,
                          style: TextStyle(
                            color: headerTextColor,
                            fontSize: 13, // Balanced font size
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 6), // Balanced height spacing
                  
                  // Calendar Card
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: innerCardBg,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Balanced padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCalendarStrip(contentTextColor, highlightColor),
                          const Spacer(),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              _location,
                              style: TextStyle(
                                color: contentTextColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
     ),
   ),
 ),
),
);
}

  Widget _buildCalendarStrip(Color textColor, Color highlightColor) {
    DateTime now = _currentTime;
    int currentWeekday = now.weekday; // 1=Mon, 7=Sun
    DateTime sunday = now.subtract(Duration(days: currentWeekday == 7 ? 0 : currentWeekday));
    
    List<Widget> dayWidgets = [];
    List<Widget> dateWidgets = [];
    final daysOfWeek = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    
    for (int i = 0; i < 7; i++) {
      DateTime day = sunday.add(Duration(days: i));
      bool isToday = day.year == now.year && day.month == now.month && day.day == now.day;
      
      dayWidgets.add(
        Expanded(
          child: Center(
            child: Text(
              daysOfWeek[i],
              style: TextStyle(
                color: textColor.withValues(alpha: 0.6),
                fontSize: 9, // Balanced font size
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
      
      dateWidgets.add(
        Expanded(
          child: Center(
            child: Container(
              width: 20, // Balanced circle container size
              height: 20,
              decoration: isToday ? BoxDecoration(
                color: highlightColor,
                shape: BoxShape.circle,
              ) : null,
              alignment: Alignment.center,
              child: Text(
                '${day.day}',
                style: TextStyle(
                  color: isToday ? (highlightColor == Colors.white ? Colors.black : Colors.white) : textColor,
                  fontSize: 11, // Balanced font size
                  fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    return Column(
      children: [
        Row(children: dayWidgets),
        const SizedBox(height: 6), // Balanced height between days and dates
        Row(children: dateWidgets),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final bool isDark = themeProvider.isDarkMode;

    if (widget.isDesktop) {
      return _buildDesktopClock(isDark);
    } else {
      return _buildMobileWidget(isDark);
    }
  }
}
