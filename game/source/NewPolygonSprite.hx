package;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.addons.display.FlxNestedSprite;
import flixel.group.FlxGroup;

class NewPolygonSprite extends FlxTypedGroup<FlxSprite>
{
    public var RADIUS:Float;
    public var x:Float;
    public var y:Float;
    public var angle:Float;
    public var numSides:Int;
    public var parent:BasicGameState;
    public var color:FlxColor;
    public var isExploding:Bool;
    var relativeX:Array<Float>;

    var gameObjects:Array<GameObject>;
    
    var expVels:Array<Point>;
    var aVels:Array<Float>;


    public function new(centerX:Float, centerY:Float, numSides:Int, angle:Float, radius:Float = 100, ?parentState:BasicGameState, color:FlxColor=FlxColor.WHITE):Void
    {
        super();

        RADIUS = radius;
        //makeGraphic(0,0);
        this.numSides = numSides;
        this.x = centerX;
        this.y = centerY;
        this.angle = angle;
        this.RADIUS = radius;
        this.parent = parentState;
        this.color = color;
        this.isExploding = false;

        gameObjects = new Array<GameObject>();

        var sideLength:Float = RADIUS * Math.sqrt(2*(1-Math.cos(2*Math.PI/numSides)));
        var interiorAngle:Float = Math.PI*(numSides-2)/numSides;
        var apothemLength:Float = Math.sqrt(RADIUS*RADIUS-(sideLength/2)*(sideLength/2));

        var indicator = new FlxSprite(0, -2);
        indicator.makeGraphic(cast RADIUS, 4, color);
        add(indicator);

        for (i in 0...numSides)
        {
            /*var rectX:Float = centerX + apothemLength*Math.cos(Math.PI/numSides+2*i*Math.PI/numSides)-sideLength/2;
            var rectY:Float = centerY + apothemLength*Math.sin(Math.PI/numSides+2*i*Math.PI/numSides)-1;*/
            var rect:FlxSprite = new FlxSprite();
            rect.makeGraphic(cast sideLength, 3, color);
            //rect.angle = (i+0.5)*360.0/numSides+90;
            add(rect);
        }

        //forEach(function(s:FlxSprite){s.origin.set(centerX, centerY);});
        this.angle = angle;
        update(0);
    }

    override public function update(elapsed:Float){
        // trace(numSides);
        super.update(elapsed);

        var sideLength:Float = RADIUS * Math.sqrt(2*(1-Math.cos(2*Math.PI/numSides)));
        var interiorAngle:Float = Math.PI*(numSides-2)/numSides;
        var apothemLength:Float = Math.sqrt(RADIUS*RADIUS-(sideLength/2)*(sideLength/2));

        //deal with indicator
        var indicator:FlxSprite = members[0]; //Anderson likes explicit typing
        indicator.x = x + RADIUS*(Math.cos(angle*Math.PI/180)-1)/2;
        indicator.y = y + RADIUS*Math.sin(angle*Math.PI/180)/2 - 2;
        indicator.angle = angle;

        for(i in 1...members.length)
        {
            var rect:FlxSprite = members[i];
            if(!isExploding){
                rect.x = x + apothemLength*Math.cos(Math.PI/numSides+2*i*Math.PI/numSides + angle*Math.PI/180)-sideLength/2; 
                rect.y = y + apothemLength*Math.sin(Math.PI/numSides+2*i*Math.PI/numSides + angle*Math.PI/180)-1;
                rect.angle = (i+0.5)*360.0/numSides + 90 + angle;
            }
            else{

            }
        }
        for(obj in gameObjects){
            obj.update(elapsed);
        }
    }

    /*
    To be called when the polygon dies.
    Polygon is expected to be deleted soon after.
    */
    public function explode():Void{
        isExploding = true;
        for(i in 0...members.length){
            var rect:FlxSprite = members[i];
            var angleAway = rect.angle + 180 * Math.random() - 90;
            var speed = 2 + Math.random() * 5;
            var gobj = new GameObject(rect, Point.polarPoint(speed, angleAway), Math.random()*30-15, this.color);
            gameObjects.push(gobj);
        }
    }
}
