# Post-Processing Scan

[![Unity Version](https://img.shields.io/badge/Unity-2019.4%20LTS%2B-blueviolet?logo=unity)](https://unity3d.com/get-unity/download)
[![Unity Pipeline Support (Built-In)](https://img.shields.io/badge/BiRP_✔️-darkgreen?logo=unity)](https://unity3d.com/get-unity/download)
[![Unity Pipeline Support (URP)](https://img.shields.io/badge/URP_✔️-blue?logo=unity)](https://unity3d.com/get-unity/download)
[![Unity Pipeline Support (HDRP)](https://img.shields.io/badge/HDRP_❌-darkred?logo=unity)](https://unity3d.com/get-unity/download)

[![GitHub followers](https://img.shields.io/github/followers/MirzaBeig?style=social)](https://github.com/MirzaBeig?tab=followers)
[![Twitter Follow](https://img.shields.io/twitter/follow/TheMirzaBeig?style=social)](http://twitter.com/intent/user?screen_name=TheMirzaBeig)
[![YouTube Channel Views](https://img.shields.io/youtube/channel/views/UC5c5JgFyiFXKXCVRh2DsRJg?style=social)](https://www.youtube.com/MirzaBeig)
[![YouTube Channel Subscribers](https://img.shields.io/youtube/channel/subscribers/UC5c5JgFyiFXKXCVRh2DsRJg?style=social)](https://www.youtube.com/MirzaBeig)

A 3D scan/sonar-like post-processing effect. Essentially a visualization of a spherical signed distance field (SDF) rendered using the scene's depth and colour buffers. Multiple scans are supported without image-effects, and one that works with image effects (other post-processing effects). If you're using URP, you get the best of both worlds and can have multiple scans with post-processing.

[![Stars](https://img.shields.io/github/stars/MirzaBeig/Post-Processing-Scan?style=for-the-badge)](../../stargazers)
[![Forks](https://img.shields.io/github/forks/MirzaBeig/Post-Processing-Scan?style=for-the-badge)](../../forks)
[![GitHub watchers](https://img.shields.io/github/watchers/MirzaBeig/Post-Processing-Scan?style=for-the-badge)](../../watchers)
[![GitHub repo size](https://img.shields.io/github/repo-size/MirzaBeig/Post-Processing-Scan?style=for-the-badge)](../../)
[![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/MirzaBeig/Post-Processing-Scan?style=for-the-badge)](../../)

## Preview

https://user-images.githubusercontent.com/37354140/173145001-7cd796c6-1687-4946-92e6-9edbab82fc5c.mp4

https://user-images.githubusercontent.com/37354140/148225050-e0494988-274d-4e62-9bf9-c619abe5c9dd.mp4

https://user-images.githubusercontent.com/37354140/148223918-e0093656-7a34-4c43-b3cd-c887ba678ce3.mp4

https://user-images.githubusercontent.com/37354140/148719481-aedd5c44-d6fe-40fe-8035-37aab6e1f339.mp4

## Compatibility

- Built-in pipeline + URP.
- Tested with Unity 2019.4 (LTS). 
- Can be edited using Amplify Shader Editor.

## Installation

You'll find everything under Mirza Beig/Post-Processing Scan/...

## Usage

### Built-In

#### Multiple Scans

1. Attach _CustomPostProcessing_ to your camera, and assign one of the included _Post-Processing Scan_ materials (or make your own).

![image](https://user-images.githubusercontent.com/37354140/148224103-2419e7d3-14e3-4b6d-9ae3-c89c3a5ff393.png)

2. Attach _PostProcessingScanOrigin_ to any object whose position you want to track as the scan origin. Assign the scan material.

![image](https://user-images.githubusercontent.com/37354140/148224143-e1e7feef-7abf-42ad-8710-b561c18be588.png)

#### Single Scan

Use Unity's Post-Processing Stack v2 and simply add the effect.

![image](https://user-images.githubusercontent.com/37354140/173141406-20aa2edd-5470-4cea-8d76-6e3e357d7c3c.png)

### URP

Instead of attaching a script to the camera, add CustomRenderPassFeature to your URP pipeline asset renderer and assign the material there.

![image](https://user-images.githubusercontent.com/37354140/173144456-60904e0a-4615-4831-8920-b2d92ec174b8.png)
![image](https://user-images.githubusercontent.com/37354140/173144396-f4525564-698e-4b04-a04e-1d148a7d7f1b.png)

## Social Media
- [Twitter](https://twitter.com/TheMirzaBeig/)
- [YouTube](https://www.youtube.com/c/MirzaBeig)

## License
[Unlicense](LICENSE) (do whatever you want with this)...

## Support/Donate...

This is a FREE asset. However, if you'd like, you can support me via one of the sponsor links on the side. 

Every bit is appreciated!

## Patrons (Thank You!)

- Adam Mulvey
