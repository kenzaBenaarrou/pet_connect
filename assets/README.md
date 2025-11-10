# Assets Directory

This directory contains all the assets used in the PetConnect app.

## Structure

### Images (`images/`)
- App logos and branding
- Default placeholder images
- Onboarding illustrations

### Icons (`icons/`)
- Custom app icons
- Navigation icons
- Feature-specific icons

### Animations (`animations/`)
- Lottie animation files
- Loading animations
- Success/celebration animations

### Fonts (`fonts/`)
- Poppins font family (Regular, Medium, SemiBold, Bold)

## Adding Assets

When adding new assets:

1. Place files in the appropriate subdirectory
2. Update `pubspec.yaml` if needed
3. Reference assets using the correct path:
   ```dart
   Image.asset('assets/images/your_image.png')
   ```

## Font Usage

The app uses Poppins as the primary font family. Font weights:
- Regular (400)
- Medium (500) 
- SemiBold (600)
- Bold (700)

## Image Guidelines

- Use high-quality images (2x, 3x density)
- Optimize file sizes for mobile
- Use appropriate formats (PNG for transparency, JPG for photos)
- Follow naming conventions (snake_case)

## Icon Guidelines

- Use vector formats when possible (SVG)
- Provide multiple sizes for different screen densities
- Use consistent color schemes
- Follow Material Design guidelines