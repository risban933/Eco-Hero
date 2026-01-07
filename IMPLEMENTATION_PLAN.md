# Eco Hero - Issues & Implementation Plan

## Part 1: Identified Issues

### Critical Issues

| Issue | Location | Impact |
|-------|----------|--------|
| **App crash on SwiftData failure** | `Eco_HeroApp.swift:52` | `fatalError()` kills the app if ModelContainer fails |
| **Silent data loss** | Multiple views | `try? modelContext.save()` swallows errors |
| **Unbounded negative scores** | `WasteSortingView.swift:333` | Score can go arbitrarily negative |

### High Priority Issues

| Issue | Location | Impact |
|-------|----------|--------|
| **Challenge expiration never runs** | `Challenge.swift:106` | `checkExpiration()` defined but never called |
| **Achievement system unused** | `Achievement.swift` | `unlock()` method never invoked |
| **No distance validation** | `LogActivityView.swift:418` | Accepts negative/unreasonable values |
| **Duplicate streak logic** | `UserProfile` vs `WasteSortingView` | Inconsistent streak mechanics |

### Medium Priority Issues

- Password reset not implemented (`AuthenticationView.swift:234`)
- No email format validation (`AuthenticationManager.swift:61`)
- Race condition in profile creation (`DashboardView.swift:110`)
- No duplicate challenge join check (`ChallengesView.swift:317`)
- XP level-up skips without feedback (`UserProfile.swift:85`)

### Missing Features

- No push notifications (constants exist but not implemented)
- CloudSyncService is a placeholder
- No data export functionality
- No social sharing features
- No iOS widgets

---

## Part 2: Five Meaningful Improvements

### Improvement 1: Push Notification System for Streak Reminders

**Why:** User retention is critical. The app tracks streaks but doesn't remind users to maintain them. Notification constants already exist in `Constants.swift` but aren't used.

**User Value:**
- Daily reminders prevent streak loss
- Challenge deadline notifications
- Celebration notifications for milestones

**Technical Approach:**
- Implement `UNUserNotificationCenter` for local notifications
- Schedule daily streak reminders at user-configured time
- Add notification preferences to ProfileView

---

### Improvement 2: iOS Widget for Impact Dashboard

**Why:** Widgets provide at-a-glance visibility without opening the app, increasing engagement and daily active usage.

**User Value:**
- See current streak on home screen
- View total CO2 saved
- Quick access to log activity

**Technical Approach:**
- Create WidgetKit extension
- Share SwiftData via App Groups
- Small widget: Streak + XP
- Medium widget: Impact stats grid

---

### Improvement 3: Achievement Badge Gallery with Unlock System

**Why:** The `Achievement.swift` model exists but `unlock()` is never called. Gamification drives engagement.

**User Value:**
- Visual badge collection
- Progress toward locked achievements
- Celebration animations on unlock

**Technical Approach:**
- Create AchievementGalleryView
- Add unlock triggers in activity logging
- Implement achievement notification overlays
- Pre-define 15-20 meaningful achievements

---

### Improvement 4: Environmental Impact Report Export

**Why:** Users want to share their impact and track progress over time. No export feature exists.

**User Value:**
- Generate shareable PDF report
- Share to social media
- Personal environmental portfolio

**Technical Approach:**
- Create report generator using SwiftUI → PDF
- Include charts, statistics, achievements
- ShareLink integration for iOS sharing
- Monthly/yearly summary options

---

### Improvement 5: Challenge Expiration & Smart Reminders

**Why:** `checkExpiration()` exists but is never called. Challenges stay "in progress" forever.

**User Value:**
- Clear challenge deadlines
- Reminder before expiration
- Failed challenge feedback

**Technical Approach:**
- Add background task to check expirations
- Integrate with notification system
- Show countdown timers in UI
- Grace period option for near-misses

---

## Part 3: Detailed Implementation Plan

### Phase 1: Foundation Fixes (Pre-requisites)

**1.1 Fix Critical Data Issues**
```
Files to modify:
- Eco_HeroApp.swift: Replace fatalError with graceful recovery UI
- All views with try?: Add proper error handling with user feedback
- WasteSortingView.swift: Add minimum score bound (0)
```

**1.2 Fix Challenge & Achievement Systems**
```
Files to modify:
- Challenge.swift: No changes needed (methods exist)
- Add ChallengeManager service to call checkExpiration() periodically
- Wire achievement unlocks to activity logging flow
```

---

### Phase 2: Push Notifications (Improvement #1)

**2.1 Create NotificationService**
```
New file: Eco Hero/Services/NotificationService.swift

Features:
- requestAuthorization()
- scheduleStreakReminder(at hour: Int)
- scheduleChallengeDeadline(challenge: Challenge)
- cancelAllNotifications()
```

**2.2 Add Notification Preferences**
```
Modify: Eco Hero/Views/Profile/ProfileView.swift

Add toggles for:
- Daily streak reminder (on/off + time picker)
- Challenge reminders (on/off)
- Achievement notifications (on/off)
```

**2.3 Integrate with App Lifecycle**
```
Modify: Eco_HeroApp.swift

- Request notification permission after onboarding
- Reschedule notifications on app launch
```

---

### Phase 3: iOS Widget (Improvement #2)

**3.1 Create Widget Extension**
```
New target: Eco Hero Widget

Files:
- EcoHeroWidget.swift (widget entry point)
- WidgetProvider.swift (timeline provider)
- SmallWidgetView.swift (streak + level)
- MediumWidgetView.swift (impact grid)
```

