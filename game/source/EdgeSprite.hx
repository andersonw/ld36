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
    }

    override public function update(elapsed:Float){
        // trace('begin update', this.x, this.y, this.angle);
        super.update(elapsed);
        // trace('end update', this.x, this.y, this.angle);
    }

    // public function edgeUpdate(elapsed:Float, parent:RegularPolygonSprite, i:Int){
    //     this.x = parent.x + parent.apothemLength
    // }
}