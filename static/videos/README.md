# Video Assets

## Required Files

### Personal Introduction Video
- **File**: `gabriel-intro.mp4` (primary format)
- **Backup**: `gabriel-intro.webm` (fallback format)
- **Recommended specs**:
  - Resolution: 1920x1080 (16:9 aspect ratio)
  - Duration: 60-90 seconds
  - Format: MP4 (H.264)
  - File size: < 50MB for web optimization
  - Quality: High enough for professional presentation

### Content Suggestions
Your introduction video should cover:
- Who you are and your background
- Your approach to AI strategy
- What makes EvalPoint different
- Why teams should trust you with their AI initiatives

### Video Optimization
```bash
# Use ffmpeg to optimize for web
ffmpeg -i original-video.mp4 -c:v libx264 -crf 23 -c:a aac -b:a 128k gabriel-intro.mp4

# Create WebM fallback
ffmpeg -i gabriel-intro.mp4 -c:v libvpx-vp9 -crf 30 -c:a libopus gabriel-intro.webm
```

## Placeholder
Currently using placeholder paths. Replace with your actual video files when ready.