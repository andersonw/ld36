package;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;

class SumoGameState extends BasicGameState
{
    //assume that game field is symmetric, so the playing rectangle is located
    //gameFieldXMargin from the left and right, gameFieldYMargin from the top and bottom
    var gameFieldXMargin:Float = 60;
    var gameFieldYMargin:Float = 60;
    var gameField:FlxSprite;
    var gameFieldOutline:FlxSprite;

    var countdownText:FlxText;
    var timeToGameStart:Float;
    var gameStarted:Bool;

    override public function create():Void
    {
        gameField = new FlxSprite(gameFieldXMargin, gameFieldYMargin);
        gameFieldOutline = new FlxSprite(gameFieldXMargin-2, gameFieldYMargin-2);
        add(gameFieldOutline);
        add(gameField);
        //creating now so width and height get defined
        super.create();

        gameFieldOutline.makeGraphic(cast width-2*gameFieldXMargin+4, cast height-2*gameFieldYMargin+4, FlxColor.WHITE);
        gameField.makeGraphic(cast width-2*gameFieldXMargin, cast height-2*gameFieldYMargin, FlxColor.BLACK);

        addSprites();

        countdownText = new FlxText();
        countdownText.setFormat(20);
        add(countdownText);
        resetCountdown();
    }

    public function addSprites():Void
    {
        makeSprite(new NewPolygonSprite(110, 240, Registry.player1Sides, 0, 50, FlxColor.YELLOW), [W, A, S, D]);
        makeSprite(new NewPolygonSprite(530, 240, Registry.player2Sides, 180, 50, FlxColor.LIME), [UP, LEFT, DOWN, RIGHT]);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (!gameStarted)
        {
            pause();
            timeToGameStart -= elapsed;
            if (timeToGameStart>0)
            {
                updateCountdownText();
            }
            else
            {
                gameStarted = true;
                countdownText.visible = false;
                unpause();
            }
            return;
        }  

        if (isPlayerDead(0))
        {
            trace("Player 2 wins!");
            Registry.player2Sides += 1;
            resetGame();
        }
        else if (isPlayerDead(1))
        {
            trace("Player 1 wins!");
            Registry.player1Sides += 1;
            resetGame();
        }
    }
    //extremely simple right now, maybe we want to check if the edges themselves are outside the box
    public function isPlayerDead(playerNum:Int):Bool
    {
        var player:NewPolygonSprite = playSprites[playerNum];
        if (player.x < gameFieldXMargin-player.RADIUS ||
            player.x > width-gameFieldXMargin+player.RADIUS ||
            player.y < gameFieldYMargin-player.RADIUS ||
            player.y > height-gameFieldYMargin+player.RADIUS)
        {
            return true;
        }
        return false;
    }

    public function resetGame():Void
    {
        for (sprite in playSprites)
        {
            sprite.destroy();
        }
        playSprites = new Array<NewPolygonSprite>();
        velocities = new Array<Point>();
        aVelocities = new Array<Float>();
        keyLists = new Array<Array<FlxKey>>();
        addSprites();
        resetCountdown();
    }

    public function resetCountdown():Void
    {
        countdownText.visible = true;
        timeToGameStart = 3;
        gameStarted = false;
    }

    public function updateCountdownText():Void
    {
        countdownText.text = Std.string(Math.ceil(timeToGameStart));
        countdownText.x = (width-countdownText.width)/2;
        countdownText.y = (height-countdownText.height)/2;
    }
}