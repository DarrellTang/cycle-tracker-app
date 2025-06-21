// Core Dependencies - Centralized imports for the Cycle Tracker App
// This file provides a single place to manage all external package imports

// Flutter Core
export 'package:flutter/material.dart';
export 'package:flutter/cupertino.dart' hide RefreshCallback;
export 'package:flutter/services.dart';

// State Management (using Riverpod as primary)
export 'package:flutter_riverpod/flutter_riverpod.dart';
export 'package:riverpod/riverpod.dart';

// HTTP and API
export 'package:http/http.dart' hide MultipartFile, Response;
export 'package:dio/dio.dart';

// Local Storage
export 'package:shared_preferences/shared_preferences.dart';
export 'package:sqflite/sqflite.dart';

// Calendar and Date Utils
export 'package:table_calendar/table_calendar.dart';
export 'package:intl/intl.dart' hide TextDirection;

// Charts and Visualization
export 'package:fl_chart/fl_chart.dart';

// Notifications
export 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Authentication
export 'package:local_auth/local_auth.dart';

// UI and Design
export 'package:flutter_svg/flutter_svg.dart';
export 'package:cached_network_image/cached_network_image.dart';

// Utilities
export 'package:uuid/uuid.dart';
export 'package:equatable/equatable.dart';

// Path utilities (exported with alias to avoid conflicts)
export 'package:path/path.dart' show join, dirname, basename, extension;