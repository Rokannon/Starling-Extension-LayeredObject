package starling.display {
	
	
	/**
	 * Internal data object.
	 * 
	 * @author Vladimir Atamanov
	 */
	internal class ListObject {
		
		public const list:Vector.<DisplayObject> = new Vector.<DisplayObject>();
		
		public var layerName:String;
		public var layeredObject:LayeredObject;
		
		public function ListObject() {
			
		}
		
	}
	
}