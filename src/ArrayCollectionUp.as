package
{
	import mx.collections.ArrayCollection;
	
	public class ArrayCollectionUp extends ArrayCollection
	{
		public var indexUp:int;
		
		override public function setItemAt(item:Object, index:int):Object
		{
			// TODO Auto Generated method stub
			return super.setItemAt(item, index);
		}
		
		public function ArrayCollectionUp(source:Array=null)
		{
			super(source);
		}
		public function getItemIndexUp(item:Object):int{
			indexUp = this.getItemIndex(item);
			if(indexUp < 0){
				return this.source.indexOf(item);
			} else {
				return	indexUp;
			}
			
		}
			
		
		
	}
}