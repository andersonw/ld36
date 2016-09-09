package;

// do not use polyInd

class Point
{
    public var x:Float;
    public var y:Float;

    public var polyInd:Int;

    public function new(x:Float, y:Float, ind:Int = -1){
        this.x = x;
        this.y = y;
        // this.polyInd = ind;
        this.polyInd = -1;
    }

    public function add(q:Point):Void{
        this.x += q.x;
        this.y += q.y;
    }

    public function subtract(q:Point):Void{
        this.x -= q.x;
        this.y -= q.y;
    }

    public function crossWithThis(q:Point):Float{
        return this.x*q.y - this.y*q.x;
    }

    public function dotWithThis(q:Point):Float{
        return this.x * q.x + this.y * q.y;
    }

    public function update(xvel:Float, yvel:Float):Point{
        var newx = this.x + xvel;
        var newy = this.y + yvel;
        return new Point(newx, newy, this.polyInd);
    }

    public function rotatedCW(origin:Point, degAngle:Float){
        
        var c = Math.cos(Math.PI*degAngle/180);
        var s = Math.sin(Math.PI*degAngle/180);

        var d = minus(this, origin);
        var newd = new Point(d.x * c - d.y * s, d.x * s + d.y * c, polyInd);

        return plus(newd, origin);
    }

    public function updateWithPoint(vel:Point):Point{
        var newp = Point.plus(this, vel);
        newp.polyInd = this.polyInd;
        return newp;
    }

    public function addition(rhs:Point):Point{
        return new Point(this.x+rhs.x, this.y+rhs.y, this.polyInd);
    }

    public static function plus(a:Point, b:Point):Point{
        return new Point(a.x+b.x, a.y+b.y, a.polyInd);
    }

    public static function minus(a:Point, b:Point):Point{
        return new Point(a.x-b.x, a.y-b.y, a.polyInd);
    }

    public static function dot(a:Point, b:Point):Float{
        return a.x * b.x + a.y * b.y;
    }

    public static function cross(a:Point, b:Point):Float{
        return a.x * b.y - a.y * b.x;
    }

    public static function polarPoint(r:Float, theta:Float):Point{
        return new Point(r * Math.cos(theta), r * Math.sin(theta));
    }

    public function magnitude():Float{
        return Math.pow(Math.pow(this.x, 2) + Math.pow(this.y, 2), 0.5);
    }

    public function scale(factor:Float){
        return new Point(this.x * factor, this.y * factor, this.polyInd);
    }
}