package lost.utils.effects
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.MovieClip;
	import flash.geom.Matrix;

	public class Reflect
	{
		public function Reflect()
		{
			
		}
		public static function reflectImage(img:MovieClip):void {
			var imgWidth:Number = img.width;
			var imgHeight:Number = img.height;
			
			//pixels kopiëren
			var bmd:BitmapData=new BitmapData(img.width,img.height,true,0xFFFFFF);
			bmd.draw(img);
			var reflectieBmp:Bitmap = new Bitmap(bmd);
			reflectieBmp.scaleY = -1;
			reflectieBmp.y = reflectieBmp.height*2;
			
			//make gradient from code
			var reflectionDegree:Number = 75;
			
			var matrix:Matrix = new Matrix()
			matrix.createGradientBox(1,reflectionDegree,Math.PI/2,0,0);
			
			var colors:Array = [0xFFFFFF,0x000000]
			var alphas:Array = [0.5,0]
			var ratios:Array = [0,0xFF]
			var maskMC:MovieClip = new MovieClip();
			
			maskMC.x = reflectieBmp.x;
			maskMC.y = reflectieBmp.y-reflectieBmp.height;
			maskMC.graphics.beginGradientFill(GradientType.LINEAR,colors,alphas,ratios,matrix);
			maskMC.graphics.drawRect(0,0,imgWidth,reflectionDegree);
			
			//om een gradient als mask te gebruiken  ==> cacheAsBitmap !!!
			maskMC.cacheAsBitmap = true;
			reflectieBmp.cacheAsBitmap=true;
			
			img.addChild(maskMC);
			img.addChild(reflectieBmp);
			
			reflectieBmp.mask = maskMC;
			
		}
		
	}
}