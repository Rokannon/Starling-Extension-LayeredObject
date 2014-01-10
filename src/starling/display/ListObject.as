package starling.display {
	
	
	/**
	 * Internal data object.
	 * 
	 * @author Vladimir Atamanov
	 */
	internal class ListObject {
		
		public var layerName:String;
		public var list:Vector.<DisplayObject>;
		public var layeredObject:LayeredObject;
		
		public function ListObject() {
			
			list = new Vector.<DisplayObject>();
			
		}
		
	}
	
}