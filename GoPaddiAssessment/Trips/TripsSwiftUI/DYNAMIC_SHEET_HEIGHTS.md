# Dynamic Sheet Heights - Implementation Guide

## Overview

Your sheets now have **dynamic heights** that adapt to their content! This implementation uses SwiftUI's `presentationDetents` to control sheet sizing.

## What Changed

### Before
```swift
.sheet(item: ...) { modal in
    destinationView(for: route)  // Fixed size sheets
}
```

### After
```swift
.sheet(item: ...) { modal in
    destinationView(for: route)
        .presentationDetents(detentsForRoute(route))  // Dynamic sizing!
        .presentationDragIndicator(.visible)
}
```

## Sheet Sizes by Route

| Route | Detents | Behavior |
|-------|---------|----------|
| `.selectCountry` | `[.medium]` | Fixed at ~50% screen height |
| `.countryList` | `[.medium, .large]` | User can drag between 50% and 95% |
| `.countryDetail` | `[.medium, .large]` | User can drag between 50% and 95% |
| `.tripCreate` | `[.large]` | Fixed at ~95% screen height |

## Available Detent Types

### 1. Preset Detents

```swift
// Small fraction of screen (varies by device)
return [.fraction(0.25)]

// Medium (~50% of screen height)
return [.medium]

// Large (~95% of screen height, leaves room for status bar)
return [.large]
```

### 2. Custom Height Detents

```swift
// Fixed height in points
return [.height(300)]

// Multiple options
return [.height(300), .medium, .large]
```

### 3. Multiple Detents (User Can Choose)

```swift
// User can drag between these sizes
return [.medium, .large]

// More options give more flexibility
return [.height(200), .medium, .large]
```

### 4. Fraction-based Detents

```swift
// 25% of screen height
return [.fraction(0.25)]

// 75% of screen height
return [.fraction(0.75)]

// Multiple fractions
return [.fraction(0.3), .fraction(0.7)]
```

## Advanced Customization Examples

### Example 1: Small Modal with Fixed Height
```swift
case .selectCountry:
    return [.height(250)]  // Exactly 250 points
```

### Example 2: Resizable Between Three Sizes
```swift
case .countryList:
    return [.height(400), .medium, .large]
    // User can drag between 400pt, 50%, and 95%
```

### Example 3: Precise Fraction Control
```swift
case .countryDetail:
    return [.fraction(0.4), .fraction(0.8)]
    // Starts at 40%, can expand to 80%
```

### Example 4: Content-Adaptive Custom Detent
```swift
case .tripCreate:
    // Use custom detent that calculates based on content
    return [.height(calculateFormHeight()), .large]
```

## Additional Sheet Modifiers

You can add more sheet customization:

```swift
destinationView(for: route)
    .presentationDetents(detentsForRoute(route))
    .presentationDragIndicator(.visible)           // Already added
    .presentationCornerRadius(20)                  // Custom corner radius
    .presentationBackground(.ultraThinMaterial)    // Blurred background
    .presentationBackgroundInteraction(.enabled)   // Allow interaction behind sheet
    .interactiveDismissDisabled(true)              // Prevent swipe to dismiss
```

### Example: Styled Sheet
```swift
.sheet(item: ...) { modal in
    switch modal {
    case .sheet(let route):
        destinationView(for: route)
            .presentationDetents(detentsForRoute(route))
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(20)
            .presentationBackground {
                Color(.systemBackground)
                    .opacity(0.95)
            }
    default:
        EmptyView()
    }
}
```

## Dynamic Selection of Starting Detent

You can control which detent is selected initially:

```swift
@State private var selectedDetent: PresentationDetent = .medium

.sheet(item: ...) { modal in
    destinationView(for: route)
        .presentationDetents(
            [.medium, .large],
            selection: $selectedDetent  // Starts at .medium
        )
}
```

## Conditional Detents

Make detents conditional based on content:

```swift
private func detentsForRoute(_ route: AppRoute) -> Set<PresentationDetent> {
    switch route {
    case .countryList:
        // If there are many countries, allow full screen
        if Country.allCountries.count > 50 {
            return [.medium, .large]
        } else {
            return [.medium]
        }
        
    case .tripCreate:
        // Different sizes based on device
        if UIDevice.current.userInterfaceIdiom == .pad {
            return [.height(600)]  // Fixed on iPad
        } else {
            return [.large]  // Full height on iPhone
        }
        
    default:
        return [.medium, .large]
    }
}
```

