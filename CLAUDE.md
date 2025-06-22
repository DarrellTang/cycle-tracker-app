# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter-based mobile application for tracking menstrual cycles of family members. The app is designed for parents/partners to independently track and understand cycles, providing phase-based insights and symptom predictions to better support loved ones.

**Current Status**: Early planning phase - contains only TaskMaster configuration and PRD. No Flutter code has been implemented yet.

## Technology Stack

- **Framework**: Flutter (Dart)
- **Database**: SQLite (local storage)
- **State Management**: Provider or Riverpod
- **Charts**: fl_chart package
- **Calendar**: table_calendar package
- **Notifications**: flutter_local_notifications
- **Authentication**: local_auth (biometric)

## Project Structure (Planned)

```
lib/
├── data/           # Repositories, data sources
├── domain/         # Entities, use cases
├── presentation/   # UI, view models
│   ├── screens/
│   └── widgets/
└── core/          # Shared utilities
```

## Development Commands

Since this is a Flutter project, these commands will be relevant once the Flutter project is initialized:

```bash
# Setup and dependencies
flutter pub get                    # Install dependencies
flutter pub upgrade               # Update dependencies

# Development
flutter run                       # Run app in development mode
flutter run --release            # Run app in release mode
flutter hot-reload                # Hot reload during development

# Testing and Quality (Streamlined for Early Development)
flutter analyze                   # Static analysis - primary quality gate
dart format .                     # Code formatting
flutter test                      # Basic smoke tests only

# Testing Strategy for Early Development:
# - Keep widget tests minimal (just crash detection)
# - Focus on `flutter analyze` for code quality
# - Use manual testing in development
# - Add comprehensive tests only after core features stabilize

# CI/CD Pipeline
## Current Status: Lightweight CI for Early Development
The GitHub Actions workflow (.github/workflows/flutter-ci.yml) is currently simplified for early development:
- ✅ Code formatting verification (dart format)
- ✅ Static analysis (flutter analyze) - PRIMARY QUALITY GATE
- ✅ Basic smoke test (app doesn't crash)
- ❌ Complex widget tests - Added later when UI stabilizes
- ❌ Build artifacts (APK/iOS) - Disabled for faster CI
- ❌ Coverage reporting - Disabled for faster CI

## Development Philosophy: Fast Iteration
- Static analysis catches most issues early
- Manual testing for UI/UX validation  
- Simple smoke tests prevent major regressions
- Complex tests added after feature completion

## TODO: Enhanced CI for Production
When ready for production deployment, the CI should be enhanced to include:
- Comprehensive widget and integration tests
- APK build and artifact upload for Android testing
- iOS build for multi-platform validation
- Coverage reporting with Codecov integration
- Deployment to Firebase App Distribution or similar
- Build status badges in README

# Building
flutter build apk                 # Build Android APK
flutter build ios                # Build iOS app
flutter build appbundle          # Build Android App Bundle
```

## Key Features to Implement

1. **Multi-Profile Management** - Track cycles for wife + 2 daughters
2. **Cycle Tracking & Predictions** - Calendar-based with visual phase indicators
3. **Phase-Based Insights** - Menstrual, Follicular, Ovulation, Luteal phases
4. **Symptom Tracking** - Physical and emotional symptoms with predictions
5. **Support Suggestions** - Daily tips based on current phase
6. **Privacy-First** - All data stored locally, no cloud sync

## Data Architecture

- **Storage**: Local SQLite database only
- **Privacy**: Encrypted local storage with biometric lock
- **No Cloud**: All data remains on device
- **Backup**: Export/backup functionality for data portability

## TaskMaster Integration

This project uses TaskMaster for project management. Key files:
- `.taskmaster/docs/prd.txt` - Complete product requirements document
- `.taskmaster/tasks/tasks.json` - Detailed task breakdown
- `.taskmaster/config.json` - TaskMaster configuration

### TaskMaster CLI Commands

```bash
# Task Management
task-master list --with-subtasks           # List all tasks and subtasks
task-master next                           # Show next task to work on
task-master show <id>                      # Show detailed task information
task-master set-status --id=<id> --status=<status>  # Update task status

# Task Status Options
# pending, in-progress, done, review, deferred, cancelled

# Examples
task-master show 1.3                       # Show details for subtask 1.3
task-master set-status --id=1.3 --status=in-progress
task-master set-status --id=1.3 --status=done
```

## Development Phases

1. **Foundation** (Weeks 1-2): Flutter setup, database schema, basic profiles
2. **Core Features** (Weeks 3-4): Cycle tracking, phase calculations, symptom logging
3. **Polish & Testing** (Weeks 5-6): Notifications, support suggestions, testing

## Development Workflow

This project follows a strict branch-and-PR workflow for all development tasks:

### Branch Strategy
- **main**: Production-ready code only
- **feature branches**: One branch per TaskMaster subtask (e.g., `feature/task-1-subtask-1-flutter-setup`)
- **Branch naming**: `feature/task-{task_id}-subtask-{subtask_id}-{brief-description}`

### Development Process for Each Subtask
1. **Create Feature Branch**: Create new branch from main for the specific subtask
2. **Implement**: Complete the subtask implementation
3. **Test**: Run all quality checks (`flutter analyze`, `flutter test`)
4. **Format**: Run `dart format .` to ensure consistent code formatting
5. **Self-Verify**: Ensure subtask requirements are fully met
6. **Create PR**: Open pull request to merge into main
7. **User Review**: Wait for manual confirmation from user
8. **Merge**: Only merge after explicit user approval
9. **Next Subtask**: Move to next subtask only after previous is merged

### Quality Gates Before PR Creation
- `dart format .` applied to ensure consistent formatting
- `flutter analyze` passes with no issues
- `flutter test` passes (once tests exist)
- App builds and runs successfully
- All subtask acceptance criteria met
- No broken functionality

### PR Requirements
- **Title**: Clear description of subtask completed
- **Description**: Summary of changes and how to test
- **Testing**: Instructions for manual verification
- **Screenshots**: If UI changes are involved

**CRITICAL**: Never move to the next subtask until the current subtask's PR is merged into main.

## Privacy & Security Requirements

- All data must remain local to the device
- No internet connectivity required for core functionality
- Biometric app lock option must be implemented
- No data sharing capabilities
- No third-party analytics or tracking