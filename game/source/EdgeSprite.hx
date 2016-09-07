package;

import flixel.util.FlxColor;
import flixel.FlxSprite;

class EdgeSprite extends FlxSprite
{
    public var p1:Point;
    public var p2:Point;
    public var center:Point;
    // public parentSprite:RegularPolygonSprite;

    // public function new(){
    //     super();
    // }

    public function new(X:Float = 0, Y:Float = 0){
        super(X, Y);
        // setXYA(X, Y, 0);
    }

    override public function update(elapsed:Float){
        // trace('begin update', this.x, this.y, this.angle);
        super.update(elapsed);
        // trace('end update', this.x, this.y, this.angle);
    }

    public function setXYA(x:Float, y:Float, angle:Float){
        // trace('setxya', x, y, angle);
        this.x = x;
        this.y = y;
        this.center = new Point(x + this.width/2, y + this.height/2);
        this.angle = angle;

        var radAngle:Float = angle * Math.PI / 180;
        p1 = new Point(center.x - width*Math.cos(radAngle)/2, center.y - width*Math.sin(radAngle)/2);
        p2 = new Point(center.x + width*Math.cos(radAngle)/2, center.y + width*Math.sin(radAngle)/2);
        // trace(p1);
        // trace(p2);

    }
}