package;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class EdgeSprite extends FlxSprite
{
    public var p1:Point;
    public var p2:Point;
    public var center:Point;

    public function new(X:Float = 0, Y:Float = 0){
        super(X, Y);
        
        setXYA(0, 0, 0);
        FlxG.watch.add(this, "p1");
    }

    override public function update(elapsed:Float){
        super.update(elapsed);
    }

    public function setXYA(x:Float, y:Float, angle:Float){
        this.x = x;
        this.y = y;
        this.center = new Point(x + this.width/2, y + this.height/2);
        this.angle = angle;

        var radAngle:Float = angle * Math.PI / 180;
        p1 = new Point(center.x - width*Math.cos(radAngle)/2, center.y - width*Math.sin(radAngle)/2);
        p2 = new Point(center.x + width*Math.cos(radAngle)/2, center.y + width*Math.sin(radAngle)/2);

    }
}