# Image Assets

## Required Files

### Video Poster Image
- **File**: `video-poster.jpg`
- **Purpose**: Shown before video plays
- **Specifications**:
  - Resolution: 1920x1080 (16:9 aspect ratio)
  - Format: JPEG (optimized for web)
  - File size: < 500KB
  - Content: Professional headshot or branded image representing you/EvalPoint

### Content Suggestions
The video poster should:
- Show Gabriel in a professional setting
- Include EvalPoint branding if desired
- Be visually appealing and high-quality
- Match the futuristic design aesthetic
- Be clearly visible at various sizes

### Image Optimization
```bash
# Optimize with imagemagick
convert original-poster.jpg -quality 85 -resize 1920x1080^ -gravity center -extent 1920x1080 video-poster.jpg

# Or use online tools like TinyPNG for compression
```

## Future Assets
Consider adding:
- `gabriel-headshot.jpg` - Professional headshot for about page
- `evalpoint-logo.svg` - Company logo
- `og-image.jpg` - Social media preview image

## Placeholder
Currently using placeholder paths. Replace with your actual image files when ready.