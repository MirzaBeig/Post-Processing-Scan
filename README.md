# Post-Processing Scan

A 3D scan/sonar-like post-processing effect. Essentially a visualization of a spherical signed distance field (SDF) rendered using the scene's depth and colour buffers. Multiple scans are supported without image-effects, and one that works with image effects (other post-processing effects).

https://user-images.githubusercontent.com/37354140/148225050-e0494988-274d-4e62-9bf9-c619abe5c9dd.mp4

https://user-images.githubusercontent.com/37354140/148223918-e0093656-7a34-4c43-b3cd-c887ba678ce3.mp4

https://user-images.githubusercontent.com/37354140/148719481-aedd5c44-d6fe-40fe-8035-37aab6e1f339.mp4

## Compatibility

- Built-in pipeline.
- Tested with Unity 2019.4 (LTS). 
- Can be edited using Amplify Shader Editor.

## Installation

You'll find everything under Mirza Beig/Post-Processing Scan/...

## Usage

### Multiple Scans:

1. Attach _CustomPostProcessing_ to your camera, and assign one of the included _Post-Processing Scan_ materials (or make your own).

![image](https://user-images.githubusercontent.com/37354140/148224103-2419e7d3-14e3-4b6d-9ae3-c89c3a5ff393.png)

2. Attach _PostProcessingScanOrigin_ to any object whose position you want to track as the scan origin. Assign the scan material.

![image](https://user-images.githubusercontent.com/37354140/148224143-e1e7feef-7abf-42ad-8710-b561c18be588.png)

### Single Scan:

Use Unity's Post-Processing Stack v2 and simply add the effect.

![image](https://user-images.githubusercontent.com/37354140/148717857-08f6162d-a3b9-47af-b242-b5431b4b5379.png)

## Social Media
- [Twitter](https://twitter.com/TheMirzaBeig/)
- [YouTube](https://www.youtube.com/c/MirzaBeig)

## License
[Unlicense](LICENSE.txt) (do whatever you want with this)...
