package;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.addons.display.FlxNestedSprite;
import flixel.group.FlxGroup;

class RegularPolygonSprite extends FlxTypedGroup<EdgeSprite>
{
    public var x:Float;
    public var y:Float;
    public var mx:Float;
    public var my:Float;
    public var center:Point;
    public var angle:Float;

    public var RADIUS:Float;
    public var numSides:Int;
    public var sideLength:Float;
    public var interiorAngle:Float;
    public var apothemLength:Float;
    

    public var parent:BasicGameState;
    public var color:FlxColor;
    
    public var isExploding:Bool;
    // var relativeX:Array<Float>;

    var gameObjects:Array<GameObject>;
    
    // var expVels:Array<Point>;
    // var aVels:Array<Float>;


    public function new(centerX:Float, centerY:Float, numSides:Int, angle:Float, radius:Float = 100, ?parentState:BasicGameState, color:FlxColor=FlxColor.WHITE):Void
    {
        super();

        this.x = centerX;
        this.y = centerY;
        this.mx = x;
        this.my = y; // TODO: make my = -y and so forth
        this.center = new Point(mx, my);
        this.angle = angle;

        this.RADIUS = radius;
        this.numSides = numSides;
        sideLength = RADIUS * Math.sqrt(2*(1-Math.cos(2*Math.PI/numSides)));
        interiorAngle = Math.PI*(numSides-2)/numSides;
        apothemLength = Math.sqrt(RADIUS*RADIUS-(sideLength/2)*(sideLength/2));

        this.parent = parentState;
        this.color = color;
        this.isExploding = false;

        gameObjects = new Array<GameObject>();

        createRects();

        update(0);
    }

    private function createRects():Void
    {
        // create indicator
        var indicator = new EdgeSprite(0, -2);
        indicator.makeGraphic(cast RADIUS, 4, color);
        add(indicator);

        // create sides
        for (i in 0...numSides)
        {
            var rect:EdgeSprite = new EdgeSprite();
            rect.makeGraphic(cast sideLength, 3, color);
            add(rect);
        }
    }

    override public function update(elapsed:Float){

        //deal with indicator
        var indicator:EdgeSprite = members[0]; //Anderson likes explicit typing
        indicator.x = x + RADIUS*(Math.cos(angle*Math.PI/180)-1)/2;
        indicator.y = y + RADIUS*Math.sin(angle*Math.PI/180)/2 - 2;
        indicator.angle = angle;

        for(i in 1...members.length){
            if(!isExploding)
                updateEdge(i);
        }
        for(obj in gameObjects){
            obj.update(elapsed);
        }

    }

    public function newUpdate(elapsed:Float, velX:Float, velY:Float, aVel:Float){
        mx += velX * 60 * elapsed;
        my += velY * 60 * elapsed;
        center = new Point(mx, my);
        x = mx;
        y = my;

        angle += aVel * 60 * elapsed;
    }

    public function updateEdge(i:Int){
        var rect:EdgeSprite = members[i];
        var rectx = x + apothemLength*Math.cos(Math.PI/numSides+2*i*Math.PI/numSides + angle*Math.PI/180)-sideLength/2;
        var recty = y + apothemLength*Math.sin(Math.PI/numSides+2*i*Math.PI/numSides + angle*Math.PI/180)-1;
        var rectAngle = (i+0.5)*360.0/numSides + 90 + angle;
        rect.setXYA(rectx, recty, rectAngle);
    }

    /*
    To be called when the polygon dies.
    Polygon is expected to be deleted soon after.
    */
    public function explode():Void{
        isExploding = true;
        for(i in 0...members.length){
            var rect:EdgeSprite = members[i];
            var angleAway = rect.angle + 180 * Math.random() - 90;
            var speed = 2 + Math.random() * 5;
            var gobj = new GameObject(rect, Point.polarPoint(speed, angleAway), Math.random()*30-15, this.color);
            gameObjects.push(gobj);
        }
    }
}
