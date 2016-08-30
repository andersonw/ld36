package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.math.FlxMath;

class BetterButton extends FlxTypedGroup<FlxSprite>
{
    public var buttonBorder:FlxSprite;
    public var buttonRect:FlxSprite;
    public var buttonText:FlxText;
    public var callback:Void->Void;
    var hovered:Bool;
    var pressed:Bool;

    override public function new(x:Float=0, y:Float=0, width:Float=0, height:Float=0, text:String="", fontSize = 16, ?onClick:Void->Void)
    {
        super();

        buttonBorder = new FlxSprite(x-1, y-1);
        buttonBorder.makeGraphic(cast width+2, cast height+2, FlxColor.WHITE);
        buttonRect = new FlxSprite(x, y);
        buttonRect.makeGraphic(cast width, cast height, FlxColor.BLACK);
        buttonText = new FlxText(text);
        buttonText.setFormat(Registry.FONT_PATH, fontSize);
        buttonText.x = x+width/2-buttonText.width/2;
        buttonText.y = y+height/2-buttonText.height/2;
        add(buttonBorder);
        add(buttonRect);
        add(buttonText);
        callback = onClick;
        hovered = false;
        pressed = false;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        var x:Float = FlxG.mouse.x;
        var y:Float = FlxG.mouse.y;
        var buttonWidth:Int = cast buttonRect.width;
        var buttonHeight:Int = cast buttonRect.height;
        if (x>buttonRect.x && x<(buttonRect.x+buttonWidth) && y>buttonRect.y && y<(buttonRect.y+buttonHeight))
        {
            if (pressed && FlxG.mouse.justReleased)
            {
                pressed = false;
                callback();
            }
            if (!hovered)
            {
                hovered = true;
                buttonRect.makeGraphic(buttonWidth, buttonHeight, FlxColor.RED);
            }
            if (!pressed && FlxG.mouse.justPressed)
            {
                pressed = true;
                buttonRect.makeGraphic(buttonWidth, buttonHeight, FlxColor.GREEN);
            }
        }
        else
        {
            if (hovered)
            {
                hovered = false;
                buttonRect.makeGraphic(buttonWidth, buttonHeight, FlxColor.BLACK);
            }
            if (pressed && FlxG.mouse.justReleased)
            {
                pressed = false;
                buttonRect.makeGraphic(buttonWidth, buttonHeight, FlxColor.BLACK);
            }
        }
    }
}