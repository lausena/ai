# Gemini API Models Documentation

This document provides a comprehensive overview of Google's Gemini API models and their capabilities.

## Model Overview

Google offers several Gemini model variants optimized for different use cases:

- **Gemini 2.5 Pro**: Most powerful thinking model with maximum response accuracy
- **Gemini 2.5 Flash**: Best price-performance balance with well-rounded capabilities
- **Gemini 2.5 Flash-Lite**: Most cost-efficient model for high throughput
- **Specialized Models**: Live API, Native Audio, TTS, and Image Generation variants

## Model Variants Comparison

| Model variant | Input(s) | Output | Optimized for |
| --- | --- | --- | --- |
| **Gemini 2.5 Pro** `gemini-2.5-pro` | Audio, images, videos, text, and PDF | Text | Enhanced thinking and reasoning, multimodal understanding, advanced coding |
| **Gemini 2.5 Flash** `gemini-2.5-flash` | Audio, images, videos, and text | Text | Adaptive thinking, cost efficiency |
| **Gemini 2.5 Flash-Lite** `gemini-2.5-flash-lite` | Text, image, video, audio | Text | Most cost-efficient model supporting high throughput |
| **Gemini 2.5 Flash Live** `gemini-live-2.5-flash-preview` | Audio, video, and text | Text, audio | Low-latency bidirectional voice and video interactions |
| **Gemini 2.5 Flash Native Audio** `gemini-2.5-flash-preview-native-audio-dialog` | Audio, videos, and text | Text and audio, interleaved | High quality, natural conversational audio outputs |
| **Gemini 2.5 Flash Preview TTS** `gemini-2.5-flash-preview-tts` | Text | Audio | Low latency, controllable text-to-speech generation |
| **Gemini 2.5 Pro Preview TTS** `gemini-2.5-pro-preview-tts` | Text | Audio | Low latency, controllable text-to-speech generation |
| **Gemini 2.0 Flash** `gemini-2.0-flash` | Audio, images, videos, and text | Text | Next generation features, speed, and realtime streaming |
| **Gemini 2.0 Flash Preview Image Generation** `gemini-2.0-flash-preview-image-generation` | Audio, images, videos, and text | Text, images | Conversational image generation and editing |
| **Gemini 2.0 Flash-Lite** `gemini-2.0-flash-lite` | Audio, images, videos, and text | Text | Cost efficiency and low latency |
| **Gemini 2.0 Flash Live** `gemini-2.0-flash-live-001` | Audio, video, and text | Text, audio | Low-latency bidirectional voice and video interactions |

## Detailed Model Specifications

### Gemini 2.5 Pro
Our most powerful thinking model with maximum response accuracy and state-of-the-art performance.

**Model Details:**
- **Model code:** `gemini-2.5-pro`
- **Input token limit:** 1,048,576
- **Output token limit:** 65,536
- **Knowledge cutoff:** January 2025
- **Latest update:** June 2025

**Capabilities:**
- ✅ Structured outputs
- ✅ Caching
- ✅ Function calling
- ✅ Code execution
- ✅ Search grounding
- ✅ Thinking
- ✅ Batch Mode
- ❌ Image generation
- ❌ Audio generation
- ❌ Live API

### Gemini 2.5 Flash
Best model in terms of price-performance, offering well-rounded capabilities.

**Model Details:**
- **Model code:** `models/gemini-2.5-flash`
- **Input token limit:** 1,048,576
- **Output token limit:** 65,536
- **Knowledge cutoff:** January 2025
- **Latest update:** June 2025

**Capabilities:**
- ✅ Structured outputs
- ✅ Caching
- ✅ Function calling
- ✅ Code execution
- ✅ Search grounding
- ✅ Thinking
- ✅ Batch Mode
- ❌ Image generation
- ❌ Audio generation

### Gemini 2.5 Flash-Lite
A Gemini 2.5 Flash model optimized for cost-efficiency and high throughput.

**Model Details:**
- **Model code:** `models/gemini-2.5-flash-lite`
- **Input token limit:** 1,048,576
- **Output token limit:** 65,536
- **Knowledge cutoff:** January 2025
- **Latest update:** July 2025

**Capabilities:**
- ✅ Structured outputs
- ✅ Caching
- ✅ Function calling
- ✅ Code execution
- ✅ URL Context
- ✅ Search grounding
- ✅ Thinking
- ✅ Batch mode
- ❌ Image generation
- ❌ Audio generation
- ❌ Live API

### Gemini 2.0 Flash
Gemini 2.0 Flash delivers next-gen features and improved capabilities.

**Model Details:**
- **Model code:** `models/gemini-2.0-flash`
- **Input token limit:** 1,048,576
- **Output token limit:** 8,192
- **Knowledge cutoff:** August 2024
- **Latest update:** February 2025

**Capabilities:**
- ✅ Structured outputs
- ✅ Caching
- ✅ Function calling
- ✅ Code execution
- ✅ Search
- ✅ Live API
- ✅ Thinking (Experimental)
- ✅ Batch Mode
- ❌ Image generation
- ❌ Audio generation
- ❌ Tuning

## Model Version Patterns

### Latest Stable
Points to the most recent stable version: `<model>-<generation>-<variation>`
Example: `gemini-2.0-flash`

### Stable
Points to a specific stable model: `<model>-<generation>-<variation>-<version>`
Example: `gemini-2.0-flash-001`

### Preview
Points to a preview model: `<model>-<generation>-<variation>-<version>`
Example: `gemini-2.5-pro-preview-06-05`

### Experimental
Points to an experimental model: `<model>-<generation>-<variation>-<version>`
Example: `gemini-2.0-pro-exp-02-05`

## Supported Languages

Gemini models support the following languages:

- Arabic (`ar`)
- Bengali (`bn`)
- Bulgarian (`bg`)
- Chinese simplified and traditional (`zh`)
- Croatian (`hr`)
- Czech (`cs`)
- Danish (`da`)
- Dutch (`nl`)
- English (`en`)
- Estonian (`et`)
- Finnish (`fi`)
- French (`fr`)
- German (`de`)
- Greek (`el`)
- Hebrew (`iw`)
- Hindi (`hi`)
- Hungarian (`hu`)
- Indonesian (`id`)
- Italian (`it`)
- Japanese (`ja`)
- Korean (`ko`)
- Latvian (`lv`)
- Lithuanian (`lt`)
- Norwegian (`no`)
- Polish (`pl`)
- Portuguese (`pt`)
- Romanian (`ro`)
- Russian (`ru`)
- Serbian (`sr`)
- Slovak (`sk`)
- Slovenian (`sl`)
- Spanish (`es`)
- Swahili (`sw`)
- Swedish (`sv`)
- Thai (`th`)
- Turkish (`tr`)
- Ukrainian (`uk`)
- Vietnamese (`vi`)

## Token Information

A token is equivalent to about 4 characters for Gemini models. 100 tokens are about 60-80 English words.

## Rate Limits

Rate limits vary by model. Check the [rate limits page](https://ai.google.dev/gemini-api/docs/rate-limits) for specific limits for each model.

## Try the Models

You can try these models in [Google AI Studio](https://aistudio.google.com/) with the specific model links provided in the original documentation.

---

*Documentation fetched from: https://ai.google.dev/gemini-api/docs/models*  
*Last updated: August 7, 2025*