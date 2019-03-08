# ZScript Material #

This script makes it easier to use GZDoom's new (v3.7) destructible geometry feature. It does this by providing an event handler, which assigns *materials* to lines, floors, ceilings and 3D floors based on texture (though they can also be assigned manually). Materials, like actors, have Health and DamageFactor properties, allowing level geometry to have strengths and weaknesses to different damage types. The event handler also defines several new events, allowing you to customize a material's behavior when it's damaged or destroyed.

## Tutorial ##

In this tutorial, we'll create a forcefield material which is immune to hitscan weapons, fades out as it's damaged, and regenerates over time. To create a new material, the first thing we need to do is define an `EventHandler` that descends from `MaterialHandler`. Create a new PK3 file, and place `material_handler.zc` inside it, in a directory called `zscript`. Create `zscript.zc` in the PK3's root directory, and define the handler inside it:

```cpp
version "3.7.2"

#include "zscript/material_handler.zc"

class ForcefieldHandler : MaterialHandler
{
}
```

In order for the game to recognize this event handler, we need to register it in `mapinfo.lmp`:

```cpp
GameInfo
{
    AddEventHandlers = "ForcefieldHandler"
}
```

Now that we have a material handler, we need to assign it to level geometry. The primary way to do this is to specify textures it corresponds to. The `MaterialHandler` class contains a dynamic array of texture names, called `textures`. When a level loads, it looks for pieces of level geometry with these textures, and applies the material to each one. We can add a texture to this array by overriding the initialization method `OnRegister`. As for what texture to use, `FIREBLU1` looks strange and shimmery enough to be a forcefield:

```cpp
class ForcefieldHandler : MaterialHandler
{
    override void OnRegister()
    {
        textures.Push("FIREBLU1");
    }
}
```

If you start GZDoom with this PK3 loaded, the forcefield material should be applied to every instance of the `FIREBLU1` texture. But our material doesn't actually have any properties, so this won't do an awful lot. Our next task is to make the material destructible. We do this by setting its health. `health` is just an `int`, so all you need to do is set it > 0 in `OnRegister`.

```cpp
override void OnRegister()
{
    textures.Push("FIREBLU1");
    health = 200;
}
```

If you'd like, create a map and place a two-sided line somewhere, with `FIREBLU1` as its mid-texture, on both sides. If the line is two-sided, the texture has to be on both sides, but only the mid-texture matters. Make sure to set the line to block everything. Now load up the game, and attack it. Eventually, the line will be destroyed, and you (and your bullets) can pass through it. The texture won't change or disappear, yet, but the forcefield can be destroyed.

To make the forcefield disappear, we should override the appropriate event. In this case, that would be `MaterialLineDestroyed`, which takes a `WorldEvent` containing a pointer to the line in question (`damageLine`), and a lot of other info that isn't relevant, at the moment. See the [ZDoom wiki](https://zdoom.org/wiki/Events_and_handlers) for more info. What we want to do is set the line's alpha to 0, which we can do like so:

```cpp
override void MaterialLineDestroyed(WorldEvent e)
{
    Super.MaterialLineDestroyed(e);
    e.damageLine.alpha = 0;
}
```

Make sure to call `Super.MaterialLineDestroyed`, since it contains the code to actually destroy the forcefield. Otherwise, it would just become an invisible wall.

This is entirely functional, but we can add a little more visual feedback, if we want. Let's have the forcefield fade out gradually as it's damaged. Override the event `MaterialLineTick`, which takes a line as an argument:

```cpp
override void MaterialLineTick(Line l)
{
    l.alpha = double(l.GetHealth()) / health;
}
```

Note: `MaterialLineTick` is only triggered for lines that haven't been destroyed. This means that the line in `MaterialLineDestroyed`, which sets the alpha to 0, is necessary. If it weren't there the forcefield would keep whatever opacity it had just before it was destroyed.

Let's add a few more effects, just to show what this script is capable of. First, we can make the forcefield regenerate its health, over time, by changing `MaterialLineTick`.

```cpp
override void MaterialLineTick(Line l)
{
    l.SetHealth(Min(l.GetHealth() + 1, health));
    l.alpha = double(l.GetHealth()) / health;
}
```

We can also make the forcefield immune to hitscan weapons, using the `SetDamageFactor` method:

```cpp
override void OnRegister()
{
    textures.Push("FIREBLU1");
    health = 200;
    SetDamageFactor("Hitscan", 0);
}
```

These are a few of the things that are possible with material handlers. There are more examples in the demo, or you can peruse the source code.