package;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.addons.display.FlxNestedSprite;

class PolygonSprite extends FlxSpriteGroup
{
    public static inline var RADIUS:Float = 100;

    public function new(centerX:Float, centerY:Float, numSides:Int, angle:Float):Void
    {
        super(centerX, centerY);

        var sideLength:Float = RADIUS * Math.sqrt(2*(1-Math.cos(2*Math.PI/numSides)));
        //var rectList:Array<FlxSprite> = new Array<FlxSprite>();
        var interiorAngle:Float = Math.PI*(numSides-2)/numSides;
        var apothemLength:Float = Math.sqrt(RADIUS*RADIUS-(sideLength/2)*(sideLength/2));
        for (i in 0...numSides)
        {
            var rectX:Float = apothemLength*Math.cos(Math.PI/numSides+2*i*Math.PI/numSides)-sideLength/2;
            var rectY:Float = apothemLength*Math.sin(Math.PI/numSides+2*i*Math.PI/numSides)-1;
            var rect:FlxSprite = new FlxSprite(rectX, rectY);
            rect.makeGraphic(cast sideLength, 3, FlxColor.WHITE);
            rect.angle = (i+0.5)*360.0/numSides+90;
            add(rect);
        }
        forEach(function(s:FlxSprite){s.origin.set(centerX, centerY);});
        this.angle = angle;
    }
}