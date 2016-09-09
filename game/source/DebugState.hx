import flixel.FlxG;
import flixel.FlxState;

class DebugState extends FlxState
{
    override public function create():Void
    {
        super.create();
        FlxG.switchState(new TestState());
    }
}