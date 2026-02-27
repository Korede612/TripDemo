# Create Trip View - Component Structure

## Visual Hierarchy

```
CreateTripView
│
├── ScrollView
│   │
│   └── VStack (main container)
│       │
│       ├── headerSection
│       │   ├── HStack (top row)
│       │   │   ├── ZStack (gift icon)
│       │   │   │   ├── RoundedRectangle (blue background)
│       │   │   │   └── Image (gift.fill)
│       │   │   └── Button (X close button)
│       │   └── VStack (titles)
│       │       ├── Text ("Create a Trip")
│       │       └── Text ("Let's Go! Build Your Next Adventure")
│       │
│       └── VStack (content sections)
│           │
│           ├── tripNameSection
│           │   ├── Text ("Trip Name")
│           │   └── TextField (custom styled)
│           │
│           ├── travelStyleSection
│           │   ├── Text ("Travel Style")
│           │   └── VStack (dropdown)
│           │       ├── Button (dropdown trigger)
│           │       └── [Conditional] VStack (options)
│           │           ├── Button ("Solo")
│           │           ├── Button ("Couple")
│           │           ├── Button ("Family")
│           │           └── Button ("Group")
│           │
│           └── tripDescriptionSection
│               ├── Text ("Trip Description")
│               └── ZStack
│                   ├── Text (placeholder)
│                   └── TextEditor (input)
│
└── safeAreaInset (bottom)
    └── nextButton
        └── Button ("Next")
```

## State Flow

```
User Interaction → ViewModel @Published Property → View Updates
```

### Example Flow: Selecting Travel Style

```
1. User taps dropdown button
   ↓
2. viewModel.isTravelStyleExpanded.toggle()
   ↓
3. SwiftUI detects @Published change
   ↓
4. View re-renders with animation
   ↓
5. Dropdown options appear/disappear
```

### Example Flow: Form Validation

```
1. User types in Trip Name field
   ↓
2. viewModel.tripName updates (@Published)
   ↓
3. Computed property viewModel.isFormValid recalculates
   ↓
4. Next button appearance updates
   ↓
5. Button enabled/disabled state changes
```

## Data Model

```swift
// Input
struct TripFormData {
    var tripName: String           // Required
    var travelStyle: TravelStyle?  // Required (Solo/Couple/Family/Group)
    var description: String        // Optional
}

// Output (when Next is tapped)
completion: (String, TravelStyle, String) -> Void
```

## View Model Properties

```
CreateTripViewModel
│
├── @Published Properties (trigger UI updates)
│   ├── tripName: String
│   ├── selectedTravelStyle: TravelStyle?
│   ├── tripDescription: String
│   └── isTravelStyleExpanded: Bool
│
├── Computed Properties (derived state)
│   └── isFormValid: Bool
│
└── Methods (user actions)
    └── handleNext(completion:)
```

## Animation Timeline

### Dropdown Expand/Collapse
```
Time:  0ms                    200ms
       │─────────────────────│
State: Collapsed              Expanded
       
Animation: easeInOut
Properties:
- opacity: 0 → 1
- position: top edge → normal
- chevron rotation: 0° → 180°
```

### Button State Change
```
Time:  Instant (no animation)

Disabled State:
- Background: systemGray5
- Text Color: secondary
- Interaction: disabled

Enabled State:
- Background: blue
- Text Color: white
- Interaction: enabled
```

## Styling Constants

```swift
// Colors
primaryBlue = Color.blue
textPrimary = Color.primary
textSecondary = Color.secondary
backgroundGray = Color(.systemGray6)
borderGray = Color(.systemGray4)

// Typography
titleSize = 24pt, weight: .semibold
subtitleSize = 15pt, weight: .regular
labelSize = 15pt, weight: .medium
inputSize = 15pt, weight: .regular
buttonSize = 16pt, weight: .semibold

// Spacing
horizontalPadding = 20pt
sectionSpacing = 24pt
fieldInternalPadding = 16pt (h), 14pt (v)
stackSpacing = 8pt

// Corner Radius
fields = 8pt
button = 10pt
iconBackground = 12pt

// Border Width
default = 1pt
selected = 2pt

// Heights
textField = 44pt (via internal padding)
textEditor = 120pt minimum
button = 50pt (via internal padding)
iconBackground = 60pt × 60pt
closeButton = 32pt × 32pt
```

## Accessibility Tree

```
CreateTripView
├── [Close] Button
│   └── Accessibility: "Close"
│
├── Trip Name TextField
│   ├── Label: "Trip Name"
│   └── Hint: "Enter a name for your trip"
│
├── Travel Style Button (dropdown)
│   ├── Label: "Travel Style"
│   ├── Hint: "Select your preferred travel style"
│   └── Value: "Currently selected: [style]" or "Not selected"
│
├── [When expanded] Travel Style Options
│   ├── Solo Button
│   │   ├── Label: "Solo"
│   │   └── Traits: [.isSelected] if selected
│   ├── Couple Button
│   ├── Family Button
│   └── Group Button
│
├── Trip Description TextEditor
│   ├── Label: "Trip Description"
│   └── Hint: "Optional"
│
└── Next Button
    ├── Label: "Next"
    └── Hint: "Proceed to next step" or 
             "Complete required fields to continue"
```

## Integration Points

### Environment Objects Required
```swift
@EnvironmentObject var coordinator: NavigationCoordinator
```

### Optional Callbacks
```swift
onCreateTrip: ((String, TravelStyle, String) -> Void)?
```

### Navigation Routes
```swift
// Incoming route
AppRoute.tripCreate

// Outgoing actions
dismiss()  // via @Environment(\.dismiss)
```

## File Dependencies

```
CreateTripView.swift
├── Imports
│   └── SwiftUI (framework)
│
├── Depends On
│   ├── NavigationCoordinator (for environment)
│   └── UIKit (for haptics and keyboard dismissal)
│
└── Defines
    ├── enum TravelStyle
    ├── struct CreateTripView
    ├── class CreateTripViewModel
    ├── struct CustomTextFieldStyle
    └── View extension (keyboard helper)
```

## Performance Considerations

### Rendering
- ScrollView: Lazy loading not needed (small content)
- Animations: Hardware-accelerated (Core Animation)
- State updates: O(1) property changes
- Dropdown: Conditional rendering (only when expanded)

### Memory
- ViewModel: Lightweight (@MainActor)
- Published properties: Standard overhead
- No heavy data structures
- No image assets (only SF Symbols)

### Responsiveness
- Animation duration: 200ms (feels instant)
- Form validation: Computed property (instant)
- State changes: SwiftUI's diffing (optimized)
- Haptics: Non-blocking (fire-and-forget)

---

## Quick Reference Commands

### To view the main file:
```bash
open CreateTripView.swift
```

### To test the view:
```bash
# Run the app and tap "Create Trip"
```

### To modify styling:
```swift
// Look for these sections in CreateTripView.swift:
- headerSection
- tripNameSection
- travelStyleSection
- tripDescriptionSection
- nextButton
```

### To change colors:
```swift
// Search for:
Color.blue          // Primary accent
Color(.systemGray6) // Field backgrounds
Color(.systemGray4) // Borders
```

### To adjust animations:
```swift
// Search for:
withAnimation(.easeInOut(duration: 0.2))
```

### To modify validation:
```swift
// In CreateTripViewModel:
var isFormValid: Bool {
    !tripName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
    selectedTravelStyle != nil
}
```
