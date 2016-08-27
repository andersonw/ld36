package;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.addons.display.FlxNestedSprite;
import flixel.group.FlxGroup;

class NewPolygonSprite extends FlxTypedGroup<FlxSprite>
{
    public static inline var RADIUS:Float = 100;
    public var x:Float;
    public var y:Float;
    public var angle:Float;
    var numSides:Int;
    var relativeX:Array<Float>;


    public function new(centerX:Float, centerY:Float, numSides:Int, angle:Float):Void
    {
        super();

        //makeGraphic(0,0);
        this.numSides = numSides;
        this.x = centerX;
        this.y = centerY;
        this.angle = angle;

        var sideLength:Float = RADIUS * Math.sqrt(2*(1-Math.cos(2*Math.PI/numSides)));
        var interiorAngle:Float = Math.PI*(numSides-2)/numSides;
        var apothemLength:Float = Math.sqrt(RADIUS*RADIUS-(sideLength/2)*(sideLength/2));

        var indicator = new FlxSprite(0, -2);
        indicator.makeGraphic(cast RADIUS, 4, FlxColor.WHITE);
        add(indicator);

        for (i in 0...numSides)
        {
            /*var rectX:Float = centerX + apothemLength*Math.cos(Math.PI/numSides+2*i*Math.PI/numSides)-sideLength/2;
            var rectY:Float = centerY + apothemLength*Math.sin(Math.PI/numSides+2*i*Math.PI/numSides)-1;*/
            var rect:FlxSprite = new FlxSprite();
            rect.makeGraphic(cast sideLength, 3, FlxColor.WHITE);
            //rect.angle = (i+0.5)*360.0/numSides+90;
            add(rect);
        }

        //forEach(function(s:FlxSprite){s.origin.set(centerX, centerY);});
        this.angle = angle;
        update(0);
    }

    override public function update(elapsed:Float){
        super.update(elapsed);

        var sideLength:Float = RADIUS * Math.sqrt(2*(1-Math.cos(2*Math.PI/numSides)));
        var interiorAngle:Float = Math.PI*(numSides-2)/numSides;
        var apothemLength:Float = Math.sqrt(RADIUS*RADIUS-(sideLength/2)*(sideLength/2));

        //deal with indicator
        var indicator:FlxSprite = members[0]; //Anderson likes explicit typing
        indicator.x = x + RADIUS*(Math.cos(angle*Math.PI/180)-1)/2 - 2*Math.cos(angle*Math.PI/180);
        indicator.y = y + RADIUS*Math.sin(angle*Math.PI/180)/2 - 2*Math.sin(angle*Math.PI/180);
        indicator.angle = angle;

        for(i in 1...members.length)
        {
            var rect:FlxSprite = members[i];
            rect.x = x + apothemLength*Math.cos(Math.PI/numSides+2*i*Math.PI/numSides + angle*Math.PI/180)-sideLength/2; 
            rect.y = y + apothemLength*Math.sin(Math.PI/numSides+2*i*Math.PI/numSides + angle*Math.PI/180)-1;
            rect.angle = (i+0.5)*360.0/numSides + 90 + angle;
        }
    }
}
