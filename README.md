# Fivem Character Scaling Script

Adjust your players’ height and weight dynamically using the native `SetEntityMatrix`.

## Features

- **Height & Weight Adjustment**  
  Uses `SetEntityMatrix` to change a ped’s height and width.
- **Admin‑Only Commands by Default**  
  All commands are restricted to admins out of the box (can be enabled for everyone via config).
- **Full Sync**  
  Changes are synchronized across all connected players.
- **High Performance**  
  Optimized for minimal impact on client tick rate.

## Known Issues

Because this relies on the native `SetEntityMatrix`, you may encounter:

- **Unchanged Hitbox**  
  The character’s collision bounds remain at the original size.
- **Animation Glitches**  
  During certain animations the ped may briefly revert to its default size.
- **In‑Vehicle Reversion**  
  While inside a vehicle, the character may snap back to its original dimensions.
- **Weight Scaling Limitations**  
  Increasing the weight scale can introduce more severe visual glitches.

## Requirements

- **ox_lib**

## Installation

1. Download the script from the [Releases](https://github.com/TGIANN/tgiann-ped-scale/releases) section.
2. Extract the downloaded files to your FiveM server's resource directory.
3. Add `ensure tgiann-ped-scale` to your server.cfg file.
4. Restart your FiveM server.

## License

This project is licensed under the GPL-3.0 License - see the [LICENSE](https://github.com/TGIANN/tgiann-ped-scale?tab=GPL-3.0-1-ov-file#readme) file for details.
