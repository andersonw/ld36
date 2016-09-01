package;

import flixel.util.FlxColor;
import flixel.FlxSprite;

class EdgeSprite extends FlxSprite
{
    public p1:Point;
    public p2:Point;
    public center:Point;
    public parentSprite:RegularPolygonSprite;

    public function new(){
        super();
    }
}