## Best Practices

### ✅ Do:
- Use `.medium` for simple selections or small forms
- Use `[.medium, .large]` for lists that might need more space
- Use `.large` for complex forms like trip creation
- Add `.presentationDragIndicator(.visible)` for discoverability
- Consider content when choosing detents

### ❌ Don't:
- Don't use too many detent options (max 3-4)
- Don't use `.height()` for responsive content (use fractions)
- Don't make sheets non-dismissible without good reason
- Don't forget to test on different device sizes

## Device Considerations

### iPhone SE / Small Screens
- `.medium` ≈ 300-350pt
- `.large` ≈ Screen height - 60pt

### iPhone Pro / Standard Screens
- `.medium` ≈ 400-450pt
- `.large` ≈ Screen height - 60pt

### iPhone Pro Max / Large Screens
- `.medium` ≈ 450-500pt
- `.large` ≈ Screen height - 60pt

### iPad
- Sheets appear as floating modals with max width
- Consider using `.height()` for consistent sizing
- Or use `.formSheet` style instead

## Testing Checklist

- [ ] Sheet appears at correct initial size
- [ ] Drag indicator is visible and works
- [ ] User can drag to resize (if multiple detents)
- [ ] Sheet snaps to detents smoothly
- [ ] Content is fully visible at each detent
- [ ] Works on different device sizes
- [ ] Works in landscape orientation
- [ ] Dismiss gesture works
- [ ] Sheet doesn't cover critical UI

## Common Issues & Solutions

### Issue: Sheet too small for content
```swift
// Solution: Add larger detent or use custom height
return [.medium, .large]  // Allow expansion
// or
return [.height(600)]  // Specific height for content
```

### Issue: Content gets cut off
```swift
// Solution: Wrap content in ScrollView
var body: some View {
    ScrollView {
        // Your content
    }
    .presentationDetents([.medium, .large])
}
```

### Issue: Sheet covers important UI
```swift
// Solution: Use smaller detent or enable background interaction
.presentationDetents([.height(400)])
.presentationBackgroundInteraction(.enabled)
```

### Issue: User can't resize when needed
```swift
// Solution: Provide multiple detent options
return [.medium, .large]  // Let user choose
```

## Real-World Examples

### Example: Settings Sheet
```swift
case .settings:
    return [.height(500), .large]
    // Starts at comfortable 500pt, can expand for more options
```

### Example: Image Picker
```swift
case .imagePicker:
    return [.medium, .large]
    // Medium for quick picks, large for browsing
```

### Example: Quick Action Menu
```swift
case .quickActions:
    return [.height(280)]
    // Fixed height, just enough for action buttons
```

### Example: Search/Filter
```swift
case .searchFilter:
    return [.fraction(0.35), .medium, .large]
    // Small for quick filters, can expand for more options
```

## Accessibility Considerations

- Ensure content is readable at smallest detent
- Don't rely on drag gestures for essential actions
- Provide alternative ways to dismiss
- Test with Dynamic Type (larger text sizes)
- Verify VoiceOver announces detent changes

## Performance Tips

- Detent calculations are lightweight
- No performance impact vs fixed sheets
- Animations are hardware-accelerated
- Consider lazy loading for large lists in sheets

## Summary

Your sheets now adapt perfectly to their content:
- **Select Country**: Medium size (perfect for simple selection)
- **Country List**: Medium to Large (user can expand to browse)
- **Country Detail**: Medium to Large (flexible viewing)
- **Create Trip**: Large (full form needs space)

All with smooth animations and intuitive drag interactions! 🎉

## Quick Reference

```swift
// Current implementation in AppNavigationRoot.swift
private func detentsForRoute(_ route: AppRoute) -> Set<PresentationDetent> {
    switch route {
    case .selectCountry:    return [.medium]
    case .countryList:      return [.medium, .large]
    case .countryDetail:    return [.medium, .large]
    case .tripCreate:       return [.large]
    }
}
```

To customize, just modify the return values in this function!
