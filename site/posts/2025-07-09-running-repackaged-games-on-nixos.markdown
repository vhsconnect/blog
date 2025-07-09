Repackaged software is widely available but there is little information about how to run it on linux however far gaming on linux has come. I found this [great writeup](https://github.com/elmhadji/instal_repacks_in_Linux/blob/main/README.md) the other day and I wanted to summarize what worked for me running on NixOs.

## Introduction
The difference between a repacked game and a game you download from let's say St eam or Epi cgames is that those games are signed on the server prior to you getting your copy on the host. Repackaged games or simply - repacks - have a binary installer that does this "signing" instead of the game server. Lutris provides a nice interface to run that installer with the `Run EXE inside Wine prefix.` option.

TLDR. Install lutris and protonup-qt. Install the latest versions of wine through protonup-qt. Use lutris to run the installer and then game. 

## Packages to install?
[Lutris](https://search.nixos.org/packages?show=lutris) to manage your game installation, settings and launch
[ProtonUp-Qt](https://search.nixos.org/packages?show=protonup-qt) to manage your version of wine


## Configuring Lutris (optional)
1. **Open Lutris**: If it's your first time running Lutris, wait a few minutes for setup.
2. **Access Preferences** and do the following:
- disable Lutris Runtime
- disable screen saver
- prefer system librarie 


 ##  Installing versions of Wine through protonup-qt
 Proton up allows you to add and remove various Vulkan libraries and version of wine. These are the ones recommended to use with Lutris.

```

vkd3d (Experimental Direct3D to Vulkan layer)
dxvk (DirectX translation layer for Vulkan)
wine-ge (wine version with loads of patches)
lutris (lutris wine)
```


1. Open ProtonUp-Qt.
2. Select "Lutris" from the drop-down menu.
3. Click "Add version."
4. Select "Wine-GE" under "Compatibility tool."
5. Choose the latest non-lol version and click "Install."
6. Restart Lutris if it was open.

## Installing Windows Repacks in Lutris
1. Open Lutris.
2. Click on the '+' icon in the top left corner.
3. Click "Add locally installed game."
4. Enter the name of your game in the "Name" field.
5. Select "Wine (Run Windows games)" from the "Runner" list.
6. Go to the "Game options" tab and enable "Show advanced options."
7. The executable is empty for now - After you run the installer - i.e. `Setup.exe`, you can come back and add its path here.
8. In the "Wine prefix" field, enter the path where you want to create the prefix (e.g., `~/Games/my-game`).

9. Click on the game you just added.
10. Click the "Up" icon next to the "Wine Glass" icon on the bottom panel and select `Run EXE inside Wine prefix.`
11. Choose the "setup.exe" file from the repack folder and run it.
12. Follow the installer instructions, ensuring you install the game on the "C:\" drive within the Wine prefix.
13. Once that is done, you'll have to find the exe file and set it back in the field from earlier
14. Double click the game to launch it. You can adjust the settings for the game by right clicking it and hitting `Configure` 


## Troubleshooting
- I ran into this issue because my monitor wasn't set to start at pixels x:0 and y:0. You can use software like `wdisplays` to set it