**3.2 Configure App Groups**
```
Modify: Project settings

- Add App Group: group.eco.hero.shared
- Configure SwiftData to use shared container
```

**3.3 Create Shared Data Layer**
```
New file: Shared/WidgetDataProvider.swift

- Read-only access to UserProfile
- Cached impact metrics
- Last activity timestamp
```

---

### Phase 4: Achievement Gallery (Improvement #3)

**4.1 Define Achievement Catalog**
```
New file: Eco Hero/Models/AchievementCatalog.swift

Achievements:
- "First Steps" - Log first activity
- "Week Warrior" - 7-day streak
- "Carbon Crusher" - Save 100kg CO2
- "Plastic Free" - Avoid 50 plastic items
- "Sorting Pro" - 90% accuracy in waste game
- "Level 10" - Reach level 10
- (15+ total achievements)
```

**4.2 Create Achievement Gallery View**
```
New file: Eco Hero/Views/Profile/AchievementGalleryView.swift

Features:
- Grid of badge icons (locked/unlocked states)
- Progress indicators for locked badges
- Detail sheet on tap
- Celebration animation on unlock
```

**4.3 Wire Unlock Triggers**
```
Modify: Multiple files

Trigger points:
- LogActivityView: Check after saving activity
- WasteSortingView: Check after game session
- UserProfile: Check after XP update
- Dashboard: Check on appear for time-based
```

**4.4 Achievement Unlock Overlay**
```
New file: Eco Hero/Views/Components/AchievementUnlockOverlay.swift

- Full-screen celebration effect
- Badge reveal animation
- Confetti particles
- Auto-dismiss after 3 seconds
```

---

### Phase 5: Impact Report Export (Improvement #4)

**5.1 Create Report Generator**
```
New file: Eco Hero/Services/ReportGeneratorService.swift

Features:
- generatePDF(for profile: UserProfile, period: ReportPeriod) -> URL
- generateShareImage(stats: ImpactStats) -> UIImage
```

**5.2 Design Report Template**
```
New file: Eco Hero/Views/Reports/ImpactReportView.swift

Sections:
- Header with user name and period
- Impact summary cards (CO2, water, plastic)
- Activity breakdown chart
- Achievement highlights
- Comparison to average user
- Call-to-action footer
```

**5.3 Add Export UI**
```
Modify: Eco Hero/Views/Profile/ProfileView.swift

Add:
- "Export Report" button
- Period selector (week/month/year/all-time)
- ShareLink integration
```

---

### Phase 6: Challenge Expiration System (Improvement #5)

**6.1 Create ChallengeManager Service**
```
New file: Eco Hero/Services/ChallengeManager.swift

Features:
- checkAllExpirations()
- getExpiringChallenges(within hours: Int) -> [Challenge]
- scheduleExpirationCheck()
```

**6.2 Add Background Task**
```
Modify: Eco_HeroApp.swift

- Register BGTaskScheduler for daily expiration check
- Run checkAllExpirations() on app launch
```

**6.3 Update Challenge UI**
```
Modify: Eco Hero/Views/Challenges/ChallengesView.swift

Add:
- Countdown timer for active challenges
- "Expiring Soon" badge
- Failed challenge visual state
- Retry option for failed challenges
```

**6.4 Integrate with Notifications**
```
Modify: NotificationService.swift

Add:
- scheduleExpirationWarning(challenge: Challenge, hoursBefore: Int)
- notifyChallengeExpired(challenge: Challenge)
```

---

## Implementation Priority Order

| Order | Improvement | Effort | Impact | Dependencies |
|-------|-------------|--------|--------|--------------|
| 1 | Foundation Fixes | 1 day | Critical | None |
| 2 | Challenge Expiration (#5) | 2 days | High | Foundation fixes |
| 3 | Push Notifications (#1) | 2 days | High | None |
| 4 | Achievement Gallery (#3) | 3 days | High | Foundation fixes |
| 5 | Impact Report Export (#4) | 2 days | Medium | None |
| 6 | iOS Widget (#2) | 3 days | Medium | App Groups setup |

**Total Estimated Effort:** ~13 days

---

## File Summary

### New Files to Create
```
Eco Hero/Services/
├── NotificationService.swift
├── ChallengeManager.swift
└── ReportGeneratorService.swift

Eco Hero/Models/
└── AchievementCatalog.swift

Eco Hero/Views/
├── Profile/
│   └── AchievementGalleryView.swift
├── Reports/
│   └── ImpactReportView.swift
└── Components/
    └── AchievementUnlockOverlay.swift

Eco Hero Widget/ (new target)
├── EcoHeroWidget.swift
├── WidgetProvider.swift
├── SmallWidgetView.swift
└── MediumWidgetView.swift

Shared/
└── WidgetDataProvider.swift
```

### Files to Modify
```
Eco_HeroApp.swift
Eco Hero/Views/Profile/ProfileView.swift
Eco Hero/Views/Challenges/ChallengesView.swift
Eco Hero/Views/Activities/LogActivityView.swift
Eco Hero/Views/WasteSorting/WasteSortingView.swift
Eco Hero/Views/Dashboard/DashboardView.swift
Eco Hero/Models/Challenge.swift
Eco Hero/Utilities/Constants.swift
```

---

## Success Metrics

| Improvement | Success Metric |
|-------------|----------------|
| Notifications | 80% of users enable notifications |
| Widget | 30% widget adoption rate |
| Achievements | Average 5+ achievements unlocked per user |
| Report Export | 20% of users export at least one report |
| Challenge System | 50% reduction in "stuck" challenges |
