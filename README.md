# minetest-mod-supervanish
Minetest mod that allows you be invisible to other players. It can be used in singleplayer mode, *even if it is not useful*.

## Usage
* `/vanish [playername]` - make player or yourself invisible and immortal (from other players including vanish privilege users)
* `/vanished` - show list of vanished players
* Above commands require `vanish` priv to execute.
* `/supervanish [playername]` - make player or yourself superinvisible and immortal (noone can see you or list your name). *However you can still appear in logged users*.
* This command require `supervanish` priv to execute.

> [!NOTE]
> It is *impossible* to change the visibility according to the player and therefore vanished people cannot be seen even by people with vanish or supervanish privilege. However, they can be listed and unvanished.

## Legal
The code is a fork from [Minetest mod vanish](https://github.com/zmv7/minetest-mod-vanish) under GPL3 and is therefore under the same license.