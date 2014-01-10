# Starling-Extension-LayeredObject

This extension adds special type of DisplayObjectContainer with layers. Developer can link several DisplayObjects together and manipulate their transform as a whole. Such logic of display fits very well for games with top-down view. Consider following example:

```
const TORSO_LAYER:String = "torsoLayer";
const LEGS_LAYER:String = "legsLayer";

// Creating special container for DisplayObjects linked 
// to layers.
var monster:LayeredObject = new LayeredObject();
monster.addChildToLayer(monsterLegs, LEGS_LAYER);
monster.addChildToLayer(monsterTorso, TORSO_LAYER);

// Same for player character. Notice that order of adding 
// won't result overall order of display.
var player:LayeredObject = new LayeredObject();
player.addChildToLayer(playerTorso, TORSO_LAYER);
player.addChildToLayer(playerLegs, LEGS_LAYER);

// Now creating container for above two objects.
// Order of layer creation effects display order.
var worldContainer:LayeredContainer = new LayeredContainer();
worldContainer.createLayer(LEGS_LAYER);
worldContainer.createLayer(TORSO_LAYER);
worldContainer.addChild(player);
worldContainer.addChild(monster);

// Every DisplayObject from torso layer will 
// always be above every DisplayObject from 
// legs level. Regardless to children order 
// in 'player' and 'monster' containers.

// However this does not affect transform of 
// these DisplayObjects. Following line of code 
// will rotate whole container with both torso 
// and legs of player.
player.rotation = 0.5 * Math.PI;
```

#### Garbage collection

Methods 'createLayer' and 'addChildToLayer' require memory allocation to hold internal data. So their opposite methods ('deleteLayer' and 'removeChild') may have caused unwanted call to garbage collector. To prevent that internal data objects are pooled. For the same reason I am not using 'splice' method as it creates unnecessary array object.

#### Notes

- LayeredObject extends DisplayObjectContainer class. Adding it to regular DisplayObjectContainer will result displaying all it's children in order respecting standard children indices.
- LayeredContainer displays only those DisplayObjects that are linked to existing layer within some LayeredObject. So calling addChild with non-LayeredObject argument is useless.
- Calling 'dispose' method from either LayeredObject or LayeredContainer classes with result releasing all their internal data objects back to pool.
