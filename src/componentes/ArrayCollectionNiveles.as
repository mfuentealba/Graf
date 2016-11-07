package componentes
{
	import modelo.Modelo;
	
	import mx.collections.ArrayCollection;
	
	public class ArrayCollectionNiveles extends ArrayCollection
	{
		public function ArrayCollectionNiveles(source:Array=null)
		{
			super(source);
		}
		
		override public function addItem(item:Object):void
		{
			// TODO Auto Generated method stub
			if(Modelo.getInstance().objMin.hasOwnProperty(this.source.join('|') + '|' + item['num']){
				Modelo.getInstance().arrMaximos.removeItemAt(Modelo.getInstance().arrMaximos.getItemIndex(this));
			} else {
				
				super.addItem(item);
				Modelo.getInstance().objMin[this.source.join('|')] = this;
			}
			
		}
		
		override public function addItemAt(item:Object, index:int):void
		{
			// TODO Auto Generated method stub
			super.addItemAt(item, index);
		}
		
		override public function removeItemAt(index:int):Object
		{
			// TODO Auto Generated method stub
			return super.removeItemAt(index);
			if(Modelo.getInstance().objMin.hasOwnProperty(this.source.join('|')){
				Modelo.getInstance().arrMaximos.removeItemAt(Modelo.getInstance().arrMaximos.getItemIndex(this));
			} else {
				Modelo.getInstance().objMin[this.source.join('|')] = this;
			}
		}
		
	}
}