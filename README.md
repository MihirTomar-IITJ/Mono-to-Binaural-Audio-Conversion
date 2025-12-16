# Binaural Rendering Using HRTF

This project is a MATLAB-based tool designed to simulate spatial audio experiences. By convolving a mono audio source with Head-Related Transfer Functions (HRTFs) corresponding to specific spatial locations, it generates binaural audio that mimics how sound is heard by human ears from a specific direction and distance.

## Features

-   **Interactive GUI**: Easy-to-use graphical interface built with MATLAB's App Designer components (`uifigure`).
-   **Spatial Positioning**:
    -   **Azimuth & Distance**: Select the speaker's position on a 2D plane (X-Y) using a mouse click.
    -   **Elevation**: Input a specific elevation angle ($\phi$) for the sound source.
-   **Real-time Processing**: Convolves input audio with HRIRs (Head-Related Impulse Responses) based on the closest matching position in the dataset.
-   **Distance Attenuation**: Simulates sound volume changes based on distance from the listener.
-   **Visualization**: Displays the rendered Left and Right channel waveforms.
-   **Playback & Export**: Instantly plays the rendered 3D audio and saves it as `rendered_binaural.wav`.

## Prerequisites

To run this project, you need:

1.  **MATLAB** (Recommend R2020a or later for `uifigure` and UI component support).
2.  **Audio Toolbox** (for `audioread`, `audiowrite`, etc.).
3.  **Data Files**:
    -   `ReferenceHRTF.mat`: Must contain `hrtfData` (HRIRs) and `sourcePosition` (coordinates).
    -   `white-noise.wav`: A mono or stereo audio file to be rendered (code defaults to 'white-noise.wav').

## Usage

1.  **Setup**:
    -   Ensure `BinauralRenderer (1).m`, `ReferenceHRTF.mat`, and `white-noise.wav` are in the same directory (or MATLAB path).
2.  **Run**:
    -   Open `BinauralRenderer (1).m` in MATLAB.
    -   Run the script/function.
3.  **Interact**:
    -   **Speaker Position**: Click anywhere on the "Select Speaker Position" axes to place the sound source relative to the listener (center).
    -   **Elevation**: Enter the desired elevation angle in degrees in the "Elevation" field.
    -   **Render**: Click "Render & Play" to generate and hear the effect.
    -   **Stop**: Click "Stop" to halt playback.

## How It Works

1.  **HRTF Selection**: The algorithm calculates the azimuth and elevation of the selected point and finds the closest matching HRIR from the `ReferenceHRTF.mat` dataset.
2.  **Convolution**: The input audio is convolved with the Left and Right ear HRIRs.
3.  **Gain Control**: Inverse distance attenuation is applied to simulate the drop in volume as the source moves away.
4.  **Binaural Output**: The resulting stereo signal is normalized and sent to the audio output.

## File Structure

-   `BinauralRenderer (1).m`: Main MATLAB application script.
-   `ReferenceHRTF.mat`: Dataset containing HRTF measurements.
-   `white-noise.wav`: Input audio sample.
-   `rendered_binaural.wav`: The output file generated after rendering.
